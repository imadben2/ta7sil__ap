<?php

namespace App\Services;

use App\Models\StudySession;
use App\Models\User;
use Carbon\Carbon;

class PointsCalculationService
{
    /**
     * Calculate points for completing a study session
     * Based on documentation: Base 10 points + bonuses
     *
     * Bonuses:
     * - Duration: +5 points for sessions >= 45 min
     * - Mood: +3 points for positive mood, -2 for negative
     * - Streak: +5 points for 3+ consecutive days
     * - On-time: +2 points for starting within 5 min of scheduled time
     *
     * Maximum: 25 points per session
     */
    public function calculateSessionPoints(StudySession $session, ?string $mood = null): int
    {
        $points = 10; // Base points

        // Bonus 1: Duration bonus (+5 for >= 45 minutes)
        if ($session->actual_duration >= 45) {
            $points += 5;
        }

        // Bonus 2: Mood bonus (+3 for happy, 0 for neutral, -2 for sad)
        if ($mood === 'happy') {
            $points += 3;
        } elseif ($mood === 'sad') {
            $points -= 2;
        }

        // Bonus 3: Streak bonus (+5 for 3+ consecutive days)
        $streakBonus = $this->calculateStreakBonus($session->user_id);
        $points += $streakBonus;

        // Bonus 4: On-time bonus (+2 for starting within 5 min of scheduled time)
        $onTimeBonus = $this->calculateOnTimeBonus($session);
        $points += $onTimeBonus;

        // Ensure points are non-negative and capped at 25
        return max(0, min(25, $points));
    }

    /**
     * Calculate streak bonus based on consecutive days of completed sessions
     */
    private function calculateStreakBonus(int $userId): int
    {
        $consecutiveDays = $this->getConsecutiveDaysStreak($userId);

        if ($consecutiveDays >= 3) {
            return 5;
        }

        return 0;
    }

    /**
     * Get number of consecutive days with at least one completed session
     */
    private function getConsecutiveDaysStreak(int $userId): int
    {
        $streak = 0;
        $currentDate = Carbon::today();

        for ($i = 0; $i < 30; $i++) { // Check last 30 days max
            $hasCompletedSession = StudySession::where('user_id', $userId)
                ->where('status', 'completed')
                ->whereDate('scheduled_at', $currentDate)
                ->exists();

            if ($hasCompletedSession) {
                $streak++;
                $currentDate = $currentDate->subDay();
            } else {
                break; // Streak broken
            }
        }

        return $streak;
    }

    /**
     * Calculate on-time bonus if session started within 5 minutes of scheduled time
     */
    private function calculateOnTimeBonus(StudySession $session): int
    {
        if (!$session->actual_start_time || !$session->scheduled_at) {
            return 0;
        }

        $scheduledTime = Carbon::parse($session->scheduled_at);
        $actualStartTime = Carbon::parse($session->actual_start_time);

        $diff = abs($scheduledTime->diffInMinutes($actualStartTime));

        if ($diff <= 5) {
            return 2;
        }

        return 0;
    }

    /**
     * Award points to user and update level
     */
    public function awardPoints(User $user, int $points): void
    {
        $user->total_points += $points;

        // Update level (100 points per level)
        $this->updateUserLevel($user);

        $user->save();
    }

    /**
     * Update user level based on total points
     * Level formula: level = floor(total_points / 100) + 1
     */
    private function updateUserLevel(User $user): void
    {
        $pointsPerLevel = 100;
        $newLevel = floor($user->total_points / $pointsPerLevel) + 1;

        if ($newLevel != $user->current_level) {
            $user->current_level = $newLevel;
        }

        // Calculate points needed for next level
        $user->points_to_next_level = ($newLevel * $pointsPerLevel) - $user->total_points;
    }

