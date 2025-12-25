<?php

namespace App\Http\Controllers;

use App\Models\PlannerSubject;
use App\Models\PlannerSchedule;
use App\Models\PlannerStudySession;
use App\Models\PlannerSetting;
use App\Models\PlannerExam;
use App\Models\Subject;
use App\Services\SchedulingAlgorithmService;
use App\Services\ContentAllocationService;
use App\Services\PlannerService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class PlannerController extends Controller
{
    protected PlannerService $plannerService;

    public function __construct(PlannerService $plannerService)
    {
        $this->plannerService = $plannerService;
    }
    /**
     * 1. Batch create planner subjects
     * POST /api/v1/planner/subjects/batch
     */
    public function batchCreateSubjects(Request $request)
    {
        $validated = $request->validate([
            'subjects' => 'required|array',
            'subjects.*.subject_id' => 'required|exists:subjects,id',
            'subjects.*.priority' => 'required|in:low,medium,high,critical',
            'subjects.*.difficulty_level' => 'required|integer|min:1|max:5',
            'subjects.*.is_selected' => 'required|boolean',
        ]);

        $user = $request->user();

        // Delete existing planner subjects for this user
        PlannerSubject::where('user_id', $user->id)->delete();

        // Create new planner subjects
        $plannerSubjects = [];
        foreach ($validated['subjects'] as $subjectData) {
            $plannerSubjects[] = PlannerSubject::create([
                'user_id' => $user->id,
                'subject_id' => $subjectData['subject_id'],
                'priority' => $subjectData['priority'],
                'difficulty_level' => $subjectData['difficulty_level'],
                'is_selected' => $subjectData['is_selected'],
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Subjects created successfully',
            'data' => $plannerSubjects,
        ], 201);
    }

    /**
     * 2. Get user's planner subjects
     * GET /api/v1/planner/subjects
     */
    public function getSubjects(Request $request)
    {
        $user = $request->user();

        $plannerSubjects = PlannerSubject::with('subject')
            ->where('user_id', $user->id)
            ->get()
            ->map(function ($ps) {
                return [
                    'id' => $ps->subject->id, // Use subjects.id for consistency
                    'subject_id' => $ps->subject->id, // Same as id
                    'name' => $ps->subject->name_ar,
                    'name_ar' => $ps->subject->name_ar,
                    'name_en' => $ps->subject->name_fr,
                    'color' => $ps->subject->color,
                    'coefficient' => $ps->subject->coefficient,
                    'priority' => $ps->priority,
                    'difficulty_level' => $ps->difficulty_level,
                    'is_selected' => $ps->is_selected,
                    'average_score' => null,
                    'completion_percentage' => 0,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $plannerSubjects,
        ]);
    }

    /**
     * 3. Generate schedule
     * POST /api/v1/planner/schedules/generate
     */
    public function generateSchedule(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'start_date' => 'required|date',
            'end_date' => 'required|date|after:start_date',
            'subject_ids' => 'required|array',
            'subject_ids.*' => 'required|exists:subjects,id',
        ]);

        // Get academic profile
        $academicProfile = $user->academicProfile;
        if (!$academicProfile) {
            return response()->json([
                'message' => 'Academic profile not found. Please complete your profile first.',
            ], 422);
        }

        // Deactivate existing schedules
        PlannerSchedule::where('user_id', $user->id)
            ->update(['is_active' => false]);

        // Create new schedule
        $schedule = PlannerSchedule::create([
            'user_id' => $user->id,
            'academic_year_id' => $academicProfile->academic_year_id,
            'academic_stream_id' => $academicProfile->academic_stream_id,
            'start_date' => $validated['start_date'],
            'end_date' => $validated['end_date'],
            'is_active' => true,
            'generation_algorithm_version' => '3.0-unit-weekly',
        ]);

        // Get planner settings
        $settings = PlannerSetting::firstOrCreate(
            ['user_id' => $user->id],
            [
                'study_days' => json_encode(['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']),
                'study_start_time' => '08:00',
                'study_end_time' => '22:00',
                'session_duration' => 45,
                'short_break' => 10,
                'long_break' => 30,
                'pomodoros_before_long_break' => 4,
            ]
        );

        // Get subjects directly from subjects table
        $subjects = Subject::whereIn('id', $validated['subject_ids'])->get();

        // Generate study sessions using PlannerService algorithm
        $sessions = $this->plannerService->generateSessionsForSchedule($user, $schedule, $subjects, $settings);

        // Update schedule statistics
        $schedule->update([
            'total_sessions' => $sessions->count(),
        ]);

        // Re-fetch sessions from DB with subject relationship for proper formatting
        $sessionIds = $sessions->pluck('id')->toArray();
        $sessionsWithSubject = PlannerStudySession::with('subject')
            ->whereIn('id', $sessionIds)
            ->orderBy('scheduled_date')
            ->orderBy('scheduled_start_time')
            ->get();

        // Format sessions for response (same format as getTodaySessions)
        $formattedSessions = $sessionsWithSubject->map(function ($session) {
            $isBreak = $session->is_break ?? false;
            $subjectName = $isBreak ? 'استراحة' : ($session->subject->name_ar ?? 'مادة غير معروفة');
            return [
                'id' => (string) $session->id,
                'user_id' => (string) $session->user_id,
                'subject_id' => (string) $session->subject_id,
                'subject_name' => $subjectName,
                'chapter_id' => $session->chapter_id ? (string) $session->chapter_id : null,
                'chapter_name' => $session->chapter_name ?? null,
                'scheduled_date' => $session->scheduled_date->format('Y-m-d'),
                'scheduled_start_time' => $session->scheduled_start_time ? substr($session->scheduled_start_time, 0, 5) : '08:00',
                'scheduled_end_time' => $session->scheduled_end_time ? substr($session->scheduled_end_time, 0, 5) : '08:45',
                'duration_minutes' => $session->duration_minutes ?? 45,
                'suggested_content_id' => $session->suggested_content_id ? (string) $session->suggested_content_id : null,
                'suggested_content_type' => $session->suggested_content_type ?? null,
                'content_title' => $session->content_title ?? null,
                'subject_planner_content_id' => $session->subject_planner_content_id ? (string) $session->subject_planner_content_id : null,
                'has_content' => $session->has_content ?? false,
                'content_phase' => $session->content_phase ?? null,
                'topic_name' => $session->topic_name ?? null,
                'subject_category' => $session->subject_category ?? null,
                'session_type' => $session->session_type ?? 'study',
                'required_energy_level' => $session->required_energy_level ?? 'medium',
                'priority_score' => $session->priority_score ?? 50,
                'is_pinned' => $session->is_pinned ?? false,
                'is_break' => $isBreak,
                'is_prayer_time' => $session->is_prayer_time ?? false,
                'status' => $session->status ?? 'scheduled',
                'actual_start_time' => $session->actual_start_time?->toIso8601String(),
                'actual_end_time' => $session->actual_end_time?->toIso8601String(),
                'actual_duration_minutes' => $session->actual_duration_minutes,
                'user_notes' => $session->user_notes ?? null,
                'skip_reason' => $session->skip_reason ?? null,
                'completion_percentage' => $session->completion_percentage ?? 0,
                'created_at' => $session->created_at->toIso8601String(),
                'updated_at' => $session->updated_at->toIso8601String(),
            ];
        });

        // Generate HTML planner file
        $htmlResult = $this->generateHtmlPlanner($user, $schedule, $sessionsWithSubject);

        return response()->json([
            'success' => true,
            'message' => 'Schedule generated successfully',
            'data' => [
                'id' => (string) $schedule->id,
                'user_id' => (string) $schedule->user_id,
                'start_date' => $schedule->start_date->format('Y-m-d'),
                'end_date' => $schedule->end_date->format('Y-m-d'),
                'is_active' => $schedule->is_active,
                'total_sessions' => $schedule->total_sessions,
                'sessions' => $formattedSessions,
                'created_at' => $schedule->created_at->toIso8601String(),
            ],
            'html_planner' => $htmlResult,
        ], 201);
    }

    /**
     * Get today's sessions
     * GET /api/v1/planner/sessions/today
     */
    public function getTodaySessions(Request $request)
    {
        $user = $request->user();
        $today = Carbon::today();

        \Log::info('getTodaySessions called', [
            'user_id' => $user->id,
            'today' => $today->toDateString(),
        ]);

        $schedule = PlannerSchedule::where('user_id', $user->id)
            ->where('is_active', true)
            ->first();

        if (!$schedule) {
            \Log::info('No active schedule found for user');
            return response()->json([
                'success' => true,
                'data' => [],
            ]);
        }

        \Log::info('Found active schedule', [
            'schedule_id' => $schedule->id,
            'start_date' => $schedule->start_date,
            'end_date' => $schedule->end_date,
            'total_sessions' => $schedule->total_sessions,
        ]);

        // First check total sessions in schedule
        $totalInSchedule = PlannerStudySession::where('schedule_id', $schedule->id)->count();
        \Log::info('Total sessions in schedule', ['count' => $totalInSchedule]);

        // Check sessions for today
        $todaySessionsRaw = PlannerStudySession::where('schedule_id', $schedule->id)
            ->whereDate('scheduled_date', $today)
            ->get();
        \Log::info('Sessions for today (raw)', [
            'count' => $todaySessionsRaw->count(),
            'today_date' => $today->toDateString(),
            'sample_dates' => PlannerStudySession::where('schedule_id', $schedule->id)
                ->take(5)
                ->pluck('scheduled_date')
                ->map(fn($d) => $d->toDateString())
                ->toArray(),
        ]);

        $sessions = PlannerStudySession::with('subject')
            ->where('schedule_id', $schedule->id)
            ->whereDate('scheduled_date', $today)
            ->where('status', '!=', 'skipped') // Exclude skipped sessions from display
            ->orderBy('scheduled_start_time')
            ->get()
            ->map(function ($session) {
                $isBreak = $session->is_break ?? false;
                $subjectName = $isBreak ? 'استراحة' : ($session->subject->name_ar ?? 'مادة غير معروفة');
                return [
                    'id' => (string) $session->id,
                    'user_id' => (string) $session->user_id,
                    'subject_id' => (string) $session->subject_id,
                    'subject_name' => $subjectName,
                    'chapter_id' => $session->chapter_id ? (string) $session->chapter_id : null,
                    'chapter_name' => $session->chapter_name ?? null,
                    'scheduled_date' => $session->scheduled_date->format('Y-m-d'),
                    'scheduled_start_time' => $session->scheduled_start_time ? substr($session->scheduled_start_time, 0, 5) : '08:00',
                    'scheduled_end_time' => $session->scheduled_end_time ? substr($session->scheduled_end_time, 0, 5) : '08:45',
                    'duration_minutes' => $session->duration_minutes ?? 45,
                    'suggested_content_id' => $session->suggested_content_id ? (string) $session->suggested_content_id : null,
                    'suggested_content_type' => $session->suggested_content_type ?? null,
                    'content_title' => $session->content_title ?? null,
                    'subject_planner_content_id' => $session->subject_planner_content_id ? (string) $session->subject_planner_content_id : null,
                    'has_content' => $session->has_content ?? false,
                    'content_phase' => $session->content_phase ?? null,
                    'topic_name' => $session->topic_name ?? null,
                    'subject_category' => $session->subject_category ?? null,
                    'session_type' => $session->session_type ?? 'study',
                    'required_energy_level' => $session->required_energy_level ?? 'medium',
                    'priority_score' => $session->priority_score ?? 50,
                    'is_pinned' => $session->is_pinned ?? false,
                    'is_break' => $isBreak,
                    'is_prayer_time' => $session->is_prayer_time ?? false,
                    'status' => $session->status ?? 'scheduled',
                    'actual_start_time' => $session->actual_start_time?->toIso8601String(),
                    'actual_end_time' => $session->actual_end_time?->toIso8601String(),
                    'actual_duration_minutes' => $session->actual_duration_minutes,
                    'user_notes' => $session->user_notes ?? null,
                    'skip_reason' => $session->skip_reason ?? null,
                    'completion_percentage' => $session->completion_percentage ?? 0,
                    'created_at' => $session->created_at->toIso8601String(),
                    'updated_at' => $session->updated_at->toIso8601String(),
                ];
            });

        \Log::info('Returning sessions', ['count' => $sessions->count()]);

        return response()->json([
            'success' => true,
            'data' => $sessions,
        ]);
    }

    /**
     * 4. Get active schedule
     * GET /api/v1/planner/schedules/active
     */
    public function getActiveSchedule(Request $request)
    {
        $user = $request->user();

        $schedule = PlannerSchedule::with(['studySessions' => function ($query) {
            $query->with('subject')->orderBy('scheduled_date')->orderBy('scheduled_start_time');
        }])
            ->where('user_id', $user->id)
            ->where('is_active', true)
            ->first();

        if (!$schedule) {
            return response()->json([
                'success' => false,
                'error' => 'Schedule not found',
            ], 404);
        }

        // Format sessions for frontend
        $sessions = $schedule->studySessions->map(function ($session) {
            $isBreak = $session->is_break ?? false;
            $subjectName = $isBreak ? 'استراحة' : ($session->subject->name_ar ?? 'مادة غير معروفة');
            return [
                'id' => $session->id,
                'user_id' => $session->user_id,
                'subject_id' => $session->subject_id,
                'subject_name' => $subjectName,
                'chapter_id' => $session->chapter_id,
                'chapter_name' => $session->chapter_name,
                'scheduled_date' => $session->scheduled_date->format('Y-m-d'),
                'scheduled_start_time' => $session->scheduled_start_time,
                'scheduled_end_time' => $session->scheduled_end_time,
                'duration_minutes' => $session->duration_minutes,
                'suggested_content_id' => $session->suggested_content_id,
                'suggested_content_type' => $session->suggested_content_type,
                'content_title' => $session->content_title,
                'content_suggestion' => $session->content_suggestion,
                'topic_name' => $session->topic_name,
                'session_type' => $session->session_type,
                'required_energy_level' => $session->required_energy_level,
                'estimated_energy_level' => $session->estimated_energy_level,
                'priority_score' => $session->priority_score,
                'is_pinned' => $session->is_pinned,
                'is_break' => $session->is_break,
                'is_prayer_time' => $session->is_prayer_time,
                'use_pomodoro_technique' => $session->use_pomodoro_technique,
                'pomodoro_duration_minutes' => $session->pomodoro_duration_minutes,
                'status' => $session->status,
                'actual_start_time' => $session->actual_start_time?->toIso8601String(),
                'actual_end_time' => $session->actual_end_time?->toIso8601String(),
                'actual_duration_minutes' => $session->actual_duration_minutes,
                'current_pomodoro_count' => $session->current_pomodoro_count,
                'total_pomodoros_planned' => $session->total_pomodoros_planned,
                'pause_count' => $session->pause_count,
                'user_notes' => $session->user_notes,
                'skip_reason' => $session->skip_reason,
                'completion_percentage' => $session->completion_percentage,
                'mood' => $session->mood,
                'points_earned' => $session->points_earned,
                'created_at' => $session->created_at->toIso8601String(),
                'updated_at' => $session->updated_at->toIso8601String(),
            ];
        });

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $schedule->id,
                'user_id' => $schedule->user_id,
                'start_date' => $schedule->start_date->format('Y-m-d'),
                'end_date' => $schedule->end_date->format('Y-m-d'),
                'is_active' => $schedule->is_active,
                'total_sessions' => $schedule->total_sessions,
                'completed_sessions' => $schedule->completed_sessions,
                'completion_rate' => $schedule->completion_rate,
                'sessions' => $sessions,
            ],
        ]);
    }

    /**
     * 5. Start session
     * POST /api/v1/planner/sessions/{id}/start
     */
    public function startSession(Request $request, $id)
    {
        $session = PlannerStudySession::findOrFail($id);

        if ($session->user_id !== $request->user()->id) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $session->update([
            'status' => 'inProgress',
            'actual_start_time' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Session started',
            'data' => $session,
        ]);
    }

    /**
     * 6. Complete session
     * POST /api/v1/planner/sessions/{id}/complete
     *
     * Triggers STEP 3 adaptation from promt.md when completing TOPIC_TEST sessions:
     * - Score < 60%: +2 EXERCISES, RETEST after 3 days, extra SPACED_REVIEW
     * - Score 60-80%: +1 EXERCISES, SPACED_REVIEW after 3 days
     * - Score >= 80%: Normal spaced reviews (already scheduled)
     */
    public function completeSession(Request $request, $id)
    {
        $validated = $request->validate([
            'completion_percentage' => 'required|integer|min:0|max:100',
            'mood' => 'nullable|in:positive,neutral,negative',
            'user_notes' => 'nullable|string',
            'pause_count' => 'nullable|integer|min:0',
            'score' => 'nullable|integer|min:0|max:100', // For TOPIC_TEST adaptation
        ]);

        $session = PlannerStudySession::findOrFail($id);

        if ($session->user_id !== $request->user()->id) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $actualDuration = $session->actual_start_time
            ? now()->diffInMinutes($session->actual_start_time)
            : $session->duration_minutes;

        // Calculate points
        $points = $this->calculateSessionPoints(
            $validated['completion_percentage'],
            $validated['pause_count'] ?? 0,
            $actualDuration,
            $session->duration_minutes,
            $validated['mood'] ?? null
        );

        $session->update([
            'status' => 'completed',
            'actual_end_time' => now(),
            'actual_duration_minutes' => $actualDuration,
            'completion_percentage' => $validated['completion_percentage'],
            'mood' => $validated['mood'] ?? null,
            'user_notes' => $validated['user_notes'] ?? null,
            'pause_count' => $validated['pause_count'] ?? 0,
            'points_earned' => $points,
            'score' => $validated['score'] ?? null,
        ]);

        // Update schedule statistics
        $schedule = $session->schedule;
        $schedule->increment('completed_sessions');
        $schedule->update([
            'completion_rate' => ($schedule->completed_sessions / $schedule->total_sessions) * 100,
        ]);

        // STEP 3: Adaptation after TOPIC_TEST completion (from promt.md)
        $adaptationResult = null;
        if ($session->session_type === PlannerStudySession::TYPE_TOPIC_TEST && isset($validated['score'])) {
            $adaptationResult = $this->triggerTopicTestAdaptation($session, $validated['score']);
        }

        return response()->json([
            'success' => true,
            'message' => 'Session completed',
            'data' => [
                'session' => $session,
                'points_earned' => $points,
                'adaptation' => $adaptationResult,
            ],
        ]);
    }

    /**
     * Trigger STEP 3 adaptation after topic test (from promt.md)
     *
     * Score < 60%: Topic mastery insufficient
     *   - Add 2 EXERCISES for same topic
     *   - Add RETEST after 3 days
     *   - Add extra SPACED_REVIEW next day
     *
     * Score 60-80%: Topic needs reinforcement
     *   - Add 1 EXERCISES
     *   - Add SPACED_REVIEW after 3 days
     *
     * Score >= 80%: Topic mastered
     *   - Keep normal spaced reviews (already scheduled)
     */
    protected function triggerTopicTestAdaptation(PlannerStudySession $session, int $score): array
    {
        $algorithmService = app(SchedulingAlgorithmService::class);
        $algorithmService->adaptAfterTopicTest($session, $score);

        $adaptationType = 'none';
        $sessionsAdded = 0;

        if ($score < 60) {
            $adaptationType = 'insufficient_mastery';
            $sessionsAdded = 4; // 2 exercises + 1 retest + 1 extra review
        } elseif ($score < 80) {
            $adaptationType = 'needs_reinforcement';
            $sessionsAdded = 2; // 1 exercise + 1 review
        } else {
            $adaptationType = 'mastered';
            $sessionsAdded = 0;
        }

        return [
            'triggered' => $score < 80,
            'type' => $adaptationType,
            'score' => $score,
            'sessions_added' => $sessionsAdded,
            'message' => $this->getAdaptationMessage($adaptationType),
        ];
    }

    /**
     * Get user-friendly adaptation message in Arabic
     */
    protected function getAdaptationMessage(string $type): string
    {
        return match ($type) {
            'insufficient_mastery' => 'تم إضافة جلسات إضافية للتمارين وإعادة الاختبار لتحسين الفهم',
            'needs_reinforcement' => 'تم إضافة جلسة تمارين ومراجعة إضافية لتثبيت المعلومات',
            'mastered' => 'أحسنت! تم إتقان الموضوع بنجاح',
            default => '',
        };
    }

    /**
     * 6b. Pause session
     * POST /api/v1/planner/sessions/{id}/pause
     */
    public function pauseSession(Request $request, $id)
    {
        $session = PlannerStudySession::findOrFail($id);

        if ($session->user_id !== $request->user()->id) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        if ($session->status !== 'inProgress') {
            return response()->json(['error' => 'Session is not in progress'], 400);
        }

        $session->update([
            'status' => 'paused',
        ]);

        $session->increment('pause_count');

        return response()->json([
            'success' => true,
            'message' => 'Session paused',
            'data' => $session,
        ]);
    }

    /**
     * 6c. Resume session
     * POST /api/v1/planner/sessions/{id}/resume
     */
    public function resumeSession(Request $request, $id)
    {
        $session = PlannerStudySession::findOrFail($id);

        if ($session->user_id !== $request->user()->id) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        if ($session->status !== 'paused') {
            return response()->json(['error' => 'Session is not paused'], 400);
        }

        $session->update([
            'status' => 'inProgress',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Session resumed',
            'data' => $session,
        ]);
    }

    /**
     * 6d. Skip session
     * POST /api/v1/planner/sessions/{id}/skip
     */
    public function skipSession(Request $request, $id)
    {
        $validated = $request->validate([
            'reason' => 'nullable|string|max:500',
        ]);

        $session = PlannerStudySession::findOrFail($id);

        if ($session->user_id !== $request->user()->id) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $session->update([
            'status' => 'skipped',
            'skip_reason' => $validated['reason'] ?? null,
        ]);

        // Update schedule statistics
        $schedule = $session->schedule;
        if ($schedule) {
            $schedule->increment('skipped_sessions');
        }

        return response()->json([
            'success' => true,
            'message' => 'Session skipped',
            'data' => $session,
        ]);
    }

    /**
     * 7. Get planner settings
     * GET /api/v1/planner/settings
     */
    public function getSettings(Request $request)
    {
        $user = $request->user();

        $settings = PlannerSetting::firstOrCreate(
            ['user_id' => $user->id],
            [
                'study_days' => json_encode(['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']),
                'study_start_time' => '08:00',
                'study_end_time' => '22:00',
                'session_duration' => 45,
                'short_break' => 10,
                'long_break' => 30,
                'pomodoros_before_long_break' => 4,
                'morning_energy_level' => 7,
                'afternoon_energy_level' => 6,
                'evening_energy_level' => 5,
                'night_energy_level' => 4,
            ]
        );

        return response()->json([
            'success' => true,
            'data' => $settings,
        ]);
    }

    /**
     * 8. Update planner settings
     * PUT /api/v1/planner/settings
     */
    public function updateSettings(Request $request)
    {
        $validated = $request->validate([
            // Study time window
            'study_days' => 'nullable|array',
            'study_start_time' => 'nullable|date_format:H:i',
            'study_end_time' => 'nullable|date_format:H:i',
            // Sleep schedule
            'sleep_start_time' => 'nullable|date_format:H:i',
            'sleep_end_time' => 'nullable|date_format:H:i',
            // Exercise settings
            'exercise_enabled' => 'nullable|boolean',
            'exercise_days' => 'nullable|array',
            'exercise_time' => 'nullable|date_format:H:i',
            'exercise_duration_minutes' => 'nullable|integer|min:5|max:180',
            // Energy levels (1-10 scale)
            'morning_energy_level' => 'nullable|integer|min:0|max:10',
            'afternoon_energy_level' => 'nullable|integer|min:0|max:10',
            'evening_energy_level' => 'nullable|integer|min:0|max:10',
            'night_energy_level' => 'nullable|integer|min:0|max:10',
            // Pomodoro settings
            'use_pomodoro' => 'nullable|boolean',
            'pomodoro_duration' => 'nullable|integer|min:15|max:120',
            'short_break' => 'nullable|integer|min:5|max:30',
            'long_break' => 'nullable|integer|min:15|max:60',
            'pomodoros_before_long_break' => 'nullable|integer|min:2|max:8',
            // Prayer settings
            'enable_prayer_times' => 'nullable|boolean',
            'city_for_prayer' => 'nullable|string|max:100',
            'prayer_duration_minutes' => 'nullable|integer|min:5|max:60',
            // Auto features
            'auto_reschedule_missed' => 'nullable|boolean',
            'adapt_to_performance_enabled' => 'nullable|boolean',
            // Priority weights
            'coefficient_weight' => 'nullable|integer|min:0|max:100',
            'exam_proximity_weight' => 'nullable|integer|min:0|max:100',
            'difficulty_weight' => 'nullable|integer|min:0|max:100',
            'inactivity_weight' => 'nullable|integer|min:0|max:100',
            'performance_gap_weight' => 'nullable|integer|min:0|max:100',
            // Limits
            'max_study_hours_per_day' => 'nullable|integer|min:1|max:16',
            'min_break_between_sessions' => 'nullable|integer|min:5|max:60',
            'session_duration_minutes' => 'nullable|integer|min:15|max:180',
            // Coefficient durations
            'coefficient_durations' => 'nullable|array',
            'coefficient_durations.*' => 'nullable|integer|min:15|max:180',
        ]);

        $user = $request->user();

        $settings = PlannerSetting::updateOrCreate(
            ['user_id' => $user->id],
            $validated
        );

        return response()->json([
            'success' => true,
            'message' => 'Settings updated successfully',
            'data' => $settings,
        ]);
    }

    /**
     * 9. Get points history
     * GET /api/v1/planner/points/history
     */
    public function getPointsHistory(Request $request)
    {
        $user = $request->user();

        $history = DB::table('planner_points_history')
            ->where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->limit(100)
            ->get();

        $totalPoints = DB::table('planner_points_history')
            ->where('user_id', $user->id)
            ->sum('points');

        return response()->json([
            'success' => true,
            'data' => [
                'history' => $history,
                'total_points' => $totalPoints,
            ],
        ]);
    }

    /**
     * 10. Get achievements
     * GET /api/v1/planner/achievements
     */
    public function getAchievements(Request $request)
    {
        $user = $request->user();

        $achievements = DB::table('planner_achievements')
            ->where('user_id', $user->id)
            ->orderBy('unlocked_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $achievements,
        ]);
    }

    /**
     * 11. Create exam
     * POST /api/v1/planner/exams
     */
    public function createExam(Request $request)
    {
        $validated = $request->validate([
            'subject_id' => 'required|exists:subjects,id',
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'exam_date' => 'required|date',
            'exam_time' => 'nullable|date_format:H:i',
            'duration_minutes' => 'nullable|integer|min:15',
            'location' => 'nullable|string|max:255',
        ]);

        $exam = PlannerExam::create([
            'user_id' => $request->user()->id,
            ...$validated,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Exam created successfully',
            'data' => $exam,
        ], 201);
    }

    /**
     * 12. Get exams
     * GET /api/v1/planner/exams
     */
    public function getExams(Request $request)
    {
        $user = $request->user();

        $exams = PlannerExam::with('subject')
            ->where('user_id', $user->id)
            ->orderBy('exam_date')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $exams,
        ]);
    }

    /**
     * 13. Update exam
     * PUT /api/v1/planner/exams/{id}
     */
    public function updateExam(Request $request, $id)
    {
        $exam = PlannerExam::findOrFail($id);

        if ($exam->user_id !== $request->user()->id) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'title' => 'nullable|string|max:255',
            'description' => 'nullable|string',
            'exam_date' => 'nullable|date',
            'exam_time' => 'nullable|date_format:H:i',
            'duration_minutes' => 'nullable|integer|min:15',
            'location' => 'nullable|string|max:255',
        ]);

        $exam->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Exam updated successfully',
            'data' => $exam,
        ]);
    }

    /**
     * 14. Delete exam
     * DELETE /api/v1/planner/exams/{id}
     */
    public function deleteExam(Request $request, $id)
    {
        $exam = PlannerExam::findOrFail($id);

        if ($exam->user_id !== $request->user()->id) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $exam->delete();

        return response()->json([
            'success' => true,
            'message' => 'Exam deleted successfully',
        ]);
    }

    /**
     * 15. Record exam result
     * POST /api/v1/planner/exams/{id}/result
     */
    public function recordExamResult(Request $request, $id)
    {
        $validated = $request->validate([
            'score' => 'required|numeric|min:0',
            'max_score' => 'required|numeric|min:0',
            'notes' => 'nullable|string',
        ]);

        $exam = PlannerExam::findOrFail($id);

        if ($exam->user_id !== $request->user()->id) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $percentage = ($validated['score'] / $validated['max_score']) * 100;
        $grade = $this->calculateGrade($percentage);

        $exam->update([
            'score' => $validated['score'],
            'max_score' => $validated['max_score'],
            'percentage' => $percentage,
            'grade' => $grade,
            'notes' => $validated['notes'],
        ]);

        // Check if adaptation should be triggered (if score is below 60%)
        $adaptationTriggered = false;
        if ($percentage < 60) {
            $adaptationTriggered = true;
            $exam->update([
                'triggered_adaptation' => true,
                'adaptation_triggered_at' => now(),
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Exam result recorded',
            'data' => [
                'exam' => $exam,
                'adaptation_triggered' => $adaptationTriggered,
            ],
        ]);
    }

    /**
     * 16. Adapt schedule
     * POST /api/v1/planner/schedules/{id}/adapt
     */
    public function adaptSchedule(Request $request, $id)
    {
        $validated = $request->validate([
            'reason' => 'required|string',
            'changes' => 'required|array',
        ]);

        $schedule = PlannerSchedule::findOrFail($id);

        if ($schedule->user_id !== $request->user()->id) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $adaptationReasons = $schedule->adaptation_reasons ?? [];
        $adaptationReasons[] = [
            'date' => now()->toIso8601String(),
            'reason' => $validated['reason'],
            'changes' => $validated['changes'],
        ];

        $schedule->update([
            'adaptation_count' => $schedule->adaptation_count + 1,
            'last_adapted_at' => now(),
            'adaptation_reasons' => $adaptationReasons,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Schedule adapted successfully',
            'data' => $schedule,
        ]);
    }

    /**
     * 17. Reschedule session
     * PUT /api/v1/planner/sessions/{id}/reschedule
     */
    public function rescheduleSession(Request $request, $id)
    {
        $validated = $request->validate([
            'scheduled_date' => 'required|date',
            'scheduled_start_time' => 'required|date_format:H:i',
            'scheduled_end_time' => 'required|date_format:H:i',
        ]);

        $session = PlannerStudySession::findOrFail($id);

        if ($session->user_id !== $request->user()->id) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $session->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Session rescheduled successfully',
            'data' => $session,
        ]);
    }

    // Helper methods

    /**
     * Generate basic study sessions without curriculum content
     * Used as fallback when no content is available for subjects
     */
    private function generateBasicSessionsWithoutContent($schedule, $subjects, $settings, $startDate, $endDate, $studyDays)
    {
        $sessions = collect();
        $studyStartTime = $settings->study_start_time ?? '08:00';

        // Base duration by coefficient
        $baseDurations = [
            7 => 90, 6 => 80, 5 => 75, 4 => 60, 3 => 50, 2 => 40, 1 => 30
        ];

        $date = $startDate->copy();
        $subjectIndex = 0;
        $subjectsArray = $subjects->values()->all();
        $subjectCount = count($subjectsArray);

        if ($subjectCount === 0) {
            return $sessions;
        }

        while ($date->lte($endDate)) {
            $dayName = strtolower($date->englishDayOfWeek);

            if (in_array($dayName, $studyDays)) {
                $daySlotIndex = 0;
                $maxSlotsPerDay = min(6, $subjectCount * 2); // Max 2 sessions per subject per day
                $daySessionCounts = [];

                while ($daySlotIndex < $maxSlotsPerDay) {
                    // Round-robin through subjects
                    $subject = $subjectsArray[$subjectIndex % $subjectCount];
                    $subjectId = $subject->id;

                    // Max 2 sessions per subject per day
                    $subjectDayCount = $daySessionCounts[$subjectId] ?? 0;
                    if ($subjectDayCount >= 2) {
                        $subjectIndex++;
                        // Check if we've tried all subjects
                        if ($subjectIndex >= $subjectCount * 2) {
                            break;
                        }
                        continue;
                    }

                    $coefficient = $subject->coefficient ?? 4;
                    $duration = $baseDurations[$coefficient] ?? 60;

                    // Calculate time slot
                    $startTime = Carbon::parse($studyStartTime)->addMinutes($daySlotIndex * 90);
                    $endTime = $startTime->copy()->addMinutes($duration);

                    // Create session without content
                    $session = PlannerStudySession::create([
                        'user_id' => $schedule->user_id,
                        'schedule_id' => $schedule->id,
                        'subject_id' => $subjectId,
                        'subject_planner_content_id' => null,
                        'has_content' => false,
                        'content_phase' => 'understanding',
                        'content_title' => 'سيتم اضافة المحتوى قريبا',
                        'topic_name' => $subject->name_ar ?? $subject->name ?? 'مادة دراسية',
                        'scheduled_date' => $date->toDateString(),
                        'scheduled_start_time' => $startTime->format('H:i'),
                        'scheduled_end_time' => $endTime->format('H:i'),
                        'duration_minutes' => $duration,
                        'session_type' => 'lesson_review',
                        'subject_category' => 'OTHER',
                        'required_energy_level' => 'medium',
                        'priority_score' => $coefficient * 10,
                        'status' => 'scheduled',
                        'use_pomodoro_technique' => true,
                        'pomodoro_duration_minutes' => 25,
                    ]);

                    $sessions->push($session);
                    $daySessionCounts[$subjectId] = $subjectDayCount + 1;
                    $daySlotIndex++;
                    $subjectIndex++;
                }
            }

            $date->addDay();
        }

        return $sessions;
    }

    /**
     * Calculate session points
     */
    private function calculateSessionPoints($completionPercentage, $pauseCount, $actualDuration, $scheduledDuration, $mood)
    {
        $points = 10; // Base points

        // Completion bonus (0-5 points)
        $points += round(($completionPercentage / 100) * 5);

        // No pause bonus (0-5 points)
        if ($pauseCount == 0) {
            $points += 5;
        } else {
            $points += max(0, 5 - $pauseCount);
        }

        // On time bonus (3 points)
        if ($actualDuration <= $scheduledDuration) {
            $points += 3;
        }

        // Mood bonus (2 points)
        if ($mood === 'positive') {
            $points += 2;
        }

        return min($points, 25); // Max 25 points
    }

    /**
     * Calculate grade from percentage
     */
    private function calculateGrade($percentage)
    {
        if ($percentage >= 90) return 'A';
        if ($percentage >= 80) return 'B';
        if ($percentage >= 70) return 'C';
        if ($percentage >= 60) return 'D';
        if ($percentage >= 50) return 'E';
        return 'F';
    }

    /**
     * Generate HTML planner file for a schedule
     *
     * @param \App\Models\User $user
     * @param PlannerSchedule $schedule
     * @param \Illuminate\Support\Collection $sessions
     * @return array
     */
    private function generateHtmlPlanner($user, PlannerSchedule $schedule, $sessions): array
    {
        try {
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

            // Calculate per-subject statistics
            $subjectStats = [];
            $contentAllocationService = app(\App\Services\ContentAllocationService::class);

            foreach ($sessions->where('is_break', false) as $session) {
                if ($session->subject) {
                    $subjectId = $session->subject_id;
                    $subjectName = $session->subject->name_fr
                        ?? $session->subject->name_en
                        ?? $session->subject->name
                        ?? $session->subject->name_ar
                        ?? 'Matiere';

                    if (!isset($subjectStats[$subjectId])) {
                        // Get coefficient and category
                        $coefficient = $contentAllocationService->getSubjectCoefficientForUser($session->subject, $user);
                        $category = $contentAllocationService->getSubjectCategory($session->subject);
                        $isHardCore = $category === 'HARD_CORE';

                        $subjectStats[$subjectId] = [
                            'name' => $subjectName,
                            'sessions' => 0,
                            'minutes' => 0,
                            'color' => $session->subject->color ?? '#6366f1',
                            'coefficient' => $coefficient,
                            'category' => $category,
                            'is_hard_core' => $isHardCore,
                        ];
                    }
                    $subjectStats[$subjectId]['sessions']++;
                    $subjectStats[$subjectId]['minutes'] += $session->duration_minutes ?? 0;
                }
            }

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
                'lesson_review' => 'Revision de cours',
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
        .subject-stats { margin-bottom: 30px; }
        .subject-stats h2 { color: #374151; font-size: 18px; margin-bottom: 15px; text-align: center; }
        .subject-stats-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .subject-stats-table th { background: #6366f1; color: white; padding: 12px 15px; text-align: center; font-weight: bold; font-size: 13px; }
        .subject-stats-table td { padding: 12px 15px; border: 1px solid #e5e7eb; font-size: 13px; text-align: center; }
        .subject-stats-table tr:nth-child(even) { background: #f8fafc; }
        .subject-stats-table tr:hover { background: #f3f4f6; }
        .subject-color { display: inline-block; width: 12px; height: 12px; border-radius: 3px; margin-right: 8px; vertical-align: middle; }
        .subject-name-cell { text-align: left !important; font-weight: 500; }
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

            // Add subject statistics section
            if (!empty($subjectStats)) {
                $html .= '
        <div class="subject-stats">
            <h2>Statistiques par Matiere</h2>
            <table class="subject-stats-table">
                <thead>
                    <tr>
                        <th>Matiere</th>
                        <th>Coef</th>
                        <th>Categorie</th>
                        <th>Nombre de Seances</th>
                        <th>Heures d\'etude</th>
                    </tr>
                </thead>
                <tbody>';

                // Sort: HARD_CORE first, then by coefficient descending, then by hours
                uasort($subjectStats, function ($a, $b) {
                    // HARD_CORE always first
                    if ($a['is_hard_core'] !== $b['is_hard_core']) {
                        return $b['is_hard_core'] - $a['is_hard_core'];
                    }
                    // Then by coefficient descending
                    if ($a['coefficient'] !== $b['coefficient']) {
                        return $b['coefficient'] - $a['coefficient'];
                    }
                    // Then by hours descending
                    return $b['minutes'] - $a['minutes'];
                });

                // Category translations
                $categoryLabels = [
                    'HARD_CORE' => '⭐ HARD_CORE',
                    'LANGUAGE' => 'Langue',
                    'MEMORIZATION' => 'Memorisation',
                    'OTHER' => 'Autre',
                ];

                foreach ($subjectStats as $stat) {
                    $hours = round($stat['minutes'] / 60, 1);
                    $categoryLabel = $categoryLabels[$stat['category']] ?? $stat['category'];
                    $rowStyle = $stat['is_hard_core'] ? 'background: #fef3c7; font-weight: bold;' : '';

                    $html .= '
                    <tr style="' . $rowStyle . '">
                        <td class="subject-name-cell">
                            <span class="subject-color" style="background: ' . htmlspecialchars($stat['color']) . ';"></span>
                            ' . htmlspecialchars($stat['name']) . '
                        </td>
                        <td style="font-weight: bold; color: #6366f1;">' . $stat['coefficient'] . '</td>
                        <td>' . htmlspecialchars($categoryLabel) . '</td>
                        <td>' . $stat['sessions'] . ' seances</td>
                        <td>' . $hours . ' h</td>
                    </tr>';
                }

                $html .= '
                </tbody>
            </table>
        </div>';
            }

            // Add day sections
            foreach ($sessionsByDate as $date => $daySessions) {
                $dateCarbon = Carbon::parse($date);
                $dayName = $frenchDays[$dateCarbon->format('l')] ?? $dateCarbon->format('l');

                // Sort sessions by start time within each day
                $sortedDaySessions = $daySessions->sortBy(function ($session) {
                    return $session->scheduled_start_time ?? '00:00';
                });

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

                foreach ($sortedDaySessions as $session) {
                    $isBreak = $session->is_break ?? false;
                    $contentTitle = $session->content_title ?? '';
                    $isPrayer = $session->is_prayer_time ?? (mb_strpos($contentTitle, 'صلا') !== false);
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
                    $startTime = substr($session->scheduled_start_time ?? '00:00', 0, 5);

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
                        <td class="duration-cell">' . ($session->duration_minutes ?? 45) . ' min</td>
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
