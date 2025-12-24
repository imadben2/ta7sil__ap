<?php

namespace App\Observers;

use App\Models\User;
use App\Services\CacheService;

class UserObserver
{
    /**
     * Handle the User "updated" event.
     */
    public function updated(User $user): void
    {
        CacheService::invalidateUserCache($user->id);
        CacheService::invalidateDashboardStats();
    }

    /**
     * Handle the User "deleted" event.
     */
    public function deleted(User $user): void
    {
        CacheService::invalidateUserCache($user->id);
        CacheService::invalidateDashboardStats();
    }

    /**
     * Handle the User "restored" event.
     */
    public function restored(User $user): void
    {
        CacheService::invalidateUserCache($user->id);
        CacheService::invalidateDashboardStats();
    }
}
