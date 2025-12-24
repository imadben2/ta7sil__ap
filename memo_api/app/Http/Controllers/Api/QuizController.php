<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Quiz;
use App\Models\Subject;
use App\Services\QuizAttemptService;
use App\Services\QuizRecommendationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class QuizController extends Controller
{
    protected QuizAttemptService $attemptService;
    protected QuizRecommendationService $recommendationService;

    public function __construct(
        QuizAttemptService $attemptService,
        QuizRecommendationService $recommendationService
    ) {
        $this->attemptService = $attemptService;
        $this->recommendationService = $recommendationService;
    }

    /**
     * GET /api/v1/quizzes
     * List quizzes with filters
     */
    public function index(Request $request)
    {
        $query = Quiz::published()->with(['subject', 'chapter', 'academicStream']);
        $user = auth()->user();

        // Filter by year_id and/or stream_id from request (explicit filters take priority)
        $hasExplicitStreamFilter = $request->filled('stream_id') || $request->filled('year_id');

        if ($hasExplicitStreamFilter) {
            // Direct filter on quiz's academic_stream_id if provided
            if ($request->filled('stream_id')) {
                $query->byStream($request->stream_id);
            }

            // Also filter by subjects matching year_id if provided
            if ($request->filled('year_id')) {
                $subjectQuery = Subject::where('academic_year_id', $request->year_id);
                $filterSubjectIds = $subjectQuery->pluck('id');
                if ($filterSubjectIds->isNotEmpty()) {
                    $query->whereIn('subject_id', $filterSubjectIds);
                }
            }
        } elseif ($request->input('academic_filter', false)) {
            // Apply academic profile filter based on user's year AND stream
            $academicProfile = $user->academicProfile;
            if ($academicProfile) {
                // Direct filter on quiz's academic_stream_id (priority)
                if ($academicProfile->academic_stream_id) {
                    $query->byStream($academicProfile->academic_stream_id);
                }

                // Also filter by subjects matching academic year
                if ($academicProfile->academic_year_id) {
                    $subjectQuery = Subject::where('academic_year_id', $academicProfile->academic_year_id);
                    $academicSubjectIds = $subjectQuery->pluck('id');
                    if ($academicSubjectIds->isNotEmpty()) {
                        $query->whereIn('subject_id', $academicSubjectIds);
                    }
                }

                // Fallback: if academic filter would return empty results, show all published quizzes
                if ((clone $query)->count() === 0) {
                    $query = Quiz::published()->with(['subject', 'chapter', 'academicStream']);
                }
            }
        }

        // Filter by user's selected subjects only (skip if would return empty)
        if ($request->input('my_subjects_only', false)) {
            $userSubjectIds = $user->subjects()->pluck('subjects.id');
            if ($userSubjectIds->isNotEmpty()) {
                $query->whereIn('subject_id', $userSubjectIds);
            }
        }

        // Final fallback: if query would return empty, return all published quizzes
        if ((clone $query)->count() === 0) {
            $query = Quiz::published()->with(['subject', 'chapter', 'academicStream']);
        }

        // Filter by subject
        if ($request->filled('subject_id')) {
            $query->where('subject_id', $request->subject_id);
        }

        // Filter by chapter
        if ($request->filled('chapter_id')) {
            $query->where('chapter_id', $request->chapter_id);
        }

        // Filter by difficulty
        if ($request->filled('difficulty')) {
            $query->where('difficulty_level', $request->difficulty);
        }

        // Filter by tags
        if ($request->filled('tags')) {
            $tags = explode(',', $request->tags);
            $query->byTags($tags);
        }

        // Filter by duration
        if ($request->filled('duration')) {
            switch ($request->duration) {
                case 'short':
                    $query->where('estimated_duration_minutes', '<', 15);
                    break;
                case 'medium':
                    $query->whereBetween('estimated_duration_minutes', [15, 30]);
                    break;
                case 'long':
                    $query->where('estimated_duration_minutes', '>', 30);
                    break;
            }
        }

        // Filter by type (support both 'type' and 'quiz_type' parameter names)
        if ($request->filled('type') || $request->filled('quiz_type')) {
            $query->where('quiz_type', $request->input('type') ?? $request->input('quiz_type'));
        }

        // Pagination with configurable per_page
        $perPage = $request->input('per_page', 20);
        $quizzes = $query->paginate($perPage);

        // Transform to Flutter-compatible format
        $quizzes->getCollection()->transform(function ($quiz) use ($user) {
            return [
                'id' => $quiz->id,
                'title_ar' => $quiz->title_ar,
                'description_ar' => $quiz->description_ar,
                'academic_stream_id' => $quiz->academic_stream_id,
                'academic_stream' => $quiz->academicStream ? [
                    'id' => $quiz->academicStream->id,
                    'name_ar' => $quiz->academicStream->name_ar,
                    'slug' => $quiz->academicStream->slug,
                ] : null,
                'subject' => $quiz->subject ? [
                    'id' => $quiz->subject->id,
                    'name_ar' => $quiz->subject->name_ar,
                    'name_en' => $quiz->subject->name_en,
                    'name_fr' => $quiz->subject->name_fr ?? null,
                    'color' => $quiz->subject->color ?? '#2196F3',
                    'icon' => $quiz->subject->icon ?? null,
                ] : null,
                'chapter' => $quiz->chapter ? [
                    'id' => $quiz->chapter->id,
                    'name_ar' => $quiz->chapter->title_ar,
                ] : null,
                'difficulty_level' => $quiz->difficulty_level,
                'time_limit_minutes' => $quiz->time_limit_minutes,
                'estimated_duration_minutes' => $quiz->estimated_duration_minutes,
                'total_questions' => $quiz->total_questions,
                'quiz_type' => $quiz->quiz_type,
                'passing_score' => $quiz->passing_score,
                'average_score' => $quiz->average_score ? round($quiz->average_score, 1) : null,
                'total_attempts' => $quiz->total_attempts,
                'is_premium' => $quiz->is_premium,
                'tags' => $quiz->tags,
                'user_stats' => [
                    'attempts_count' => $quiz->attempts()->where('user_id', $user->id)->count(),
                    'best_score' => $quiz->getUserBestScore($user),
                    'last_attempt_at' => $quiz->getUserLastAttempt($user)?->completed_at?->toIso8601String(),
                    'has_in_progress' => $quiz->attempts()->where('user_id', $user->id)->where('status', 'in_progress')->exists(),
                ],
            ];
        });

        return response()->json([
            'success' => true,
            'data' => [
                'quizzes' => $quizzes->items(),
                'meta' => [
                    'total' => $quizzes->total(),
                    'per_page' => $quizzes->perPage(),
                    'current_page' => $quizzes->currentPage(),
                    'last_page' => $quizzes->lastPage(),
                    'from' => $quizzes->firstItem(),
                    'to' => $quizzes->lastItem(),
                ],
            ],
        ]);
    }

    /**
     * GET /api/v1/quizzes/{id}
     * Get quiz details
     */
    public function show($id)
    {
        $quiz = Quiz::published()
            ->with(['subject', 'chapter', 'academicStream'])
            ->findOrFail($id);

        $user = auth()->user();

        return response()->json([
            'success' => true,
            'data' => [
                'quiz' => [
                    'id' => $quiz->id,
                    'title_ar' => $quiz->title_ar,
                    'description_ar' => $quiz->description_ar,
                    'academic_stream_id' => $quiz->academic_stream_id,
                    'academic_stream' => $quiz->academicStream ? [
                        'id' => $quiz->academicStream->id,
                        'name_ar' => $quiz->academicStream->name_ar,
                        'slug' => $quiz->academicStream->slug,
                    ] : null,
                    'subject' => $quiz->subject ? [
                        'id' => $quiz->subject->id,
                        'name_ar' => $quiz->subject->name_ar,
                        'name_en' => $quiz->subject->name_en,
                        'name_fr' => $quiz->subject->name_fr ?? null,
                        'color' => $quiz->subject->color ?? '#2196F3',
                        'icon' => $quiz->subject->icon ?? null,
                    ] : null,
                    'chapter' => $quiz->chapter ? [
                        'id' => $quiz->chapter->id,
                        'name_ar' => $quiz->chapter->title_ar,
                    ] : null,
                    'difficulty_level' => $quiz->difficulty_level,
                    'time_limit_minutes' => $quiz->time_limit_minutes,
                    'estimated_duration_minutes' => $quiz->estimated_duration_minutes,
                    'total_questions' => $quiz->total_questions,
                    'passing_score' => $quiz->passing_score,
                    'quiz_type' => $quiz->quiz_type,
                    'shuffle_questions' => $quiz->shuffle_questions,
                    'shuffle_answers' => $quiz->shuffle_answers,
                    'show_correct_answers' => $quiz->show_correct_answers,
                    'allow_review' => $quiz->allow_review,
                    'is_premium' => $quiz->is_premium,
                    'tags' => $quiz->tags,
                    'average_score' => $quiz->average_score ? round($quiz->average_score, 1) : null,
                    'total_attempts' => $quiz->total_attempts,
                ],
                'user_stats' => [
                    'attempts_count' => $quiz->attempts()->where('user_id', $user->id)->count(),
                    'best_score' => $quiz->getUserBestScore($user),
                    'average_score' => $quiz->getUserAverageScore($user),
                    'last_attempt_at' => $quiz->getUserLastAttempt($user)?->completed_at?->toIso8601String(),
                    'last_attempt_id' => $quiz->getUserLastAttempt($user)?->id,
                    'has_in_progress' => $quiz->attempts()->where('user_id', $user->id)->where('status', 'in_progress')->exists(),
                ],
                'can_start' => $quiz->canUserStart($user),
            ],
        ]);
    }

    /**
     * POST /api/v1/quizzes/{id}/start
     * Start a new quiz attempt or resume existing in-progress attempt
     */
    public function start(Request $request, $id)
    {
        $quiz = Quiz::published()->findOrFail($id);
        $user = auth()->user();

        // Check premium access
        if ($quiz->is_premium) {
            $hasActiveSubscription = $user->subscriptions()
                ->where('status', 'active')
                ->where('expires_at', '>', now())
                ->exists();

            if (!$hasActiveSubscription) {
                return response()->json([
                    'success' => false,
                    'message' => 'هذا الاختبار متاح للمشتركين فقط. يرجى الاشتراك للوصول إلى المحتوى المميز.',
                    'error_code' => 'PREMIUM_REQUIRED',
                ], 403);
            }
        }

        try {
            // Check for existing in-progress attempt first
            $existingAttempt = $this->attemptService->getCurrentAttempt($user, $quiz);

            if ($existingAttempt) {
                // Check if expired - if so, it will auto-submit and we can create new
                if ($this->attemptService->checkExpiration($existingAttempt)) {
                    // Attempt was expired and auto-submitted, proceed to create new
                    $existingAttempt = null;
                } else {
                    // Resume existing attempt
                    $questions = $this->attemptService->getAttemptQuestions($existingAttempt);
                    $timeSpent = $existingAttempt->started_at->diffInSeconds(now());

                    return response()->json([
                        'success' => true,
                        'data' => [
                            'id' => $existingAttempt->id,
                            'quiz_id' => $quiz->id,
                            'user_id' => $user->id,
                            'started_at' => $existingAttempt->started_at->toIso8601String(),
                            'completed_at' => null,
                            'expires_at' => $existingAttempt->getExpiresAt()?->toIso8601String(),
                            'status' => $existingAttempt->status,
                            'time_limit_seconds' => $quiz->time_limit_minutes ? $quiz->time_limit_minutes * 60 : null,
                            'time_spent_seconds' => $timeSpent,
                            'total_questions' => $quiz->total_questions,
                            'quiz' => [
                                'id' => $quiz->id,
                                'title_ar' => $quiz->title_ar,
                                'quiz_type' => $quiz->quiz_type,
                                'passing_score' => $quiz->passing_score,
                            ],
                            'questions' => $questions,
                            'answers' => (object) ($existingAttempt->answers ?? []),
                            'resumed' => true, // Flag to indicate this is a resumed attempt
                        ],
                    ]);
                }
            }

            // Get optional seed from request
            $seed = $request->input('seed');

            // Start new attempt with seed
            $attempt = $this->attemptService->startAttempt($user, $quiz, $seed);

            // Get questions for attempt
            $questions = $this->attemptService->getAttemptQuestions($attempt);

            // Return Flutter-compatible response format
            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $attempt->id,
                    'quiz_id' => $quiz->id,
                    'user_id' => $user->id,
                    'started_at' => $attempt->started_at->toIso8601String(),
                    'completed_at' => null,
                    'expires_at' => $attempt->getExpiresAt()?->toIso8601String(),
                    'status' => $attempt->status,
                    'time_limit_seconds' => $quiz->time_limit_minutes ? $quiz->time_limit_minutes * 60 : null,
                    'time_spent_seconds' => 0,
                    'total_questions' => $quiz->total_questions,
                    'quiz' => [
                        'id' => $quiz->id,
                        'title_ar' => $quiz->title_ar,
                        'quiz_type' => $quiz->quiz_type,
                        'passing_score' => $quiz->passing_score,
                    ],
                    'questions' => $questions,
                    'answers' => (object) [],
                    'resumed' => false, // Flag to indicate this is a new attempt
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
     * GET /api/v1/quizzes/recommended
     * Get recommended quizzes
     */
    public function recommended(Request $request)
    {
        $user = auth()->user();
        $limit = $request->input('limit', 5);

        $recommendations = $this->recommendationService->getRecommendedQuizzes($user, $limit);

        $formattedRecommendations = $recommendations->map(function ($item) {
            return [
                'quiz' => [
                    'id' => $item['quiz']->id,
                    'title_ar' => $item['quiz']->title_ar,
                    'subject' => $item['quiz']->subject?->name_ar,
                    'difficulty' => $item['quiz']->difficulty_level,
                    'duration' => $item['quiz']->estimated_duration_minutes,
                    'total_questions' => $item['quiz']->total_questions,
                ],
                'reason' => $item['reason'],
            ];
        });

        return response()->json([
            'success' => true,
            'data' => [
                'recommended_quizzes' => $formattedRecommendations,
            ],
        ]);
    }

    /**
     * GET /api/v1/quizzes/my-attempts
     * Get user's quiz attempts history
     */
    public function myAttempts(Request $request)
    {
        $user = auth()->user();
        $query = $user->quizAttempts()->with('quiz.subject')->orderBy('started_at', 'desc');

        // Filter by subject
        if ($request->filled('subject_id')) {
            $query->whereHas('quiz', function ($q) use ($request) {
                $q->where('subject_id', $request->subject_id);
            });
        }

        // Filter by status
        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        $perPage = $request->input('per_page', 20);
        $attempts = $query->paginate($perPage);

        // Transform to Flutter-compatible format
        $attempts->getCollection()->transform(function ($attempt) {
            return [
                'id' => $attempt->id,
                'quiz_id' => $attempt->quiz_id,
                'user_id' => $attempt->user_id,
                'started_at' => $attempt->started_at->toIso8601String(),
                'completed_at' => $attempt->completed_at?->toIso8601String(),
                'status' => $attempt->status,
                'time_spent_seconds' => $attempt->time_spent_seconds,
                'score' => [
                    'percentage' => $attempt->score_percentage,
                    'passed' => $attempt->passed,
                    'total_points' => $attempt->total_points,
                    'max_score' => $attempt->max_score,
                ],
                'quiz' => [
                    'id' => $attempt->quiz->id,
                    'title_ar' => $attempt->quiz->title_ar,
                    'subject' => $attempt->quiz->subject?->name_ar,
                    'difficulty_level' => $attempt->quiz->difficulty_level,
                ],
            ];
        });

        return response()->json([
            'success' => true,
            'data' => [
                'attempts' => $attempts->items(),
                'meta' => [
                    'total' => $attempts->total(),
                    'per_page' => $attempts->perPage(),
                    'current_page' => $attempts->currentPage(),
                    'last_page' => $attempts->lastPage(),
                ],
            ],
        ]);
    }

    /**
     * GET /api/v1/quizzes/performance
     * Get user's quiz performance
     */
    public function performance(Request $request)
    {
        $user = auth()->user();

        // Get period filter
        $period = $request->input('period', 'all');

        // Build date range based on period
        $startDate = match($period) {
            'week' => now()->subWeek(),
            'month' => now()->subMonth(),
            'quarter' => now()->subMonths(3),
            'year' => now()->subYear(),
            default => null,
        };

        // Build base query with period filter
        $attemptsQuery = $user->quizAttempts()->completed();
        if ($startDate) {
            $attemptsQuery->where('completed_at', '>=', $startDate);
        }

        // Filter by subject if provided
        if ($request->filled('subject_id')) {
            $attemptsQuery->whereHas('quiz', function ($q) use ($request) {
                $q->where('subject_id', $request->subject_id);
            });
        }

        $allAttempts = $attemptsQuery->get();

        // Overall statistics
        $overall = [
            'total_attempts' => $allAttempts->count(),
            'total_quizzes' => $allAttempts->pluck('quiz_id')->unique()->count(),
            'average_score' => $allAttempts->count() > 0 ? round($allAttempts->avg('score_percentage'), 1) : 0,
            'best_score' => $allAttempts->max('score_percentage') ?? 0,
            'total_time_spent_hours' => round($allAttempts->sum('time_spent_seconds') / 3600, 1),
            'pass_rate' => $allAttempts->count() > 0
                ? round(($allAttempts->where('passed', true)->count() / $allAttempts->count()) * 100, 1)
                : 0,
        ];

        // By subject - Flutter-compatible format
        $bySubject = $user->quizPerformances()
            ->with('subject')
            ->whereNotNull('subject_id')
            ->get()
            ->map(function ($perf) {
                return [
                    'subject_id' => $perf->subject_id,
                    'subject_name_ar' => $perf->subject->name_ar ?? 'غير محدد',
                    'attempts' => $perf->total_attempts,
                    'average_score' => round($perf->average_score, 1),
                    'best_score' => round($perf->best_score, 1),
                    'weak_concepts' => $perf->weak_concepts ?? [],
                ];
            });

        // Weak concepts aggregated
        $weakConcepts = $user->quizPerformances()
            ->whereNotNull('weak_concepts')
            ->get()
            ->pluck('weak_concepts')
            ->flatten(1)
            ->filter()
            ->groupBy('tag')
            ->map(function ($concepts, $tag) {
                return [
                    'tag' => $tag,
                    'error_rate' => round($concepts->avg('error_rate'), 2),
                ];
            })
            ->sortByDesc('error_rate')
            ->values()
            ->take(10);

        // Performance by question type
        $byQuestionType = $this->getPerformanceByQuestionType($user, $startDate);

        return response()->json([
            'success' => true,
            'data' => [
                'overall' => $overall,
                'by_subject' => $bySubject,
                'weak_concepts' => $weakConcepts,
                'by_question_type' => $byQuestionType,
            ],
        ]);
    }

    /**
     * Get performance breakdown by question type
     */
    protected function getPerformanceByQuestionType($user, $startDate = null): array
    {
        // This would require tracking answers by question type
        // For now, return empty structure - can be enhanced later
        return [
            'single_choice' => ['correct' => 0, 'total' => 0, 'accuracy' => 0],
            'multiple_choice' => ['correct' => 0, 'total' => 0, 'accuracy' => 0],
            'true_false' => ['correct' => 0, 'total' => 0, 'accuracy' => 0],
            'matching' => ['correct' => 0, 'total' => 0, 'accuracy' => 0],
            'ordering' => ['correct' => 0, 'total' => 0, 'accuracy' => 0],
            'fill_blank' => ['correct' => 0, 'total' => 0, 'accuracy' => 0],
            'short_answer' => ['correct' => 0, 'total' => 0, 'accuracy' => 0],
            'numeric' => ['correct' => 0, 'total' => 0, 'accuracy' => 0],
        ];
    }
}
