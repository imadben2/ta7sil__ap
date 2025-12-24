<?php

namespace App\Observers;

use App\Models\Subject;
use App\Services\CacheService;

class SubjectObserver
{
    /**
     * Handle the Subject "saved" event.
     */
    public function saved(Subject $subject): void
    {
        CacheService::invalidateSubjectCache($subject->id);
        CacheService::invalidateDashboardStats();
    }

    /**
     * Handle the Subject "deleted" event.
     */
    public function deleted(Subject $subject): void
    {
        CacheService::invalidateSubjectCache($subject->id);
        CacheService::invalidateDashboardStats();
    }

    /**
     * Handle the Subject "restored" event.
     */
    public function restored(Subject $subject): void
    {
        CacheService::invalidateSubjectCache($subject->id);
        CacheService::invalidateDashboardStats();
    }
}
