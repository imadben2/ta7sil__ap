<?php

namespace App\Services;

use App\Models\User;
use App\Models\StudySession;
use App\Models\SessionActivity;
use App\Models\PlannerSetting;
use Carbon\Carbon;
use Illuminate\Support\Collection;

class SessionService
{
    protected $pointsCalculationService;

    public function __construct(PointsCalculationService $pointsCalculationService)
    {
        $this->pointsCalculationService = $pointsCalculationService;
    }
    /**
     * Start a study session
     */
    public function startSession(StudySession $session): SessionActivity
    {
        // Update session status and actual start time
        $session->update([
            'status' => 'in_progress',
            'actual_start' => now(),
        ]);

        // Create start activity
        return SessionActivity::create([
            'study_session_id' => $session->id,
            'activity_type' => 'start',
            'activity_time' => now(),
            'metadata' => [
                'scheduled_start' => $session->scheduled_start,
                'actual_start' => now(),
            ],
        ]);
    }

    /**
     * Pause a study session
     */
    public function pauseSession(StudySession $session, ?string $reason = null): SessionActivity
    {
        if ($session->status !== 'in_progress') {
            throw new \Exception('Cannot pause a session that is not in progress');
        }

        // Create pause activity
        return SessionActivity::create([
            'study_session_id' => $session->id,
            'activity_type' => 'pause',
            'activity_time' => now(),
            'metadata' => [
                'reason' => $reason,
            ],
        ]);
    }

    /**
     * Resume a paused study session
     */
    public function resumeSession(StudySession $session): SessionActivity
    {
        // Create resume activity
        return SessionActivity::create([
            'study_session_id' => $session->id,
            'activity_type' => 'resume',
            'activity_time' => now(),
        ]);
    }

    /**
     * Complete a study session
     */
    public function completeSession(
        StudySession $session,
        int $completionPercentage = 100,
        ?int $focusScore = null,
        ?int $difficultyRating = null,
        ?string $notes = null,
        ?string $mood = null
    ): SessionActivity {
        // Calculate actual duration
        $actualDuration = 0;
        if ($session->actual_start) {
            $actualDuration = $session->actual_start->diffInMinutes(now());

            // Subtract pause durations
            $pauseDuration = $this->calculatePauseDuration($session);
            $actualDuration -= $pauseDuration;
        }

        // Calculate points earned
        $pointsEarned = $this->pointsCalculationService->calculateSessionPoints($session, $mood);

        // Award points to user
        $this->pointsCalculationService->awardPoints($session->user, $pointsEarned);

        // Update session
        $session->update([
            'status' => 'completed',
            'actual_end' => now(),
            'actual_duration_minutes' => $actualDuration,
            'completion_percentage' => $completionPercentage,
            'focus_score' => $focusScore,
            'difficulty_rating' => $difficultyRating,
            'notes' => $notes,
            'mood' => $mood,
            'points_earned' => $pointsEarned,
        ]);

        // Create completion activity
        return SessionActivity::create([
            'study_session_id' => $session->id,
            'activity_type' => 'complete',
            'activity_time' => now(),
            'metadata' => [
                'completion_percentage' => $completionPercentage,
                'focus_score' => $focusScore,
                'difficulty_rating' => $difficultyRating,
                'actual_duration_minutes' => $actualDuration,
                'mood' => $mood,
                'points_earned' => $pointsEarned,
            ],
        ]);
    }

    /**
     * Calculate total pause duration for a session
     */
    protected function calculatePauseDuration(StudySession $session): int
    {
        $activities = $session->activities()
            ->whereIn('activity_type', ['pause', 'resume'])
            ->orderBy('activity_time')
            ->get();

        $totalPauseDuration = 0;
        $lastPauseTime = null;

        foreach ($activities as $activity) {
            if ($activity->activity_type === 'pause') {
                $lastPauseTime = $activity->activity_time;
            } elseif ($activity->activity_type === 'resume' && $lastPauseTime) {
                $totalPauseDuration += $lastPauseTime->diffInMinutes($activity->activity_time);
                $lastPauseTime = null;
            }
        }

        // If session ended while paused, count pause until now
        if ($lastPauseTime) {
            $totalPauseDuration += $lastPauseTime->diffInMinutes(now());
        }

        return $totalPauseDuration;
    }

    /**
     * Skip a session (voluntary)
     */
    public function skipSession(StudySession $session, ?string $reason = null): SessionActivity
    {
        if ($session->status !== 'scheduled' && $session->status !== 'in_progress') {
            throw new \Exception('Cannot skip a session that is not scheduled or in progress');
        }

        // Apply penalty points for skipping
        $penalty = $this->pointsCalculationService->applySkipPenalty($session->user);

        // Update session status
        $session->update([
            'status' => 'skipped',
            'points_earned' => -$penalty, // Store the negative points
        ]);

        // Create skip activity
        return SessionActivity::create([
            'study_session_id' => $session->id,
            'activity_type' => 'skip',
            'activity_time' => now(),
            'metadata' => [
                'reason' => $reason,
                'penalty_applied' => $penalty,
            ],
        ]);
    }

