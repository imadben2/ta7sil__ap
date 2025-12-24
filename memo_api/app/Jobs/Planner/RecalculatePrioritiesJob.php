<?php

namespace App\Jobs\Planner;

use App\Models\User;
use App\Services\PriorityCalculationService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

/**
 * Recalculate Priorities Job
 *
 * Runs daily at midnight to recalculate subject priorities for all active users.
 * Priority is based on:
 * - Exam proximity (30% weight)
 * - Coefficient/importance (25% weight)
 * - Difficulty level (20% weight)
 * - Last studied date (15% weight)
 * - Recent performance (10% weight)
 */
class RecalculatePrioritiesJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    /**
     * The number of times the job may be attempted.
     *
     * @var int
     */
    public $tries = 3;

    /**
     * The number of seconds the job can run before timing out.
     *
     * @var int
     */
    public $timeout = 300;

    /**
     * Execute the job.
     *
     * @return void
     */
    public function handle(PriorityCalculationService $priorityService)
    {
        Log::info('Starting priority recalculation job');

        try {
            // Get all active users with planner subjects
            $users = User::whereHas('plannerSubjects')
                ->where('is_active', true)
                ->get();

            $totalUsers = $users->count();
            $successCount = 0;
            $failCount = 0;

            foreach ($users as $user) {
                try {
                    // Recalculate priorities for all user's subjects
                    $priorities = $priorityService->recalculateForUser($user);

                    Log::info("Recalculated priorities for user {$user->id}", [
                        'user_id' => $user->id,
                        'subjects_count' => count($priorities),
                    ]);

                    $successCount++;
                } catch (\Exception $e) {
                    Log::error("Failed to recalculate priorities for user {$user->id}", [
                        'user_id' => $user->id,
                        'error' => $e->getMessage(),
                    ]);
                    $failCount++;
                }
            }

            Log::info('Priority recalculation job completed', [
                'total_users' => $totalUsers,
                'success' => $successCount,
                'failed' => $failCount,
            ]);

        } catch (\Exception $e) {
            Log::error('Priority recalculation job failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            throw $e; // Re-throw to mark job as failed
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
        Log::error('Priority recalculation job failed permanently', [
            'error' => $exception->getMessage(),
        ]);
    }
}
