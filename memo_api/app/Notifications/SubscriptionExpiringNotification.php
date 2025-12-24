<?php

namespace App\Notifications;

use App\Models\UserSubscription;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class SubscriptionExpiringNotification extends Notification implements ShouldQueue
{
    use Queueable;

    protected UserSubscription $subscription;
    protected int $daysRemaining;

    public function __construct(UserSubscription $subscription, int $daysRemaining)
    {
        $this->subscription = $subscription;
        $this->daysRemaining = $daysRemaining;
    }

    /**
     * Get the notification's delivery channels.
     */
    public function via(object $notifiable): array
    {
        return ['database', 'mail'];
    }

    /**
     * Get the mail representation of the notification.
     */
    public function toMail(object $notifiable): MailMessage
    {
        $courseName = $this->subscription->course
            ? $this->subscription->course->title_ar
            : $this->subscription->package->name_ar;

        $daysText = $this->daysRemaining === 1 ? 'يوم واحد' : "{$this->daysRemaining} أيام";

        return (new MailMessage)
            ->subject('تنبيه: اشتراكك سينتهي قريباً - ' . $courseName)
            ->greeting('مرحباً ' . $notifiable->full_name_ar)
            ->line("اشتراكك في {$courseName} سينتهي خلال {$daysText}.")
            ->line('تاريخ الانتهاء: ' . $this->subscription->expires_at->format('Y-m-d'))
            ->line('لا تفوت فرصة إكمال دراستك!')
            ->action('أكمل دراستك الآن', url('/courses/' . ($this->subscription->course_id ?? '')))
            ->line('يمكنك تجديد اشتراكك للحصول على وصول مستمر.');
    }

    /**
     * Get the array representation of the notification.
     */
    public function toArray(object $notifiable): array
    {
        $courseName = $this->subscription->course
            ? $this->subscription->course->title_ar
            : $this->subscription->package->name_ar;

        return [
            'type' => 'subscription_expiring',
            'subscription_id' => $this->subscription->id,
            'course_id' => $this->subscription->course_id,
            'package_id' => $this->subscription->package_id,
            'days_remaining' => $this->daysRemaining,
            'expires_at' => $this->subscription->expires_at->toISOString(),
            'title' => 'اشتراكك سينتهي قريباً',
            'message' => "اشتراكك في {$courseName} سينتهي خلال {$this->daysRemaining} يوم",
            'action_url' => url('/courses/' . ($this->subscription->course_id ?? '')),
        ];
    }
}
