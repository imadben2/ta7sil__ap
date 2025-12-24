<?php

namespace App\Console\Commands;

use App\Models\Notification;
use App\Services\NotificationService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

class ProcessScheduledNotifications extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'notifications:process
                            {--batch-size=100 : Number of notifications to process per batch}
                            {--dry-run : Run without actually sending notifications}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Process and send scheduled notifications that are due';

    /**
     * The notification service instance.
     */
    protected NotificationService $notificationService;

    /**
     * Create a new command instance.
     */
    public function __construct(NotificationService $notificationService)
    {
        parent::__construct();
        $this->notificationService = $notificationService;
    }

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $batchSize = (int) $this->option('batch-size');
        $dryRun = $this->option('dry-run');

        $this->info('Starting to process scheduled notifications...');

        if ($dryRun) {
            $this->warn('Running in dry-run mode. No notifications will be sent.');
        }

        // Get due notifications (scheduled_for <= now and status = pending)
        $dueNotifications = Notification::where('status', 'pending')
            ->where('scheduled_for', '<=', now())
            ->orderBy('scheduled_for', 'asc')
            ->limit($batchSize)
            ->get();

        $total = $dueNotifications->count();

        if ($total === 0) {
            $this->info('No scheduled notifications to process.');
            return Command::SUCCESS;
        }

        $this->info("Found {$total} notifications to process.");

        $sent = 0;
        $failed = 0;
        $skipped = 0;

        $progressBar = $this->output->createProgressBar($total);
        $progressBar->start();

        foreach ($dueNotifications as $notification) {
            try {
                // Check if user has notifications enabled
                $user = $notification->user;

                if (!$user || !$user->is_active) {
                    $notification->update(['status' => 'failed']);
                    $skipped++;
                    $progressBar->advance();
                    continue;
                }

                // Check user notification settings
                $settings = $user->notificationSettings;
                if ($settings && !$settings->notifications_enabled) {
                    // User disabled notifications, mark as sent (respected preference)
                    $notification->markAsSent();
                    $skipped++;
                    $progressBar->advance();
                    continue;
                }

                // Check quiet hours (skip low/normal priority during quiet hours)
                if ($settings && $settings->isInQuietHours() && $notification->priority !== 'high') {
                    // Reschedule to after quiet hours
                    $this->rescheduleAfterQuietHours($notification, $settings);
                    $skipped++;
                    $progressBar->advance();
                    continue;
                }

                if ($dryRun) {
                    $this->line("\n[DRY-RUN] Would send: {$notification->title_ar} to User #{$notification->user_id}");
                    $sent++;
                } else {
                    if ($this->notificationService->sendPushNotification($notification)) {
                        $sent++;
                    } else {
                        $failed++;
                    }
                }
            } catch (\Exception $e) {
                Log::error("Error processing notification {$notification->id}: " . $e->getMessage());
                $notification->markAsFailed();
                $failed++;
            }

            $progressBar->advance();
        }

        $progressBar->finish();
        $this->newLine(2);

        // Summary
        $this->info("Processing complete:");
        $this->line("  - Sent: {$sent}");
        $this->line("  - Failed: {$failed}");
        $this->line("  - Skipped: {$skipped}");

        Log::info("Scheduled notifications processed", [
            'total' => $total,
            'sent' => $sent,
            'failed' => $failed,
            'skipped' => $skipped,
            'dry_run' => $dryRun,
        ]);

        return $failed > 0 ? Command::FAILURE : Command::SUCCESS;
    }

    /**
     * Reschedule notification to after quiet hours end.
     */
    protected function rescheduleAfterQuietHours(Notification $notification, $settings): void
    {
        $quietEnd = $settings->quiet_end_time;

        if ($quietEnd) {
            // Parse quiet end time and set to today or tomorrow
            $endTime = \Carbon\Carbon::parse($quietEnd);

            // If quiet end is earlier than current time (crosses midnight), schedule for tomorrow
            if ($endTime->lt(now()->startOfDay()->addHours($endTime->hour)->addMinutes($endTime->minute))) {
                $newSchedule = now()->addDay()->setTimeFromTimeString($quietEnd);
            } else {
                $newSchedule = now()->setTimeFromTimeString($quietEnd);
            }

            $notification->update(['scheduled_for' => $newSchedule]);

            Log::debug("Rescheduled notification {$notification->id} to {$newSchedule} (after quiet hours)");
        }
    }
}
