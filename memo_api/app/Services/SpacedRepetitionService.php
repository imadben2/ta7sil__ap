<?php

namespace App\Services;

use App\Models\Flashcard;
use App\Models\FlashcardReviewLog;
use App\Models\User;
use App\Models\UserFlashcardProgress;
use Carbon\Carbon;
use Illuminate\Support\Collection;

/**
 * SM-2 Spaced Repetition Algorithm Implementation
 *
 * The SM-2 algorithm calculates optimal review intervals based on:
 * - Quality of recall (0-5 rating)
 * - Ease Factor (difficulty multiplier)
 * - Repetition count
 *
 * Quality ratings:
 * 0 - Complete blackout, no recall
 * 1 - Incorrect, but upon seeing answer it was recognized
 * 2 - Incorrect, but close / Correct with serious difficulty
 * 3 - Correct with some hesitation
 * 4 - Correct with slight hesitation
 * 5 - Perfect response
 */
class SpacedRepetitionService
{
    // SM-2 Algorithm Constants
    private const MIN_EASE_FACTOR = 1.30;
    private const DEFAULT_EASE_FACTOR = 2.50;
    private const MAX_EASE_FACTOR = 3.00;

    // Quality rating thresholds
    public const QUALITY_AGAIN = 0;      // Complete blackout
    public const QUALITY_WRONG = 1;      // Wrong but recognized
    public const QUALITY_HARD = 2;       // Correct with difficulty
    public const QUALITY_GOOD = 3;       // Correct with hesitation
    public const QUALITY_VERY_GOOD = 4;  // Correct smoothly
    public const QUALITY_EASY = 5;       // Perfect recall

    // Passing threshold (quality >= 3 is considered correct)
    private const PASSING_QUALITY = 3;

    // Learning step intervals (in minutes) for new cards
    private const LEARNING_STEPS = [1, 10]; // 1 minute, then 10 minutes

    // Graduating interval (days) - when card moves from learning to reviewing
    private const GRADUATING_INTERVAL = 1;

    // Easy bonus multiplier
    private const EASY_BONUS = 1.3;

    /**
     * Calculate the next review schedule using SM-2 algorithm
     *
     * @param UserFlashcardProgress $progress Current card progress
     * @param int $quality Quality rating (0-5)
     * @return array ['ease_factor', 'interval', 'repetitions', 'next_review_date', 'learning_state']
     */
    public function calculateNextReview(UserFlashcardProgress $progress, int $quality): array
    {
        $quality = max(0, min(5, $quality)); // Clamp to 0-5

        $currentEF = (float) $progress->ease_factor;
        $currentInterval = (int) $progress->interval;
        $currentReps = (int) $progress->repetitions;
        $currentState = $progress->learning_state;

        // Calculate new ease factor using SM-2 formula:
        // EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
        $newEF = $this->calculateNewEaseFactor($currentEF, $quality);

        // Calculate new interval and repetitions
        if ($quality < self::PASSING_QUALITY) {
            // Failed review - reset to learning
            return $this->handleFailedReview($progress, $newEF, $quality);
        }

        // Successful review
        return $this->handleSuccessfulReview(
            $currentInterval,
            $currentReps,
            $currentState,
            $newEF,
            $quality
        );
    }

    /**
     * Calculate new ease factor using SM-2 formula
     */
    private function calculateNewEaseFactor(float $currentEF, int $quality): float
    {
        // SM-2 formula: EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
        $delta = 0.1 - (5 - $quality) * (0.08 + (5 - $quality) * 0.02);
        $newEF = $currentEF + $delta;

        // Clamp to valid range
        return max(self::MIN_EASE_FACTOR, min(self::MAX_EASE_FACTOR, $newEF));
    }

    /**
     * Handle failed review (quality < 3)
     */
    private function handleFailedReview(UserFlashcardProgress $progress, float $newEF, int $quality): array
    {
        // Reset repetitions
        $newReps = 0;

        // Set interval to 1 day (or less for learning cards)
        $newInterval = 1;

        // Determine new state
        $newState = $progress->learning_state === UserFlashcardProgress::STATE_NEW
            ? UserFlashcardProgress::STATE_LEARNING
            : UserFlashcardProgress::STATE_RELEARNING;

        // Calculate next review date (due now for relearning)
        $nextReviewDate = now()->toDateString();

        return [
            'ease_factor' => round($newEF, 2),
            'interval' => $newInterval,
            'repetitions' => $newReps,
            'next_review_date' => $nextReviewDate,
            'learning_state' => $newState,
        ];
    }

