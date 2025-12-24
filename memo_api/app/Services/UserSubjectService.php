<?php

namespace App\Services;

use App\Models\User;
use App\Models\Subject;
use App\Models\UserSubject;
use Illuminate\Support\Collection;

class UserSubjectService
{
    /**
     * Get user subjects with optional stats.
     */
    public function getUserSubjects(User $user, bool $includeStats = false): Collection
    {
        $userSubjects = UserSubject::where('user_id', $user->id)
            ->with('subject')
            ->byPriority()
            ->get();

        if (!$includeStats) {
            return $userSubjects;
        }

        // Add stats to each subject
        return $userSubjects->map(function ($userSubject) use ($user) {
            $userSubject->stats = $this->getSubjectStats($user, $userSubject->subject);
            return $userSubject;
        });
    }

    /**
     * Update subject settings for a user.
     */
    public function updateSubjectSettings(User $user, Subject $subject, array $settings): UserSubject
    {
        $userSubject = UserSubject::where('user_id', $user->id)
            ->where('subject_id', $subject->id)
            ->firstOrFail();

        // Update settings
        $userSubject->update($settings);

        // Recalculate priority score
        $userSubject->updatePriorityScore();

        return $userSubject->fresh();
    }

    /**
     * Calculate priority score for a user subject.
     */
    public function calculatePriorityScore(UserSubject $userSubject): float
    {
        return $userSubject->calculatePriorityScore();
    }

    /**
     * Recalculate all subject priorities for a user.
     */
    public function recalculateAllPriorities(User $user): void
    {
        $userSubjects = UserSubject::where('user_id', $user->id)->get();

        foreach ($userSubjects as $userSubject) {
            $userSubject->updatePriorityScore();
        }
    }

    /**
     * Get statistics for a specific subject.
     */
    public function getSubjectStats(User $user, Subject $subject): array
    {
        // Get total study time for this subject
        $studySessions = $user->studySessions()
            ->where('subject_id', $subject->id)
            ->get();

        $totalMinutes = $studySessions->sum('duration_minutes');
        $sessionsCount = $studySessions->count();

        // Get last session
        $lastSession = $user->studySessions()
            ->where('subject_id', $subject->id)
            ->orderBy('started_at', 'desc')
            ->first();

        // Get quiz average (placeholder - depends on quiz system implementation)
        $averageScore = 0.0;

        // Get weekly progress
        $weekStart = now()->startOfWeek();
        $weeklyMinutes = $user->studySessions()
            ->where('subject_id', $subject->id)
            ->where('started_at', '>=', $weekStart)
            ->sum('duration_minutes');

        // Get user subject settings
        $userSubject = UserSubject::where('user_id', $user->id)
            ->where('subject_id', $subject->id)
            ->first();

        $weeklyGoal = $userSubject?->weekly_goal_minutes ?? 0;
        $weeklyProgress = $weeklyGoal > 0 ? round(($weeklyMinutes / $weeklyGoal) * 100, 1) : 0;

        return [
            'total_study_minutes' => $totalMinutes,
            'total_study_hours' => round($totalMinutes / 60, 1),
            'sessions_count' => $sessionsCount,
            'last_session_date' => $lastSession?->started_at?->toDateString(),
            'average_quiz_score' => $averageScore,
            'weekly_minutes' => $weeklyMinutes,
            'weekly_goal' => $weeklyGoal,
            'weekly_progress_percentage' => $weeklyProgress,
        ];
    }

    /**
     * Add subjects to user based on stream.
     */
    public function addSubjectsFromStream(User $user, int $streamId): int
    {
        $subjects = Subject::forStream($streamId)->get();
        $count = 0;

        foreach ($subjects as $subject) {
            // Check if already exists
            $exists = UserSubject::where('user_id', $user->id)
                ->where('subject_id', $subject->id)
                ->exists();

            if (!$exists) {
                UserSubject::create([
                    'user_id' => $user->id,
                    'subject_id' => $subject->id,
                    'coefficient' => $subject->coefficient,
                    'difficulty_level' => 'medium',
                    'weekly_goal_minutes' => 0,
                    'session_duration' => 45,
                    'is_favorite' => false,
                ]);
                $count++;
            }
        }

        // Recalculate priorities
        $this->recalculateAllPriorities($user);

        return $count;
    }

    /**
     * Remove a subject from user.
     */
    public function removeSubject(User $user, Subject $subject): bool
    {
        $deleted = UserSubject::where('user_id', $user->id)
            ->where('subject_id', $subject->id)
            ->delete();

        return $deleted > 0;
    }

    /**
     * Set weekly goals based on total available hours.
     */
    public function distributeWeeklyGoals(User $user, int $totalWeeklyHours): array
    {
        $totalMinutes = $totalWeeklyHours * 60;

        $userSubjects = UserSubject::where('user_id', $user->id)
            ->with('subject')
            ->get();

        if ($userSubjects->isEmpty()) {
            return [];
        }

        // Calculate total coefficient weight
        $totalCoefficient = $userSubjects->sum('coefficient');

        $distribution = [];

        foreach ($userSubjects as $userSubject) {
            // Distribute proportionally based on coefficient
            $proportion = $userSubject->coefficient / $totalCoefficient;
            $allocatedMinutes = round($totalMinutes * $proportion);

            $userSubject->update(['weekly_goal_minutes' => $allocatedMinutes]);
            $userSubject->updatePriorityScore();

            $distribution[] = [
                'subject' => $userSubject->subject->name_ar,
                'coefficient' => $userSubject->coefficient,
                'weekly_goal_hours' => round($allocatedMinutes / 60, 1),
                'weekly_goal_minutes' => $allocatedMinutes,
            ];
        }

        return $distribution;
    }

    /**
     * Get subjects that need attention (behind on goals).
     */
    public function getSubjectsNeedingAttention(User $user): Collection
    {
        $weekStart = now()->startOfWeek();

        $userSubjects = UserSubject::where('user_id', $user->id)
            ->where('weekly_goal_minutes', '>', 0)
            ->with('subject')
            ->get();

        return $userSubjects->filter(function ($userSubject) use ($user, $weekStart) {
            $studiedMinutes = $user->studySessions()
                ->where('subject_id', $userSubject->subject_id)
                ->where('started_at', '>=', $weekStart)
                ->sum('duration_minutes');

            $goalMinutes = $userSubject->weekly_goal_minutes;
            $progress = $goalMinutes > 0 ? ($studiedMinutes / $goalMinutes) * 100 : 100;

            // Return subjects with less than 50% progress
            return $progress < 50;
        })->values();
    }

    /**
     * Toggle favorite status for a subject.
     */
    public function toggleFavorite(User $user, Subject $subject): bool
    {
        $userSubject = UserSubject::where('user_id', $user->id)
            ->where('subject_id', $subject->id)
            ->firstOrFail();

        $newStatus = !$userSubject->is_favorite;
        $userSubject->update(['is_favorite' => $newStatus]);
        $userSubject->updatePriorityScore();

        return $newStatus;
    }
}
