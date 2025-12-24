<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Carbon\Carbon;

class UserSubjectPlannerProgress extends Model
{
    use HasFactory;

    protected $table = 'user_subject_planner_progress';

    protected $fillable = [
        'user_id',
        'subject_planner_content_id',
        'status',
        'understanding_completed',
        'review_completed',
        'theory_practice_completed',
        'exercise_practice_completed',
        'completion_percentage',
        'mastery_score',
        'time_spent_minutes',
        'study_count',
        'last_studied_at',
        'next_review_at',
    ];

    protected $casts = [
        'understanding_completed' => 'boolean',
        'review_completed' => 'boolean',
        'theory_practice_completed' => 'boolean',
        'exercise_practice_completed' => 'boolean',
        'completion_percentage' => 'integer',
        'mastery_score' => 'integer',
        'time_spent_minutes' => 'integer',
        'study_count' => 'integer',
        'last_studied_at' => 'datetime',
        'next_review_at' => 'datetime',
    ];

    /**
     * Get the user that owns this progress.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the subject planner content.
     */
    public function subjectPlannerContent(): BelongsTo
    {
        return $this->belongsTo(SubjectPlannerContent::class);
    }

    /**
     * Scope a query to filter by user.
     */
    public function scopeForUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    /**
     * Scope a query to get completed items.
     */
    public function scopeCompleted($query)
    {
        return $query->where('status', 'completed');
    }

    /**
     * Scope a query to get mastered items.
     */
    public function scopeMastered($query)
    {
        return $query->where('status', 'mastered');
    }

    /**
     * Scope a query to get items in progress.
     */
    public function scopeInProgress($query)
    {
        return $query->where('status', 'in_progress');
    }

    /**
     * Scope a query to get items due for review.
     */
    public function scopeDueForReview($query)
    {
        return $query->whereNotNull('next_review_at')
                     ->where('next_review_at', '<=', now());
    }

    /**
     * Mark a study phase as completed.
     */
    public function markPhaseCompleted(string $phase): void
    {
        $field = $phase . '_completed';

        if (in_array($field, $this->fillable)) {
            $this->$field = true;
            $this->updateCompletionPercentage();
            $this->save();
        }
    }

    /**
     * Update completion percentage based on required phases.
     */
    public function updateCompletionPercentage(): void
    {
        $content = $this->subjectPlannerContent;
        $completedPhases = 0;
        $totalPhases = 0;

        if ($content->requires_understanding) {
            $totalPhases++;
            if ($this->understanding_completed) $completedPhases++;
        }

        if ($content->requires_review) {
            $totalPhases++;
            if ($this->review_completed) $completedPhases++;
        }

        if ($content->requires_theory_practice) {
            $totalPhases++;
            if ($this->theory_practice_completed) $completedPhases++;
        }

        if ($content->requires_exercise_practice) {
            $totalPhases++;
            if ($this->exercise_practice_completed) $completedPhases++;
        }

        $this->completion_percentage = $totalPhases > 0
            ? round(($completedPhases / $totalPhases) * 100)
            : 0;

        // Update status based on completion
        if ($this->completion_percentage === 100) {
            $this->status = $this->mastery_score >= 80 ? 'mastered' : 'completed';
        } elseif ($this->completion_percentage > 0) {
            $this->status = 'in_progress';
        }
    }

    /**
     * Record a study session.
     */
    public function recordStudySession(int $durationMinutes, int $score = null): void
    {
        $this->study_count++;
        $this->time_spent_minutes += $durationMinutes;
        $this->last_studied_at = now();

        if ($score !== null) {
            $this->mastery_score = $score;
        }

        // Calculate next review date using spaced repetition
        $this->calculateNextReview();

        $this->save();
    }

    /**
     * Calculate next review date using spaced repetition algorithm.
     * Based on study count: 1 day, 3 days, 7 days, 14 days, 30 days
     */
    public function calculateNextReview(): void
    {
        $intervals = [1, 3, 7, 14, 30, 60, 90]; // days
        $index = min($this->study_count - 1, count($intervals) - 1);
        $index = max(0, $index);

        $this->next_review_at = Carbon::now()->addDays($intervals[$index]);
    }

    /**
     * Check if this content is due for review today.
     */
    public function isDueForReview(): bool
    {
        return $this->next_review_at && $this->next_review_at->isToday();
    }

    /**
     * Check if all required phases are completed.
     */
    public function areAllPhasesCompleted(): bool
    {
        $content = $this->subjectPlannerContent;

        $checks = [
            $content->requires_understanding ? $this->understanding_completed : true,
            $content->requires_review ? $this->review_completed : true,
            $content->requires_theory_practice ? $this->theory_practice_completed : true,
            $content->requires_exercise_practice ? $this->exercise_practice_completed : true,
        ];

        return !in_array(false, $checks);
    }

    /**
     * Get progress summary as array.
     */
    public function getSummary(): array
    {
        return [
            'status' => $this->status,
            'completion_percentage' => $this->completion_percentage,
            'mastery_score' => $this->mastery_score,
            'time_spent_minutes' => $this->time_spent_minutes,
            'study_count' => $this->study_count,
            'last_studied' => $this->last_studied_at?->format('Y-m-d H:i:s'),
            'next_review' => $this->next_review_at?->format('Y-m-d'),
            'phases' => [
                'understanding' => $this->understanding_completed,
                'review' => $this->review_completed,
                'theory_practice' => $this->theory_practice_completed,
                'exercise_practice' => $this->exercise_practice_completed,
            ],
        ];
    }
}