    /**
     * Handle successful review (quality >= 3)
     */
    private function handleSuccessfulReview(
        int $currentInterval,
        int $currentReps,
        string $currentState,
        float $newEF,
        int $quality
    ): array {
        $newReps = $currentReps + 1;
        $newState = UserFlashcardProgress::STATE_REVIEWING;

        // Calculate new interval based on repetition count
        if ($newReps === 1) {
            // First successful review
            $newInterval = 1;
        } elseif ($newReps === 2) {
            // Second successful review
            $newInterval = 6;
        } else {
            // Subsequent reviews: I(n) = I(n-1) * EF
            $newInterval = (int) round($currentInterval * $newEF);
        }

        // Apply easy bonus if quality = 5
        if ($quality === self::QUALITY_EASY) {
            $newInterval = (int) round($newInterval * self::EASY_BONUS);
        }

        // Ensure minimum interval of 1 day
        $newInterval = max(1, $newInterval);

        // Calculate next review date
        $nextReviewDate = now()->addDays($newInterval)->toDateString();

        return [
            'ease_factor' => round($newEF, 2),
            'interval' => $newInterval,
            'repetitions' => $newReps,
            'next_review_date' => $nextReviewDate,
            'learning_state' => $newState,
        ];
    }

    /**
     * Process a review and update the card progress
     *
     * @param User $user
     * @param Flashcard $card
     * @param int $quality Quality rating (0-5)
     * @param int|null $sessionId Optional session ID
     * @param int|null $responseTimeSeconds Time taken to answer
     * @return UserFlashcardProgress Updated progress
     */
    public function processReview(
        User $user,
        Flashcard $card,
        int $quality,
        ?int $sessionId = null,
        ?int $responseTimeSeconds = null
    ): UserFlashcardProgress {
        // Get or create progress record
        $progress = $card->getOrCreateProgress($user->id);

        // Store state before update
        $stateBefore = [
            'ease_factor' => $progress->ease_factor,
            'interval' => $progress->interval,
            'next_review_date' => $progress->next_review_date?->toDateString(),
            'learning_state' => $progress->learning_state,
        ];

        // Calculate new review schedule
        $result = $this->calculateNextReview($progress, $quality);

        // Update progress record
        $progress->ease_factor = $result['ease_factor'];
        $progress->interval = $result['interval'];
        $progress->repetitions = $result['repetitions'];
        $progress->next_review_date = $result['next_review_date'];
        $progress->last_review_date = now()->toDateString();
        $progress->learning_state = $result['learning_state'];
        $progress->total_reviews++;

        // Update correct reviews count if passed
        if ($quality >= self::PASSING_QUALITY) {
            $progress->correct_reviews++;
        } else {
            $progress->lapses++;
        }

        // Update streak
        $progress->updateStreak($quality >= self::PASSING_QUALITY);

        $progress->save();

        // Create review log
        FlashcardReviewLog::createFromReview(
            $user->id,
            $card->id,
            $sessionId,
            $quality,
            $responseTimeSeconds,
            $stateBefore,
            [
                'ease_factor' => $result['ease_factor'],
                'interval' => $result['interval'],
                'next_review_date' => $result['next_review_date'],
                'learning_state' => $result['learning_state'],
            ]
        );

        return $progress;
    }

    /**
     * Map button response to quality rating
     *
     * @param string $response 'again', 'hard', 'good', 'easy'
     * @return int Quality rating (0-5)
     */
    public function mapResponseToQuality(string $response): int
    {
        return match (strtolower($response)) {
            'again' => self::QUALITY_AGAIN,
            'hard' => self::QUALITY_HARD,
            'good' => self::QUALITY_GOOD,
            'easy' => self::QUALITY_EASY,
            default => self::QUALITY_GOOD,
        };
    }

    /**
     * Get cards due for review for a user
     *
     * @param User $user
     * @param int|null $deckId Optional deck filter
     * @param int $limit Maximum cards to return
     * @return Collection
     */
    public function getDueCards(User $user, ?int $deckId = null, int $limit = 50): Collection
    {
        $today = now()->toDateString();

        $query = Flashcard::query()
            ->where('is_active', true)
            ->whereHas('userProgress', function ($q) use ($user, $today) {
                $q->where('user_id', $user->id)
                    ->where('next_review_date', '<=', $today);
            })
            ->with(['deck:id,title_ar,color', 'userProgress' => function ($q) use ($user) {
                $q->where('user_id', $user->id);
            }]);

        if ($deckId) {
            $query->where('deck_id', $deckId);
        }

        // Order by overdue days (most overdue first), then by ease factor (harder cards first)
        return $query
            ->join('user_flashcard_progress as ufp', function ($join) use ($user) {
                $join->on('flashcards.id', '=', 'ufp.flashcard_id')
                    ->where('ufp.user_id', '=', $user->id);
            })
            ->orderByRaw('DATEDIFF(?, ufp.next_review_date) DESC', [$today])
            ->orderBy('ufp.ease_factor', 'asc')
            ->select('flashcards.*')
            ->limit($limit)
            ->get();
    }

