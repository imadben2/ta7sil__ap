<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SubjectPriority;
use App\Services\PriorityCalculationService;
use Illuminate\Http\Request;

class PriorityController extends Controller
{
    protected PriorityCalculationService $priorityService;

    public function __construct(PriorityCalculationService $priorityService)
    {
        $this->priorityService = $priorityService;
    }

    /**
     * Get user's subject priorities
     */
    public function getPriorities(Request $request)
    {
        $user = $request->user();
        $priorities = SubjectPriority::where('user_id', $user->id)
            ->with('subject')
            ->orderBy('total_priority_score', 'desc')
            ->get();

        return response()->json([
            'priorities' => $priorities,
        ]);
    }

    /**
     * Get specific subject priority
     */
    public function getSubjectPriority(Request $request, $subjectId)
    {
        $user = $request->user();
        $priority = SubjectPriority::where('user_id', $user->id)
            ->where('subject_id', $subjectId)
            ->with('subject')
            ->first();

        if (!$priority) {
            return response()->json([
                'error' => 'Priority data not found for this subject',
            ], 404);
        }

        return response()->json([
            'priority' => $priority,
        ]);
    }

    /**
     * Recalculate all priorities
     */
    public function recalculateAll(Request $request)
    {
        $user = $request->user();

        try {
            $this->priorityService->calculateAllPriorities($user);

            $priorities = $this->priorityService->getPrioritizedSubjects($user);

            return response()->json([
                'message' => 'Priorities recalculated successfully',
                'priorities' => $priorities,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Recalculate priority for specific subject
     */
    public function recalculateSubject(Request $request, $subjectId)
    {
        $user = $request->user();
        $subject = $user->subjects()->find($subjectId);

        if (!$subject) {
            return response()->json([
                'error' => 'Subject not found',
            ], 404);
        }

        try {
            $priority = $this->priorityService->calculateSubjectPriority($user, $subject);

            return response()->json([
                'message' => 'Subject priority recalculated successfully',
                'priority' => $priority->load('subject'),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get top priority subjects
     */
    public function getTopPriorities(Request $request)
    {
        $user = $request->user();
        $limit = $request->query('limit', 5);

        $priorities = $this->priorityService->getPrioritizedSubjects($user, $limit);

        return response()->json([
            'top_priorities' => $priorities,
        ]);
    }
}
