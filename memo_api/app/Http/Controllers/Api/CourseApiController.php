<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\CourseResource;
use App\Http\Resources\CourseListResource;
use App\Models\Course;
use App\Models\CourseModule;
use App\Models\CourseLesson;
use App\Services\SubscriptionService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class CourseApiController extends Controller
{
    protected SubscriptionService $subscriptionService;

    public function __construct(SubscriptionService $subscriptionService)
    {
        $this->subscriptionService = $subscriptionService;
    }

    /**
     * Get all published courses
     * GET /api/courses
     *
     * OPTIMIZED: Uses CourseListResource with eager loading to avoid N+1 queries.
     * Returns all course info but without modules/lessons structure.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Course::where('is_published', true)
            ->with(['subject'])
            ->withCount(['modules as modules_count' => function ($q) {
                $q->where('is_published', true);
            }]);

        // Search
        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('title_ar', 'like', "%{$search}%")
                  ->orWhere('instructor_name', 'like', "%{$search}%");
            });
        }

        // Filter by subject
        if ($request->filled('subject_id')) {
            $query->where('subject_id', $request->subject_id);
        }

        // Filter by level
        if ($request->filled('level')) {
            $query->where('level', $request->level);
        }

        // Filter by academic phase
        if ($request->filled('academic_phase_id')) {
            $query->whereHas('subject.academicYear', function ($q) use ($request) {
                $q->where('academic_phase_id', $request->academic_phase_id);
            });
        }

        // Filter by featured
        if ($request->filled('featured')) {
            $query->where('is_featured', true);
        }

        // Filter by free/paid
        if ($request->filled('is_free')) {
            $query->where('is_free', $request->is_free);
        }

        // Sorting
        $sortBy = $request->get('sort_by', 'created_at');
        $sortOrder = $request->get('sort_order', 'desc');
        $query->orderBy($sortBy, $sortOrder);

        $perPage = $request->get('per_page', 20);
        $courses = $query->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => [
                'data' => CourseListResource::collection($courses->items()),
                'current_page' => $courses->currentPage(),
                'last_page' => $courses->lastPage(),
                'per_page' => $courses->perPage(),
                'total' => $courses->total(),
            ],
        ]);
    }

    /**
     * Get featured courses
     * GET /api/courses/featured
     *
     * OPTIMIZED: Uses CourseListResource with eager loading to avoid N+1 queries.
     */
    public function featured(): JsonResponse
    {
        $courses = Course::where('is_published', true)
            ->where('is_featured', true)
            ->with(['subject'])
            ->withCount(['modules as modules_count' => function ($q) {
                $q->where('is_published', true);
            }])
            ->orderBy('view_count', 'desc')
            ->limit(10)
            ->get();

        return response()->json([
            'success' => true,
            'data' => CourseListResource::collection($courses),
        ]);
    }

    /**
     * Get all courses data in one call (featured + paginated list)
     * GET /api/courses/complete
     *
     * OPTIMIZED: Single endpoint for courses page - reduces 2 API calls to 1
     */
    public function complete(Request $request): JsonResponse
    {
        // Get featured courses
        $featuredCourses = Course::where('is_published', true)
            ->where('is_featured', true)
            ->with(['subject'])
            ->withCount(['modules as modules_count' => function ($q) {
                $q->where('is_published', true);
            }])
            ->orderBy('view_count', 'desc')
            ->limit(10)
            ->get();

        // Get all courses (paginated)
        $query = Course::where('is_published', true)
            ->with(['subject'])
            ->withCount(['modules as modules_count' => function ($q) {
                $q->where('is_published', true);
            }]);

        // Apply filters
        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('title_ar', 'like', "%{$search}%")
                  ->orWhere('instructor_name', 'like', "%{$search}%");
            });
        }

        if ($request->filled('subject_id')) {
            $query->where('subject_id', $request->subject_id);
        }

        if ($request->filled('level')) {
            $query->where('level', $request->level);
        }

        if ($request->filled('is_free')) {
            $query->where('is_free', $request->is_free);
        }

        $sortBy = $request->get('sort_by', 'created_at');
        $sortOrder = $request->get('sort_order', 'desc');
        $query->orderBy($sortBy, $sortOrder);

        $perPage = $request->get('per_page', 20);
        $courses = $query->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => [
                'featured_courses' => CourseListResource::collection($featuredCourses),
                'courses' => [
                    'data' => CourseListResource::collection($courses->items()),
                    'current_page' => $courses->currentPage(),
                    'last_page' => $courses->lastPage(),
                    'per_page' => $courses->perPage(),
                    'total' => $courses->total(),
                ],
            ],
        ]);
    }

    /**
     * Get single course details
     * GET /api/courses/{id}
     */
    public function show(Request $request, $id): JsonResponse
    {
        $course = Course::with([
            'subject',
            'modules' => function ($query) {
                $query->where('is_published', true)
                    ->orderBy('order')
                    ->with(['lessons' => function ($q) {
                        $q->where('is_published', true)->orderBy('order');
                    }]);
            },
            'approvedReviews.user',
        ])->findOrFail($id);

        // Check if user has access
        $user = $request->user();
        $hasAccess = false;

        if ($user) {
            $hasAccess = $this->subscriptionService->hasAccessToCourse($user, $course);
        }

        // Increment view count
        $course->incrementViewCount();

        return response()->json([
            'success' => true,
            'data' => [
                'course' => new CourseResource($course),
                'has_access' => $hasAccess,
            ],
        ]);
    }

    /**
     * Get course modules
     * GET /api/courses/{id}/modules
     */
    public function modules($id): JsonResponse
    {
        $course = Course::findOrFail($id);

        $modules = CourseModule::where('course_id', $course->id)
            ->where('is_published', true)
            ->orderBy('order')
            ->with(['lessons' => function ($q) {
                $q->where('is_published', true)->orderBy('order');
            }])
            ->get();

        return response()->json([
            'success' => true,
            'data' => $modules,
        ]);
    }

    /**
     * Get lesson details with access control
     * GET /api/lessons/{id}
     */
    public function lesson(Request $request, $id): JsonResponse
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'يجب تسجيل الدخول للوصول إلى الدروس',
            ], 401);
        }

        $lesson = CourseLesson::with([
            'module.course',
            'attachments',
        ])->findOrFail($id);

        // Check access
        if (!$lesson->isAccessibleByUser($user)) {
            return response()->json([
                'success' => false,
                'message' => 'ليس لديك صلاحية للوصول إلى هذا الدرس',
            ], 403);
        }

        // Get signed video URL
        $videoUrl = $lesson->getSignedVideoUrl(120); // 2 hours expiry

        // Get user progress for this lesson
        $progress = $user->lessonProgress()
            ->where('course_lesson_id', $lesson->id)
            ->first();

        return response()->json([
            'success' => true,
            'data' => [
                'lesson' => $lesson,
                'video_url' => $videoUrl,
                'progress' => $progress,
            ],
        ]);
    }

    /**
     * Get course statistics
     * GET /api/courses/{id}/stats
     */
    public function stats($id): JsonResponse
    {
        $course = Course::findOrFail($id);

        $stats = [
            'total_modules' => $course->modules()->count(),
            'total_lessons' => CourseLesson::whereIn('course_module_id', $course->modules()->pluck('id'))->count(),
            'total_duration_minutes' => CourseLesson::whereIn('course_module_id', $course->modules()->pluck('id'))->sum('video_duration_seconds') / 60,
            'enrollment_count' => $course->enrollment_count,
            'average_rating' => $course->average_rating,
            'total_reviews' => $course->total_reviews,
        ];

        return response()->json([
            'success' => true,
            'data' => $stats,
        ]);
    }

    /**
     * Search courses
     * GET /api/courses/search
     *
     * OPTIMIZED: Uses CourseListResource with eager loading to avoid N+1 queries.
     */
    public function search(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'query' => 'required|string|min:2',
        ]);

        $query = $validated['query'];

        $courses = Course::where('is_published', true)
            ->where(function ($q) use ($query) {
                $q->where('title_ar', 'like', "%{$query}%")
                  ->orWhere('description_ar', 'like', "%{$query}%")
                  ->orWhere('instructor_name', 'like', "%{$query}%")
                  ->orWhereJsonContains('tags', $query);
            })
            ->with(['subject'])
            ->withCount(['modules as modules_count' => function ($q) {
                $q->where('is_published', true);
            }])
            ->limit(20)
            ->get();

        return response()->json([
            'success' => true,
            'data' => CourseListResource::collection($courses),
        ]);
    }
}
