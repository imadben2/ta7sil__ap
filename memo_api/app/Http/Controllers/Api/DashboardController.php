<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\StudySession;
use App\Models\UserSubject;
use App\Models\QuizAttempt;
use App\Models\UserActivityLog;
use App\Models\Achievement;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    /**
     * Get complete dashboard data for home screen
     */
    public function getDashboard(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'success' => true,
            'data' => [
                'header_stats' => $this->getHeaderStats($user),
                'daily_planning' => $this->getDailyPlanning($user),
                'user_subjects' => $this->getUserSubjects($user),
                'quick_actions' => $this->getQuickActions($user),
                'weekly_progress' => $this->getWeeklyProgress($user),
                'recent_activities' => $this->getRecentActivities($user),
                'gamification' => $this->getGamificationData($user),
                'contextual_data' => $this->getContextualData($user),
            ],
            'meta' => [
                'last_updated' => now()->toIso8601String(),
                'timezone' => config('app.timezone'),
            ]
        ]);
    }

    /**
     * Get header statistics (Streak, Points, Level, Study Time)
     */
    public function getHeaderStats(User $user)
    {
        $stats = $user->stats()->first();

        if (!$stats) {
            // Create default stats if not exists
            $stats = $user->stats()->create([
                'current_streak_days' => 0,
                'gamification_points' => 0,
                'level' => 1,
                'experience_points' => 0,
            ]);
        }

        // Calculate today's study time
        $todayStudyMinutes = StudySession::where('user_id', $user->id)
            ->whereDate('scheduled_date', today())
            ->where('status', 'completed')
            ->sum('actual_duration_minutes') ?? 0;

        // Calculate daily goal progress
        // Calculate from study time range or use default 2 hours
        $dailyGoalMinutes = 120; // Default 2 hours
        if ($user->plannerSetting) {
            try {
                $start = Carbon::parse($user->plannerSetting->study_start_time);
                $end = Carbon::parse($user->plannerSetting->study_end_time);
                $totalMinutes = $start->diffInMinutes($end);
                // Use 60% of available time as goal (accounting for breaks)
                $dailyGoalMinutes = (int) ($totalMinutes * 0.6);
            } catch (\Exception $e) {
                // Keep default if parsing fails
            }
        }
        $dailyGoalProgress = $dailyGoalMinutes > 0 ? min(100, ($todayStudyMinutes / $dailyGoalMinutes) * 100) : 0;

        // Points needed for next level
        $nextLevelXP = $this->calculateNextLevelXP($stats->level);
        $pointsToNextLevel = max(0, $nextLevelXP - $stats->experience_points);

        return [
            'streak' => [
                'current_days' => $stats->current_streak_days ?? 0,
                'longest_days' => $stats->longest_streak_days ?? 0,
                'is_active' => $stats->last_study_date && Carbon::parse($stats->last_study_date)->isToday(),
                'message' => $this->getStreakMessage($stats->current_streak_days),
            ],
            'points' => [
                'total' => $stats->gamification_points ?? 0,
                'experience_points' => $stats->experience_points ?? 0,
                'points_to_next_level' => $pointsToNextLevel,
                'next_level_xp' => $nextLevelXP,
                'progress_percentage' => $this->calculateLevelProgress($stats->experience_points, $stats->level),
            ],
            'level' => [
                'current' => $stats->level ?? 1,
                'title' => $this->getLevelTitle($stats->level),
                'badge_icon' => $this->getLevelBadgeIcon($stats->level),
            ],
            'study_time_today' => [
                'minutes' => $todayStudyMinutes,
                'hours' => floor($todayStudyMinutes / 60),
                'remaining_minutes' => $todayStudyMinutes % 60,
                'daily_goal_minutes' => $dailyGoalMinutes,
                'progress_percentage' => round($dailyGoalProgress, 1),
                'formatted' => $this->formatDuration($todayStudyMinutes),
            ],
        ];
    }

    /**
     * Get today's planning/schedule
     */
    public function getDailyPlanning(User $user)
    {
        $today = today();

        $sessions = StudySession::where('user_id', $user->id)
            ->whereDate('scheduled_date', $today)
            ->where('status', '!=', 'skipped') // Exclude skipped sessions from display
            ->with(['subject:id,name_ar,color,icon', 'suggestedContent:id,title_ar'])
            ->orderBy('scheduled_start_time')
            ->get()
            ->map(function ($session) {
                $scheduledStart = $session->scheduled_start;
                $now = now();

                // Determine session state
                $state = 'upcoming';
                if ($session->status === 'completed') {
                    $state = 'completed';
                } elseif ($session->status === 'missed') {
                    $state = 'missed';
                } elseif ($scheduledStart && $scheduledStart->isPast() && !$session->isCompleted()) {
                    $state = 'in_progress';
                }

                // Calculate countdown if upcoming
                $countdownMinutes = null;
                if ($state === 'upcoming' && $scheduledStart) {
                    $countdownMinutes = max(0, $now->diffInMinutes($scheduledStart, false));
                }

                return [
                    'id' => $session->id,
                    'subject' => [
                        'id' => $session->subject->id ?? null,
                        'name' => $session->subject->name_ar ?? 'غير محدد',
                        'color' => $session->subject->color ?? '#6B7280',
                        'icon' => $session->subject->icon ?? 'book',
                    ],
                    'activity_type' => $session->session_type ?? 'study',
                    'activity_type_label' => $this->getActivityTypeLabel($session->session_type),
                    'topic' => $session->suggestedContent->title_ar ?? null,
                    'scheduled_start' => $scheduledStart ? $scheduledStart->toIso8601String() : null,
                    'scheduled_end' => $session->scheduled_end ? $session->scheduled_end->toIso8601String() : null,
                    'start_time' => $session->session_start_time,
                    'end_time' => $session->session_end_time,
                    'duration_minutes' => $session->duration_minutes,
                    'duration_formatted' => $this->formatDuration($session->duration_minutes),
                    'status' => $session->status,
                    'state' => $state,
                    'countdown_minutes' => $countdownMinutes,
                    'countdown_label' => $countdownMinutes !== null ? $this->formatCountdown($countdownMinutes) : null,
                ];
            });

        return [
            'date' => $today->toDateString(),
            'day_name_ar' => $this->getArabicDayName($today),
            'sessions' => $sessions,
            'total_sessions' => $sessions->count(),
            'completed_sessions' => $sessions->where('status', 'completed')->count(),
            'total_planned_minutes' => $sessions->sum('duration_minutes'),
            'completed_minutes' => StudySession::where('user_id', $user->id)
                ->whereDate('scheduled_date', $today)
                ->where('status', 'completed')
                ->sum('actual_duration_minutes') ?? 0,
            'has_sessions' => $sessions->isNotEmpty(),
        ];
    }

    /**
     * Get user's subjects with progress
     * OPTIMIZED: Uses batch queries instead of N+1 queries per subject
     */
    public function getUserSubjects(User $user)
    {
        // Get user's academic profile to determine their subjects
        $academicProfile = $user->academicProfile;

        if (!$academicProfile || !$academicProfile->academic_year_id || !$academicProfile->academic_stream_id) {
            return [
                'subjects' => [],
                'total_count' => 0,
            ];
        }

        // Get subjects for the user's academic year and stream
        $subjects = DB::table('subjects')
            ->where('academic_year_id', $academicProfile->academic_year_id)
            ->where(function ($q) use ($academicProfile) {
                $q->whereJsonContains('academic_stream_ids', $academicProfile->academic_stream_id)
                  ->orWhereNull('academic_stream_ids');
            })
            ->where('is_active', true)
            ->get();

        if ($subjects->isEmpty()) {
            return [
                'subjects' => [],
                'total_count' => 0,
            ];
        }

        $subjectIds = $subjects->pluck('id')->toArray();

        // BATCH QUERY 1: Get all upcoming exams for user's subjects in one query
        $upcomingExams = DB::table('exam_schedule')
            ->where('user_id', $user->id)
            ->whereIn('subject_id', $subjectIds)
            ->where('exam_date', '>', now())
            ->orderBy('exam_date')
            ->get()
            ->groupBy('subject_id')
            ->map(fn($exams) => $exams->first()); // Get first (nearest) exam per subject

        // BATCH QUERY 2: Get total lessons count per subject
        $totalLessonsCounts = DB::table('contents')
            ->whereIn('subject_id', $subjectIds)
            ->where('content_type_id', 1)
            ->select('subject_id', DB::raw('COUNT(*) as total'))
            ->groupBy('subject_id')
            ->pluck('total', 'subject_id');

        // BATCH QUERY 3: Get completed lessons count per subject for this user
        $completedLessonsCounts = DB::table('user_content_progress')
            ->join('contents', 'user_content_progress.content_id', '=', 'contents.id')
            ->where('user_content_progress.user_id', $user->id)
            ->whereIn('contents.subject_id', $subjectIds)
            ->where('user_content_progress.status', 'completed')
            ->select('contents.subject_id', DB::raw('COUNT(*) as completed'))
            ->groupBy('contents.subject_id')
            ->pluck('completed', 'contents.subject_id');

        // BATCH QUERY 4: Get quiz attempts count per subject
        $quizAttemptsCounts = DB::table('quiz_attempts')
            ->join('quizzes', 'quiz_attempts.quiz_id', '=', 'quizzes.id')
            ->where('quiz_attempts.user_id', $user->id)
            ->whereIn('quizzes.subject_id', $subjectIds)
            ->where('quiz_attempts.status', 'completed')
            ->select('quizzes.subject_id', DB::raw('COUNT(*) as attempts'))
            ->groupBy('quizzes.subject_id')
            ->pluck('attempts', 'quizzes.subject_id');

        // BATCH QUERY 5: Get user subject preferences (favorites, priority)
        $userSubjects = DB::table('user_subjects')
            ->where('user_id', $user->id)
            ->whereIn('subject_id', $subjectIds)
            ->get()
            ->keyBy('subject_id');

        // Map subjects with pre-fetched data (NO additional queries in loop)
        $mappedSubjects = $subjects->map(function ($subject) use (
            $upcomingExams,
            $totalLessonsCounts,
            $completedLessonsCounts,
            $quizAttemptsCounts,
            $userSubjects
        ) {
            $subjectId = $subject->id;
            $upcomingExam = $upcomingExams->get($subjectId);
            $totalLessons = $totalLessonsCounts->get($subjectId, 0);
            $completedLessons = $completedLessonsCounts->get($subjectId, 0);
            $quizzesTaken = $quizAttemptsCounts->get($subjectId, 0);
            $userSubject = $userSubjects->get($subjectId);

            $completionPercentage = $totalLessons > 0 ? round(($completedLessons / $totalLessons) * 100) : 0;

            $daysToExam = null;
            if ($upcomingExam) {
                $daysToExam = Carbon::parse($upcomingExam->exam_date)->diffInDays(now());
            }

            return [
                'id' => $subjectId,
                'name' => $subject->name_ar,
                'color' => $subject->color ?? '#6B7280',
                'icon' => $subject->icon ?? 'book',
                'coefficient' => (int) ($subject->coefficient ?? 1),
                'total_lessons' => $totalLessons,
                'completed_lessons' => $completedLessons,
                'completion_percentage' => $completionPercentage,
                'quizzes_taken' => $quizzesTaken,
                'is_favorite' => (bool) ($userSubject->is_favorite ?? false),
                'priority_score' => (int) ($userSubject->priority_score ?? 0),
                'exam_info' => $upcomingExam ? [
                    'has_upcoming_exam' => true,
                    'days_remaining' => $daysToExam,
                    'exam_date' => Carbon::parse($upcomingExam->exam_date)->toDateString(),
                    'is_urgent' => $daysToExam <= 7,
                ] : [
                    'has_upcoming_exam' => false,
                ],
            ];
        })
        ->sortByDesc('coefficient')
        ->values()
        ->take(8);

        return [
            'subjects' => $mappedSubjects,
            'total_count' => $mappedSubjects->count(),
        ];
    }

    /**
     * Get quick actions configuration
     */
    public function getQuickActions(User $user)
    {
        return [
            'actions' => [
                [
                    'id' => 'new_quiz',
                    'label_ar' => 'اختبار جديد',
                    'label_en' => 'New Quiz',
                    'icon' => 'quiz',
                    'color' => '#F97316',
                    'action_type' => 'navigate',
                    'route' => '/quizzes',
                ],
                [
                    'id' => 'revision',
                    'label_ar' => 'مراجعة',
                    'label_en' => 'Review',
                    'icon' => 'refresh',
                    'color' => '#10B981',
                    'action_type' => 'navigate',
                    'route' => '/revision',
                ],
                [
                    'id' => 'bac_archives',
                    'label_ar' => 'أرشيف الباك',
                    'label_en' => 'BAC Archives',
                    'icon' => 'archive',
                    'color' => '#8B5CF6',
                    'action_type' => 'navigate',
                    'route' => '/bac-archives',
                ],
                [
                    'id' => 'paid_courses',
                    'label_ar' => 'الدورات المدفوعة',
                    'label_en' => 'Paid Courses',
                    'icon' => 'diamond',
                    'color' => '#3B82F6',
                    'action_type' => 'navigate',
                    'route' => '/courses',
                    'has_badge' => $this->hasNewCourses(),
                ],
                [
                    'id' => 'pomodoro',
                    'label_ar' => 'جلسة تركيز',
                    'label_en' => 'Focus Session',
                    'icon' => 'timer',
                    'color' => '#EF4444',
                    'action_type' => 'action',
                    'route' => '/pomodoro',
                ],
                [
                    'id' => 'statistics',
                    'label_ar' => 'إحصائياتي',
                    'label_en' => 'My Statistics',
                    'icon' => 'chart',
                    'color' => '#06B6D4',
                    'action_type' => 'navigate',
                    'route' => '/analytics',
                ],
            ],
        ];
    }

    /**
     * Get weekly progress chart data
     */
    public function getWeeklyProgress(User $user)
    {
        $startOfWeek = now()->startOfWeek(); // Saturday in Arabic calendar
        $days = [];

        for ($i = 0; $i < 7; $i++) {
            $date = $startOfWeek->copy()->addDays($i);
            $studyMinutes = StudySession::where('user_id', $user->id)
                ->whereDate('scheduled_date', $date)
                ->where('status', 'completed')
                ->sum('actual_duration_minutes') ?? 0;

            $days[] = [
                'date' => $date->toDateString(),
                'day_name_ar' => $this->getArabicDayName($date),
                'study_minutes' => $studyMinutes,
                'study_hours' => round($studyMinutes / 60, 1),
                'is_today' => $date->isToday(),
            ];
        }

        $totalWeekMinutes = collect($days)->sum('study_minutes');
        $avgDailyMinutes = round($totalWeekMinutes / 7);
        $dailyGoal = $user->plannerSetting->daily_study_minutes ?? 120;

        // Compare with previous week
        $prevWeekStart = $startOfWeek->copy()->subWeek();
        $prevWeekEnd = $prevWeekStart->copy()->addDays(6);
        $prevWeekMinutes = StudySession::where('user_id', $user->id)
            ->whereBetween('scheduled_date', [$prevWeekStart, $prevWeekEnd])
            ->where('status', 'completed')
            ->sum('actual_duration_minutes') ?? 0;

        $weekComparison = 0;
        if ($prevWeekMinutes > 0) {
            $weekComparison = round((($totalWeekMinutes - $prevWeekMinutes) / $prevWeekMinutes) * 100);
        }

        return [
            'days' => $days,
            'summary' => [
                'total_minutes' => $totalWeekMinutes,
                'total_hours' => round($totalWeekMinutes / 60, 1),
                'avg_daily_minutes' => $avgDailyMinutes,
                'avg_daily_hours' => round($avgDailyMinutes / 60, 1),
                'daily_goal_minutes' => $dailyGoal,
                'week_comparison_percentage' => $weekComparison,
                'week_comparison_direction' => $weekComparison > 0 ? 'up' : ($weekComparison < 0 ? 'down' : 'same'),
            ],
        ];
    }

    /**
     * Get recent activities (quiz, lessons, badges, etc.)
     */
    public function getRecentActivities(User $user)
    {
        $activities = [];

        // Get recent quiz attempts
        $recentQuizzes = QuizAttempt::where('user_id', $user->id)
            ->where('status', 'completed')
            ->with('quiz:id,title_ar')
            ->orderBy('completed_at', 'desc')
            ->limit(3)
            ->get()
            ->map(function ($attempt) {
                return [
                    'type' => 'quiz_completed',
                    'icon' => 'quiz_check',
                    'title_ar' => 'أكملت اختبار ' . $attempt->quiz->title_ar,
                    'subject' => '',
                    'score' => $attempt->score,
                    'max_score' => $attempt->total_questions,
                    'score_label' => "حصلت على {$attempt->score}/{$attempt->total_questions}",
                    'score_badge_color' => $this->getScoreBadgeColor($attempt->score, $attempt->total_questions),
                    'time_ago' => $attempt->completed_at->diffForHumans(),
                    'timestamp' => $attempt->completed_at->toIso8601String(),
                ];
            });

        $activities = array_merge($activities, $recentQuizzes->toArray());

        // Get recently completed lessons
        $recentLessons = DB::table('user_content_progress')
            ->join('contents', 'user_content_progress.content_id', '=', 'contents.id')
            ->join('subjects', 'contents.subject_id', '=', 'subjects.id')
            ->where('user_content_progress.user_id', $user->id)
            ->where('user_content_progress.status', 'completed')
            ->select(
                'contents.title_ar',
                'subjects.name_ar as subject_name_ar',
                'user_content_progress.updated_at'
            )
            ->orderBy('user_content_progress.updated_at', 'desc')
            ->limit(2)
            ->get()
            ->map(function ($lesson) {
                return [
                    'type' => 'lesson_completed',
                    'icon' => 'book_check',
                    'title_ar' => 'أنهيت درس ' . $lesson->title_ar,
                    'subject' => $lesson->subject_name_ar,
                    'score' => 0,
                    'max_score' => 0,
                    'time_ago' => Carbon::parse($lesson->updated_at)->diffForHumans(),
                    'timestamp' => Carbon::parse($lesson->updated_at)->toIso8601String(),
                ];
            });

        $activities = array_merge($activities, $recentLessons->toArray());

        // Get recent achievements
        $recentAchievements = DB::table('user_achievements')
            ->join('achievements', 'user_achievements.achievement_id', '=', 'achievements.id')
            ->where('user_achievements.user_id', $user->id)
            ->select(
                'achievements.name_ar',
                'achievements.icon',
                'user_achievements.unlocked_at'
            )
            ->orderBy('user_achievements.unlocked_at', 'desc')
            ->limit(2)
            ->get()
            ->map(function ($achievement) {
                return [
                    'type' => 'badge_unlocked',
                    'icon' => $achievement->icon ?? 'trophy',
                    'title_ar' => 'حصلت على وسام ' . $achievement->name_ar,
                    'subject' => '',
                    'score' => 0,
                    'max_score' => 0,
                    'time_ago' => Carbon::parse($achievement->unlocked_at)->diffForHumans(),
                    'timestamp' => Carbon::parse($achievement->unlocked_at)->toIso8601String(),
                ];
            });

        $activities = array_merge($activities, $recentAchievements->toArray());

        // Sort all activities by timestamp
        usort($activities, function ($a, $b) {
            return strtotime($b['timestamp']) - strtotime($a['timestamp']);
        });

        return [
            'activities' => array_slice($activities, 0, 5),
            'total_count' => count($activities),
        ];
    }

    /**
     * Get gamification data (challenges, badges)
     */
    public function getGamificationData(User $user)
    {
        $stats = $user->stats()->first();

        // Today's challenge
        $todayChallenge = $this->getTodayChallenge($user);

        // Next unlockable badges
        $nextBadges = Achievement::whereNotIn('id', function ($query) use ($user) {
                $query->select('achievement_id')
                    ->from('user_achievements')
                    ->where('user_id', $user->id);
            })
            ->limit(3)
            ->get()
            ->map(function ($achievement) use ($user, $stats) {
                $progress = $this->calculateAchievementProgress($achievement, $user, $stats);

                return [
                    'id' => $achievement->id,
                    'name_ar' => $achievement->name_ar,
                    'description_ar' => $achievement->description_ar,
                    'icon' => $achievement->icon,
                    'progress_percentage' => $progress['percentage'],
                    'progress_label' => $progress['label'],
                ];
            });

        return [
            'today_challenge' => $todayChallenge,
            'next_badges' => $nextBadges,
            'total_badges_unlocked' => $stats->total_achievements_unlocked ?? 0,
        ];
    }

    /**
     * Get contextual data based on time and exams
     */
    public function getContextualData(User $user)
    {
        $hour = now()->hour;
        $greeting = $this->getGreeting($hour);

        // Check for upcoming exams
        $upcomingExam = DB::table('exam_schedule')
            ->join('subjects', 'exam_schedule.subject_id', '=', 'subjects.id')
            ->where('exam_schedule.user_id', $user->id)
            ->where('exam_date', '>', now())
            ->where('exam_date', '<=', now()->addDays(7))
            ->select('subjects.name_ar', 'exam_schedule.exam_date', 'subjects.id as subject_id')
            ->orderBy('exam_schedule.exam_date')
            ->first();

        $examContext = null;
        if ($upcomingExam) {
            $daysToExam = Carbon::parse($upcomingExam->exam_date)->diffInDays(now());
            $examContext = [
                'has_upcoming_exam' => true,
                'subject_name' => $upcomingExam->name_ar,
                'days_remaining' => $daysToExam,
                'exam_date' => Carbon::parse($upcomingExam->exam_date)->toDateString(),
                'message_ar' => "امتحان {$upcomingExam->name_ar} بعد {$daysToExam} أيام",
            ];
        }

        return [
            'greeting' => $greeting,
            'time_period' => $this->getTimePeriod($hour),
            'motivational_message' => $this->getMotivationalMessage($hour),
            'exam_context' => $examContext,
        ];
    }

    // ========== HELPER METHODS ==========

    private function calculateNextLevelXP($currentLevel)
    {
        // XP needed = 100 * level^1.5
        return ceil(100 * pow($currentLevel + 1, 1.5));
    }

    private function calculateLevelProgress($currentXP, $currentLevel)
    {
        $currentLevelXP = ceil(100 * pow($currentLevel, 1.5));
        $nextLevelXP = $this->calculateNextLevelXP($currentLevel);
        $xpInCurrentLevel = $currentXP - $currentLevelXP;
        $xpNeededForLevel = $nextLevelXP - $currentLevelXP;

        return $xpNeededForLevel > 0 ? round(($xpInCurrentLevel / $xpNeededForLevel) * 100, 1) : 0;
    }

    private function getLevelTitle($level)
    {
        $titles = [
            1 => 'مبتدئ',
            5 => 'متعلم',
            10 => 'متقدم',
            15 => 'خبير',
            20 => 'أستاذ',
            25 => 'عالم',
        ];

        foreach (array_reverse($titles, true) as $minLevel => $title) {
            if ($level >= $minLevel) {
                return $title;
            }
        }

        return 'مبتدئ';
    }

    private function getLevelBadgeIcon($level)
    {
        if ($level >= 25) return 'crown_gold';
        if ($level >= 20) return 'crown_silver';
        if ($level >= 15) return 'trophy_gold';
        if ($level >= 10) return 'trophy_silver';
        if ($level >= 5) return 'medal_bronze';
        return 'badge';
    }

    private function getStreakMessage($days)
    {
        if ($days === 0) return 'ابدأ سلسلتك اليوم!';
        if ($days < 3) return 'استمر!';
        if ($days < 7) return 'أداء رائع!';
        if ($days < 14) return 'حافظ عليها!';
        return 'أنت مذهل!';
    }

    private function formatDuration($minutes)
    {
        $hours = floor($minutes / 60);
        $mins = $minutes % 60;

        if ($hours > 0) {
            return "{$hours}س {$mins}د";
        }
        return "{$mins}د";
    }

    private function formatCountdown($minutes)
    {
        if ($minutes < 60) {
            return "بعد {$minutes} دقيقة";
        }

        $hours = floor($minutes / 60);
        return "بعد {$hours} ساعة";
    }

    private function getArabicDayName($date)
    {
        $days = [
            'Saturday' => 'السبت',
            'Sunday' => 'الأحد',
            'Monday' => 'الاثنين',
            'Tuesday' => 'الثلاثاء',
            'Wednesday' => 'الأربعاء',
            'Thursday' => 'الخميس',
            'Friday' => 'الجمعة',
        ];

        return $days[$date->format('l')] ?? $date->format('l');
    }

    private function getActivityTypeLabel($type)
    {
        $labels = [
            'study' => 'درس',
            'revision' => 'مراجعة',
            'quiz' => 'اختبار',
            'homework' => 'واجب',
        ];

        return $labels[$type] ?? 'درس';
    }

    private function getScoreBadgeColor($score, $total)
    {
        $percentage = ($score / $total) * 100;

        if ($percentage >= 80) return '#10B981'; // Green
        if ($percentage >= 60) return '#F59E0B'; // Orange
        return '#EF4444'; // Red
    }

    private function hasNewCourses()
    {
        $lastWeek = now()->subWeek();
        return DB::table('courses')
            ->where('created_at', '>', $lastWeek)
            ->exists();
    }

    private function getTodayChallenge($user)
    {
        // Simple daily challenge: Complete 3 lessons
        $completedToday = DB::table('user_content_progress')
            ->where('user_id', $user->id)
            ->whereDate('updated_at', today())
            ->where('status', 'completed')
            ->count();

        return [
            'id' => 'daily_lessons',
            'title_ar' => 'تحدي اليوم',
            'description_ar' => 'أكمل 3 دروس',
            'target' => 3,
            'current' => min($completedToday, 3),
            'progress_percentage' => min(100, round(($completedToday / 3) * 100)),
            'reward_points' => 50,
            'is_completed' => $completedToday >= 3,
        ];
    }

    private function calculateAchievementProgress($achievement, $user, $stats)
    {
        // Simplified achievement progress calculation
        // In reality, this would be more complex based on achievement type

        return [
            'percentage' => rand(20, 80), // Placeholder
            'label' => 'باقي 2 خطوات',
        ];
    }

    private function getGreeting($hour)
    {
        if ($hour >= 6 && $hour < 12) {
            return [
                'ar' => 'صباح الخير',
                'en' => 'Good Morning',
                'icon' => 'sun',
            ];
        } elseif ($hour >= 12 && $hour < 18) {
            return [
                'ar' => 'مساء الخير',
                'en' => 'Good Afternoon',
                'icon' => 'sun',
            ];
        } elseif ($hour >= 18 && $hour < 23) {
            return [
                'ar' => 'مساء الخير',
                'en' => 'Good Evening',
                'icon' => 'moon',
            ];
        } else {
            return [
                'ar' => 'وقت الراحة',
                'en' => 'Rest Time',
                'icon' => 'moon',
            ];
        }
    }

    private function getTimePeriod($hour)
    {
        if ($hour >= 6 && $hour < 12) return 'morning';
        if ($hour >= 12 && $hour < 18) return 'afternoon';
        if ($hour >= 18 && $hour < 23) return 'evening';
        return 'night';
    }

    private function getMotivationalMessage($hour)
    {
        if ($hour >= 6 && $hour < 12) {
            return 'ابدأ يومك بقوة!';
        } elseif ($hour >= 12 && $hour < 18) {
            return 'واصل التقدم!';
        } elseif ($hour >= 18 && $hour < 23) {
            return 'أنت تحرز تقدماً رائعاً!';
        }
        return 'استرح جيداً';
    }

    // ========== FLUTTER APP COMPATIBLE ENDPOINTS ==========

    /**
     * Get simplified stats for Flutter app
     * GET /api/v1/dashboard/stats
     */
    public function getStats(Request $request)
    {
        $user = $request->user();
        $headerStats = $this->getHeaderStats($user);

        return response()->json([
            'success' => true,
            'data' => [
                'streak' => $headerStats['streak']['current_days'],
                'total_points' => $headerStats['points']['total'],
                'level' => $headerStats['level']['current'],
                'points_to_next_level' => $headerStats['points']['points_to_next_level'],
                'study_time_today' => $headerStats['study_time_today']['minutes'],
                'daily_goal' => $headerStats['study_time_today']['daily_goal_minutes'],
            ]
        ]);
    }

    /**
     * Get today's study sessions for Flutter app
     * GET /api/v1/dashboard/today-sessions
     */
    public function getTodaySessions(Request $request)
    {
        $user = $request->user();
        $dailyPlanning = $this->getDailyPlanning($user);

        $sessions = collect($dailyPlanning['sessions'])->map(function ($session) {
            return [
                'id' => $session['id'],
                'subject_id' => $session['subject']['id'] ?? 0,
                'subject_name' => $session['subject']['name'] ?? '',
                'subject_color' => $session['subject']['color'] ?? '#6B7280',
                'type' => $this->mapSessionType($session['activity_type'] ?? 'study'),
                'status' => $this->mapSessionStatus($session['status'] ?? 'scheduled'),
                'start_time' => $session['scheduled_start'] ?? now()->toIso8601String(),
                'end_time' => $session['scheduled_end'] ?? now()->addHour()->toIso8601String(),
                'topic' => $session['topic'] ?? null,
                'notes' => null,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $sessions->values()
        ]);
    }

    /**
     * Map API session type to Flutter expected values
     */
    private function mapSessionType(string $type): string
    {
        return match($type) {
            'study', 'new_content' => 'lesson',
            'revision', 'review' => 'review',
            'quiz', 'assessment' => 'quiz',
            'homework', 'exercise' => 'homework',
            default => 'lesson',
        };
    }

    /**
     * Map API session status to Flutter expected values
     */
    private function mapSessionStatus(string $status): string
    {
        return match($status) {
            'scheduled', 'upcoming' => 'pending',
            'in_progress', 'started' => 'in_progress',
            'completed', 'done' => 'completed',
            'missed', 'skipped' => 'missed',
            default => 'pending',
        };
    }

    // ========== UNIFIED DASHBOARD ENDPOINT ==========

    /**
     * Get complete dashboard data in a single request
     * OPTIMIZED: Combines 6 API calls into 1 for the Flutter home page
     * GET /api/v1/dashboard/complete
     *
     * This endpoint returns:
     * - stats (user stats, streak, points, level)
     * - today_sessions (today's study sessions)
     * - subjects_progress (subjects with completion %)
     * - featured_courses (top 5 courses)
     * - sponsors (sponsor carousel data)
     * - promos (promotional items)
     */
    public function getComplete(Request $request)
    {
        $user = $request->user();

        // Fetch all data in parallel-like manner (PHP doesn't have true parallelism,
        // but we optimize by using batch queries within each section)

        // 1. Get header stats (already optimized with single query)
        $headerStats = $this->getHeaderStats($user);

        // 2. Get today's sessions (already optimized with eager loading)
        $dailyPlanning = $this->getDailyPlanning($user);

        // 3. Get subjects progress (NOW OPTIMIZED with batch queries)
        $userSubjects = $this->getUserSubjects($user);

        // 4. Get featured courses (limit to 5 for home page)
        $featuredCourses = $this->getFeaturedCourses(5);

        // 5. Get sponsors
        $sponsors = $this->getSponsors();

        // 6. Get promos
        $promos = $this->getPromos();

        // Format response for Flutter compatibility
        return response()->json([
            'success' => true,
            'data' => [
                // Stats section (Flutter HomeBloc expects this format)
                'stats' => [
                    'streak' => $headerStats['streak']['current_days'],
                    'total_points' => $headerStats['points']['total'],
                    'level' => $headerStats['level']['current'],
                    'level_progress' => $headerStats['points']['progress_percentage'],
                    'points_to_next_level' => $headerStats['points']['points_to_next_level'],
                    'study_time_today' => $headerStats['study_time_today']['minutes'],
                    'daily_goal' => $headerStats['study_time_today']['daily_goal_minutes'],
                    'daily_goal_progress' => $headerStats['study_time_today']['progress_percentage'],
                ],

                // Today's sessions (Flutter expects this format)
                'today_sessions' => collect($dailyPlanning['sessions'])->map(function ($session) {
                    return [
                        'id' => $session['id'],
                        'subject_id' => $session['subject']['id'] ?? 0,
                        'subject_name' => $session['subject']['name'] ?? '',
                        'subject_color' => $session['subject']['color'] ?? '#6B7280',
                        'type' => $this->mapSessionType($session['activity_type'] ?? 'study'),
                        'status' => $this->mapSessionStatus($session['status'] ?? 'scheduled'),
                        'start_time' => $session['scheduled_start'] ?? now()->toIso8601String(),
                        'end_time' => $session['scheduled_end'] ?? now()->addHour()->toIso8601String(),
                        'topic' => $session['topic'] ?? null,
                        'duration_minutes' => $session['duration_minutes'] ?? 60,
                    ];
                })->values(),

                // Subjects progress (top 4 by coefficient)
                'subjects_progress' => collect($userSubjects['subjects'])->take(4)->map(function ($subject) {
                    return [
                        'id' => $subject['id'],
                        'name' => $subject['name'],
                        'color' => $subject['color'],
                        'icon' => $subject['icon'],
                        'coefficient' => $subject['coefficient'],
                        'completion_percentage' => $subject['completion_percentage'],
                        'total_lessons' => $subject['total_lessons'],
                        'completed_lessons' => $subject['completed_lessons'],
                    ];
                })->values(),

                // Featured courses
                'featured_courses' => $featuredCourses,

                // Sponsors
                'sponsors' => $sponsors,

                // Promos
                'promos' => $promos,
            ],
            'meta' => [
                'last_updated' => now()->toIso8601String(),
                'cache_ttl_seconds' => 300, // 5 minutes suggested cache
            ],
        ]);
    }

    /**
     * Get featured courses for home page
     */
    private function getFeaturedCourses(int $limit = 5): array
    {
        $courses = DB::table('courses')
            ->where('is_published', true)
            ->orderBy('is_featured', 'desc')
            ->orderBy('created_at', 'desc')
            ->limit($limit)
            ->get();

        return $courses->map(function ($course) {
            return [
                'id' => $course->id,
                'title' => $course->title_ar ?? $course->title,
                'description' => $course->short_description_ar ?? $course->short_description ?? '',
                'thumbnail_url' => $course->thumbnail_url,
                'price' => $course->price ?? 0,
                'discount_price' => $course->discount_price,
                'is_featured' => (bool) $course->is_featured,
                'instructor_name' => $course->instructor_name ?? '',
                'rating' => $course->average_rating ?? 0,
                'students_count' => $course->students_count ?? 0,
            ];
        })->toArray();
    }

    /**
     * Get sponsors for home page carousel
     */
    private function getSponsors(): array
    {
        $sponsors = DB::table('sponsors')
            ->where('is_active', true)
            ->where(function ($q) {
                $q->whereNull('start_date')
                  ->orWhere('start_date', '<=', now());
            })
            ->where(function ($q) {
                $q->whereNull('end_date')
                  ->orWhere('end_date', '>=', now());
            })
            ->orderBy('priority', 'desc')
            ->orderBy('created_at', 'desc')
            ->limit(10)
            ->get();

        return $sponsors->map(function ($sponsor) {
            return [
                'id' => $sponsor->id,
                'name' => $sponsor->name,
                'logo_url' => $sponsor->logo_url,
                'banner_url' => $sponsor->banner_url,
                'link_url' => $sponsor->link_url,
                'description' => $sponsor->description_ar ?? $sponsor->description ?? '',
            ];
        })->toArray();
    }

    /**
     * Get promotional items for home page
     */
    private function getPromos(): array
    {
        // Check if promos table exists
        if (!DB::getSchemaBuilder()->hasTable('promos')) {
            return [];
        }

        $promos = DB::table('promos')
            ->where('is_active', true)
            ->where(function ($q) {
                $q->whereNull('start_date')
                  ->orWhere('start_date', '<=', now());
            })
            ->where(function ($q) {
                $q->whereNull('end_date')
                  ->orWhere('end_date', '>=', now());
            })
            ->orderBy('priority', 'desc')
            ->limit(5)
            ->get();

        return $promos->map(function ($promo) {
            return [
                'id' => $promo->id,
                'title' => $promo->title_ar ?? $promo->title ?? '',
                'description' => $promo->description_ar ?? $promo->description ?? '',
                'image_url' => $promo->image_url ?? $promo->banner_url ?? '',
                'link_url' => $promo->link_url ?? '',
                'type' => $promo->type ?? 'banner',
            ];
        })->toArray();
    }
}
