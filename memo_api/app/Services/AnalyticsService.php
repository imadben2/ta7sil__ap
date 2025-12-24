<?php

namespace App\Services;

use App\Models\User;
use App\Models\StudySession;
use App\Models\QuizAttempt;
use App\Models\Subject;
use App\Models\ContentChapter;
use App\Models\Content;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Str;

class AnalyticsService
{
    /**
     * Get overview analytics for a user.
     */
    public function getOverview(User $user, string $period = 'last_30_days'): array
    {
        $cacheKey = "analytics_overview_{$user->id}_{$period}";

        return Cache::remember($cacheKey, 3600, function () use ($user, $period) {
            [$startDate, $endDate] = $this->getPeriodDates($period);

            // Study statistics
            $studySessions = StudySession::where('user_id', $user->id)
                ->whereBetween('scheduled_date', [$startDate, $endDate])
                ->get();

            $completedSessions = $studySessions->where('status', 'completed');
            $missedSessions = $studySessions->where('status', 'missed');

            $totalMinutes = $completedSessions->sum('actual_duration_minutes');
            $totalHours = round($totalMinutes / 60, 1);

            // Performance statistics
            $quizAttempts = QuizAttempt::where('user_id', $user->id)
                ->whereBetween('started_at', [$startDate, $endDate])
                ->where('status', 'completed')
                ->get();

            $bacSimulations = $quizAttempts->where('quiz.is_bac_simulation', true);

            // Streak calculation
            $currentStreak = $this->calculateCurrentStreak($user);
            $longestStreak = $this->calculateLongestStreak($user);

            // Subject breakdown
            $subjectData = $this->getSubjectBreakdown($user, $startDate, $endDate);

            return [
                'period' => $period,
                'study' => [
                    'total_hours' => $totalHours,
                    'sessions_completed' => $completedSessions->count(),
                    'sessions_missed' => $missedSessions->count(),
                    'completion_rate' => $studySessions->count() > 0
                        ? round(($completedSessions->count() / $studySessions->count()) * 100, 1)
                        : 0,
                    'average_session_duration' => $completedSessions->count() > 0
                        ? round($totalMinutes / $completedSessions->count())
                        : 0,
                    'current_streak' => $currentStreak,
                    'longest_streak' => $longestStreak,
                ],
                'performance' => [
                    'quizzes_taken' => $quizAttempts->count(),
                    'average_quiz_score' => $quizAttempts->count() > 0
                        ? round($quizAttempts->avg('score'), 1)
                        : 0,
                    'bac_simulations' => $bacSimulations->count(),
                    'average_bac_score' => $bacSimulations->count() > 0
                        ? round($bacSimulations->avg('score'), 1)
                        : 0,
                    'improvement_rate' => $this->calculateImprovementRate($user, $startDate, $endDate),
                ],
                'subjects' => $subjectData,
            ];
        });
    }

    /**
     * Get trends data for charts.
     */
    public function getTrends(User $user, string $metric, string $period): array
    {
        $cacheKey = "analytics_trends_{$user->id}_{$metric}_{$period}";

        return Cache::remember($cacheKey, 3600, function () use ($user, $metric, $period) {
            [$startDate, $endDate] = $this->getPeriodDates($period);

            switch ($metric) {
                case 'study_time':
                    return $this->getStudyTimeTrends($user, $startDate, $endDate, $period);
                case 'scores':
                    return $this->getScoreTrends($user, $startDate, $endDate, $period);
                case 'sessions':
                    return $this->getSessionTrends($user, $startDate, $endDate, $period);
                default:
                    return [];
            }
        });
    }

    /**
     * Get heatmap data for activity visualization.
     */
    public function getHeatmapData(User $user, Carbon $startDate, Carbon $endDate): array
    {
        // Limit to 365 days
        if ($startDate->diffInDays($endDate) > 365) {
            $startDate = $endDate->copy()->subDays(365);
        }

        $cacheKey = "analytics_heatmap_{$user->id}_{$startDate->format('Y-m-d')}_{$endDate->format('Y-m-d')}";

        return Cache::remember($cacheKey, 3600, function () use ($user, $startDate, $endDate) {
            $sessions = StudySession::where('user_id', $user->id)
                ->where('status', 'completed')
                ->whereBetween('scheduled_date', [$startDate, $endDate])
                ->select(
                    DB::raw('DATE(scheduled_date) as date'),
                    DB::raw('SUM(actual_duration_minutes) as minutes'),
                    DB::raw('COUNT(*) as sessions')
                )
                ->groupBy('date')
                ->get();

            $heatmap = [];
            $currentDate = $startDate->copy();

            while ($currentDate <= $endDate) {
                $dateStr = $currentDate->format('Y-m-d');
                $dayData = $sessions->firstWhere('date', $dateStr);

                $minutes = $dayData ? $dayData->minutes : 0;
                $sessionCount = $dayData ? $dayData->sessions : 0;

                // Determine intensity
                $intensity = 'none';
                if ($minutes > 0) {
                    if ($minutes >= 120) {
                        $intensity = 'high';
                    } elseif ($minutes >= 60) {
                        $intensity = 'medium';
                    } else {
                        $intensity = 'low';
                    }
                }

                $heatmap[] = [
                    'date' => $dateStr,
                    'minutes' => $minutes,
                    'sessions' => $sessionCount,
                    'intensity' => $intensity,
                ];

                $currentDate->addDay();
            }

            return ['heatmap' => $heatmap];
        });
    }

    /**
     * Generate comprehensive report data.
     */
    public function generateReport(User $user, Carbon $startDate, Carbon $endDate): array
    {
        $overview = $this->getOverview($user, 'custom');
        $patterns = $this->identifyPatterns($user);
        $recommendations = $this->getRecommendations($user);

        return [
            'user' => [
                'name' => $user->name,
                'email' => $user->email,
            ],
            'period' => [
                'start' => $startDate->format('Y-m-d'),
                'end' => $endDate->format('Y-m-d'),
                'days' => $startDate->diffInDays($endDate),
            ],
            'overview' => $overview,
            'patterns' => $patterns,
            'recommendations' => $recommendations,
            'achievements' => $this->getAchievements($user, $startDate, $endDate),
        ];
    }

    /**
     * Identify user study patterns.
     */
    public function identifyPatterns(User $user): array
    {
        $cacheKey = "analytics_patterns_{$user->id}";

        return Cache::remember($cacheKey, 3600, function () use ($user) {
            $sessions = StudySession::where('user_id', $user->id)
                ->where('status', 'completed')
                ->where('scheduled_date', '>=', now()->subDays(90))
                ->get();

            if ($sessions->isEmpty()) {
                return [
                    'best_time' => null,
                    'best_days' => [],
                    'optimal_duration' => null,
                    'productivity_score' => 0,
                ];
            }

            // Best time of day
            $timeSlots = $sessions->groupBy(function ($session) {
                // Parse time string like "08:30:00" and get hour
                return (int) substr($session->scheduled_start_time, 0, 2);
            });

            $bestHour = $timeSlots->map(function ($group) {
                return [
                    'count' => $group->count(),
                    'completion_rate' => $group->where('status', 'completed')->count() / $group->count(),
                ];
            })->sortByDesc('completion_rate')->keys()->first();

            // Best days of week
            $dayStats = $sessions->groupBy(function ($session) {
                return $session->scheduled_date->dayOfWeek;
            })->map(function ($group) {
                return [
                    'count' => $group->count(),
                    'avg_duration' => $group->avg('actual_duration_minutes'),
                ];
            })->sortByDesc('count');

            $dayNames = [
                0 => 'الأحد',
                1 => 'الإثنين',
                2 => 'الثلاثاء',
                3 => 'الأربعاء',
                4 => 'الخميس',
                5 => 'الجمعة',
                6 => 'السبت',
            ];

            $bestDays = $dayStats->take(2)->keys()->map(function ($day) use ($dayNames) {
                return $dayNames[$day];
            })->toArray();

            // Optimal session duration
            $durationGroups = $sessions->groupBy(function ($session) {
                $duration = $session->actual_duration_minutes;
                if ($duration < 30) return '< 30';
                if ($duration < 45) return '30-45';
                if ($duration < 60) return '45-60';
                return '> 60';
            });

            $optimalDuration = $durationGroups->map(function ($group) {
                return $group->count();
            })->sortDesc()->keys()->first();

            return [
                'best_time' => $bestHour ? sprintf('%02d:00-%02d:00', $bestHour, $bestHour + 1) : null,
                'best_days' => $bestDays,
                'optimal_duration' => $optimalDuration,
                'productivity_score' => $this->calculateProductivityScore($sessions),
            ];
        });
    }

