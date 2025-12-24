<?php

namespace App\Notifications;

use App\Models\UserSubscription;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class SubscriptionActivatedNotification extends Notification implements ShouldQueue
{
    use Queueable;

    protected UserSubscription $subscription;

    public function __construct(UserSubscription $subscription)
    {
        $this->subscription = $subscription;
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

        $type = $this->subscription->course ? 'الدورة' : 'الباقة';

        return (new MailMessage)
            ->subject('تم تفعيل اشتراكك - ' . $courseName)
            ->greeting('مرحباً ' . $notifiable->full_name_ar)
            ->line("تم تفعيل اشتراكك في {$type}: {$courseName}")
            ->line('تاريخ بداية الاشتراك: ' . $this->subscription->starts_at->format('Y-m-d'))
            ->line('تاريخ انتهاء الاشتراك: ' . $this->subscription->expires_at->format('Y-m-d'))
            ->action('ابدأ التعلم الآن', url('/courses/' . ($this->subscription->course_id ?? '')))
            ->line('نتمنى لك تجربة تعليمية مميزة!');
    }

    /**
     * Get the array representation of the notification.
     */
    public function toArray(object $notifiable): array
    {
        $courseName = $this->subscription->course
            ? $this->subscription->course->title_ar
            : $this->subscription->package->name_ar;

        $type = $this->subscription->course ? 'course' : 'package';

        return [
            'type' => 'subscription_activated',
            'subscription_id' => $this->subscription->id,
            'subscription_type' => $type,
            'course_id' => $this->subscription->course_id,
            'package_id' => $this->subscription->package_id,
            'title' => 'تم تفعيل اشتراكك',
            'message' => "تم تفعيل اشتراكك في {$courseName}",
            'starts_at' => $this->subscription->starts_at->toISOString(),
            'expires_at' => $this->subscription->expires_at->toISOString(),
            'action_url' => url('/courses/' . ($this->subscription->course_id ?? '')),
        ];
    }
}
