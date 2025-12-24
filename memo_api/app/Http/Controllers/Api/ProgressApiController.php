<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Course;
use App\Models\CourseLesson;
use App\Services\CourseProgressService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class ProgressApiController extends Controller
{
    protected CourseProgressService $progressService;

    public function __construct(CourseProgressService $progressService)
    {
        $this->progressService = $progressService;
    }

    /**
     * Update video watch progress
     * POST /api/lessons/{id}/progress
     */
    public function updateLessonProgress(Request $request, $id): JsonResponse
    {
        $validated = $request->validate([
            'position_seconds' => 'required|integer|min:0',
        ]);

        $user = $request->user();
        $lesson = CourseLesson::findOrFail($id);

        try {
            $progress = $this->progressService->updateVideoProgress(
                $user,
                $lesson,
                $validated['position_seconds']
            );

            return response()->json([
                'success' => true,
                'message' => 'تم تحديث التقدم بنجاح',
                'data' => $progress,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Mark lesson as completed
     * POST /api/lessons/{id}/complete
     */
    public function completeLesson(Request $request, $id): JsonResponse
    {
        $user = $request->user();
        $lesson = CourseLesson::findOrFail($id);

        try {
            $progress = $this->progressService->markLessonComplete($user, $lesson);

            return response()->json([
                'success' => true,
                'message' => 'تم تحديد الدرس كمكتمل',
                'data' => $progress,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get course progress for user
     * GET /api/courses/{id}/my-progress
     */
    public function courseProgress(Request $request, $id): JsonResponse
    {
        $user = $request->user();
        $course = Course::findOrFail($id);

        try {
            $progress = $this->progressService->getCourseProgress($user, $course);
            $lessonsProgress = $this->progressService->getCourseLessonsProgress($user, $course);

            return response()->json([
                'success' => true,
                'data' => [
                    'course_progress' => $progress,
                    'lessons_progress' => $lessonsProgress,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get user dashboard statistics
     * GET /api/my-stats
     */
    public function myStatistics(Request $request): JsonResponse
    {
        $user = $request->user();

        try {
            $stats = $this->progressService->getUserStatistics($user);

            return response()->json([
                'success' => true,
                'data' => $stats,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get user's recent activity
     * GET /api/my-recent-activity
     */
    public function recentActivity(Request $request): JsonResponse
    {
        $user = $request->user();
        $limit = $request->get('limit', 10);

        try {
            $activity = $this->progressService->getUserRecentActivity($user, $limit);

            return response()->json([
                'success' => true,
                'data' => $activity,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get next lesson to watch
     * GET /api/courses/{id}/next-lesson
     */
    public function nextLesson(Request $request, $id): JsonResponse
    {
        $user = $request->user();
        $course = Course::findOrFail($id);

        try {
            $nextLesson = $this->progressService->getNextLesson($user, $course);

            if (!$nextLesson) {
                return response()->json([
                    'success' => true,
                    'message' => 'تم إكمال جميع الدروس',
                    'data' => null,
                ]);
            }

            return response()->json([
                'success' => true,
                'data' => $nextLesson->load(['module']),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get certificate data if course is completed
     * GET /api/courses/{id}/certificate
     */
    public function certificate(Request $request, $id): JsonResponse
    {
        $user = $request->user();
        $course = Course::findOrFail($id);

        try {
            $certificateData = $this->progressService->getCertificateData($user, $course);

            if (!$certificateData) {
                return response()->json([
                    'success' => false,
                    'message' => 'يجب إكمال الدورة للحصول على الشهادة',
                ], 403);
            }

            return response()->json([
                'success' => true,
                'data' => $certificateData,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get all enrolled courses with progress
     * GET /api/my-courses
     */
    public function myCourses(Request $request): JsonResponse
    {
        $user = $request->user();

        $coursesWithProgress = $user->subscriptions()
            ->where('is_active', true)
            ->where('expires_at', '>', now())
            ->with(['course' => function ($q) {
                $q->with(['subject', 'modules']);
            }])
            ->get()
            ->map(function ($subscription) use ($user) {
                $course = $subscription->course;
                $progress = $this->progressService->getCourseProgress($user, $course);

                return [
                    'subscription' => $subscription,
                    'course' => $course,
                    'progress' => $progress,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $coursesWithProgress,
        ]);
    }

    /**
     * Get lesson progress
     * GET /api/lessons/{id}/my-progress
     */
    public function lessonProgress(Request $request, $id): JsonResponse
    {
        $user = $request->user();
        $lesson = CourseLesson::findOrFail($id);

        $progress = $this->progressService->getLessonProgress($user, $lesson);

        return response()->json([
            'success' => true,
            'data' => $progress,
        ]);
    }
}