    /**
     * Get personalized recommendations.
     */
    public function getRecommendations(User $user): array
    {
        $overview = $this->getOverview($user, 'last_30_days');
        $patterns = $this->identifyPatterns($user);
        $recommendations = [];

        // Study time recommendations
        if ($overview['study']['total_hours'] < 20) {
            $recommendations[] = [
                'type' => 'warning',
                'category' => 'study_time',
                'message' => 'ساعات الدراسة أقل من المتوقع. حاول زيادة وقت الدراسة إلى 30 ساعة شهرياً',
                'action' => 'create_schedule',
            ];
        }

        // Completion rate
        if ($overview['study']['completion_rate'] < 70) {
            $recommendations[] = [
                'type' => 'alert',
                'category' => 'completion',
                'message' => 'نسبة إكمال الجلسات منخفضة. راجع جدولك وتأكد من واقعية الأوقات',
                'action' => 'adjust_schedule',
            ];
        }

        // Subject-specific
        foreach ($overview['subjects'] as $subject) {
            if ($subject['status'] === 'weak' && $subject['average_score'] < 60) {
                $recommendations[] = [
                    'type' => 'focus',
                    'category' => 'subject',
                    'message' => sprintf('يحتاج %s إلى مزيد من الاهتمام. متوسط درجاتك: %.1f%%', $subject['subject'], $subject['average_score']),
                    'action' => 'study_subject',
                    'subject_id' => $subject['subject_id'] ?? null,
                ];
            }
        }

        // Positive patterns
        if ($patterns['best_time']) {
            $recommendations[] = [
                'type' => 'success',
                'category' => 'pattern',
                'message' => sprintf('أفضل وقت لك للدراسة: %s (نسبة إنجاز عالية)', $patterns['best_time']),
                'action' => null,
            ];
        }

        if (!empty($patterns['best_days'])) {
            $recommendations[] = [
                'type' => 'success',
                'category' => 'pattern',
                'message' => sprintf('%s أيامك الأكثر إنتاجية', implode(' و', $patterns['best_days'])),
                'action' => null,
            ];
        }

        // Streak encouragement
        if ($overview['study']['current_streak'] >= 7) {
            $recommendations[] = [
                'type' => 'achievement',
                'category' => 'streak',
                'message' => sprintf('رائع! حافظت على streak %d أيام. استمر!', $overview['study']['current_streak']),
                'action' => null,
            ];
        }

        return $recommendations;
    }

    /**
     * Get user achievements for a period.
     */
    private function getAchievements(User $user, Carbon $startDate, Carbon $endDate): array
    {
        $achievements = [];

        $sessions = StudySession::where('user_id', $user->id)
            ->where('status', 'completed')
            ->whereBetween('scheduled_date', [$startDate, $endDate])
            ->count();

        if ($sessions >= 20) {
            $achievements[] = [
                'title' => 'طالب مجتهد',
                'description' => sprintf('أكملت %d جلسة دراسية', $sessions),
                'icon' => 'fa-medal',
            ];
        }

        $quizzes = QuizAttempt::where('user_id', $user->id)
            ->whereBetween('started_at', [$startDate, $endDate])
            ->where('status', 'completed')
            ->where('score', '>=', 80)
            ->count();

        if ($quizzes >= 10) {
            $achievements[] = [
                'title' => 'متفوق',
                'description' => sprintf('حصلت على +80%% في %d اختبار', $quizzes),
                'icon' => 'fa-trophy',
            ];
        }

        return $achievements;
    }

    /**
     * Get period date range.
     */
    private function getPeriodDates(string $period): array
    {
        switch ($period) {
            case 'last_7_days':
                return [now()->subDays(7), now()];
            case 'last_30_days':
                return [now()->subDays(30), now()];
            case 'last_90_days':
                return [now()->subDays(90), now()];
            case 'this_month':
                return [now()->startOfMonth(), now()];
            case 'last_month':
                return [now()->subMonth()->startOfMonth(), now()->subMonth()->endOfMonth()];
            default:
                return [now()->subDays(30), now()];
        }
    }

    /**
     * Calculate current study streak.
     */
    private function calculateCurrentStreak(User $user): int
    {
        $sessions = StudySession::where('user_id', $user->id)
            ->where('status', 'completed')
            ->orderBy('scheduled_date', 'desc')
            ->get()
            ->map(function ($session) {
                return $session->scheduled_date->format('Y-m-d');
            })
            ->unique();

        $streak = 0;
        $currentDate = now()->format('Y-m-d');

        foreach ($sessions as $date) {
            if ($date === $currentDate || $date === now()->subDay()->format('Y-m-d')) {
                $streak++;
                $currentDate = Carbon::parse($date)->subDay()->format('Y-m-d');
            } else {
                break;
            }
        }

        return $streak;
    }

    /**
     * Calculate longest study streak.
     */
    private function calculateLongestStreak(User $user): int
    {
        $sessions = StudySession::where('user_id', $user->id)
            ->where('status', 'completed')
            ->orderBy('scheduled_date', 'asc')
            ->get()
            ->map(function ($session) {
                return $session->scheduled_date->format('Y-m-d');
            })
            ->unique()
            ->values();

        if ($sessions->isEmpty()) {
            return 0;
        }

        $maxStreak = 1;
        $currentStreak = 1;

        for ($i = 1; $i < $sessions->count(); $i++) {
            $prevDate = Carbon::parse($sessions[$i - 1]);
            $currDate = Carbon::parse($sessions[$i]);

            if ($prevDate->diffInDays($currDate) === 1) {
                $currentStreak++;
                $maxStreak = max($maxStreak, $currentStreak);
            } else {
                $currentStreak = 1;
            }
        }

        return $maxStreak;
    }

    /**
     * Get subject breakdown with performance.
     */
    private function getSubjectBreakdown(User $user, Carbon $startDate, Carbon $endDate): array
    {
        $sessions = StudySession::where('user_id', $user->id)
            ->where('status', 'completed')
            ->whereBetween('scheduled_date', [$startDate, $endDate])
            ->with('subject')
            ->get();

        $totalMinutes = $sessions->sum('actual_duration_minutes');

        $subjectGroups = $sessions->groupBy('subject_id');

        $subjects = [];

        foreach ($subjectGroups as $subjectId => $subjectSessions) {
            $subject = $subjectSessions->first()->subject;
            if (!$subject) continue;

            $minutes = $subjectSessions->sum('actual_duration_minutes');
            $hours = round($minutes / 60, 1);

            // Get quiz scores for this subject
            $quizScores = QuizAttempt::where('user_id', $user->id)
                ->whereBetween('started_at', [$startDate, $endDate])
                ->whereHas('quiz', function ($q) use ($subjectId) {
                    $q->where('subject_id', $subjectId);
                })
                ->where('status', 'completed')
                ->avg('score');

            $avgScore = $quizScores ?? 0;

            // Determine status
            $status = 'average';
            if ($avgScore >= 80) {
                $status = 'strong';
            } elseif ($avgScore < 60) {
                $status = 'weak';
            }

            $subjects[] = [
                'subject_id' => $subjectId,
                'subject' => $subject->name_ar,
                'hours' => $hours,
                'percentage' => $totalMinutes > 0 ? round(($minutes / $totalMinutes) * 100, 1) : 0,
                'average_score' => round($avgScore, 1),
                'status' => $status,
            ];
        }

        return collect($subjects)->sortByDesc('hours')->values()->toArray();
    }

