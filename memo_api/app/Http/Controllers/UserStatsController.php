<?php

namespace App\Http\Controllers;

use App\Services\StatisticsService;
use App\Services\UserService;
use Illuminate\Http\Request;
use Carbon\Carbon;

class UserStatsController extends Controller
{
    protected $statisticsService;
    protected $userService;

    public function __construct(StatisticsService $statisticsService, UserService $userService)
    {
        $this->statisticsService = $statisticsService;
        $this->userService = $userService;
    }

    /**
     * Get user statistics.
     *
     * GET /api/v1/user/stats
     */
    public function index(Request $request)
    {
        $period = $request->get('period', 'all');

        if (!in_array($period, ['today', 'week', 'month', 'year', 'all'])) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid period. Must be one of: today, week, month, year, all',
            ], 400);
        }

        $stats = $this->userService->calculateUserStats(auth()->user(), $period);

        return response()->json([
            'success' => true,
            'data' => $stats,
        ]);
    }

    /**
     * Get productivity heatmap data.
     *
     * GET /api/v1/user/stats/heatmap
     */
    public function heatmap(Request $request)
    {
        $startDate = $request->has('start_date')
            ? Carbon::parse($request->start_date)
            : now()->subDays(90);

        $endDate = $request->has('end_date')
            ? Carbon::parse($request->end_date)
            : now();

        // Limit to max 365 days
        if ($startDate->diffInDays($endDate) > 365) {
            return response()->json([
                'success' => false,
                'message' => 'Date range cannot exceed 365 days',
            ], 400);
        }

        $heatmap = $this->statisticsService->getStudyHeatmap(auth()->user(), $startDate, $endDate);

        return response()->json([
            'success' => true,
            'data' => [
                'heatmap' => $heatmap,
                'start_date' => $startDate->toDateString(),
                'end_date' => $endDate->toDateString(),
            ],
        ]);
    }

    /**
     * Get performance trend over time.
     *
     * GET /api/v1/user/stats/performance
     */
    public function performance(Request $request)
    {
        $subjectId = $request->get('subject_id');
        $subject = $subjectId ? \App\Models\Subject::find($subjectId) : null;

        $trend = $this->statisticsService->getPerformanceTrend(auth()->user(), $subject);

        return response()->json([
            'success' => true,
            'data' => [
                'subject' => $subject ? $subject->name_ar : 'All Subjects',
                'trend' => $trend,
            ],
        ]);
    }

    /**
     * Get subjects breakdown by study time.
     *
     * GET /api/v1/user/stats/subjects-breakdown
     */
    public function subjectsBreakdown(Request $request)
    {
        $period = $request->get('period', 'week');

        if (!in_array($period, ['today', 'week', 'month', 'year', 'all'])) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid period',
            ], 400);
        }

        $breakdown = $this->statisticsService->getSubjectsBreakdown(auth()->user(), $period);

        return response()->json([
            'success' => true,
            'data' => [
                'period' => $period,
                'subjects' => $breakdown,
            ],
        ]);
    }

    /**
     * Get weekly progress summary.
     *
     * GET /api/v1/user/stats/weekly-summary
     */
    public function weeklySummary()
    {
        $user = auth()->user();
        $weekStart = now()->startOfWeek();
        $weekEnd = now()->endOfWeek();

        // Get this week's study sessions
        $sessions = $user->studySessions()
            ->whereBetween('started_at', [$weekStart, $weekEnd])
            ->get();

        $totalMinutes = $sessions->sum('duration_minutes');
        $sessionsCount = $sessions->count();

        // Get user subjects with weekly goals
        $userSubjects = \App\Models\UserSubject::where('user_id', $user->id)
            ->where('weekly_goal_minutes', '>', 0)
            ->with('subject')
            ->get();

        $goalsProgress = $userSubjects->map(function ($userSubject) use ($user, $weekStart, $weekEnd) {
            $studiedMinutes = $user->studySessions()
                ->where('subject_id', $userSubject->subject_id)
                ->whereBetween('started_at', [$weekStart, $weekEnd])
                ->sum('duration_minutes');

            $goalMinutes = $userSubject->weekly_goal_minutes;
            $percentage = $goalMinutes > 0 ? round(($studiedMinutes / $goalMinutes) * 100, 1) : 0;

            return [
                'subject' => $userSubject->subject->name_ar,
                'goal_minutes' => $goalMinutes,
                'studied_minutes' => $studiedMinutes,
                'percentage' => $percentage,
                'achieved' => $studiedMinutes >= $goalMinutes,
            ];
        });

        $goalsAchieved = $goalsProgress->filter(fn($g) => $g['achieved'])->count();
        $totalGoals = $goalsProgress->count();

        return response()->json([
            'success' => true,
            'data' => [
                'week_start' => $weekStart->toDateString(),
                'week_end' => $weekEnd->toDateString(),
                'total_study_hours' => round($totalMinutes / 60, 1),
                'sessions_completed' => $sessionsCount,
                'goals_achieved' => $goalsAchieved,
                'total_goals' => $totalGoals,
                'goals_progress' => $goalsProgress->values(),
            ],
        ]);
    }

    /**
     * Get daily streak information.
     *
     * GET /api/v1/user/stats/streak
     */
    public function streak()
    {
        $stats = auth()->user()->stats;

        if (!$stats) {
            return response()->json([
                'success' => true,
                'data' => [
                    'current_streak' => 0,
                    'longest_streak' => 0,
                    'last_study_date' => null,
                    'studied_today' => false,
                ],
            ]);
        }

        $today = now()->toDateString();
        $studiedToday = $stats->last_study_date === $today;

        return response()->json([
            'success' => true,
            'data' => [
                'current_streak' => $stats->current_streak_days,
                'longest_streak' => $stats->longest_streak_days,
                'last_study_date' => $stats->last_study_date,
                'studied_today' => $studiedToday,
                'next_milestone' => $this->getNextStreakMilestone($stats->current_streak_days),
            ],
        ]);
    }

    /**
     * Get overall progress summary.
     *
     * GET /api/v1/user/stats/summary
     */
    public function summary()
    {
        $user = auth()->user();
        $stats = $user->stats;

        // Content progress
        $totalContents = \App\Models\Content::published()->count();
        $completedContents = \App\Models\UserContentProgress::where('user_id', $user->id)
            ->where('is_completed', true)
            ->count();

        // Quiz stats
        $quizAttempts = $stats->total_quiz_attempts ?? 0;
        $quizAverage = $stats->average_quiz_score ?? 0;

        // Achievements
        $totalAchievements = \App\Models\Achievement::count();
        $unlockedAchievements = $user->achievements()->count();

        return response()->json([
            'success' => true,
            'data' => [
                'study' => [
                    'total_hours' => round(($stats->total_study_minutes ?? 0) / 60, 1),
                    'current_streak' => $stats->current_streak_days ?? 0,
                    'longest_streak' => $stats->longest_streak_days ?? 0,
                ],
                'content' => [
                    'completed' => $completedContents,
                    'total' => $totalContents,
                    'percentage' => $totalContents > 0 ? round(($completedContents / $totalContents) * 100, 1) : 0,
                ],
                'quizzes' => [
                    'attempts' => $quizAttempts,
                    'average_score' => $quizAverage,
                ],
                'achievements' => [
                    'unlocked' => $unlockedAchievements,
                    'total' => $totalAchievements,
                    'percentage' => $totalAchievements > 0 ? round(($unlockedAchievements / $totalAchievements) * 100, 1) : 0,
                ],
                'gamification' => [
                    'level' => $stats->level ?? 1,
                    'points' => $stats->gamification_points ?? 0,
                    'next_level_points' => $this->getNextLevelPoints($stats->level ?? 1),
                ],
            ],
        ]);
    }

    /**
     * Get next streak milestone.
     */
    private function getNextStreakMilestone(int $currentStreak): int
    {
        $milestones = [7, 14, 21, 30, 60, 90, 180, 365];

        foreach ($milestones as $milestone) {
            if ($currentStreak < $milestone) {
                return $milestone;
            }
        }

        return ceil(($currentStreak + 1) / 100) * 100; // Next hundred
    }

    /**
     * Get points required for next level.
     */
    private function getNextLevelPoints(int $currentLevel): int
    {
        $levels = [
            1 => 100,
            2 => 300,
            3 => 600,
            4 => 1000,
            5 => 1500,
            6 => 2100,
            7 => 2800,
            8 => 3600,
            9 => 4500,
            10 => 5500,
        ];

        return $levels[$currentLevel + 1] ?? ($currentLevel + 1) * 1000;
    }
}
