<?php

namespace App\Services;

use App\Models\Flashcard;
use App\Models\FlashcardDeck;
use App\Models\FlashcardReviewLog;
use App\Models\FlashcardReviewSession;
use App\Models\User;
use App\Models\UserFlashcardProgress;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class FlashcardService
{
    protected SpacedRepetitionService $spacedRepetitionService;

    public function __construct(SpacedRepetitionService $spacedRepetitionService)
    {
        $this->spacedRepetitionService = $spacedRepetitionService;
    }

    // ==================== Deck Operations ====================

    /**
     * Get decks with user progress
     */
    public function getDecksForUser(User $user, array $filters = []): LengthAwarePaginator
    {
        $query = FlashcardDeck::query()
            ->published()
            ->with(['subject:id,name_ar,color,icon', 'chapter:id,title_ar'])
            ->withCount(['activeFlashcards as total_cards']);

        // Apply filters
        if (!empty($filters['subject_id'])) {
            $query->bySubject($filters['subject_id']);
        }

        if (!empty($filters['chapter_id'])) {
            $query->byChapter($filters['chapter_id']);
        }

        if (!empty($filters['stream_id'])) {
            $query->forStream($filters['stream_id']);
        }

        if (isset($filters['is_premium'])) {
            $query->where('is_premium', $filters['is_premium']);
        }

        if (!empty($filters['search'])) {
            $query->search($filters['search']);
        }

        if (!empty($filters['difficulty'])) {
            $query->where('difficulty_level', $filters['difficulty']);
        }

        // Order by priority
        $query->orderBy('order')->orderBy('created_at', 'desc');

        $perPage = $filters['per_page'] ?? 20;
        $decks = $query->paginate($perPage);

        // Attach user progress to each deck
        $decks->getCollection()->transform(function ($deck) use ($user) {
            $deck->user_progress = $deck->getUserProgress($user->id);
            return $deck;
        });

        return $decks;
    }

    /**
     * Get a single deck with cards
     */
    public function getDeckWithCards(int $deckId, User $user): ?FlashcardDeck
    {
        $deck = FlashcardDeck::query()
            ->with([
                'subject:id,name_ar,color,icon',
                'chapter:id,title_ar',
                'activeFlashcards' => function ($q) {
                    $q->orderBy('order');
                },
            ])
            ->findOrFail($deckId);

        // Attach user progress
        $deck->user_progress = $deck->getUserProgress($user->id);

        // Attach individual card progress
        $deck->activeFlashcards->each(function ($card) use ($user) {
            $progress = $card->userProgress()->where('user_id', $user->id)->first();
            $card->user_review_data = $progress ? [
                'learning_state' => $progress->learning_state,
                'next_review_date' => $progress->next_review_date?->toDateString(),
                'interval' => $progress->interval,
                'ease_factor' => $progress->ease_factor,
                'total_reviews' => $progress->total_reviews,
                'retention_rate' => $progress->getRetentionPercentage(),
            ] : null;
        });

        return $deck;
    }

    /**
     * Get decks with due cards for a user
     */
    public function getDecksWithDueCards(User $user): Collection
    {
        $today = now()->toDateString();

        return FlashcardDeck::query()
            ->published()
            ->whereHas('activeFlashcards.userProgress', function ($q) use ($user, $today) {
                $q->where('user_id', $user->id)
                    ->where('next_review_date', '<=', $today);
            })
            ->with('subject:id,name_ar,color')
            ->get()
            ->map(function ($deck) use ($user) {
                $deck->user_progress = $deck->getUserProgress($user->id);
                return $deck;
            });
    }

    // ==================== Review Session Operations ====================

    /**
     * Start a new review session
     */
    public function startReviewSession(User $user, ?int $deckId = null, ?int $cardLimit = null, bool $browseMode = false): FlashcardReviewSession
    {
        // Always clean up old in-progress sessions first
        $existingSessions = FlashcardReviewSession::query()
            ->forUser($user->id)
            ->inProgress()
            ->get();

        foreach ($existingSessions as $existingSession) {
            // Use abs() to handle timezone issues
            $minutesAgo = abs($existingSession->started_at->diffInMinutes(now()));

            if (!$browseMode && $deckId === $existingSession->deck_id && $minutesAgo < 30) {
                // Return existing session if it was started less than 30 minutes ago (same deck, not browse mode)
                return $existingSession;
            }

            // Abandon old sessions (use direct update to avoid any calculation issues)
            $existingSession->update([
                'status' => FlashcardReviewSession::STATUS_ABANDONED,
                'completed_at' => now(),
                'duration_seconds' => (int) abs($existingSession->started_at->diffInSeconds(now())),
            ]);
        }

        // Create new session
        return FlashcardReviewSession::create([
            'user_id' => $user->id,
            'deck_id' => $deckId,
            'started_at' => now(),
            'status' => FlashcardReviewSession::STATUS_IN_PROGRESS,
            'cards_reviewed' => [],
        ]);
    }

    /**
     * Get current in-progress session for user
     */
    public function getCurrentSession(User $user): ?FlashcardReviewSession
    {
        return FlashcardReviewSession::query()
            ->forUser($user->id)
            ->inProgress()
            ->with('deck:id,title_ar,color')
            ->first();
    }

    /**
     * Get cards for a review session
     * @param bool $browseMode If true, returns all cards in the deck instead of just due/new cards
     */
    public function getCardsForSession(User $user, ?int $deckId = null, bool $browseMode = false, int $dueLimit = 50, int $newLimit = 20): array
    {
        if ($browseMode && $deckId) {
            // In browse mode, get all cards from the deck
            $cards = Flashcard::where('deck_id', $deckId)
                ->active()
                ->orderBy('order')
                ->get();

            // Load formatted content for each card
            $cards->each(function ($card) {
                $card->formatted_content = $card->getFormattedContent();
                $card->is_new = null;
                $card->next_interval_preview = null;
            });

            return [
                'cards' => $cards,
                'summary' => [
                    'total' => $cards->count(),
                    'due' => 0,
                    'new' => 0,
                ],
            ];
        }

        // Normal review mode - get due and new cards
        $queue = $this->spacedRepetitionService->getStudyQueue($user, $deckId, $dueLimit, $newLimit);

        // Merge and shuffle cards
        $cards = $queue['due']->merge($queue['new']);

        // Load additional data for each card
        $cards->each(function ($card) use ($user) {
            $card->formatted_content = $card->getFormattedContent();
            $progress = $card->userProgress()->where('user_id', $user->id)->first();

            if ($progress) {
                $card->is_new = false;
                $card->next_interval_preview = $this->spacedRepetitionService->getNextIntervalPreview($progress);
            } else {
                $card->is_new = true;
                // Create a temporary progress for preview calculation
                $tempProgress = new UserFlashcardProgress([
                    'ease_factor' => 2.50,
                    'interval' => 0,
                    'repetitions' => 0,
                    'learning_state' => 'new',
                ]);
                $card->next_interval_preview = $this->spacedRepetitionService->getNextIntervalPreview($tempProgress);
            }
        });

        return [
            'cards' => $cards,
            'summary' => [
                'total' => $cards->count(),
                'due' => $queue['due']->count(),
                'new' => $queue['new']->count(),
            ],
        ];
    }

    /**
     * Submit answer for a card in a session
     */
    public function submitAnswer(
        FlashcardReviewSession $session,
        Flashcard $card,
        string $response,
        ?int $responseTimeSeconds = null
    ): array {
        $user = $session->user;
        $isNewCard = !$card->userProgress()->where('user_id', $user->id)->exists();

        // Convert response to quality rating
        $quality = $this->spacedRepetitionService->mapResponseToQuality($response);

        // Process the review using SM-2 algorithm
        $progress = $this->spacedRepetitionService->processReview(
            $user,
            $card,
            $quality,
            $session->id,
            $responseTimeSeconds
        );

        // Update session statistics
        $session->recordReview($card->id, $quality, $isNewCard, $responseTimeSeconds ?? 0);

        // Get updated interval preview
        $intervalPreview = $this->spacedRepetitionService->getNextIntervalPreview($progress);

        return [
            'card_id' => $card->id,
            'quality_rating' => $quality,
            'was_correct' => $quality >= SpacedRepetitionService::QUALITY_GOOD,
            'review_data' => [
                'ease_factor' => $progress->ease_factor,
                'interval' => $progress->interval,
                'repetitions' => $progress->repetitions,
                'next_review_date' => $progress->next_review_date?->toDateString(),
                'learning_state' => $progress->learning_state,
                'retention_rate' => $progress->getRetentionPercentage(),
            ],
            'session_progress' => [
                'cards_reviewed' => $session->total_cards_reviewed,
                'again_count' => $session->again_count,
                'hard_count' => $session->hard_count,
                'good_count' => $session->good_count,
                'easy_count' => $session->easy_count,
            ],
            'next_interval_preview' => $intervalPreview,
        ];
    }

    /**
     * Complete a review session
     */
    public function completeSession(FlashcardReviewSession $session): FlashcardReviewSession
    {
        $session->complete();
        return $session->fresh(['deck:id,title_ar']);
    }

    /**
     * Abandon a review session
     */
    public function abandonSession(FlashcardReviewSession $session): FlashcardReviewSession
    {
        $session->abandon();
        return $session;
    }

    // ==================== Statistics ====================

    /**
     * Get user flashcard statistics (optimized)
     */
    public function getUserStats(User $user, ?int $deckId = null): array
    {
        $today = now()->toDateString();

        // Combine today's session stats in a single query
        $todaySessionStats = FlashcardReviewSession::query()
            ->forUser($user->id)
            ->completed()
            ->whereDate('completed_at', $today)
            ->selectRaw('COUNT(*) as session_count, COALESCE(SUM(duration_seconds), 0) as total_time')
            ->first();

        // Reviews today - single query
        $reviewsToday = FlashcardReviewLog::query()
            ->forUser($user->id)
            ->whereDate('reviewed_at', $today)
            ->count();

        // Current streak (optimized - only look at last 365 days max)
        $streak = $this->calculateStudyStreak($user);

        // Get deck count
        $totalDecks = FlashcardDeck::published()
            ->when($deckId, fn($q) => $q->where('id', $deckId))
            ->count();

        // Get base retention stats
        $baseStats = $this->spacedRepetitionService->calculateRetentionStats($user, $deckId);

        $timeStudiedToday = (int) ($todaySessionStats->total_time ?? 0);

        return array_merge($baseStats, [
            'total_decks' => $totalDecks,
            'reviews_today' => $reviewsToday,
            'sessions_today' => (int) ($todaySessionStats->session_count ?? 0),
            'time_studied_today_seconds' => $timeStudiedToday,
            'time_studied_today_formatted' => gmdate('H:i:s', $timeStudiedToday),
            'current_streak' => $streak['current'],
            'longest_streak' => $streak['longest'],
        ]);
    }

    /**
     * Calculate study streak for user (optimized)
     * Only queries last 365 days max for performance
     */
    private function calculateStudyStreak(User $user): array
    {
        // Only look at last 365 days - no one needs a streak longer than that for display
        $startDate = now()->subDays(365)->toDateString();

        $dates = FlashcardReviewLog::query()
            ->forUser($user->id)
            ->where('reviewed_at', '>=', $startDate)
            ->select(DB::raw('DATE(reviewed_at) as review_date'))
            ->groupBy('review_date')
            ->orderBy('review_date', 'desc')
            ->limit(365)
            ->pluck('review_date');

        if ($dates->isEmpty()) {
            return ['current' => 0, 'longest' => 0];
        }

        $today = now()->toDateString();
        $yesterday = now()->subDay()->toDateString();

        $currentStreak = 0;
        $longestStreak = 0;
        $tempStreak = 0;
        $previousDate = null;

        foreach ($dates as $date) {
            if ($previousDate === null) {
                // First date - check if it's today or yesterday
                if ($date === $today || $date === $yesterday) {
                    $currentStreak = 1;
                }
                $tempStreak = 1;
            } else {
                // Check if consecutive
                $diff = (new \DateTime($previousDate))->diff(new \DateTime($date))->days;

                if ($diff === 1) {
                    $tempStreak++;
                    if ($currentStreak > 0) {
                        $currentStreak++;
                    }
                } else {
                    // Streak broken - for longest streak we only need to track up to this point
                    $longestStreak = max($longestStreak, $tempStreak);
                    $tempStreak = 1;
                    // Once current streak is broken, we can stop checking it
                    if ($currentStreak > 0) {
                        // Current streak was already counted, now it's broken
                    }
                    $currentStreak = 0;
                }
            }

            $previousDate = $date;
        }

        $longestStreak = max($longestStreak, $tempStreak, $currentStreak);

        return [
            'current' => $currentStreak,
            'longest' => $longestStreak,
        ];
    }

    /**
     * Get review forecast
     */
    public function getReviewForecast(User $user, int $days = 7): array
    {
        return $this->spacedRepetitionService->getReviewForecast($user, $days);
    }

    /**
     * Get review heatmap data
     */
    public function getReviewHeatmap(User $user, int $days = 365): array
    {
        $startDate = now()->subDays($days)->startOfDay();

        $reviews = FlashcardReviewLog::query()
            ->forUser($user->id)
            ->where('reviewed_at', '>=', $startDate)
            ->select(
                DB::raw('DATE(reviewed_at) as date'),
                DB::raw('COUNT(*) as count')
            )
            ->groupBy('date')
            ->orderBy('date')
            ->get()
            ->keyBy('date');

        $heatmap = [];
        $currentDate = $startDate->copy();

        while ($currentDate <= now()) {
            $dateStr = $currentDate->toDateString();
            $heatmap[] = [
                'date' => $dateStr,
                'count' => $reviews[$dateStr]->count ?? 0,
            ];
            $currentDate->addDay();
        }

        return $heatmap;
    }

    /**
     * Get review history (past sessions)
     */
    public function getReviewHistory(User $user, ?int $deckId = null, int $perPage = 20): LengthAwarePaginator
    {
        return FlashcardReviewSession::query()
            ->forUser($user->id)
            ->completed()
            ->when($deckId, fn($q) => $q->forDeck($deckId))
            ->with('deck:id,title_ar,color')
            ->orderBy('completed_at', 'desc')
            ->paginate($perPage);
    }

    /**
     * Get stats for a specific deck
     */
    public function getDeckStats(User $user, int $deckId): array
    {
        $deck = FlashcardDeck::findOrFail($deckId);

        $stats = $this->spacedRepetitionService->calculateRetentionStats($user, $deckId);
        $progress = $deck->getUserProgress($user->id);

        // Get card distribution by learning state
        $cardDistribution = UserFlashcardProgress::query()
            ->where('user_id', $user->id)
            ->whereHas('flashcard', fn($q) => $q->where('deck_id', $deckId))
            ->select('learning_state', DB::raw('COUNT(*) as count'))
            ->groupBy('learning_state')
            ->pluck('count', 'learning_state')
            ->toArray();

        // Get difficulty distribution
        $difficultyDistribution = Flashcard::query()
            ->where('deck_id', $deckId)
            ->where('is_active', true)
            ->select('difficulty_level', DB::raw('COUNT(*) as count'))
            ->groupBy('difficulty_level')
            ->pluck('count', 'difficulty_level')
            ->toArray();

        return array_merge($stats, [
            'deck' => [
                'id' => $deck->id,
                'title_ar' => $deck->title_ar,
                'color' => $deck->color,
            ],
            'user_progress' => $progress,
            'card_distribution' => [
                'new' => $progress['cards_new'],
                'learning' => $cardDistribution['learning'] ?? 0,
                'reviewing' => $cardDistribution['reviewing'] ?? 0,
                'relearning' => $cardDistribution['relearning'] ?? 0,
                'mastered' => $progress['cards_mastered'],
            ],
            'difficulty_distribution' => $difficultyDistribution,
        ]);
    }
}
