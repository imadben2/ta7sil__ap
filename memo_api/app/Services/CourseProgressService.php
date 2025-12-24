<?php

namespace App\Services;

use App\Models\User;
use App\Models\Course;
use App\Models\CourseLesson;
use App\Models\CourseQuiz;
use App\Models\UserCourseProgress;
use App\Models\UserLessonProgress;
use Illuminate\Support\Facades\DB;

class CourseProgressService
{
    /**
     * Update video watch progress
     */
    public function updateVideoProgress(User $user, CourseLesson $lesson, int $positionSeconds): UserLessonProgress
    {
        $progress = UserLessonProgress::firstOrCreate(
            [
                'user_id' => $user->id,
                'course_lesson_id' => $lesson->id,
            ],
            [
                'video_duration_seconds' => $lesson->video_duration_seconds,
                'watch_time_seconds' => 0,
                'is_completed' => false,
            ]
        );

        $progress->updateWatchTime($positionSeconds);

        return $progress;
    }

    /**
     * Mark lesson as completed
     */
    public function markLessonComplete(User $user, CourseLesson $lesson): UserLessonProgress
    {
        $progress = UserLessonProgress::firstOrCreate(
            [
                'user_id' => $user->id,
                'course_lesson_id' => $lesson->id,
            ],
            [
                'video_duration_seconds' => $lesson->video_duration_seconds,
                'watch_time_seconds' => $lesson->video_duration_seconds,
            ]
        );

        if (!$progress->is_completed) {
            $progress->markAsCompleted();
        }

        return $progress;
    }

    /**
     * Mark quiz as completed
     */
    public function markQuizComplete(User $user, CourseQuiz $courseQuiz, int $score): void
    {
        $course = $courseQuiz->module->course;

        $courseProgress = UserCourseProgress::firstOrCreate([
            'user_id' => $user->id,
            'course_id' => $course->id,
        ]);

        $courseProgress->markQuizComplete();
    }

    /**
     * Get user's progress for a course
     */
    public function getCourseProgress(User $user, Course $course): UserCourseProgress
    {
        $progress = UserCourseProgress::firstOrCreate([
            'user_id' => $user->id,
            'course_id' => $course->id,
        ]);

        $progress->updateProgress();

        return $progress;
    }

    /**
     * Get user's progress for a lesson
     */
    public function getLessonProgress(User $user, CourseLesson $lesson): ?UserLessonProgress
    {
        return UserLessonProgress::where('user_id', $user->id)
            ->where('course_lesson_id', $lesson->id)
            ->first();
    }

    /**
     * Get all lesson progress for a course
     */
    public function getCourseLessonsProgress(User $user, Course $course)
    {
        $lessonIds = CourseLesson::whereIn(
            'course_module_id',
            $course->modules()->pluck('id')
        )->pluck('id');

        return UserLessonProgress::where('user_id', $user->id)
            ->whereIn('course_lesson_id', $lessonIds)
            ->with('lesson')
            ->get();
    }

    /**
     * Get completed lessons count for a course
     */
    public function getCompletedLessonsCount(User $user, Course $course): int
    {
        $lessonIds = CourseLesson::whereIn(
            'course_module_id',
            $course->modules()->pluck('id')
        )->pluck('id');

        return UserLessonProgress::where('user_id', $user->id)
            ->whereIn('course_lesson_id', $lessonIds)
            ->where('is_completed', true)
            ->count();
    }

    /**
     * Get user's dashboard statistics
     */
    public function getUserStatistics(User $user): array
    {
        $activeSubscriptions = $user->subscriptions()
            ->where('status', 'active')
            ->count();

        $coursesInProgress = UserCourseProgress::where('user_id', $user->id)
            ->where('status', 'in_progress')
            ->count();

        $completedCourses = UserCourseProgress::where('user_id', $user->id)
            ->where('status', 'completed')
            ->count();

        $totalWatchTime = UserCourseProgress::where('user_id', $user->id)
            ->sum('total_watch_time_minutes');

        $completedLessons = UserLessonProgress::where('user_id', $user->id)
            ->where('is_completed', true)
            ->count();

        return [
            'active_subscriptions' => $activeSubscriptions,
            'courses_in_progress' => $coursesInProgress,
            'completed_courses' => $completedCourses,
            'total_watch_time_minutes' => $totalWatchTime,
            'completed_lessons' => $completedLessons,
        ];
    }

