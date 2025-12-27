<?php

namespace App\Imports;

use Illuminate\Support\Collection;
use Maatwebsite\Excel\Concerns\ToCollection;
use Maatwebsite\Excel\Concerns\WithHeadingRow;
use Maatwebsite\Excel\Concerns\SkipsEmptyRows;

class QuizSheetImport implements ToCollection, WithHeadingRow, SkipsEmptyRows
{
    protected string $sheetName;
    protected array $questions = [];
    protected array $errors = [];

    public function __construct(string $sheetName)
    {
        $this->sheetName = $sheetName;
    }

    public function collection(Collection $rows)
    {
        foreach ($rows as $index => $row) {
            $rowNumber = $index + 2; // +2 for header row and 0-based index

            try {
                $question = $this->transformRow($row, $rowNumber);
                if ($question) {
                    $this->questions[] = $question;
                }
            } catch (\Exception $e) {
                $this->errors[] = [
                    'sheet' => $this->sheetName,
                    'row' => $rowNumber,
                    'message' => $e->getMessage()
                ];
            }
        }
    }

    protected function transformRow(Collection $row, int $rowNumber): ?array
    {
        // Column A: Question text (key might be 'question', 'questions', or index 0)
        $questionText = trim($row['question'] ?? $row['questions'] ?? $row[0] ?? '');
        if (empty($questionText)) {
            return null;
        }

        // Column B: Options separated by \ or / or \n
        $optionsRaw = trim($row['options'] ?? $row[1] ?? '');
        $options = $this->parseOptions($optionsRaw);

        if (count($options) < 2) {
            throw new \Exception("يجب وجود خيارين على الأقل في السطر {$rowNumber}");
        }

        // Column C: Correct answer index (1-based)
        $correctIndexRaw = $row['correct_answer_index'] ?? $row[2] ?? 1;
        $correctIndex = (int) $correctIndexRaw;

        // Convert to 0-based index
        $correctIndex = $correctIndex - 1;

        if ($correctIndex < 0 || $correctIndex >= count($options)) {
            throw new \Exception("فهرس الإجابة الصحيحة ({$correctIndexRaw}) غير صالح في السطر {$rowNumber}. يجب أن يكون بين 1 و " . count($options));
        }

        // Column D: Question type (default: text_only) - we ignore this, always mcq_single
        // Column E: Option type (default: text_only) - we ignore this

        // Format options with is_correct flag
        $formattedOptions = [];
        foreach ($options as $i => $optionText) {
            $formattedOptions[] = [
                'text' => $optionText,
                'is_correct' => ($i === $correctIndex),
            ];
        }

        return [
            'question_text' => $questionText,
            'question_type' => 'mcq_single',
            'options' => $formattedOptions,
            'correct_answer' => [$correctIndex],
        ];
    }

    /**
     * Parse options from raw string.
     * Options can be separated by \ or / or \n
     */
    protected function parseOptions(string $raw): array
    {
        // First try splitting by newline
        if (str_contains($raw, "\n")) {
            $options = preg_split('/\r?\n/', $raw);
        } else {
            // Split by \ or / (common separators in Arabic content)
            $options = preg_split('/[\\\\\/]/', $raw);
        }

        // Clean up options
        $cleaned = [];
        foreach ($options as $option) {
            $option = trim($option);
            // Remove leading/trailing markers like "ا " or letter prefixes
            $option = preg_replace('/^[أا-ي]\s*[-:)]\s*/u', '', $option);
            $option = trim($option);

            if (!empty($option)) {
                $cleaned[] = $option;
            }
        }

        return $cleaned;
    }

    public function getSheetName(): string
    {
        return $this->sheetName;
    }

    public function getQuestions(): array
    {
        return $this->questions;
    }

    public function getErrors(): array
    {
        return $this->errors;
    }

    public function hasErrors(): bool
    {
        return !empty($this->errors);
    }
}
