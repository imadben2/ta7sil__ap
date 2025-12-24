<?php

/**
 * Script to extract all quizzes from Word documents and export to Markdown
 *
 * Usage: php extract_quizzes_to_md.php
 */

require_once __DIR__ . '/vendor/autoload.php';

// Load Laravel app for access to services
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Services\WordTableParser;
use App\Services\QuizTableInterpreter;

class QuizToMarkdownExporter
{
    protected WordTableParser $tableParser;
    protected QuizTableInterpreter $tableInterpreter;
    protected array $allQuizzes = [];
    protected array $quizzesBySubject = [];

    public function __construct()
    {
        $this->tableParser = new WordTableParser();
        $this->tableInterpreter = new QuizTableInterpreter();
    }

    /**
     * Export all quizzes from a directory to Markdown files
     */
    public function exportDirectory(string $inputDir, string $outputDir): array
    {
        $results = [
            'files_processed' => 0,
            'subjects_found' => 0,
            'lessons_found' => 0,
            'questions_found' => 0,
            'errors' => [],
        ];

        // Create output directory if it doesn't exist
        if (!is_dir($outputDir)) {
            mkdir($outputDir, 0755, true);
        }

        // Get all .docx files
        $files = glob($inputDir . '/*.docx');

        if (empty($files)) {
            $results['errors'][] = "No .docx files found in: $inputDir";
            return $results;
        }

        echo "Found " . count($files) . " Word documents\n\n";

        foreach ($files as $file) {
            echo "Processing: " . basename($file) . "... ";

            try {
                $quizData = $this->parseQuizFile($file);

                if (!empty($quizData['subjects'])) {
                    foreach ($quizData['subjects'] as $subjectData) {
                        $subjectName = $subjectData['name'] ?? 'غير محدد';

                        if (!isset($this->quizzesBySubject[$subjectName])) {
                            $this->quizzesBySubject[$subjectName] = [
                                'lessons' => [],
                            ];
                        }

                        foreach ($subjectData['lessons'] as $lesson) {
                            $this->quizzesBySubject[$subjectName]['lessons'][] = [
                                'name' => $lesson['name'],
                                'questions' => $lesson['questions'],
                                'source_file' => basename($file),
                            ];
                            $results['lessons_found']++;
                            $results['questions_found'] += count($lesson['questions']);
                        }
                    }
                    echo "OK (" . count($quizData['subjects']) . " subjects)\n";
                } else {
                    echo "No quiz data found\n";
                }

                $results['files_processed']++;

            } catch (\Exception $e) {
                $results['errors'][] = basename($file) . ": " . $e->getMessage();
                echo "ERROR: " . $e->getMessage() . "\n";
            }
        }

        $results['subjects_found'] = count($this->quizzesBySubject);

        // Generate Markdown files
        echo "\n--- Generating Markdown files ---\n";

        // Generate combined file
        $allMd = $this->generateCombinedMarkdown();
        file_put_contents($outputDir . '/quiz_all.md', $allMd);
        echo "Created: quiz_all.md\n";

        // Generate per-subject files
        foreach ($this->quizzesBySubject as $subjectName => $subjectData) {
            $md = $this->generateSubjectMarkdown($subjectName, $subjectData);
            $filename = $this->sanitizeFilename($subjectName) . '.md';
            file_put_contents($outputDir . '/' . $filename, $md);
            echo "Created: $filename\n";
        }

        return $results;
    }

