<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserFlashcardProgress extends Model
{
    use HasFactory;

    protected $table = 'user_flashcard_progress';

    // Learning state constants
    public const STATE_NEW = 'new';
    public const STATE_LEARNING = 'learning';
    public const STATE_REVIEWING = 'reviewing';
    public const STATE_RELEARNING = 'relearning';

    protected $fillable = [
        'user_id',
        'flashcard_id',
        'ease_factor',
        'interval',
        'repetitions',
        'next_review_date',
        'last_review_date',
        'total_reviews',
        'correct_reviews',
        'lapses',
        'current_streak',
        'longest_streak',
        'learning_state',
    ];

    protected $casts = [
        'ease_factor' => 'decimal:2',
        'interval' => 'integer',
        'repetitions' => 'integer',
        'next_review_date' => 'date',
        'last_review_date' => 'date',
        'total_reviews' => 'integer',
        'correct_reviews' => 'integer',
        'lapses' => 'integer',
        'current_streak' => 'integer',
        'longest_streak' => 'integer',
    ];

    // ==================== Relationships ====================

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function flashcard(): BelongsTo
    {
        return $this->belongsTo(Flashcard::class);
    }

    // ==================== Scopes ====================

    public function scopeDueToday($query)
    {
        $today = now()->toDateString();
        return $query->where('next_review_date', '<=', $today);
    }

    public function scopeDueBefore($query, $date)
    {
        return $query->where('next_review_date', '<=', $date);
    }

    public function scopeForUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    public function scopeNew($query)
    {
        return $query->where('learning_state', self::STATE_NEW);
    }

    public function scopeLearning($query)
    {
        return $query->where('learning_state', self::STATE_LEARNING);
    }

    public function scopeReviewing($query)
    {
        return $query->where('learning_state', self::STATE_REVIEWING);
    }

    public function scopeRelearning($query)
    {
        return $query->where('learning_state', self::STATE_RELEARNING);
    }

    public function scopeMastered($query)
    {
        return $query->where('interval', '>=', 21);
    }

    // ==================== Computed Properties ====================

    /**
     * Check if card is due for review
     */
    public function isDue(): bool
    {
        if (!$this->next_review_date) {
            return true; // Never reviewed = due now
        }

        return $this->next_review_date <= now()->toDateString();
    }

    /**
     * Check if card is new (never reviewed)
     */
    public function isNew(): bool
    {
        return $this->learning_state === self::STATE_NEW || $this->total_reviews === 0;
    }

    /**
     * Check if card is mastered (interval >= 21 days)
     */
    public function isMastered(): bool
    {
        return $this->interval >= 21;
    }

    /**
     * Get retention rate as percentage
     */
    public function getRetentionPercentage(): float
    {
        if ($this->total_reviews === 0) {
            return 0;
        }

        return round(($this->correct_reviews / $this->total_reviews) * 100, 1);
    }

    /**
     * Get days until next review (negative if overdue)
     */
    public function getDaysUntilReview(): ?int
    {
        if (!$this->next_review_date) {
            return 0;
        }

        return now()->startOfDay()->diffInDays($this->next_review_date, false);
    }

    /**
     * Get overdue days (0 if not overdue)
     */
    public function getOverdueDays(): int
    {
        $days = $this->getDaysUntilReview();
        return $days < 0 ? abs($days) : 0;
    }

    // ==================== State Transitions ====================

    /**
     * Transition to learning state
     */
    public function transitionToLearning(): void
    {
        $this->learning_state = self::STATE_LEARNING;
        $this->save();
    }

    /**
     * Transition to reviewing state (graduated from learning)
     */
    public function transitionToReviewing(): void
    {
        $this->learning_state = self::STATE_REVIEWING;
        $this->save();
    }

    /**
     * Transition to relearning state (lapsed)
     */
    public function transitionToRelearning(): void
    {
        $this->learning_state = self::STATE_RELEARNING;
        $this->lapses++;
        $this->save();
    }

    /**
     * Update streak after review
     */
    public function updateStreak(bool $wasCorrect): void
    {
        if ($wasCorrect) {
            $this->current_streak++;
            if ($this->current_streak > $this->longest_streak) {
                $this->longest_streak = $this->current_streak;
            }
        } else {
            $this->current_streak = 0;
        }
    }
}