    /**
     * Get user's recent activity
     */
    public function getUserRecentActivity(User $user, int $limit = 10)
    {
        return UserLessonProgress::where('user_id', $user->id)
            ->whereNotNull('last_watched_at')
            ->with(['lesson.module.course'])
            ->orderBy('last_watched_at', 'desc')
            ->limit($limit)
            ->get();
    }

    /**
     * Get next lesson to watch for a course
     */
    public function getNextLesson(User $user, Course $course): ?CourseLesson
    {
        // Get all lessons in course ordered by module order and lesson order
        $lessons = CourseLesson::whereIn(
            'course_module_id',
            $course->modules()->orderBy('order')->pluck('id')
        )->orderBy('order')->get();

        // Get completed lesson IDs
        $completedLessonIds = UserLessonProgress::where('user_id', $user->id)
            ->where('is_completed', true)
            ->pluck('course_lesson_id')
            ->toArray();

        // Find first incomplete lesson
        foreach ($lessons as $lesson) {
            if (!in_array($lesson->id, $completedLessonIds)) {
                return $lesson;
            }
        }

        return null; // All lessons completed
    }

    /**
     * Get course completion certificate data
     */
    public function getCertificateData(User $user, Course $course): ?array
    {
        $progress = UserCourseProgress::where('user_id', $user->id)
            ->where('course_id', $course->id)
            ->first();

        if (!$progress || !$progress->isCompleted()) {
            return null;
        }

        return [
            'user_name' => $user->name,
            'course_title' => $course->title_ar,
            'completion_date' => $progress->completed_at->format('Y-m-d'),
            'completion_date_ar' => $progress->completed_at->locale('ar')->translatedFormat('j F Y'),
            'total_watch_time' => $progress->getFormattedWatchTime(),
            'instructor_name' => $course->instructor_name,
            'progress_percentage' => $progress->progress_percentage,
        ];
    }

    /**
     * Reset course progress (admin function)
     */
    public function resetCourseProgress(User $user, Course $course): void
    {
        DB::transaction(function () use ($user, $course) {
            // Delete course progress
            UserCourseProgress::where('user_id', $user->id)
                ->where('course_id', $course->id)
                ->delete();

            // Delete lesson progress
            $lessonIds = CourseLesson::whereIn(
                'course_module_id',
                $course->modules()->pluck('id')
            )->pluck('id');

            UserLessonProgress::where('user_id', $user->id)
                ->whereIn('course_lesson_id', $lessonIds)
                ->delete();
        });
    }

    /**
     * Calculate course completion rate
     */
    public function getCourseCompletionRate(Course $course): float
    {
        $totalEnrollments = UserCourseProgress::where('course_id', $course->id)->count();

        if ($totalEnrollments === 0) {
            return 0;
        }

        $completedEnrollments = UserCourseProgress::where('course_id', $course->id)
            ->where('status', 'completed')
            ->count();

        return ($completedEnrollments / $totalEnrollments) * 100;
    }

    /**
     * Get course engagement statistics
     */
    public function getCourseEngagementStats(Course $course): array
    {
        $totalEnrollments = UserCourseProgress::where('course_id', $course->id)->count();
        $activeStudents = UserCourseProgress::where('course_id', $course->id)
            ->where('status', 'in_progress')
            ->count();
        $completedStudents = UserCourseProgress::where('course_id', $course->id)
            ->where('status', 'completed')
            ->count();

        $averageProgress = UserCourseProgress::where('course_id', $course->id)
            ->avg('progress_percentage') ?? 0;

        $totalWatchTime = UserCourseProgress::where('course_id', $course->id)
            ->sum('total_watch_time_minutes');

        $averageWatchTime = $totalEnrollments > 0 ? $totalWatchTime / $totalEnrollments : 0;

        return [
            'total_enrollments' => $totalEnrollments,
            'active_students' => $activeStudents,
            'completed_students' => $completedStudents,
            'completion_rate' => $this->getCourseCompletionRate($course),
            'average_progress' => round($averageProgress, 2),
            'total_watch_time_hours' => round($totalWatchTime / 60, 2),
            'average_watch_time_hours' => round($averageWatchTime / 60, 2),
        ];
    }

    /**
     * Get most active students for a course
     */
    public function getMostActiveStudents(Course $course, int $limit = 10)
    {
        return UserCourseProgress::where('course_id', $course->id)
            ->with('user')
            ->orderBy('progress_percentage', 'desc')
            ->orderBy('total_watch_time_minutes', 'desc')
            ->limit($limit)
            ->get();
    }
}
