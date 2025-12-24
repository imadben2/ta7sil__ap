<?php

namespace App\Jobs;

use App\Services\ReportGenerationService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Log;

class GenerateMonthlyReportsJob implements ShouldQueue
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
        Log::info('Generating monthly reports for all users...');

        $generated = $reportService->generateMonthlySummariesForAll();

        Log::info("Generated {$generated} monthly reports");
    }
}
