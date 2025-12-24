<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\StudySession;
use App\Services\SessionService;
use App\Services\PointsCalculationService;
use App\Services\NotificationService;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class StudySessionController extends Controller
{
    protected SessionService $sessionService;
    protected PointsCalculationService $pointsService;
    protected NotificationService $notificationService;

    public function __construct(
        SessionService $sessionService,
        PointsCalculationService $pointsService,
        NotificationService $notificationService
    ) {
        $this->sessionService = $sessionService;
        $this->pointsService = $pointsService;
        $this->notificationService = $notificationService;
    }

    /**
     * Get today's sessions
     */
    public function getTodaySessions(Request $request)
    {
        $user = $request->user();
        $sessions = $this->sessionService->getTodaySessions($user);

        return response()->json([
            'data' => $sessions,
        ]);
    }

    /**
     * Get upcoming sessions
     */
    public function getUpcomingSessions(Request $request)
    {
        $user = $request->user();
        $days = $request->query('days', 7);
        $sessions = $this->sessionService->getUpcomingSessions($user, $days);

        return response()->json([
            'data' => $sessions,
        ]);
    }

    /**
     * Get current active session
     */
    public function getCurrentSession(Request $request)
    {
        $user = $request->user();
        $session = $this->sessionService->getCurrentSession($user);

        if (!$session) {
            return response()->json([
                'message' => 'No active session',
            ], 404);
        }

        return response()->json([
            'data' => $session,
        ]);
    }

    /**
     * Get specific session
     */
    public function getSession(Request $request, $id)
    {
        $user = $request->user();
        $session = StudySession::where('user_id', $user->id)
            ->where('id', $id)
            ->with(['subject', 'activities', 'suggestedContent'])
            ->first();

        if (!$session) {
            return response()->json([
                'error' => 'Session not found',
            ], 404);
        }

        return response()->json([
            'data' => $session,
        ]);
    }

    /**
     * Start a session
     */
    public function startSession(Request $request, $id)
    {
        $user = $request->user();
        $session = StudySession::where('user_id', $user->id)
            ->where('id', $id)
            ->first();

        if (!$session) {
            return response()->json([
                'error' => 'Session not found',
            ], 404);
        }

        if ($session->status !== 'scheduled') {
            return response()->json([
                'error' => 'Session cannot be started',
            ], 422);
        }

        try {
            $activity = $this->sessionService->startSession($session);

            return response()->json([
                'message' => 'Session started successfully',
                'data' => $session->fresh()->load('activities'),
                'activity' => $activity,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Pause a session
     */
    public function pauseSession(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'reason' => 'nullable|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        $session = StudySession::where('user_id', $user->id)
            ->where('id', $id)
            ->first();

        if (!$session) {
            return response()->json([
                'error' => 'Session not found',
            ], 404);
        }

        try {
            $activity = $this->sessionService->pauseSession($session, $request->reason);

            return response()->json([
                'message' => 'Session paused successfully',
                'data' => $session->fresh()->load('activities'),
                'activity' => $activity,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Resume a session
     */
    public function resumeSession(Request $request, $id)
    {
        $user = $request->user();
        $session = StudySession::where('user_id', $user->id)
            ->where('id', $id)
            ->first();

        if (!$session) {
            return response()->json([
                'error' => 'Session not found',
            ], 404);
        }

        try {
            $activity = $this->sessionService->resumeSession($session);

            return response()->json([
                'message' => 'Session resumed successfully',
                'data' => $session->fresh()->load('activities'),
                'activity' => $activity,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Complete a session
     */
    public function completeSession(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'completion_percentage' => 'nullable|integer|min:0|max:100',
            'focus_score' => 'nullable|integer|min:1|max:10',
            'difficulty_rating' => 'nullable|integer|min:1|max:10',
            'notes' => 'nullable|string|max:1000',
            'mood' => 'nullable|in:happy,neutral,sad',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        $session = StudySession::where('user_id', $user->id)
            ->where('id', $id)
            ->first();

        if (!$session) {
            return response()->json([
                'error' => 'Session not found',
            ], 404);
        }

        try {
            $previousLevel = $user->current_level;

            $activity = $this->sessionService->completeSession(
                $session,
                $request->completion_percentage ?? 100,
                $request->focus_score,
                $request->difficulty_rating,
                $request->notes,
                $request->mood
            );

            // Get updated user points info
            $pointsInfo = $this->pointsService->getUserPointsInfo($user);

            // Check for level up and send achievement notification
            $user->refresh();
            if ($user->current_level > $previousLevel) {
                $this->notificationService->sendAchievementNotification(
                    $user,
                    'level_up',
                    [
                        'previous_level' => $previousLevel,
                        'new_level' => $user->current_level,
                        'total_points' => $user->total_points,
                    ]
                );
            }

            // Check for streak achievement (7 days)
            $consecutiveDays = $this->sessionService->getUserStreak($user);
            if ($consecutiveDays == 7) {
                $this->notificationService->sendAchievementNotification(
                    $user,
                    'streak_7_days',
                    ['streak_days' => 7]
                );
            }

            return response()->json([
                'message' => 'Session completed successfully',
                'data' => $session->fresh()->load('activities'),
                'activity' => $activity,
                'points_earned' => $session->points_earned ?? 0,
                'user_points' => $pointsInfo,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Mark session as missed
     */
    public function markAsMissed(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'reason' => 'nullable|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        $session = StudySession::where('user_id', $user->id)
            ->where('id', $id)
            ->first();

        if (!$session) {
            return response()->json([
                'error' => 'Session not found',
            ], 404);
        }

        try {
            $this->sessionService->markSessionAsMissed($session, $request->reason);

            return response()->json([
                'message' => 'Session marked as missed',
                'data' => $session->fresh(),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Reschedule a session
     */
    public function rescheduleSession(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'new_start' => 'required|date|after:now',
            'new_end' => 'required|date|after:new_start',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        $session = StudySession::where('user_id', $user->id)
            ->where('id', $id)
            ->first();

        if (!$session) {
            return response()->json([
                'error' => 'Session not found',
            ], 404);
        }

        try {
            $newSession = $this->sessionService->rescheduleSession(
                $session,
                Carbon::parse($request->new_start),
                Carbon::parse($request->new_end)
            );

            return response()->json([
                'message' => 'Session rescheduled successfully',
                'data' => $newSession,
                'old_session' => $session->fresh(),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Toggle pin session
     */
    public function togglePin(Request $request, $id)
    {
        $user = $request->user();
        $session = StudySession::where('user_id', $user->id)
            ->where('id', $id)
            ->first();

        if (!$session) {
            return response()->json([
                'error' => 'Session not found',
            ], 404);
        }

        $this->sessionService->togglePinSession($session);

        return response()->json([
            'message' => 'Session pin toggled',
            'data' => $session->fresh(),
        ]);
    }

    /**
     * Get session statistics
     */
    public function getStatistics(Request $request)
    {
        $user = $request->user();
        $startDate = $request->query('start_date') ? Carbon::parse($request->query('start_date')) : null;
        $endDate = $request->query('end_date') ? Carbon::parse($request->query('end_date')) : null;

        $statistics = $this->sessionService->getSessionStatistics($user, $startDate, $endDate);

        return response()->json([
            'data' => $statistics,
        ]);
    }

    /**
     * Get sessions in date range (required by Flutter app)
     */
    public function getSessionsInRange(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|exists:users,id',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        // Ensure user can only access their own sessions
        if ($request->user_id != $user->id && !$user->is_admin) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $sessions = StudySession::where('user_id', $request->user_id)
            ->whereBetween('scheduled_date', [
                Carbon::parse($request->start_date)->startOfDay(),
                Carbon::parse($request->end_date)->endOfDay(),
            ])
            ->with(['subject', 'chapter', 'suggestedContent'])
            ->orderBy('scheduled_date')
            ->orderBy('scheduled_start_time')
            ->get();

        return response()->json([
            'data' => $sessions,
        ]);
    }

    /**
     * Create a new study session (required by Flutter app)
     */
    public function createSession(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|exists:users,id',
            'subject_id' => 'required|exists:subjects,id',
            'chapter_id' => 'nullable|exists:chapters,id',
            'scheduled_date' => 'required|date',
            'scheduled_start_time' => 'required|date_format:H:i',
            'scheduled_end_time' => 'required|date_format:H:i|after:scheduled_start_time',
            'duration_minutes' => 'required|integer|min:1',
            'suggested_content_id' => 'nullable|exists:contents,id',
            'suggested_content_type' => 'nullable|in:lesson,summary,exercise,test,quiz',
            'content_title' => 'nullable|string|max:255',
            'session_type' => 'required|in:study,revision,practice,longRevision,test',
            'required_energy_level' => 'required|in:veryLow,low,medium,high',
            'priority_score' => 'nullable|integer|min:1|max:100',
            'use_pomodoro_technique' => 'nullable|boolean',
            'pomodoro_duration_minutes' => 'nullable|integer|min:1',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        // Ensure user can only create their own sessions
        if ($request->user_id != $user->id && !$user->is_admin) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $session = StudySession::create([
            'user_id' => $request->user_id,
            'subject_id' => $request->subject_id,
            'chapter_id' => $request->chapter_id,
            'scheduled_date' => $request->scheduled_date,
            'scheduled_start_time' => $request->scheduled_start_time,
            'scheduled_end_time' => $request->scheduled_end_time,
            'estimated_duration_minutes' => $request->duration_minutes,
            'suggested_content_id' => $request->suggested_content_id,
            'suggested_content_type' => $request->suggested_content_type,
            'content_title' => $request->content_title,
            'session_type' => $request->session_type,
            'required_energy_level' => $request->required_energy_level,
            'priority_score' => $request->priority_score ?? 50,
            'status' => 'scheduled',
        ]);

        $session->load(['subject', 'chapter', 'suggestedContent']);

        return response()->json([
            'data' => $session,
            'message' => 'Session created successfully',
        ], 201);
    }

    /**
     * Update an existing study session (required by Flutter app)
     */
    public function updateSession(Request $request, $id)
    {
        $user = $request->user();
        $session = StudySession::where('id', $id)->first();

        if (!$session) {
            return response()->json(['error' => 'Session not found'], 404);
        }

        // Ensure user can only update their own sessions
        if ($session->user_id != $user->id && !$user->is_admin) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $validator = Validator::make($request->all(), [
            'subject_id' => 'sometimes|exists:subjects,id',
            'chapter_id' => 'nullable|exists:chapters,id',
            'scheduled_date' => 'sometimes|date',
            'scheduled_start_time' => 'sometimes|date_format:H:i',
            'scheduled_end_time' => 'sometimes|date_format:H:i',
            'duration_minutes' => 'sometimes|integer|min:1',
            'suggested_content_id' => 'nullable|exists:contents,id',
            'suggested_content_type' => 'nullable|in:lesson,summary,exercise,test,quiz',
            'content_title' => 'nullable|string|max:255',
            'session_type' => 'sometimes|in:study,revision,practice,longRevision,test',
            'required_energy_level' => 'sometimes|in:veryLow,low,medium,high',
            'priority_score' => 'nullable|integer|min:1|max:100',
            'status' => 'sometimes|in:scheduled,inProgress,paused,completed,missed,skipped',
            'user_notes' => 'nullable|string|max:1000',
            'completion_percentage' => 'nullable|integer|min:0|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
            ], 422);
        }

        $updateData = $request->only([
            'subject_id',
            'chapter_id',
            'scheduled_date',
            'scheduled_start_time',
            'scheduled_end_time',
            'suggested_content_id',
            'suggested_content_type',
            'content_title',
            'session_type',
            'required_energy_level',
            'priority_score',
            'status',
            'user_notes',
            'completion_percentage',
        ]);

        if ($request->has('duration_minutes')) {
            $updateData['estimated_duration_minutes'] = $request->duration_minutes;
        }

        $session->update($updateData);
        $session->load(['subject', 'chapter', 'suggestedContent']);

        return response()->json([
            'data' => $session,
            'message' => 'Session updated successfully',
        ]);
    }

    /**
     * Delete a study session (required by Flutter app)
     */
    public function deleteSession(Request $request, $id)
    {
        $user = $request->user();
        $session = StudySession::where('id', $id)->first();

        if (!$session) {
            return response()->json(['error' => 'Session not found'], 404);
        }

        // Ensure user can only delete their own sessions
        if ($session->user_id != $user->id && !$user->is_admin) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        // Prevent deletion of completed sessions
        if ($session->status === 'completed') {
            return response()->json([
                'error' => 'Cannot delete completed sessions',
            ], 422);
        }

        $session->delete();

        return response()->json([
            'message' => 'Session deleted successfully',
        ]);
    }

    /**
     * Delete all sessions for the authenticated user (required by Flutter app)
     */
    public function deleteAll(Request $request)
    {
        $user = $request->user();

        // Optional: Allow filtering by status
        $status = $request->query('status');

        // Delete from both session tables for complete cleanup
        // PlannerStudySession is used by the new planner feature
        $plannerQuery = \App\Models\PlannerStudySession::where('user_id', $user->id);
        if ($status) {
            $plannerQuery->where('status', $status);
        }
        $plannerDeletedCount = $plannerQuery->forceDelete(); // Use forceDelete to bypass soft deletes

        // Also delete from legacy StudySession table for backward compatibility
        $legacyQuery = StudySession::where('user_id', $user->id);
        if ($status) {
            $legacyQuery->where('status', $status);
        }
        $legacyDeletedCount = $legacyQuery->delete();

        // Delete ALL planner schedules for this user (not just deactivate)
        $schedulesDeletedCount = \App\Models\PlannerSchedule::where('user_id', $user->id)
            ->forceDelete(); // Force delete to completely remove schedules

        $totalDeleted = $plannerDeletedCount + $legacyDeletedCount;

        return response()->json([
            'message' => 'All sessions and schedules deleted successfully',
            'deleted_count' => $totalDeleted,
            'planner_sessions_deleted' => $plannerDeletedCount,
            'legacy_sessions_deleted' => $legacyDeletedCount,
            'schedules_deleted' => $schedulesDeletedCount,
        ]);
    }

    /**
     * Skip a session with reason (required by Flutter app)
     */
    public function skipSession(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'reason' => 'nullable|string|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        $session = StudySession::where('user_id', $user->id)
            ->where('id', $id)
            ->first();

        if (!$session) {
            return response()->json(['error' => 'Session not found'], 404);
        }

        try {
            $activity = $this->sessionService->skipSession($session, $request->reason);

            return response()->json([
                'message' => 'Session skipped successfully',
                'data' => $session->fresh()->load('activities'),
                'activity' => $activity,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get session history with aggregations for calendar view
     *
     * Supports flexible date ranges and grouping for heatmap visualization
     * Query params: start_date, end_date, group_by (day|week|month)
     * Filter params: status, subject_id, mood, min_duration, max_duration, session_type
     */
    public function getSessionHistory(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'group_by' => 'nullable|in:day,week,month',
            'status' => 'nullable|in:scheduled,inProgress,paused,completed,missed,skipped',
            'subject_id' => 'nullable|integer|exists:subjects,id',
            'mood' => 'nullable|in:happy,neutral,sad',
            'min_duration' => 'nullable|integer|min:0',
            'max_duration' => 'nullable|integer|min:0',
            'session_type' => 'nullable|in:study,revision,practice,longRevision,test',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        $startDate = $request->input('start_date', Carbon::now()->subMonths(3)->startOfDay());
        $endDate = $request->input('end_date', Carbon::now()->endOfDay());
        $groupBy = $request->input('group_by', 'day');

        // Convert to Carbon instances if strings
        if (is_string($startDate)) {
            $startDate = Carbon::parse($startDate);
        }
        if (is_string($endDate)) {
            $endDate = Carbon::parse($endDate);
        }

        // Build base query with optional filters
        $query = StudySession::where('user_id', $user->id)
            ->whereBetween('scheduled_date', [$startDate, $endDate])
            ->with(['subject:id,name_ar,name_fr,name_en,color']);

        // Apply status filter (default to completed for backward compatibility if no filter)
        if ($request->has('status')) {
            $query->where('status', $request->input('status'));
        } else {
            // Default to completed only when no status filter is specified
            $query->where('status', 'completed');
        }

        // Apply subject filter
        if ($request->has('subject_id')) {
            $query->where('subject_id', $request->input('subject_id'));
        }

        // Apply mood filter
        if ($request->has('mood')) {
            $query->where('mood', $request->input('mood'));
        }

        // Apply duration filters (on actual duration or estimated duration)
        if ($request->has('min_duration')) {
            $query->where(function ($q) use ($request) {
                $q->whereRaw('COALESCE(actual_duration_minutes, estimated_duration_minutes) >= ?', [$request->input('min_duration')]);
            });
        }
        if ($request->has('max_duration')) {
            $query->where(function ($q) use ($request) {
                $q->whereRaw('COALESCE(actual_duration_minutes, estimated_duration_minutes) <= ?', [$request->input('max_duration')]);
            });
        }

        // Apply session type filter
        if ($request->has('session_type')) {
            $query->where('session_type', $request->input('session_type'));
        }

        // Get detailed sessions for list view
        $sessions = $query->get()->map(function ($session) {
            return [
                'id' => $session->id,
                'subject_id' => $session->subject_id,
                'subject_name' => $session->subject->name_ar ?? 'مادة محذوفة',
                'subject_color' => $session->subject->color ?? '#6366F1',
                'scheduled_date' => $session->scheduled_date->format('Y-m-d'),
                'scheduled_start_time' => $session->scheduled_start_time,
                'scheduled_end_time' => $session->scheduled_end_time,
                'actual_start_time' => $session->actual_start_time?->format('Y-m-d H:i:s'),
                'actual_end_time' => $session->actual_end_time?->format('Y-m-d H:i:s'),
                'duration_minutes' => $session->actual_duration_minutes ?? $session->estimated_duration_minutes,
                'points_earned' => $session->points_earned ?? 0,
                'mood' => $session->mood,
                'completion_percentage' => $session->completion_percentage ?? 100,
                'user_notes' => $session->user_notes,
                'session_type' => $session->session_type,
                'content_title' => $session->content_title,
            ];
        });

        // Aggregate data by grouping (for heatmap)
        $aggregated = $this->aggregateSessionsByPeriod($sessions, $groupBy);

        // Calculate overall statistics
        $totalSessions = $sessions->count();
        $totalMinutes = $sessions->sum('duration_minutes');
        $totalPoints = $sessions->sum('points_earned');
        $averageSessionDuration = $totalSessions > 0 ? round($totalMinutes / $totalSessions) : 0;

        // Mood distribution
        $moodCounts = [
            'happy' => $sessions->where('mood', 'happy')->count(),
            'neutral' => $sessions->where('mood', 'neutral')->count(),
            'sad' => $sessions->where('mood', 'sad')->count(),
        ];

        // Subject breakdown
        $subjectBreakdown = $sessions->groupBy('subject_id')->map(function ($subjectSessions) {
            $first = $subjectSessions->first();
            return [
                'subject_id' => $first['subject_id'],
                'subject_name' => $first['subject_name'],
                'subject_color' => $first['subject_color'],
                'session_count' => $subjectSessions->count(),
                'total_minutes' => $subjectSessions->sum('duration_minutes'),
                'total_points' => $subjectSessions->sum('points_earned'),
            ];
        })->values();

        return response()->json([
            'data' => [
                'sessions' => $sessions->values(),
                'aggregated' => $aggregated,
                'statistics' => [
                    'total_sessions' => $totalSessions,
                    'total_minutes' => $totalMinutes,
                    'total_hours' => round($totalMinutes / 60, 1),
                    'total_points' => $totalPoints,
                    'average_session_duration' => $averageSessionDuration,
                    'mood_distribution' => $moodCounts,
                    'subject_breakdown' => $subjectBreakdown,
                ],
                'date_range' => [
                    'start_date' => $startDate->format('Y-m-d'),
                    'end_date' => $endDate->format('Y-m-d'),
                    'group_by' => $groupBy,
                ],
                'filters_applied' => [
                    'status' => $request->input('status'),
                    'subject_id' => $request->input('subject_id'),
                    'mood' => $request->input('mood'),
                    'min_duration' => $request->input('min_duration'),
                    'max_duration' => $request->input('max_duration'),
                    'session_type' => $request->input('session_type'),
                ],
            ],
        ]);
    }

    /**
     * Aggregate sessions by time period for heatmap visualization
     */
    private function aggregateSessionsByPeriod($sessions, $groupBy)
    {
        $grouped = $sessions->groupBy(function ($session) use ($groupBy) {
            $date = Carbon::parse($session['scheduled_date']);

            switch ($groupBy) {
                case 'week':
                    // Return first day of week (Sunday)
                    return $date->startOfWeek()->format('Y-m-d');
                case 'month':
                    // Return first day of month
                    return $date->startOfMonth()->format('Y-m-d');
                case 'day':
                default:
                    return $session['scheduled_date'];
            }
        });

        return $grouped->map(function ($periodSessions, $date) {
            $sessionCount = $periodSessions->count();
            $totalMinutes = $periodSessions->sum('duration_minutes');
            $totalPoints = $periodSessions->sum('points_earned');

            // Calculate intensity for heatmap (0-4 scale)
            // Based on session count: 0 = none, 1 = 1-2, 2 = 3-4, 3 = 5-6, 4 = 7+
            $intensity = min(4, floor($sessionCount / 2) + ($sessionCount > 0 ? 1 : 0));

            // Mood summary
            $moodCounts = [
                'happy' => $periodSessions->where('mood', 'happy')->count(),
                'neutral' => $periodSessions->where('mood', 'neutral')->count(),
                'sad' => $periodSessions->where('mood', 'sad')->count(),
            ];

            return [
                'date' => $date,
                'session_count' => $sessionCount,
                'total_minutes' => $totalMinutes,
                'total_points' => $totalPoints,
                'intensity' => $intensity,
                'mood_distribution' => $moodCounts,
            ];
        })->values();
    }
}
