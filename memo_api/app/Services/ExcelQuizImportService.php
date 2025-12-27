<?php

namespace App\Services;

use App\Imports\QuizExcelImport;
use App\Models\Quiz;
use App\Models\QuizQuestion;
use App\Models\Subject;
use App\Models\ContentChapter;
use App\Models\User;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;
use Maatwebsite\Excel\Facades\Excel;

class ExcelQuizImportService
{
    protected QuizService $quizService;

    public function __construct(QuizService $quizService)
    {
        $this->quizService = $quizService;
    }

    /**
     * Import quizzes from Excel file with multiple sheets.
     * Each sheet becomes a separate chapter and quiz.
     * If questions_per_quiz is set, splits into multiple quizzes.
     */
    public function importFromExcel(
        string $filePath,
        User $creator,
        int $subjectId,
        array $options = []
    ): array {
        $options = array_merge([
            'create_chapters' => true,
            'difficulty_level' => 'medium',
            'quiz_type' => 'practice',
            'is_published' => false,
            'academic_stream_id' => null, // null = all streams
            'questions_per_quiz' => null, // null = all questions in one quiz, or number to split
        ], $options);

        $results = [
            'success' => true,
            'quizzes_created' => 0,
            'questions_created' => 0,
            'chapters_created' => 0,
            'quizzes' => [],
            'errors' => [],
            'warnings' => [],
        ];

        // Validate file exists
        if (!file_exists($filePath)) {
            $results['success'] = false;
            $results['errors'][] = "الملف غير موجود: {$filePath}";
            return $results;
        }

        // Validate subject exists
        $subject = Subject::find($subjectId);
        if (!$subject) {
            $results['success'] = false;
            $results['errors'][] = "المادة غير موجودة: ID {$subjectId}";
            return $results;
        }

        // Load and parse Excel file
        $import = new QuizExcelImport($filePath);
        Excel::import($import, $filePath);

        $allQuestions = $import->getAllQuestions();
        $allErrors = $import->getAllErrors();

        // Collect parsing errors as warnings
        foreach ($allErrors as $sheetName => $sheetErrors) {
            foreach ($sheetErrors as $error) {
                $results['warnings'][] = "[{$sheetName}] السطر {$error['row']}: {$error['message']}";
            }
        }

        if (empty($allQuestions)) {
            $results['success'] = false;
            $results['errors'][] = "لم يتم العثور على أي أسئلة صالحة في الملف";
            return $results;
        }

        DB::beginTransaction();

        try {
            foreach ($allQuestions as $sheetName => $questions) {
                if (empty($questions)) {
                    $results['warnings'][] = "الورقة '{$sheetName}' لا تحتوي على أسئلة صالحة.";
                    continue;
                }

                // Create or find chapter for this sheet
                $chapter = null;
                $chapterCreated = false;

                if ($options['create_chapters']) {
                    [$chapter, $chapterCreated] = $this->matchOrCreateChapter($subject, $sheetName, $options);
                    if ($chapterCreated) {
                        $results['chapters_created']++;
                    }
                }

                // Split questions into chunks if questions_per_quiz is set
                $questionsPerQuiz = $options['questions_per_quiz'];
                if ($questionsPerQuiz && $questionsPerQuiz > 0 && count($questions) > $questionsPerQuiz) {
                    $chunks = array_chunk($questions, $questionsPerQuiz);
                    $partNumber = 1;

                    foreach ($chunks as $chunk) {
                        $partTitle = $sheetName . ' - الجزء ' . $partNumber;

                        $quiz = $this->createQuiz(
                            subject: $subject,
                            title: $partTitle,
                            questions: $chunk,
                            creator: $creator,
                            chapter: $chapter,
                            options: $options
                        );

                        $results['quizzes'][] = [
                            'id' => $quiz->id,
                            'title' => $quiz->title_ar,
                            'chapter' => $sheetName,
                            'chapter_id' => $chapter?->id,
                            'questions_count' => count($chunk),
                        ];
                        $results['quizzes_created']++;
                        $results['questions_created'] += count($chunk);
                        $partNumber++;
                    }
                } else {
                    // Create single quiz for this sheet
                    $quiz = $this->createQuiz(
                        subject: $subject,
                        title: $sheetName,
                        questions: $questions,
                        creator: $creator,
                        chapter: $chapter,
                        options: $options
                    );

                    $results['quizzes'][] = [
                        'id' => $quiz->id,
                        'title' => $quiz->title_ar,
                        'chapter' => $sheetName,
                        'chapter_id' => $chapter?->id,
                        'questions_count' => count($questions),
                    ];
                    $results['quizzes_created']++;
                    $results['questions_created'] += count($questions);
                }
            }

            DB::commit();

        } catch (\Exception $e) {
            DB::rollBack();
            $results['success'] = false;
            $results['errors'][] = $e->getMessage();
        }

        return $results;
    }

