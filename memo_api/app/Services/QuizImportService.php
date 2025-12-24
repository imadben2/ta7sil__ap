<?php

namespace App\Services;

use App\Models\Quiz;
use App\Models\QuizQuestion;
use App\Models\Subject;
use App\Models\ContentChapter;
use App\Models\AcademicStream;
use App\Models\User;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;
use ZipArchive;

class QuizImportService
{
    protected QuizService $quizService;
    protected WordTableParser $tableParser;
    protected QuizTableInterpreter $tableInterpreter;

    public function __construct(QuizService $quizService)
    {
        $this->quizService = $quizService;
        $this->tableParser = new WordTableParser();
        $this->tableInterpreter = new QuizTableInterpreter();
    }

    /**
     * Import quizzes from a Word document (legacy text-based parsing)
     */
    public function importFromWord(string $filePath, User $creator, array $options = []): array
    {
        $options = array_merge([
            'create_subjects' => false,
            'create_chapters' => true,
            'quiz_per_lesson' => true,
            'difficulty_level' => 'medium',
            'quiz_type' => 'practice',
            'is_published' => false,
            'academic_stream_id' => null,
        ], $options);

        $content = $this->parseWordDocument($filePath);
        $quizData = $this->parseQuizStructure($content);
        $results = $this->createQuizzesFromData($quizData, $creator, $options);

        return $results;
    }

    /**
     * Import quizzes from a Word document using TABLE extraction
     *
     * This method properly parses the table structure used in quiz documents:
     * - Tables contain lessons with questions in 6-column format
     * - Subject headers appear as paragraphs between tables
     *
     * @param string $filePath Path to the .docx file
     * @param User $creator User who is importing
     * @param array $options Import options
     * @return array Import results
     */
    public function importFromWordWithTables(string $filePath, User $creator, array $options = []): array
    {
        $options = array_merge([
            'create_subjects' => false,
            'create_chapters' => true,
            'quiz_per_lesson' => true,
            'difficulty_level' => 'medium',
            'quiz_type' => 'practice',
            'is_published' => false,
            'academic_stream_id' => null,
        ], $options);

        // Parse document structure
        $quizData = $this->parseQuizStructureFromTables($filePath);

        // Create quizzes from parsed data
        $results = $this->createQuizzesFromData($quizData, $creator, $options);

        return $results;
    }

