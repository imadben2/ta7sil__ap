<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class FlashcardReviewSession extends Model
{
    use HasFactory;

    // Status constants
    public const STATUS_IN_PROGRESS = 'in_progress';
    public const STATUS_COMPLETED = 'completed';
    public const STATUS_ABANDONED = 'abandoned';

    protected $fillable = [
        'user_id',
        'deck_id',
        'started_at',
        'completed_at',
        'duration_seconds',
        'total_cards_reviewed',
        'new_cards_studied',
        'review_cards_studied',
        'again_count',
        'hard_count',
        'good_count',
        'easy_count',
        'average_response_time_seconds',
        'session_retention_rate',
        'status',
        'cards_reviewed',
    ];

    protected $casts = [
        'started_at' => 'datetime',
        'completed_at' => 'datetime',
        'duration_seconds' => 'integer',
        'total_cards_reviewed' => 'integer',
        'new_cards_studied' => 'integer',
        'review_cards_studied' => 'integer',
        'again_count' => 'integer',
        'hard_count' => 'integer',
        'good_count' => 'integer',
        'easy_count' => 'integer',
        'average_response_time_seconds' => 'decimal:2',
        'session_retention_rate' => 'decimal:2',
        'cards_reviewed' => 'array',
    ];

    // ==================== Relationships ====================

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function deck(): BelongsTo
    {
        return $this->belongsTo(FlashcardDeck::class, 'deck_id');
    }

    public function reviewLogs(): HasMany
    {
        return $this->hasMany(FlashcardReviewLog::class, 'session_id');
    }

    // ==================== Scopes ====================

    public function scopeInProgress($query)
    {
        return $query->where('status', self::STATUS_IN_PROGRESS);
    }

    public function scopeCompleted($query)
    {
        return $query->where('status', self::STATUS_COMPLETED);
    }

    public function scopeForUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    public function scopeForDeck($query, $deckId)
    {
        return $query->where('deck_id', $deckId);
    }

    public function scopeRecent($query, $days = 7)
    {
        return $query->where('started_at', '>=', now()->subDays($days));
    }

    public function scopeToday($query)
    {
        return $query->whereDate('started_at', today());
    }

    // ==================== Helpers ====================

    /**
     * Check if session is in progress
     */
    public function isInProgress(): bool
    {
        return $this->status === self::STATUS_IN_PROGRESS;
    }

    /**
     * Check if session is completed
     */
    public function isCompleted(): bool
    {
        return $this->status === self::STATUS_COMPLETED;
    }

    /**
     * Mark session as completed
     */
    public function complete(): void
    {
        $this->status = self::STATUS_COMPLETED;
        $this->completed_at = now();
        // Use abs() and intval() to ensure duration is always a positive integer
        $this->duration_seconds = (int) abs($this->started_at->diffInSeconds(now()));
        $this->calculateRetentionRate();
        $this->save();
    }

    /**
     * Mark session as abandoned
     */
    public function abandon(): void
    {
        $this->status = self::STATUS_ABANDONED;
        $this->completed_at = now();
        // Use abs() and intval() to ensure duration is always a positive integer
        $this->duration_seconds = (int) abs($this->started_at->diffInSeconds(now()));
        $this->save();
    }

    /**
     * Record a card review
     */
    public function recordReview(int $cardId, int $quality, bool $isNewCard, int $responseTimeSeconds): void
    {
        $this->total_cards_reviewed++;

        if ($isNewCard) {
            $this->new_cards_studied++;
        } else {
            $this->review_cards_studied++;
        }

        // Update quality counts
        switch ($quality) {
            case 0:
            case 1:
                $this->again_count++;
                break;
            case 2:
                $this->hard_count++;
                break;
            case 3:
            case 4:
                $this->good_count++;
                break;
            case 5:
                $this->easy_count++;
                break;
        }

        // Update cards reviewed array
        $cardsReviewed = $this->cards_reviewed ?? [];
        if (!in_array($cardId, $cardsReviewed)) {
            $cardsReviewed[] = $cardId;
            $this->cards_reviewed = $cardsReviewed;
        }

        // Update average response time
        $this->updateAverageResponseTime($responseTimeSeconds);

        $this->save();
    }

    /**
     * Update average response time
     */
    private function updateAverageResponseTime(int $newResponseTime): void
    {
        if ($this->total_cards_reviewed <= 1) {
            $this->average_response_time_seconds = $newResponseTime;
        } else {
            // Calculate rolling average
            $currentTotal = $this->average_response_time_seconds * ($this->total_cards_reviewed - 1);
            $this->average_response_time_seconds = ($currentTotal + $newResponseTime) / $this->total_cards_reviewed;
        }
    }

    /**
     * Calculate retention rate (percentage of correct answers)
     */
    public function calculateRetentionRate(): void
    {
        if ($this->total_cards_reviewed === 0) {
            $this->session_retention_rate = 0;
            return;
        }

        // Correct = good + easy (quality >= 3)
        $correct = $this->good_count + $this->easy_count;
        $this->session_retention_rate = round(($correct / $this->total_cards_reviewed) * 100, 2);
    }

    /**
     * Get session statistics
     */
    public function getStats(): array
    {
        return [
            'total_cards_reviewed' => $this->total_cards_reviewed,
            'new_cards_studied' => $this->new_cards_studied,
            'review_cards_studied' => $this->review_cards_studied,
            'quality_distribution' => [
                'again' => $this->again_count,
                'hard' => $this->hard_count,
                'good' => $this->good_count,
                'easy' => $this->easy_count,
            ],
            'retention_rate' => $this->session_retention_rate,
            'average_response_time' => $this->average_response_time_seconds,
            'duration_seconds' => $this->duration_seconds,
            'duration_formatted' => gmdate('H:i:s', $this->duration_seconds ?? 0),
        ];
    }
}
