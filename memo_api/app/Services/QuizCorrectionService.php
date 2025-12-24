<?php

namespace App\Services;

use App\Models\QuizQuestion;

class QuizCorrectionService
{
    /**
     * Correct a single choice question
     *
     * Supports multiple formats:
     * - Legacy format: correct_answer = ['answer' => index]
     * - Array of indices: correct_answer = [0, 2] (indices of correct options)
     * - User answer can be: index (int) or {'answer': index}
     */
    public function correctSingleChoice(QuizQuestion $question, $userAnswer): bool
    {
        // Extract user's selected index
        $userIndex = $this->extractUserAnswerIndex($userAnswer);

        if ($userIndex === null) {
            return false;
        }

        // Get correct answer(s)
        $correctAnswer = $question->correct_answer;

        // Handle legacy format: {'answer': index}
        if (is_array($correctAnswer) && isset($correctAnswer['answer'])) {
            return $userIndex === $correctAnswer['answer'];
        }

        // Handle array of indices format: [0, 2, 3]
        if (is_array($correctAnswer)) {
            // For single choice, user is correct if they selected any of the correct indices
            return in_array($userIndex, $correctAnswer, true) || in_array((string)$userIndex, $correctAnswer, true);
        }

        // Handle single index: correctAnswer = 1
        if (is_numeric($correctAnswer)) {
            return $userIndex === (int)$correctAnswer;
        }

        return false;
    }

    /**
     * Extract user answer index from various formats
     */
    protected function extractUserAnswerIndex($userAnswer): ?int
    {
        if (is_numeric($userAnswer)) {
            return (int)$userAnswer;
        }

        if (is_array($userAnswer)) {
            if (isset($userAnswer['answer'])) {
                return is_numeric($userAnswer['answer']) ? (int)$userAnswer['answer'] : null;
            }
            // First element if array
            if (!empty($userAnswer)) {
                $first = reset($userAnswer);
                return is_numeric($first) ? (int)$first : null;
            }
        }

        return null;
    }

    /**
     * Correct a multiple choice question
     *
     * Supports multiple formats:
     * - Legacy format: correct_answer = ['answers' => [0, 2]]
     * - Array of indices: correct_answer = [0, 2] (indices of correct options)
     * - User answer can be: [0, 2] or {'answers': [0, 2]}
     */
    public function correctMultipleChoice(QuizQuestion $question, $userAnswers): bool
    {
        // Extract user's selected indices
        $userIndices = $this->extractUserAnswerIndices($userAnswers);

        if (empty($userIndices)) {
            return false;
        }

        // Get correct answer(s)
        $correctAnswer = $question->correct_answer;

        // Handle legacy format: {'answers': [0, 2]}
        if (is_array($correctAnswer) && isset($correctAnswer['answers'])) {
            $correctIndices = array_map('intval', $correctAnswer['answers']);
        } elseif (is_array($correctAnswer)) {
            // Handle array of indices format: [0, 2]
            $correctIndices = array_map('intval', $correctAnswer);
        } else {
            return false;
        }

        if (empty($correctIndices)) {
            return false;
        }

        // Sort both arrays for comparison
        sort($userIndices);
        sort($correctIndices);

        return $userIndices === $correctIndices;
    }

    /**
     * Extract user answer indices from various formats
     */
    protected function extractUserAnswerIndices($userAnswers): array
    {
        if (!is_array($userAnswers)) {
            return [];
        }

        // Handle {'answers': [0, 2]} format
        if (isset($userAnswers['answers']) && is_array($userAnswers['answers'])) {
            return array_map('intval', $userAnswers['answers']);
        }

        // Handle [0, 2] format directly
        return array_map('intval', array_values($userAnswers));
    }

    /**
     * Correct a true/false question
     */
    public function correctTrueFalse(QuizQuestion $question, $userAnswer): bool
    {
        $correctAnswer = $question->correct_answer['answer'] ?? null;

        if ($correctAnswer === null) {
            return false;
        }

        // Handle string "true"/"false" or boolean
        $userBool = is_bool($userAnswer) ? $userAnswer : ($userAnswer === 'true' || $userAnswer === true);
        $correctBool = is_bool($correctAnswer) ? $correctAnswer : ($correctAnswer === 'true' || $correctAnswer === true);

        return $userBool === $correctBool;
    }