    /**
     * Calculate improvement rate.
     */
    private function calculateImprovementRate(User $user, Carbon $startDate, Carbon $endDate): float
    {
        $midPoint = $startDate->copy()->addDays($startDate->diffInDays($endDate) / 2);

        $firstHalf = QuizAttempt::where('user_id', $user->id)
            ->whereBetween('started_at', [$startDate, $midPoint])
            ->where('status', 'completed')
            ->avg('score');

        $secondHalf = QuizAttempt::where('user_id', $user->id)
            ->whereBetween('started_at', [$midPoint, $endDate])
            ->where('status', 'completed')
            ->avg('score');

        if (!$firstHalf || $firstHalf == 0) {
            return 0;
        }

        return round((($secondHalf - $firstHalf) / $firstHalf) * 100, 1);
    }

    /**
     * Get study time trends.
     */
    private function getStudyTimeTrends(User $user, Carbon $startDate, Carbon $endDate, string $period): array
    {
        $groupBy = $period === 'week' ? 'date' : ($period === 'year' ? 'month' : 'date');

        $query = StudySession::where('user_id', $user->id)
            ->where('status', 'completed')
            ->whereBetween('scheduled_date', [$startDate, $endDate]);

        if ($groupBy === 'month') {
            $data = $query->select(
                DB::raw('DATE_FORMAT(scheduled_date, "%Y-%m") as period'),
                DB::raw('SUM(actual_duration_minutes) / 60 as hours')
            )->groupBy('period')->get();
        } else {
            $data = $query->select(
                DB::raw('DATE(scheduled_date) as period'),
                DB::raw('SUM(actual_duration_minutes) / 60 as hours')
            )->groupBy('period')->get();
        }

        return [
            'labels' => $data->pluck('period')->toArray(),
            'values' => $data->pluck('hours')->map(fn($h) => round($h, 1))->toArray(),
        ];
    }

    /**
     * Get score trends.
     */
    private function getScoreTrends(User $user, Carbon $startDate, Carbon $endDate, string $period): array
    {
        $groupBy = $period === 'week' ? 'date' : ($period === 'year' ? 'month' : 'date');

        $query = QuizAttempt::where('user_id', $user->id)
            ->where('status', 'completed')
            ->whereBetween('started_at', [$startDate, $endDate]);

        if ($groupBy === 'month') {
            $data = $query->select(
                DB::raw('DATE_FORMAT(started_at, "%Y-%m") as period'),
                DB::raw('AVG(score) as avg_score')
            )->groupBy('period')->get();
        } else {
            $data = $query->select(
                DB::raw('DATE(started_at) as period'),
                DB::raw('AVG(score) as avg_score')
            )->groupBy('period')->get();
        }

        return [
            'labels' => $data->pluck('period')->toArray(),
            'values' => $data->pluck('avg_score')->map(fn($s) => round($s, 1))->toArray(),
        ];
    }

    /**
     * Get session trends.
     */
    private function getSessionTrends(User $user, Carbon $startDate, Carbon $endDate, string $period): array
    {
        $groupBy = $period === 'week' ? 'date' : ($period === 'year' ? 'month' : 'date');

        $query = StudySession::where('user_id', $user->id)
            ->whereBetween('scheduled_date', [$startDate, $endDate]);

        if ($groupBy === 'month') {
            $data = $query->select(
                DB::raw('DATE_FORMAT(scheduled_date, "%Y-%m") as period'),
                DB::raw('COUNT(*) as total'),
                DB::raw('SUM(CASE WHEN status = "completed" THEN 1 ELSE 0 END) as completed')
            )->groupBy('period')->get();
        } else {
            $data = $query->select(
                DB::raw('DATE(scheduled_date) as period'),
                DB::raw('COUNT(*) as total'),
                DB::raw('SUM(CASE WHEN status = "completed" THEN 1 ELSE 0 END) as completed')
            )->groupBy('period')->get();
        }

        return [
            'labels' => $data->pluck('period')->toArray(),
            'total' => $data->pluck('total')->toArray(),
            'completed' => $data->pluck('completed')->toArray(),
        ];
    }

    /**
     * Calculate productivity score.
     */
    private function calculateProductivityScore(mixed $sessions): int
    {
        if ($sessions->isEmpty()) {
            return 0;
        }

        $completionRate = $sessions->where('status', 'completed')->count() / $sessions->count();
        $avgDuration = $sessions->avg('actual_duration_minutes');
        $consistency = $sessions->count() / 90; // Over 90 days

        $score = ($completionRate * 40) + (min($avgDuration / 60, 1) * 30) + (min($consistency, 1) * 30);

        return (int) round($score * 100);
    }

    /**
     * Get enhanced planner analytics with detailed insights.
     */
    public function getPlannerAnalytics(User $user, string $period = 'last_30_days'): array
    {
        $cacheKey = "planner_analytics_{$user->id}_{$period}";

        return Cache::remember($cacheKey, 1800, function () use ($user, $period) {
            [$startDate, $endDate] = $this->getPeriodDates($period);

            $sessions = StudySession::where('user_id', $user->id)
                ->whereBetween('scheduled_date', [$startDate, $endDate])
                ->get();

            $completedSessions = $sessions->where('status', 'completed');

            return [
                'summary' => $this->getPlannerSummary($user, $sessions, $completedSessions),
                'time_analysis' => $this->getTimeAnalysis($completedSessions),
                'performance_metrics' => $this->getPerformanceMetrics($user, $completedSessions),
                'productivity_insights' => $this->getProductivityInsights($completedSessions),
                'subject_performance' => $this->getDetailedSubjectPerformance($user, $completedSessions),
                'weekly_breakdown' => $this->getWeeklyBreakdown($completedSessions),
                'peak_hours' => $this->getPeakStudyHours($completedSessions),
                'mood_analysis' => $this->getMoodAnalysis($completedSessions),
            ];
        });
    }

    private function getPlannerSummary(User $user, $allSessions, $completedSessions): array
    {
        $totalMinutes = $completedSessions->sum('actual_duration_minutes');

        return [
            'total_sessions_scheduled' => $allSessions->count(),
            'total_sessions_completed' => $completedSessions->count(),
            'total_sessions_missed' => $allSessions->where('status', 'missed')->count(),
            'total_study_hours' => round($totalMinutes / 60, 1),
            'total_points_earned' => $completedSessions->sum('points_earned'),
            'current_level' => $user->current_level,
            'current_streak' => $this->calculateCurrentStreak($user),
            'completion_rate' => $allSessions->count() > 0
                ? round(($completedSessions->count() / $allSessions->count()) * 100, 1)
                : 0,
        ];
    }

    private function getTimeAnalysis($sessions): array
    {
        $totalMinutes = $sessions->sum('actual_duration_minutes');
        $avgSession = $sessions->count() > 0 ? round($totalMinutes / $sessions->count()) : 0;

        return [
            'total_minutes' => $totalMinutes,
            'total_hours' => round($totalMinutes / 60, 1),
            'average_session_duration' => $avgSession,
            'shortest_session' => $sessions->min('actual_duration_minutes') ?? 0,
            'longest_session' => $sessions->max('actual_duration_minutes') ?? 0,
            'sessions_under_30min' => $sessions->where('actual_duration_minutes', '<', 30)->count(),
            'sessions_30_to_60min' => $sessions->whereBetween('actual_duration_minutes', [30, 60])->count(),
            'sessions_over_60min' => $sessions->where('actual_duration_minutes', '>', 60)->count(),
        ];
    }

    private function getPerformanceMetrics(User $user, $sessions): array
    {
        return [
            'total_points' => $sessions->sum('points_earned'),
            'average_points_per_session' => $sessions->count() > 0
                ? round($sessions->avg('points_earned'), 1)
                : 0,
            'points_to_next_level' => $user->points_to_next_level,
            'level_progress_percentage' => $this->calculateLevelProgressPercentage($user),
            'average_completion_percentage' => $sessions->count() > 0
                ? round($sessions->avg('completion_percentage'), 1)
                : 0,
        ];
    }