    /**
     * Mark a session as missed
     */
    public function markSessionAsMissed(StudySession $session, ?string $reason = null): void
    {
        // Apply penalty points for missing
        $penalty = $this->pointsCalculationService->applyMissPenalty($session->user);

        $session->update([
            'status' => 'missed',
            'points_earned' => -$penalty, // Store the negative points
        ]);

        SessionActivity::create([
            'study_session_id' => $session->id,
            'activity_type' => 'missed',
            'activity_time' => now(),
            'metadata' => [
                'marked_as_missed' => true,
                'reason' => $reason,
                'penalty_applied' => $penalty,
            ],
        ]);
    }

    /**
     * Reschedule a session
     */
    public function rescheduleSession(
        StudySession $session,
        Carbon $newStart,
        Carbon $newEnd
    ): StudySession {
        // Create new session with updated times
        $newSession = $session->replicate();
        $newSession->scheduled_start = $newStart;
        $newSession->scheduled_end = $newEnd;
        $newSession->planned_duration_minutes = $newStart->diffInMinutes($newEnd);
        $newSession->rescheduled_from = $session->id;
        $newSession->status = 'scheduled';
        $newSession->save();

        // Mark old session as rescheduled
        $session->update([
            'status' => 'rescheduled',
        ]);

        return $newSession;
    }

    /**
     * Get today's sessions for a user
     */
    public function getTodaySessions(User $user): Collection
    {
        return StudySession::where('user_id', $user->id)
            ->whereDate('scheduled_date', today())
            ->with(['subject', 'activities'])
            ->orderBy('scheduled_start_time')
            ->get();
    }

    /**
     * Get upcoming sessions for a user
     */
    public function getUpcomingSessions(User $user, int $days = 7): Collection
    {
        return StudySession::where('user_id', $user->id)
            ->where('status', 'scheduled')
            ->whereBetween('scheduled_date', [now()->toDateString(), now()->addDays($days)->toDateString()])
            ->with(['subject', 'studySchedule'])
            ->orderBy('scheduled_date')
            ->orderBy('scheduled_start_time')
            ->get();
    }

    /**
     * Get current active session for a user
     */
    public function getCurrentSession(User $user): ?StudySession
    {
        return StudySession::where('user_id', $user->id)
            ->where('status', 'in_progress')
            ->with(['subject', 'activities'])
            ->first();
    }

    /**
     * Check for missed sessions and mark them
     */
    public function checkAndMarkMissedSessions(User $user): int
    {
        $now = now();
        $missedSessions = StudySession::where('user_id', $user->id)
            ->where('status', 'scheduled')
            ->where(function($query) use ($now) {
                $query->where('scheduled_date', '<', $now->toDateString())
                    ->orWhere(function($q) use ($now) {
                        $q->where('scheduled_date', '=', $now->toDateString())
                          ->whereRaw("CONCAT(scheduled_date, ' ', scheduled_end_time) < ?", [$now]);
                    });
            })
            ->get();

        foreach ($missedSessions as $session) {
            $this->markSessionAsMissed($session, 'Automatically marked as missed');
        }

        return $missedSessions->count();
    }

    /**
     * Get session statistics for a user
     */
    public function getSessionStatistics(User $user, ?Carbon $startDate = null, ?Carbon $endDate = null): array
    {
        $query = StudySession::where('user_id', $user->id);

        if ($startDate) {
            $query->where('scheduled_date', '>=', $startDate->toDateString());
        }

        if ($endDate) {
            $query->where('scheduled_date', '<=', $endDate->toDateString());
        }

        $sessions = $query->get();

        return [
            'total_sessions' => $sessions->count(),
            'completed_sessions' => $sessions->where('status', 'completed')->count(),
            'missed_sessions' => $sessions->where('status', 'missed')->count(),
            'in_progress_sessions' => $sessions->where('status', 'in_progress')->count(),
            'total_study_hours' => $sessions->where('status', 'completed')->sum('actual_duration_minutes') / 60,
            'average_completion_percentage' => $sessions->where('status', 'completed')->avg('completion_percentage'),
            'average_focus_score' => $sessions->where('status', 'completed')->whereNotNull('focus_score')->avg('focus_score'),
            'average_difficulty_rating' => $sessions->where('status', 'completed')->whereNotNull('difficulty_rating')->avg('difficulty_rating'),
            'completion_rate' => $sessions->count() > 0
                ? ($sessions->where('status', 'completed')->count() / $sessions->count()) * 100
                : 0,
        ];
    }

    /**
     * Pin/Unpin a session
     */
    public function togglePinSession(StudySession $session): void
    {
        $session->update([
            'is_pinned' => !$session->is_pinned,
        ]);
    }

    /**
     * Suggest content for a session based on subject and session type
     */
    public function suggestContentForSession(StudySession $session): ?int
    {
        // Get content for this subject that hasn't been covered recently
        $recentlyCovered = StudySession::where('user_id', $session->user_id)
            ->where('subject_id', $session->subject_id)
            ->whereNotNull('suggested_content_id')
            ->where('created_at', '>=', now()->subDays(14))
            ->pluck('suggested_content_id')
            ->toArray();

        $content = \App\Models\Content::where('subject_id', $session->subject_id)
            ->whereNotIn('id', $recentlyCovered)
            ->inRandomOrder()
            ->first();

        if ($content) {
            $session->update([
                'suggested_content_id' => $content->id,
            ]);

            return $content->id;
        }

        return null;
    }
}
