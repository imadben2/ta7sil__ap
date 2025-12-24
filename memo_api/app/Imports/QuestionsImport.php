<?php

namespace App\Imports;

use Illuminate\Support\Collection;
use Illuminate\Support\Str;
use Maatwebsite\Excel\Concerns\ToCollection;
use Maatwebsite\Excel\Concerns\WithHeadingRow;
use Maatwebsite\Excel\Concerns\WithValidation;
use Maatwebsite\Excel\Concerns\SkipsEmptyRows;

class QuestionsImport implements ToCollection, WithHeadingRow, WithValidation, SkipsEmptyRows
{
    protected array $questions = [];
    protected array $errors = [];

    /**
     * Process the collection from Excel.
     */
    public function collection(Collection $rows)
    {
        foreach ($rows as $index => $row) {
            $rowNumber = $index + 2; // +2 because of header row and 0-based index

            try {
                $question = $this->transformRow($row, $rowNumber);
                $this->questions[] = $question;
            } catch (\Exception $e) {
                $this->errors[] = [
                    'row' => $rowNumber,
                    'message' => $e->getMessage()
                ];
            }
        }
    }

    /**
     * Transform a row into a question array.
     */
    protected function transformRow(Collection $row, int $rowNumber): array
    {
        $questionType = strtolower(trim($row['question_type'] ?? ''));

        // Map frontend types to database types
        $typeMapping = [
            'single_choice' => 'mcq_single',
            'multiple_choice' => 'mcq_multiple',
            'true_false' => 'true_false',
            'short_answer' => 'short_answer',
        ];

        $dbQuestionType = $typeMapping[$questionType] ?? $questionType;

        // Validate question type
        $validTypes = ['mcq_single', 'mcq_multiple', 'true_false', 'short_answer'];
        if (!in_array($dbQuestionType, $validTypes)) {
            throw new \Exception("نوع السؤال غير صحيح: {$questionType}. الأنواع المسموحة: single_choice, multiple_choice, true_false, short_answer");
        }

        $question = [
            'question_type' => $dbQuestionType,
            'question_text_ar' => trim($row['question_text_ar'] ?? ''),
            'points' => (int)($row['points'] ?? 1),
            'difficulty' => $this->validateDifficulty($row['difficulty'] ?? null),
            'explanation_ar' => trim($row['explanation_ar'] ?? '') ?: null,
            'tags' => $this->parseTags($row['tags'] ?? ''),
            'question_image_url' => trim($row['question_image_url'] ?? '') ?: null,
        ];

        // Validate required fields
        if (empty($question['question_text_ar'])) {
            throw new \Exception("نص السؤال مطلوب في السطر {$rowNumber}");
        }

        if ($question['points'] < 1) {
            throw new \Exception("يجب أن تكون النقاط أكبر من أو تساوي 1 في السطر {$rowNumber}");
        }

        // Process options and correct answer based on question type
        switch ($dbQuestionType) {
            case 'mcq_single':
                $question['options'] = $this->processMcqOptions($row, $rowNumber);
                $question['correct_answer'] = $this->processMcqSingleAnswer($row, $rowNumber);
                break;

            case 'mcq_multiple':
                $question['options'] = $this->processMcqOptions($row, $rowNumber);
                $question['correct_answer'] = $this->processMcqMultipleAnswer($row, $rowNumber);
                break;

            case 'true_false':
                $question['options'] = null;
                $question['correct_answer'] = $this->processTrueFalseAnswer($row, $rowNumber);
                break;

            case 'short_answer':
                $question['options'] = null;
                $question['correct_answer'] = $this->processShortAnswer($row, $rowNumber);
                break;
        }

        return $question;
    }

    /**
     * Process MCQ options.
     */
    protected function processMcqOptions(Collection $row, int $rowNumber): array
    {
        $options = [];

        for ($i = 1; $i <= 4; $i++) {
            $optionKey = "option_{$i}";
            $optionText = trim($row[$optionKey] ?? '');

            if (!empty($optionText)) {
                $options[] = ['text' => $optionText];
            }
        }

        if (count($options) < 2) {
            throw new \Exception("يجب أن يكون هناك خياران على الأقل للأسئلة متعددة الخيارات في السطر {$rowNumber}");
        }

        return $options;
    }

    /**
     * Process MCQ single choice correct answer.
     */
    protected function processMcqSingleAnswer(Collection $row, int $rowNumber): array
    {
        $correctAnswer = trim($row['correct_answer'] ?? '');

        if (empty($correctAnswer)) {
            throw new \Exception("الإجابة الصحيحة مطلوبة في السطر {$rowNumber}");
        }

        // Accept either number (1-4) or letter (A-D) or option text
        if (is_numeric($correctAnswer)) {
            $index = (int)$correctAnswer - 1; // Convert to 0-based index
        } elseif (preg_match('/^[A-Da-d]$/', $correctAnswer)) {
            $index = ord(strtoupper($correctAnswer)) - ord('A');
        } else {
            // Try to find the option by text
            for ($i = 1; $i <= 4; $i++) {
                if (trim($row["option_{$i}"] ?? '') === $correctAnswer) {
                    $index = $i - 1;
                    break;
                }
            }

            if (!isset($index)) {
                throw new \Exception("الإجابة الصحيحة غير صحيحة في السطر {$rowNumber}. استخدم رقم (1-4) أو حرف (A-D) أو نص الخيار");
            }
        }

        if ($index < 0 || $index > 3) {
            throw new \Exception("رقم الإجابة الصحيحة يجب أن يكون بين 1 و 4 في السطر {$rowNumber}");
        }

        return [$index];
    }