    private function getProductivityInsights($sessions): array
    {
        $sessionsOnTime = $sessions->filter(function ($session) {
            if (!$session->actual_start_time || !$session->scheduled_start_time) {
                return false;
            }
            $scheduledTime = \Carbon\Carbon::parse($session->scheduled_date->format('Y-m-d') . ' ' . $session->scheduled_start_time);
            $actualStart = $session->actual_start_time;
            return $actualStart->diffInMinutes($scheduledTime, false) <= 5;
        });

        return [
            'on_time_rate' => $sessions->count() > 0
                ? round(($sessionsOnTime->count() / $sessions->count()) * 100, 1)
                : 0,
            'sessions_started_on_time' => $sessionsOnTime->count(),
            'productivity_score' => $this->calculateProductivityScore($sessions),
        ];
    }

    private function getDetailedSubjectPerformance(User $user, $sessions): array
    {
        return $sessions->groupBy('subject_id')->map(function ($subjectSessions, $subjectId) {
            $subject = $subjectSessions->first()->subject;

            return [
                'subject_id' => $subjectId,
                'subject_name' => $subject ? $subject->name_ar : 'مادة محذوفة',
                'subject_color' => $subject ? $subject->color : '#6366F1',
                'sessions_count' => $subjectSessions->count(),
                'total_minutes' => $subjectSessions->sum('actual_duration_minutes'),
                'total_hours' => round($subjectSessions->sum('actual_duration_minutes') / 60, 1),
                'total_points' => $subjectSessions->sum('points_earned'),
                'average_points' => round($subjectSessions->avg('points_earned'), 1),
                'completion_rate' => round($subjectSessions->avg('completion_percentage'), 1),
            ];
        })->values()->sortByDesc('total_minutes')->values()->toArray();
    }

    private function getWeeklyBreakdown($sessions): array
    {
        return $sessions->groupBy(function ($session) {
            return $session->scheduled_date->format('W'); // Week number
        })->map(function ($weekSessions) {
            return [
                'week' => $weekSessions->first()->scheduled_date->format('W'),
                'sessions_count' => $weekSessions->count(),
                'total_minutes' => $weekSessions->sum('actual_duration_minutes'),
                'total_points' => $weekSessions->sum('points_earned'),
            ];
        })->values()->toArray();
    }

    private function getPeakStudyHours($sessions): array
    {
        $hourDistribution = $sessions->groupBy(function ($session) {
            if (!$session->actual_start_time) {
                return null;
            }
            return $session->actual_start_time->format('H');
        })->filter()->map(function ($hourSessions, $hour) {
            return [
                'hour' => (int) $hour,
                'sessions_count' => $hourSessions->count(),
                'total_minutes' => $hourSessions->sum('actual_duration_minutes'),
                'hour_label' => sprintf('%02d:00', $hour),
            ];
        })->sortByDesc('sessions_count')->take(5)->values()->toArray();

        return $hourDistribution;
    }

    private function getMoodAnalysis($sessions): array
    {
        $withMood = $sessions->whereNotNull('mood');

        return [
            'happy_count' => $withMood->where('mood', 'happy')->count(),
            'neutral_count' => $withMood->where('mood', 'neutral')->count(),
            'sad_count' => $withMood->where('mood', 'sad')->count(),
            'total_with_mood' => $withMood->count(),
            'happy_percentage' => $withMood->count() > 0
                ? round(($withMood->where('mood', 'happy')->count() / $withMood->count()) * 100, 1)
                : 0,
            'average_points_when_happy' => $withMood->where('mood', 'happy')->avg('points_earned') ?? 0,
            'average_points_when_neutral' => $withMood->where('mood', 'neutral')->avg('points_earned') ?? 0,
            'average_points_when_sad' => $withMood->where('mood', 'sad')->avg('points_earned') ?? 0,
        ];
    }

    private function calculateLevelProgressPercentage(User $user): int
    {
        $pointsPerLevel = 100;
        $pointsAtLevelStart = ($user->current_level - 1) * $pointsPerLevel;
        $pointsInCurrentLevel = $user->total_points - $pointsAtLevelStart;

        if ($user->points_to_next_level <= 0) {
            return 100;
        }

        return (int) min(100, round(($pointsInCurrentLevel / $pointsPerLevel) * 100));
    }

    /**
     * Get subject-specific analytics.
     */
    public function getSubjectAnalytics(User $user, int $subjectId, string $period = 'last_30_days'): array
    {
        $cacheKey = "analytics_subject_{$user->id}_{$subjectId}_{$period}";

        return Cache::remember($cacheKey, 3600, function () use ($user, $subjectId, $period) {
            [$startDate, $endDate] = $this->getPeriodDates($period);

            $subject = Subject::with('contentChapters')->find($subjectId);
            if (!$subject) {
                throw new \Exception('Subject not found');
            }

            // Study sessions for this subject
            $sessions = StudySession::where('user_id', $user->id)
                ->where('subject_id', $subjectId)
                ->whereBetween('scheduled_date', [$startDate, $endDate])
                ->get();

            $completedSessions = $sessions->where('status', 'completed');
            $totalMinutes = $completedSessions->sum('actual_duration_minutes');

            // Quiz performance for this subject
            $quizAttempts = QuizAttempt::where('user_id', $user->id)
                ->where('status', 'completed')
                ->whereBetween('started_at', [$startDate, $endDate])
                ->whereHas('quiz', function ($q) use ($subjectId) {
                    $q->where('subject_id', $subjectId);
                })
                ->with('quiz.chapter')
                ->get();

            $avgScore = $quizAttempts->avg('score_percentage') ?? 0;

            // Chapter breakdown
            $chapterBreakdown = $this->getChapterBreakdown($user, $subjectId, $startDate, $endDate);

            // Quiz score trends
            $quizScores = $this->getSubjectQuizScoreTrends($user, $subjectId, $startDate, $endDate);

            // Study time distribution
            $studyTimeDistribution = $this->getStudyTimeDistribution($completedSessions);

            // Strengths and weaknesses
            $analysis = $this->analyzeStrengthsAndWeaknesses($chapterBreakdown);

            // Determine trend
            $trend = $this->calculateSubjectTrend($user, $subjectId, $startDate, $endDate);

            return [
                'subject' => [
                    'id' => $subject->id,
                    'name' => $subject->name_ar,
                    'coefficient' => $subject->coefficient,
                    'color' => $subject->color,
                ],
                'overview' => [
                    'study_hours' => round($totalMinutes / 60, 1),
                    'completed_sessions' => $completedSessions->count(),
                    'average_quiz_score' => round($avgScore, 1),
                    'progress_percentage' => $this->calculateSubjectProgress($chapterBreakdown),
                    'trend' => $trend,
                ],
                'chapter_breakdown' => $chapterBreakdown,
                'quiz_scores' => $quizScores,
                'study_time' => $studyTimeDistribution,
                'strengths' => $analysis['strengths'],
                'weaknesses' => $analysis['weaknesses'],
                'improvement_suggestions' => $this->generateSubjectSuggestions($subject, $analysis),
            ];
        });
    }

