<?php

namespace App\Listeners;

use App\Events\CourseUpdated;
use App\Models\UserSubscription;
use App\Services\NotificationService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Support\Facades\Log;

class SendCourseUpdateNotification implements ShouldQueue
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
    public function handle(CourseUpdated $event): void
    {
        try {
            $course = $event->course;

            // Get all users subscribed to this course
            $subscribedUsers = UserSubscription::where('status', 'active')
                ->whereHas('subscriptionPackage', function ($query) use ($course) {
                    $query->whereHas('courses', function ($q) use ($course) {
                        $q->where('courses.id', $course->id);
                    });
                })
                ->with('user')
                ->get()
                ->pluck('user')
                ->filter();

            $sent = 0;

            foreach ($subscribedUsers as $user) {
                $notification = $this->notificationService->sendCourseUpdateNotification(
                    $user,
                    $course->title_ar ?? $course->title,
                    $event->updateType
                );

                if ($notification) {
                    $sent++;
                }
            }

            Log::info("Sent course update notifications for course {$course->id}", [
                'update_type' => $event->updateType,
                'notifications_sent' => $sent,
            ]);

        } catch (\Exception $e) {
            Log::error("Failed to send course update notifications", [
                'course_id' => $event->course->id,
                'update_type' => $event->updateType,
                'error' => $e->getMessage(),
            ]);
        }
    }
}
