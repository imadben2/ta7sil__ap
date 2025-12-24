<?php

namespace App\Jobs;

use App\Models\User;
use App\Services\NotificationService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Log;

class SendDailySummaryJob implements ShouldQueue
{
    use Queueable;

    /**
     * The number of times the job may be attempted.
     */
    public int $tries = 3;

    /**
     * The number of seconds to wait before retrying the job.
     */
    public int $backoff = 60;

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
        Log::info('Starting daily summary notifications...');

        $sent = 0;
        $failed = 0;

        // Get all active users who have daily_summary enabled
        $users = User::where('is_active', true)
            ->whereHas('notificationSettings', function ($query) {
                $query->where('daily_summary', true)
                    ->where('notifications_enabled', true);
            })
            ->with('notificationSettings')
            ->cursor();

        foreach ($users as $user) {
            try {
                // Check if user is not in quiet hours
                if ($user->notificationSettings && $user->notificationSettings->isInQuietHours()) {
                    continue;
                }

                $notification = $notificationService->sendDailySummary($user);

                if ($notification) {
                    $sent++;
                }
            } catch (\Exception $e) {
                $failed++;
                Log::error("Failed to send daily summary to user {$user->id}", [
                    'error' => $e->getMessage(),
                ]);
            }
        }

        Log::info("Daily summary notifications completed", [
            'sent' => $sent,
            'failed' => $failed,
        ]);
    }
}
