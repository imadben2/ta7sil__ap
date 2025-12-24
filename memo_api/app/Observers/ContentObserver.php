<?php

namespace App\Observers;

use App\Models\Content;
use App\Services\CacheService;

class ContentObserver
{
    /**
     * Handle the Content "saved" event.
     */
    public function saved(Content $content): void
    {
        CacheService::invalidateContentCache($content->id, $content->subject_id);
        CacheService::invalidateDashboardStats();
    }

    /**
     * Handle the Content "deleted" event.
     */
    public function deleted(Content $content): void
    {
        CacheService::invalidateContentCache($content->id, $content->subject_id);
        CacheService::invalidateDashboardStats();
    }

    /**
     * Handle the Content "restored" event.
     */
    public function restored(Content $content): void
    {
        CacheService::invalidateContentCache($content->id, $content->subject_id);
        CacheService::invalidateDashboardStats();
    }
}