    /**
     * Get new cards (never studied) for a user
     *
     * @param User $user
     * @param int|null $deckId Optional deck filter
     * @param int $limit Maximum cards to return
     * @return Collection
     */
    public function getNewCards(User $user, ?int $deckId = null, int $limit = 20): Collection
    {
        $query = Flashcard::query()
            ->where('is_active', true)
            ->whereDoesntHave('userProgress', function ($q) use ($user) {
                $q->where('user_id', $user->id);
            })
            ->with('deck:id,title_ar,color');

        if ($deckId) {
            $query->where('deck_id', $deckId);
        }

        return $query
            ->orderBy('order')
            ->limit($limit)
            ->get();
    }

    /**
     * Get combined study queue (due cards + new cards)
     *
     * @param User $user
     * @param int|null $deckId Optional deck filter
     * @param int $dueLimit Max due cards
     * @param int $newLimit Max new cards
     * @return array ['due' => Collection, 'new' => Collection]
     */
    public function getStudyQueue(
        User $user,
        ?int $deckId = null,
        int $dueLimit = 50,
        int $newLimit = 20
    ): array {
        return [
            'due' => $this->getDueCards($user, $deckId, $dueLimit),
            'new' => $this->getNewCards($user, $deckId, $newLimit),
        ];
    }

    /**
     * Calculate retention statistics for a user
     *
     * @param User $user
     * @param int|null $deckId Optional deck filter
     * @return array Statistics
     */
    public function calculateRetentionStats(User $user, ?int $deckId = null): array
    {
        $query = UserFlashcardProgress::where('user_id', $user->id);

        if ($deckId) {
            $query->whereHas('flashcard', function ($q) use ($deckId) {
                $q->where('deck_id', $deckId);
            });
        }

        $progress = $query->get();

        if ($progress->isEmpty()) {
            return [
                'total_cards' => 0,
                'cards_studied' => 0,
                'cards_mastered' => 0,
                'cards_due' => 0,
                'average_ease_factor' => self::DEFAULT_EASE_FACTOR,
                'average_interval' => 0,
                'retention_rate' => 0,
                'total_reviews' => 0,
            ];
        }

        $today = now()->toDateString();

        return [
            'total_cards' => $progress->count(),
            'cards_studied' => $progress->where('total_reviews', '>', 0)->count(),
            'cards_mastered' => $progress->where('interval', '>=', 21)->count(),
            'cards_due' => $progress->filter(fn($p) => $p->next_review_date && $p->next_review_date <= $today)->count(),
            'average_ease_factor' => round($progress->avg('ease_factor'), 2),
            'average_interval' => round($progress->avg('interval'), 1),
            'retention_rate' => $this->calculateOverallRetention($progress),
            'total_reviews' => $progress->sum('total_reviews'),
        ];
    }

    /**
     * Calculate overall retention rate from progress records
     */
    private function calculateOverallRetention(Collection $progress): float
    {
        $totalReviews = $progress->sum('total_reviews');
        $correctReviews = $progress->sum('correct_reviews');

        if ($totalReviews === 0) {
            return 0;
        }

        return round(($correctReviews / $totalReviews) * 100, 1);
    }

    /**
     * Get review forecast for upcoming days
     *
     * @param User $user
     * @param int $days Number of days to forecast
     * @return array Daily forecast
     */
    public function getReviewForecast(User $user, int $days = 7): array
    {
        $forecast = [];
        $today = now()->startOfDay();

        for ($i = 0; $i < $days; $i++) {
            $date = $today->copy()->addDays($i)->toDateString();

            $count = UserFlashcardProgress::where('user_id', $user->id)
                ->where('next_review_date', $date)
                ->count();

            $forecast[] = [
                'date' => $date,
                'day_name' => $today->copy()->addDays($i)->translatedFormat('l'),
                'cards_due' => $count,
            ];
        }

        return $forecast;
    }

    /**
     * Get estimated next intervals for each response type
     * (Used to show preview in UI)
     *
     * @param UserFlashcardProgress $progress
     * @return array Intervals for each response
     */
    public function getNextIntervalPreview(UserFlashcardProgress $progress): array
    {
        $previews = [];

        foreach (['again', 'hard', 'good', 'easy'] as $response) {
            $quality = $this->mapResponseToQuality($response);
            $result = $this->calculateNextReview($progress, $quality);

            $interval = $result['interval'];

            $previews[$response] = [
                'interval_days' => $interval,
                'interval_text' => $this->formatIntervalText($interval),
                'next_date' => $result['next_review_date'],
            ];
        }

        return $previews;
    }

    /**
     * Format interval as human-readable text (Arabic)
     */
    private function formatIntervalText(int $days): string
    {
        if ($days === 0) {
            return 'الآن';
        } elseif ($days === 1) {
            return 'يوم واحد';
        } elseif ($days === 2) {
            return 'يومان';
        } elseif ($days >= 3 && $days <= 10) {
            return "{$days} أيام";
        } elseif ($days < 30) {
            return "{$days} يوم";
        } elseif ($days < 365) {
            $months = (int) ($days / 30);
            return $months === 1 ? 'شهر' : "{$months} أشهر";
        } else {
            $years = (int) ($days / 365);
            return $years === 1 ? 'سنة' : "{$years} سنوات";
        }
    }
}
