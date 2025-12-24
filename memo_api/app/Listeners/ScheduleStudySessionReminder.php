<?php

namespace App\Listeners;

use App\Events\StudySessionCreated;
use App\Services\NotificationService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Support\Facades\Log;

class ScheduleStudySessionReminder implements ShouldQueue
{
    /**
     * The notification service instance.
     */
    protected NotificationService $notificationService;

    /**
     * Create the event listener.
     */
    public function __construct(NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    /**
     * Handle the event.
     */
    public function handle(StudySessionCreated $event): void
    {
        try {
            $notification = $this->notificationService->scheduleStudyReminder($event->session);

            if ($notification) {
                Log::info("Scheduled study reminder for session {$event->session->id}");
            }
        } catch (\Exception $e) {
            Log::error("Failed to schedule study reminder", [
                'session_id' => $event->session->id,
                'error' => $e->getMessage(),
            ]);
        }
    }
}
