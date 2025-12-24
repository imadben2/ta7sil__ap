<?php

namespace App\Providers;

use Illuminate\Foundation\Support\Providers\EventServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Event;

// Events
use App\Events\StudySessionCreated;
use App\Events\ExamScheduleCreated;
use App\Events\AchievementUnlocked;
use App\Events\CourseUpdated;
use App\Events\BacSimulationCompleted;

// Listeners
use App\Listeners\ScheduleStudySessionReminder;
use App\Listeners\ScheduleExamAlerts;
use App\Listeners\SendAchievementNotification;
use App\Listeners\SendCourseUpdateNotification;
use App\Listeners\UpdatePlannerAfterSimulation;

class EventServiceProvider extends ServiceProvider
{
    /**
     * The event to listener mappings for the application.
     *
     * @var array<class-string, array<int, class-string>>
     */
    protected $listen = [
        StudySessionCreated::class => [
            ScheduleStudySessionReminder::class,
        ],
        ExamScheduleCreated::class => [
            ScheduleExamAlerts::class,
        ],
        AchievementUnlocked::class => [
            SendAchievementNotification::class,
        ],
        CourseUpdated::class => [
            SendCourseUpdateNotification::class,
        ],
        BacSimulationCompleted::class => [
            UpdatePlannerAfterSimulation::class,
        ],
    ];

    /**
     * Register any events for your application.
     */
    public function boot(): void
    {
        //
    }

    /**
     * Determine if events and listeners should be automatically discovered.
     */
    public function shouldDiscoverEvents(): bool
    {
        return false;
    }
}
