<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\BacSubject;
use App\Models\BacSubjectBookmark;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class BacBookmarkController extends Controller
{
    /**
     * Get all user's BAC bookmarks.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        $query = BacSubjectBookmark::where('user_id', Auth::id())
            ->with(['bacSubject.bacYear', 'bacSubject.bacSession', 'bacSubject.subject']);

        $bookmarks = $query->orderBy('created_at', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => $bookmarks->map(function($bookmark) {
                return $this->formatBookmark($bookmark);
            }),
        ]);
    }

    /**
     * Toggle bookmark for a BAC subject.
     *
     * @param Request $request
     * @param int $bacSubjectId
     * @return JsonResponse
     */
    public function toggle(Request $request, int $bacSubjectId): JsonResponse
    {
        $bacSubject = BacSubject::findOrFail($bacSubjectId);

        $existingBookmark = BacSubjectBookmark::where('user_id', Auth::id())
            ->where('bac_subject_id', $bacSubjectId)
            ->first();

        if ($existingBookmark) {
            // Remove bookmark
            $existingBookmark->delete();
            return response()->json([
                'success' => true,
                'message' => 'تم إزالة العلامة المرجعية',
                'data' => [
                    'is_bookmarked' => false,
                ],
            ]);
        } else {
            // Add bookmark
            $validated = $request->validate([
                'page_number' => 'nullable|integer|min:1',
                'notes' => 'nullable|string|max:1000',
            ]);

            $bookmark = BacSubjectBookmark::create([
                'user_id' => Auth::id(),
                'bac_subject_id' => $bacSubjectId,
                'page_number' => $validated['page_number'] ?? null,
                'notes' => $validated['notes'] ?? null,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'تمت إضافة العلامة المرجعية بنجاح',
                'data' => [
                    'is_bookmarked' => true,
                    'bookmark' => $this->formatBookmark($bookmark->load(['bacSubject.bacYear', 'bacSubject.bacSession', 'bacSubject.subject'])),
                ],
            ], 201);
        }
    }

    /**
     * Check if BAC subject is bookmarked.
     *
     * @param int $bacSubjectId
     * @return JsonResponse
     */
    public function check(int $bacSubjectId): JsonResponse
    {
        $bacSubject = BacSubject::findOrFail($bacSubjectId);

        $bookmark = BacSubjectBookmark::where('user_id', Auth::id())
            ->where('bac_subject_id', $bacSubjectId)
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
     * @param int $bacSubjectId
     * @return JsonResponse
     */
    public function destroy(int $bacSubjectId): JsonResponse
    {
        $bacSubject = BacSubject::findOrFail($bacSubjectId);

        $deleted = BacSubjectBookmark::where('user_id', Auth::id())
            ->where('bac_subject_id', $bacSubjectId)
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
        $count = BacSubjectBookmark::where('user_id', Auth::id())->count();

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
     * @param BacSubjectBookmark $bookmark
     * @return array
     */
    private function formatBookmark(BacSubjectBookmark $bookmark): array
    {
        $bacSubject = $bookmark->bacSubject;

        return [
            'id' => $bookmark->id,
            'bac_subject' => [
                'id' => $bacSubject->id,
                'name_ar' => $bacSubject->subject?->name_ar ?? $bacSubject->title_ar,
                'name_fr' => $bacSubject->subject?->name_fr,
                'title_ar' => $bacSubject->title_ar,
                'duration' => $bacSubject->duration_minutes,
                'has_correction' => $bacSubject->correction_file_path !== null,
                'file_url' => $bacSubject->getFileUrl(),
                'correction_url' => $bacSubject->getCorrectionUrl(),
                'download_url' => $bacSubject->getSignedDownloadUrl(),
                'correction_download_url' => $bacSubject->getSignedCorrectionUrl(),
                'bac_year' => $bacSubject->bacYear ? [
                    'id' => $bacSubject->bacYear->id,
                    'year' => $bacSubject->bacYear->year,
                ] : null,
                'bac_session' => $bacSubject->bacSession ? [
                    'id' => $bacSubject->bacSession->id,
                    'name_ar' => $bacSubject->bacSession->name_ar,
                ] : null,
                'subject' => $bacSubject->subject ? [
                    'id' => $bacSubject->subject->id,
                    'name_ar' => $bacSubject->subject->name_ar,
                    'color' => $bacSubject->subject->color,
                ] : null,
            ],
            'page_number' => $bookmark->page_number,
            'notes' => $bookmark->notes,
            'created_at' => $bookmark->created_at->toISOString(),
            'updated_at' => $bookmark->updated_at->toISOString(),
        ];
    }
}
