<?php

namespace App\Jobs;

use App\Models\StudySession;
use App\Services\NotificationService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Log;

class CheckUpcomingSessionsJob implements ShouldQueue
{
    use Queueable;

    /**
     * The number of times the job may be attempted.
     */
    public int $tries = 3;

    /**
     * The number of seconds to wait before retrying the job.
     */
    public int $backoff = 30;

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
        Log::info('Checking for upcoming study sessions...');

        $reminders = 0;

        // Find sessions starting in the next 15-20 minutes that haven't been reminded
        $upcomingSessions = StudySession::where('status', 'scheduled')
            ->whereBetween('scheduled_start_time', [
                now()->addMinutes(14),
                now()->addMinutes(20),
            ])
            ->whereDate('scheduled_date', today())
            ->whereDoesntHave('notifications', function ($query) {
                $query->where('type', 'study_reminder');
            })
            ->with(['user', 'user.notificationSettings', 'subject'])
            ->get();

        foreach ($upcomingSessions as $session) {
            try {
                $user = $session->user;

                // Check if user wants study reminders
                if (!$user->notificationSettings?->shouldReceive('study_reminder')) {
                    continue;
                }

                $notification = $notificationService->scheduleStudyReminder($session);

                if ($notification) {
                    $reminders++;
                }

            } catch (\Exception $e) {
                Log::error("Failed to schedule study reminder for session {$session->id}", [
                    'error' => $e->getMessage(),
                ]);
            }
        }

        Log::info("Upcoming sessions check completed", [
            'reminders_scheduled' => $reminders,
        ]);
    }
}
