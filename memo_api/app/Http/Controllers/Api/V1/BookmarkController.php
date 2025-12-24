<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Content;
use App\Models\ContentBookmark;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class BookmarkController extends Controller
{
    /**
     * Get all user's bookmarks.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        $query = ContentBookmark::where('user_id', Auth::id())
            ->with(['content.subject', 'content.contentType', 'content.chapter']);

        // Filter by content type
        if ($request->has('content_type_id')) {
            $query->whereHas('content', function($q) use ($request) {
                $q->where('content_type_id', $request->content_type_id);
            });
        }

        // Filter by subject
        if ($request->has('subject_id')) {
            $query->whereHas('content', function($q) use ($request) {
                $q->where('subject_id', $request->subject_id);
            });
        }

        $bookmarks = $query->orderBy('created_at', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => $bookmarks->map(function($bookmark) {
                return $this->formatBookmark($bookmark);
            }),
        ]);
    }

    /**
     * Add a bookmark.
     *
     * @param Request $request
     * @param int $contentId
     * @return JsonResponse
     */
    public function store(Request $request, int $contentId): JsonResponse
    {
        $validated = $request->validate([
            'page_number' => 'nullable|integer|min:1',
            'timestamp_seconds' => 'nullable|integer|min:0',
            'notes' => 'nullable|string|max:1000',
        ]);

        $content = Content::where('is_published', true)->findOrFail($contentId);

        $bookmark = ContentBookmark::updateOrCreate(
            [
                'user_id' => Auth::id(),
                'content_id' => $contentId,
            ],
            [
                'page_number' => $validated['page_number'] ?? null,
                'timestamp_seconds' => $validated['timestamp_seconds'] ?? null,
                'notes' => $validated['notes'] ?? null,
            ]
        );

        return response()->json([
            'success' => true,
            'message' => 'تمت إضافة العلامة المرجعية بنجاح',
            'data' => $this->formatBookmark($bookmark->load(['content.subject', 'content.contentType'])),
        ], 201);
    }

    /**
     * Check if content is bookmarked.
     *
     * @param int $contentId
     * @return JsonResponse
     */
    public function check(int $contentId): JsonResponse
    {
        $content = Content::where('is_published', true)->findOrFail($contentId);

        $bookmark = ContentBookmark::where('user_id', Auth::id())
            ->where('content_id', $contentId)
            ->first();

        return response()->json([
            'success' => true,
            'data' => [
                'is_bookmarked' => $bookmark !== null,
                'bookmark' => $bookmark ? $this->formatBookmark($bookmark) : null,
            ],
        ]);
    }

    /**
     * Remove a bookmark.
     *
     * @param int $contentId
     * @return JsonResponse
     */
    public function destroy(int $contentId): JsonResponse
    {
        $content = Content::where('is_published', true)->findOrFail($contentId);

        $deleted = ContentBookmark::where('user_id', Auth::id())
            ->where('content_id', $contentId)
            ->delete();

        if (!$deleted) {
            return response()->json([
                'success' => false,
                'message' => 'العلامة المرجعية غير موجودة',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'تم حذف العلامة المرجعية بنجاح',
        ]);
    }

    /**
     * Get bookmarks count.
     *
     * @return JsonResponse
     */
    public function count(): JsonResponse
    {
        $count = ContentBookmark::where('user_id', Auth::id())->count();

        return response()->json([
            'success' => true,
            'data' => [
                'total_bookmarks' => $count,
            ],
        ]);
    }

    /**
     * Format bookmark data for API response.
     *
     * @param ContentBookmark $bookmark
     * @return array
     */
    private function formatBookmark(ContentBookmark $bookmark): array
    {
        return [
            'id' => $bookmark->id,
            'content' => [
                'id' => $bookmark->content->id,
                'title_ar' => $bookmark->content->title_ar,
                'title_fr' => $bookmark->content->title_fr,
                'slug' => $bookmark->content->slug,
                'difficulty_level' => $bookmark->content->difficulty_level,
                'estimated_duration_minutes' => $bookmark->content->estimated_duration_minutes,
                'is_premium' => $bookmark->content->is_premium,
                'subject' => [
                    'id' => $bookmark->content->subject->id,
                    'name_ar' => $bookmark->content->subject->name_ar,
                    'color' => $bookmark->content->subject->color,
                    'icon' => $bookmark->content->subject->icon,
                ],
                'type' => [
                    'id' => $bookmark->content->contentType->id,
                    'name_ar' => $bookmark->content->contentType->name_ar,
                    'icon' => $bookmark->content->contentType->icon,
                ],
                'chapter' => $bookmark->content->chapter ? [
                    'id' => $bookmark->content->chapter->id,
                    'title_ar' => $bookmark->content->chapter->title_ar,
                ] : null,
            ],
            'page_number' => $bookmark->page_number,
            'timestamp_seconds' => $bookmark->timestamp_seconds,
            'notes' => $bookmark->notes,
            'created_at' => $bookmark->created_at->toISOString(),
            'updated_at' => $bookmark->updated_at->toISOString(),
        ];
    }
}
