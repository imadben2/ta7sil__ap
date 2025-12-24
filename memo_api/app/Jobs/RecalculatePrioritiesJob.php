<?php

namespace App\Jobs;

use App\Models\User;
use App\Services\PriorityCalculationService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Log;

class RecalculatePrioritiesJob implements ShouldQueue
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
    public function handle(PriorityCalculationService $priorityService): void
    {
        try {
            if ($this->userId) {
                // Recalculate for specific user
                $user = User::find($this->userId);
                if ($user) {
                    $priorityService->calculateAllPriorities($user);
                    Log::info("Recalculated priorities for user {$this->userId}");
                }
            } else {
                // Recalculate for all users with active schedules
                $users = User::whereHas('studySchedules', function ($query) {
                    $query->where('status', 'active');
                })->get();

                foreach ($users as $user) {
                    $priorityService->calculateAllPriorities($user);
                }

                Log::info("Recalculated priorities for " . $users->count() . " users");
            }
        } catch (\Exception $e) {
            Log::error("Error recalculating priorities: " . $e->getMessage());
            throw $e;
        }
    }
}
