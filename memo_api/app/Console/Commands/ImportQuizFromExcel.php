<?php

namespace App\Console\Commands;

use App\Models\User;
use App\Models\Subject;
use App\Models\AcademicStream;
use App\Services\ExcelQuizImportService;
use Illuminate\Console\Command;

class ImportQuizFromExcel extends Command
{
    protected $signature = 'quiz:import-excel
                            {path : Path to .xlsx file}
                            {--subject-id= : Subject ID to import questions under}
                            {--user-id=1 : User ID of the creator}
                            {--stream= : Academic stream ID (leave empty for all streams)}
                            {--preview : Preview what will be imported without actually importing}
                            {--create-chapters : Create chapters for each sheet if they do not exist}
                            {--difficulty=medium : Difficulty level (easy, medium, hard)}
                            {--publish : Publish quizzes immediately after import}
                            {--questions-per-quiz= : Split into multiple quizzes with this many questions each}';

    protected $description = 'Import quizzes from Excel (.xlsx) file with multiple sheets. Each sheet becomes a chapter and quiz.';

    protected ExcelQuizImportService $importService;

    public function __construct(ExcelQuizImportService $importService)
    {
        parent::__construct();
        $this->importService = $importService;
    }

    public function handle(): int
    {
        $path = $this->argument('path');
        $subjectId = $this->option('subject-id');
        $userId = (int) $this->option('user-id');
        $preview = $this->option('preview');

        // Validate file exists
        if (!file_exists($path)) {
            $this->error("الملف غير موجود: {$path}");
            return Command::FAILURE;
        }

        if (!str_ends_with(strtolower($path), '.xlsx')) {
            $this->error("فقط ملفات .xlsx مدعومة.");
            return Command::FAILURE;
        }

        // Validate subject
        if (!$subjectId) {
            $this->error("معرف المادة مطلوب. استخدم --subject-id=63 مثلاً.");
            $this->newLine();
            $this->info("المواد المتاحة:");
            Subject::orderBy('name_ar')->get()->each(fn($s) =>
                $this->line("  [{$s->id}] {$s->name_ar}")
            );
            return Command::FAILURE;
        }

        $subject = Subject::find($subjectId);
        if (!$subject) {
            $this->error("المادة غير موجودة: ID {$subjectId}");
            return Command::FAILURE;
        }

        // Validate user
        $creator = User::find($userId);
        if (!$creator) {
            $this->error("المستخدم غير موجود: ID {$userId}");
            return Command::FAILURE;
        }

        $this->info("=== استيراد الاختبارات من Excel ===");
        $this->newLine();
        $this->line("الملف: {$path}");
        $this->line("المادة: {$subject->name_ar} (ID: {$subject->id})");
        $this->line("المستخدم: {$creator->name} (ID: {$creator->id})");
        $this->newLine();

        if ($preview) {
            return $this->previewImport($path, $subjectId);
        }

        return $this->executeImport($path, $subject, $creator);
    }

    protected function previewImport(string $path, int $subjectId): int
    {
        $this->info("=== وضع المعاينة ===");
        $this->newLine();

        try {
            $preview = $this->importService->previewImport($path, $subjectId);

            if (isset($preview['error'])) {
                $this->error($preview['error']);
                return Command::FAILURE;
            }

            $this->info("المادة: " . ($preview['subject']['name'] ?? 'غير موجودة'));
            $this->info("عدد الأوراق: {$preview['total_sheets']}");
            $this->info("إجمالي الأسئلة: {$preview['total_questions']}");
            $this->newLine();

            foreach ($preview['sheets'] as $sheet) {
                $chapterStatus = isset($sheet['existing_chapter'])
                    ? "موجود (ID: {$sheet['existing_chapter']['id']})"
                    : "سيتم إنشاؤه";

                $quizStatus = isset($sheet['existing_quiz'])
                    ? "موجود (ID: {$sheet['existing_quiz']['id']})"
                    : "سيتم إنشاؤه";

                $this->line("ورقة: {$sheet['name']}");
                $this->line("  الأسئلة: {$sheet['questions_count']}");
                $this->line("  الفصل: {$chapterStatus}");
                $this->line("  الاختبار: {$quizStatus}");

                if (!empty($sheet['sample_questions'])) {
                    $this->line("  أمثلة على الأسئلة:");
                    foreach ($sheet['sample_questions'] as $sample) {
                        $this->line("    - {$sample['text']}");
                    }
                }
                $this->newLine();
            }

            if (!empty($preview['errors'])) {
                $this->warn("أخطاء في التحليل:");
                foreach ($preview['errors'] as $sheetName => $errors) {
                    foreach ($errors as $error) {
                        $this->line("  [{$sheetName}] السطر {$error['row']}: {$error['message']}");
                    }
                }
            }

        } catch (\Exception $e) {
            $this->error("خطأ: " . $e->getMessage());
            return Command::FAILURE;
        }

        return Command::SUCCESS;
    }