    /**
     * Get weak areas for user.
     */
    public function getWeakAreas(User $user, ?string $filter = null, ?int $subjectId = null): array
    {
        $cacheKey = "analytics_weak_areas_{$user->id}_{$filter}_{$subjectId}";

        return Cache::remember($cacheKey, 1800, function () use ($user, $filter, $subjectId) {
            // Query to find weak chapters based on quiz performance
            $query = QuizAttempt::where('quiz_attempts.user_id', $user->id)
                ->where('quiz_attempts.status', 'completed')
                ->join('quizzes', 'quiz_attempts.quiz_id', '=', 'quizzes.id')
                ->leftJoin('content_chapters', 'quizzes.chapter_id', '=', 'content_chapters.id')
                ->join('subjects', 'quizzes.subject_id', '=', 'subjects.id')
                ->select(
                    'content_chapters.id as chapter_id',
                    'content_chapters.title_ar as chapter_name',
                    'subjects.id as subject_id',
                    'subjects.name_ar as subject_name',
                    'subjects.coefficient',
                    'subjects.color as subject_color',
                    DB::raw('AVG(quiz_attempts.score_percentage) as average_score'),
                    DB::raw('COUNT(quiz_attempts.id) as attempts'),
                    DB::raw('MAX(quiz_attempts.completed_at) as last_attempt')
                )
                ->groupBy(
                    'content_chapters.id',
                    'content_chapters.title_ar',
                    'subjects.id',
                    'subjects.name_ar',
                    'subjects.coefficient',
                    'subjects.color'
                )
                ->havingRaw('AVG(quiz_attempts.score_percentage) < 70') // Score < 14/20
                ->havingRaw('COUNT(quiz_attempts.id) >= 2'); // At least 2 attempts

            if ($subjectId) {
                $query->where('subjects.id', $subjectId);
            }

            $weakChapters = $query->get();

            // Process and categorize weak areas
            $weakAreas = [];
            $criticalCount = 0;
            $importantCount = 0;
            $improvementCount = 0;

            foreach ($weakChapters as $chapter) {
                $urgency = $this->calculateWeakAreaUrgency($chapter->average_score, $chapter->coefficient);
                $impact = $this->calculateImpactScore($chapter->average_score, $chapter->coefficient);

                // Apply filter if specified
                if ($filter && $urgency !== $filter) {
                    continue;
                }

                // Count by urgency
                if ($urgency === 'critical') {
                    $criticalCount++;
                } elseif ($urgency === 'important') {
                    $importantCount++;
                } else {
                    $improvementCount++;
                }

                $weakAreas[] = [
                    'id' => 'wa_' . ($chapter->chapter_id ?? $chapter->subject_id),
                    'subject_id' => $chapter->subject_id,
                    'subject_name' => $chapter->subject_name,
                    'subject_color' => $chapter->subject_color ?? '#6366F1',
                    'chapter_id' => $chapter->chapter_id,
                    'chapter_name' => $chapter->chapter_name ?? 'عام',
                    'topic' => $chapter->chapter_name ?? $chapter->subject_name,
                    'average_score' => round($chapter->average_score / 5, 1), // Convert to /20 scale
                    'attempts' => $chapter->attempts,
                    'urgency' => $urgency,
                    'impact' => round($impact, 1),
                    'last_attempt' => $chapter->last_attempt,
                    'estimated_improvement_time' => $this->estimateImprovementTime($chapter->average_score),
                    'expected_score_gain' => $this->estimateScoreGain($chapter->average_score),
                    'recommended_actions' => $this->getRecommendedActions($chapter),
                ];
            }

            // Sort by impact (highest first)
            usort($weakAreas, fn($a, $b) => $b['impact'] <=> $a['impact']);

            return [
                'total_weak_areas' => count($weakAreas),
                'critical_count' => $criticalCount,
                'important_count' => $importantCount,
                'improvement_count' => $improvementCount,
                'weak_areas' => $weakAreas,
            ];
        });
    }

    /**
     * Get weak area detail.
     */
    public function getWeakAreaDetail(User $user, int $topicId): array
    {
        // Get chapter info
        $chapter = ContentChapter::with('subject')->find($topicId);
        if (!$chapter) {
            throw new \Exception('Topic not found');
        }

        // Get quiz attempts for this chapter
        $quizAttempts = QuizAttempt::where('user_id', $user->id)
            ->where('status', 'completed')
            ->whereHas('quiz', function ($q) use ($topicId) {
                $q->where('chapter_id', $topicId);
            })
            ->with('quiz')
            ->orderBy('completed_at', 'desc')
            ->get();

        // Get available content for this chapter
        $availableContent = Content::where('chapter_id', $topicId)
            ->where('is_published', true)
            ->select('id', 'title_ar', 'content_type', 'duration_minutes')
            ->get();

        // Analyze common mistakes (from quiz answers if available)
        $commonMistakes = $this->analyzeCommonMistakes($quizAttempts);

        return [
            'topic' => [
                'id' => $chapter->id,
                'name' => $chapter->title_ar,
                'subject_id' => $chapter->subject_id,
                'subject_name' => $chapter->subject->name_ar ?? '',
            ],
            'performance' => [
                'average_score' => $quizAttempts->avg('score_percentage')
                    ? round($quizAttempts->avg('score_percentage') / 5, 1)
                    : 0,
                'total_attempts' => $quizAttempts->count(),
                'best_score' => $quizAttempts->max('score_percentage')
                    ? round($quizAttempts->max('score_percentage') / 5, 1)
                    : 0,
                'worst_score' => $quizAttempts->min('score_percentage')
                    ? round($quizAttempts->min('score_percentage') / 5, 1)
                    : 0,
            ],
            'quiz_history' => $quizAttempts->take(10)->map(fn($a) => [
                'id' => $a->id,
                'quiz_title' => $a->quiz->title_ar ?? '',
                'score' => round($a->score_percentage / 5, 1),
                'date' => $a->completed_at?->toIso8601String(),
                'time_spent' => $a->time_spent_seconds,
            ])->toArray(),
            'common_mistakes' => $commonMistakes,
            'available_content' => $availableContent->map(fn($c) => [
                'id' => $c->id,
                'title' => $c->title_ar,
                'type' => $c->content_type,
                'duration' => $c->duration_minutes,
            ])->toArray(),
            'recommended_plan' => $this->generateRecommendedPlan($chapter, $quizAttempts->avg('score_percentage') ?? 0),
        ];
    }

    /**
     * Create improvement plan for weak area.
     */
    public function createImprovementPlan(User $user, int $topicId, array $options): array
    {
        $chapter = ContentChapter::with('subject', 'contents')->find($topicId);
        if (!$chapter) {
            throw new \Exception('Topic not found');
        }

        $startDate = isset($options['start_date'])
            ? Carbon::parse($options['start_date'])
            : Carbon::tomorrow();
        $hoursPerDay = $options['hours_per_day'] ?? 1;
        $preferredSlots = $options['preferred_time_slots'] ?? ['evening'];

        // Generate plan steps
        $steps = $this->generateImprovementPlanSteps($chapter, $user);
        $totalDuration = array_sum(array_column($steps, 'estimated_duration'));

        // Calculate expected outcomes
        $currentAvgScore = QuizAttempt::where('user_id', $user->id)
            ->where('status', 'completed')
            ->whereHas('quiz', fn($q) => $q->where('chapter_id', $topicId))
            ->avg('score_percentage') ?? 0;

        $expectedImprovement = min(40, (70 - $currentAvgScore) * 0.7);
        $daysNeeded = ceil($totalDuration / 60 / $hoursPerDay);

        return [
            'plan_id' => 'plan_' . Str::uuid(),
            'topic' => [
                'id' => $chapter->id,
                'name' => $chapter->title_ar,
                'subject' => $chapter->subject->name_ar ?? '',
            ],
            'schedule' => [
                'start_date' => $startDate->toIso8601String(),
                'end_date' => $startDate->copy()->addDays($daysNeeded)->toIso8601String(),
                'hours_per_day' => $hoursPerDay,
                'preferred_time_slots' => $preferredSlots,
                'total_days' => $daysNeeded,
            ],
            'steps' => $steps,
            'total_duration_minutes' => $totalDuration,
            'expected_improvement' => round($expectedImprovement / 5, 1), // In /20 scale
            'success_probability' => $this->calculateSuccessProbability($steps, $hoursPerDay),
            'tips' => [
                'ابدأ بمراجعة الدروس الأساسية قبل التمارين',
                'خصص وقتاً للمراجعة بعد كل جلسة',
                'لا تتجاوز 90 دقيقة متواصلة من الدراسة',
            ],
        ];
    }

