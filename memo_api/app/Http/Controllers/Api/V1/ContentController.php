<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Content;
use App\Models\Subject;
use App\Models\ContentType;
use App\Models\ContentChapter;
use App\Models\UserContentProgress;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;

class ContentController extends Controller
{
    /**
     * Get the stream ID from request or authenticated user's academic profile.
     *
     * @param Request $request
     * @return int|null
     */
    private function getStreamId(Request $request): ?int
    {
        // First check if stream_id is provided in request
        if ($request->has('stream_id')) {
            return (int) $request->stream_id;
        }

        // Otherwise, try to get from authenticated user's academic profile
        $user = Auth::user();
        if ($user) {
            $user->loadMissing('academicProfile');
            return $user->academicProfile?->academic_stream_id;
        }

        return null;
    }

    /**
     * Get contents list with filtering and pagination.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        $query = Content::where('is_published', true)
            ->with(['subject', 'contentType', 'chapter', 'academicStream']);

        // Filter by academic stream (from request or user profile)
        $streamId = $this->getStreamId($request);
        if ($streamId) {
            $query->forStream($streamId);
        }

        // Filter by subject
        if ($request->has('subject_id')) {
            $query->where('subject_id', $request->subject_id);
        }

        // Filter by chapter
        if ($request->has('chapter_id')) {
            $query->where('chapter_id', $request->chapter_id);
        }

        // Filter by content type
        if ($request->has('content_type_id')) {
            $query->where('content_type_id', $request->content_type_id);
        }

        // Filter by difficulty
        if ($request->has('difficulty')) {
            $query->where('difficulty_level', $request->difficulty);
        }

        // Filter premium content
        if ($request->has('premium')) {
            $query->where('is_premium', filter_var($request->premium, FILTER_VALIDATE_BOOLEAN));
        }

        // Order by
        $orderBy = $request->get('order_by', 'order');
        $orderDirection = $request->get('order_direction', 'asc');

        if (in_array($orderBy, ['order', 'views_count', 'created_at'])) {
            $query->orderBy($orderBy, $orderDirection);
        } else {
            $query->orderBy('order');
        }

        $perPage = min($request->get('per_page', 20), 50);
        $contents = $query->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $contents->map(function($content) {
                return $this->formatContent($content, false);
            }),
            'pagination' => [
                'total' => $contents->total(),
                'per_page' => $contents->perPage(),
                'current_page' => $contents->currentPage(),
                'last_page' => $contents->lastPage(),
            ],
        ]);
    }

    /**
     * Get a specific content with full details.
     *
     * @param int $id
     * @return JsonResponse
     */
    public function show(int $id): JsonResponse
    {
        $content = Content::where('is_published', true)
            ->with(['subject', 'contentType', 'chapter', 'creator'])
            ->findOrFail($id);

        // Increment view count
        $content->increment('views_count');

        return response()->json([
            'success' => true,
            'data' => $this->formatContent($content, true),
        ]);
    }

    /**
     * Search contents.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function search(Request $request): JsonResponse
    {
        $request->validate([
            'q' => 'required|string|min:2',
        ]);

        $query = Content::where('is_published', true)
            ->with(['subject', 'contentType', 'chapter', 'academicStream']);

        // Filter by academic stream (from request or user profile)
        $streamId = $this->getStreamId($request);
        if ($streamId) {
            $query->forStream($streamId);
        }

        $searchTerm = $request->get('q');

        $query->where(function($q) use ($searchTerm) {
            $q->where('title_ar', 'LIKE', '%' . $searchTerm . '%')
              ->orWhere('description_ar', 'LIKE', '%' . $searchTerm . '%')
              ->orWhere('search_keywords', 'LIKE', '%' . $searchTerm . '%')
              ->orWhereJsonContains('tags', $searchTerm);
        });

        // Apply filters
        if ($request->has('subject_id')) {
            $query->where('subject_id', $request->subject_id);
        }

        if ($request->has('content_type_id')) {
            $query->where('content_type_id', $request->content_type_id);
        }

        $perPage = min($request->get('per_page', 20), 50);
        $contents = $query->orderByRaw("
            CASE
                WHEN title_ar LIKE ? THEN 1
                WHEN description_ar LIKE ? THEN 2
                ELSE 3
            END
        ", ['%' . $searchTerm . '%', '%' . $searchTerm . '%'])
        ->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $contents->map(function($content) {
                return $this->formatContent($content, false);
            }),
            'pagination' => [
                'total' => $contents->total(),
                'per_page' => $contents->perPage(),
                'current_page' => $contents->currentPage(),
                'last_page' => $contents->lastPage(),
            ],
        ]);
    }

    /**
     * Get contents by chapter.
     *
     * @param int $chapterId
     * @param Request $request
     * @return JsonResponse
     */
    public function byChapter(int $chapterId, Request $request): JsonResponse
    {
        $chapter = ContentChapter::where('is_active', true)->findOrFail($chapterId);

        $query = Content::where('is_published', true)
            ->where('chapter_id', $chapterId)
            ->with(['subject', 'contentType', 'academicStream']);

        // Filter by academic stream (from request or user profile)
        $streamId = $this->getStreamId($request);
        if ($streamId) {
            $query->forStream($streamId);
        }

        $contents = $query->orderBy('order')->get();

        return response()->json([
            'success' => true,
            'data' => [
                'chapter' => [
                    'id' => $chapter->id,
                    'title_ar' => $chapter->title_ar,
                    'title_fr' => $chapter->title_fr,
                    'description_ar' => $chapter->description_ar,
                    'academic_stream_id' => $chapter->academic_stream_id,
                ],
                'contents' => $contents->map(function($content) {
                    return $this->formatContent($content, false);
                }),
            ],
        ]);
    }