    /**
     * Get user's current points and level information
     */
    public function getUserPointsInfo(User $user): array
    {
        return [
            'total_points' => $user->total_points,
            'current_level' => $user->current_level,
            'points_to_next_level' => $user->points_to_next_level,
            'level_progress_percentage' => $this->getLevelProgressPercentage($user),
        ];
    }

    /**
     * Calculate percentage progress to next level
     */
    private function getLevelProgressPercentage(User $user): int
    {
        $pointsPerLevel = 100;
        $currentLevelStart = ($user->current_level - 1) * $pointsPerLevel;
        $pointsInCurrentLevel = $user->total_points - $currentLevelStart;

        return (int) (($pointsInCurrentLevel / $pointsPerLevel) * 100);
    }

    /**
     * Get recent points history for user
     */
    public function getRecentPointsHistory(int $userId, int $days = 7): array
    {
        $sessions = StudySession::where('user_id', $userId)
            ->where('status', 'completed')
            ->where('completed_at', '>=', Carbon::now()->subDays($days))
            ->orderBy('completed_at', 'desc')
            ->get();

        return $sessions->map(function($session) {
            return [
                'date' => $session->completed_at,
                'session_id' => $session->id,
                'subject_name' => $session->subject->name_ar ?? 'N/A',
                'points_earned' => $session->points_earned ?? 0,
                'mood' => $session->mood ?? null,
            ];
        })->toArray();
    }

    /**
     * Calculate penalty points for skipping a session
     * Penalty: -5 points (can't go below 0 total)
     */
    public function calculateSkipPenalty(): int
    {
        return -5;
    }

    /**
     * Apply skip penalty to user
     */
    public function applySkipPenalty(User $user): int
    {
        $penalty = $this->calculateSkipPenalty();

        // Ensure user doesn't go below 0 points
        $newTotal = max(0, $user->total_points + $penalty);
        $actualPenalty = $user->total_points - $newTotal;

        $user->total_points = $newTotal;
        $this->updateUserLevel($user);
        $user->save();

        return $actualPenalty;
    }

    /**
     * Calculate penalty points for missing a session
     * Penalty: -2 points (lighter than skip since it's automatic)
     */
    public function calculateMissPenalty(): int
    {
        return -2;
    }

    /**
     * Apply miss penalty to user
     */
    public function applyMissPenalty(User $user): int
    {
        $penalty = $this->calculateMissPenalty();

        // Ensure user doesn't go below 0 points
        $newTotal = max(0, $user->total_points + $penalty);
        $actualPenalty = $user->total_points - $newTotal;

        $user->total_points = $newTotal;
        $this->updateUserLevel($user);
        $user->save();

        return $actualPenalty;
    }

    /**
     * Get points summary for user
     */
    public function getPointsSummary(User $user, int $periodDays = 30): array
    {
        $startDate = Carbon::now()->subDays($periodDays);

        // Get completed sessions
        $completedSessions = StudySession::where('user_id', $user->id)
            ->where('status', 'completed')
            ->where('completed_at', '>=', $startDate)
            ->get();

        // Get skipped sessions
        $skippedSessions = StudySession::where('user_id', $user->id)
            ->where('status', 'skipped')
            ->where('updated_at', '>=', $startDate)
            ->count();

        // Get missed sessions
        $missedSessions = StudySession::where('user_id', $user->id)
            ->where('status', 'missed')
            ->where('updated_at', '>=', $startDate)
            ->count();

        $totalEarned = $completedSessions->sum('points_earned');
        $totalPenalties = ($skippedSessions * 5) + ($missedSessions * 2);

        return [
            'period_days' => $periodDays,
            'total_earned' => $totalEarned,
            'total_penalties' => $totalPenalties,
            'net_points' => $totalEarned - $totalPenalties,
            'completed_sessions' => $completedSessions->count(),
            'skipped_sessions' => $skippedSessions,
            'missed_sessions' => $missedSessions,
            'average_points_per_session' => $completedSessions->count() > 0
                ? round($totalEarned / $completedSessions->count(), 1)
                : 0,
        ];
    }
}
