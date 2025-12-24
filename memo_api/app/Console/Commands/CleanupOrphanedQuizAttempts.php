<?php

namespace App\Console\Commands;

use App\Models\QuizAttempt;
use Carbon\Carbon;
use Illuminate\Console\Command;

class CleanupOrphanedQuizAttempts extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'quiz:cleanup-orphaned
                            {--hours=24 : Hours after which incomplete attempts are considered orphaned}
                            {--dry-run : Show what would be abandoned without actually doing it}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Abandon quiz attempts that have been in progress for more than the specified hours (default: 24 hours)';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $hours = (int) $this->option('hours');
        $dryRun = $this->option('dry-run');
        $cutoffTime = Carbon::now()->subHours($hours);

        $this->info("Looking for quiz attempts in progress before: {$cutoffTime->toDateTimeString()}");

        // Find orphaned attempts
        $orphanedAttempts = QuizAttempt::where('status', 'in_progress')
            ->where('started_at', '<', $cutoffTime)
            ->with(['quiz', 'user'])
            ->get();

        if ($orphanedAttempts->isEmpty()) {
            $this->info('No orphaned quiz attempts found.');
            return Command::SUCCESS;
        }

        $count = $orphanedAttempts->count();
        $this->warn("Found {$count} orphaned quiz attempt(s):");

        // Display the orphaned attempts
        $this->table(
            ['ID', 'User', 'Quiz', 'Started At', 'Hours Ago'],
            $orphanedAttempts->map(function ($attempt) {
                return [
                    $attempt->id,
                    $attempt->user->name ?? 'N/A',
                    $attempt->quiz->title_ar ?? 'N/A',
                    $attempt->started_at->toDateTimeString(),
                    $attempt->started_at->diffInHours(Carbon::now()),
                ];
            })
        );

        if ($dryRun) {
            $this->info('DRY RUN: No attempts were actually abandoned.');
            return Command::SUCCESS;
        }

        // Confirm before abandoning
        if (!$this->confirm('Do you want to abandon these attempts?', true)) {
            $this->info('Operation cancelled.');
            return Command::SUCCESS;
        }

        // Abandon the attempts
        $abandonedCount = 0;
        foreach ($orphanedAttempts as $attempt) {
            try {
                $attempt->status = 'abandoned';
                $attempt->completed_at = Carbon::now();
                $attempt->save();
                $abandonedCount++;

                $this->info("Abandoned attempt #{$attempt->id} for user: {$attempt->user->name}");
            } catch (\Exception $e) {
                $this->error("Failed to abandon attempt #{$attempt->id}: {$e->getMessage()}");
            }
        }

        $this->info("Successfully abandoned {$abandonedCount} out of {$count} orphaned attempt(s).");

        return Command::SUCCESS;
    }
}