    /**
     * Correct a matching question
     */
    public function correctMatching(QuizQuestion $question, $userPairs): bool
    {
        if (!is_array($userPairs)) {
            return false;
        }

        $correctPairs = $question->correct_answer['pairs'] ?? [];

        if (empty($correctPairs)) {
            return false;
        }

        // Convert to comparable format
        $correctFormatted = [];
        foreach ($correctPairs as $pair) {
            $correctFormatted[$pair['left']] = $pair['right'];
        }

        $userFormatted = [];
        foreach ($userPairs as $pair) {
            if (isset($pair['left']) && isset($pair['right'])) {
                $userFormatted[$pair['left']] = $pair['right'];
            }
        }

        return $correctFormatted === $userFormatted;
    }

    /**
     * Correct an ordering question
     */
    public function correctOrdering(QuizQuestion $question, $userOrder): bool
    {
        if (!is_array($userOrder)) {
            return false;
        }

        $correctOrder = $question->correct_answer['order'] ?? [];

        if (empty($correctOrder)) {
            return false;
        }

        return $userOrder === $correctOrder;
    }

    /**
     * Correct a fill-in-the-blank question
     * Supports multiple blanks with multiple correct answers per blank
     * @param QuizQuestion $question
     * @param array|string $userAnswers - can be array of answers or single string
     * @return bool
     */
    public function correctFillBlank(QuizQuestion $question, mixed $userAnswers): bool
    {
        // correct_answer is an array of arrays: [[answer1, alt1, alt2], [answer2, alt1], ...]
        $correctAnswers = $question->correct_answer ?? [];

        // Handle single answer case (legacy format)
        if (!is_array($userAnswers)) {
            $userAnswers = [$userAnswers];
        }

        // If correct_answer has 'answer' key (legacy format)
        if (isset($correctAnswers['answer'])) {
            $correctAnswer = $correctAnswers['answer'] ?? '';
            $alternatives = $correctAnswers['alternatives'] ?? [];

            $normalizedUser = $this->normalizeText($userAnswers[0] ?? '');
            $normalizedCorrect = $this->normalizeText($correctAnswer);

            if ($normalizedUser === $normalizedCorrect) {
                return true;
            }

            foreach ($alternatives as $alternative) {
                if ($normalizedUser === $this->normalizeText($alternative)) {
                    return true;
                }
            }

            return false;
        }

        // New format: array of arrays with possible answers for each blank
        if (count($userAnswers) !== count($correctAnswers)) {
            return false;
        }

        // Check each blank
        for ($i = 0; $i < count($correctAnswers); $i++) {
            $userAnswer = $userAnswers[$i] ?? '';
            $acceptedAnswers = $correctAnswers[$i] ?? [];

            // If it's not an array, wrap it
            if (!is_array($acceptedAnswers)) {
                $acceptedAnswers = [$acceptedAnswers];
            }

            $normalizedUser = $this->normalizeText($userAnswer);
            $found = false;

            foreach ($acceptedAnswers as $acceptedAnswer) {
                if ($normalizedUser === $this->normalizeText($acceptedAnswer)) {
                    $found = true;
                    break;
                }
            }

            if (!$found) {
                return false;
            }
        }

        return true;
    }

    /**
     * Correct a numeric question
     */
    public function correctNumeric(QuizQuestion $question, $userAnswer): bool
    {
        $correctAnswer = $question->correct_answer['answer'] ?? null;
        $tolerance = $question->correct_answer['tolerance'] ?? 0;

        if ($correctAnswer === null) {
            return false;
        }

        // Convert to float
        $userFloat = floatval($userAnswer);
        $correctFloat = floatval($correctAnswer);
        $toleranceFloat = floatval($tolerance);

        // Check if within tolerance
        $difference = abs($userFloat - $correctFloat);

        return $difference <= $toleranceFloat;
    }

    /**
     * Correct a short answer question (keyword matching or manual review)
     */
    public function correctShortAnswer(QuizQuestion $question, string $userAnswer)
    {
        $keywords = $question->correct_answer['keywords'] ?? [];
        $modelAnswer = $question->correct_answer['model_answer'] ?? '';

        if (empty($keywords)) {
            // Requires manual correction
            return 'manual';
        }

        // Normalize user answer
        $normalizedUser = $this->normalizeText($userAnswer);

        // Count matched keywords
        $matchedKeywords = 0;
        $totalKeywords = count($keywords);

        foreach ($keywords as $keyword) {
            $normalizedKeyword = $this->normalizeText($keyword);

            if (str_contains($normalizedUser, $normalizedKeyword)) {
                $matchedKeywords++;
            }
        }

        // Consider correct if at least 70% of keywords are present
        $matchPercentage = ($matchedKeywords / $totalKeywords) * 100;

        if ($matchPercentage >= 70) {
            return true;
        } elseif ($matchPercentage >= 40) {
            // Partial match - needs manual review
            return 'manual';
        } else {
            return false;
        }
    }

