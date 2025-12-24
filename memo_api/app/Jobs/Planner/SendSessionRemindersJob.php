<?php

namespace App\Jobs\Planner;

use App\Models\StudySession;
use App\Services\NotificationService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

/**
 * Send Session Reminders Job
 *
 * Runs every 15 minutes to send notifications for upcoming sessions.
 * Sends reminder 15 minutes before session start time.
 *
 * Notification includes:
 * - Subject name
 * - Session type
 * - Duration
 * - Start time
 */
class SendSessionRemindersJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    /**
     * The number of times the job may be attempted.
     *
     * @var int
     */
    public $tries = 2;

    /**
     * The number of seconds the job can run before timing out.
     *
     * @var int
     */
    public $timeout = 120;

    /**
     * Execute the job.
     *
     * @return void
     */
    public function handle(NotificationService $notificationService)
    {
        Log::info('Starting session reminders job');

        try {
            $now = Carbon::now();
            $reminderWindow = 15; // minutes before session

            // Get sessions starting in the next 15-20 minutes that haven't been reminded
            $upcomingSessions = StudySession::where('status', 'scheduled')
                ->whereDate('scheduled_date', $now->toDateString())
                ->where('reminder_sent', false)
                ->get()
                ->filter(function ($session) use ($now, $reminderWindow) {
                    // Parse scheduled start time
                    $scheduledStart = Carbon::parse(
                        $session->scheduled_date->format('Y-m-d') . ' ' . $session->scheduled_start_time
                    );

                    // Check if session starts in 15-20 minutes
                    $minutesUntilStart = $now->diffInMinutes($scheduledStart, false);

                    return $minutesUntilStart >= $reminderWindow &&
                           $minutesUntilStart <= ($reminderWindow + 5);
                });

            $totalSent = 0;

            foreach ($upcomingSessions as $session) {
                try {
                    $scheduledStart = Carbon::parse(
                        $session->scheduled_date->format('Y-m-d') . ' ' . $session->scheduled_start_time
                    );

                    // Send notification
                    $notificationService->sendSessionReminder(
                        $session->user,
                        $session,
                        [
                            'subject_name' => $session->subject->name_ar ?? 'مادة',
                            'session_type' => $this->getSessionTypeAr($session->session_type),
                            'start_time' => $scheduledStart->format('H:i'),
                            'duration' => $session->planned_duration_minutes,
                            'minutes_until_start' => (int) Carbon::now()->diffInMinutes($scheduledStart, false),
                        ]
                    );

                    // Mark as reminded
                    $session->update(['reminder_sent' => true]);

                    $totalSent++;

                    Log::info("Sent reminder for session {$session->id}", [
                        'session_id' => $session->id,
                        'user_id' => $session->user_id,
                        'subject' => $session->subject->name_ar ?? 'N/A',
                        'start_time' => $scheduledStart->format('H:i'),
                    ]);

                } catch (\Exception $e) {
                    Log::error("Failed to send reminder for session {$session->id}", [
                        'session_id' => $session->id,
                        'error' => $e->getMessage(),
                    ]);
                }
            }

            Log::info('Session reminders job completed', [
                'total_reminders_sent' => $totalSent,
            ]);

        } catch (\Exception $e) {
            Log::error('Session reminders job failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            throw $e;
        }
    }

    /**
     * Get Arabic translation for session type
     *
     * @param string $type
     * @return string
     */
    private function getSessionTypeAr(string $type): string
    {
        $types = [
            'study' => 'دراسة',
            'revision' => 'مراجعة',
            'practice' => 'تمارين',
            'longRevision' => 'مراجعة عامة',
            'test' => 'اختبار',
        ];

        return $types[$type] ?? 'جلسة دراسية';
    }

    /**
     * Handle a job failure.
     *
     * @param  \Throwable  $exception
     * @return void
     */
    public function failed(\Throwable $exception)
    {
        Log::error('Session reminders job failed permanently', [
            'error' => $exception->getMessage(),
        ]);
    }
}
