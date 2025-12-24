<?php

namespace App\Jobs\Planner;

use App\Models\User;
use App\Services\SessionService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

/**
 * Check Missed Sessions Job
 *
 * Runs hourly to check for sessions that were scheduled but not started.
 * Automatically marks them as 'missed' for accurate statistics.
 *
 * A session is considered missed if:
 * - Status is still 'scheduled'
 * - Scheduled end time has passed
 * - Session was not started by the user
 */
class CheckMissedSessionsJob implements ShouldQueue
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
    public $timeout = 180;

    /**
     * Execute the job.
     *
     * @return void
     */
    public function handle(SessionService $sessionService)
    {
        Log::info('Starting missed sessions check job');

        try {
            // Get all active users
            $users = User::where('is_active', true)->get();

            $totalUsers = $users->count();
            $totalMissed = 0;

            foreach ($users as $user) {
                try {
                    // Check and mark missed sessions for this user
                    $missedCount = $sessionService->checkAndMarkMissedSessions($user);

                    if ($missedCount > 0) {
                        Log::info("Marked {$missedCount} sessions as missed for user {$user->id}", [
                            'user_id' => $user->id,
                            'missed_count' => $missedCount,
                        ]);

                        $totalMissed += $missedCount;
                    }

                } catch (\Exception $e) {
                    Log::error("Failed to check missed sessions for user {$user->id}", [
                        'user_id' => $user->id,
                        'error' => $e->getMessage(),
                    ]);
                }
            }

            Log::info('Missed sessions check job completed', [
                'total_users' => $totalUsers,
                'total_sessions_marked_missed' => $totalMissed,
            ]);

        } catch (\Exception $e) {
            Log::error('Missed sessions check job failed', [
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
        Log::error('Missed sessions check job failed permanently', [
            'error' => $exception->getMessage(),
        ]);
    }
}