    /**
     * Download content file (PDF/DOC).
     *
     * @param int $id
     * @return mixed
     */
    public function download(int $id)
    {
        $content = Content::where('is_published', true)->findOrFail($id);

        if (!$content->has_file || !$content->file_path) {
            return response()->json([
                'success' => false,
                'message' => 'لا يوجد ملف للتحميل',
            ], 404);
        }

        // Increment download count
        $content->increment('downloads_count');

        // Return file download
        return Storage::download($content->file_path);
    }

    /**
     * Stream content file directly (for files not in public storage).
     *
     * @param int $id
     * @return mixed
     */
    public function streamFile(int $id)
    {
        $content = Content::where('is_published', true)->findOrFail($id);

        if (!$content->has_file || !$content->file_path) {
            return response()->json([
                'success' => false,
                'message' => 'لا يوجد ملف متاح',
            ], 404);
        }

        // Check if file exists
        if (!Storage::exists($content->file_path)) {
            return response()->json([
                'success' => false,
                'message' => 'الملف غير موجود',
            ], 404);
        }

        // Get file content and mime type
        $mimeType = $content->file_type ?? Storage::mimeType($content->file_path);
        $fileName = basename($content->file_path);

        // Return file as response
        return response(Storage::get($content->file_path), 200)
            ->header('Content-Type', $mimeType)
            ->header('Content-Disposition', 'inline; filename="' . $fileName . '"')
            ->header('Cache-Control', 'public, max-age=86400');
    }

    /**
     * Get content types.
     *
     * @return JsonResponse
     */
    public function types(): JsonResponse
    {
        $types = ContentType::all(['id', 'name_ar', 'name_fr', 'slug', 'icon']);

        return response()->json([
            'success' => true,
            'data' => $types,
        ]);
    }

