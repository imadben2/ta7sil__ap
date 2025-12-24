<?php

namespace App\Jobs;

use App\Models\ExamSchedule;
use App\Services\NotificationService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Log;

class SendExamAlertsJob implements ShouldQueue
{
    use Queueable;

    /**
     * The number of times the job may be attempted.
     */
    public int $tries = 3;

    /**
     * The number of seconds to wait before retrying the job.
     */
    public int $backoff = 60;

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
        Log::info('Starting exam alerts check...');

        $alerts = 0;

        // Get upcoming exams in the next 7 days that haven't been completed
        $exams = ExamSchedule::where('is_completed', false)
            ->where('exam_date', '>=', now())
            ->where('exam_date', '<=', now()->addDays(7))
            ->with(['user', 'user.notificationSettings'])
            ->get();

        foreach ($exams as $exam) {
            try {
                $user = $exam->user;

                // Check if user wants exam reminders
                if (!$user->notificationSettings?->shouldReceive('exam_reminder')) {
                    continue;
                }

                $notifications = $notificationService->scheduleExamAlerts($exam);
                $alerts += count($notifications);

            } catch (\Exception $e) {
                Log::error("Failed to schedule exam alert for exam {$exam->id}", [
                    'error' => $e->getMessage(),
                ]);
            }
        }

        Log::info("Exam alerts job completed", [
            'alerts_scheduled' => $alerts,
        ]);
    }
}