    /**
     * Get progress tracking data.
     */
    public function getProgress(User $user, string $period, ?string $startDate = null, ?string $endDate = null): array
    {
        if ($period === 'custom' && $startDate && $endDate) {
            $start = Carbon::parse($startDate);
            $end = Carbon::parse($endDate);
        } else {
            [$start, $end] = $this->getPeriodDates($period === '3_months' ? 'last_90_days' : 'last_' . ($period === 'week' ? '7' : '30') . '_days');
        }

        $cacheKey = "analytics_progress_{$user->id}_{$start->format('Y-m-d')}_{$end->format('Y-m-d')}";

        return Cache::remember($cacheKey, 1800, function () use ($user, $start, $end, $period) {
            // Study hours chart data
            $studyHoursData = StudySession::where('user_id', $user->id)
                ->where('status', 'completed')
                ->whereBetween('scheduled_date', [$start, $end])
                ->select(
                    DB::raw('DATE(scheduled_date) as date'),
                    DB::raw('SUM(actual_duration_minutes) / 60 as hours'),
                    DB::raw('COUNT(*) as sessions')
                )
                ->groupBy('date')
                ->orderBy('date')
                ->get();

            // Quiz score trends
            $quizScoreData = QuizAttempt::where('user_id', $user->id)
                ->where('status', 'completed')
                ->whereBetween('started_at', [$start, $end])
                ->select(
                    DB::raw('DATE(started_at) as date'),
                    DB::raw('AVG(score_percentage) / 5 as avg_score'),
                    DB::raw('COUNT(*) as count')
                )
                ->groupBy('date')
                ->orderBy('date')
                ->get();

            // Subject distribution
            $subjectDistribution = StudySession::where('user_id', $user->id)
                ->where('status', 'completed')
                ->whereBetween('scheduled_date', [$start, $end])
                ->join('subjects', 'study_sessions.subject_id', '=', 'subjects.id')
                ->select(
                    'subjects.id as subject_id',
                    'subjects.name_ar as subject_name',
                    'subjects.color',
                    DB::raw('SUM(actual_duration_minutes) / 60 as hours')
                )
                ->groupBy('subjects.id', 'subjects.name_ar', 'subjects.color')
                ->orderByDesc('hours')
                ->get();

            $totalHours = $subjectDistribution->sum('hours');

            // Insights
            $insights = $this->generateProgressInsights($studyHoursData, $quizScoreData, $start, $end);

            return [
                'period' => [
                    'type' => $period,
                    'start_date' => $start->toIso8601String(),
                    'end_date' => $end->toIso8601String(),
                    'total_days' => $start->diffInDays($end),
                ],
                'study_hours_chart' => [
                    'labels' => $studyHoursData->pluck('date')->toArray(),
                    'values' => $studyHoursData->pluck('hours')->map(fn($h) => round($h, 1))->toArray(),
                    'sessions' => $studyHoursData->pluck('sessions')->toArray(),
                ],
                'quiz_score_chart' => [
                    'labels' => $quizScoreData->pluck('date')->toArray(),
                    'values' => $quizScoreData->pluck('avg_score')->map(fn($s) => round($s, 1))->toArray(),
                    'counts' => $quizScoreData->pluck('count')->toArray(),
                ],
                'subject_distribution' => $subjectDistribution->map(fn($s) => [
                    'subject_id' => $s->subject_id,
                    'subject_name' => $s->subject_name,
                    'color' => $s->color ?? '#6366F1',
                    'hours' => round($s->hours, 1),
                    'percentage' => $totalHours > 0 ? round(($s->hours / $totalHours) * 100, 1) : 0,
                ])->toArray(),
                'summary' => [
                    'total_study_hours' => round($totalHours, 1),
                    'total_sessions' => $studyHoursData->sum('sessions'),
                    'average_quiz_score' => $quizScoreData->count() > 0
                        ? round($quizScoreData->avg('avg_score'), 1)
                        : null,
                    'total_quizzes' => $quizScoreData->sum('count'),
                ],
                'insights' => $insights,
            ];
        });
    }

    /**
     * Generate export report.
     */
    public function generateExportReport(User $user, array $options): array
    {
        $reportType = $options['report_type'];
        $startDate = Carbon::parse($options['start_date']);
        $endDate = Carbon::parse($options['end_date']);
        $format = $options['format'];
        $language = $options['language'] ?? 'ar';

        // Generate report ID
        $reportId = 'report_' . Str::uuid();

        // Get report data based on type
        $reportData = match ($reportType) {
            'comprehensive' => $this->generateReport($user, $startDate, $endDate),
            'summary' => $this->getOverview($user, 'custom'),
            'subject' => $this->getSubjectAnalytics($user, $options['subject_id'], 'custom'),
        };

        // For PDF, queue the generation (simplified - returns URL placeholder)
        if ($format === 'pdf') {
            return [
                'report_id' => $reportId,
                'status' => 'processing',
                'message' => 'جاري إنشاء التقرير...',
                'estimated_time_seconds' => 30,
                'download_url' => null, // Will be available after processing
            ];
        }

        // For JSON/CSV, return data directly
        return [
            'report_id' => $reportId,
            'status' => 'completed',
            'format' => $format,
            'language' => $language,
            'generated_at' => now()->toIso8601String(),
            'period' => [
                'start' => $startDate->toIso8601String(),
                'end' => $endDate->toIso8601String(),
            ],
            'data' => $reportData,
        ];
    }

    /**
     * Compare subjects performance.
     */
    public function compareSubjects(User $user, string $period = 'last_30_days'): array
    {
        $cacheKey = "analytics_compare_subjects_{$user->id}_{$period}";

        return Cache::remember($cacheKey, 3600, function () use ($user, $period) {
            [$startDate, $endDate] = $this->getPeriodDates($period);

            // Get all subjects with user data
            $subjectData = Subject::whereHas('users', fn($q) => $q->where('users.id', $user->id))
                ->get()
                ->map(function ($subject) use ($user, $startDate, $endDate) {
                    // Study hours
                    $sessions = StudySession::where('user_id', $user->id)
                        ->where('subject_id', $subject->id)
                        ->where('status', 'completed')
                        ->whereBetween('scheduled_date', [$startDate, $endDate])
                        ->get();

                    $studyHours = round($sessions->sum('actual_duration_minutes') / 60, 1);

                    // Quiz performance
                    $quizAttempts = QuizAttempt::where('user_id', $user->id)
                        ->where('status', 'completed')
                        ->whereBetween('started_at', [$startDate, $endDate])
                        ->whereHas('quiz', fn($q) => $q->where('subject_id', $subject->id))
                        ->get();

                    $avgScore = $quizAttempts->count() > 0
                        ? round($quizAttempts->avg('score_percentage') / 5, 1)
                        : null;

                    // Calculate completion
                    $totalChapters = $subject->contentChapters()->count();
                    $completedChapters = $this->countCompletedChapters($user, $subject->id);
                    $completionRate = $totalChapters > 0
                        ? round(($completedChapters / $totalChapters) * 100, 1)
                        : 0;

                    return [
                        'subject_id' => $subject->id,
                        'subject_name' => $subject->name_ar,
                        'coefficient' => $subject->coefficient,
                        'color' => $subject->color ?? '#6366F1',
                        'study_hours' => $studyHours,
                        'sessions_count' => $sessions->count(),
                        'average_score' => $avgScore,
                        'quizzes_taken' => $quizAttempts->count(),
                        'completion_rate' => $completionRate,
                        'status' => $this->determineSubjectStatus($avgScore, $completionRate),
                    ];
                });

            // Calculate totals for percentage
            $totalHours = $subjectData->sum('study_hours');

            // Add percentage to each subject
            $subjectData = $subjectData->map(function ($subject) use ($totalHours) {
                $subject['hours_percentage'] = $totalHours > 0
                    ? round(($subject['study_hours'] / $totalHours) * 100, 1)
                    : 0;
                return $subject;
            });

            // Identify strongest and weakest
            $withScores = $subjectData->filter(fn($s) => $s['average_score'] !== null);
            $strongest = $withScores->sortByDesc('average_score')->first();
            $weakest = $withScores->sortBy('average_score')->first();
            $mostStudied = $subjectData->sortByDesc('study_hours')->first();
            $neglected = $subjectData->filter(fn($s) => $s['hours_percentage'] < 5)->values();

            // Prepare radar chart data
            $radarData = [
                'labels' => $subjectData->pluck('subject_name')->toArray(),
                'datasets' => [
                    [
                        'label' => 'النقاط',
                        'data' => $subjectData->pluck('average_score')->map(fn($s) => $s ?? 0)->toArray(),
                    ],
                    [
                        'label' => 'الإتمام',
                        'data' => $subjectData->pluck('completion_rate')->map(fn($r) => $r / 5)->toArray(), // Scale to /20
                    ],
                ],
            ];

            return [
                'period' => $period,
                'subjects' => $subjectData->values()->toArray(),
                'radar_chart' => $radarData,
                'bar_chart' => [
                    'labels' => $subjectData->pluck('subject_name')->toArray(),
                    'hours' => $subjectData->pluck('study_hours')->toArray(),
                    'colors' => $subjectData->pluck('color')->toArray(),
                ],
                'insights' => [
                    'strongest_subject' => $strongest ? [
                        'name' => $strongest['subject_name'],
                        'score' => $strongest['average_score'],
                    ] : null,
                    'weakest_subject' => $weakest ? [
                        'name' => $weakest['subject_name'],
                        'score' => $weakest['average_score'],
                    ] : null,
                    'most_studied' => $mostStudied ? [
                        'name' => $mostStudied['subject_name'],
                        'hours' => $mostStudied['study_hours'],
                    ] : null,
                    'neglected_subjects' => $neglected->pluck('subject_name')->toArray(),
                    'balance_score' => $this->calculateStudyBalanceScore($subjectData),
                ],
                'recommendations' => $this->generateComparisonRecommendations($subjectData),
            ];
        });
    }

