<?php

namespace App\Listeners;

use App\Events\AchievementUnlocked;
use App\Services\NotificationService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Support\Facades\Log;

class SendAchievementNotification implements ShouldQueue
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
    public function handle(AchievementUnlocked $event): void
    {
        try {
            $notification = $this->notificationService->sendAchievementNotification(
                $event->user,
                $event->achievementType,
                $event->data
            );

            if ($notification) {
                Log::info("Sent achievement notification to user {$event->user->id}", [
                    'achievement_type' => $event->achievementType,
                ]);
            }
        } catch (\Exception $e) {
            Log::error("Failed to send achievement notification", [
                'user_id' => $event->user->id,
                'achievement_type' => $event->achievementType,
                'error' => $e->getMessage(),
            ]);
        }
    }
}
