<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class FlashcardReviewLog extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $fillable = [
        'user_id',
        'flashcard_id',
        'session_id',
        'quality_rating',
        'response_time_seconds',
        'ease_factor_before',
        'ease_factor_after',
        'interval_before',
        'interval_after',
        'next_review_before',
        'next_review_after',
        'state_before',
        'state_after',
        'reviewed_at',
    ];

    protected $casts = [
        'quality_rating' => 'integer',
        'response_time_seconds' => 'integer',
        'ease_factor_before' => 'decimal:2',
        'ease_factor_after' => 'decimal:2',
        'interval_before' => 'integer',
        'interval_after' => 'integer',
        'next_review_before' => 'date',
        'next_review_after' => 'date',
        'reviewed_at' => 'datetime',
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

    public function session(): BelongsTo
    {
        return $this->belongsTo(FlashcardReviewSession::class, 'session_id');
    }

    // ==================== Scopes ====================

    public function scopeForUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    public function scopeForCard($query, $cardId)
    {
        return $query->where('flashcard_id', $cardId);
    }

    public function scopeForSession($query, $sessionId)
    {
        return $query->where('session_id', $sessionId);
    }

    public function scopeRecent($query, $days = 30)
    {
        return $query->where('reviewed_at', '>=', now()->subDays($days));
    }

    public function scopeCorrect($query)
    {
        return $query->where('quality_rating', '>=', 3);
    }

    public function scopeIncorrect($query)
    {
        return $query->where('quality_rating', '<', 3);
    }

    // ==================== Helpers ====================

    /**
     * Check if this review was correct (quality >= 3)
     */
    public function wasCorrect(): bool
    {
        return $this->quality_rating >= 3;
    }

    /**
     * Get human-readable quality label
     */
    public function getQualityLabel(): string
    {
        return match ($this->quality_rating) {
            0 => 'مرة أخرى',  // Again
            1 => 'خطأ',       // Wrong
            2 => 'صعب',       // Hard
            3 => 'جيد',       // Good
            4 => 'جيد جداً',  // Very Good
            5 => 'سهل',       // Easy
            default => 'غير معروف',
        };
    }

    /**
     * Get interval change description
     */
    public function getIntervalChange(): string
    {
        $before = $this->interval_before;
        $after = $this->interval_after;

        if ($after > $before) {
            return "+{$after} يوم";
        } elseif ($after < $before) {
            return "إعادة تعيين إلى {$after} يوم";
        } else {
            return "{$after} يوم";
        }
    }

    /**
     * Create a log entry from SM-2 calculation result
     */
    public static function createFromReview(
        int $userId,
        int $flashcardId,
        ?int $sessionId,
        int $qualityRating,
        ?int $responseTimeSeconds,
        array $stateBefore,
        array $stateAfter
    ): self {
        return self::create([
            'user_id' => $userId,
            'flashcard_id' => $flashcardId,
            'session_id' => $sessionId,
            'quality_rating' => $qualityRating,
            'response_time_seconds' => $responseTimeSeconds,
            'ease_factor_before' => $stateBefore['ease_factor'],
            'ease_factor_after' => $stateAfter['ease_factor'],
            'interval_before' => $stateBefore['interval'],
            'interval_after' => $stateAfter['interval'],
            'next_review_before' => $stateBefore['next_review_date'],
            'next_review_after' => $stateAfter['next_review_date'],
            'state_before' => $stateBefore['learning_state'] ?? null,
            'state_after' => $stateAfter['learning_state'] ?? null,
            'reviewed_at' => now(),
        ]);
    }
}
