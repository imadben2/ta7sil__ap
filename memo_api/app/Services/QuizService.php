<?php

namespace App\Services;

use App\Models\Quiz;
use App\Models\QuizQuestion;
use App\Models\User;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;

class QuizService
{
    /**
     * Create a new quiz
     */
    public function createQuiz(array $data, User $creator): Quiz
    {
        DB::beginTransaction();

        try {
            // Generate slug if not provided
            if (empty($data['slug'])) {
                $data['slug'] = Str::slug($data['title_ar'] . '-' . Str::random(6));
            }

            // Set creator
            $data['created_by'] = $creator->id;

            // Create quiz
            $quiz = Quiz::create($data);

            DB::commit();

            return $quiz;

        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Update a quiz
     */
    public function updateQuiz(Quiz $quiz, array $data): Quiz
    {
        DB::beginTransaction();

        try {
            // Update slug if title changed
            if (isset($data['title_ar']) && $data['title_ar'] !== $quiz->title_ar) {
                $data['slug'] = Str::slug($data['title_ar'] . '-' . $quiz->id);
            }

            $quiz->update($data);

            DB::commit();

            return $quiz->fresh();

        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Publish a quiz
     */
    public function publishQuiz(Quiz $quiz): Quiz
    {
        // Validate quiz has questions
        if ($quiz->questions()->count() === 0) {
            throw new \Exception('Cannot publish a quiz without questions');
        }

        $quiz->is_published = true;
        $quiz->save();

        return $quiz;
    }

    /**
     * Unpublish a quiz
     */
    public function unpublishQuiz(Quiz $quiz): Quiz
    {
        $quiz->is_published = false;
        $quiz->save();

        return $quiz;
    }

    /**
     * Delete a quiz
     */
    public function deleteQuiz(Quiz $quiz): bool
    {
        // Soft delete
        return $quiz->delete();
    }

    /**
     * Add a question to a quiz
     */
    public function addQuestion(Quiz $quiz, array $questionData): QuizQuestion
    {
        DB::beginTransaction();

        try {
            // Set order if not provided
            if (!isset($questionData['question_order'])) {
                $questionData['question_order'] = $quiz->questions()->max('question_order') + 1;
            }

            // Create question
            $question = $quiz->questions()->create($questionData);

            // Update quiz statistics
            $quiz->updateStatistics();

            DB::commit();

            return $question;

        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Update a question
     */
    public function updateQuestion(QuizQuestion $question, array $data): QuizQuestion
    {
        DB::beginTransaction();

        try {
            $question->update($data);

            // Update quiz statistics if points changed
            if (isset($data['points'])) {
                $question->quiz->updateStatistics();
            }

            DB::commit();

            return $question->fresh();

        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Delete a question
     */
    public function deleteQuestion(QuizQuestion $question): bool
    {
        DB::beginTransaction();

        try {
            $quiz = $question->quiz;

            // Delete question
            $deleted = $question->delete();

            // Reorder remaining questions
            $this->reorderAfterDeletion($quiz, $question->question_order);

            // Update quiz statistics
            $quiz->updateStatistics();

            DB::commit();

            return $deleted;

        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Reorder questions
     */
    public function reorderQuestions(Quiz $quiz, array $order): bool
    {
        DB::beginTransaction();

        try {
            foreach ($order as $index => $questionId) {
                QuizQuestion::where('id', $questionId)
                    ->where('quiz_id', $quiz->id)
                    ->update(['question_order' => $index + 1]);
            }

            DB::commit();

            return true;

        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Duplicate a quiz
     */
    public function duplicateQuiz(Quiz $quiz, User $creator): Quiz
    {
        DB::beginTransaction();

        try {
            // Clone quiz
            $newQuiz = $quiz->replicate();
            $newQuiz->title_ar = $quiz->title_ar . ' (نسخة)';
            $newQuiz->slug = Str::slug($newQuiz->title_ar . '-' . Str::random(6));
            $newQuiz->is_published = false;
            $newQuiz->created_by = $creator->id;
            $newQuiz->total_questions = 0;
            $newQuiz->average_score = 0;
            $newQuiz->total_attempts = 0;
            $newQuiz->save();

            // Clone questions
            foreach ($quiz->questions as $question) {
                $newQuestion = $question->replicate();
                $newQuestion->quiz_id = $newQuiz->id;
                $newQuestion->save();
            }

            // Update statistics
            $newQuiz->updateStatistics();

            DB::commit();

            return $newQuiz;

        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Reorder questions after deletion
     */
    protected function reorderAfterDeletion(Quiz $quiz, int $deletedOrder): void
    {
        QuizQuestion::where('quiz_id', $quiz->id)
            ->where('question_order', '>', $deletedOrder)
            ->decrement('question_order');
    }

    /**
     * Validate question data based on type
     */
    public function validateQuestionData(string $questionType, array $data): array
    {
        $errors = [];

        switch ($questionType) {
            case QuizQuestion::TYPE_SINGLE_CHOICE:
            case QuizQuestion::TYPE_MULTIPLE_CHOICE:
                if (empty($data['options']) || !is_array($data['options'])) {
                    $errors[] = 'Options are required for multiple choice questions';
                }
                if (empty($data['correct_answer'])) {
                    $errors[] = 'Correct answer is required';
                }
                break;

            case QuizQuestion::TYPE_TRUE_FALSE:
                if (!isset($data['correct_answer']['answer'])) {
                    $errors[] = 'Correct answer is required for true/false questions';
                }
                break;

            case QuizQuestion::TYPE_MATCHING:
                if (empty($data['options']['left']) || empty($data['options']['right'])) {
                    $errors[] = 'Both left and right items are required for matching questions';
                }
                if (empty($data['correct_answer']['pairs'])) {
                    $errors[] = 'Correct pairs are required';
                }
                break;

            case QuizQuestion::TYPE_ORDERING:
                if (empty($data['options']) || !is_array($data['options'])) {
                    $errors[] = 'Items to order are required';
                }
                if (empty($data['correct_answer']['order'])) {
                    $errors[] = 'Correct order is required';
                }
                break;

            case QuizQuestion::TYPE_FILL_BLANK:
                if (empty($data['correct_answer']['answer'])) {
                    $errors[] = 'Correct answer is required for fill blank questions';
                }
                break;

            case QuizQuestion::TYPE_NUMERIC:
                if (!isset($data['correct_answer']['answer'])) {
                    $errors[] = 'Correct answer is required for numeric questions';
                }
                break;

            case QuizQuestion::TYPE_SHORT_ANSWER:
                if (empty($data['correct_answer']['model_answer']) && empty($data['correct_answer']['keywords'])) {
                    $errors[] = 'Either model answer or keywords are required for short answer questions';
                }
                break;
        }

        return $errors;
    }

    /**
     * Get quiz statistics
     */
    public function getQuizStatistics(Quiz $quiz): array
    {
        $attempts = $quiz->attempts()->completed()->get();

        return [
            'total_attempts' => $attempts->count(),
            'average_score' => $attempts->avg('score_percentage') ?? 0,
            'best_score' => $attempts->max('score_percentage') ?? 0,
            'worst_score' => $attempts->min('score_percentage') ?? 0,
            'pass_rate' => $attempts->where('passed', true)->count() / max(1, $attempts->count()) * 100,
            'average_time_spent' => $attempts->avg('time_spent_seconds') ?? 0,
            'completion_rate' => $quiz->attempts()->completed()->count() / max(1, $quiz->attempts()->count()) * 100,
        ];
    }

    /**
     * Create a quiz with imported questions from Excel
     */
    public function createQuizWithImportedQuestions(array $quizData, array $questions): Quiz
    {
        DB::beginTransaction();

        try {
            // Generate slug
            if (empty($quizData['slug'])) {
                $quizData['slug'] = Str::slug($quizData['title_ar'] . '-' . Str::random(6));
            }

            // Create the quiz
            $quiz = Quiz::create($quizData);

            // Prepare questions for bulk insert
            $questionsToInsert = [];
            $order = 1;

            foreach ($questions as $questionData) {
                $questionsToInsert[] = [
                    'quiz_id' => $quiz->id,
                    'question_type' => $questionData['question_type'],
                    'question_text_ar' => $questionData['question_text_ar'],
                    'question_image_url' => $questionData['question_image_url'],
                    'options' => !empty($questionData['options']) ? json_encode($questionData['options']) : null,
                    'correct_answer' => json_encode($questionData['correct_answer']),
                    'points' => $questionData['points'],
                    'explanation_ar' => $questionData['explanation_ar'],
                    'difficulty' => $questionData['difficulty'],
                    'tags' => !empty($questionData['tags']) ? json_encode($questionData['tags']) : null,
                    'question_order' => $order++,
                    'created_at' => now(),
                    'updated_at' => now(),
                ];
            }

            // Bulk insert questions
            QuizQuestion::insert($questionsToInsert);

            // Update quiz total_questions
            $quiz->update([
                'total_questions' => count($questionsToInsert)
            ]);

            DB::commit();

            return $quiz->fresh();

        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }
}
