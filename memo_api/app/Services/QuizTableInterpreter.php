<?php

namespace App\Services;

use App\Models\QuizQuestion;

/**
 * Interpreter for quiz table structure from Word documents
 *
 * This class interprets the specific 6-column table format used in quiz documents:
 * - Row 0: Lesson header (merged) - "الدرس : lesson_name"
 * - Row 1: Question texts - Q1, Q1, Q2, Q2, Q3, Q3 (text, marker pairs)
 * - Rows 2+: Options with ✔/✘ markers
 */
class QuizTableInterpreter
{
    protected const CORRECT_MARKER = '✔';
    protected const INCORRECT_MARKER = '✘';

    /**
     * Interpret a parsed table into lesson data with questions
     *
     * @param array $tableRows Parsed table rows from WordTableParser
     * @return array|null Lesson data with questions, or null if invalid table
     */
    public function interpretQuizTable(array $tableRows): ?array
    {
        if (count($tableRows) < 3) {
            return null; // Need at least header, questions, and one option row
        }

        // Check if this is a quiz table by looking for lesson header
        $lessonName = $this->extractLessonName($tableRows[0]);
        if (empty($lessonName)) {
            return null;
        }

        // Parse questions from the table structure
        $questions = $this->parseQuestionColumns($tableRows);

        if (empty($questions)) {
            return null;
        }

        return [
            'name' => $lessonName,
            'questions' => $questions,
        ];
    }

    /**
     * Interpret multiple consecutive lesson blocks within a single table
     *
     * Some tables contain multiple lessons stacked vertically:
     * - Rows 0-5: First lesson (header + questions + options)
     * - Rows 6-11: Second lesson
     * - etc.
     *
     * @param array $tableRows Full table rows
     * @return array Array of lesson data
     */
    public function interpretMultipleLessons(array $tableRows): array
    {
        $lessons = [];
        $currentLesson = [];
        $inLesson = false;

        foreach ($tableRows as $row) {
            $firstCell = $row[0] ?? '';

            // Check if this is a new lesson header
            if ($this->isLessonHeader($firstCell)) {
                // Save previous lesson if exists
                if (!empty($currentLesson)) {
                    $lessonData = $this->interpretQuizTable($currentLesson);
                    if ($lessonData) {
                        $lessons[] = $lessonData;
                    }
                }
                // Start new lesson
                $currentLesson = [$row];
                $inLesson = true;
            } elseif ($inLesson) {
                $currentLesson[] = $row;
            }
        }

        // Don't forget the last lesson
        if (!empty($currentLesson)) {
            $lessonData = $this->interpretQuizTable($currentLesson);
            if ($lessonData) {
                $lessons[] = $lessonData;
            }
        }

        return $lessons;
    }

    /**
     * Check if a cell contains a lesson header
     *
     * @param string $cellContent Cell text
     * @return bool True if this is a lesson header
     */
    protected function isLessonHeader(string $cellContent): bool
    {
        return preg_match('/الدرس\s*:/u', $cellContent) === 1;
    }

    /**
     * Extract lesson name from header row
     *
     * Format: "الدرس : lesson_name" or merged across columns
     *
     * @param array $headerRow First row of the table
     * @return string Lesson name or empty string
     */
    protected function extractLessonName(array $headerRow): string
    {
        // Header row usually has merged cells, check all cells
        foreach ($headerRow as $cell) {
            $cell = trim($cell);
            if (empty($cell)) {
                continue;
            }

            // Look for "الدرس :" pattern
            if (preg_match('/الدرس\s*:\s*(.+)/u', $cell, $match)) {
                return trim($match[1]);
            }

            // Also check for English lesson pattern
            if (preg_match('/(?:Lesson|الدرس)\s*:\s*(.+)/ui', $cell, $match)) {
                return trim($match[1]);
            }
        }

        return '';
    }

    /**
     * Parse questions from the table structure
     *
     * Word tables with merged cells result in different column counts:
     * - Row 0 (header): 1 cell (merged) - "الدرس : lesson_name"
     * - Row 1 (questions): 3 cells - [Q1 text, Q2 text, Q3 text]
     * - Rows 2+ (options): 6 cells - [opt1, ✔/✘, opt2, ✔/✘, opt3, ✔/✘]
     *
     * @param array $rows All table rows
     * @return array Parsed questions
     */
    protected function parseQuestionColumns(array $rows): array
    {
        $questions = [];

        if (count($rows) < 3) {
            return $questions;
        }

        $questionRow = $rows[1] ?? [];
        $optionRowSample = $rows[2] ?? [];

        // Determine structure based on row cell counts
        $questionCellCount = count($questionRow);
        $optionCellCount = count($optionRowSample);

        // Standard case: 3 question cells, 6 option cells
        if ($questionCellCount === 3 && $optionCellCount === 6) {
            // Questions at indices 0, 1, 2 in row 1
            // Options at pairs [0,1], [2,3], [4,5] in rows 2+
            for ($qIdx = 0; $qIdx < 3; $qIdx++) {
                $question = $this->parseQuestionWithSeparateLayout($rows, $qIdx, $qIdx * 2, $qIdx * 2 + 1);
                if ($question) {
                    $question['order'] = $qIdx + 1;
                    $questions[] = $question;
                }
            }
        }
        // Fallback: 6 cells in both rows (no merging detected)
        elseif ($questionCellCount === 6 && $optionCellCount === 6) {
            $columnPairs = [[0, 1], [2, 3], [4, 5]];
            foreach ($columnPairs as $pairIndex => [$textCol, $markerCol]) {
                $question = $this->parseQuestionFromColumns($rows, $textCol, $markerCol);
                if ($question) {
                    $question['order'] = $pairIndex + 1;
                    $questions[] = $question;
                }
            }
        }
        // Single question per row variant
        elseif ($questionCellCount <= 2 && $optionCellCount <= 2) {
            $question = $this->parseQuestionFromColumns($rows, 0, 1);
            if ($question) {
                $question['order'] = 1;
                $questions[] = $question;
            }
        }

        return $questions;
    }

