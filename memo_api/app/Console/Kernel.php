<?php

namespace App\Console;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;
use App\Jobs\Planner\RecalculatePrioritiesJob;
use App\Jobs\Planner\CheckMissedSessionsJob;
use App\Jobs\Planner\AdaptSchedulesJob;
use App\Jobs\Planner\SendSessionRemindersJob;

class Kernel extends ConsoleKernel
{
    /**
     * Define the application's command schedule.
     *
     * @param  \Illuminate\Console\Scheduling\Schedule  $schedule
     * @return void
     */
    protected function schedule(Schedule $schedule)
    {
        // ===================================
        // PLANNER AUTOMATION JOBS
        // ===================================

        // Recalculate subject priorities daily at midnight
        // Ensures priorities stay updated based on exam proximity and performance
        $schedule->job(new RecalculatePrioritiesJob())
            ->daily()
            ->at('00:00')
            ->name('planner.recalculate-priorities')
            ->withoutOverlapping()
            ->runInBackground();

        // Check for missed sessions every hour
        // Marks sessions that weren't started as 'missed' for accurate statistics
        $schedule->job(new CheckMissedSessionsJob())
            ->hourly()
            ->name('planner.check-missed-sessions')
            ->withoutOverlapping()
            ->runInBackground();

        // Adapt study schedules weekly (Sunday at 2 AM)
        // Intelligently adjusts schedules based on performance trends
        $schedule->job(new AdaptSchedulesJob())
            ->weekly()
            ->sundays()
            ->at('02:00')
            ->name('planner.adapt-schedules')
            ->withoutOverlapping()
            ->runInBackground();

        // Send session reminders every 15 minutes
        // Notifies users 15 minutes before upcoming sessions
        $schedule->job(new SendSessionRemindersJob())
            ->everyFifteenMinutes()
            ->name('planner.send-reminders')
            ->withoutOverlapping()
            ->runInBackground();

        // ===================================
        // QUIZ SYSTEM AUTOMATION
        // ===================================

        // Cleanup orphaned quiz attempts every hour
        // Abandons quiz attempts that have been in progress for more than 24 hours
        $schedule->command('quiz:cleanup-orphaned --hours=24')
            ->hourly()
            ->name('quiz.cleanup-orphaned-attempts')
            ->withoutOverlapping()
            ->runInBackground();

        // ===================================
        // NOTIFICATION SYSTEM
        // ===================================

        // Process scheduled notifications every minute
        // Sends notifications that are due based on scheduled_for timestamp
        $schedule->command('notifications:process --batch-size=100')
            ->everyMinute()
            ->name('notifications.process-scheduled')
            ->withoutOverlapping()
            ->runInBackground();

        // Send daily summary notifications at 21:00
        // Sends study progress summary to users who have it enabled
        $schedule->job(new \App\Jobs\SendDailySummaryJob())
            ->daily()
            ->at('21:00')
            ->name('notifications.daily-summary')
            ->withoutOverlapping()
            ->runInBackground();

        // Send weekly summary notifications on Sundays at 20:00
        // Sends weekly study recap to users who have it enabled
        $schedule->job(new \App\Jobs\SendWeeklySummaryJob())
            ->weekly()
            ->sundays()
            ->at('20:00')
            ->name('notifications.weekly-summary')
            ->withoutOverlapping()
            ->runInBackground();

        // Send exam alert notifications hourly
        // Checks for upcoming exams and schedules alerts (7d, 3d, 24h, 2h before)
        $schedule->job(new \App\Jobs\SendExamAlertsJob())
            ->hourly()
            ->name('notifications.exam-alerts')
            ->withoutOverlapping()
            ->runInBackground();

        // ===================================
        // OTHER SCHEDULED TASKS
        // ===================================

        // Example: Clear expired cache daily at 3 AM
        // $schedule->command('cache:prune-stale-tags')
        //     ->daily()
        //     ->at('03:00');

        // Example: Generate daily analytics report
        // $schedule->command('analytics:generate-report')
        //     ->daily()
        //     ->at('01:00');

        // Example: Backup database daily at 4 AM
        // $schedule->command('backup:run')
        //     ->daily()
        //     ->at('04:00');
    }

    /**
     * Register the commands for the application.
     *
     * @return void
     */
    protected function commands()
    {
        $this->load(__DIR__.'/Commands');

        require base_path('routes/console.php');
    }
}