    /**
     * Correct any question type
     */
    public function correctQuestion(QuizQuestion $question, $userAnswer)
    {
        switch ($question->question_type) {
            case QuizQuestion::TYPE_SINGLE_CHOICE:
                return $this->correctSingleChoice($question, $userAnswer);

            case QuizQuestion::TYPE_MULTIPLE_CHOICE:
                return $this->correctMultipleChoice($question, $userAnswer);

            case QuizQuestion::TYPE_TRUE_FALSE:
                return $this->correctTrueFalse($question, $userAnswer);

            case QuizQuestion::TYPE_MATCHING:
                return $this->correctMatching($question, $userAnswer);

            case QuizQuestion::TYPE_ORDERING:
                return $this->correctOrdering($question, $userAnswer);

            case QuizQuestion::TYPE_FILL_BLANK:
                return $this->correctFillBlank($question, $userAnswer);

            case QuizQuestion::TYPE_NUMERIC:
                return $this->correctNumeric($question, $userAnswer);

            case QuizQuestion::TYPE_SHORT_ANSWER:
                return $this->correctShortAnswer($question, $userAnswer);

            default:
                return false;
        }
    }

    /**
     * Normalize text for comparison
     */
    protected function normalizeText(string $text): string
    {
        // Convert to lowercase
        $text = mb_strtolower($text, 'UTF-8');

        // Trim whitespace
        $text = trim($text);

        // Remove extra spaces
        $text = preg_replace('/\s+/', ' ', $text);

        // Remove Arabic diacritics (tashkeel)
        $text = preg_replace('/[\x{064B}-\x{065F}]/u', '', $text);

        // Normalize Arabic letters
        $text = str_replace(['أ', 'إ', 'آ'], 'ا', $text);
        $text = str_replace('ة', 'ه', $text);
        $text = str_replace('ى', 'ي', $text);

        return $text;
    }

    /**
     * Calculate partial credit for a question (if applicable)
     */
    public function calculatePartialCredit(QuizQuestion $question, $userAnswer): float
    {
        // Only certain question types support partial credit
        if ($question->question_type === QuizQuestion::TYPE_MULTIPLE_CHOICE) {
            return $this->calculateMultipleChoicePartialCredit($question, $userAnswer);
        }

        if ($question->question_type === QuizQuestion::TYPE_MATCHING) {
            return $this->calculateMatchingPartialCredit($question, $userAnswer);
        }

        // Default: either full credit or no credit
        $isCorrect = $this->correctQuestion($question, $userAnswer);
        return $isCorrect ? 1.0 : 0.0;
    }

    /**
     * Calculate partial credit for multiple choice
     */
    protected function calculateMultipleChoicePartialCredit(QuizQuestion $question, $userAnswers): float
    {
        // Extract user's selected indices
        $userIndices = $this->extractUserAnswerIndices($userAnswers);

        if (empty($userIndices)) {
            return 0.0;
        }

        // Get correct answer(s) - support both formats
        $correctAnswer = $question->correct_answer;
        if (is_array($correctAnswer) && isset($correctAnswer['answers'])) {
            $correctIndices = array_map('intval', $correctAnswer['answers']);
        } elseif (is_array($correctAnswer)) {
            $correctIndices = array_map('intval', $correctAnswer);
        } else {
            return 0.0;
        }

        if (empty($correctIndices)) {
            return 0.0;
        }

        // Count correct selections
        $correctSelections = count(array_intersect($userIndices, $correctIndices));

        // Count incorrect selections (penalty)
        $incorrectSelections = count(array_diff($userIndices, $correctIndices));

        $totalCorrect = count($correctIndices);

        // Partial credit formula: (correct - incorrect) / total
        $credit = ($correctSelections - $incorrectSelections) / $totalCorrect;

        return max(0.0, min(1.0, $credit));
    }

    /**
     * Calculate partial credit for matching
     */
    protected function calculateMatchingPartialCredit(QuizQuestion $question, $userPairs): float
    {
        if (!is_array($userPairs)) {
            return 0.0;
        }

        $correctPairs = $question->correct_answer['pairs'] ?? [];

        if (empty($correctPairs)) {
            return 0.0;
        }

        // Convert to comparable format
        $correctFormatted = [];
        foreach ($correctPairs as $pair) {
            $correctFormatted[$pair['left']] = $pair['right'];
        }

        $correctCount = 0;
        foreach ($userPairs as $pair) {
            if (isset($pair['left']) && isset($pair['right'])) {
                $left = $pair['left'];
                $right = $pair['right'];

                if (isset($correctFormatted[$left]) && $correctFormatted[$left] === $right) {
                    $correctCount++;
                }
            }
        }

        return $correctCount / count($correctPairs);
    }
}
