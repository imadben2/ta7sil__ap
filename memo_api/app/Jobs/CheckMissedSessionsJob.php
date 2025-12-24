<?php

namespace App\Jobs;

use App\Models\User;
use App\Services\SessionService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Log;

class CheckMissedSessionsJob implements ShouldQueue
{
    use Queueable;

    protected ?int $userId;

    /**
     * Create a new job instance.
     */
    public function __construct(?int $userId = null)
    {
        $this->userId = $userId;
    }

    /**
     * Execute the job.
     */
    public function handle(SessionService $sessionService): void
    {
        try {
            if ($this->userId) {
                // Check for specific user
                $user = User::find($this->userId);
                if ($user) {
                    $missedCount = $sessionService->checkAndMarkMissedSessions($user);
                    if ($missedCount > 0) {
                        Log::info("Marked {$missedCount} missed sessions for user {$this->userId}");
                    }
                }
            } else {
                // Check for all users with active schedules
                $users = User::whereHas('studySchedules', function ($query) {
                    $query->where('status', 'active');
                })->get();

                $totalMissed = 0;

                foreach ($users as $user) {
                    $missedCount = $sessionService->checkAndMarkMissedSessions($user);
                    $totalMissed += $missedCount;
                }

                if ($totalMissed > 0) {
                    Log::info("Marked {$totalMissed} total missed sessions across " . $users->count() . " users");
                }
            }
        } catch (\Exception $e) {
            Log::error("Error checking missed sessions: " . $e->getMessage());
            throw $e;
        }
    }
}