    /**
     * Parse question with separate column indices for question text and options
     *
     * @param array $rows All table rows
     * @param int $questionCol Column index for question text in row 1
     * @param int $optionTextCol Column index for option text in rows 2+
     * @param int $optionMarkerCol Column index for ✔/✘ marker in rows 2+
     * @return array|null Question data or null if invalid
     */
    protected function parseQuestionWithSeparateLayout(array $rows, int $questionCol, int $optionTextCol, int $optionMarkerCol): ?array
    {
        if (count($rows) < 3) {
            return null;
        }

        // Row 1 contains question texts
        $questionRow = $rows[1] ?? [];
        $questionText = $this->extractQuestionText($questionRow[$questionCol] ?? '');

        if (empty($questionText)) {
            return null;
        }

        $options = [];
        $correctAnswers = [];

        // Rows 2+ contain options
        for ($i = 2; $i < count($rows); $i++) {
            $row = $rows[$i];

            // Check if we hit a new lesson header (stop processing)
            if ($this->isLessonHeader($row[0] ?? '')) {
                break;
            }

            // Skip rows with different cell count (might be merged rows)
            if (count($row) < $optionMarkerCol + 1) {
                continue;
            }

            $optionText = trim($row[$optionTextCol] ?? '');
            $marker = trim($row[$optionMarkerCol] ?? '');

            // Skip empty options
            if (empty($optionText)) {
                continue;
            }

            $isCorrect = $this->isCorrectMarker($marker);

            $options[] = [
                'text' => $optionText,
                'is_correct' => $isCorrect,
            ];

            if ($isCorrect) {
                $correctAnswers[] = $optionText;
            }
        }

        // Need at least 2 options and 1 correct answer
        if (count($options) < 2 || empty($correctAnswers)) {
            return null;
        }

        // Determine question type based on correct answer count
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
     * Parse a single question from two columns (fallback method)
     *
     * @param array $rows All table rows
     * @param int $textCol Column index for option text
     * @param int $markerCol Column index for ✔/✘ marker
     * @return array|null Question data or null if invalid
     */
    protected function parseQuestionFromColumns(array $rows, int $textCol, int $markerCol): ?array
    {
        if (count($rows) < 2) {
            return null;
        }

        // Row 1 contains question text (row 0 is lesson header)
        $questionRow = $rows[1] ?? [];
        $questionText = $this->extractQuestionText($questionRow[$textCol] ?? '');

        if (empty($questionText)) {
            return null;
        }

        $options = [];
        $correctAnswers = [];

        // Rows 2+ contain options
        for ($i = 2; $i < count($rows); $i++) {
            $row = $rows[$i];

            // Check if we hit a new lesson header (stop processing)
            if ($this->isLessonHeader($row[0] ?? '')) {
                break;
            }

            $optionText = trim($row[$textCol] ?? '');
            $marker = trim($row[$markerCol] ?? '');

            // Skip empty options
            if (empty($optionText)) {
                continue;
            }

            $isCorrect = $this->isCorrectMarker($marker);

            $options[] = [
                'text' => $optionText,
                'is_correct' => $isCorrect,
            ];

            if ($isCorrect) {
                $correctAnswers[] = $optionText;
            }
        }

        // Need at least 2 options and 1 correct answer
        if (count($options) < 2 || empty($correctAnswers)) {
            return null;
        }

        // Determine question type based on correct answer count
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
     * Extract question text, removing Q prefix
     *
     * Handles formats: "Q1: text", "Q 1: text", etc.
     *
     * @param string $cellContent Raw cell content
     * @return string Clean question text
     */
    protected function extractQuestionText(string $cellContent): string
    {
        $text = trim($cellContent);

        // Remove Q1:, Q2:, Q3: etc. prefix
        $text = preg_replace('/^Q\s*\d+\s*:\s*/ui', '', $text);

        // Normalize whitespace
        $text = preg_replace('/\s+/', ' ', $text);

        return trim($text);
    }

    /**
     * Check if a marker indicates correct answer
     *
     * @param string $marker Cell content that should contain ✔ or ✘
     * @return bool True if correct answer marker
     */
    protected function isCorrectMarker(string $marker): bool
    {
        return mb_strpos($marker, self::CORRECT_MARKER) !== false;
    }

    /**
     * Detect subject from paragraph or table header text
     *
     * @param string $text Text to analyze
     * @return string|null Subject name or null
     */
    public function detectSubject(string $text): ?string
    {
        $subjects = [
            'العلوم الطبيعية' => 'العلوم الطبيعية',
            'علوم الطبيعة' => 'العلوم الطبيعية',
            'التاريخ والجغرافيا' => 'التاريخ والجغرافيا',
            'تاريخ وجغرافيا' => 'التاريخ والجغرافيا',
            'الفرنسية' => 'الفرنسية',
            'اللغة الفرنسية' => 'الفرنسية',
            'الرياضيات' => 'الرياضيات',
            'الفيزياء' => 'الفيزياء',
            'الفلسفة' => 'الفلسفة',
            'اللغة العربية' => 'اللغة العربية',
            'اللغة الإنجليزية' => 'اللغة الإنجليزية',
            'التربية الإسلامية' => 'التربية الإسلامية',
            'الإسلامية' => 'التربية الإسلامية',
        ];

        foreach ($subjects as $pattern => $canonical) {
            if (mb_strpos($text, $pattern) !== false) {
                return $canonical;
            }
        }

        return null;
    }
}
