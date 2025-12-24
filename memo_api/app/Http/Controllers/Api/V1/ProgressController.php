<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Content;
use App\Models\Subject;
use App\Models\UserContentProgress;
use App\Models\ContentRating;
use App\Services\UserProgressService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ProgressController extends Controller
{
    protected UserProgressService $progressService;

    public function __construct(UserProgressService $progressService)
    {
        $this->progressService = $progressService;
    }
    /**
     * Get user's progress for a content.
     *
     * @param int $contentId
     * @return JsonResponse
     */
    public function getProgress(int $contentId): JsonResponse
    {
        $content = Content::where('is_published', true)->findOrFail($contentId);

        $progress = UserContentProgress::where('user_id', Auth::id())
            ->where('content_id', $contentId)
            ->first();

        if (!$progress) {
            return response()->json([
                'success' => true,
                'data' => [
                    'progress' => 0,
                    'is_completed' => false,
                    'started_at' => null,
                    'completed_at' => null,
                ],
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'progress' => $progress->progress_percentage,
                'is_completed' => $progress->is_completed,
                'time_spent_seconds' => $progress->time_spent_seconds,
                'started_at' => $progress->started_at?->toISOString(),
                'completed_at' => $progress->completed_at?->toISOString(),
                'last_accessed_at' => $progress->last_accessed_at?->toISOString(),
            ],
        ]);
    }

    /**
     * Update user's progress for a content.
     *
     * @param Request $request
     * @param int $contentId
     * @return JsonResponse
     */
    public function updateProgress(Request $request, int $contentId): JsonResponse
    {
        $validated = $request->validate([
            'progress' => 'required|integer|min:0|max:100',
            'time_spent' => 'nullable|integer|min:0',
        ]);

        $content = Content::where('is_published', true)->findOrFail($contentId);

        $isCompleted = $validated['progress'] >= 100;
        $status = $isCompleted ? 'completed' : ($validated['progress'] > 0 ? 'in_progress' : 'not_started');

        $progress = UserContentProgress::updateOrCreate(
            [
                'user_id' => Auth::id(),
                'content_id' => $contentId,
            ],
            [
                'status' => $status,
                'progress_percentage' => $validated['progress'],
                'time_spent_seconds' => $validated['time_spent'] ?? 0,
                'is_completed' => $isCompleted,
                'started_at' => UserContentProgress::where('user_id', Auth::id())
                    ->where('content_id', $contentId)
                    ->value('started_at') ?? now(),
                'completed_at' => $isCompleted ? now() : null,
                'last_accessed_at' => now(),
            ]
        );

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث التقدم بنجاح',
            'data' => [
                'progress' => $progress->progress_percentage,
                'is_completed' => $progress->is_completed,
                'status' => $progress->status,
                'time_spent_seconds' => $progress->time_spent_seconds,
                'started_at' => $progress->started_at?->toISOString(),
                'completed_at' => $progress->completed_at?->toISOString(),
                'last_accessed_at' => $progress->last_accessed_at?->toISOString(),
            ],
        ]);
    }

    /**
     * Mark content as completed.
     *
     * @param int $contentId
     * @return JsonResponse
     */
    public function markCompleted(int $contentId): JsonResponse
    {
        \Log::info('📥 PROGRESS_CONTROLLER: markCompleted called', [
            'content_id' => $contentId,
            'user_id' => Auth::id(),
            'timestamp' => now()->toISOString(),
        ]);

        $content = Content::where('is_published', true)->findOrFail($contentId);

        $progress = UserContentProgress::updateOrCreate(
            [
                'user_id' => Auth::id(),
                'content_id' => $contentId,
            ],
            [
                'status' => 'completed',
                'progress_percentage' => 100,
                'is_completed' => true,
                'started_at' => UserContentProgress::where('user_id', Auth::id())
                    ->where('content_id', $contentId)
                    ->value('started_at') ?? now(),
                'completed_at' => now(),
                'last_accessed_at' => now(),
            ]
        );

        \Log::info('✅ PROGRESS_CONTROLLER: Progress saved successfully', [
            'progress_id' => $progress->id,
            'status' => $progress->status,
            'is_completed' => $progress->is_completed,
            'user_id' => Auth::id(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'تم تحديد المحتوى كمكتمل',
            'data' => [
                'progress' => $progress->progress_percentage,
                'is_completed' => $progress->is_completed,
                'status' => $progress->status,
                'completed_at' => $progress->completed_at?->toISOString(),
                'started_at' => $progress->started_at?->toISOString(),
                'last_accessed_at' => $progress->last_accessed_at?->toISOString(),
                'time_spent_seconds' => $progress->time_spent_seconds,
            ],
        ]);
    }

    /**
     * Get user's progress summary for a subject.
     *
     * @param int $subjectId
     * @return JsonResponse
     */
    public function subjectProgress(int $subjectId): JsonResponse
    {
        $contents = Content::where('is_published', true)
            ->where('subject_id', $subjectId)
            ->pluck('id');

        $progress = UserContentProgress::where('user_id', Auth::id())
            ->whereIn('content_id', $contents)
            ->get();

        $totalContents = $contents->count();
        $completedContents = $progress->where('is_completed', true)->count();
        $inProgressContents = $progress->where('is_completed', false)->where('progress_percentage', '>', 0)->count();
        $totalTimeSpent = $progress->sum('time_spent_seconds');

        return response()->json([
            'success' => true,
            'data' => [
                'total_contents' => $totalContents,
                'completed_contents' => $completedContents,
                'in_progress_contents' => $inProgressContents,
                'not_started_contents' => $totalContents - $completedContents - $inProgressContents,
                'completion_percentage' => $totalContents > 0 ? round(($completedContents / $totalContents) * 100, 2) : 0,
                'total_time_spent_seconds' => $totalTimeSpent,
                'total_time_spent_hours' => round($totalTimeSpent / 3600, 2),
            ],
        ]);
    }

    /**
     * Rate a content.
     *
     * @param Request $request
     * @param int $contentId
     * @return JsonResponse
     */
    public function rateContent(Request $request, int $contentId): JsonResponse
    {
        $validated = $request->validate([
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string|max:1000',
        ]);

        $content = Content::where('is_published', true)->findOrFail($contentId);

        $rating = ContentRating::updateOrCreate(
            [
                'user_id' => Auth::id(),
                'content_id' => $contentId,
            ],
            [
                'rating' => $validated['rating'],
                'comment' => $validated['comment'] ?? null,
            ]
        );

        return response()->json([
            'success' => true,
            'message' => 'تم تقييم المحتوى بنجاح',
            'data' => [
                'rating' => $rating->rating,
                'comment' => $rating->comment,
                'created_at' => $rating->created_at->toISOString(),
            ],
        ]);
    }

    /**
     * Get user's rating for a content.
     *
     * @param int $contentId
     * @return JsonResponse
     */
    public function getRating(int $contentId): JsonResponse
    {
        $content = Content::where('is_published', true)->findOrFail($contentId);

        $rating = ContentRating::where('user_id', Auth::id())
            ->where('content_id', $contentId)
            ->first();

        if (!$rating) {
            return response()->json([
                'success' => true,
                'data' => null,
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'rating' => $rating->rating,
                'comment' => $rating->comment,
                'created_at' => $rating->created_at->toISOString(),
                'updated_at' => $rating->updated_at->toISOString(),
            ],
        ]);
    }

    /**
     * Get all user's progress.
     *
     * @return JsonResponse
     */
    public function allProgress(): JsonResponse
    {
        $progress = UserContentProgress::where('user_id', Auth::id())
            ->with(['content.subject', 'content.contentType'])
            ->orderBy('last_accessed_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $progress->map(function($item) {
                return [
                    'content' => [
                        'id' => $item->content->id,
                        'title_ar' => $item->content->title_ar,
                        'slug' => $item->content->slug,
                        'subject' => [
                            'id' => $item->content->subject->id,
                            'name_ar' => $item->content->subject->name_ar,
                            'color' => $item->content->subject->color,
                        ],
                        'type' => [
                            'id' => $item->content->contentType->id,
                            'name_ar' => $item->content->contentType->name_ar,
                            'icon' => $item->content->contentType->icon,
                        ],
                    ],
                    'progress' => $item->progress_percentage,
                    'is_completed' => $item->is_completed,
                    'time_spent_seconds' => $item->time_spent_seconds,
                    'last_accessed_at' => $item->last_accessed_at->toISOString(),
                ];
            }),
        ]);
    }
}
