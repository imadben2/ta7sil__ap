<?php

namespace App\Jobs;

use App\Models\User;
use App\Services\PlannerService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Carbon\Carbon;

/**
 * Heavy operation: Generate user's study schedule
 * This can take several seconds, so it's queued
 */
class GenerateScheduleJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    /**
     * The number of times the job may be attempted.
     */
    public $tries = 3;

    /**
     * The number of seconds the job can run before timing out.
     */
    public $timeout = 120;

    /**
     * Create a new job instance.
     */
    public function __construct(
        public User $user,
        public Carbon $startDate,
        public Carbon $endDate,
        public array $preferences = []
    ) {
        $this->onQueue('default');
    }

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        try {
            // Generate the schedule using the planner service
            $schedule = PlannerService::generateSchedule(
                $this->user,
                $this->startDate,
                $this->endDate,
                $this->preferences
            );

            // Optionally notify user that schedule is ready
            // TODO: Send notification when notification system is ready
            \Log::info("Schedule generated for user {$this->user->id}");
        } catch (\Exception $e) {
            \Log::error("Failed to generate schedule for user {$this->user->id}: {$e->getMessage()}");
            throw $e;
        }
    }

    /**
     * Handle a job failure.
     */
    public function failed(\Throwable $exception): void
    {
        \Log::error("GenerateScheduleJob failed for user {$this->user->id}: {$exception->getMessage()}");
        // TODO: Notify user of failure
    }
}
