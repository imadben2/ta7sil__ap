<?php

namespace App\Providers;

use App\Models\PlannerSchedule;
use App\Models\PlannerStudySession;
use App\Models\PlannerExam;
use App\Models\PlannerSubject;
use App\Policies\PlannerSchedulePolicy;
use App\Policies\PlannerStudySessionPolicy;
use App\Policies\PlannerExamPolicy;
use App\Policies\PlannerSubjectPolicy;
use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Gate;

class AuthServiceProvider extends ServiceProvider
{
    /**
     * The model to policy mappings for the application.
     *
     * @var array<class-string, class-string>
     */
    protected $policies = [
        PlannerSchedule::class => PlannerSchedulePolicy::class,
        PlannerStudySession::class => PlannerStudySessionPolicy::class,
        PlannerExam::class => PlannerExamPolicy::class,
        PlannerSubject::class => PlannerSubjectPolicy::class,
    ];

    /**
     * Register services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        $this->registerPolicies();

        // Additional gates can be defined here if needed
        // Example:
        // Gate::define('manage-planner', function ($user) {
        //     return $user->hasPermission('manage-planner');
        // });
    }
}