    // ========== Helper Methods for New Features ==========

    private function getChapterBreakdown(User $user, int $subjectId, Carbon $startDate, Carbon $endDate): array
    {
        $chapters = ContentChapter::where('subject_id', $subjectId)
            ->orderBy('order')
            ->get();

        return $chapters->map(function ($chapter) use ($user, $startDate, $endDate) {
            // Quiz attempts for this chapter
            $attempts = QuizAttempt::where('user_id', $user->id)
                ->where('status', 'completed')
                ->whereBetween('started_at', [$startDate, $endDate])
                ->whereHas('quiz', fn($q) => $q->where('chapter_id', $chapter->id))
                ->get();

            $avgScore = $attempts->count() > 0
                ? round($attempts->avg('score_percentage') / 5, 1)
                : null;

            // Determine status
            $status = 'not_started';
            if ($avgScore !== null) {
                if ($avgScore >= 16) {
                    $status = 'mastered';
                } elseif ($avgScore >= 10) {
                    $status = 'in_progress';
                } else {
                    $status = 'needs_work';
                }
            }

            return [
                'chapter_id' => $chapter->id,
                'chapter_name' => $chapter->title_ar,
                'average_score' => $avgScore,
                'attempts' => $attempts->count(),
                'status' => $status,
                'last_attempt' => $attempts->max('completed_at')?->toIso8601String(),
            ];
        })->toArray();
    }

    private function getSubjectQuizScoreTrends(User $user, int $subjectId, Carbon $startDate, Carbon $endDate): array
    {
        $attempts = QuizAttempt::where('user_id', $user->id)
            ->where('status', 'completed')
            ->whereBetween('started_at', [$startDate, $endDate])
            ->whereHas('quiz', fn($q) => $q->where('subject_id', $subjectId))
            ->select('completed_at', 'score_percentage')
            ->orderBy('completed_at')
            ->get();

        return [
            'labels' => $attempts->pluck('completed_at')->map(fn($d) => $d->format('Y-m-d'))->toArray(),
            'values' => $attempts->pluck('score_percentage')->map(fn($s) => round($s / 5, 1))->toArray(),
        ];
    }

    private function getStudyTimeDistribution($sessions): array
    {
        $byChapter = $sessions->groupBy('chapter_id')->map(fn($g) => round($g->sum('actual_duration_minutes') / 60, 1));
        $byType = [
            'lessons' => round($sessions->where('session_type', 'lesson')->sum('actual_duration_minutes') / 60, 1),
            'exercises' => round($sessions->where('session_type', 'exercise')->sum('actual_duration_minutes') / 60, 1),
            'revision' => round($sessions->where('session_type', 'revision')->sum('actual_duration_minutes') / 60, 1),
        ];

        return [
            'by_chapter' => $byChapter->toArray(),
            'by_type' => $byType,
        ];
    }

    private function analyzeStrengthsAndWeaknesses(array $chapterBreakdown): array
    {
        $strengths = [];
        $weaknesses = [];

        foreach ($chapterBreakdown as $chapter) {
            if ($chapter['average_score'] === null) continue;

            if ($chapter['average_score'] >= 14) {
                $strengths[] = [
                    'chapter' => $chapter['chapter_name'],
                    'score' => $chapter['average_score'],
                ];
            } elseif ($chapter['average_score'] < 10) {
                $weaknesses[] = [
                    'chapter' => $chapter['chapter_name'],
                    'score' => $chapter['average_score'],
                ];
            }
        }

        return [
            'strengths' => $strengths,
            'weaknesses' => $weaknesses,
        ];
    }

    private function calculateSubjectTrend(User $user, int $subjectId, Carbon $startDate, Carbon $endDate): string
    {
        $midPoint = $startDate->copy()->addDays($startDate->diffInDays($endDate) / 2);

        $firstHalf = QuizAttempt::where('user_id', $user->id)
            ->where('status', 'completed')
            ->whereBetween('started_at', [$startDate, $midPoint])
            ->whereHas('quiz', fn($q) => $q->where('subject_id', $subjectId))
            ->avg('score_percentage');

        $secondHalf = QuizAttempt::where('user_id', $user->id)
            ->where('status', 'completed')
            ->whereBetween('started_at', [$midPoint, $endDate])
            ->whereHas('quiz', fn($q) => $q->where('subject_id', $subjectId))
            ->avg('score_percentage');

        if ($firstHalf === null || $secondHalf === null) {
            return 'stable';
        }

        $diff = $secondHalf - $firstHalf;
        if ($diff > 5) return 'improving';
        if ($diff < -5) return 'declining';
        return 'stable';
    }

    private function calculateSubjectProgress(array $chapterBreakdown): int
    {
        if (empty($chapterBreakdown)) return 0;

        $completed = count(array_filter($chapterBreakdown, fn($c) => $c['status'] === 'mastered'));
        return (int) round(($completed / count($chapterBreakdown)) * 100);
    }

    private function generateSubjectSuggestions(Subject $subject, array $analysis): array
    {
        $suggestions = [];

        if (!empty($analysis['weaknesses'])) {
            $weakest = $analysis['weaknesses'][0];
            $suggestions[] = [
                'type' => 'focus',
                'message' => "ركز على فصل {$weakest['chapter']} - معدلك الحالي {$weakest['score']}/20",
                'action' => 'study_chapter',
            ];
        }

        if (count($analysis['strengths']) > 0) {
            $suggestions[] = [
                'type' => 'success',
                'message' => 'أداء ممتاز في ' . count($analysis['strengths']) . ' فصول، حافظ على مستواك!',
                'action' => null,
            ];
        }

        return $suggestions;
    }

    private function calculateWeakAreaUrgency(float $scorePercentage, float $coefficient): string
    {
        // Score is 0-100 percentage, convert to /20
        $scoreOn20 = $scorePercentage / 5;

        if ($scoreOn20 < 8 && $coefficient >= 5) {
            return 'critical';
        } elseif ($scoreOn20 < 10) {
            return 'important';
        } else {
            return 'needs_improvement';
        }
    }

    private function calculateImpactScore(float $scorePercentage, float $coefficient): float
    {
        // Impact = coefficient * (target_score - current_score)
        $targetScore = 14; // 14/20 is passing
        $currentScore = $scorePercentage / 5;
        return $coefficient * max(0, $targetScore - $currentScore);
    }

