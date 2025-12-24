<?php

namespace App\Console\Commands;

use App\Models\User;
use App\Models\Quiz;
use App\Models\QuizQuestion;
use App\Models\Subject;
use App\Models\ContentChapter;
use App\Models\AcademicStream;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class ImportQuizFromMarkdown extends Command
{
    protected $signature = 'quiz:import-md
                            {path : Path to .md file}
                            {--user-id=1 : User ID of the creator}
                            {--subject= : Subject name in Arabic (e.g., التاريخ والجغرافيا)}
                            {--all-streams : Make quiz available to all streams (no stream restriction)}
                            {--preview : Preview what will be imported without actually importing}
                            {--publish : Publish quizzes immediately after import}
                            {--difficulty=medium : Difficulty level (easy, medium, hard)}
                            {--questions-per-quiz=20 : Number of questions per quiz}';

    protected $description = 'Import quizzes from markdown (.md) file with Question/Answer format';

    public function handle(): int
    {
        $path = $this->argument('path');
        $userId = (int) $this->option('user-id');
        $preview = $this->option('preview');
        $subjectName = $this->option('subject');
        $allStreams = $this->option('all-streams');
        $questionsPerQuiz = (int) $this->option('questions-per-quiz');

        // Validate file exists
        if (!file_exists($path)) {
            $this->error("File not found: {$path}");
            return Command::FAILURE;
        }

        // Validate user exists
        $creator = User::find($userId);
        if (!$creator) {
            $this->error("User with ID {$userId} not found.");
            return Command::FAILURE;
        }

        // Read and parse the markdown file
        $content = file_get_contents($path);
        $questions = $this->parseMarkdownQuestions($content);

        if (empty($questions)) {
            $this->error("No questions found in the file.");
            return Command::FAILURE;
        }

        $this->info("Found " . count($questions) . " questions in the file.");

        // Detect or use provided subject
        $subject = null;
        if ($subjectName) {
            $subject = $this->findSubject($subjectName);
        } else {
            // Try to auto-detect from content
            $subject = $this->detectSubjectFromContent($content);
        }

        if (!$subject) {
            $this->error("Could not find subject. Please specify with --subject option.");
            $this->line("Available subjects:");
            Subject::all()->each(fn($s) => $this->line("  - {$s->name_ar}"));
            return Command::FAILURE;
        }

        $this->info("Subject: {$subject->name_ar} (ID: {$subject->id})");

        if ($preview) {
            return $this->previewImport($questions, $subject, $questionsPerQuiz);
        }

        return $this->executeImport($questions, $subject, $creator, $allStreams, $questionsPerQuiz);
    }

    /**
     * Parse markdown questions in both English and Arabic formats
     */
    protected function parseMarkdownQuestions(string $content): array
    {
        $questions = [];

        // Split by question markers (Question X: or السؤال X)
        // Support both English and Arabic formats
        $pattern = '/(?:Question\s*(\d+)\s*:|السؤال\s*(\d+))/u';

        $parts = preg_split($pattern, $content, -1, PREG_SPLIT_DELIM_CAPTURE | PREG_SPLIT_NO_EMPTY);

        $i = 0;
        while ($i < count($parts)) {
            // Skip numeric parts (question numbers)
            if (is_numeric(trim($parts[$i]))) {
                $i++;
                continue;
            }

            $questionContent = trim($parts[$i]);
            if (empty($questionContent)) {
                $i++;
                continue;
            }

            $question = $this->parseQuestionBlock($questionContent);
            if ($question) {
                $questions[] = $question;
            }

            $i++;
        }

        return $questions;
    }

    /**
     * Parse a single question block
     */
    protected function parseQuestionBlock(string $content): ?array
    {
        $lines = array_filter(array_map('trim', explode("\n", $content)));
        $lines = array_values($lines);

        if (empty($lines)) {
            return null;
        }

        // First line(s) until we hit an option is the question text
        $questionText = '';
        $options = [];
        $correctAnswer = null;
        $optionIndex = 0;

        foreach ($lines as $line) {
            // Skip separator lines
            if (preg_match('/^[_\-=]{3,}$/', $line)) {
                continue;
            }

            // Check for correct answer line (English or Arabic)
            if (preg_match('/^(?:Correct answer|الإجابة الصحيحة)\s*:\s*([A-Da-d])/ui', $line, $match)) {
                $correctAnswer = strtoupper($match[1]);
                continue;
            }

            // Check for option line (A), B), C), D) or A. B. C. D.)
            if (preg_match('/^([A-Da-d])[\)\.]\s*(.+)$/u', $line, $match)) {
                $optionLetter = strtoupper($match[1]);
                $optionText = trim($match[2]);

                $options[] = [
                    'letter' => $optionLetter,
                    'text' => $optionText,
                    'is_correct' => false, // Will be set later
                ];
                continue;
            }

            // Otherwise it's part of the question text
            if (empty($options)) {
                $questionText .= ($questionText ? ' ' : '') . $line;
            }
        }

        // Clean up question text
        $questionText = trim($questionText);

        // If no question text or options, skip
        if (empty($questionText) || count($options) < 2) {
            return null;
        }

        // Set correct answer
        if ($correctAnswer) {
            foreach ($options as &$option) {
                if ($option['letter'] === $correctAnswer) {
                    $option['is_correct'] = true;
                }
            }
            unset($option); // CRITICAL: break reference to avoid PHP foreach bug
        }

        // Check if we have at least one correct answer
        $hasCorrect = false;
        foreach ($options as $opt) {
            if ($opt['is_correct']) {
                $hasCorrect = true;
                break;
            }
        }

        if (!$hasCorrect) {
            return null;
        }

        return [
            'question_text' => $questionText,
            'options' => $options,
            'question_type' => 'mcq_single',
        ];
    }

    /**
     * Find subject by Arabic name
     */
    protected function findSubject(string $name): ?Subject
    {
        $name = trim($name);

        // Direct match
        $subject = Subject::where('name_ar', $name)->first();
        if ($subject) {
            return $subject;
        }

        // Partial match
        $subject = Subject::where('name_ar', 'LIKE', "%{$name}%")->first();
        if ($subject) {
            return $subject;
        }

        // Common variations mapping
        $mappings = [
            'جغرافيا' => ['التاريخ والجغرافيا', 'تاريخ وجغرافيا', 'جغرافيا'],
            'تاريخ' => ['التاريخ والجغرافيا', 'تاريخ وجغرافيا', 'تاريخ'],
            'التاريخ والجغرافيا' => ['التاريخ والجغرافيا', 'تاريخ وجغرافيا'],
        ];

        foreach ($mappings as $key => $variations) {
            if ($name === $key || in_array($name, $variations)) {
                foreach ($variations as $searchTerm) {
                    $subject = Subject::where('name_ar', 'LIKE', "%{$searchTerm}%")->first();
                    if ($subject) {
                        return $subject;
                    }
                }
            }
        }

        return null;
    }

    /**
     * Detect subject from content keywords
     */
    protected function detectSubjectFromContent(string $content): ?Subject
    {
        $subjectKeywords = [
            'التاريخ والجغرافيا' => ['التقدم', 'التخلف', 'المبادلات', 'الاقتصاد', 'الولايات المتحدة', 'الاتحاد الأوروبي', 'آسيا', 'الشمال', 'الجنوب'],
            'العلوم الطبيعية' => ['الخلية', 'ADN', 'ARN', 'البروتين', 'الترجمة', 'الاستنساخ', 'المناعة'],
            'الفيزياء' => ['الطاقة', 'القوة', 'التيار', 'الموجات', 'النواة'],
            'الرياضيات' => ['الدالة', 'المشتقة', 'التكامل', 'المتتالية', 'الأعداد المركبة'],
            'اللغة العربية' => ['الإعراب', 'البلاغة', 'النحو', 'الصرف', 'الأدب'],
            'الفلسفة' => ['الإنسان', 'الوعي', 'الحرية', 'الأخلاق', 'المعرفة'],
        ];

        $scores = [];
        foreach ($subjectKeywords as $subject => $keywords) {
            $scores[$subject] = 0;
            foreach ($keywords as $keyword) {
                if (mb_stripos($content, $keyword) !== false) {
                    $scores[$subject]++;
                }
            }
        }

        arsort($scores);
        $topSubject = array_key_first($scores);

        if ($scores[$topSubject] >= 3) {
            return $this->findSubject($topSubject);
        }

        return null;
    }

    /**
     * Preview import without executing
     */
    protected function previewImport(array $questions, Subject $subject, int $questionsPerQuiz): int
    {
        $this->info("=== PREVIEW MODE ===");
        $this->newLine();

        $quizCount = ceil(count($questions) / $questionsPerQuiz);

        $this->table(
            ['Metric', 'Value'],
            [
                ['Subject', $subject->name_ar],
                ['Total Questions', count($questions)],
                ['Questions per Quiz', $questionsPerQuiz],
                ['Quizzes to Create', $quizCount],
            ]
        );

        $this->newLine();
        $this->info("Sample Questions:");

        foreach (array_slice($questions, 0, 5) as $i => $q) {
            $this->line("  " . ($i + 1) . ". " . mb_substr($q['question_text'], 0, 80) . "...");
            $this->line("     Options: " . count($q['options']));
            $correctLetter = '';
            foreach ($q['options'] as $opt) {
                if ($opt['is_correct']) {
                    $correctLetter = $opt['letter'];
                    break;
                }
            }
            $this->line("     Correct: {$correctLetter}");
        }

        if (count($questions) > 5) {
            $this->line("  ... and " . (count($questions) - 5) . " more questions");
        }

        return Command::SUCCESS;
    }

    /**
     * Execute the import
     */
    protected function executeImport(array $questions, Subject $subject, User $creator, bool $allStreams, int $questionsPerQuiz): int
    {
        $options = [
            'difficulty_level' => $this->option('difficulty'),
            'is_published' => $this->option('publish'),
        ];

        $this->info("Import Configuration:");
        $this->line("  - Subject: {$subject->name_ar}");
        $this->line("  - Questions per Quiz: {$questionsPerQuiz}");
        $this->line("  - Difficulty: {$options['difficulty_level']}");
        $this->line("  - Auto-publish: " . ($options['is_published'] ? 'Yes' : 'No'));
        $this->line("  - Available to: " . ($allStreams ? 'All streams' : 'Specific stream'));
        $this->line("  - Creator: {$creator->name} (ID: {$creator->id})");
        $this->newLine();

        if (!$this->confirm('Proceed with import?', true)) {
            $this->info('Import cancelled.');
            return Command::SUCCESS;
        }

        DB::beginTransaction();

        try {
            $quizzes = [];
            $questionChunks = array_chunk($questions, $questionsPerQuiz);

            $this->output->progressStart(count($questionChunks));

            foreach ($questionChunks as $chunkIndex => $chunk) {
                $quizNumber = $chunkIndex + 1;
                $quizTitle = "{$subject->name_ar} - اختبار {$quizNumber}";

                // Create quiz
                $quiz = Quiz::create([
                    'subject_id' => $subject->id,
                    'academic_stream_id' => $allStreams ? null : null, // null means all streams
                    'chapter_id' => null,
                    'title_ar' => $quizTitle,
                    'slug' => Str::slug($quizTitle . '-' . Str::random(6)),
                    'description_ar' => "اختبار في مادة {$subject->name_ar} - الجزء {$quizNumber}",
                    'quiz_type' => 'practice',
                    'difficulty_level' => $options['difficulty_level'],
                    'shuffle_questions' => true,
                    'shuffle_answers' => true,
                    'show_correct_answers' => true,
                    'allow_review' => true,
                    'is_published' => $options['is_published'],
                    'is_premium' => false,
                    'passing_score' => 50,
                    'time_limit_minutes' => 0,
                    'estimated_duration_minutes' => max(5, count($chunk) * 2),
                    'total_questions' => count($chunk),
                    'total_attempts' => 0,
                    'average_score' => 0,
                    'created_by' => $creator->id,
                ]);

                // Create questions
                $order = 1;
                foreach ($chunk as $q) {
                    // Format options for storage
                    $formattedOptions = [];
                    $correctIndices = [];

                    foreach ($q['options'] as $index => $opt) {
                        $formattedOptions[] = [
                            'text' => $opt['text'],
                            'is_correct' => $opt['is_correct'],
                        ];

                        if ($opt['is_correct']) {
                            $correctIndices[] = $index;
                        }
                    }

                    QuizQuestion::create([
                        'quiz_id' => $quiz->id,
                        'question_type' => $q['question_type'],
                        'question_text_ar' => $q['question_text'],
                        'question_image_url' => null,
                        'options' => $formattedOptions,
                        'correct_answer' => $correctIndices,
                        'points' => 1,
                        'explanation_ar' => null,
                        'difficulty' => $options['difficulty_level'],
                        'tags' => null,
                        'question_order' => $order++,
                    ]);
                }

                $quizzes[] = [
                    'id' => $quiz->id,
                    'title' => $quiz->title_ar,
                    'questions' => count($chunk),
                ];

                $this->output->progressAdvance();
            }

            DB::commit();

            $this->output->progressFinish();
            $this->newLine();

            $this->info("=== IMPORT COMPLETE ===");
            $this->table(
                ['Quiz ID', 'Title', 'Questions'],
                array_map(fn($q) => [$q['id'], $q['title'], $q['questions']], $quizzes)
            );

            $this->newLine();
            $this->info("Total Quizzes Created: " . count($quizzes));
            $this->info("Total Questions Created: " . count($questions));

            return Command::SUCCESS;

        } catch (\Exception $e) {
            DB::rollBack();
            $this->error("Import failed: " . $e->getMessage());
            return Command::FAILURE;
        }
    }
}
