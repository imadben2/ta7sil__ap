<?php

namespace App\Services;

use App\Models\User;
use App\Models\UserStats;
use App\Models\Subject;
use App\Models\StudySession;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class StatisticsService
{
    /**
     * Update study statistics after a study session.
     */
    public function updateStudyStats(User $user, int $minutes, ?Subject $subject = null): void
    {
        $stats = UserStats::firstOrCreate(['user_id' => $user->id]);

        // Update total study minutes
        $stats->increment('total_study_minutes', $minutes);

        // Update streak
        $this->updateStreak($user);

        // Update gamification points
        $points = $this->calculateSessionPoints($minutes);
        $stats->increment('gamification_points', $points);

        // Update level based on points
        $newLevel = $this->calculateLevel($stats->gamification_points);
        if ($newLevel > $stats->level) {
            $stats->update(['level' => $newLevel]);
        }

        // Update last study date
        $stats->update(['last_study_date' => now()->toDateString()]);
    }

    /**
     * Update user streak.
     */
    public function updateStreak(User $user): void
    {
        $stats = UserStats::firstOrCreate(['user_id' => $user->id]);

        $today = now()->toDateString();
        $lastStudyDate = $stats->last_study_date;

        if (!$lastStudyDate) {
            // First session ever
            $stats->update([
                'current_streak_days' => 1,
                'longest_streak_days' => 1,
                'last_study_date' => $today,
            ]);
            return;
        }

        $daysSinceLastStudy = Carbon::parse($lastStudyDate)->diffInDays(now());

        if ($daysSinceLastStudy === 0) {
            // Already studied today, no change
            return;
        } elseif ($daysSinceLastStudy === 1) {
            // Consecutive day - increment streak
            $newStreak = $stats->current_streak_days + 1;
            $stats->update([
                'current_streak_days' => $newStreak,
                'longest_streak_days' => max($stats->longest_streak_days, $newStreak),
                'last_study_date' => $today,
            ]);

            // Bonus points for maintaining streak
            if ($newStreak % 7 === 0) {
                // Weekly streak bonus
                $stats->increment('gamification_points', 50);
            } else {
                $stats->increment('gamification_points', 5);
            }
        } else {
            // Streak broken - reset to 1
            $stats->update([
                'current_streak_days' => 1,
                'last_study_date' => $today,
            ]);
        }
    }

    /**
     * Calculate average quiz score for a user.
     */
    public function calculateAverageScore(User $user, ?Subject $subject = null): float
    {
        $stats = $user->stats;

        if (!$stats || $stats->total_quiz_attempts === 0) {
            return 0.0;
        }

        if ($subject) {
            // Calculate for specific subject
            // This would require quiz attempt data with subject_id
            // Placeholder for now
            return 0.0;
        }

        return $stats->average_quiz_score;
    }

    /**
     * Get performance trend over time.
     */
    public function getPerformanceTrend(User $user, ?Subject $subject = null): array
    {
        $query = $user->studySessions()
            ->selectRaw('DATE(started_at) as date, AVG(focus_score) as avg_score, COUNT(*) as sessions')
            ->groupBy('date')
            ->orderBy('date', 'desc')
            ->limit(30);

        if ($subject) {
            $query->where('subject_id', $subject->id);
        }

        return $query->get()->map(function ($item) {
            return [
                'date' => $item->date,
                'score' => round($item->avg_score ?? 0, 1),
                'sessions' => $item->sessions,
            ];
        })->reverse()->values()->toArray();
    }

    /**
     * Get subjects breakdown for a period.
     */
    public function getSubjectsBreakdown(User $user, string $period = 'week'): array
    {
        $startDate = $this->getPeriodStartDate($period);

        $breakdown = $user->studySessions()
            ->when($startDate, fn($q) => $q->where('started_at', '>=', $startDate))
            ->selectRaw('subject_id, SUM(duration_minutes) as total_minutes, COUNT(*) as sessions')
            ->groupBy('subject_id')
            ->with('subject:id,name_ar,color')
            ->get();

        $totalMinutes = $breakdown->sum('total_minutes');

        return $breakdown->map(function ($item) use ($totalMinutes) {
            return [
                'subject_id' => $item->subject_id,
                'subject_name' => $item->subject->name_ar ?? 'مادة غير معروفة',
                'color' => $item->subject->color ?? '#3B82F6',
                'minutes' => $item->total_minutes,
                'hours' => round($item->total_minutes / 60, 1),
                'sessions' => $item->sessions,
                'percentage' => $totalMinutes > 0 ? round(($item->total_minutes / $totalMinutes) * 100, 1) : 0,
            ];
        })->sortByDesc('minutes')->values()->toArray();
    }

    /**
     * Get study heatmap data.
     */
    public function getStudyHeatmap(User $user, Carbon $startDate, Carbon $endDate): array
    {
        $sessions = $user->studySessions()
            ->whereBetween('started_at', [$startDate, $endDate])
            ->selectRaw('DATE(started_at) as date, SUM(duration_minutes) as minutes, COUNT(*) as sessions')
            ->groupBy('date')
            ->get()
            ->keyBy('date');

        // Fill in missing dates with 0 minutes
        $heatmap = [];
        $currentDate = $startDate->copy();

        while ($currentDate <= $endDate) {
            $dateStr = $currentDate->toDateString();
            $session = $sessions->get($dateStr);

            $minutes = $session ? $session->minutes : 0;
            $intensity = $this->calculateIntensity($minutes);

            $heatmap[] = [
                'date' => $dateStr,
                'minutes' => $minutes,
                'sessions' => $session ? $session->sessions : 0,
                'intensity' => $intensity,
            ];

            $currentDate->addDay();
        }

        return $heatmap;
    }

    /**
     * Update quiz statistics.
     */
    public function updateQuizStats(User $user, int $score, int $totalQuestions, ?Subject $subject = null): void
    {
        $stats = UserStats::firstOrCreate(['user_id' => $user->id]);

        $stats->increment('total_quiz_attempts');
        $stats->increment('total_quiz_correct', $score);

        // Recalculate average
        $newAverage = ($stats->total_quiz_correct / ($stats->total_quiz_attempts * $totalQuestions)) * 100;
        $stats->update(['average_quiz_score' => round($newAverage, 2)]);

        // Award points based on score
        $percentage = ($score / $totalQuestions) * 100;
        $points = match(true) {
            $percentage >= 90 => 20,
            $percentage >= 80 => 15,
            $percentage >= 70 => 10,
            $percentage >= 60 => 5,
            default => 2,
        };

        $stats->increment('gamification_points', $points);
    }

    /**
     * Calculate session points based on duration.
     */
    private function calculateSessionPoints(int $minutes): int
    {
        // Base: 10 points per session
        $points = 10;

        // Bonus for longer sessions
        if ($minutes >= 60) {
            $points += 10; // 1+ hour bonus
        }
        if ($minutes >= 90) {
            $points += 5; // 1.5+ hour bonus
        }

        return $points;
    }

    /**
     * Calculate user level based on points.
     */
    private function calculateLevel(int $points): int
    {
        $levels = [
            0 => 1,
            100 => 2,
            300 => 3,
            600 => 4,
            1000 => 5,
            1500 => 6,
            2100 => 7,
            2800 => 8,
            3600 => 9,
            4500 => 10,
        ];

        $level = 1;
        foreach ($levels as $threshold => $lvl) {
            if ($points >= $threshold) {
                $level = $lvl;
            } else {
                break;
            }
        }

        return $level;
    }

    /**
     * Get period start date.
     */
    private function getPeriodStartDate(string $period): ?Carbon
    {
        return match($period) {
            'today' => now()->startOfDay(),
            'week' => now()->startOfWeek(),
            'month' => now()->startOfMonth(),
            'year' => now()->startOfYear(),
            default => null,
        };
    }

    /**
     * Calculate intensity level based on study minutes.
     */
    private function calculateIntensity(int $minutes): string
    {
        return match(true) {
            $minutes === 0 => 'none',
            $minutes < 30 => 'low',
            $minutes < 60 => 'medium',
            $minutes < 90 => 'high',
            default => 'very_high',
        };
    }
}