    private function estimateImprovementTime(float $scorePercentage): int
    {
        // Estimate hours needed based on current score
        $scoreOn20 = $scorePercentage / 5;
        if ($scoreOn20 < 8) return 8;
        if ($scoreOn20 < 10) return 5;
        return 3;
    }

    private function estimateScoreGain(float $scorePercentage): float
    {
        $currentScore = $scorePercentage / 5;
        $potentialGain = min(14, 14 - $currentScore) * 0.7;
        return round($potentialGain, 1);
    }

    private function getRecommendedActions($chapter): array
    {
        $actions = [];

        $actions[] = [
            'type' => 'watch_lesson',
            'title' => 'مراجعة الدرس الأساسي',
            'priority' => 1,
        ];

        $actions[] = [
            'type' => 'practice_exercises',
            'title' => 'حل تمارين تطبيقية',
            'priority' => 2,
        ];

        $actions[] = [
            'type' => 'take_quiz',
            'title' => 'اختبار ذاتي',
            'priority' => 3,
        ];

        return $actions;
    }

    private function analyzeCommonMistakes($quizAttempts): array
    {
        // Simplified - would need question-level analysis for full implementation
        return [
            [
                'type' => 'concept',
                'description' => 'صعوبة في فهم المفاهيم الأساسية',
                'frequency' => 'متكرر',
            ],
        ];
    }

    private function generateRecommendedPlan($chapter, float $avgScore): array
    {
        $steps = [];
        $stepOrder = 1;

        // Always start with lesson review
        $steps[] = [
            'order' => $stepOrder++,
            'type' => 'lesson',
            'title' => 'مراجعة الدرس',
            'duration_minutes' => 30,
        ];

        // Add exercises if score is low
        if ($avgScore < 50) {
            $steps[] = [
                'order' => $stepOrder++,
                'type' => 'exercises',
                'title' => 'تمارين تطبيقية',
                'duration_minutes' => 45,
            ];
        }

        // Always end with quiz
        $steps[] = [
            'order' => $stepOrder++,
            'type' => 'quiz',
            'title' => 'اختبار ذاتي',
            'duration_minutes' => 20,
        ];

        return [
            'steps' => $steps,
            'total_duration' => array_sum(array_column($steps, 'duration_minutes')),
        ];
    }

    private function generateImprovementPlanSteps($chapter, User $user): array
    {
        $steps = [];
        $stepOrder = 1;

        // Get available content for this chapter
        $contents = Content::where('chapter_id', $chapter->id)
            ->where('is_published', true)
            ->orderBy('order')
            ->get();

        // Add lesson content
        foreach ($contents->where('content_type', 'video')->take(2) as $content) {
            $steps[] = [
                'order' => $stepOrder++,
                'type' => 'watch_lesson',
                'content_id' => $content->id,
                'title' => $content->title_ar,
                'estimated_duration' => $content->duration_minutes ?? 30,
                'completed' => false,
            ];
        }

        // Add summary
        $summary = $contents->where('content_type', 'summary')->first();
        if ($summary) {
            $steps[] = [
                'order' => $stepOrder++,
                'type' => 'read_summary',
                'content_id' => $summary->id,
                'title' => $summary->title_ar,
                'estimated_duration' => 20,
                'completed' => false,
            ];
        }

        // Add exercises
        $exercises = $contents->where('content_type', 'exercise')->first();
        if ($exercises) {
            $steps[] = [
                'order' => $stepOrder++,
                'type' => 'solve_exercises',
                'content_id' => $exercises->id,
                'title' => 'حل تمارين',
                'estimated_duration' => 60,
                'completed' => false,
            ];
        }

        // Add quiz
        $steps[] = [
            'order' => $stepOrder++,
            'type' => 'take_quiz',
            'title' => 'اختبار ذاتي',
            'estimated_duration' => 30,
            'completed' => false,
        ];

        return $steps;
    }

    private function calculateSuccessProbability(array $steps, float $hoursPerDay): int
    {
        $totalHours = array_sum(array_column($steps, 'estimated_duration')) / 60;
        $daysNeeded = $totalHours / $hoursPerDay;

        // Higher probability if more time per day and fewer total days
        if ($hoursPerDay >= 2 && $daysNeeded <= 5) return 90;
        if ($hoursPerDay >= 1.5 && $daysNeeded <= 7) return 80;
        if ($hoursPerDay >= 1 && $daysNeeded <= 10) return 70;
        return 60;
    }

    private function generateProgressInsights(mixed $studyData, mixed $quizData, Carbon $start, Carbon $end): array
    {
        $insights = [];

        // Best study day
        if ($studyData->count() > 0) {
            $bestDay = $studyData->sortByDesc('hours')->first();
            $insights[] = [
                'type' => 'best_day',
                'message' => "أفضل يوم للدراسة: {$bestDay->date} ({$bestDay->hours} ساعات)",
            ];
        }

        // Study consistency
        $studyDays = $studyData->count();
        $totalDays = $start->diffInDays($end);
        $consistency = $totalDays > 0 ? round(($studyDays / $totalDays) * 100) : 0;
        $insights[] = [
            'type' => 'consistency',
            'message' => "نسبة الانتظام: {$consistency}%",
            'value' => $consistency,
        ];

        // Quiz improvement
        if ($quizData->count() >= 2) {
            $firstScore = $quizData->first()->avg_score ?? 0;
            $lastScore = $quizData->last()->avg_score ?? 0;
            $improvement = round($lastScore - $firstScore, 1);
            if ($improvement > 0) {
                $insights[] = [
                    'type' => 'improvement',
                    'message' => "تحسن في المعدل: +{$improvement} نقطة",
                ];
            }
        }

        return $insights;
    }

    private function countCompletedChapters(User $user, int $subjectId): int
    {
        return ContentChapter::where('subject_id', $subjectId)
            ->whereHas('contents', function ($q) use ($user) {
                $q->whereHas('progress', fn($p) => $p->where('user_id', $user->id)->where('is_completed', true));
            })
            ->count();
    }

    private function determineSubjectStatus(?float $score, float $completionRate): string
    {
        if ($score === null) return 'not_started';
        if ($score >= 14 && $completionRate >= 70) return 'strong';
        if ($score < 10 || $completionRate < 30) return 'weak';
        return 'average';
    }

    private function calculateStudyBalanceScore($subjectData): int
    {
        if ($subjectData->count() === 0) return 0;

        // Calculate coefficient-weighted expected distribution
        $totalCoefficient = $subjectData->sum('coefficient');
        $deviations = [];

        foreach ($subjectData as $subject) {
            $expectedPercentage = ($subject['coefficient'] / $totalCoefficient) * 100;
            $actualPercentage = $subject['hours_percentage'];
            $deviations[] = abs($expectedPercentage - $actualPercentage);
        }

        // Lower deviation = better balance
        $avgDeviation = count($deviations) > 0 ? array_sum($deviations) / count($deviations) : 0;
        return max(0, 100 - (int)($avgDeviation * 2));
    }

    private function generateComparisonRecommendations($subjectData): array
    {
        $recommendations = [];

        // Find neglected subjects
        $neglected = $subjectData->filter(fn($s) => $s['hours_percentage'] < 5 && $s['coefficient'] >= 4);
        foreach ($neglected as $subject) {
            $recommendations[] = [
                'type' => 'warning',
                'message' => "خصص وقتاً أكبر لمادة {$subject['subject_name']} (معامل {$subject['coefficient']})",
            ];
        }

        // Find over-studied subjects
        $overStudied = $subjectData->filter(fn($s) => $s['hours_percentage'] > 40);
        foreach ($overStudied as $subject) {
            $recommendations[] = [
                'type' => 'balance',
                'message' => "وزع وقتك بشكل أفضل - {$subject['subject_name']} تأخذ {$subject['hours_percentage']}% من وقتك",
            ];
        }

        return $recommendations;
    }
}