    /**
     * Parse quiz structure from Word document tables
     *
     * The document structure is:
     * - Paragraph: "• Subject Name:"
     * - Table: Contains lessons for that subject
     * - Paragraph: "• Next Subject Name:"
     * - Table: Contains lessons for next subject
     * - etc.
     *
     * @param string $filePath Path to .docx file
     * @return array Structured quiz data
     */
    public function parseQuizStructureFromTables(string $filePath): array
    {
        $result = [
            'title' => '',
            'subjects' => [],
        ];

        // Get paragraphs (for subject headers like "• العلوم الطبيعية:")
        $paragraphs = $this->tableParser->getParagraphs($filePath);

        // Get all tables
        $tables = $this->tableParser->parseTables($filePath);

        if (empty($tables)) {
            return $result;
        }

        // Detect subjects from paragraphs
        // These appear as "• Subject Name:" before each table
        $subjectNames = [];
        foreach ($paragraphs as $paragraph) {
            // Look for bullet point pattern: • Subject Name:
            if (preg_match('/[•·]\s*(.+?)\s*:/u', $paragraph, $match)) {
                $subjectName = trim($match[1]);
                // Map to canonical subject name
                $canonicalName = $this->tableInterpreter->detectSubject($subjectName);
                if ($canonicalName) {
                    $subjectNames[] = $canonicalName;
                } elseif (!empty($subjectName)) {
                    // Use original name if no canonical mapping
                    $subjectNames[] = $subjectName;
                }
            }
        }

        // If we have same number of subjects as tables, match them 1:1
        if (count($subjectNames) === count($tables)) {
            foreach ($tables as $tableIndex => $tableRows) {
                if (empty($tableRows)) {
                    continue;
                }

                $subjectName = $subjectNames[$tableIndex];

                // Parse lessons from this table
                $lessons = $this->tableInterpreter->interpretMultipleLessons($tableRows);

                $validLessons = [];
                foreach ($lessons as $lesson) {
                    if (!empty($lesson['questions'])) {
                        $validLessons[] = $lesson;
                    }
                }

                if (!empty($validLessons)) {
                    $result['subjects'][] = [
                        'name' => $subjectName,
                        'lessons' => $validLessons,
                    ];
                }
            }
        } else {
            // Fallback: Try to detect subject from table content
            $currentSubject = null;
            $currentLessons = [];

            foreach ($tables as $tableIndex => $tableRows) {
                if (empty($tableRows)) {
                    continue;
                }

                // Try to detect subject from first row of table
                $firstRowText = implode(' ', $tableRows[0] ?? []);
                $detectedSubject = $this->tableInterpreter->detectSubject($firstRowText);

                if ($detectedSubject && $detectedSubject !== $currentSubject) {
                    // Save previous subject's lessons
                    if ($currentSubject && !empty($currentLessons)) {
                        $result['subjects'][] = [
                            'name' => $currentSubject,
                            'lessons' => $currentLessons,
                        ];
                    }
                    $currentSubject = $detectedSubject;
                    $currentLessons = [];
                }

                // If no subject detected yet, use first from paragraph markers
                if (!$currentSubject && !empty($subjectNames)) {
                    $currentSubject = $subjectNames[0];
                }

                // Parse lessons from this table
                $lessons = $this->tableInterpreter->interpretMultipleLessons($tableRows);

                foreach ($lessons as $lesson) {
                    if (!empty($lesson['questions'])) {
                        $currentLessons[] = $lesson;
                    }
                }
            }

            // Don't forget the last subject
            if ($currentSubject && !empty($currentLessons)) {
                $result['subjects'][] = [
                    'name' => $currentSubject,
                    'lessons' => $currentLessons,
                ];
            }
        }

        return $result;
    }

    /**
     * Preview import using table extraction
     *
     * @param string $filePath Path to .docx file
     * @return array Preview data
     */
    public function previewImportWithTables(string $filePath): array
    {
        $quizData = $this->parseQuizStructureFromTables($filePath);

        $preview = [
            'title' => $quizData['title'] ?? '',
            'subjects' => [],
            'total_subjects' => 0,
            'total_lessons' => 0,
            'total_questions' => 0,
        ];

        foreach ($quizData['subjects'] as $subjectData) {
            $subject = $this->matchSubject($subjectData['name']);

            $subjectPreview = [
                'name' => $subjectData['name'],
                'matched_subject' => $subject ? [
                    'id' => $subject->id,
                    'name' => $subject->name_ar,
                ] : null,
                'lessons' => [],
            ];

            foreach ($subjectData['lessons'] as $lesson) {
                $subjectPreview['lessons'][] = [
                    'name' => $lesson['name'],
                    'questions_count' => count($lesson['questions']),
                    'questions' => array_map(fn($q) => [
                        'text' => mb_substr($q['question_text'], 0, 80) . (mb_strlen($q['question_text']) > 80 ? '...' : ''),
                        'type' => $q['question_type'],
                        'options_count' => count($q['options']),
                        'correct_count' => count($q['correct_answer']),
                    ], $lesson['questions']),
                ];
                $preview['total_questions'] += count($lesson['questions']);
            }

            $preview['total_lessons'] += count($subjectData['lessons']);
            $preview['subjects'][] = $subjectPreview;
        }

        $preview['total_subjects'] = count($quizData['subjects']);

        return $preview;
    }

