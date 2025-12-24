<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\QuizAttempt;
use App\Services\QuizAttemptService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class QuizAttemptController extends Controller
{
    protected QuizAttemptService $attemptService;

    public function __construct(QuizAttemptService $attemptService)
    {
        $this->attemptService = $attemptService;
    }

    /**
     * POST /api/v1/quiz-attempts/{id}/answer
     * Save answer for a question
     */
    public function answer(Request $request, $id)
    {
        $attempt = QuizAttempt::findOrFail($id);

        // Verify ownership
        if ($attempt->user_id !== auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'question_id' => 'required|integer',
            'answer' => 'required',
            'time_spent' => 'nullable|integer',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            // Check if attempt is expired
            if ($this->attemptService->checkExpiration($attempt)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Quiz time has expired. Your answers have been submitted.',
                ], 400);
            }

            $this->attemptService->saveAnswer(
                $attempt,
                $request->question_id,
                $request->answer,
                $request->time_spent
            );

            // If practice mode with immediate feedback
            $quiz = $attempt->quiz;
            $response = [
                'success' => true,
                'message' => 'Answer saved',
            ];

            if ($quiz->quiz_type === 'practice' && $quiz->show_correct_answers) {
                // Provide immediate feedback
                $question = $quiz->questions()->find($request->question_id);

                if ($question) {
                    $correctionService = app(\App\Services\QuizCorrectionService::class);
                    $isCorrect = $correctionService->correctQuestion($question, $request->answer);

                    if ($isCorrect !== 'manual') {
                        $response['feedback'] = [
                            'is_correct' => $isCorrect,
                            'correct_answer' => $question->correct_answer,
                            'explanation_ar' => $question->explanation_ar,
                            'points_earned' => $isCorrect ? $question->points : 0,
                        ];
                    }
                }
            }

            return response()->json($response);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * POST /api/v1/quiz-attempts/{id}/submit
     * Submit quiz attempt
     */
    public function submit(Request $request, $id)
    {
        $attempt = QuizAttempt::with('quiz')->findOrFail($id);

        // Verify ownership
        if ($attempt->user_id !== auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'answers' => 'nullable|array',
            'final_answers' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            // Support both 'answers' and 'final_answers' parameter names
            $answersData = $request->input('answers') ?? $request->input('final_answers');
            $result = $this->attemptService->submitAttempt($attempt, $answersData);

            // Reload attempt to get updated values
            $attempt->refresh();

            // Add gamification points
            $pointsEarned = $this->calculateGamificationPoints($result['results']['score_percentage']);

            // Update user stats
            $user = auth()->user();
            if (isset($user->stats)) {
                $user->stats->increment('total_quiz_attempts');
                $user->stats->increment('total_quiz_correct', $result['results']['correct_answers']);
            }

            // Return Flutter-compatible format
            return response()->json([
                'success' => true,
                'data' => [
                    'attempt_id' => $attempt->id,
                    'quiz_id' => $attempt->quiz_id,
                    'quiz_title_ar' => $attempt->quiz->title_ar,
                    'subject_id' => $attempt->quiz->subject_id,
                    'subject_name_ar' => $attempt->quiz->subject->name_ar ?? 'الرياضيات',
                    'status' => 'completed',
                    'percentage' => $result['results']['score_percentage'],
                    'total_points' => $result['results']['max_points'],
                    'earned_points' => $result['results']['total_points'],
                    'passed' => $result['results']['passed'],
                    'passing_score' => $attempt->quiz->passing_score,
                    'correct_answers' => $result['results']['correct_answers'],
                    'incorrect_answers' => $result['results']['incorrect_answers'],
                    'skipped_answers' => $result['results']['skipped_answers'],
                    'total_questions' => $result['results']['total_questions'],
                    'time_spent_seconds' => $attempt->time_spent_seconds,
                    'completed_at' => $attempt->completed_at->toIso8601String(),
                    'weak_concepts' => array_map(fn($c) => $c['tag'], $result['weak_concepts']),
                    'allow_review' => $attempt->quiz->allow_review,
                    'performance_message' => $result['performance_message'],
                    'gamification' => [
                        'points_earned' => $pointsEarned,
                        'new_total' => $user->points ?? 0,
                        'badge_earned' => null,
                    ],
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * GET /api/v1/quiz-attempts/{id}/results
     * Get quiz results (summary without full review)
     */
    public function results($id)
    {
        $attempt = QuizAttempt::with('quiz.subject')->findOrFail($id);

        // Verify ownership
        if ($attempt->user_id !== auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        // Verify attempt is completed
        if ($attempt->status !== QuizAttempt::STATUS_COMPLETED) {
            return response()->json([
                'success' => false,
                'message' => 'Attempt is not completed yet',
            ], 400);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'attempt_id' => $attempt->id,
                'quiz_id' => $attempt->quiz_id,
                'quiz_title_ar' => $attempt->quiz->title_ar,
                'subject_id' => $attempt->quiz->subject_id,
                'subject_name_ar' => $attempt->quiz->subject->name_ar ?? 'الرياضيات',
                'percentage' => $attempt->score_percentage,
                'total_points' => $attempt->max_score,
                'earned_points' => $attempt->total_points,
                'passed' => $attempt->passed,
                'passing_score' => $attempt->quiz->passing_score,
                'correct_answers' => $attempt->correct_answers,
                'incorrect_answers' => $attempt->incorrect_answers,
                'skipped_answers' => $attempt->skipped_answers,
                'total_questions' => $attempt->total_questions,
                'time_spent_seconds' => $attempt->time_spent_seconds,
                'completed_at' => $attempt->completed_at?->toIso8601String(),
                'allow_review' => $attempt->quiz->allow_review,
                'performance_message' => $attempt->getPerformanceMessage(),
            ],
        ]);
    }

    /**
     * GET /api/v1/quiz-attempts/{id}/review
     * Review completed attempt
     */
    public function review($id)
    {
        $attempt = QuizAttempt::with('quiz')->findOrFail($id);

        // Verify ownership
        if ($attempt->user_id !== auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        try {
            $review = $this->attemptService->getReview($attempt);

            // Return Flutter-compatible format
            return response()->json([
                'success' => true,
                'data' => [
                    'attempt_id' => $attempt->id,
                    'quiz_id' => $attempt->quiz_id,
                    'quiz_title_ar' => $attempt->quiz->title_ar,
                    'subject_id' => $attempt->quiz->subject_id,
                    'subject_name_ar' => $attempt->quiz->subject->name_ar ?? 'الرياضيات',
                    'percentage' => $attempt->score_percentage,
                    'total_points' => $attempt->max_score,
                    'earned_points' => $attempt->total_points,
                    'passed' => $attempt->passed,
                    'passing_score' => $attempt->quiz->passing_score,
                    'correct_answers' => $attempt->correct_answers,
                    'incorrect_answers' => $attempt->incorrect_answers,
                    'skipped_answers' => $attempt->skipped_answers,
                    'total_questions' => $attempt->total_questions,
                    'time_spent_seconds' => $attempt->time_spent_seconds,
                    'completed_at' => $attempt->completed_at?->toIso8601String(),
                    'allow_review' => $attempt->quiz->allow_review,
                    'questions' => $review,
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * GET /api/v1/quiz-attempts/current
     * Get current in-progress attempt
     */
    public function current(Request $request)
    {
        $user = auth()->user();

        $attempt = QuizAttempt::where('user_id', $user->id)
            ->where('status', QuizAttempt::STATUS_IN_PROGRESS)
            ->with('quiz')
            ->first();

        if (!$attempt) {
            return response()->json([
                'success' => true,
                'data' => [
                    'has_active_attempt' => false,
                    'attempt' => null,
                ],
            ]);
        }

        // Check if expired
        if ($this->attemptService->checkExpiration($attempt)) {
            return response()->json([
                'success' => true,
                'data' => [
                    'has_active_attempt' => false,
                    'attempt' => null,
                    'message' => 'Your previous attempt has been auto-submitted due to timeout',
                ],
            ]);
        }

        // Get questions for the attempt
        $questions = $this->attemptService->getAttemptQuestions($attempt);

        // Return Flutter-compatible format
        return response()->json([
            'success' => true,
            'data' => [
                'has_active_attempt' => true,
                'attempt' => [
                    'id' => $attempt->id,
                    'quiz_id' => $attempt->quiz_id,
                    'user_id' => $attempt->user_id,
                    'started_at' => $attempt->started_at->toIso8601String(),
                    'completed_at' => null,
                    'expires_at' => $attempt->getExpiresAt()?->toIso8601String(),
                    'status' => $attempt->status,
                    'time_limit_seconds' => $attempt->quiz->time_limit_minutes ? $attempt->quiz->time_limit_minutes * 60 : null,
                    'time_spent_seconds' => $attempt->started_at->diffInSeconds(now()),
                    'total_questions' => $attempt->total_questions,
                    'quiz' => [
                        'id' => $attempt->quiz->id,
                        'title_ar' => $attempt->quiz->title_ar,
                        'quiz_type' => $attempt->quiz->quiz_type,
                        'passing_score' => $attempt->quiz->passing_score,
                    ],
                    'questions' => $questions,
                    'answers' => $attempt->answers ?? [],
                ],
            ],
        ]);
    }

    /**
     * DELETE /api/v1/quiz-attempts/{id}/abandon
     * Abandon an in-progress attempt
     */
    public function abandon($id)
    {
        $attempt = QuizAttempt::findOrFail($id);

        // Verify ownership
        if ($attempt->user_id !== auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        try {
            $this->attemptService->abandonAttempt($attempt);

            return response()->json([
                'success' => true,
                'message' => 'Attempt abandoned',
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Calculate gamification points based on score
     */
    protected function calculateGamificationPoints(float $scorePercentage): int
    {
        if ($scorePercentage >= 95) {
            return 20;
        } elseif ($scorePercentage >= 85) {
            return 15;
        } elseif ($scorePercentage >= 75) {
            return 12;
        } elseif ($scorePercentage >= 65) {
            return 10;
        } elseif ($scorePercentage >= 50) {
            return 7;
        } else {
            return 5;
        }
    }
}
