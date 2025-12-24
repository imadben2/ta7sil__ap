<?php

namespace App\Console\Commands;

use App\Models\User;
use App\Models\AcademicStream;
use App\Services\QuizImportService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\File;

class ImportQuizFromWord extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'quiz:import
                            {path? : Path to .docx file or folder containing .docx files}
                            {--user-id=1 : User ID of the creator}
                            {--stream= : Academic stream ID or slug (default: sciences-exp for 3AS Scientific)}
                            {--all : Process all .docx files in the quiz folder}
                            {--preview : Preview what will be imported without actually importing}
                            {--create-chapters : Create chapters if they do not exist}
                            {--quiz-per-subject : Create one quiz per subject instead of per lesson}
                            {--difficulty=medium : Difficulty level (easy, medium, hard)}
                            {--publish : Publish quizzes immediately after import}
                            {--use-tables : Use table extraction method (recommended for structured documents)}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Import quizzes from Word document(s) (.docx) with table structure support';

    protected QuizImportService $importService;

    public function __construct(QuizImportService $importService)
    {
        parent::__construct();
        $this->importService = $importService;
    }

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        // Determine path
        $path = $this->argument('path');
        if ($this->option('all') || empty($path)) {
            $path = base_path('../quiz');
        }

        $userId = (int) $this->option('user-id');
        $preview = $this->option('preview');
        $useTables = $this->option('use-tables');

        // Validate user exists
        $creator = User::find($userId);
        if (!$creator) {
            $this->error("User with ID {$userId} not found.");
            return Command::FAILURE;
        }

        // Resolve academic stream
        $streamId = $this->resolveStreamId($this->option('stream'));

        // Get list of files to process
        $files = $this->getFilesToProcess($path);

        if (empty($files)) {
            $this->error("No .docx files found at: {$path}");
            return Command::FAILURE;
        }

        $this->info("Found " . count($files) . " Word document(s) to process:");
        foreach ($files as $file) {
            $this->line("  - " . basename($file));
        }
        $this->newLine();

        // Show stream info
        if ($streamId) {
            $stream = AcademicStream::find($streamId);
            if ($stream) {
                $this->info("Target stream: {$stream->name_ar} (ID: {$streamId})");
            }
        } else {
            $this->warn("No academic stream specified. Quizzes will be available to all streams.");
        }
        $this->newLine();

        if ($preview) {
            return $this->previewImport($files, $useTables);
        }

        return $this->executeImport($files, $creator, $streamId, $useTables);
    }

    /**
     * Resolve stream ID from option
     */
    protected function resolveStreamId(?string $streamOption): ?int
    {
        if (empty($streamOption)) {
            // Default to علوم تجريبية (sciences-exp) if available
            $stream = AcademicStream::where('slug', 'sciences-exp')
                ->orWhere('slug', 'LIKE', '%علوم تجريبية%')
                ->first();

            return $stream?->id;
        }

        // Try as ID first
        if (is_numeric($streamOption)) {
            $exists = AcademicStream::where('id', (int) $streamOption)->exists();
            return $exists ? (int) $streamOption : null;
        }

        // Try as slug
        $stream = AcademicStream::where('slug', $streamOption)->first();
        return $stream?->id;
    }

    /**
     * Get list of .docx files to process
     */
    protected function getFilesToProcess(string $path): array
    {
        // Normalize path
        $path = str_replace(['/', '\\'], DIRECTORY_SEPARATOR, $path);

        if (is_file($path)) {
            if (str_ends_with(strtolower($path), '.docx')) {
                return [$path];
            }
            $this->warn("File is not a .docx file: {$path}");
            return [];
        }

        if (is_dir($path)) {
            $files = File::glob($path . DIRECTORY_SEPARATOR . '*.docx');
            return $files;
        }

        // Try as relative path from base
        $absolutePath = base_path($path);
        if (is_file($absolutePath) && str_ends_with(strtolower($absolutePath), '.docx')) {
            return [$absolutePath];
        }

        if (is_dir($absolutePath)) {
            return File::glob($absolutePath . DIRECTORY_SEPARATOR . '*.docx');
        }

        return [];
    }

    /**
     * Preview import without executing
     */
    protected function previewImport(array $files, bool $useTables): int
    {
        $this->info("=== PREVIEW MODE ===");
        if ($useTables) {
            $this->info("Using TABLE extraction method");
        }
        $this->newLine();

        $totalSubjects = 0;
        $totalLessons = 0;
        $totalQuestions = 0;

        foreach ($files as $file) {
            $this->info("📄 File: " . basename($file));
            $this->line(str_repeat('-', 50));

            try {
                $preview = $useTables
                    ? $this->importService->previewImportWithTables($file)
                    : $this->importService->previewImport($file);

                $this->line("Title: {$preview['title']}");
                $this->line("Subjects: {$preview['total_subjects']}");
                $this->line("Lessons: {$preview['total_lessons']}");
                $this->line("Questions: {$preview['total_questions']}");
                $this->newLine();

                foreach ($preview['subjects'] as $subject) {
                    $matchStatus = $subject['matched_subject']
                        ? "✅ Matched to: {$subject['matched_subject']['name']} (ID: {$subject['matched_subject']['id']})"
                        : "⚠️ No match found";

                    $this->line("  📚 {$subject['name']}");
                    $this->line("     {$matchStatus}");

                    foreach ($subject['lessons'] as $lesson) {
                        $this->line("     📖 {$lesson['name']} ({$lesson['questions_count']} questions)");

                        // Show sample questions
                        if (!empty($lesson['questions'])) {
                            $samples = array_slice($lesson['questions'], 0, 2);
                            foreach ($samples as $sample) {
                                $this->line("        • [{$sample['type']}] {$sample['text']}");
                            }
                            if (count($lesson['questions']) > 2) {
                                $this->line("        ... and " . (count($lesson['questions']) - 2) . " more");
                            }
                        }
                    }
                    $this->newLine();
                }

                $totalSubjects += $preview['total_subjects'];
                $totalLessons += $preview['total_lessons'];
                $totalQuestions += $preview['total_questions'];

            } catch (\Exception $e) {
                $this->error("Error processing file: {$e->getMessage()}");
            }

            $this->newLine();
        }

        $this->info("=== SUMMARY ===");
        $this->table(
            ['Metric', 'Count'],
            [
                ['Files', count($files)],
                ['Subjects', $totalSubjects],
                ['Lessons', $totalLessons],
                ['Questions', $totalQuestions],
            ]
        );

        return Command::SUCCESS;
    }

    /**
     * Execute the import
     */
    protected function executeImport(array $files, User $creator, ?int $streamId, bool $useTables): int
    {
        $options = [
            'create_subjects' => false,
            'create_chapters' => $this->option('create-chapters'),
            'quiz_per_lesson' => !$this->option('quiz-per-subject'),
            'difficulty_level' => $this->option('difficulty'),
            'quiz_type' => 'practice',
            'is_published' => $this->option('publish'),
            'academic_stream_id' => $streamId,
        ];

        $this->info("Import options:");
        $this->line("  - Create chapters: " . ($options['create_chapters'] ? 'Yes' : 'No'));
        $this->line("  - Quiz grouping: " . ($options['quiz_per_lesson'] ? 'Per lesson' : 'Per subject'));
        $this->line("  - Difficulty: {$options['difficulty_level']}");
        $this->line("  - Auto-publish: " . ($options['is_published'] ? 'Yes' : 'No'));
        $this->line("  - Academic stream ID: " . ($streamId ?? 'None'));
        $this->line("  - Creator: {$creator->name} (ID: {$creator->id})");
        $this->line("  - Parsing method: " . ($useTables ? 'Table extraction' : 'Text-based'));
        $this->newLine();

        if (!$this->confirm('Proceed with import?', true)) {
            $this->info('Import cancelled.');
            return Command::SUCCESS;
        }

        $totalQuizzesCreated = 0;
        $totalQuestionsCreated = 0;
        $allErrors = [];
        $allWarnings = [];

        $this->output->progressStart(count($files));

        foreach ($files as $file) {
            try {
                $result = $useTables
                    ? $this->importService->importFromWordWithTables($file, $creator, $options)
                    : $this->importService->importFromWord($file, $creator, $options);

                $totalQuizzesCreated += $result['quizzes_created'];
                $totalQuestionsCreated += $result['questions_created'];

                if (!empty($result['errors'])) {
                    $allErrors[basename($file)] = $result['errors'];
                }

                if (!empty($result['warnings'])) {
                    $allWarnings[basename($file)] = $result['warnings'];
                }

            } catch (\Exception $e) {
                $allErrors[basename($file)] = [$e->getMessage()];
            }

            $this->output->progressAdvance();
        }

        $this->output->progressFinish();
        $this->newLine();

        // Display results
        $this->info("=== IMPORT COMPLETE ===");
        $this->table(
            ['Metric', 'Count'],
            [
                ['Files processed', count($files)],
                ['Quizzes created', $totalQuizzesCreated],
                ['Questions created', $totalQuestionsCreated],
            ]
        );

        // Display warnings
        if (!empty($allWarnings)) {
            $this->newLine();
            $this->warn("Warnings:");
            foreach ($allWarnings as $file => $warnings) {
                $this->line("  {$file}:");
                foreach ($warnings as $warning) {
                    $this->line("    ⚠️ {$warning}");
                }
            }
        }

        // Display errors
        if (!empty($allErrors)) {
            $this->newLine();
            $this->error("Errors:");
            foreach ($allErrors as $file => $errors) {
                $this->line("  {$file}:");
                foreach ($errors as $error) {
                    $this->line("    ❌ {$error}");
                }
            }
            return Command::FAILURE;
        }

        return Command::SUCCESS;
    }
}