    /**
     * Parse Word document and extract text content
     */
    public function parseWordDocument(string $filePath): string
    {
        if (!file_exists($filePath)) {
            throw new \Exception("File not found: {$filePath}");
        }

        if (!str_ends_with(strtolower($filePath), '.docx')) {
            throw new \Exception("Only .docx files are supported");
        }

        $zip = new ZipArchive();
        if ($zip->open($filePath) !== true) {
            throw new \Exception("Cannot open Word document");
        }

        $content = $zip->getFromName('word/document.xml');
        $zip->close();

        if ($content === false) {
            throw new \Exception("Cannot read document content");
        }

        $xml = simplexml_load_string($content);
        $xml->registerXPathNamespace('w', 'http://schemas.openxmlformats.org/wordprocessingml/2006/main');

        $texts = [];
        foreach ($xml->xpath('//w:t') as $t) {
            $texts[] = (string)$t;
        }

        return implode(' ', $texts);
    }

    /**
     * Parse quiz structure from content - IMPROVED ALGORITHM
     */
    public function parseQuizStructure(string $content): array
    {
        $result = [
            'title' => '',
            'subjects' => [],
        ];

        // Extract day number if exists (for reference only, not used in title)
        if (preg_match('/(?:Quiz|اليوم|يوم|الاسبوع)\s*(\d+)/u', $content, $matches)) {
            $result['day_number'] = $matches[1];
        }

        // Split by subject markers (• followed by subject name)
        $subjectPattern = '/•\s*(العلوم الطبيعية|التاريخ والجغرافيا|الفرنسية|الرياضيات|الفيزياء|الفلسفة|اللغة العربية|اللغة الإنجليزية|الإسلامية|التربية الإسلامية)[:\s]*/u';
        $parts = preg_split($subjectPattern, $content, -1, PREG_SPLIT_DELIM_CAPTURE);

        for ($i = 1; $i < count($parts); $i += 2) {
            $subjectName = trim($parts[$i]);
            $subjectContent = isset($parts[$i + 1]) ? trim($parts[$i + 1]) : '';

            if (empty($subjectContent)) {
                continue;
            }

            $subject = [
                'name' => $subjectName,
                'lessons' => [],
            ];

            // Parse lessons with their questions
            $lessons = $this->parseLessonsFromContent($subjectContent);

            if (!empty($lessons)) {
                $subject['lessons'] = $lessons;
                $result['subjects'][] = $subject;
            }
        }

        return $result;
    }

    /**
     * Parse lessons and questions from subject content
     */
    protected function parseLessonsFromContent(string $content): array
    {
        $lessons = [];

        // Pattern to find lesson markers: "الدرس :" or "الدرس:" followed by lesson name
        // Lesson content ends at next "الدرس" or at next subject marker or end of content
        $lessonPattern = '/الدرس\s*:\s*(.+?)(?=الدرس\s*:|•|$)/us';

        if (preg_match_all($lessonPattern, $content, $matches, PREG_SET_ORDER)) {
            foreach ($matches as $match) {
                $lessonContent = trim($match[1]);

                // Extract lesson name (text before first Q marker)
                $lessonName = $this->extractLessonName($lessonContent);

                // Parse all questions in this lesson
                $questions = $this->parseAllQuestions($lessonContent);

                if (!empty($questions) && !empty($lessonName)) {
                    $lessons[] = [
                        'name' => $lessonName,
                        'questions' => $questions,
                    ];
                }
            }
        } else {
            // No lesson markers found, try to parse questions directly
            // Look for any identifiable section headers or just parse all questions
            $questions = $this->parseAllQuestions($content);

            if (!empty($questions)) {
                // Try to extract a title from the content
                $title = $this->extractSectionTitle($content);
                $lessons[] = [
                    'name' => $title ?: 'عام',
                    'questions' => $questions,
                ];
            }
        }

        return $lessons;
    }

