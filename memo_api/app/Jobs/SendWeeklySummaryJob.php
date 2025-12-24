<?php

namespace App\Jobs;

use App\Models\User;
use App\Services\NotificationService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Log;

class SendWeeklySummaryJob implements ShouldQueue
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
        Log::info('Starting weekly summary notifications...');

        $sent = 0;
        $failed = 0;

        // Get all active users who have weekly_summary enabled
        $users = User::where('is_active', true)
            ->whereHas('notificationSettings', function ($query) {
                $query->where('weekly_summary', true)
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

                $notification = $notificationService->sendWeeklySummary($user);

                if ($notification) {
                    $sent++;
                }
            } catch (\Exception $e) {
                $failed++;
                Log::error("Failed to send weekly summary to user {$user->id}", [
                    'error' => $e->getMessage(),
                ]);
            }
        }

        Log::info("Weekly summary notifications completed", [
            'sent' => $sent,
            'failed' => $failed,
        ]);
    }
}
