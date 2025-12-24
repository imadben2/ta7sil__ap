<?php

namespace App\Observers;

use App\Models\Course;
use App\Services\CacheService;

class CourseObserver
{
    /**
     * Handle the Course "saved" event.
     */
    public function saved(Course $course): void
    {
        CacheService::invalidateCourseCache($course->id);
    }

    /**
     * Handle the Course "deleted" event.
     */
    public function deleted(Course $course): void
    {
        CacheService::invalidateCourseCache($course->id);
    }

    /**
     * Handle the Course "restored" event.
     */
    public function restored(Course $course): void
    {
        CacheService::invalidateCourseCache($course->id);
    }
}
