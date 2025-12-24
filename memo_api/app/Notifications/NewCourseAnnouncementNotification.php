<?php

namespace App\Notifications;

use App\Models\Course;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class NewCourseAnnouncementNotification extends Notification implements ShouldQueue
{
    use Queueable;

    protected Course $course;

    public function __construct(Course $course)
    {
        $this->course = $course;
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
        return (new MailMessage)
            ->subject('دورة جديدة متاحة الآن - ' . $this->course->title_ar)
            ->greeting('مرحباً ' . $notifiable->full_name_ar)
            ->line('تم نشر دورة جديدة قد تهمك!')
            ->line('الدورة: ' . $this->course->title_ar)
            ->line('المدرب: ' . $this->course->instructor_name)
            ->line('المستوى: ' . $this->course->level)
            ->line($this->course->short_description_ar)
            ->action('اكتشف المزيد', url('/courses/' . $this->course->id))
            ->line('ابدأ رحلتك التعليمية اليوم!');
    }

    /**
     * Get the array representation of the notification.
     */
    public function toArray(object $notifiable): array
    {
        return [
            'type' => 'new_course_announcement',
            'course_id' => $this->course->id,
            'title' => 'دورة جديدة متاحة',
            'message' => "تم نشر دورة جديدة: {$this->course->title_ar}",
            'course_title' => $this->course->title_ar,
            'instructor_name' => $this->course->instructor_name,
            'level' => $this->course->level,
            'thumbnail_url' => $this->course->thumbnail_url,
            'price_dzd' => $this->course->price_dzd,
            'is_free' => $this->course->is_free,
            'action_url' => url('/courses/' . $this->course->id),
        ];
    }
}
