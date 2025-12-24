<?php

namespace App\Jobs;

use App\Models\User;
use App\Services\NotificationService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Log;

class SendWeeklySummariesJob implements ShouldQueue
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
        Log::info('Sending weekly summaries...');

        $users = User::whereHas('notificationSettings', function ($query) {
            $query->where('notifications_enabled', true)
                ->where('weekly_summary', true);
        })->get();

        $sent = 0;
        foreach ($users as $user) {
            if ($notificationService->sendWeeklySummary($user)) {
                $sent++;
            }
        }

        Log::info("Sent {$sent} weekly summary notifications");
    }
}