    /**
     * Extract lesson name from lesson content
     */
    protected function extractLessonName(string $content): string
    {
        // Get text before first Q marker
        if (preg_match('/^(.+?)(?=Q\s*\d+\s*:)/us', $content, $match)) {
            $name = trim($match[1]);
            // Clean up the name
            $name = preg_replace('/\s+/u', ' ', $name);
            $name = trim($name, " \t\n\r\0\x0B:-");

            // Limit length
            if (mb_strlen($name) > 100) {
                $name = mb_substr($name, 0, 100);
            }

            return $name;
        }

        // If no Q marker, take first line or first few words
        $lines = preg_split('/[\n\r]+/', $content);
        if (!empty($lines[0])) {
            $name = trim($lines[0]);
            $name = preg_replace('/\s+/u', ' ', $name);
            if (mb_strlen($name) > 100) {
                $name = mb_substr($name, 0, 100);
            }
            return $name;
        }

        return 'عام';
    }

    /**
     * Extract section title from content without lesson markers
     */
    protected function extractSectionTitle(string $content): string
    {
        // Try to find a title pattern
        $patterns = [
            '/^([^Q✔✘\n]+?)(?=Q\s*\d+)/us',  // Text before first Q
            '/^(.{10,80}?)(?=\s)/us',  // First significant chunk
        ];

        foreach ($patterns as $pattern) {
            if (preg_match($pattern, $content, $match)) {
                $title = trim($match[1]);
                $title = preg_replace('/\s+/u', ' ', $title);
                if (mb_strlen($title) >= 3 && mb_strlen($title) <= 100) {
                    return $title;
                }
            }
        }

        return '';
    }

    /**
     * Parse ALL questions from content (improved algorithm)
     */
    protected function parseAllQuestions(string $content): array
    {
        $questions = [];

        // Find all Q markers with their content
        // Q 1: or Q1: followed by content until next Q marker or end
        $pattern = '/Q\s*(\d+)\s*:\s*(.+?)(?=Q\s*\d+\s*:|$)/us';

        if (preg_match_all($pattern, $content, $matches, PREG_SET_ORDER)) {
            foreach ($matches as $match) {
                $questionNumber = (int)$match[1];
                $questionContent = trim($match[2]);

                $question = $this->parseQuestionWithOptions($questionContent);

                if ($question) {
                    $question['order'] = $questionNumber;
                    $questions[] = $question;
                }
            }
        }

        return $questions;
    }

    /**
     * Parse a single question with its options (improved)
     */
    protected function parseQuestionWithOptions(string $content): ?array
    {
        // Find all options marked with ✔ or ✘
        $optionPattern = '/(✔|✘)\s*([^✔✘]+)/u';
        preg_match_all($optionPattern, $content, $matches, PREG_SET_ORDER);

        if (count($matches) < 2) {
            return null;
        }

        // Extract question text (everything before first ✔ or ✘)
        $firstMarkerPos = min(
            mb_strpos($content, '✔') !== false ? mb_strpos($content, '✔') : PHP_INT_MAX,
            mb_strpos($content, '✘') !== false ? mb_strpos($content, '✘') : PHP_INT_MAX
        );

        if ($firstMarkerPos === PHP_INT_MAX) {
            return null;
        }

        $questionText = trim(mb_substr($content, 0, $firstMarkerPos));
        $questionText = preg_replace('/\s+/u', ' ', $questionText);
        $questionText = trim($questionText);

        if (empty($questionText)) {
            return null;
        }

        $options = [];
        $correctAnswers = [];

        foreach ($matches as $match) {
            $isCorrect = $match[1] === '✔';
            $optionText = trim($match[2]);
            $optionText = preg_replace('/\s+/u', ' ', $optionText);

            if (empty($optionText)) {
                continue;
            }

            $options[] = [
                'text' => $optionText,
                'is_correct' => $isCorrect,
            ];

            if ($isCorrect) {
                $correctAnswers[] = $optionText;
            }
        }

        if (empty($options) || empty($correctAnswers)) {
            return null;
        }

        // Determine question type
        $questionType = count($correctAnswers) === 1
            ? QuizQuestion::TYPE_SINGLE_CHOICE
            : QuizQuestion::TYPE_MULTIPLE_CHOICE;

        return [
            'question_text' => $questionText,
            'question_type' => $questionType,
            'options' => $options,
            'correct_answer' => $correctAnswers,
        ];
    }

