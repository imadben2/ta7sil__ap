<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;
use App\Jobs\RecalculatePrioritiesJob;
use App\Jobs\CheckMissedSessionsJob;
use App\Jobs\AdaptSchedulesJob;
use App\Jobs\ProcessDueNotificationsJob;
use App\Jobs\SendDailySummaryJob;
use App\Jobs\SendWeeklySummaryJob;
use App\Jobs\SendExamAlertsJob;
use App\Jobs\CheckUpcomingSessionsJob;
use App\Jobs\GenerateWeeklyReportsJob;
use App\Jobs\GenerateMonthlyReportsJob;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Schedule planner tasks
Schedule::job(new RecalculatePrioritiesJob())
    ->daily()
    ->at('06:00')
    ->name('recalculate-priorities')
    ->description('Recalculate subject priorities for all users');

Schedule::job(new CheckMissedSessionsJob())
    ->hourly()
    ->name('check-missed-sessions')
    ->description('Check and mark missed study sessions');

Schedule::job(new AdaptSchedulesJob())
    ->daily()
    ->at('02:00')
    ->name('adapt-schedules')
    ->description('Adapt schedules based on user behavior patterns');

// Paid Courses Automation
Schedule::command('subscriptions:expire')
    ->daily()
    ->at('00:30')
    ->name('expire-subscriptions')
    ->description('Expire subscriptions that have passed their expiration date');

Schedule::command('codes:deactivate-expired')
    ->daily()
    ->at('01:00')
    ->name('deactivate-expired-codes')
    ->description('Deactivate expired subscription codes');

Schedule::command('courses:update-statistics')
    ->weekly()
    ->sundays()
    ->at('03:00')
    ->name('update-course-statistics')
    ->description('Update course statistics (modules, lessons, reviews, ratings)');

Schedule::command('subscriptions:check-expiring')
    ->daily()
    ->at('09:00')
    ->name('check-expiring-subscriptions')
    ->description('Check for subscriptions expiring soon and send notifications');

// Notification System
Schedule::job(new ProcessDueNotificationsJob())
    ->everyFiveMinutes()
    ->name('process-due-notifications')
    ->description('Process and send due notifications');

Schedule::job(new CheckUpcomingSessionsJob())
    ->everyFiveMinutes()
    ->name('check-upcoming-sessions')
    ->description('Check for upcoming study sessions and schedule reminders');

Schedule::job(new SendExamAlertsJob())
    ->hourly()
    ->name('send-exam-alerts')
    ->description('Check for upcoming exams and schedule alert notifications');

Schedule::job(new SendDailySummaryJob())
    ->daily()
    ->at('21:00')
    ->name('send-daily-summaries')
    ->description('Send daily summary notifications to all users');

Schedule::job(new SendWeeklySummaryJob())
    ->weekly()
    ->sundays()
    ->at('20:00')
    ->name('send-weekly-summaries')
    ->description('Send weekly summary notifications to all users');

// Analytics Reports
Schedule::job(new GenerateWeeklyReportsJob())
    ->weekly()
    ->sundays()
    ->at('21:00')
    ->name('generate-weekly-reports')
    ->description('Generate weekly analytics reports for all users');

Schedule::job(new GenerateMonthlyReportsJob())
    ->monthly()
    ->at('01:00')
    ->name('generate-monthly-reports')
    ->description('Generate monthly analytics reports for all users');
