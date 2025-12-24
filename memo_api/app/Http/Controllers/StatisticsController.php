<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use App\Models\UserStats;

class StatisticsController extends Controller
{
    /**
     * Get comprehensive user statistics.
     *
     * Returns data formatted for Flutter StatisticsModel:
     * - current_streak, longest_streak, total_points, completed_sessions
     * - total_study_hours, average_quiz_score
     * - unlocked_badges, total_badges
     * - weekly_hours, subject_breakdown, achievements, streak_calendar
     */
    public function getStatistics(Request $request): JsonResponse
    {
        $user = $request->user();
        $user->load(['stats']);

        $stats = $user->stats;

        // Create default stats if not exists
        if (!$stats) {
            $stats = UserStats::create([
                'user_id' => $user->id,
                'total_study_minutes' => 0,
                'total_sessions' => 0,
                'total_sessions_completed' => 0,
                'total_contents_completed' => 0,
                'total_quizzes_completed' => 0,
                'total_quizzes_taken' => 0,
                'total_quizzes_passed' => 0,
                'average_quiz_score' => 0,
                'total_simulations_completed' => 0,
                'total_content_viewed' => 0,
                'average_daily_study_minutes' => 0,
                'current_week_minutes' => 0,
                'current_month_minutes' => 0,
                'current_streak_days' => 0,
                'longest_streak_days' => 0,
                'level' => 1,
                'experience_points' => 0,
                'gamification_points' => 0,
                'total_achievements_unlocked' => 0,
            ]);

            // Reload the relationship
            $user->load('stats');
            $stats = $user->stats;
        }

        // Get total badges count
        $totalBadges = DB::table('achievements')->count();

        return response()->json([
            'success' => true,
            'data' => [
                // Overview stats matching Flutter StatisticsModel
                'current_streak' => $stats->current_streak_days ?? 0,
                'longest_streak' => $stats->longest_streak_days ?? 0,
                'total_points' => $stats->gamification_points ?? 0,
                'completed_sessions' => $stats->total_sessions_completed ?? 0,
                'total_study_hours' => round(($stats->total_study_minutes ?? 0) / 60, 1),
                'average_quiz_score' => (float) ($stats->average_quiz_score ?? 0),
                'unlocked_badges' => $stats->total_achievements_unlocked ?? 0,
                'total_badges' => $totalBadges,

                // Weekly hours chart
                'weekly_hours' => $this->getWeeklyHoursData($user),

                // Subject breakdown
                'subject_breakdown' => $this->getSubjectBreakdownData($user),

                // Achievements
                'achievements' => $this->getAchievementsData($user),

                // Streak calendar
                'streak_calendar' => $this->getStreakCalendarData($user),
            ],
        ]);
    }