    /**
     * Create quizzes from parsed data
     */
    protected function createQuizzesFromData(array $quizData, User $creator, array $options): array
    {
        $results = [
            'success' => true,
            'quizzes_created' => 0,
            'questions_created' => 0,
            'quizzes' => [],
            'errors' => [],
            'warnings' => [],
        ];

        DB::beginTransaction();

        try {
            foreach ($quizData['subjects'] as $subjectData) {
                $subject = $this->matchSubject($subjectData['name']);

                if (!$subject && !$options['create_subjects']) {
                    $results['warnings'][] = "Subject not found: {$subjectData['name']}. Skipping.";
                    continue;
                }

                if (!$subject && $options['create_subjects']) {
                    $results['warnings'][] = "Creating subjects is not yet implemented. Skipping: {$subjectData['name']}";
                    continue;
                }

                if ($options['quiz_per_lesson']) {
                    // Create one quiz per lesson
                    foreach ($subjectData['lessons'] as $lesson) {
                        $chapter = null;
                        if ($options['create_chapters']) {
                            $chapter = $this->matchOrCreateChapter($subject, $lesson['name']);
                        }

                        // Title is just the lesson name (no Quiz/اليوم prefix)
                        $title = $lesson['name'];

                        $quiz = $this->createQuiz(
                            subject: $subject,
                            title: $title,
                            questions: $lesson['questions'],
                            creator: $creator,
                            chapter: $chapter,
                            options: $options
                        );

                        $results['quizzes'][] = [
                            'id' => $quiz->id,
                            'title' => $quiz->title_ar,
                            'subject' => $subject->name_ar,
                            'lesson' => $lesson['name'],
                            'questions_count' => count($lesson['questions']),
                        ];
                        $results['quizzes_created']++;
                        $results['questions_created'] += count($lesson['questions']);
                    }
                } else {
                    // Create one quiz per subject with all lessons combined
                    $allQuestions = [];
                    $lessonNames = [];

                    foreach ($subjectData['lessons'] as $lesson) {
                        $allQuestions = array_merge($allQuestions, $lesson['questions']);
                        $lessonNames[] = $lesson['name'];
                    }

                    // Title is subject name only
                    $title = $subject->name_ar;

                    $quiz = $this->createQuiz(
                        subject: $subject,
                        title: $title,
                        questions: $allQuestions,
                        creator: $creator,
                        chapter: null,
                        options: $options
                    );

                    $results['quizzes'][] = [
                        'id' => $quiz->id,
                        'title' => $quiz->title_ar,
                        'subject' => $subject->name_ar,
                        'lessons' => $lessonNames,
                        'questions_count' => count($allQuestions),
                    ];
                    $results['quizzes_created']++;
                    $results['questions_created'] += count($allQuestions);
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
     * Match subject by Arabic name
     */
    public function matchSubject(string $name): ?Subject
    {
        $name = trim($name);

        // Direct match
        $subject = Subject::where('name_ar', $name)->first();
        if ($subject) {
            return $subject;
        }

        // Fuzzy matching for common variations
        $mappings = [
            'العلوم الطبيعية' => ['علوم', 'طبيعية', 'علوم طبيعية', 'علوم الطبيعة'],
            'التاريخ والجغرافيا' => ['تاريخ', 'جغرافيا', 'تاريخ وجغرافيا'],
            'الفرنسية' => ['فرنسية', 'اللغة الفرنسية', 'لغة فرنسية'],
            'الرياضيات' => ['رياضيات', 'الرياضيات'],
            'الفيزياء' => ['فيزياء', 'الفيزياء'],
            'الفلسفة' => ['فلسفة', 'الفلسفة'],
            'اللغة العربية' => ['عربية', 'اللغة العربية', 'لغة عربية'],
            'اللغة الإنجليزية' => ['إنجليزية', 'انجليزية', 'اللغة الإنجليزية', 'الانجليزية'],
            'الإسلامية' => ['إسلامية', 'التربية الإسلامية', 'علوم إسلامية'],
        ];

        foreach ($mappings as $canonicalName => $variations) {
            if ($name === $canonicalName || in_array($name, $variations)) {
                foreach (array_merge([$canonicalName], $variations) as $searchTerm) {
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
     * Match or create chapter for a subject
     */
    public function matchOrCreateChapter(Subject $subject, string $lessonName): ContentChapter
    {
        $lessonName = trim($lessonName);

        // Try to find existing chapter
        $chapter = ContentChapter::where('subject_id', $subject->id)
            ->where(function ($query) use ($lessonName) {
                $query->where('title_ar', $lessonName)
                    ->orWhere('title_ar', 'LIKE', "%{$lessonName}%");
            })
            ->first();

        if ($chapter) {
            return $chapter;
        }

        // Create new chapter
        $maxOrder = ContentChapter::where('subject_id', $subject->id)->max('order') ?? 0;

        return ContentChapter::create([
            'subject_id' => $subject->id,
            'title_ar' => $lessonName,
            'slug' => Str::slug($lessonName . '-' . Str::random(4)),
            'description_ar' => "فصل: {$lessonName}",
            'order' => $maxOrder + 1,
            'is_active' => true,
        ]);
    }

    /**
     * Create a quiz with questions
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
        ];

        $questionsData = [];

        foreach ($questions as $q) {
            // Convert correct_answer texts to indices
            $correctIndices = [];
            foreach ($q['options'] as $index => $option) {
                if ($option['is_correct']) {
                    $correctIndices[] = $index;
                }
            }

            $questionsData[] = [
                'question_type' => $q['question_type'],
                'question_text_ar' => $q['question_text'],
                'question_image_url' => null,
                'options' => $q['options'],
                'correct_answer' => $correctIndices,
                'points' => 1,
                'explanation_ar' => null,
                'difficulty' => $options['difficulty_level'],
                'tags' => null,
            ];
        }

        return $this->quizService->createQuizWithImportedQuestions($quizData, $questionsData);
    }

    /**
     * Get preview of what will be imported (dry run)
     */
    public function previewImport(string $filePath): array
    {
        $content = $this->parseWordDocument($filePath);
        $quizData = $this->parseQuizStructure($content);

        $preview = [
            'title' => $quizData['title'] ?? '',
            'subjects' => [],
            'total_subjects' => 0,
            'total_lessons' => 0,
            'total_questions' => 0,
        ];

        foreach ($quizData['subjects'] as $subjectData) {
            $subject = $this->matchSubject($subjectData['name']);

            $subjectPreview = [
                'name' => $subjectData['name'],
                'matched_subject' => $subject ? [
                    'id' => $subject->id,
                    'name' => $subject->name_ar,
                ] : null,
                'lessons' => [],
            ];

            foreach ($subjectData['lessons'] as $lesson) {
                $subjectPreview['lessons'][] = [
                    'name' => $lesson['name'],
                    'questions_count' => count($lesson['questions']),
                    'questions' => array_map(fn($q) => [
                        'text' => mb_substr($q['question_text'], 0, 80) . (mb_strlen($q['question_text']) > 80 ? '...' : ''),
                        'type' => $q['question_type'],
                        'options_count' => count($q['options']),
                        'correct_count' => count($q['correct_answer']),
                    ], $lesson['questions']),
                ];
                $preview['total_questions'] += count($lesson['questions']);
            }

            $preview['total_lessons'] += count($subjectData['lessons']);
            $preview['subjects'][] = $subjectPreview;
        }

        $preview['total_subjects'] = count($quizData['subjects']);

        return $preview;
    }
}
