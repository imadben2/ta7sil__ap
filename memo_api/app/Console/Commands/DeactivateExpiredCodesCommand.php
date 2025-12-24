<?php

namespace App\Console\Commands;

use App\Services\CodeGenerationService;
use Illuminate\Console\Command;

class DeactivateExpiredCodesCommand extends Command
{
    protected $signature = 'codes:deactivate-expired';
    protected $description = 'Deactivate subscription codes that have expired';

    protected CodeGenerationService $codeService;

    public function __construct(CodeGenerationService $codeService)
    {
        parent::__construct();
        $this->codeService = $codeService;
    }

    public function handle()
    {
        $this->info('Checking for expired subscription codes...');

        $deactivatedCount = $this->codeService->deactivateExpiredCodes();

        if ($deactivatedCount > 0) {
            $this->info("✓ {$deactivatedCount} code(s) have been deactivated.");
        } else {
            $this->info('No expired codes to deactivate.');
        }

        return Command::SUCCESS;
    }
}