    /**
     * Process MCQ multiple choice correct answers.
     */
    protected function processMcqMultipleAnswer(Collection $row, int $rowNumber): array
    {
        $correctAnswer = trim($row['correct_answer'] ?? '');

        if (empty($correctAnswer)) {
            throw new \Exception("الإجابات الصحيحة مطلوبة في السطر {$rowNumber}");
        }

        // Accept comma-separated values: "1,3", "A,C", or "option text, option text"
        $answers = array_map('trim', explode(',', $correctAnswer));
        $indices = [];

        foreach ($answers as $answer) {
            if (is_numeric($answer)) {
                $index = (int)$answer - 1;
            } elseif (preg_match('/^[A-Da-d]$/', $answer)) {
                $index = ord(strtoupper($answer)) - ord('A');
            } else {
                // Try to find the option by text
                for ($i = 1; $i <= 4; $i++) {
                    if (trim($row["option_{$i}"] ?? '') === $answer) {
                        $index = $i - 1;
                        break;
                    }
                }

                if (!isset($index)) {
                    throw new \Exception("الإجابة '{$answer}' غير صحيحة في السطر {$rowNumber}");
                }
            }

            if ($index < 0 || $index > 3) {
                throw new \Exception("رقم الإجابة يجب أن يكون بين 1 و 4 في السطر {$rowNumber}");
            }

            $indices[] = $index;
        }

        if (count($indices) < 1) {
            throw new \Exception("يجب تحديد إجابة صحيحة واحدة على الأقل في السطر {$rowNumber}");
        }

        return array_unique($indices);
    }

    /**
     * Process true/false correct answer.
     */
    protected function processTrueFalseAnswer(Collection $row, int $rowNumber): array
    {
        $correctAnswer = strtolower(trim($row['correct_answer'] ?? ''));

        if ($correctAnswer === 'true' || $correctAnswer === 'صحيح' || $correctAnswer === '1') {
            return ['answer' => 'true'];
        } elseif ($correctAnswer === 'false' || $correctAnswer === 'خطأ' || $correctAnswer === '0') {
            return ['answer' => 'false'];
        } else {
            throw new \Exception("الإجابة يجب أن تكون 'true' أو 'false' (أو 'صحيح'/'خطأ') في السطر {$rowNumber}");
        }
    }

    /**
     * Process short answer.
     */
    protected function processShortAnswer(Collection $row, int $rowNumber): array
    {
        $modelAnswer = trim($row['correct_answer'] ?? '');

        if (empty($modelAnswer)) {
            throw new \Exception("الإجابة النموذجية مطلوبة في السطر {$rowNumber}");
        }

        $keywords = trim($row['keywords'] ?? '');

        return [
            'model_answer' => $modelAnswer,
            'keywords' => !empty($keywords) ? $keywords : null,
        ];
    }

    /**
     * Validate difficulty level.
     */
    protected function validateDifficulty(?string $difficulty): ?string
    {
        if (empty($difficulty)) {
            return null;
        }

        $difficulty = strtolower(trim($difficulty));

        $validLevels = ['easy', 'medium', 'hard', 'سهل', 'متوسط', 'صعب'];

        if (!in_array($difficulty, $validLevels)) {
            return null;
        }

        // Map Arabic to English
        $mapping = [
            'سهل' => 'easy',
            'متوسط' => 'medium',
            'صعب' => 'hard',
        ];

        return $mapping[$difficulty] ?? $difficulty;
    }

    /**
     * Parse tags from comma-separated string.
     */
    protected function parseTags(string $tags): ?array
    {
        if (empty($tags)) {
            return null;
        }

        $tagsArray = array_map('trim', explode(',', $tags));
        $tagsArray = array_filter($tagsArray); // Remove empty values

        return !empty($tagsArray) ? array_values($tagsArray) : null;
    }

    /**
     * Get the transformed questions.
     */
    public function getQuestions(): array
    {
        return $this->questions;
    }

    /**
     * Get validation errors.
     */
    public function getErrors(): array
    {
        return $this->errors;
    }

    /**
     * Check if import has errors.
     */
    public function hasErrors(): bool
    {
        return !empty($this->errors);
    }

    /**
     * Validation rules for the import.
     */
    public function rules(): array
    {
        return [
            'question_text_ar' => 'required|string|max:1000',
            'question_type' => 'required|string|in:single_choice,multiple_choice,true_false,short_answer,mcq_single,mcq_multiple',
            'correct_answer' => 'required|string',
            'points' => 'nullable|integer|min:1',
        ];
    }

    /**
     * Custom validation messages.
     */
    public function customValidationMessages(): array
    {
        return [
            'question_text_ar.required' => 'نص السؤال مطلوب',
            'question_text_ar.max' => 'نص السؤال يجب أن لا يتجاوز 1000 حرف',
            'question_type.required' => 'نوع السؤال مطلوب',
            'question_type.in' => 'نوع السؤال غير صحيح',
            'correct_answer.required' => 'الإجابة الصحيحة مطلوبة',
            'points.integer' => 'النقاط يجب أن تكون رقم صحيح',
            'points.min' => 'النقاط يجب أن تكون 1 على الأقل',
        ];
    }
}
