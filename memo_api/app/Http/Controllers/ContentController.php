<?php

namespace App\Http\Controllers;

use App\Models\Content;
use App\Models\ContentRating;
use App\Models\UserContentProgress;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ContentController extends Controller
{
    /**
     * Get list of contents with filtering.
     *
     * GET /api/contents
     */
    public function index(Request $request)
    {
        $query = Content::with([
            'subject',
            'contentType',
            'chapter',
        ])->published();

        // Filter by subject
        if ($request->has('subject_id')) {
            $query->where('subject_id', $request->subject_id);
        }

        // Filter by content type
        if ($request->has('type_id')) {
            $query->where('content_type_id', $request->type_id);
        }

        // Filter by chapter
        if ($request->has('chapter_id')) {
            $query->where('chapter_id', $request->chapter_id);
        }

        // Filter by difficulty
        if ($request->has('difficulty')) {
            $query->where('difficulty_level', $request->difficulty);
        }

        // Filter by premium/free
        if ($request->has('is_premium')) {
            if ($request->boolean('is_premium')) {
                $query->premium();
            } else {
                $query->free();
            }
        } else {
            // Default: only free content for non-authenticated users
            if (!auth('sanctum')->check()) {
                $query->free();
            }
        }

        // Search
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('title_ar', 'like', "%{$search}%")
                    ->orWhere('description_ar', 'like', "%{$search}%")
                    ->orWhere('search_keywords', 'like', "%{$search}%");
            });
        }

        // Order by
        $orderBy = $request->get('order_by', 'order');
        $orderDirection = $request->get('order_direction', 'asc');
        $query->orderBy($orderBy, $orderDirection);

        // Pagination
        $perPage = $request->get('per_page', 15);
        $contents = $query->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $contents,
        ]);
    }

    /**
     * Get single content details.
     *
     * GET /api/contents/{id}
     */
    public function show($id)
    {
        $content = Content::with([
            'subject',
            'contentType',
            'chapter',
            'creator',
            'ratings',
        ])->published()->findOrFail($id);

        // Check if premium and user has access
        if ($content->is_premium && !$this->userHasAccessToPremiumContent(auth('sanctum')->id(), $content)) {
            return response()->json([
                'success' => false,
                'message' => 'This content requires an active subscription.',
                'error_code' => 'PREMIUM_CONTENT',
            ], 403);
        }

        // Get user progress if authenticated
        if (auth('sanctum')->check()) {
            $progress = UserContentProgress::where('user_id', auth('sanctum')->id())
                ->where('content_id', $id)
                ->first();

            $content->user_progress = $progress;
        }

        // Calculate average rating
        $content->average_rating = $content->ratings()->avg('rating');
        $content->rating_count = $content->ratings()->count();

        return response()->json([
            'success' => true,
            'data' => $content,
        ]);
    }

    /**
     * Record content view.
     *
     * POST /api/contents/{id}/view
     * Also creates/updates user_content_progress to track the view
     */
    public function recordView($id)
    {
        $content = Content::findOrFail($id);

        // Check premium access
        if ($content->is_premium && !$this->userHasAccessToPremiumContent(auth()->id(), $content)) {
            return response()->json([
                'success' => false,
                'message' => 'This content requires an active subscription.',
            ], 403);
        }

        $content->increment('views_count');

        // Create or update user content progress
        $userId = auth()->id();
        if ($userId) {
            // First, check if progress record exists
            $existingProgress = UserContentProgress::where('user_id', $userId)
                ->where('content_id', $id)
                ->first();

            if ($existingProgress) {
                // Update last_accessed_at only
                $existingProgress->update([
                    'last_accessed_at' => now(),
                ]);
                $progress = $existingProgress;
            } else {
                // Create new progress record
                $progress = UserContentProgress::create([
                    'user_id' => $userId,
                    'content_id' => $id,
                    'status' => 'in_progress',
                    'progress_percentage' => 0,
                    'time_spent_seconds' => 0,
                    'is_completed' => false,
                    'started_at' => now(),
                    'last_accessed_at' => now(),
                ]);
            }

            \Log::info('📥 CONTENT_VIEW: Recorded view for content', [
                'content_id' => $id,
                'user_id' => $userId,
                'progress_id' => $progress->id,
                'status' => $progress->status,
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'View recorded',
        ]);
    }

    /**
     * Record content download.
     *
     * POST /api/contents/{id}/download or /api/contents/{id}/record-download
     * Also updates user_content_progress to track the download
     */
    public function recordDownload($id)
    {
        $content = Content::findOrFail($id);

        // Check premium access
        if ($content->is_premium && !$this->userHasAccessToPremiumContent(auth()->id(), $content)) {
            return response()->json([
                'success' => false,
                'message' => 'This content requires an active subscription.',
            ], 403);
        }

        if (!$content->has_file) {
            return response()->json([
                'success' => false,
                'message' => 'No file available for download',
            ], 400);
        }

        $content->increment('downloads_count');

        // Create or update user content progress
        $userId = auth()->id();
        if ($userId) {
            // First, check if progress record exists
            $existingProgress = UserContentProgress::where('user_id', $userId)
                ->where('content_id', $id)
                ->first();

            if ($existingProgress) {
                // Update last_accessed_at only
                $existingProgress->update([
                    'last_accessed_at' => now(),
                ]);
                $progress = $existingProgress;
            } else {
                // Create new progress record
                $progress = UserContentProgress::create([
                    'user_id' => $userId,
                    'content_id' => $id,
                    'status' => 'in_progress',
                    'progress_percentage' => 0,
                    'time_spent_seconds' => 0,
                    'is_completed' => false,
                    'started_at' => now(),
                    'last_accessed_at' => now(),
                ]);
            }

            \Log::info('📥 CONTENT_DOWNLOAD: Recorded download for content', [
                'content_id' => $id,
                'user_id' => $userId,
                'progress_id' => $progress->id,
                'status' => $progress->status,
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Download recorded',
            'data' => [
                'file_path' => $content->file_path,
                'file_type' => $content->file_type,
                'file_size' => $content->file_size,
            ],
        ]);
    }

    /**
     * Rate content.
     *
     * POST /api/contents/{id}/rate
     */
    public function rate(Request $request, $id)
    {
        $validated = $request->validate([
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string|max:1000',
        ]);

        $content = Content::findOrFail($id);

        // Check if user already rated this content
        $existingRating = ContentRating::where('user_id', auth()->id())
            ->where('content_id', $id)
            ->first();

        if ($existingRating) {
            $existingRating->update([
                'rating' => $validated['rating'],
                'comment' => $validated['comment'] ?? null,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Rating updated successfully',
                'data' => $existingRating->fresh(),
            ]);
        }

        $rating = ContentRating::create([
            'user_id' => auth()->id(),
            'content_id' => $id,
            'rating' => $validated['rating'],
            'comment' => $validated['comment'] ?? null,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Content rated successfully',
            'data' => $rating,
        ], 201);
    }

    /**
     * Get user's progress for a content.
     *
     * GET /api/contents/{id}/progress
     */
    public function getProgress($id)
    {
        $progress = UserContentProgress::where('user_id', auth()->id())
            ->where('content_id', $id)
            ->first();

        if (!$progress) {
            return response()->json([
                'success' => true,
                'data' => [
                    'is_completed' => false,
                    'progress_percentage' => 0,
                    'time_spent_seconds' => 0,
                ],
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => $progress,
        ]);
    }

    /**
     * Update user's progress for a content.
     *
     * POST /api/contents/{id}/progress
     */
    public function updateProgress(Request $request, $id)
    {
        $validated = $request->validate([
            'progress_percentage' => 'required|integer|min:0|max:100',
            'time_spent_seconds' => 'nullable|integer|min:0',
            'is_completed' => 'nullable|boolean',
        ]);

        $content = Content::findOrFail($id);

        $progress = UserContentProgress::updateOrCreate(
            [
                'user_id' => auth()->id(),
                'content_id' => $id,
            ],
            [
                'progress_percentage' => $validated['progress_percentage'],
                'time_spent_seconds' => DB::raw('time_spent_seconds + ' . ($validated['time_spent_seconds'] ?? 0)),
                'is_completed' => $validated['is_completed'] ?? ($validated['progress_percentage'] >= 100),
                'completed_at' => ($validated['is_completed'] ?? false) ? now() : null,
            ]
        );

        return response()->json([
            'success' => true,
            'message' => 'Progress updated successfully',
            'data' => $progress->fresh(),
        ]);
    }

    /**
     * Check if user has access to premium content.
     */
    private function userHasAccessToPremiumContent($userId, $content)
    {
        if (!$userId) {
            return false;
        }

        // Check if user has active subscription for this content's course
        // This will be implemented when we add the subscription system
        // For now, return false
        return false;
    }
}
