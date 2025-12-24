<?php

namespace App\Services;

use App\Models\User;
use App\Models\StudySession;
use App\Models\StudySchedule;
use App\Models\PlannerSetting;
use App\Models\SubjectPriority;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;

class AdaptationService
{
    protected SessionService $sessionService;
    protected PriorityCalculationService $priorityService;
    protected PlannerService $plannerService;

    public function __construct(
        SessionService $sessionService,
        PriorityCalculationService $priorityService,
        PlannerService $plannerService
    ) {
        $this->sessionService = $sessionService;
        $this->priorityService = $priorityService;
        $this->plannerService = $plannerService;
    }

    /**
     * Analyze user behavior and adapt schedule
     */
    public function adaptScheduleForUser(User $user): array
    {
        $adaptations = [];

        // Check for missed sessions and reschedule if enabled
        $missedSessions = $this->handleMissedSessions($user);
        if ($missedSessions > 0) {
            $adaptations[] = "Handled {$missedSessions} missed sessions";
        }

        // Analyze performance patterns
        $performanceAdjustments = $this->analyzePerformancePatterns($user);
        if (!empty($performanceAdjustments)) {
            $adaptations[] = "Applied performance-based adjustments";
        }

        // Adjust priorities based on recent activity
        $priorityUpdates = $this->adjustPrioritiesBasedOnActivity($user);
        if ($priorityUpdates > 0) {
            $adaptations[] = "Updated {$priorityUpdates} subject priorities";
        }

        // Optimize session times based on energy patterns
        $timeOptimizations = $this->optimizeSessionTimes($user);
        if ($timeOptimizations > 0) {
            $adaptations[] = "Optimized {$timeOptimizations} session times";
        }

        return $adaptations;
    }

    /**
     * Handle missed sessions with rescheduling
     */
    protected function handleMissedSessions(User $user): int
    {
        $settings = $user->plannerSetting;

        if (!$settings || !$settings->auto_reschedule_missed) {
            return 0;
        }

        // Mark missed sessions
        $missedCount = $this->sessionService->checkAndMarkMissedSessions($user);

        // Get active schedule
        $activeSchedule = StudySchedule::where('user_id', $user->id)
            ->where('status', 'active')
            ->first();

        if (!$activeSchedule) {
            return $missedCount;
        }

        // Get missed sessions from today
        $missedSessions = StudySession::where('user_id', $user->id)
            ->where('status', 'missed')
            ->whereDate('scheduled_date', today())
            ->get();

        // Try to reschedule each missed session
        foreach ($missedSessions as $session) {
            $this->rescheduleToNextAvailableSlot($user, $session, $activeSchedule);
        }

        return $missedCount;
    }

    /**
     * Reschedule session to next available slot
     */
    protected function rescheduleToNextAvailableSlot(
        User $user,
        StudySession $missedSession,
        StudySchedule $schedule
    ): ?StudySession {
        // Find available slots in the next 7 days
        $startDate = Carbon::tomorrow();
        $endDate = Carbon::now()->addDays(7);

        // Get existing sessions in this period
        $existingSessions = StudySession::where('user_id', $user->id)
            ->where('status', 'scheduled')
            ->whereBetween('scheduled_date', [$startDate->toDateString(), $endDate->toDateString()])
            ->orderBy('scheduled_date')
            ->orderBy('scheduled_start_time')
            ->get();

        // Try each day
        for ($date = $startDate->copy(); $date->lte($endDate); $date->addDay()) {
            $settings = $user->plannerSetting;
            $studyStart = Carbon::parse($date->format('Y-m-d') . ' ' . $settings->study_start_time);
            $studyEnd = Carbon::parse($date->format('Y-m-d') . ' ' . $settings->study_end_time);

            // Find gaps in existing sessions
            $daysSessions = $existingSessions->filter(function ($session) use ($date) {
                return $session->scheduled_start->isSameDay($date);
            })->sortBy('scheduled_start');

            $currentTime = $studyStart->copy();

            foreach ($daysSessions as $session) {
                $gapDuration = $currentTime->diffInMinutes($session->scheduled_start);

                if ($gapDuration >= $missedSession->planned_duration_minutes) {
                    // Found a slot!
                    return $this->sessionService->rescheduleSession(
                        $missedSession,
                        $currentTime->copy(),
                        $currentTime->copy()->addMinutes($missedSession->planned_duration_minutes)
                    );
                }

                $currentTime = $session->scheduled_end->copy();
            }

            // Check if there's space at the end
            $remainingTime = $currentTime->diffInMinutes($studyEnd);
            if ($remainingTime >= $missedSession->planned_duration_minutes) {
                return $this->sessionService->rescheduleSession(
                    $missedSession,
                    $currentTime->copy(),
                    $currentTime->copy()->addMinutes($missedSession->planned_duration_minutes)
                );
            }
        }

        Log::warning("Could not find slot to reschedule session {$missedSession->id}");
        return null;
    }