    /**
     * Get weekly study hours chart data.
     */
    public function getWeeklyChart(Request $request): JsonResponse
    {
        $user = $request->user();
        $data = $this->getWeeklyHoursData($user);

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    /**
     * Get subject breakdown statistics.
     */
    public function getSubjectBreakdown(Request $request): JsonResponse
    {
        $user = $request->user();
        $data = $this->getSubjectBreakdownData($user);

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    /**
     * Get user achievements.
     */
    public function getAchievements(Request $request): JsonResponse
    {
        $user = $request->user();
        $data = $this->getAchievementsData($user);

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    /**
     * Get streak calendar data.
     */
    public function getStreakCalendar(Request $request): JsonResponse
    {
        $user = $request->user();
        $data = $this->getStreakCalendarData($user);

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    /**
     * Helper: Generate weekly hours data for Flutter WeeklyDataPointModel.
     * Returns: [{ date, hours, sessions }, ...]
     */
    private function getWeeklyHoursData($user): array
    {
        $startDate = Carbon::now()->subDays(6)->startOfDay();
        $endDate = Carbon::now()->endOfDay();

        // Check if study_sessions table exists and has data
        try {
            // Use actual_duration_minutes for completed sessions, estimated_duration_minutes otherwise
            $sessions = DB::table('study_sessions')
                ->where('user_id', $user->id)
                ->whereBetween('scheduled_date', [$startDate->format('Y-m-d'), $endDate->format('Y-m-d')])
                ->select(
                    DB::raw('DATE(scheduled_date) as study_date'),
                    DB::raw('SUM(COALESCE(actual_duration_minutes, estimated_duration_minutes, 0)) as total_minutes'),
                    DB::raw('COUNT(*) as session_count')
                )
                ->groupBy('study_date')
                ->get()
                ->keyBy('study_date');
        } catch (\Exception $e) {
            // Table doesn't exist or query failed - return empty data
            $sessions = collect();
        }

        $chartData = [];
        for ($i = 0; $i < 7; $i++) {
            $date = Carbon::now()->subDays(6 - $i);
            $dateStr = $date->format('Y-m-d');

            $dayData = $sessions->get($dateStr);
            $chartData[] = [
                'date' => $dateStr,
                'hours' => round(($dayData->total_minutes ?? 0) / 60, 1),
                'sessions' => (int)($dayData->session_count ?? 0),
                // Extra fields for Arabic UI
                'day_name_ar' => $this->getDayNameAr($date->dayOfWeek),
                'day_name_short_ar' => $this->getDayNameShortAr($date->dayOfWeek),
            ];
        }

        return $chartData;
    }

    /**
     * Helper: Generate subject breakdown for Flutter SubjectBreakdownModel.
     * Returns: [{ subject_id, subject_name, subject_name_ar, color, hours, sessions, percentage }, ...]
     */
    private function getSubjectBreakdownData($user): array
    {
        try {
            $subjects = DB::table('study_sessions')
                ->join('subjects', 'study_sessions.subject_id', '=', 'subjects.id')
                ->where('study_sessions.user_id', $user->id)
                ->select(
                    'subjects.id',
                    'subjects.name_ar',
                    'subjects.name_en',
                    'subjects.color',
                    DB::raw('SUM(COALESCE(study_sessions.actual_duration_minutes, study_sessions.estimated_duration_minutes, 0)) as total_minutes'),
                    DB::raw('COUNT(study_sessions.id) as session_count')
                )
                ->groupBy('subjects.id', 'subjects.name_ar', 'subjects.name_en', 'subjects.color')
                ->orderByDesc('total_minutes')
                ->get();

            $totalMinutes = $subjects->sum('total_minutes');

            return $subjects->map(function ($subject) use ($totalMinutes) {
                return [
                    'subject_id' => $subject->id,
                    'subject_name' => $subject->name_en ?? $subject->name_ar,
                    'subject_name_ar' => $subject->name_ar,
                    'color' => $subject->color ?? '#7C3AED',
                    'hours' => round(($subject->total_minutes ?? 0) / 60, 1),
                    'sessions' => (int)$subject->session_count,
                    'percentage' => $totalMinutes > 0
                        ? round(($subject->total_minutes / $totalMinutes) * 100, 1)
                        : 0,
                ];
            })->toArray();
        } catch (\Exception $e) {
            return [];
        }
    }

    /**
     * Helper: Generate achievements data for Flutter AchievementModel.
     * Returns: [{ id, title, title_ar, description, description_ar, icon, is_unlocked, unlocked_at, points }, ...]
     */
    private function getAchievementsData($user): array
    {
        try {
            // Table uses name_ar instead of title_ar
            $allAchievements = DB::table('achievements')
                ->select('id', 'name_ar', 'description_ar', 'icon', 'badge_color', 'criteria_type', 'points')
                ->orderBy('id')
                ->get();

            $unlockedAchievements = DB::table('user_achievements')
                ->where('user_id', $user->id)
                ->select('achievement_id', 'unlocked_at')
                ->get()
                ->keyBy('achievement_id');

            return $allAchievements->map(function ($achievement) use ($unlockedAchievements) {
                $unlocked = $unlockedAchievements->get($achievement->id);
                $isUnlocked = $unlocked !== null;

                return [
                    'id' => $achievement->id,
                    'title' => $achievement->name_ar,
                    'title_ar' => $achievement->name_ar,
                    'description' => $achievement->description_ar,
                    'description_ar' => $achievement->description_ar,
                    'icon' => $achievement->icon ?? '🏆',
                    'is_unlocked' => $isUnlocked,
                    'unlocked_at' => $unlocked?->unlocked_at,
                    'points' => $achievement->points ?? 10,
                    'category' => $achievement->criteria_type,
                    'goal' => null,
                    'progress' => 0,
                ];
            })->toArray();
        } catch (\Exception $e) {
            return [];
        }
    }

    /**
     * Helper: Generate streak calendar for Flutter StreakCalendarModel.
     * Returns: { month, year, active_days: [1, 5, 7, ...], active_days_count, current_streak, longest_streak }
     */
    private function getStreakCalendarData($user): array
    {
        $now = Carbon::now();
        $startOfMonth = $now->copy()->startOfMonth();
        $endOfMonth = $now->copy()->endOfMonth();

        try {
            // Get all study days in current month
            $studyDays = DB::table('study_sessions')
                ->where('user_id', $user->id)
                ->whereBetween('scheduled_date', [$startOfMonth->format('Y-m-d'), $endOfMonth->format('Y-m-d')])
                ->where('status', 'completed')
                ->select(DB::raw('DISTINCT DAY(scheduled_date) as day_number'))
                ->pluck('day_number')
                ->toArray();

            // Get user stats for streak info
            $stats = $user->stats;

            return [
                'month' => $now->month,
                'year' => $now->year,
                'active_days' => array_map('intval', $studyDays),
                'active_days_count' => count($studyDays),
                'current_streak' => $stats->current_streak_days ?? 0,
                'longest_streak' => $stats->longest_streak_days ?? 0,
            ];
        } catch (\Exception $e) {
            return [
                'month' => $now->month,
                'year' => $now->year,
                'active_days' => [],
                'active_days_count' => 0,
                'current_streak' => 0,
                'longest_streak' => 0,
            ];
        }
    }

    /**
     * Helper: Get day name in Arabic.
     */
    private function getDayNameAr(int $dayOfWeek): string
    {
        $days = [
            0 => 'الأحد',
            1 => 'الإثنين',
            2 => 'الثلاثاء',
            3 => 'الأربعاء',
            4 => 'الخميس',
            5 => 'الجمعة',
            6 => 'السبت',
        ];

        return $days[$dayOfWeek] ?? '';
    }

    /**
     * Helper: Get short day name in Arabic.
     */
    private function getDayNameShortAr(int $dayOfWeek): string
    {
        $days = [
            0 => 'أحد',
            1 => 'إثن',
            2 => 'ثلا',
            3 => 'أرب',
            4 => 'خمي',
            5 => 'جمع',
            6 => 'سبت',
        ];

        return $days[$dayOfWeek] ?? '';
    }
}
