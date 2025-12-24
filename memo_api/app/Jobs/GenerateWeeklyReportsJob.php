<?php

namespace App\Jobs;

use App\Services\ReportGenerationService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Log;

class GenerateWeeklyReportsJob implements ShouldQueue
{
    use Queueable;

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
    public function handle(ReportGenerationService $reportService): void
    {
        Log::info('Generating weekly reports for all users...');

        $generated = $reportService->generateWeeklySummariesForAll();

        Log::info("Generated {$generated} weekly reports");
    }
}
