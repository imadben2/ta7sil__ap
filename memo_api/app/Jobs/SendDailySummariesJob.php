<?php

namespace App\Jobs;

use App\Models\User;
use App\Services\NotificationService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Log;

class SendDailySummariesJob implements ShouldQueue
{
    use Queueable;

    /**
     * Create a new job instance.
     */
    public function __construct()
    {
        //
    }

    /**
     * Execute the job.
     */
    public function handle(NotificationService $notificationService): void
    {
        Log::info('Sending daily summaries...');

        $users = User::whereHas('notificationSettings', function ($query) {
            $query->where('notifications_enabled', true)
                ->where('daily_summary', true);
        })->get();

        $sent = 0;
        foreach ($users as $user) {
            if ($notificationService->sendDailySummary($user)) {
                $sent++;
            }
        }

        Log::info("Sent {$sent} daily summary notifications");
    }
}
