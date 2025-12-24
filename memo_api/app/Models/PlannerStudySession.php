<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class PlannerStudySession extends Model
{
    use HasFactory, SoftDeletes;

    // Session types from promt.md
    public const TYPE_LESSON_REVIEW = 'lesson_review';
    public const TYPE_EXERCISES = 'exercises';
    public const TYPE_TOPIC_TEST = 'topic_test';
    public const TYPE_SPACED_REVIEW = 'spaced_review';
    public const TYPE_LANGUAGE_DAILY = 'language_daily';
    public const TYPE_MOCK_TEST = 'mock_test';

    protected $fillable = [
        'user_id',
        'schedule_id',
        'subject_id',
        'chapter_id',
        'subject_planner_content_id',
        'has_content',
        'content_phase',
        'is_spaced_review',
        'original_topic_test_session_id',
        // Algorithm fields from promt.md
        'is_late',
        'is_mock_test',
        'is_language_daily',
        'score',
        'priority_score_calculated',
        'subject_category',
        'due_date',
        // End algorithm fields
        'scheduled_date',
        'scheduled_start_time',
        'scheduled_end_time',
        'duration_minutes',
        'suggested_content_id',
        'suggested_content_type',
        'content_title',
        'content_suggestion',
        'topic_name',
        'session_type',
        'required_energy_level',
        'estimated_energy_level',
        'priority_score',
        'importance',
        'difficulty',
        'is_pinned',
        'is_break',
        'is_prayer_time',
        'use_pomodoro_technique',
        'pomodoro_duration_minutes',
        'status',
        'actual_start_time',
        'actual_end_time',
        'actual_duration_minutes',
        'current_pomodoro_count',
        'total_pomodoros_planned',
        'pause_count',
        'user_notes',
        'skip_reason',
        'completion_percentage',
        'mood',
        'points_earned',
    ];

    protected $casts = [
        'scheduled_date' => 'date',
        'due_date' => 'date',
        'is_pinned' => 'boolean',
        'is_break' => 'boolean',
        'is_prayer_time' => 'boolean',
        'has_content' => 'boolean',
        'is_spaced_review' => 'boolean',
        'is_late' => 'boolean',
        'is_mock_test' => 'boolean',
        'is_language_daily' => 'boolean',
        'use_pomodoro_technique' => 'boolean',
        'actual_start_time' => 'datetime',
        'actual_end_time' => 'datetime',
        'priority_score' => 'integer',
        'importance' => 'integer',
        'difficulty' => 'integer',
        'score' => 'integer',
        'priority_score_calculated' => 'float',
        'duration_minutes' => 'integer',
        'actual_duration_minutes' => 'integer',
        'pomodoro_duration_minutes' => 'integer',
        'current_pomodoro_count' => 'integer',
        'total_pomodoros_planned' => 'integer',
        'pause_count' => 'integer',
        'completion_percentage' => 'integer',
        'points_earned' => 'integer',
    ];

    /**
     * Get the user that owns the session
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the schedule this session belongs to
     */
    public function schedule(): BelongsTo
    {
        return $this->belongsTo(PlannerSchedule::class, 'schedule_id');
    }

    /**
     * Get the subject for this session
     */
    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    /**
     * Get the chapter for this session (if any)
     */
    public function chapter(): BelongsTo
    {
        return $this->belongsTo(Chapter::class);
    }

    /**
     * Get the suggested content item
     */
    public function suggestedContent(): BelongsTo
    {
        return $this->belongsTo(Content::class, 'suggested_content_id');
    }

    /**
     * Get the curriculum content item for this session (if linked)
     * This links the session to the structured curriculum
     */
    public function curriculumContent(): BelongsTo
    {
        return $this->belongsTo(SubjectPlannerContent::class, 'subject_planner_content_id');
    }

    /**
     * Alias for curriculumContent - for consistency with plan naming
     */
    public function subjectPlannerContent(): BelongsTo
    {
        return $this->belongsTo(SubjectPlannerContent::class);
    }

    /**
     * Get the original topic test session (for spaced review sessions)
     */
    public function originalTopicTestSession(): BelongsTo
    {
        return $this->belongsTo(PlannerStudySession::class, 'original_topic_test_session_id');
    }

    /**
     * Get the spaced review sessions derived from this topic test
     */
    public function spacedReviewSessions()
    {
        return $this->hasMany(PlannerStudySession::class, 'original_topic_test_session_id');
    }

    /**
     * Scope for scheduled sessions
     */
    public function scopeScheduled($query)
    {
        return $query->where('status', 'scheduled');
    }

    /**
     * Scope for completed sessions
     */
    public function scopeCompleted($query)
    {
        return $query->where('status', 'completed');
    }

    /**
     * Scope for today's sessions
     */
    public function scopeToday($query)
    {
        return $query->whereDate('scheduled_date', today());
    }

    /**
     * Scope for spaced review sessions
     */
    public function scopeSpacedReviews($query)
    {
        return $query->where('is_spaced_review', true);
    }

    /**
     * Scope for sessions due for spaced review on a specific date
     */
    public function scopeDueSpacedReviews($query, $date = null)
    {
        $date = $date ?? today();
        return $query->where('is_spaced_review', true)
                     ->whereDate('scheduled_date', $date)
                     ->where('status', 'scheduled');
    }

    /**
     * Scope for sessions with curriculum content linked
     */
    public function scopeWithContent($query)
    {
        return $query->where('has_content', true)
                     ->whereNotNull('subject_planner_content_id');
    }

    /**
     * Scope for sessions without curriculum content
     */
    public function scopeWithoutContent($query)
    {
        return $query->where('has_content', false);
    }

    /**
     * Scope for late (missed and rescheduled) sessions
     */
    public function scopeLate($query)
    {
        return $query->where('is_late', true);
    }

    /**
     * Scope for mock test sessions
     */
    public function scopeMockTests($query)
    {
        return $query->where('is_mock_test', true);
    }

    /**
     * Scope for language daily sessions
     */
    public function scopeLanguageDaily($query)
    {
        return $query->where('is_language_daily', true);
    }

    /**
     * Scope for topic test sessions
     */
    public function scopeTopicTests($query)
    {
        return $query->where('session_type', self::TYPE_TOPIC_TEST);
    }

    /**
     * Scope for sessions due on a specific date
     */
    public function scopeDueOn($query, $date)
    {
        return $query->whereDate('due_date', $date);
    }

    /**
     * Scope for sessions of a specific subject category
     */
    public function scopeOfCategory($query, string $category)
    {
        return $query->where('subject_category', $category);
    }

    /**
     * Check if this is a test session type
     */
    public function isTestSession(): bool
    {
        return in_array($this->session_type, [
            self::TYPE_TOPIC_TEST,
            self::TYPE_MOCK_TEST,
        ]);
    }

    /**
     * Check if score-based adaptation is needed
     */
    public function needsScoreAdaptation(): bool
    {
        return $this->session_type === self::TYPE_TOPIC_TEST
            && $this->score !== null;
    }
}
