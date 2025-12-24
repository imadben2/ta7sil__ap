<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Course;
use App\Models\CourseReview;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class ReviewApiController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth:sanctum')->except(['index', 'courseReviews']);
    }

    /**
     * Get all approved reviews
     * GET /api/reviews
     */
    public function index(Request $request): JsonResponse
    {
        $query = CourseReview::where('is_approved', true)
            ->with(['user', 'course']);

        // Filter by course
        if ($request->filled('course_id')) {
            $query->where('course_id', $request->course_id);
        }

        // Filter by rating
        if ($request->filled('rating')) {
            $query->where('rating', $request->rating);
        }

        // Sorting
        $sortBy = $request->get('sort_by', 'created_at');
        $sortOrder = $request->get('sort_order', 'desc');
        $query->orderBy($sortBy, $sortOrder);

        $perPage = $request->get('per_page', 20);
        $reviews = $query->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $reviews,
        ]);
    }

    /**
     * Get reviews for a specific course
     * GET /api/courses/{id}/reviews
     */
    public function courseReviews($courseId): JsonResponse
    {
        $course = Course::findOrFail($courseId);

        $reviews = CourseReview::where('course_id', $course->id)
            ->where('is_approved', true)
            ->with(['user'])
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        // Calculate rating distribution
        $ratingDistribution = [
            '5' => CourseReview::where('course_id', $course->id)->where('is_approved', true)->where('rating', 5)->count(),
            '4' => CourseReview::where('course_id', $course->id)->where('is_approved', true)->where('rating', 4)->count(),
            '3' => CourseReview::where('course_id', $course->id)->where('is_approved', true)->where('rating', 3)->count(),
            '2' => CourseReview::where('course_id', $course->id)->where('is_approved', true)->where('rating', 2)->count(),
            '1' => CourseReview::where('course_id', $course->id)->where('is_approved', true)->where('rating', 1)->count(),
        ];

        return response()->json([
            'success' => true,
            'data' => [
                'reviews' => $reviews,
                'rating_distribution' => $ratingDistribution,
                'average_rating' => $course->average_rating,
                'total_reviews' => $course->total_reviews,
            ],
        ]);
    }

    /**
     * Submit a review for a course
     * POST /api/courses/{id}/review
     */
    public function store(Request $request, $courseId): JsonResponse
    {
        $validated = $request->validate([
            'rating' => 'required|integer|min:1|max:5',
            'review_text_ar' => 'required|string|min:10|max:1000',
        ]);

        $user = $request->user();
        $course = Course::findOrFail($courseId);

        // Check if user has already reviewed this course
        $existingReview = CourseReview::where('user_id', $user->id)
            ->where('course_id', $course->id)
            ->first();

        if ($existingReview) {
            return response()->json([
                'success' => false,
                'message' => 'لقد قمت بتقييم هذه الدورة مسبقاً',
            ], 400);
        }

        // Check if user has access to the course
        $hasAccess = \App\Models\UserSubscription::where('user_id', $user->id)
            ->where('course_id', $course->id)
            ->where('is_active', true)
            ->where('expires_at', '>', now())
            ->exists();

        if (!$hasAccess && !$course->is_free) {
            return response()->json([
                'success' => false,
                'message' => 'يجب الاشتراك في الدورة أولاً لتتمكن من تقييمها',
            ], 403);
        }

        try {
            $review = CourseReview::create([
                'user_id' => $user->id,
                'course_id' => $course->id,
                'rating' => $validated['rating'],
                'review_text_ar' => $validated['review_text_ar'],
                'is_approved' => false, // Requires admin approval
            ]);

            return response()->json([
                'success' => true,
                'message' => 'تم إرسال تقييمك بنجاح، سيظهر بعد مراجعة الإدارة',
                'data' => $review,
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء إرسال التقييم: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Update user's review
     * PUT /api/reviews/{id}
     */
    public function update(Request $request, $id): JsonResponse
    {
        $validated = $request->validate([
            'rating' => 'required|integer|min:1|max:5',
            'review_text_ar' => 'required|string|min:10|max:1000',
        ]);

        $user = $request->user();
        $review = CourseReview::where('user_id', $user->id)
            ->where('id', $id)
            ->firstOrFail();

        try {
            $review->update([
                'rating' => $validated['rating'],
                'review_text_ar' => $validated['review_text_ar'],
                'is_approved' => false, // Requires re-approval after edit
            ]);

            return response()->json([
                'success' => true,
                'message' => 'تم تحديث تقييمك بنجاح، سيظهر بعد مراجعة الإدارة',
                'data' => $review,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء تحديث التقييم: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Delete user's review
     * DELETE /api/reviews/{id}
     */
    public function destroy(Request $request, $id): JsonResponse
    {
        $user = $request->user();
        $review = CourseReview::where('user_id', $user->id)
            ->where('id', $id)
            ->firstOrFail();

        try {
            $course = $review->course;
            $review->delete();
            $course->updateStatistics();

            return response()->json([
                'success' => true,
                'message' => 'تم حذف تقييمك بنجاح',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء حذف التقييم: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get user's reviews
     * GET /api/my-reviews
     */
    public function myReviews(Request $request): JsonResponse
    {
        $user = $request->user();

        $reviews = CourseReview::where('user_id', $user->id)
            ->with(['course'])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $reviews,
        ]);
    }

    /**
     * Check if user can review a course
     * GET /api/courses/{id}/can-review
     */
    public function canReview(Request $request, $courseId): JsonResponse
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'success' => true,
                'can_review' => false,
                'reason' => 'يجب تسجيل الدخول',
            ]);
        }

        $course = Course::findOrFail($courseId);

        // Check if already reviewed
        $hasReviewed = CourseReview::where('user_id', $user->id)
            ->where('course_id', $course->id)
            ->exists();

        if ($hasReviewed) {
            return response()->json([
                'success' => true,
                'can_review' => false,
                'reason' => 'لقد قمت بتقييم هذه الدورة مسبقاً',
            ]);
        }

        // Check if has access
        $hasAccess = \App\Models\UserSubscription::where('user_id', $user->id)
            ->where('course_id', $course->id)
            ->where('is_active', true)
            ->where('expires_at', '>', now())
            ->exists();

        if (!$hasAccess && !$course->is_free) {
            return response()->json([
                'success' => true,
                'can_review' => false,
                'reason' => 'يجب الاشتراك في الدورة أولاً',
            ]);
        }

        return response()->json([
            'success' => true,
            'can_review' => true,
        ]);
    }
}
