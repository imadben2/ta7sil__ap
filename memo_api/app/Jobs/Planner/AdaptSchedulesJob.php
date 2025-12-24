<?php

namespace App\Jobs\Planner;

use App\Models\User;
use App\Services\AdaptationService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

/**
 * Adapt Schedules Job
 *
 * Runs weekly (Sunday at 2 AM) to adapt study schedules based on:
 * - Recent performance trends
 * - Completion rates by subject
 * - Time of day effectiveness
 * - Exam proximity changes
 *
 * This provides intelligent schedule optimization without user intervention.
 */
class AdaptSchedulesJob implements ShouldQueue
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
    public $timeout = 600;

    /**
     * Execute the job.
     *
     * @return void
     */
    public function handle(AdaptationService $adaptationService)
    {
        Log::info('Starting schedule adaptation job');

        try {
            // Get users who have active schedules
            $users = User::whereHas('studySchedule', function ($query) {
                $query->where('is_active', true);
            })->get();

            $totalUsers = $users->count();
            $successCount = 0;
            $failCount = 0;
            $skippedCount = 0;

            foreach ($users as $user) {
                try {
                    // Check if user has enough data for adaptation (at least 7 days of activity)
                    $hasEnoughData = $user->studySessions()
                        ->where('created_at', '>=', Carbon::now()->subDays(7))
                        ->count() >= 5;

                    if (!$hasEnoughData) {
                        Log::info("Skipped adaptation for user {$user->id} - insufficient data", [
                            'user_id' => $user->id,
                        ]);
                        $skippedCount++;
                        continue;
                    }

                    // Trigger adaptation based on weekly performance
                    $result = $adaptationService->adaptScheduleForUser($user, [
                        'trigger' => 'weekly_optimization',
                        'analysis_period' => 'last_7_days',
                    ]);

                    Log::info("Adapted schedule for user {$user->id}", [
                        'user_id' => $user->id,
                        'changes_made' => $result['changes_count'] ?? 0,
                        'improvements' => $result['improvements'] ?? [],
                    ]);

                    $successCount++;

                } catch (\Exception $e) {
                    Log::error("Failed to adapt schedule for user {$user->id}", [
                        'user_id' => $user->id,
                        'error' => $e->getMessage(),
                    ]);
                    $failCount++;
                }
            }

            Log::info('Schedule adaptation job completed', [
                'total_users' => $totalUsers,
                'success' => $successCount,
                'failed' => $failCount,
                'skipped' => $skippedCount,
            ]);

        } catch (\Exception $e) {
            Log::error('Schedule adaptation job failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            throw $e;
        }
    }

    /**
     * Handle a job failure.
     *
     * @param  \Throwable  $exception
     * @return void
     */
    public function failed(\Throwable $exception)
    {
        Log::error('Schedule adaptation job failed permanently', [
            'error' => $exception->getMessage(),
        ]);
    }
}
