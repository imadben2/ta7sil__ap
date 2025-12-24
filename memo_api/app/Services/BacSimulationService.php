<?php

namespace App\Services;

use App\Models\BacSimulation;
use App\Models\BacSubject;
use App\Models\UserBacPerformance;
use App\Models\User;
use App\Events\BacSimulationCompleted;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class BacSimulationService
{
    /**
     * Start a new BAC simulation
     */
    public function startSimulation(User $user, int $bacSubjectId)
    {
        // Check if user has an active simulation
        $activeSimulation = BacSimulation::where('user_id', $user->id)
            ->where('status', 'started')
            ->first();

        if ($activeSimulation) {
            // Check if it has expired
            if ($activeSimulation->hasExpired()) {
                $activeSimulation->markAsAbandoned();
            } else {
                throw new \Exception('لديك محاكاة نشطة بالفعل. يرجى إكمالها أولاً.');
            }
        }

        // Get BAC subject
        $bacSubject = BacSubject::with(['bacYear', 'bacSession', 'subject', 'academicStream', 'chapters'])
            ->findOrFail($bacSubjectId);

        // Create new simulation with time limit
        $timeLimitSeconds = $bacSubject->duration_minutes * 60;

        $simulation = BacSimulation::create([
            'user_id' => $user->id,
            'bac_subject_id' => $bacSubjectId,
            'started_at' => now(),
            'duration_seconds' => 0,
            'time_limit_seconds' => $timeLimitSeconds,
            'status' => 'started'
        ]);

        // Increment simulation count on the subject
        $bacSubject->incrementSimulations();

        return [
            'simulation' => $simulation,
            'bac_subject' => $bacSubject,
            'duration_minutes' => $bacSubject->duration_minutes,
            'chapters' => $bacSubject->chapters,
        ];
    }

    /**
     * Get active simulation for user
     */
    public function getActiveSimulation(User $user)
    {
        $simulation = BacSimulation::where('user_id', $user->id)
            ->where('status', 'started')
            ->with(['bacSubject.bacYear', 'bacSubject.bacSession', 'bacSubject.subject', 'bacSubject.chapters'])
            ->first();

        if (!$simulation) {
            return null;
        }

        // Check if expired
        if ($simulation->hasExpired()) {
            $simulation->markAsAbandoned();
            return null;
        }

        return [
            'simulation' => $simulation,
            'bac_subject' => $simulation->bacSubject,
            'remaining_seconds' => $simulation->getRemainingTimeSeconds(),
            'chapters' => $simulation->bacSubject->chapters,
        ];
    }

    /**
     * Submit simulation results
     */
    public function submitSimulation(User $user, int $simulationId, array $results)
    {
        DB::beginTransaction();

        try {
            // Get simulation
            $simulation = BacSimulation::where('id', $simulationId)
                ->where('user_id', $user->id)
                ->where('status', 'started')
                ->with('bacSubject')
                ->firstOrFail();

            // Check if expired
            if ($simulation->hasExpired()) {
                $simulation->markAsAbandoned();
                throw new \Exception('انتهى وقت المحاكاة');
            }

            // Extract submission data
            $overallScore = $results['overall_score'] ?? 0;
            $chapterScores = $results['chapter_scores'] ?? [];
            $difficultyFelt = $results['difficulty_felt'] ?? null;
            $userNotes = $results['user_notes'] ?? null;

            // Save all submission data using the new method
            $simulation->saveSubmissionData([
                'user_score' => $overallScore,
                'chapter_scores' => $chapterScores,
                'difficulty_felt' => $difficultyFelt,
                'user_notes' => $userNotes
            ]);

            // Update the BAC subject's average score
            $simulation->bacSubject->updateAverageScore($overallScore);

            // Update or create performance record
            $performance = UserBacPerformance::firstOrNew([
                'user_id' => $user->id,
                'subject_id' => $simulation->bacSubject->subject_id
            ]);

            $performance->updateAfterSimulation($overallScore, $chapterScores);

            DB::commit();

            // Reload simulation to get fresh data
            $simulation->refresh();

            // Get weak chapters for event
            $weakChaptersData = $performance->getWeakChaptersWithDetails();
            $weakChapters = $weakChaptersData ? $weakChaptersData->toArray() : [];

            // Dispatch event for planner integration
            event(new BacSimulationCompleted($simulation, $performance, $weakChapters));

            return [
                'simulation' => $simulation,
                'performance' => $performance,
                'score' => $overallScore,
                'percentage' => $simulation->getPercentage(),
                'grade' => $simulation->getGradeLabel(),
                'weak_chapters' => $weakChaptersData,
            ];
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Abandon simulation
     */
    public function abandonSimulation(User $user, int $simulationId)
    {
        $simulation = BacSimulation::where('id', $simulationId)
            ->where('user_id', $user->id)
            ->where('status', 'started')
            ->firstOrFail();

        $simulation->markAsAbandoned();

        return $simulation;
    }

    /**
     * Get user's simulation history
     */
    public function getUserSimulations(User $user, array $filters = [])
    {
        $query = BacSimulation::where('user_id', $user->id)
            ->with(['bacSubject.bacYear', 'bacSubject.bacSession', 'bacSubject.subject']);

        if (isset($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        if (isset($filters['subject_id'])) {
            $query->whereHas('bacSubject', function ($q) use ($filters) {
                $q->where('subject_id', $filters['subject_id']);
            });
        }

        return $query->orderBy('started_at', 'desc')->paginate(20);
    }

    /**
     * Get user's performance for a subject
     */
    public function getUserPerformance(User $user, int $subjectId)
    {
        $performance = UserBacPerformance::where('user_id', $user->id)
            ->where('subject_id', $subjectId)
            ->with('subject')
            ->first();

        if (!$performance) {
            return null;
        }

        return [
            'total_simulations' => $performance->total_simulations,
            'average_score' => $performance->average_score,
            'best_score' => $performance->best_score,
            'weak_chapters' => $performance->getWeakChaptersWithDetails(),
            'subject' => $performance->subject,
        ];
    }

    /**
     * Get all user performances
     */
    public function getAllUserPerformances(User $user)
    {
        return UserBacPerformance::where('user_id', $user->id)
            ->with('subject')
            ->orderBy('updated_at', 'desc')
            ->get()
            ->map(function ($performance) {
                return [
                    'subject' => $performance->subject,
                    'total_simulations' => $performance->total_simulations,
                    'average_score' => $performance->average_score,
                    'best_score' => $performance->best_score,
                    'weak_chapters_count' => count($performance->weak_chapters ?? []),
                ];
            });
    }

    /**
     * Get simulation statistics
     */
    public function getSimulationStatistics()
    {
        return [
            'total_simulations' => BacSimulation::count(),
            'completed_simulations' => BacSimulation::where('status', 'completed')->count(),
            'active_simulations' => BacSimulation::where('status', 'started')->count(),
            'abandoned_simulations' => BacSimulation::where('status', 'abandoned')->count(),
            'average_duration' => BacSimulation::where('status', 'completed')
                ->avg('duration_seconds'),
            'simulations_by_subject' => BacSimulation::selectRaw('bac_subject_id, COUNT(*) as count')
                ->where('status', 'completed')
                ->groupBy('bac_subject_id')
                ->with('bacSubject')
                ->get(),
        ];
    }

    /**
     * Clean up expired simulations
     */
    public function cleanupExpiredSimulations()
    {
        $expiredCount = 0;

        $activeSimulations = BacSimulation::where('status', 'started')
            ->with('bacSubject')
            ->get();

        foreach ($activeSimulations as $simulation) {
            if ($simulation->hasExpired()) {
                $simulation->markAsAbandoned();
                $expiredCount++;
            }
        }

        return $expiredCount;
    }
}
