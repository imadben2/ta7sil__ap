<?php

namespace App\Services;

use App\Models\Quiz;
use App\Models\QuizAttempt;
use App\Models\QuizQuestion;
use App\Models\User;
use App\Models\UserQuizPerformance;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class QuizAttemptService
{
    protected QuizCorrectionService $correctionService;

    public function __construct(QuizCorrectionService $correctionService)
    {
        $this->correctionService = $correctionService;
    }

    /**
     * Start a new quiz attempt
     */
    public function startAttempt(User $user, Quiz $quiz, ?int $seed = null): QuizAttempt
    {
        // Check if user can start (no in-progress attempt)
        if (!$quiz->canUserStart($user)) {
            throw new \Exception('You already have an in-progress attempt for this quiz');
        }

        // Generate seed if not provided
        $attemptSeed = $seed ?? $this->generateSeed();

        // Create attempt
        $attempt = QuizAttempt::create([
            'user_id' => $user->id,
            'quiz_id' => $quiz->id,
            'started_at' => now(),
            'status' => QuizAttempt::STATUS_IN_PROGRESS,
            'total_questions' => $quiz->questions()->count(),
            'max_score' => $quiz->questions()->sum('points'),
            'answers' => [],
            'seed' => $attemptSeed,
        ]);

        return $attempt;
    }

    /**
     * Generate a random seed for question/answer shuffling
     */
    protected function generateSeed(): int
    {
        return random_int(1, PHP_INT_MAX);
    }

    /**
     * Get questions for an attempt (with shuffling if enabled)
     */
    public function getAttemptQuestions(QuizAttempt $attempt): array
    {
        $quiz = $attempt->quiz;
        $questions = $quiz->questions()->get();

        // Use stored seed or attempt ID as fallback for reproducible shuffling
        $seed = $attempt->seed ?? $attempt->id;

        // Shuffle questions if enabled
        if ($quiz->shuffle_questions) {
            $questions = $questions->shuffle($seed);
        }

        // Format questions for attempt
        $formattedQuestions = [];
        $questionNumber = 1;

        foreach ($questions as $question) {
            $formatted = $question->formatForAttempt($quiz->shuffle_answers, $seed);
            $formatted['question_number'] = $questionNumber++;
            $formattedQuestions[] = $formatted;
        }

        return $formattedQuestions;
    }

    /**
     * Save answer for a question
     */
    public function saveAnswer(QuizAttempt $attempt, int $questionId, $answer, ?int $timeSpent = null): void
    {
        // Validate attempt is in progress
        if (!$attempt->isInProgress()) {
            throw new \Exception('This attempt is not in progress');
        }

        // Validate question belongs to quiz
        $question = QuizQuestion::where('id', $questionId)
            ->where('quiz_id', $attempt->quiz_id)
            ->firstOrFail();

        // Save answer
        $attempt->saveAnswer($questionId, $answer, $timeSpent);
    }

    /**
     * Submit quiz attempt and calculate score
     */
    public function submitAttempt(QuizAttempt $attempt, ?array $finalAnswers = null): array
    {
        // Validate attempt is in progress
        if (!$attempt->isInProgress()) {
            throw new \Exception('This attempt is not in progress');
        }

        DB::beginTransaction();

        try {
            // Update with final answers if provided
            if ($finalAnswers) {
                foreach ($finalAnswers as $questionId => $answerData) {
                    $answer = $answerData['answer'] ?? $answerData;
                    $timeSpent = $answerData['time_spent'] ?? null;
                    $this->saveAnswer($attempt, $questionId, $answer, $timeSpent);
                }
            }

            // Grade the attempt
            $results = $this->gradeAttempt($attempt);

            // Update attempt status
            $attempt->status = QuizAttempt::STATUS_COMPLETED;
            $attempt->completed_at = now();
            $attempt->time_spent_seconds = $attempt->started_at->diffInSeconds($attempt->completed_at);
            $attempt->save();

            // Update statistics
            $this->updateStatistics($attempt);

            // Identify weak concepts
            $weakConcepts = $this->identifyWeakConcepts($attempt);

            // Update user quiz performance
            $this->updateUserQuizPerformance($attempt, $weakConcepts);

            DB::commit();

            return [
                'results' => $results,
                'weak_concepts' => $weakConcepts,
                'performance_message' => $attempt->getPerformanceMessage(),
            ];

        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Grade a quiz attempt
     */
    public function gradeAttempt(QuizAttempt $attempt): array
    {
        $quiz = $attempt->quiz;
        $questions = $quiz->questions()->get()->keyBy('id');
        $answers = $attempt->answers ?? [];

        $correctCount = 0;
        $incorrectCount = 0;
        $skippedCount = 0;
        $totalPoints = 0;
        $detailedResults = [];

        foreach ($questions as $questionId => $question) {
            $userAnswer = $answers[(string)$questionId] ?? null;

            if ($userAnswer === null || !isset($userAnswer['answer'])) {
                // Skipped question
                $skippedCount++;
                $detailedResults[$questionId] = [
                    'is_correct' => false,
                    'is_skipped' => true,
                    'points_earned' => 0,
                    'max_points' => $question->points,
                ];
                continue;
            }

            // Grade the answer
            $isCorrect = $this->correctionService->correctQuestion($question, $userAnswer['answer']);

            // Handle manual review flag
            if ($isCorrect === 'manual') {
                // Mark for manual review - give benefit of doubt for now
                $detailedResults[$questionId] = [
                    'is_correct' => null,
                    'needs_manual_review' => true,
                    'points_earned' => 0,
                    'max_points' => $question->points,
                ];
                $skippedCount++; // Count as skipped for now
                continue;
            }

            // Calculate points (with partial credit if applicable)
            $pointsEarned = 0;
            if ($isCorrect) {
                $pointsEarned = $question->points;
                $correctCount++;
            } else {
                // Check for partial credit
                $partialCredit = $this->correctionService->calculatePartialCredit($question, $userAnswer['answer']);
                if ($partialCredit > 0 && $partialCredit < 1) {
                    $pointsEarned = $question->points * $partialCredit;
                }
                $incorrectCount++;
            }

            $totalPoints += $pointsEarned;

            $detailedResults[$questionId] = [
                'is_correct' => $isCorrect,
                'points_earned' => $pointsEarned,
                'max_points' => $question->points,
                'partial_credit' => $partialCredit ?? null,
            ];
        }

        // Calculate percentage
        $scorePercentage = $attempt->max_score > 0 ? ($totalPoints / $attempt->max_score) * 100 : 0;
        $passed = $scorePercentage >= $quiz->passing_score;

        // Update attempt
        $attempt->correct_answers = $correctCount;
        $attempt->incorrect_answers = $incorrectCount;
        $attempt->skipped_answers = $skippedCount;
        $attempt->total_points = $totalPoints;
        $attempt->score_percentage = $scorePercentage;
        $attempt->passed = $passed;
        $attempt->save();

        return [
            'total_questions' => $attempt->total_questions,
            'correct_answers' => $correctCount,
            'incorrect_answers' => $incorrectCount,
            'skipped_answers' => $skippedCount,
            'score_percentage' => round($scorePercentage, 2),
            'total_points' => $totalPoints,
            'max_points' => $attempt->max_score,
            'passed' => $passed,
            'time_spent_seconds' => $attempt->time_spent_seconds,
            'detailed_results' => $detailedResults,
        ];
    }

    /**
     * Identify weak concepts from incorrect answers
     */
    public function identifyWeakConcepts(QuizAttempt $attempt): array
    {
        $quiz = $attempt->quiz;
        $questions = $quiz->questions()->get()->keyBy('id');
        $answers = $attempt->answers ?? [];
        $conceptStats = [];

        foreach ($questions as $questionId => $question) {
            $userAnswer = $answers[(string)$questionId] ?? null;

            if ($userAnswer === null || !isset($userAnswer['answer'])) {
                continue;
            }

            // Check if answer is correct
            $isCorrect = $this->correctionService->correctQuestion($question, $userAnswer['answer']);

            if ($isCorrect === 'manual') {
                continue; // Skip manual review questions
            }

            // Extract tags from question
            $tags = $question->tags ?? [];

            foreach ($tags as $tag) {
                if (!isset($conceptStats[$tag])) {
                    $conceptStats[$tag] = ['correct' => 0, 'total' => 0];
                }

                $conceptStats[$tag]['total']++;

                if ($isCorrect) {
                    $conceptStats[$tag]['correct']++;
                }
            }
        }

        // Calculate error rates and filter weak concepts
        $weakConcepts = [];

        foreach ($conceptStats as $tag => $stats) {
            if ($stats['total'] < 2) {
                continue; // Need at least 2 questions to identify as weak
            }

            $errorRate = ($stats['total'] - $stats['correct']) / $stats['total'];

            if ($errorRate >= 0.5) { // 50% or more errors
                $weakConcepts[] = [
                    'tag' => $tag,
                    'correct' => $stats['correct'],
                    'total' => $stats['total'],
                    'error_rate' => round($errorRate, 2),
                ];
            }
        }

        // Sort by error rate (highest first)
        usort($weakConcepts, function ($a, $b) {
            return $b['error_rate'] <=> $a['error_rate'];
        });

        return $weakConcepts;
    }

    /**
     * Get review data for completed attempt
     */
    public function getReview(QuizAttempt $attempt): array
    {
        if (!$attempt->isCompleted()) {
            throw new \Exception('Cannot review an incomplete attempt');
        }

        if (!$attempt->quiz->allow_review) {
            throw new \Exception('Review is not allowed for this quiz');
        }

        $quiz = $attempt->quiz;
        $questions = $quiz->questions()->get();
        $answers = $attempt->answers ?? [];
        $review = [];

        foreach ($questions as $question) {
            $userAnswer = $answers[(string)$question->id] ?? null;

            // Build the question object (matches QuestionModel in Flutter)
            $questionData = [
                'id' => $question->id,
                'question_order' => $question->question_order,
                'question_type' => $question->question_type,
                'question_text_ar' => $question->question_text_ar,
                'question_image_url' => $question->question_image_url,
                'options' => $question->options,
                'points' => $question->points,
                'explanation_ar' => $question->explanation_ar,
                'difficulty' => $question->difficulty,
                'tags' => $question->tags ?? [],
            ];

            $questionReview = [
                'question' => $questionData,
                'user_answer' => $userAnswer['answer'] ?? null,
                'correct_answer' => null,
                'is_correct' => false,
                'points_earned' => 0,
                'time_spent_seconds' => $userAnswer['time_spent'] ?? null,
            ];

            if ($userAnswer && isset($userAnswer['answer'])) {
                $isCorrect = $this->correctionService->correctQuestion($question, $userAnswer['answer']);

                if ($isCorrect !== 'manual') {
                    $questionReview['is_correct'] = (bool) $isCorrect;

                    // Always show correct answer in review mode (review is already gated by allow_review)
                    $questionReview['correct_answer'] = $question->correct_answer;

                    // Calculate points earned
                    if ($isCorrect) {
                        $questionReview['points_earned'] = $question->points;
                    } else {
                        $partialCredit = $this->correctionService->calculatePartialCredit($question, $userAnswer['answer']);
                        $questionReview['points_earned'] = $question->points * $partialCredit;
                    }
                }
            } else {
                $questionReview['is_correct'] = false;

                // Always show correct answer in review mode (review is already gated by allow_review)
                $questionReview['correct_answer'] = $question->correct_answer;
            }

            $review[] = $questionReview;
        }

        return $review;
    }

    /**
     * Abandon an in-progress attempt
     */
    public function abandonAttempt(QuizAttempt $attempt): void
    {
        if (!$attempt->isInProgress()) {
            throw new \Exception('This attempt is not in progress');
        }

        $attempt->status = QuizAttempt::STATUS_ABANDONED;
        $attempt->save();
    }

    /**
     * Update quiz statistics
     */
    protected function updateStatistics(QuizAttempt $attempt): void
    {
        $quiz = $attempt->quiz;
        $quiz->updateStatistics();
    }

    /**
     * Update user quiz performance
     */
    protected function updateUserQuizPerformance(QuizAttempt $attempt, array $weakConcepts): void
    {
        $performance = UserQuizPerformance::firstOrCreate(
            [
                'user_id' => $attempt->user_id,
                'quiz_id' => $attempt->quiz_id,
                'subject_id' => $attempt->quiz->subject_id,
            ],
            [
                'total_attempts' => 0,
                'best_score' => 0,
                'average_score' => 0,
                'total_time_spent_minutes' => 0,
            ]
        );

        $performance->updateFromAttempt($attempt);

        // Update weak concepts
        foreach ($weakConcepts as $concept) {
            $performance->addWeakConcept($concept['tag'], $concept['error_rate']);
        }
    }

    /**
     * Check if attempt is expired
     */
    public function checkExpiration(QuizAttempt $attempt): bool
    {
        if (!$attempt->isInProgress()) {
            return false;
        }

        if ($attempt->isExpired()) {
            // Auto-submit expired attempt
            $this->submitAttempt($attempt);
            return true;
        }

        return false;
    }

    /**
     * Get current in-progress attempt for user and quiz
     */
    public function getCurrentAttempt(User $user, Quiz $quiz): ?QuizAttempt
    {
        return QuizAttempt::where('user_id', $user->id)
            ->where('quiz_id', $quiz->id)
            ->where('status', QuizAttempt::STATUS_IN_PROGRESS)
            ->first();
    }
}