    /**
     * Analyze performance patterns and suggest adjustments
     */
    protected function analyzePerformancePatterns(User $user): array
    {
        $adjustments = [];

        // Get recent sessions (last 30 days)
        $recentSessions = StudySession::where('user_id', $user->id)
            ->where('status', 'completed')
            ->where('created_at', '>=', Carbon::now()->subDays(30))
            ->get();

        if ($recentSessions->isEmpty()) {
            return [];
        }

        // Analyze focus scores by time of day
        $focusPatterns = $recentSessions->groupBy(function ($session) {
            $hour = $session->scheduled_start->hour;
            if ($hour >= 5 && $hour < 12) return 'morning';
            if ($hour >= 12 && $hour < 17) return 'afternoon';
            if ($hour >= 17 && $hour < 22) return 'evening';
            return 'night';
        })->map(function ($sessions) {
            return $sessions->whereNotNull('focus_score')->avg('focus_score');
        });

        // Update user's energy levels based on performance
        $settings = $user->plannerSetting;
        if ($settings) {
            foreach ($focusPatterns as $timeOfDay => $avgFocus) {
                $energyLevel = $this->focusScoreToEnergyLevel($avgFocus);
                $field = $timeOfDay . '_energy';

                if ($settings->$field !== $energyLevel) {
                    $settings->update([$field => $energyLevel]);
                    $adjustments[] = "Updated {$timeOfDay} energy to {$energyLevel}";
                }
            }
        }

        // Analyze completion rates by subject
        $subjectCompletion = $recentSessions->groupBy('subject_id')->map(function ($sessions) {
            $total = $sessions->count();
            $completed = $sessions->where('completion_percentage', '>=', 80)->count();
            return $total > 0 ? ($completed / $total) * 100 : 0;
        });

        // Flag subjects with low completion rates for adjustment
        foreach ($subjectCompletion as $subjectId => $completionRate) {
            if ($completionRate < 50) {
                $adjustments[] = "Subject {$subjectId} has low completion rate: {$completionRate}%";
            }
        }

        return $adjustments;
    }

    /**
     * Convert focus score to energy level
     */
    protected function focusScoreToEnergyLevel(?float $avgFocus): string
    {
        if (!$avgFocus) return 'medium';

        if ($avgFocus >= 8) return 'high';
        if ($avgFocus >= 5) return 'medium';
        return 'low';
    }

    /**
     * Adjust priorities based on recent activity
     */
    protected function adjustPrioritiesBasedOnActivity(User $user): int
    {
        // Recalculate all priorities
        $this->priorityService->calculateAllPriorities($user);

        // Count subjects with updated priorities
        return SubjectPriority::where('user_id', $user->id)
            ->where('last_calculated_at', '>=', Carbon::now()->subMinutes(5))
            ->count();
    }

    /**
     * Optimize session times based on historical performance
     */
    protected function optimizeSessionTimes(User $user): int
    {
        $optimizations = 0;

        // Get upcoming sessions
        $upcomingSessions = $this->sessionService->getUpcomingSessions($user, 7);

        foreach ($upcomingSessions as $session) {
            // Get historical performance for this subject at this time of day
            $hourOfDay = $session->scheduled_start->hour;
            $similarSessions = StudySession::where('user_id', $user->id)
                ->where('subject_id', $session->subject_id)
                ->where('status', 'completed')
                ->whereRaw('HOUR(scheduled_start_time) = ?', [$hourOfDay])
                ->whereNotNull('focus_score')
                ->get();

            if ($similarSessions->isEmpty()) {
                continue;
            }

            $avgFocus = $similarSessions->avg('focus_score');

            // If focus is consistently low at this time, suggest moving
            if ($avgFocus < 5 && !$session->is_pinned) {
                // Try to find a better time slot
                $betterTimes = $this->findBetterTimeSlots($user, $session, $similarSessions);

                if (!empty($betterTimes)) {
                    Log::info("Session {$session->id} could be moved to a better time slot");
                    $optimizations++;
                }
            }
        }

        return $optimizations;
    }

    /**
     * Find better time slots based on historical performance
     */
    protected function findBetterTimeSlots(User $user, StudySession $session, $similarSessions): array
    {
        // Group similar sessions by hour and get average focus
        $performanceByHour = $similarSessions->groupBy(function ($s) {
            return $s->scheduled_start->hour;
        })->map(function ($sessions) {
            return $sessions->avg('focus_score');
        })->sortDesc();

        // Return top 3 time slots
        return $performanceByHour->take(3)->toArray();
    }

    /**
     * Detect patterns in user behavior
     */
    public function detectBehaviorPatterns(User $user): array
    {
        $patterns = [];

        // Get last 60 days of sessions
        $sessions = StudySession::where('user_id', $user->id)
            ->where('created_at', '>=', Carbon::now()->subDays(60))
            ->orderBy('scheduled_date')
            ->orderBy('scheduled_start_time')
            ->get();

        if ($sessions->isEmpty()) {
            return ['message' => 'Not enough data to detect patterns'];
        }

        // Pattern 1: Most productive time of day
        $productiveTime = $sessions->where('status', 'completed')
            ->groupBy(function ($s) {
                $hour = $s->scheduled_start->hour;
                if ($hour >= 5 && $hour < 12) return 'morning';
                if ($hour >= 12 && $hour < 17) return 'afternoon';
                if ($hour >= 17 && $hour < 22) return 'evening';
                return 'night';
            })
            ->map(function ($sessions) {
                return $sessions->avg('focus_score');
            })
            ->sortDesc()
            ->first();

        $patterns['most_productive_time'] = $productiveTime;

        // Pattern 2: Consistency score
        $completedCount = $sessions->where('status', 'completed')->count();
        $consistencyScore = $sessions->count() > 0 ? ($completedCount / $sessions->count()) * 100 : 0;
        $patterns['consistency_score'] = round($consistencyScore, 2);

        // Pattern 3: Preferred session duration
        $avgActualDuration = $sessions->where('status', 'completed')
            ->avg('actual_duration_minutes');
        $patterns['preferred_session_duration'] = round($avgActualDuration ?? 0);

        // Pattern 4: Subject preferences (by completion rate)
        $subjectPreferences = $sessions->groupBy('subject_id')
            ->map(function ($subjectSessions) {
                $completed = $subjectSessions->where('status', 'completed')->count();
                return $subjectSessions->count() > 0 ? ($completed / $subjectSessions->count()) * 100 : 0;
            })
            ->sortDesc();

        $patterns['subject_completion_rates'] = $subjectPreferences->toArray();

        return $patterns;
    }
}
