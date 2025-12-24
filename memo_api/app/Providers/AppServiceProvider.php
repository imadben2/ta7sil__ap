<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Schema;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Fix for MySQL key length error
        Schema::defaultStringLength(191);

        // Register model observers for cache invalidation
        \App\Models\User::observe(\App\Observers\UserObserver::class);
        \App\Models\Content::observe(\App\Observers\ContentObserver::class);
        \App\Models\Subject::observe(\App\Observers\SubjectObserver::class);
        \App\Models\Course::observe(\App\Observers\CourseObserver::class);
    }
}
