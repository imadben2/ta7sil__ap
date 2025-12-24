<?php

namespace App\Notifications;

use App\Models\PaymentReceipt;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class PaymentReceiptStatusNotification extends Notification implements ShouldQueue
{
    use Queueable;

    protected PaymentReceipt $receipt;
    protected string $status;

    public function __construct(PaymentReceipt $receipt, string $status)
    {
        $this->receipt = $receipt;
        $this->status = $status; // 'approved' or 'rejected'
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
        $courseName = $this->receipt->course
            ? $this->receipt->course->title_ar
            : $this->receipt->package->name_ar;

        if ($this->status === 'approved') {
            return (new MailMessage)
                ->subject('تم قبول إيصال الدفع - ' . $courseName)
                ->greeting('مرحباً ' . $notifiable->full_name_ar)
                ->line('تم قبول إيصال الدفع الخاص بك.')
                ->line('الدورة/الباقة: ' . $courseName)
                ->line('المبلغ: ' . number_format($this->receipt->amount_dzd, 2) . ' دج')
                ->line('تم تفعيل اشتراكك ويمكنك الآن الوصول إلى المحتوى.')
                ->action('ابدأ التعلم', url('/courses/' . ($this->receipt->course_id ?? '')))
                ->line('شكراً لك!');
        } else {
            return (new MailMessage)
                ->subject('تم رفض إيصال الدفع - ' . $courseName)
                ->greeting('مرحباً ' . $notifiable->full_name_ar)
                ->line('للأسف، تم رفض إيصال الدفع الخاص بك.')
                ->line('الدورة/الباقة: ' . $courseName)
                ->line('السبب: ' . ($this->receipt->admin_notes ?? 'لم يتم تحديد السبب'))
                ->line('يرجى التواصل معنا أو إعادة إرسال إيصال صحيح.')
                ->action('إعادة الإرسال', url('/payment-receipts/submit'))
                ->line('نعتذر عن الإزعاج.');
        }
    }

    /**
     * Get the array representation of the notification.
     */
    public function toArray(object $notifiable): array
    {
        $courseName = $this->receipt->course
            ? $this->receipt->course->title_ar
            : $this->receipt->package->name_ar;

        return [
            'type' => 'payment_receipt_' . $this->status,
            'receipt_id' => $this->receipt->id,
            'course_id' => $this->receipt->course_id,
            'package_id' => $this->receipt->package_id,
            'status' => $this->status,
            'title' => $this->status === 'approved' ? 'تم قبول إيصال الدفع' : 'تم رفض إيصال الدفع',
            'message' => $this->status === 'approved'
                ? "تم قبول إيصال الدفع للدورة {$courseName}"
                : "تم رفض إيصال الدفع للدورة {$courseName}",
            'amount_dzd' => $this->receipt->amount_dzd,
            'admin_notes' => $this->receipt->admin_notes,
            'action_url' => $this->status === 'approved'
                ? url('/courses/' . ($this->receipt->course_id ?? ''))
                : url('/payment-receipts/submit'),
        ];
    }
}
