<?php

namespace App\Http\Controllers;

use App\Models\UserSubject;
use App\Models\Subject;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class UserSubjectController extends Controller
{
    /**
     * Get user's subjects with settings and optional stats.
     *
     * GET /api/v1/user/subjects
     */
    public function index(Request $request)
    {
        $includeStats = $request->boolean('include_stats', false);

        $userSubjects = UserSubject::where('user_id', auth()->id())
            ->with('subject')
            ->byPriority()
            ->get();

        $data = $userSubjects->map(function ($userSubject) use ($includeStats) {
            $subject = $userSubject->subject;

            $item = [
                'id' => $userSubject->id,
                'subject_id' => $subject->id,
                'name_ar' => $subject->name_ar,
                'coefficient' => $userSubject->coefficient,
                'difficulty_level' => $userSubject->difficulty_level,
                'weekly_goal_minutes' => $userSubject->weekly_goal_minutes,
                'session_duration' => $userSubject->session_duration,
                'is_favorite' => $userSubject->is_favorite,
                'priority_score' => $userSubject->priority_score,
                'color' => $subject->color,
                'icon' => $subject->icon,
            ];

            if ($includeStats) {
                $item['stats'] = $this->getSubjectStats($userSubject);
            }

            return $item;
        });

        return response()->json([
            'success' => true,
            'data' => [
                'subjects' => $data,
            ],
        ]);
    }

    /**
     * Get specific user subject.
     *
     * GET /api/v1/user/subjects/{subject_id}
     */
    public function show($subjectId)
    {
        $userSubject = UserSubject::where('user_id', auth()->id())
            ->where('subject_id', $subjectId)
            ->with('subject')
            ->firstOrFail();

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $userSubject->id,
                'subject_id' => $userSubject->subject->id,
                'name_ar' => $userSubject->subject->name_ar,
                'coefficient' => $userSubject->coefficient,
                'difficulty_level' => $userSubject->difficulty_level,
                'weekly_goal_minutes' => $userSubject->weekly_goal_minutes,
                'session_duration' => $userSubject->session_duration,
                'is_favorite' => $userSubject->is_favorite,
                'priority_score' => $userSubject->priority_score,
                'stats' => $this->getSubjectStats($userSubject),
            ],
        ]);
    }

    /**
     * Update user subject settings.
     *
     * PUT /api/v1/user/subjects/{subject_id}
     */
    public function update(Request $request, $subjectId)
    {
        $validator = Validator::make($request->all(), [
            'difficulty_level' => 'nullable|in:easy,medium,hard',
            'weekly_goal_minutes' => 'nullable|integer|min:0|max:3000',
            'session_duration' => 'nullable|integer|min:15|max:120',
            'is_favorite' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $userSubject = UserSubject::where('user_id', auth()->id())
            ->where('subject_id', $subjectId)
            ->firstOrFail();

        // Update settings
        $userSubject->update($validator->validated());

        // Recalculate priority score
        $userSubject->updatePriorityScore();

        // If goal or duration changed, trigger planner recalculation
        if ($request->has('weekly_goal_minutes') || $request->has('session_duration')) {
            // TODO: Trigger planner recalculation job
            // dispatch(new RecalculatePlannerJob(auth()->user()));
        }

        return response()->json([
            'success' => true,
            'message' => 'Subject settings updated successfully',
            'data' => $userSubject->fresh(['subject']),
        ]);
    }

    /**
     * Recalculate all subject priorities.
     *
     * POST /api/v1/user/subjects/recalculate-priorities
     */
    public function recalculatePriorities()
    {
        $userSubjects = UserSubject::where('user_id', auth()->id())->get();

        foreach ($userSubjects as $userSubject) {
            $userSubject->updatePriorityScore();
        }

        return response()->json([
            'success' => true,
            'message' => 'All subject priorities recalculated',
            'data' => [
                'subjects_updated' => $userSubjects->count(),
            ],
        ]);
    }

    /**
     * Toggle favorite status for a subject.
     *
     * POST /api/v1/user/subjects/{subject_id}/toggle-favorite
     */
    public function toggleFavorite($subjectId)
    {
        $userSubject = UserSubject::where('user_id', auth()->id())
            ->where('subject_id', $subjectId)
            ->firstOrFail();

        $userSubject->update(['is_favorite' => !$userSubject->is_favorite]);
        $userSubject->updatePriorityScore();

        return response()->json([
            'success' => true,
            'message' => $userSubject->is_favorite ? 'Added to favorites' : 'Removed from favorites',
            'data' => [
                'is_favorite' => $userSubject->is_favorite,
                'priority_score' => $userSubject->priority_score,
            ],
        ]);
    }

    /**
     * Get subject statistics.
     */
    private function getSubjectStats(UserSubject $userSubject): array
    {
        $userId = $userSubject->user_id;
        $subjectId = $userSubject->subject_id;

        // Get total study minutes for this subject
        $totalMinutes = DB::table('study_sessions')
            ->where('user_id', $userId)
            ->where('subject_id', $subjectId)
            ->sum('duration_minutes');

        // Get last session
        $lastSession = DB::table('study_sessions')
            ->where('user_id', $userId)
            ->where('subject_id', $subjectId)
            ->orderBy('started_at', 'desc')
            ->first();

        // Get average quiz score for this subject (if available)
        // This is a placeholder - actual implementation depends on quiz system
        $averageScore = 0.0;

        return [
            'total_study_minutes' => $totalMinutes ?? 0,
            'total_study_hours' => round(($totalMinutes ?? 0) / 60, 1),
            'last_session' => $lastSession?->started_at,
            'average_score' => $averageScore,
        ];
    }
}
