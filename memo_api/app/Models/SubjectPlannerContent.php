<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class SubjectPlannerContent extends Model
{
    use HasFactory, SoftDeletes;

    protected $table = 'subject_planner_content';

    protected $fillable = [
        'academic_phase_id',
        'academic_year_id',
        'academic_stream_ids',
        'trimester',
        'subject_id',
        'parent_id',
        'level',
        'code',
        'title_ar',
        'description_ar',
        'order',
        'content_type',
        'difficulty_level',
        'estimated_duration_minutes',
        'requires_understanding',
        'requires_review',
        'requires_theory_practice',
        'requires_exercise_practice',
        'learning_objectives',
        'competencies',
        'prerequisites',
        'related_content_ids',
        'related_chapter_id',
        'bac_exam_years',
        'is_bac_priority',
        'bac_frequency',
        'is_active',
        'is_published',
        'published_at',
        'created_by',
        'updated_by',
    ];

    protected $casts = [
        'academic_stream_ids' => 'array',
        'trimester' => 'integer',
        'requires_understanding' => 'boolean',
        'requires_review' => 'boolean',
        'requires_theory_practice' => 'boolean',
        'requires_exercise_practice' => 'boolean',
        'learning_objectives' => 'array',
        'competencies' => 'array',
        'prerequisites' => 'array',
        'related_content_ids' => 'array',
        'bac_exam_years' => 'array',
        'is_bac_priority' => 'boolean',
        'is_active' => 'boolean',
        'is_published' => 'boolean',
        'published_at' => 'datetime',
        'order' => 'integer',
        'estimated_duration_minutes' => 'integer',
        'bac_frequency' => 'integer',
    ];

    /**
     * Get the academic phase that owns this content.
     */
    public function academicPhase(): BelongsTo
    {
        return $this->belongsTo(AcademicPhase::class);
    }

    /**
     * Get the academic year that owns this content.
     */
    public function academicYear(): BelongsTo
    {
        return $this->belongsTo(AcademicYear::class);
    }

    /**
     * Get the academic streams associated with this content.
     */
    public function academicStreams()
    {
        return AcademicStream::whereIn('id', $this->academic_stream_ids ?? [])->get();
    }

    /**
     * Get the subject that owns this content.
     */
    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    /**
     * Get the parent content item (for hierarchical structure).
     */
    public function parent(): BelongsTo
    {
        return $this->belongsTo(SubjectPlannerContent::class, 'parent_id');
    }

    /**
     * Get the children content items (for hierarchical structure).
     */
    public function children(): HasMany
    {
        return $this->hasMany(SubjectPlannerContent::class, 'parent_id')->orderBy('order');
    }

    /**
     * Get all descendants recursively.
     */
    public function descendants(): HasMany
    {
        return $this->children()->with('descendants');
    }

    /**
     * Get the related chapter.
     */
    public function relatedChapter(): BelongsTo
    {
        return $this->belongsTo(ContentChapter::class, 'related_chapter_id');
    }

    /**
     * Get the user progress records for this content.
     */
    public function userProgress(): HasMany
    {
        return $this->hasMany(UserSubjectPlannerProgress::class);
    }

    /**
     * Get the BAC topic mappings.
     */
    public function bacTopicMappings(): HasMany
    {
        return $this->hasMany(BacTopicContentMapping::class);
    }

    /**
     * Get the BAC study day topics linked to this content.
     */
    public function bacTopics(): BelongsToMany
    {
        return $this->belongsToMany(
            BacStudyDayTopic::class,
            'bac_topic_content_mapping',
            'subject_planner_content_id',
            'bac_study_day_topic_id'
        )->withPivot('relevance_score');
    }

    /**
     * Get the user who created this content.
     */
    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    /**
     * Get the user who last updated this content.
     */
    public function updater(): BelongsTo
    {
        return $this->belongsTo(User::class, 'updated_by');
    }

    /**
     * Scope a query to only include published content.
     */
    public function scopePublished($query)
    {
        return $query->where('is_published', true)->where('is_active', true);
    }

    /**
     * Scope a query to filter by academic context.
     */
    public function scopeForAcademicContext($query, $phaseId, $yearId, $streamId = null)
    {
        $query->where('academic_phase_id', $phaseId)
              ->where('academic_year_id', $yearId);

        if ($streamId) {
            $query->where(function ($q) use ($streamId) {
                $q->whereJsonContains('academic_stream_ids', $streamId)
                  ->orWhereNull('academic_stream_ids');
            });
        }

        return $query;
    }

    /**
     * Scope a query to filter by subject.
     */
    public function scopeForSubject($query, $subjectId)
    {
        return $query->where('subject_id', $subjectId);
    }

    /**
     * Scope a query to get only root level items (no parent).
     */
    public function scopeRootLevel($query)
    {
        return $query->whereNull('parent_id');
    }

    /**
     * Scope a query to filter by level.
     */
    public function scopeByLevel($query, $level)
    {
        return $query->where('level', $level);
    }

    /**
     * Scope a query to get BAC priority content.
     */
    public function scopeBacPriority($query)
    {
        return $query->where('is_bac_priority', true)->orderByDesc('bac_frequency');
    }

    /**
     * Get the full hierarchical path (breadcrumb).
     */
    public function getFullPathAttribute(): string
    {
        $path = [$this->title_ar];
        $current = $this;

        while ($current->parent) {
            $current = $current->parent;
            array_unshift($path, $current->title_ar);
        }

        return implode(' > ', $path);
    }

    /**
     * Check if this content has prerequisites that are not completed by the user.
     */
    public function hasUnmetPrerequisites(int $userId): bool
    {
        if (empty($this->prerequisites)) {
            return false;
        }

        $completedIds = UserSubjectPlannerProgress::where('user_id', $userId)
            ->whereIn('subject_planner_content_id', $this->prerequisites)
            ->where('status', 'completed')
            ->pluck('subject_planner_content_id')
            ->toArray();

        return count($completedIds) < count($this->prerequisites);
    }

    /**
     * Get the hierarchy level number (for display indentation).
     */
    public function getHierarchyDepth(): int
    {
        $depth = 0;
        $current = $this;

        while ($current->parent) {
            $depth++;
            $current = $current->parent;
        }

        return $depth;
    }
}