    /**
     * Get chapters by subject with content counts.
     *
     * GET /v1/contents/chapters?subject_id=X&stream_id=Y
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function chapters(Request $request): JsonResponse
    {
        $request->validate([
            'subject_id' => 'required|integer|exists:subjects,id',
        ]);

        $subjectId = $request->get('subject_id');

        // Get stream ID from request or user profile
        $streamId = $this->getStreamId($request);

        $query = ContentChapter::where('subject_id', $subjectId)
            ->where('is_active', true);

        // Filter chapters by stream
        if ($streamId) {
            $query->forStream($streamId);
        }

        // Count contents with stream filtering
        $chapters = $query->withCount([
                'contents as lessons_count' => function($q) use ($streamId) {
                    $q->where('is_published', true)->where('content_type_id', 1);
                    if ($streamId) {
                        $q->where(function($sq) use ($streamId) {
                            $sq->where('academic_stream_id', $streamId)
                               ->orWhereNull('academic_stream_id');
                        });
                    }
                },
                'contents as summaries_count' => function($q) use ($streamId) {
                    $q->where('is_published', true)->where('content_type_id', 2);
                    if ($streamId) {
                        $q->where(function($sq) use ($streamId) {
                            $sq->where('academic_stream_id', $streamId)
                               ->orWhereNull('academic_stream_id');
                        });
                    }
                },
                'contents as exercises_count' => function($q) use ($streamId) {
                    $q->where('is_published', true)->where('content_type_id', 3);
                    if ($streamId) {
                        $q->where(function($sq) use ($streamId) {
                            $sq->where('academic_stream_id', $streamId)
                               ->orWhereNull('academic_stream_id');
                        });
                    }
                },
                'contents as tests_count' => function($q) use ($streamId) {
                    $q->where('is_published', true)->where('content_type_id', 4);
                    if ($streamId) {
                        $q->where(function($sq) use ($streamId) {
                            $sq->where('academic_stream_id', $streamId)
                               ->orWhereNull('academic_stream_id');
                        });
                    }
                },
            ])
            ->orderBy('order')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $chapters->map(function($chapter) {
                $totalCount = $chapter->lessons_count + $chapter->summaries_count +
                              $chapter->exercises_count + $chapter->tests_count;

                return [
                    'id' => $chapter->id,
                    'subject_id' => $chapter->subject_id,
                    'academic_stream_id' => $chapter->academic_stream_id,
                    'title_ar' => $chapter->title_ar,
                    'title_fr' => $chapter->title_fr ?? $chapter->title_ar,
                    'slug' => $chapter->slug,
                    'description_ar' => $chapter->description_ar,
                    'order' => $chapter->order,
                    'is_active' => $chapter->is_active,
                    'content_counts' => [
                        'lessons' => $chapter->lessons_count,
                        'summaries' => $chapter->summaries_count,
                        'exercises' => $chapter->exercises_count,
                        'tests' => $chapter->tests_count,
                    ],
                    'total_count' => $totalCount,
                ];
            }),
        ]);
    }

    /**
     * Format content data for API response.
     *
     * @param Content $content
     * @param bool $detailed
     * @return array
     */
    private function formatContent(Content $content, bool $detailed = false): array
    {
        $data = [
            'id' => $content->id,
            'academic_stream_id' => $content->academic_stream_id,
            'title_ar' => $content->title_ar,
            'title_fr' => $content->title_fr,
            'description_ar' => $content->description_ar,
            'description_fr' => $content->description_fr,
            'slug' => $content->slug,
            'difficulty_level' => $content->difficulty_level,
            'estimated_duration_minutes' => $content->estimated_duration_minutes,
            'is_premium' => $content->is_premium,
            'views_count' => $content->views_count,
            'downloads_count' => $content->downloads_count,
            'average_rating' => $content->average_rating,
            'total_ratings' => $content->total_ratings,
            'order' => $content->order,
            'subject' => [
                'id' => $content->subject->id,
                'name_ar' => $content->subject->name_ar,
                'name_fr' => $content->subject->name_fr,
                'color' => $content->subject->color,
                'icon' => $content->subject->icon,
            ],
            'type' => [
                'id' => $content->contentType->id,
                'name_ar' => $content->contentType->name_ar,
                'name_fr' => $content->contentType->name_fr,
                'icon' => $content->contentType->icon,
            ],
        ];

        // Include academic stream info if available
        if ($content->academicStream) {
            $data['academic_stream'] = [
                'id' => $content->academicStream->id,
                'name_ar' => $content->academicStream->name_ar,
            ];
        }

        if ($content->chapter) {
            $data['chapter'] = [
                'id' => $content->chapter->id,
                'title_ar' => $content->chapter->title_ar,
                'title_fr' => $content->chapter->title_fr,
            ];
        }

        // Include user progress if authenticated
        $userId = Auth::id();
        if ($userId) {
            $progress = UserContentProgress::where('user_id', $userId)
                ->where('content_id', $content->id)
                ->first();

            if ($progress) {
                $data['user_progress'] = [
                    'progress_percentage' => $progress->progress_percentage,
                    'is_completed' => $progress->is_completed,
                    'status' => $progress->status,
                    'time_spent_seconds' => $progress->time_spent_seconds,
                    'started_at' => $progress->started_at?->toISOString(),
                    'completed_at' => $progress->completed_at?->toISOString(),
                    'last_accessed_at' => $progress->last_accessed_at?->toISOString(),
                ];
            } else {
                $data['user_progress'] = null;
            }
        }

        if ($detailed) {
            $data['content_body_ar'] = $content->content_body_ar;
            $data['content_body_fr'] = $content->content_body_fr;
            $data['tags'] = $content->tags;

            // Files - use file_path field from model
            // Generate proper URL based on file_path format
            $fileUrl = null;
            if ($content->has_file && $content->file_path) {
                // Check if file_path starts with 'public/' (uses storage:link)
                if (str_starts_with($content->file_path, 'public/')) {
                    $fileUrl = url(Storage::url($content->file_path));
                } else {
                    // File is in storage/app/ - serve via API route
                    $fileUrl = url('/api/v1/contents/' . $content->id . '/file');
                }
            }

            $data['files'] = [
                'pdf' => ($content->has_file && $content->file_path) ? [
                    'url' => $fileUrl,
                    'name' => basename($content->file_path),
                    'type' => $content->file_type,
                    'size' => $content->file_size,
                ] : null,
                'has_file' => $content->has_file,
                'file_path' => $content->file_path,
                'file_type' => $content->file_type,
                'video_url' => $content->video_url,
                'has_video' => $content->has_video,
            ];

            $data['published_at'] = $content->published_at?->toISOString();
            $data['created_at'] = $content->created_at->toISOString();
            $data['updated_at'] = $content->updated_at->toISOString();
        }

        return $data;
    }
}
