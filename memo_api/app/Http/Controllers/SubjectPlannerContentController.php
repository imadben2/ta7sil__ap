<?php

namespace App\Http\Controllers;

use App\Models\SubjectPlannerContent;
use App\Models\UserSubjectPlannerProgress;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class SubjectPlannerContentController extends Controller
{
    /**
     * Get full curriculum tree for user's stream
     * GET /api/curriculum
     */
    public function index(Request $request): JsonResponse
    {
        $user = Auth::user();

        if (!$user->academicYear || !$user->academicStream) {
            return response()->json([
                'success' => false,
                'message' => 'User academic context not set'
            ], 400);
        }

        $query = SubjectPlannerContent::with(['children', 'subject'])
            ->forAcademicContext(
                $user->academicPhase->id,
                $user->academicYear->id,
                $user->academicStream->id
            )
            ->published()
            ->rootLevel()
            ->orderBy('order');

        // Filter by subject if provided
        if ($request->has('subject_id')) {
            $query->where('subject_id', $request->subject_id);
        }

        $curriculum = $query->get();

        // Add user progress if requested
        if ($request->boolean('with_progress')) {
            $curriculum->load(['userProgress' => function ($query) use ($user) {
                $query->where('user_id', $user->id);
            }]);
        }

        return response()->json([
            'success' => true,
            'data' => $curriculum
        ]);
    }

    /**
     * Get curriculum for specific subject
     * GET /api/curriculum/{subjectId}
     */
    public function getBySubject(int $subjectId): JsonResponse
    {
        $user = Auth::user();

        if (!$user->academicYear || !$user->academicStream) {
            return response()->json([
                'success' => false,
                'message' => 'User academic context not set'
            ], 400);
        }

        $curriculum = SubjectPlannerContent::with(['descendants', 'subject'])
            ->forAcademicContext(
                $user->academicPhase->id,
                $user->academicYear->id,
                $user->academicStream->id
            )
            ->forSubject($subjectId)
            ->published()
            ->rootLevel()
            ->orderBy('order')
            ->get();

        // Add user progress
        $curriculum->load(['userProgress' => function ($query) use ($user) {
            $query->where('user_id', $user->id);
        }]);

        return response()->json([
            'success' => true,
            'data' => $curriculum
        ]);
    }

    /**
     * Get specific curriculum content item with details
     * GET /api/curriculum/content/{id}
     */
    public function show(int $id): JsonResponse
    {
        $user = Auth::user();

        $content = SubjectPlannerContent::with([
            'academicPhase',
            'academicYear',
            'academicStream',
            'subject',
            'parent',
            'children',
            'relatedChapter',
            'userProgress' => function ($query) use ($user) {
                $query->where('user_id', $user->id);
            }
        ])->find($id);

        if (!$content) {
            return response()->json([
                'success' => false,
                'message' => 'Content not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $content
        ]);
    }

    /**
     * Get user progress for specific content item
     * GET /api/curriculum/content/{id}/progress
     */
    public function getProgress(int $id): JsonResponse
    {
        $user = Auth::user();

        $content = SubjectPlannerContent::find($id);

        if (!$content) {
            return response()->json([
                'success' => false,
                'message' => 'Content not found'
            ], 404);
        }

        $progress = UserSubjectPlannerProgress::where('user_id', $user->id)
            ->where('subject_planner_content_id', $id)
            ->first();

        if (!$progress) {
            // Return default progress structure
            return response()->json([
                'success' => true,
                'data' => [
                    'status' => 'not_started',
                    'completion_percentage' => 0,
                    'mastery_score' => 0,
                    'time_spent_minutes' => 0,
                    'study_count' => 0,
                    'phases' => [
                        'understanding' => false,
                        'review' => false,
                        'theory_practice' => false,
                        'exercise_practice' => false,
                    ]
                ]
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => $progress->getSummary()
        ]);
    }

    /**
     * Update user progress for content item
     * POST /api/curriculum/content/{id}/progress
     */
    public function updateProgress(Request $request, int $id): JsonResponse
    {
        $user = Auth::user();

        $content = SubjectPlannerContent::find($id);

        if (!$content) {
            return response()->json([
                'success' => false,
                'message' => 'Content not found'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'phase' => 'nullable|in:understanding,review,theory_practice,exercise_practice',
            'duration_minutes' => 'nullable|integer|min:0',
            'score' => 'nullable|integer|min:0|max:100',
            'status' => 'nullable|in:not_started,in_progress,completed,mastered',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $progress = UserSubjectPlannerProgress::firstOrCreate(
            [
                'user_id' => $user->id,
                'subject_planner_content_id' => $id,
            ],
            [
                'status' => 'not_started',
                'completion_percentage' => 0,
            ]
        );

        // Update phase completion if provided
        if ($request->has('phase')) {
            $progress->markPhaseCompleted($request->phase);
        }

        // Record study session if duration provided
        if ($request->has('duration_minutes')) {
            $progress->recordStudySession(
                $request->duration_minutes,
                $request->score
            );
        }

        // Update status if provided
        if ($request->has('status')) {
            $progress->status = $request->status;
        }

        // Update completion percentage
        $progress->updateCompletionPercentage();
        $progress->save();

        return response()->json([
            'success' => true,
            'message' => 'Progress updated successfully',
            'data' => $progress->getSummary()
        ]);
    }

    /**
     * Get BAC priority content for user's stream
     * GET /api/curriculum/bac-priority
     */
    public function getBacPriority(): JsonResponse
    {
        $user = Auth::user();

        if (!$user->academicYear || !$user->academicStream) {
            return response()->json([
                'success' => false,
                'message' => 'User academic context not set'
            ], 400);
        }

        $bacContent = SubjectPlannerContent::with(['subject', 'parent'])
            ->forAcademicContext(
                $user->academicPhase->id,
                $user->academicYear->id,
                $user->academicStream->id
            )
            ->published()
            ->bacPriority()
            ->get();

        // Add user progress
        $bacContent->load(['userProgress' => function ($query) use ($user) {
            $query->where('user_id', $user->id);
        }]);

        return response()->json([
            'success' => true,
            'data' => $bacContent
        ]);
    }

    /**
     * Get content items due for review (spaced repetition)
     * GET /api/curriculum/due-for-review
     */
    public function getDueForReview(): JsonResponse
    {
        $user = Auth::user();

        $dueItems = UserSubjectPlannerProgress::with(['subjectPlannerContent.subject'])
            ->forUser($user->id)
            ->dueForReview()
            ->get();

        return response()->json([
            'success' => true,
            'data' => $dueItems->map(function ($progress) {
                return [
                    'content' => $progress->subjectPlannerContent,
                    'progress' => $progress->getSummary(),
                ];
            })
        ]);
    }

    /**
     * Get user statistics for curriculum progress
     * GET /api/curriculum/statistics
     */
    public function getStatistics(): JsonResponse
    {
        $user = Auth::user();

        if (!$user->academicYear || !$user->academicStream) {
            return response()->json([
                'success' => false,
                'message' => 'User academic context not set'
            ], 400);
        }

        // Total curriculum items
        $totalItems = SubjectPlannerContent::forAcademicContext(
            $user->academicPhase->id,
            $user->academicYear->id,
            $user->academicStream->id
        )->published()->count();

        // User progress statistics
        $progress = UserSubjectPlannerProgress::where('user_id', $user->id)->get();

        $completedCount = $progress->where('status', 'completed')->count() +
                         $progress->where('status', 'mastered')->count();
        $inProgressCount = $progress->where('status', 'in_progress')->count();
        $notStartedCount = $totalItems - ($completedCount + $inProgressCount);

        $totalTimeSpent = $progress->sum('time_spent_minutes');
        $averageMastery = $progress->avg('mastery_score');

        // By subject
        $progressBySubject = SubjectPlannerContent::with('subject')
            ->forAcademicContext(
                $user->academicPhase->id,
                $user->academicYear->id,
                $user->academicStream->id
            )
            ->published()
            ->get()
            ->groupBy('subject_id')
            ->map(function ($items, $subjectId) use ($user) {
                $totalSubjectItems = $items->count();
                $progressedItems = UserSubjectPlannerProgress::where('user_id', $user->id)
                    ->whereIn('subject_planner_content_id', $items->pluck('id'))
                    ->whereIn('status', ['completed', 'mastered'])
                    ->count();

                return [
                    'subject' => $items->first()->subject,
                    'total_items' => $totalSubjectItems,
                    'completed_items' => $progressedItems,
                    'completion_percentage' => $totalSubjectItems > 0
                        ? round(($progressedItems / $totalSubjectItems) * 100, 2)
                        : 0,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => [
                'total_items' => $totalItems,
                'completed' => $completedCount,
                'in_progress' => $inProgressCount,
                'not_started' => $notStartedCount,
                'completion_percentage' => $totalItems > 0
                    ? round(($completedCount / $totalItems) * 100, 2)
                    : 0,
                'total_time_spent_minutes' => $totalTimeSpent,
                'average_mastery_score' => round($averageMastery, 2),
                'by_subject' => $progressBySubject->values(),
            ]
        ]);
    }

    /**
     * Get next content items to study for a subject session
     * GET /api/curriculum/subject/{subjectId}/next-session-content
     *
     * Returns content items based on:
     * - User's progress (prioritizes not-completed items)
     * - Hierarchical order
     * - Session type (study, revision, practice, exam)
     */
    public function getNextSessionContent(int $subjectId, Request $request): JsonResponse
    {
        $user = Auth::user();

        if (!$user->academicYear || !$user->academicStream) {
            return response()->json([
                'success' => false,
                'message' => 'User academic context not set'
            ], 400);
        }

        $validator = Validator::make($request->all(), [
            'session_type' => 'nullable|in:study,revision,practice,exam',
            'duration_minutes' => 'nullable|integer|min:1',
            'limit' => 'nullable|integer|min:1|max:10',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $sessionType = $request->input('session_type', 'study');
        $limit = $request->input('limit', 5);

        // Get content items for this subject at topic/learning_objective level
        $contentItems = SubjectPlannerContent::with(['parent.parent']) // Get parent chain for context
            ->forAcademicContext(
                $user->academicPhase->id,
                $user->academicYear->id,
                $user->academicStream->id
            )
            ->forSubject($subjectId)
            ->published()
            ->whereIn('level', ['topic', 'subtopic', 'learning_objective'])
            ->orderBy('order')
            ->get();

        // Get user progress for these items
        $progressMap = UserSubjectPlannerProgress::where('user_id', $user->id)
            ->whereIn('subject_planner_content_id', $contentItems->pluck('id'))
            ->get()
            ->keyBy('subject_planner_content_id');

        // Determine which phase to check based on session type
        $phaseField = match ($sessionType) {
            'study' => 'understanding_completed',
            'revision' => 'review_completed',
            'practice' => 'theory_practice_completed',
            'exam' => 'exercise_practice_completed',
            default => 'understanding_completed',
        };

        // Sort content: incomplete items first, then by order
        $sortedContent = $contentItems->sortBy(function ($item) use ($progressMap, $phaseField) {
            $progress = $progressMap->get($item->id);
            $isCompleted = $progress && $progress->$phaseField;
            // Incomplete items first (0), completed items second (1)
            return [$isCompleted ? 1 : 0, $item->order];
        })->take($limit);

        // Format response with simplified structure
        $result = $sortedContent->map(function ($item) use ($progressMap, $sessionType) {
            $progress = $progressMap->get($item->id);

            // Build parent title chain for context
            $parentTitle = null;
            if ($item->parent) {
                $parentTitle = $item->parent->title_ar;
                if ($item->parent->parent) {
                    $parentTitle = $item->parent->parent->title_ar . ' > ' . $parentTitle;
                }
            }

            return [
                'id' => $item->id,
                'title_ar' => $item->title_ar,
                'level' => $item->level,
                'parent_title' => $parentTitle,
                'requires_understanding' => $item->requires_understanding,
                'requires_review' => $item->requires_review,
                'requires_theory_practice' => $item->requires_theory_practice,
                'requires_exercise_practice' => $item->requires_exercise_practice,
                'progress' => $progress ? [
                    'status' => $progress->status,
                    'understanding_completed' => $progress->understanding_completed,
                    'review_completed' => $progress->review_completed,
                    'theory_practice_completed' => $progress->theory_practice_completed,
                    'exercise_practice_completed' => $progress->exercise_practice_completed,
                    'completion_percentage' => $progress->completion_percentage,
                ] : null,
            ];
        })->values();

        // If no content available for this subject/stream, return placeholder message
        if ($result->isEmpty()) {
            return response()->json([
                'success' => true,
                'data' => [],
                'meta' => [
                    'session_type' => $sessionType,
                    'phase_to_complete' => match ($sessionType) {
                        'study' => 'understanding',
                        'revision' => 'review',
                        'practice' => 'theory_practice',
                        'exam' => 'exercise_practice',
                        default => 'understanding',
                    },
                    'total_available' => 0,
                    'has_content' => false,
                    'placeholder_message' => 'سيتم اضافة المحتوى قريبا',
                ]
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => $result,
            'meta' => [
                'session_type' => $sessionType,
                'phase_to_complete' => match ($sessionType) {
                    'study' => 'understanding',
                    'revision' => 'review',
                    'practice' => 'theory_practice',
                    'exam' => 'exercise_practice',
                    default => 'understanding',
                },
                'total_available' => $contentItems->count(),
                'has_content' => true,
            ]
        ]);
    }

    /**
     * Search curriculum content
     * GET /api/curriculum/search
     */
    public function search(Request $request): JsonResponse
    {
        $user = Auth::user();

        if (!$user->academicYear || !$user->academicStream) {
            return response()->json([
                'success' => false,
                'message' => 'User academic context not set'
            ], 400);
        }

        $validator = Validator::make($request->all(), [
            'query' => 'required|string|min:2',
            'subject_id' => 'nullable|integer|exists:subjects,id',
            'level' => 'nullable|in:learning_axis,unit,topic,subtopic,learning_objective',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $query = SubjectPlannerContent::with(['subject', 'parent'])
            ->forAcademicContext(
                $user->academicPhase->id,
                $user->academicYear->id,
                $user->academicStream->id
            )
            ->published()
            ->where('title_ar', 'like', '%' . $request->query . '%');

        if ($request->has('subject_id')) {
            $query->where('subject_id', $request->subject_id);
        }

        if ($request->has('level')) {
            $query->where('level', $request->level);
        }

        $results = $query->orderBy('order')->get();

        // Add user progress
        $results->load(['userProgress' => function ($q) use ($user) {
            $q->where('user_id', $user->id);
        }]);

        return response()->json([
            'success' => true,
            'data' => $results
        ]);
    }

    /**
     * Get content for a specific unit/topic (for session detail screen)
     * GET /api/curriculum/content/{id}/session-content
     *
     * Returns the specific content item and its children for display in the session screen
     */
    public function getContentSessionContent(int $id, Request $request): JsonResponse
    {
        $user = Auth::user();

        if (!$user->academicYear || !$user->academicStream) {
            return response()->json([
                'success' => false,
                'message' => 'User academic context not set'
            ], 400);
        }

        $sessionType = $request->input('session_type', 'study');

        // Get the specific content item
        $content = SubjectPlannerContent::with(['parent.parent', 'children'])
            ->forAcademicContext(
                $user->academicPhase->id,
                $user->academicYear->id,
                $user->academicStream->id
            )
            ->published()
            ->find($id);

        if (!$content) {
            return response()->json([
                'success' => true,
                'data' => [],
                'meta' => [
                    'session_type' => $sessionType,
                    'phase_to_complete' => match ($sessionType) {
                        'study' => 'understanding',
                        'revision' => 'review',
                        'practice' => 'theory_practice',
                        'exam' => 'exercise_practice',
                        default => 'understanding',
                    },
                    'total_available' => 0,
                    'has_content' => false,
                    'placeholder_message' => 'سيتم اضافة المحتوى قريبا',
                ]
            ]);
        }

        // Get user progress for this item and its children
        $contentIds = collect([$content->id]);
        if ($content->children) {
            $contentIds = $contentIds->merge($content->children->pluck('id'));
        }

        $progressMap = UserSubjectPlannerProgress::where('user_id', $user->id)
            ->whereIn('subject_planner_content_id', $contentIds)
            ->get()
            ->keyBy('subject_planner_content_id');

        // Build parent title chain for context
        $parentTitle = null;
        if ($content->parent) {
            $parentTitle = $content->parent->title_ar;
            if ($content->parent->parent) {
                $parentTitle = $content->parent->parent->title_ar . ' > ' . $parentTitle;
            }
        }

        // Format the main content item
        $progress = $progressMap->get($content->id);
        $mainItem = [
            'id' => $content->id,
            'title_ar' => $content->title_ar,
            'level' => $content->level,
            'parent_title' => $parentTitle,
            'requires_understanding' => $content->requires_understanding,
            'requires_review' => $content->requires_review,
            'requires_theory_practice' => $content->requires_theory_practice,
            'requires_exercise_practice' => $content->requires_exercise_practice,
            'progress' => $progress ? [
                'status' => $progress->status,
                'understanding_completed' => $progress->understanding_completed,
                'review_completed' => $progress->review_completed,
                'theory_practice_completed' => $progress->theory_practice_completed,
                'exercise_practice_completed' => $progress->exercise_practice_completed,
                'completion_percentage' => $progress->completion_percentage,
            ] : null,
        ];

        // Add children if they exist (e.g., topics under a unit)
        $children = [];
        if ($content->children && $content->children->count() > 0) {
            foreach ($content->children as $child) {
                $childProgress = $progressMap->get($child->id);
                $children[] = [
                    'id' => $child->id,
                    'title_ar' => $child->title_ar,
                    'level' => $child->level,
                    'parent_title' => $content->title_ar,
                    'requires_understanding' => $child->requires_understanding,
                    'requires_review' => $child->requires_review,
                    'requires_theory_practice' => $child->requires_theory_practice,
                    'requires_exercise_practice' => $child->requires_exercise_practice,
                    'progress' => $childProgress ? [
                        'status' => $childProgress->status,
                        'understanding_completed' => $childProgress->understanding_completed,
                        'review_completed' => $childProgress->review_completed,
                        'theory_practice_completed' => $childProgress->theory_practice_completed,
                        'exercise_practice_completed' => $childProgress->exercise_practice_completed,
                        'completion_percentage' => $childProgress->completion_percentage,
                    ] : null,
                ];
            }
        }

        // Combine main item and children
        $result = array_merge([$mainItem], $children);

        return response()->json([
            'success' => true,
            'data' => $result,
            'meta' => [
                'session_type' => $sessionType,
                'phase_to_complete' => match ($sessionType) {
                    'study' => 'understanding',
                    'revision' => 'review',
                    'practice' => 'theory_practice',
                    'exam' => 'exercise_practice',
                    default => 'understanding',
                },
                'total_available' => count($result),
                'has_content' => true,
                'content_id' => $id,
                'content_title' => $content->title_ar,
            ]
        ]);
    }
}