    /**
     * Parse a single quiz file
     */
    protected function parseQuizFile(string $filePath): array
    {
        $result = [
            'title' => basename($filePath),
            'subjects' => [],
        ];

        // Get paragraphs (for subject headers)
        $paragraphs = $this->tableParser->getParagraphs($filePath);

        // Get all tables
        $tables = $this->tableParser->parseTables($filePath);

        if (empty($tables)) {
            return $result;
        }

        // Detect subjects from paragraphs
        $subjectNames = [];
        foreach ($paragraphs as $paragraph) {
            if (preg_match('/[•·]\s*(.+?)\s*:/u', $paragraph, $match)) {
                $subjectName = trim($match[1]);
                $canonicalName = $this->tableInterpreter->detectSubject($subjectName);
                if ($canonicalName) {
                    $subjectNames[] = $canonicalName;
                } elseif (!empty($subjectName)) {
                    $subjectNames[] = $subjectName;
                }
            }
        }

        // Match subjects to tables
        if (count($subjectNames) === count($tables)) {
            foreach ($tables as $tableIndex => $tableRows) {
                if (empty($tableRows)) {
                    continue;
                }

                $subjectName = $subjectNames[$tableIndex];
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

            foreach ($tables as $tableRows) {
                if (empty($tableRows)) {
                    continue;
                }

                $firstRowText = implode(' ', $tableRows[0] ?? []);
                $detectedSubject = $this->tableInterpreter->detectSubject($firstRowText);

                if ($detectedSubject && $detectedSubject !== $currentSubject) {
                    if ($currentSubject && !empty($currentLessons)) {
                        $result['subjects'][] = [
                            'name' => $currentSubject,
                            'lessons' => $currentLessons,
                        ];
                    }
                    $currentSubject = $detectedSubject;
                    $currentLessons = [];
                }

                if (!$currentSubject && !empty($subjectNames)) {
                    $currentSubject = $subjectNames[0];
                }

                $lessons = $this->tableInterpreter->interpretMultipleLessons($tableRows);

                foreach ($lessons as $lesson) {
                    if (!empty($lesson['questions'])) {
                        $currentLessons[] = $lesson;
                    }
                }
            }

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
     * Generate combined Markdown with all subjects
     */
    protected function generateCombinedMarkdown(): string
    {
        $md = "# جميع الاختبارات\n\n";
        $md .= "تاريخ الإنشاء: " . date('Y-m-d H:i:s') . "\n\n";
        $md .= "---\n\n";

        foreach ($this->quizzesBySubject as $subjectName => $subjectData) {
            $md .= $this->generateSubjectMarkdown($subjectName, $subjectData);
            $md .= "\n\n---\n\n";
        }

        return $md;
    }

    /**
     * Generate Markdown for a single subject
     */
    protected function generateSubjectMarkdown(string $subjectName, array $subjectData): string
    {
        $md = "# {$subjectName}\n\n";
        $md .= "عدد الفصول: " . count($subjectData['lessons']) . "\n\n";

        $questionCount = 0;
        foreach ($subjectData['lessons'] as $lesson) {
            $questionCount += count($lesson['questions']);
        }
        $md .= "عدد الأسئلة الإجمالي: {$questionCount}\n\n";
        $md .= "---\n\n";

        // Group lessons by name to avoid duplicates
        $lessonsByName = [];
        foreach ($subjectData['lessons'] as $lesson) {
            $lessonName = $lesson['name'];
            if (!isset($lessonsByName[$lessonName])) {
                $lessonsByName[$lessonName] = [
                    'name' => $lessonName,
                    'questions' => [],
                    'sources' => [],
                ];
            }
            $lessonsByName[$lessonName]['questions'] = array_merge(
                $lessonsByName[$lessonName]['questions'],
                $lesson['questions']
            );
            $lessonsByName[$lessonName]['sources'][] = $lesson['source_file'];
        }

        foreach ($lessonsByName as $lessonData) {
            $md .= "## 📚 " . $lessonData['name'] . "\n\n";
            $md .= "المصادر: " . implode(', ', array_unique($lessonData['sources'])) . "\n\n";

            foreach ($lessonData['questions'] as $qIndex => $question) {
                $qNum = $qIndex + 1;
                $md .= "### ❓ السؤال {$qNum}\n\n";
                $md .= "**" . $question['question_text'] . "**\n\n";

                foreach ($question['options'] as $oIndex => $option) {
                    $letter = chr(65 + $oIndex); // A, B, C, D...
                    $checkbox = $option['is_correct'] ? '[x]' : '[ ]';
                    $marker = $option['is_correct'] ? '✅' : '❌';
                    $md .= "- {$checkbox} **{$letter}.** {$option['text']} {$marker}\n";
                }

                $md .= "\n---\n\n";
            }
        }

        return $md;
    }

    /**
     * Sanitize filename for filesystem
     */
    protected function sanitizeFilename(string $name): string
    {
        // Replace Arabic spaces and special chars
        $name = preg_replace('/[^\p{L}\p{N}_-]/u', '_', $name);
        $name = preg_replace('/_+/', '_', $name);
        $name = trim($name, '_');

        return $name ?: 'unknown';
    }
}

// Run the export
$inputDir = realpath(__DIR__ . '/../quiz');
$outputDir = realpath(__DIR__ . '/..') . '/quiz_export';

if (!$inputDir) {
    echo "ERROR: Quiz directory not found at: " . __DIR__ . '/../quiz' . "\n";
    exit(1);
}

echo "=== Quiz to Markdown Exporter ===\n\n";
echo "Input directory: $inputDir\n";
echo "Output directory: $outputDir\n\n";

$exporter = new QuizToMarkdownExporter();
$results = $exporter->exportDirectory($inputDir, $outputDir);

echo "\n=== Results ===\n";
echo "Files processed: {$results['files_processed']}\n";
echo "Subjects found: {$results['subjects_found']}\n";
echo "Lessons found: {$results['lessons_found']}\n";
echo "Questions found: {$results['questions_found']}\n";

if (!empty($results['errors'])) {
    echo "\nErrors:\n";
    foreach ($results['errors'] as $error) {
        echo "  - $error\n";
    }
}

echo "\nDone! Check the output in: $outputDir\n";
