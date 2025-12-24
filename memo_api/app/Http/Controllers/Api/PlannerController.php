<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\PlannerStudySessionResource;
use App\Models\PlannerSetting;
use App\Models\PlannerSchedule;
use App\Models\PlannerStudySession;
use App\Models\UserSubjectPlannerProgress;
use App\Services\PlannerService;
use App\Services\AdaptationService;
use App\Services\NotificationService;
use App\Services\ContentAllocationService;
use App\Services\SchedulingAlgorithmService;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class PlannerController extends Controller
{
    protected PlannerService $plannerService;
    protected AdaptationService $adaptationService;
    protected NotificationService $notificationService;
    protected SchedulingAlgorithmService $algorithmService;

    public function __construct(
        PlannerService $plannerService,
        AdaptationService $adaptationService,
        NotificationService $notificationService,
        SchedulingAlgorithmService $algorithmService
    ) {
        $this->plannerService = $plannerService;
        $this->adaptationService = $adaptationService;
        $this->notificationService = $notificationService;
        $this->algorithmService = $algorithmService;
    }

    /**
     * Get user's planner settings
     */
    public function getSettings(Request $request)
    {
        $user = $request->user();
        $settings = $user->plannerSetting;

        if (!$settings) {
            return response()->json([
                'message' => 'Planner settings not configured',
                'default_formula' => PlannerSetting::getDefaultPriorityFormula(),
            ], 404);
        }

        return response()->json([
            'settings' => $settings,
        ]);
    }

    /**
     * Update planner settings
     */
    public function updateSettings(Request $request)
    {
        $validator = Validator::make($request->all(), [
            // Study time window
            'study_start_time' => 'nullable|date_format:H:i',
            'study_end_time' => 'nullable|date_format:H:i',
            'study_days' => 'nullable|array',
            // Sleep schedule
            'sleep_start_time' => 'nullable|date_format:H:i',
            'sleep_end_time' => 'nullable|date_format:H:i',
            // Exercise settings
            'exercise_enabled' => 'nullable|boolean',
            'exercise_days' => 'nullable|array',
            'exercise_time' => 'nullable|date_format:H:i',
            'exercise_duration_minutes' => 'nullable|integer|min:0|max:180',
            // Energy levels (1-10)
            'morning_energy_level' => 'nullable|integer|min:1|max:10',
            'afternoon_energy_level' => 'nullable|integer|min:1|max:10',
            'evening_energy_level' => 'nullable|integer|min:1|max:10',
            'night_energy_level' => 'nullable|integer|min:1|max:10',
            // Pomodoro settings
            'use_pomodoro' => 'nullable|boolean',
            'pomodoro_duration' => 'nullable|integer|min:1|max:120',
            'short_break' => 'nullable|integer|min:1|max:60',
            'long_break' => 'nullable|integer|min:1|max:60',
            'pomodoros_before_long_break' => 'nullable|integer|min:1|max:10',
            // Prayer settings
            'enable_prayer_times' => 'nullable|boolean',
            'city_for_prayer' => 'nullable|string|max:100',
            'prayer_duration_minutes' => 'nullable|integer|min:5|max:60',
            // Auto-adaptation
            'auto_reschedule_missed' => 'nullable|boolean',
            'adapt_to_performance_enabled' => 'nullable|boolean',
            'smart_content_suggestions' => 'nullable|boolean',
            // Priority weights
            'coefficient_weight' => 'nullable|integer|min:0|max:100',
            'exam_proximity_weight' => 'nullable|integer|min:0|max:100',
            'difficulty_weight' => 'nullable|integer|min:0|max:100',
            'inactivity_weight' => 'nullable|integer|min:0|max:100',
            'performance_gap_weight' => 'nullable|integer|min:0|max:100',
            // Limits
            'max_study_hours_per_day' => 'nullable|integer|min:1|max:24',
            'min_break_between_sessions' => 'nullable|integer|min:0|max:60',
            // Algorithm settings
            'buffer_rate' => 'nullable|numeric|min:0|max:1',
            'max_coef7_per_day' => 'nullable|integer|min:1|max:10',
            'max_hard_per_day' => 'nullable|integer|min:1|max:10',
            'mock_day_of_week' => 'nullable|string|in:saturday,sunday,monday,tuesday,wednesday,thursday,friday',
            'mock_duration_minutes' => 'nullable|integer|min:30|max:240',
            'language_daily_guarantee' => 'nullable|boolean',
            'no_consecutive_hard' => 'nullable|boolean',
            // Coefficient durations
            'coefficient_durations' => 'nullable|array',
            'coefficient_durations.*' => 'nullable|integer|min:15|max:180',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();

        // Use only validated data to prevent mass assignment vulnerability
        $validatedData = $request->only([
            // Study time window
            'study_start_time',
            'study_end_time',
            'study_days',
            // Sleep schedule
            'sleep_start_time',
            'sleep_end_time',
            // Exercise settings
            'exercise_enabled',
            'exercise_days',
            'exercise_time',
            'exercise_duration_minutes',
            // Energy levels
            'morning_energy_level',
            'afternoon_energy_level',
            'evening_energy_level',
            'night_energy_level',
            // Pomodoro settings
            'use_pomodoro',
            'pomodoro_duration',
            'short_break',
            'long_break',
            'pomodoros_before_long_break',
            // Prayer settings
            'enable_prayer_times',
            'city_for_prayer',
            'prayer_duration_minutes',
            // Auto-adaptation
            'auto_reschedule_missed',
            'adapt_to_performance_enabled',
            'smart_content_suggestions',
            // Priority weights
            'coefficient_weight',
            'exam_proximity_weight',
            'difficulty_weight',
            'inactivity_weight',
            'performance_gap_weight',
            // Limits
            'max_study_hours_per_day',
            'min_break_between_sessions',
            // Algorithm settings
            'buffer_rate',
            'max_coef7_per_day',
            'max_hard_per_day',
            'mock_day_of_week',
            'mock_duration_minutes',
            'language_daily_guarantee',
            'no_consecutive_hard',
            // Coefficient durations
            'coefficient_durations',
        ]);

        \Log::info('[PlannerController] updateSettings - Validated data:', $validatedData);

        $settings = $user->plannerSetting()->updateOrCreate(
            ['user_id' => $user->id],
            array_filter($validatedData, fn($value) => $value !== null)
        );

        \Log::info('[PlannerController] Settings saved:', $settings->toArray());

        return response()->json([
            'success' => true,
            'message' => 'Planner settings updated successfully',
            'data' => $settings,
        ]);
    }

    /**
     * Generate a new study schedule
     */
    public function generateSchedule(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'start_date' => 'required|date|after_or_equal:today',
            'end_date' => 'required|date|after:start_date',
            'schedule_type' => 'nullable|in:auto,manual,exam_prep',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();

        try {
            $result = $this->plannerService->generateSchedule(
                $user,
                Carbon::parse($request->start_date),
                Carbon::parse($request->end_date),
                $request->schedule_type ?? 'auto'
            );

            // Extract schedule from result array
            $schedule = $result['schedule'];

            // Schedule notifications for all upcoming sessions
            foreach ($schedule->studySessions()->where('status', 'scheduled')->get() as $session) {
                // Only schedule reminders for future sessions
                if ($session->scheduled_date->isFuture()) {
                    $this->notificationService->scheduleStudyReminder($session);
                }
            }

            // Generate HTML planner file
            $htmlResult = $this->generateHtmlPlanner($user, $schedule);

            return response()->json([
                'message' => 'Schedule generated successfully',
                'schedule' => $schedule->load('studySessions.subject'),
                'html_planner' => $htmlResult,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get user's schedules
     */
    public function getSchedules(Request $request)
    {
        $user = $request->user();
        $schedules = PlannerSchedule::where('user_id', $user->id)
            ->with('studySessions.subject')
            ->orderBy('created_at', 'desc')
            ->paginate(10);

        return response()->json($schedules);
    }

    /**
     * Get specific schedule
     */
    public function getSchedule(Request $request, $id)
    {
        $user = $request->user();
        $schedule = PlannerSchedule::where('user_id', $user->id)
            ->where('id', $id)
            ->with(['studySessions.subject', 'studySessions.activities'])
            ->first();

        if (!$schedule) {
            return response()->json([
                'error' => 'Schedule not found',
            ], 404);
        }

        return response()->json([
            'schedule' => $schedule,
        ]);
    }

    /**
     * Activate a schedule
     */
    public function activateSchedule(Request $request, $id)
    {
        $user = $request->user();
        $schedule = PlannerSchedule::where('user_id', $user->id)
            ->where('id', $id)
            ->first();

        if (!$schedule) {
            return response()->json([
                'error' => 'Schedule not found',
            ], 404);
        }

        $this->plannerService->activateSchedule($schedule);

        return response()->json([
            'message' => 'Schedule activated successfully',
            'schedule' => $schedule->fresh(),
        ]);
    }

    /**
     * Delete a schedule (soft delete)
     */
    public function deleteSchedule(Request $request, $id)
    {
        $user = $request->user();
        $schedule = PlannerSchedule::where('user_id', $user->id)
            ->where('id', $id)
            ->first();

        if (!$schedule) {
            return response()->json([
                'error' => 'Schedule not found',
            ], 404);
        }

        if ($schedule->status === PlannerSchedule::STATUS_ACTIVE) {
            return response()->json([
                'error' => 'Cannot delete active schedule',
            ], 422);
        }

        $schedule->delete(); // Soft delete - preserves historical data

        return response()->json([
            'message' => 'Schedule deleted successfully',
        ]);
    }

    /**
     * Get dashboard data
     */
    public function getDashboard(Request $request)
    {
        $user = $request->user();

        // Get active schedule with eager loading
        $activeSchedule = PlannerSchedule::where('user_id', $user->id)
            ->where('status', PlannerSchedule::STATUS_ACTIVE)
            ->with(['studySessions.subject'])
            ->first();

        // Get behavior patterns
        $patterns = $this->adaptationService->detectBehaviorPatterns($user);

        return response()->json([
            'active_schedule' => $activeSchedule,
            'patterns' => $patterns,
            'settings' => $user->plannerSetting,
        ]);
    }

    /**
     * Trigger manual adaptation
     */
    public function triggerAdaptation(Request $request)
    {
        $user = $request->user();

        try {
            $adaptations = $this->adaptationService->adaptScheduleForUser($user);

            return response()->json([
                'message' => 'Adaptation completed successfully',
                'adaptations' => $adaptations,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get points history for gamification
     */
    public function getPointsHistory(Request $request)
    {
        $user = $request->user();

        // Get session completions with points from the last 30 days
        $pointsHistory = \DB::table('planner_study_sessions')
            ->where('user_id', $user->id)
            ->where('status', 'completed')
            ->whereNotNull('points_earned')
            ->where('actual_end_time', '>=', now()->subDays(30))
            ->select(
                \DB::raw('DATE(actual_end_time) as date'),
                \DB::raw('SUM(points_earned) as total_points'),
                \DB::raw('COUNT(*) as sessions_count')
            )
            ->groupBy('date')
            ->orderBy('date', 'desc')
            ->get();

        $totalPoints = \DB::table('planner_study_sessions')
            ->where('user_id', $user->id)
            ->where('status', 'completed')
            ->sum('points_earned');

        return response()->json([
            'points_history' => $pointsHistory,
            'total_points' => $totalPoints ?? 0,
            'period_days' => 30,
        ]);
    }

    /**
     * Get achievements for gamification
     * Optimized to reduce N+1 queries by using a single query for stats
     */
    public function getAchievements(Request $request)
    {
        $user = $request->user();

        // Single optimized query to get all basic stats at once
        $basicStats = \DB::table('planner_study_sessions')
            ->where('user_id', $user->id)
            ->where('status', 'completed')
            ->selectRaw('
                COUNT(*) as total_sessions,
                COALESCE(SUM(TIMESTAMPDIFF(MINUTE, actual_start_time, actual_end_time)) / 60, 0) as total_study_hours,
                SUM(CASE WHEN completion_percentage = 100 THEN 1 ELSE 0 END) as perfect_sessions
            ')
            ->first();

        // Get streak data in a single query
        $streakData = $this->calculateStreaks($user->id);

        // Calculate achievement statistics from pre-fetched data
        $stats = [
            'total_sessions' => (int) ($basicStats->total_sessions ?? 0),
            'total_study_hours' => (float) ($basicStats->total_study_hours ?? 0),
            'current_streak' => $streakData['current'],
            'longest_streak' => $streakData['longest'],
            'perfect_sessions' => (int) ($basicStats->perfect_sessions ?? 0),
        ];

        // Define achievements with unlock conditions
        $achievements = [
            [
                'id' => 'first_session',
                'title' => 'First Steps',
                'title_ar' => 'الخطوات الأولى',
                'description' => 'Complete your first study session',
                'description_ar' => 'أكمل أول جلسة دراسية',
                'icon' => 'star',
                'unlocked' => $stats['total_sessions'] >= 1,
                'progress' => min(100, ($stats['total_sessions'] / 1) * 100),
            ],
            [
                'id' => 'dedicated_student',
                'title' => 'Dedicated Student',
                'title_ar' => 'طالب مجتهد',
                'description' => 'Complete 10 study sessions',
                'description_ar' => 'أكمل 10 جلسات دراسية',
                'icon' => 'school',
                'unlocked' => $stats['total_sessions'] >= 10,
                'progress' => min(100, ($stats['total_sessions'] / 10) * 100),
            ],
            [
                'id' => 'study_master',
                'title' => 'Study Master',
                'title_ar' => 'سيد الدراسة',
                'description' => 'Complete 50 study sessions',
                'description_ar' => 'أكمل 50 جلسة دراسية',
                'icon' => 'emoji_events',
                'unlocked' => $stats['total_sessions'] >= 50,
                'progress' => min(100, ($stats['total_sessions'] / 50) * 100),
            ],
            [
                'id' => 'week_warrior',
                'title' => 'Week Warrior',
                'title_ar' => 'محارب الأسبوع',
                'description' => 'Maintain a 7-day study streak',
                'description_ar' => 'حافظ على سلسلة دراسة لمدة 7 أيام',
                'icon' => 'local_fire_department',
                'unlocked' => $stats['current_streak'] >= 7,
                'progress' => min(100, ($stats['current_streak'] / 7) * 100),
            ],
            [
                'id' => 'month_champion',
                'title' => 'Month Champion',
                'title_ar' => 'بطل الشهر',
                'description' => 'Maintain a 30-day study streak',
                'description_ar' => 'حافظ على سلسلة دراسة لمدة 30 يوماً',
                'icon' => 'workspace_premium',
                'unlocked' => $stats['current_streak'] >= 30,
                'progress' => min(100, ($stats['current_streak'] / 30) * 100),
            ],
            [
                'id' => 'perfectionist',
                'title' => 'Perfectionist',
                'title_ar' => 'الكمالي',
                'description' => 'Complete 20 perfect sessions (100% completion)',
                'description_ar' => 'أكمل 20 جلسة مثالية (100٪ إكمال)',
                'icon' => 'verified',
                'unlocked' => $stats['perfect_sessions'] >= 20,
                'progress' => min(100, ($stats['perfect_sessions'] / 20) * 100),
            ],
        ];

        return response()->json([
            'achievements' => $achievements,
            'stats' => $stats,
            'unlocked_count' => count(array_filter($achievements, fn($a) => $a['unlocked'])),
            'total_count' => count($achievements),
        ]);
    }

    /**
     * Calculate both current and longest streaks in a single optimized query
     * This eliminates N+1 queries by fetching all dates once
     */
    private function calculateStreaks($userId): array
    {
        // Single query to get all unique study dates
        $sessions = \DB::table('planner_study_sessions')
            ->where('user_id', $userId)
            ->where('status', 'completed')
            ->whereNotNull('actual_end_time')
            ->selectRaw('DATE(actual_end_time) as date')
            ->distinct()
            ->orderBy('date', 'desc') // Order descending for current streak calculation
            ->pluck('date')
            ->map(fn($date) => Carbon::parse($date)->startOfDay());

        if ($sessions->isEmpty()) {
            return ['current' => 0, 'longest' => 0];
        }

        // Calculate current streak (from today backwards)
        $currentStreak = 0;
        $today = now()->startOfDay();

        foreach ($sessions as $sessionDate) {
            $expectedDate = $today->copy()->subDays($currentStreak);

            if ($sessionDate->equalTo($expectedDate)) {
                $currentStreak++;
            } elseif ($sessionDate->lt($expectedDate)) {
                // Past the expected date, stop counting
                break;
            }
        }

        // Calculate longest streak (sort ascending for this)
        $sortedSessions = $sessions->sortBy(fn($date) => $date->timestamp)->values();
        $longestStreak = 1;
        $tempStreak = 1;

        for ($i = 1; $i < $sortedSessions->count(); $i++) {
            $prevDate = $sortedSessions[$i - 1];
            $currDate = $sortedSessions[$i];

            if ($currDate->diffInDays($prevDate) === 1) {
                $tempStreak++;
                $longestStreak = max($longestStreak, $tempStreak);
            } else {
                $tempStreak = 1;
            }
        }

        return [
            'current' => $currentStreak,
            'longest' => max($longestStreak, $currentStreak),
        ];
    }

    // ========================================
    // SESSION ENDPOINTS WITH CONTENT LINKING
    // ========================================

    /**
     * Get today's sessions with curriculum content information
     */
    public function getTodaySessions(Request $request)
    {
        $user = $request->user();

        $sessions = PlannerStudySession::where('user_id', $user->id)
            ->whereDate('scheduled_date', today())
            ->with(['subject', 'subjectPlannerContent.parent.parent'])
            ->orderBy('scheduled_start_time')
            ->get();

        return response()->json([
            'success' => true,
            'data' => PlannerStudySessionResource::collection($sessions),
            'meta' => [
                'date' => today()->format('Y-m-d'),
                'total_sessions' => $sessions->count(),
                'sessions_with_content' => $sessions->where('has_content', true)->count(),
                'sessions_without_content' => $sessions->where('has_content', false)->count(),
            ],
        ]);
    }

    /**
     * Get sessions for a date range with content
     */
    public function getSessionsInRange(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();

        $sessions = PlannerStudySession::where('user_id', $user->id)
            ->whereBetween('scheduled_date', [$request->start_date, $request->end_date])
            ->with(['subject', 'subjectPlannerContent.parent.parent'])
            ->orderBy('scheduled_date')
            ->orderBy('scheduled_start_time')
            ->get();

        return response()->json([
            'success' => true,
            'data' => PlannerStudySessionResource::collection($sessions),
            'meta' => [
                'start_date' => $request->start_date,
                'end_date' => $request->end_date,
                'total_sessions' => $sessions->count(),
            ],
        ]);
    }

    /**
     * Get a specific session with content details
     */
    public function getSessionWithContent(Request $request, $id)
    {
        $user = $request->user();

        $session = PlannerStudySession::where('user_id', $user->id)
            ->where('id', $id)
            ->with(['subject', 'subjectPlannerContent.parent.parent', 'originalTopicTestSession'])
            ->first();

        if (!$session) {
            return response()->json([
                'success' => false,
                'error' => 'Session not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => new PlannerStudySessionResource($session),
        ]);
    }

    /**
     * Complete a session and update content progress
     */
    public function completeSessionWithProgress(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'completion_percentage' => 'nullable|integer|min:0|max:100',
            'actual_duration_minutes' => 'nullable|integer|min:0',
            'mood' => 'nullable|in:positive,neutral,negative',
            'notes' => 'nullable|string|max:1000',
            'mark_phase_complete' => 'nullable|boolean',
            'score' => 'nullable|integer|min:0|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();

        $session = PlannerStudySession::where('user_id', $user->id)
            ->where('id', $id)
            ->with('subjectPlannerContent')
            ->first();

        if (!$session) {
            return response()->json([
                'success' => false,
                'error' => 'Session not found',
            ], 404);
        }

        // Update session
        $session->update([
            'status' => 'completed',
            'actual_end_time' => now(),
            'actual_duration_minutes' => $request->actual_duration_minutes ?? $session->duration_minutes,
            'completion_percentage' => $request->completion_percentage ?? 100,
            'mood' => $request->mood,
            'user_notes' => $request->notes,
        ]);

        // Update content progress if session has linked content
        $contentProgress = null;
        if ($session->has_content && $session->subject_planner_content_id && $request->boolean('mark_phase_complete', true)) {
            $progress = UserSubjectPlannerProgress::firstOrCreate(
                [
                    'user_id' => $user->id,
                    'subject_planner_content_id' => $session->subject_planner_content_id,
                ],
                [
                    'status' => 'not_started',
                    'completion_percentage' => 0,
                ]
            );

            // Mark phase as completed
            if ($session->content_phase) {
                $progress->markPhaseCompleted($session->content_phase);
            }

            // Record study session
            $progress->recordStudySession(
                $request->actual_duration_minutes ?? $session->duration_minutes,
                $request->score
            );

            $contentProgress = $progress->getSummary();
        }

        // Handle score-based adaptation for topic tests (promt.md algorithm)
        $adaptationResult = null;
        if ($session->session_type === PlannerStudySession::TYPE_TOPIC_TEST && $request->has('score')) {
            $score = (int) $request->score;
            $session->update(['score' => $score]);

            // Trigger adaptation based on score
            $this->algorithmService->adaptAfterTopicTest($session, $score);

            $adaptationResult = [
                'score' => $score,
                'adapted' => $score < 80,
                'message' => match (true) {
                    $score < 60 => 'تمت إضافة جلسات تمارين إضافية وإعادة اختبار بعد 3 أيام',
                    $score < 80 => 'تمت إضافة جلسة تمارين ومراجعة متباعدة',
                    default => 'نتيجة ممتازة! استمر على هذا المستوى',
                },
            ];
        }

        return response()->json([
            'success' => true,
            'message' => 'Session completed successfully',
            'data' => new PlannerStudySessionResource($session->fresh()->load(['subject', 'subjectPlannerContent'])),
            'content_progress' => $contentProgress,
            'adaptation_result' => $adaptationResult,
        ]);
    }

    /**
     * Get spaced review sessions due
     */
    public function getSpacedReviewsDue(Request $request)
    {
        $user = $request->user();
        $date = $request->query('date', today()->format('Y-m-d'));

        $sessions = PlannerStudySession::where('user_id', $user->id)
            ->dueSpacedReviews(Carbon::parse($date))
            ->with(['subject', 'subjectPlannerContent.parent'])
            ->orderBy('scheduled_start_time')
            ->get();

        return response()->json([
            'success' => true,
            'data' => PlannerStudySessionResource::collection($sessions),
            'meta' => [
                'date' => $date,
                'total_due' => $sessions->count(),
            ],
        ]);
    }

    /**
     * Generate HTML planner file for a schedule
     *
     * @param \App\Models\User $user
     * @param PlannerSchedule $schedule
     * @return array
     */
    private function generateHtmlPlanner($user, PlannerSchedule $schedule): array
    {
        try {
            // Load sessions with subjects
            $sessions = PlannerStudySession::where('schedule_id', $schedule->id)
                ->whereNull('deleted_at')
                ->with('subject')
                ->orderBy('scheduled_date')
                ->orderBy('scheduled_start_time')
                ->get();

            // Group sessions by date
            $sessionsByDate = $sessions->groupBy(function ($session) {
                return Carbon::parse($session->scheduled_date)->format('Y-m-d');
            });

            // Calculate stats
            $startDate = Carbon::parse($schedule->start_date);
            $endDate = Carbon::parse($schedule->end_date);
            $totalSessions = $sessions->where('is_break', false)->count();
            $totalBreaks = $sessions->where('is_break', true)->count();
            $totalStudyMinutes = $sessions->where('is_break', false)->sum('duration_minutes');
            $generatedAt = now();

            // French day names
            $frenchDays = [
                'Sunday' => 'Dimanche',
                'Monday' => 'Lundi',
                'Tuesday' => 'Mardi',
                'Wednesday' => 'Mercredi',
                'Thursday' => 'Jeudi',
                'Friday' => 'Vendredi',
                'Saturday' => 'Samedi',
            ];

            // Session types translation
            $sessionTypes = [
                'study' => 'Etude',
                'revision' => 'Revision',
                'practice' => 'Exercices',
                'longRevision' => 'Revision approfondie',
                'test' => 'Test',
                'break' => 'Pause',
            ];

            // Build HTML content
            $html = '<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Planning d\'etude</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; font-size: 14px; line-height: 1.6; color: #333; background: #f5f5f5; }
        .container { max-width: 900px; margin: 0 auto; padding: 20px; background: #fff; }
        .header { text-align: center; margin-bottom: 30px; padding-bottom: 20px; border-bottom: 3px solid #6366f1; }
        .header h1 { color: #6366f1; font-size: 28px; margin-bottom: 8px; }
        .header .subtitle { color: #666; font-size: 16px; margin-bottom: 10px; }
        .header .date-range { margin-top: 10px; padding: 10px 20px; background: #f3f4f6; display: inline-block; border-radius: 8px; font-size: 14px; }
        .stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 15px; margin-bottom: 30px; }
        .stat-card { text-align: center; padding: 20px; background: #f8fafc; border: 1px solid #e5e7eb; border-radius: 8px; }
        .stat-value { font-size: 28px; font-weight: bold; color: #6366f1; display: block; margin-bottom: 5px; }
        .stat-label { font-size: 12px; color: #666; }
        .legend { margin-bottom: 20px; text-align: center; font-size: 13px; }
        .legend-item { display: inline-block; margin: 0 15px; }
        .indicator { display: inline-block; width: 12px; height: 12px; margin-right: 5px; vertical-align: middle; border-radius: 3px; }
        .indicator-study { background: #6366f1; }
        .indicator-break { background: #10b981; }
        .indicator-prayer { background: #f59e0b; }
        .day-section { margin-bottom: 25px; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .day-header { background: #6366f1; color: white; padding: 12px 20px; font-size: 16px; font-weight: bold; }
        .sessions-table { width: 100%; border-collapse: collapse; background: white; }
        .sessions-table th { background: #f3f4f6; padding: 12px 15px; text-align: center; font-weight: bold; font-size: 13px; color: #374151; border: 1px solid #e5e7eb; }
        .sessions-table td { padding: 10px 15px; border: 1px solid #e5e7eb; font-size: 13px; text-align: center; }
        .row-study { background: #fff; }
        .row-break { background: #ecfdf5; }
        .row-prayer { background: #fffbeb; }
        .time-cell { font-weight: bold; color: #6366f1; width: 80px; }
        .subject-cell { font-weight: bold; color: #4338ca; }
        .break-text { color: #10b981; font-weight: bold; }
        .prayer-text { color: #f59e0b; font-weight: bold; }
        .duration-cell { color: #6b7280; width: 70px; }
        .footer { margin-top: 30px; text-align: center; padding-top: 20px; border-top: 2px solid #e5e7eb; color: #9ca3af; font-size: 12px; }
        .footer .logo { color: #6366f1; font-weight: bold; font-size: 16px; margin-bottom: 5px; }
        @media print { body { background: #fff; } .container { max-width: 100%; } .day-section { page-break-inside: avoid; } }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>MEMO - Planificateur Intelligent</h1>
            <div class="subtitle">Planning d\'etude personnel</div>
            <div class="date-range">Du ' . $startDate->format('d/m/Y') . ' au ' . $endDate->format('d/m/Y') . '</div>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <span class="stat-value">' . $totalSessions . '</span>
                <span class="stat-label">Seances d\'etude</span>
            </div>
            <div class="stat-card">
                <span class="stat-value">' . $totalBreaks . '</span>
                <span class="stat-label">Pauses</span>
            </div>
            <div class="stat-card">
                <span class="stat-value">' . round($totalStudyMinutes / 60, 1) . '</span>
                <span class="stat-label">Heures d\'etude</span>
            </div>
            <div class="stat-card">
                <span class="stat-value">' . $sessionsByDate->count() . '</span>
                <span class="stat-label">Jours</span>
            </div>
        </div>

        <div class="legend">
            <span class="legend-item"><span class="indicator indicator-study"></span> Etude</span>
            <span class="legend-item"><span class="indicator indicator-break"></span> Pause</span>
            <span class="legend-item"><span class="indicator indicator-prayer"></span> Priere</span>
        </div>';

            // Add day sections
            foreach ($sessionsByDate as $date => $daySessions) {
                $dateCarbon = Carbon::parse($date);
                $dayName = $frenchDays[$dateCarbon->format('l')] ?? $dateCarbon->format('l');

                $html .= '
        <div class="day-section">
            <div class="day-header">' . $dayName . ' - ' . $dateCarbon->format('d/m/Y') . '</div>
            <table class="sessions-table">
                <thead>
                    <tr>
                        <th>Heure</th>
                        <th>Matiere / Activite</th>
                        <th>Duree</th>
                        <th>Contenu</th>
                    </tr>
                </thead>
                <tbody>';

                foreach ($daySessions as $session) {
                    $isBreak = $session->is_break ?? false;
                    $contentTitle = $session->content_title ?? '';
                    $isPrayer = mb_strpos($contentTitle, 'صلا') !== false;
                    $rowClass = $isPrayer ? 'row-prayer' : ($isBreak ? 'row-break' : 'row-study');

                    // Get French subject name
                    $subjectName = 'Matiere';
                    if ($session->subject) {
                        $subjectName = $session->subject->name_fr
                            ?? $session->subject->name_en
                            ?? $session->subject->name
                            ?? $session->subject->name_ar
                            ?? 'Matiere';
                    }

                    $sessionType = $sessionTypes[$session->session_type ?? 'study'] ?? 'Etude';
                    $startTime = substr($session->scheduled_start_time, 0, 5);

                    $html .= '
                    <tr class="' . $rowClass . '">
                        <td class="time-cell">' . $startTime . '</td>
                        <td>';

                    if ($isBreak) {
                        if ($isPrayer) {
                            $html .= '<span class="prayer-text">Priere</span>';
                        } else {
                            $html .= '<span class="break-text">Pause</span>';
                        }
                    } else {
                        $html .= '<span class="subject-cell">' . htmlspecialchars($subjectName) . '</span>';
                    }

                    $html .= '</td>
                        <td class="duration-cell">' . $session->duration_minutes . ' min</td>
                        <td>' . ($isBreak ? '-' : $sessionType) . '</td>
                    </tr>';
                }

                $html .= '
                </tbody>
            </table>
        </div>';
            }

            // Add footer
            $html .= '
        <div class="footer">
            <div class="logo">MEMO - Planificateur Intelligent</div>
            <div>Genere le ' . $generatedAt->format('d/m/Y') . ' a ' . $generatedAt->format('H:i') . '</div>
        </div>
    </div>
</body>
</html>';

            // Create directory if it doesn't exist
            $directory = public_path('planner');
            if (!file_exists($directory)) {
                mkdir($directory, 0755, true);
            }

            // Generate filename
            $date = now()->format('Y-m-d');
            $timestamp = now()->format('His');
            $fileName = "planner_{$user->id}_{$date}_{$schedule->id}_{$timestamp}.html";
            $filePath = $directory . DIRECTORY_SEPARATOR . $fileName;

            // Save HTML file
            file_put_contents($filePath, $html);

            // Generate URL
            $url = url("planner/{$fileName}");

            \Log::info("[PlannerController] HTML planner generated successfully", [
                'user_id' => $user->id,
                'schedule_id' => $schedule->id,
                'file_path' => $filePath,
                'url' => $url,
            ]);

            return [
                'success' => true,
                'file_name' => $fileName,
                'file_path' => "planner/{$fileName}",
                'url' => $url,
            ];

        } catch (\Exception $e) {
            \Log::error("[PlannerController] Failed to generate HTML planner", [
                'user_id' => $user->id,
                'schedule_id' => $schedule->id,
                'error' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }
}