    protected function executeImport(string $path, Subject $subject, User $creator): int
    {
        $streamId = $this->resolveStreamId($this->option('stream'));
        $questionsPerQuiz = $this->option('questions-per-quiz') ? (int) $this->option('questions-per-quiz') : null;

        $options = [
            'create_chapters' => $this->option('create-chapters'),
            'difficulty_level' => $this->option('difficulty'),
            'quiz_type' => 'practice',
            'is_published' => $this->option('publish'),
            'academic_stream_id' => $streamId, // null = all streams
            'questions_per_quiz' => $questionsPerQuiz,
        ];

        $this->info("إعدادات الاستيراد:");
        $this->line("  - إنشاء الفصول: " . ($options['create_chapters'] ? 'نعم' : 'لا'));
        $this->line("  - مستوى الصعوبة: {$options['difficulty_level']}");
        $this->line("  - نشر تلقائي: " . ($options['is_published'] ? 'نعم' : 'لا'));
        $this->line("  - الشعبة: " . ($streamId ? "ID {$streamId}" : 'جميع الشعب'));
        $this->line("  - أسئلة لكل اختبار: " . ($questionsPerQuiz ? $questionsPerQuiz : 'الكل في اختبار واحد'));
        $this->newLine();

        if (!$this->confirm('هل تريد المتابعة؟', true)) {
            $this->info('تم إلغاء الاستيراد.');
            return Command::SUCCESS;
        }

        $this->info("جارٍ الاستيراد...");
        $this->newLine();

        try {
            $result = $this->importService->importFromExcel(
                $path,
                $creator,
                $subject->id,
                $options
            );

            if (!$result['success']) {
                $this->error("فشل الاستيراد:");
                foreach ($result['errors'] as $error) {
                    $this->error("  - {$error}");
                }
                return Command::FAILURE;
            }

            // Display warnings
            if (!empty($result['warnings'])) {
                $this->warn("تحذيرات:");
                foreach ($result['warnings'] as $warning) {
                    $this->line("  {$warning}");
                }
                $this->newLine();
            }

            // Display results
            $this->info("=== اكتمل الاستيراد بنجاح ===");
            $this->newLine();

            $this->table(
                ['المقياس', 'العدد'],
                [
                    ['الاختبارات المنشأة', $result['quizzes_created']],
                    ['الأسئلة المنشأة', $result['questions_created']],
                    ['الفصول المنشأة', $result['chapters_created']],
                ]
            );

            $this->newLine();
            $this->info("الاختبارات:");

            $this->table(
                ['ID', 'العنوان', 'الفصل', 'الأسئلة'],
                array_map(fn($q) => [
                    $q['id'],
                    $q['title'],
                    $q['chapter'],
                    $q['questions_count'],
                ], $result['quizzes'])
            );

            return Command::SUCCESS;

        } catch (\Exception $e) {
            $this->error("فشل الاستيراد: " . $e->getMessage());
            return Command::FAILURE;
        }
    }

    protected function resolveStreamId(?string $streamOption): ?int
    {
        if (empty($streamOption)) {
            return null; // null means all streams
        }

        if (is_numeric($streamOption)) {
            return AcademicStream::where('id', (int) $streamOption)->exists()
                ? (int) $streamOption
                : null;
        }

        $stream = AcademicStream::where('slug', $streamOption)->first();
        return $stream?->id;
    }
}