    /**
     * Preview import without executing.
     */
    public function previewImport(string $filePath, int $subjectId): array
    {
        $subject = Subject::find($subjectId);

        if (!file_exists($filePath)) {
            return [
                'error' => "الملف غير موجود: {$filePath}",
            ];
        }

        $import = new QuizExcelImport($filePath);
        Excel::import($import, $filePath);

        $allQuestions = $import->getAllQuestions();
        $allErrors = $import->getAllErrors();

        $preview = [
            'subject' => $subject ? [
                'id' => $subject->id,
                'name' => $subject->name_ar,
            ] : null,
            'sheets' => [],
            'total_sheets' => count($import->getSheetNames()),
            'total_questions' => 0,
            'errors' => [],
        ];

        foreach ($import->getSheetNames() as $sheetName) {
            $questions = $allQuestions[$sheetName] ?? [];

            $sheetPreview = [
                'name' => $sheetName,
                'questions_count' => count($questions),
                'sample_questions' => array_slice(array_map(fn($q) => [
                    'text' => mb_substr($q['question_text'], 0, 80) . (mb_strlen($q['question_text']) > 80 ? '...' : ''),
                    'options_count' => count($q['options']),
                ], $questions), 0, 3),
            ];

            // Check for existing chapter
            if ($subject) {
                $existingChapter = ContentChapter::where('subject_id', $subject->id)
                    ->where(function ($query) use ($sheetName) {
                        $query->where('title_ar', $sheetName)
                            ->orWhere('title_ar', 'LIKE', "%{$sheetName}%");
                    })
                    ->first();

                $sheetPreview['existing_chapter'] = $existingChapter ? [
                    'id' => $existingChapter->id,
                    'title' => $existingChapter->title_ar,
                ] : null;
            }

            // Check for existing quiz with same title
            $existingQuiz = Quiz::where('subject_id', $subjectId)
                ->where('title_ar', $sheetName)
                ->first();

            $sheetPreview['existing_quiz'] = $existingQuiz ? [
                'id' => $existingQuiz->id,
                'title' => $existingQuiz->title_ar,
            ] : null;

            $preview['sheets'][] = $sheetPreview;
            $preview['total_questions'] += count($questions);
        }

        // Include parsing errors
        foreach ($allErrors as $sheetName => $errors) {
            $preview['errors'][$sheetName] = $errors;
        }

        return $preview;
    }

    /**
     * Match or create chapter for the sheet.
     *
     * @return array [ContentChapter, bool wasCreated]
     */
    protected function matchOrCreateChapter(
        Subject $subject,
        string $sheetName,
        array $options
    ): array {
        // Try exact match first
        $chapter = ContentChapter::where('subject_id', $subject->id)
            ->where('title_ar', $sheetName)
            ->first();

        if ($chapter) {
            return [$chapter, false];
        }

        // Try partial match
        $chapter = ContentChapter::where('subject_id', $subject->id)
            ->where('title_ar', 'LIKE', "%{$sheetName}%")
            ->first();

        if ($chapter) {
            return [$chapter, false];
        }

        // Create new chapter
        $maxOrder = ContentChapter::where('subject_id', $subject->id)->max('order') ?? 0;

        $chapter = ContentChapter::create([
            'subject_id' => $subject->id,
            'academic_stream_id' => $options['academic_stream_id'] ?? null,
            'title_ar' => $sheetName,
            'slug' => Str::slug($sheetName . '-' . Str::random(4)),
            'description_ar' => "فصل: {$sheetName}",
            'order' => $maxOrder + 1,
            'is_active' => true,
        ]);

        return [$chapter, true];
    }

    /**
     * Create a quiz with questions.
     */
    protected function createQuiz(
        Subject $subject,
        string $title,
        array $questions,
        User $creator,
        ?ContentChapter $chapter,
        array $options
    ): Quiz {
        $quizData = [
            'subject_id' => $subject->id,
            'academic_stream_id' => $options['academic_stream_id'] ?? null,
            'chapter_id' => $chapter?->id,
            'title_ar' => $title,
            'slug' => Str::slug($title . '-' . Str::random(6)),
            'description_ar' => "اختبار: {$title}",
            'quiz_type' => $options['quiz_type'],
            'difficulty_level' => $options['difficulty_level'],
            'shuffle_questions' => true,
            'shuffle_answers' => true,
            'show_correct_answers' => true,
            'allow_review' => true,
            'is_published' => $options['is_published'],
            'is_premium' => false,
            'passing_score' => 50,
            'time_limit_minutes' => 0,
            'estimated_duration_minutes' => max(5, count($questions) * 2),
            'total_questions' => count($questions),
            'total_attempts' => 0,
            'average_score' => 0,
            'created_by' => $creator->id,
        ];

        $questionsData = [];
        foreach ($questions as $q) {
            $questionsData[] = [
                'question_type' => $q['question_type'],
                'question_text_ar' => $q['question_text'],
                'question_image_url' => null,
                'options' => $q['options'],
                'correct_answer' => $q['correct_answer'],
                'points' => 1,
                'explanation_ar' => null,
                'difficulty' => $options['difficulty_level'],
                'tags' => null,
            ];
        }

        return $this->quizService->createQuizWithImportedQuestions($quizData, $questionsData);
    }
}
