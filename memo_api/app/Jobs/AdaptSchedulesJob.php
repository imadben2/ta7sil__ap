<?php

namespace App\Jobs;

use App\Models\User;
use App\Services\AdaptationService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Log;

class AdaptSchedulesJob implements ShouldQueue
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
    public function handle(AdaptationService $adaptationService): void
    {
        try {
            if ($this->userId) {
                // Adapt schedule for specific user
                $user = User::find($this->userId);
                if ($user) {
                    $adaptations = $adaptationService->adaptScheduleForUser($user);
                    if (!empty($adaptations)) {
                        Log::info("Applied adaptations for user {$this->userId}: " . implode(', ', $adaptations));
                    }
                }
            } else {
                // Adapt schedules for all users with active schedules
                $users = User::whereHas('studySchedules', function ($query) {
                    $query->where('status', 'active');
                })->get();

                foreach ($users as $user) {
                    $adaptations = $adaptationService->adaptScheduleForUser($user);
                    if (!empty($adaptations)) {
                        Log::info("Applied adaptations for user {$user->id}: " . implode(', ', $adaptations));
                    }
                }

                Log::info("Processed schedule adaptations for " . $users->count() . " users");
            }
        } catch (\Exception $e) {
            Log::error("Error adapting schedules: " . $e->getMessage());
            throw $e;
        }
    }
}
