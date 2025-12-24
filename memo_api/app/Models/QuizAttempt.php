<?php

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class QuizAttempt extends Model
{
    use HasFactory;

    protected $fillable = [
        'quiz_id',
        'user_id',
        'started_at',
        'completed_at',
        'time_spent_seconds',
        'status',
        'total_questions',
        'correct_answers',
        'incorrect_answers',
        'skipped_answers',
        'score_percentage',
        'total_points',
        'max_score',
        'passed',
        'answers',
        'seed',
    ];

    protected $casts = [
        'started_at' => 'datetime',
        'completed_at' => 'datetime',
        'passed' => 'boolean',
        'score_percentage' => 'decimal:2',
        'answers' => 'array',
    ];

    // Status constants
    public const STATUS_IN_PROGRESS = 'in_progress';
    public const STATUS_COMPLETED = 'completed';
    public const STATUS_ABANDONED = 'abandoned';

    // Relationships

    public function quiz(): BelongsTo
    {
        return $this->belongsTo(Quiz::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function attemptAnswers(): HasMany
    {
        return $this->hasMany(QuizAttemptAnswer::class, 'quiz_attempt_id');
    }

    // Scopes

    public function scopeInProgress($query)
    {
        return $query->where('status', self::STATUS_IN_PROGRESS);
    }

    public function scopeCompleted($query)
    {
        return $query->where('status', self::STATUS_COMPLETED);
    }

    public function scopeAbandoned($query)
    {
        return $query->where('status', self::STATUS_ABANDONED);
    }

    public function scopePassed($query)
    {
        return $query->where('passed', true);
    }

    public function scopeFailed($query)
    {
        return $query->where('passed', false);
    }

    // Helper Methods

    public function isInProgress(): bool
    {
        return $this->status === self::STATUS_IN_PROGRESS;
    }

    public function isCompleted(): bool
    {
        return $this->status === self::STATUS_COMPLETED;
    }

    public function isAbandoned(): bool
    {
        return $this->status === self::STATUS_ABANDONED;
    }

    public function isPassed(): bool
    {
        return $this->passed === true;
    }

    public function isFailed(): bool
    {
        return $this->passed === false;
    }

    public function getExpiresAt(): ?Carbon
    {
        if (!$this->quiz->isTimed()) {
            return null;
        }

        return $this->started_at->addMinutes($this->quiz->time_limit_minutes);
    }

    public function isExpired(): bool
    {
        $expiresAt = $this->getExpiresAt();

        if ($expiresAt === null) {
            return false;
        }

        return Carbon::now()->greaterThan($expiresAt);
    }

    public function getRemainingSeconds(): ?int
    {
        $expiresAt = $this->getExpiresAt();

        if ($expiresAt === null) {
            return null;
        }

        return max(0, Carbon::now()->diffInSeconds($expiresAt, false));
    }

    public function saveAnswer(int $questionId, $answer, ?int $timeSpent = null): void
    {
        $answers = $this->answers ?? [];

        $answers[(string)$questionId] = [
            'answer' => $answer,
            'time_spent' => $timeSpent,
            'answered_at' => now()->toDateTimeString(),
        ];

        $this->answers = $answers;
        $this->save();
    }

    public function getAnswer(int $questionId)
    {
        $answers = $this->answers ?? [];
        return $answers[(string)$questionId] ?? null;
    }

    public function hasAnswer(int $questionId): bool
    {
        $answers = $this->answers ?? [];
        return isset($answers[(string)$questionId]);
    }

    public function getAnsweredQuestionsCount(): int
    {
        $answers = $this->answers ?? [];
        return count($answers);
    }

    public function calculateAccuracy(): float
    {
        if ($this->total_questions == 0) {
            return 0;
        }

        return ($this->correct_answers / $this->total_questions) * 100;
    }

    public function getPerformanceMessage(): string
    {
        $percentage = $this->score_percentage;

        if ($percentage >= 90) {
            return 'أداء ممتاز! واصل التفوق';
        } elseif ($percentage >= 80) {
            return 'أداء جيد جداً! استمر في التقدم';
        } elseif ($percentage >= 70) {
            return 'أداء جيد! يمكنك تحسينه أكثر';
        } elseif ($percentage >= 60) {
            return 'أداء مقبول، لكن يحتاج للمزيد من الجهد';
        } elseif ($percentage >= 50) {
            return 'أداء ضعيف، ننصح بمراجعة المادة';
        } else {
            return 'يجب مراجعة المادة بعناية';
        }
    }

    public function getFormattedDuration(): string
    {
        if (!$this->time_spent_seconds) {
            return '0 دقيقة';
        }

        $minutes = floor($this->time_spent_seconds / 60);
        $seconds = $this->time_spent_seconds % 60;

        if ($minutes > 0) {
            return $minutes . ' دقيقة و ' . $seconds . ' ثانية';
        }

        return $seconds . ' ثانية';
    }
}
