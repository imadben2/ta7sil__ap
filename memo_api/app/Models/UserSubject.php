<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserSubject extends Model
{
    protected $fillable = [
        'user_id',
        'subject_id',
        'coefficient',
        'difficulty_level',
        'weekly_goal_minutes',
        'session_duration',
        'is_favorite',
        'priority_score',
    ];

    protected $casts = [
        'coefficient' => 'decimal:1',
        'priority_score' => 'decimal:2',
        'weekly_goal_minutes' => 'integer',
        'session_duration' => 'integer',
        'is_favorite' => 'boolean',
    ];

    protected $attributes = [
        'difficulty_level' => 'medium',
        'weekly_goal_minutes' => 0,
        'session_duration' => 45,
        'is_favorite' => false,
        'priority_score' => 0.0,
    ];

    /**
     * Get the user.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the subject.
     */
    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    /**
     * Get the user's progress for this subject.
     */
    public function progress()
    {
        return $this->hasOne(UserSubjectProgress::class, 'subject_id', 'subject_id')
            ->where('user_id', $this->user_id);
    }

    /**
     * Calculate priority score based on multiple factors.
     *
     * Priority formula:
     * - Coefficient weight: 30%
     * - Difficulty weight: 25%
     * - Weekly goal adherence: 20%
     * - Favorite bonus: 15%
     * - Recent performance: 10%
     */
    public function calculatePriorityScore(): float
    {
        $score = 0.0;

        // 1. Coefficient contribution (30%) - normalized 0-10
        $coefficientScore = ($this->coefficient / 10) * 3.0;
        $score += $coefficientScore;

        // 2. Difficulty contribution (25%)
        $difficultyScores = [
            'easy' => 0.8,
            'medium' => 2.0,
            'hard' => 2.5,
        ];
        $score += $difficultyScores[$this->difficulty_level] ?? 2.0;

        // 3. Weekly goal adherence (20%)
        // Higher goals = higher priority
        $goalScore = min(($this->weekly_goal_minutes / 420), 1.0) * 2.0; // 420min = 7h/week
        $score += $goalScore;

        // 4. Favorite bonus (15%)
        if ($this->is_favorite) {
            $score += 1.5;
        }

        // 5. Recent performance (10%) - placeholder, can be enhanced with actual performance data
        // This would require joining with quiz/study session data
        $score += 1.0; // Default mid-score

        return round($score, 2);
    }

    /**
     * Update priority score.
     */
    public function updatePriorityScore(): void
    {
        $this->priority_score = $this->calculatePriorityScore();
        $this->save();
    }

    /**
     * Validate difficulty level.
     */
    public static function validateDifficultyLevel(?string $level): bool
    {
        return in_array($level, ['easy', 'medium', 'hard']);
    }

    /**
     * Validate weekly goal minutes.
     */
    public static function validateWeeklyGoal(?int $minutes): bool
    {
        return $minutes >= 0 && $minutes <= 3000; // Max ~50h/week
    }

    /**
     * Validate session duration.
     */
    public static function validateSessionDuration(?int $duration): bool
    {
        return $duration >= 15 && $duration <= 120;
    }

    /**
     * Scope to only include favorite subjects.
     */
    public function scopeFavorites($query)
    {
        return $query->where('is_favorite', true);
    }

    /**
     * Scope to order by priority score descending.
     */
    public function scopeByPriority($query)
    {
        return $query->orderBy('priority_score', 'desc');
    }
}
