<?php

namespace App\Notifications;

use App\Models\Course;
use App\Models\UserCourseProgress;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class CourseProgressMilestoneNotification extends Notification implements ShouldQueue
{
    use Queueable;

    protected Course $course;
    protected UserCourseProgress $progress;
    protected string $milestone; // '25%', '50%', '75%', '100%'

    public function __construct(Course $course, UserCourseProgress $progress, string $milestone)
    {
        $this->course = $course;
        $this->progress = $progress;
        $this->milestone = $milestone;
    }

    /**
     * Get the notification's delivery channels.
     */
    public function via(object $notifiable): array
    {
        return ['database'];
    }

    /**
     * Get the array representation of the notification.
     */
    public function toArray(object $notifiable): array
    {
        $messages = [
            '25%' => 'أحسنت! أنت في ربع الطريق',
            '50%' => 'رائع! لقد أتممت نصف الدورة',
            '75%' => 'ممتاز! أنت قريب من إتمام الدورة',
            '100%' => 'مبروك! لقد أكملت الدورة بنجاح',
        ];

        return [
            'type' => 'course_progress_milestone',
            'course_id' => $this->course->id,
            'progress_id' => $this->progress->id,
            'milestone' => $this->milestone,
            'completion_percentage' => $this->progress->completion_percentage,
            'title' => $messages[$this->milestone] ?? 'تحديث التقدم',
            'message' => "لقد أتممت {$this->milestone} من دورة {$this->course->title_ar}",
            'action_url' => url('/courses/' . $this->course->id),
        ];
    }
}
