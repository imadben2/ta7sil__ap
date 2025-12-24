<?php

namespace App\Listeners;

use App\Events\ExamScheduleCreated;
use App\Services\NotificationService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Support\Facades\Log;

class ScheduleExamAlerts implements ShouldQueue
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
    public function handle(ExamScheduleCreated $event): void
    {
        try {
            $notifications = $this->notificationService->scheduleExamAlerts($event->exam);

            Log::info("Scheduled exam alerts for exam {$event->exam->id}", [
                'notifications_count' => count($notifications),
            ]);
        } catch (\Exception $e) {
            Log::error("Failed to schedule exam alerts", [
                'exam_id' => $event->exam->id,
                'error' => $e->getMessage(),
            ]);
        }
    }
}
