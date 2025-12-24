<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

/**
 * PlannerSchedule Model
 *
 * Unified schedule model that combines functionality from both
 * study_schedules and planner_schedules tables.
 */
class PlannerSchedule extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'academic_year_id',
        'academic_stream_id',
        'start_date',
        'end_date',
        'is_active',
        'adaptation_count',
        'last_adapted_at',
        'adaptation_reasons',
        'total_sessions',
        'completed_sessions',
        'completion_rate',
        // Merged from study_schedules
        'schedule_type',
        'status',
        'generation_algorithm_version',
        'total_study_hours',
        'subjects_covered',
        'feasibility_score',
        'generated_at',
        'activated_at',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'is_active' => 'boolean',
        'adaptation_reasons' => 'array',
        'subjects_covered' => 'array',
        'last_adapted_at' => 'datetime',
        'generated_at' => 'datetime',
        'activated_at' => 'datetime',
        'adaptation_count' => 'integer',
        'total_sessions' => 'integer',
        'completed_sessions' => 'integer',
        'completion_rate' => 'float',
        'total_study_hours' => 'decimal:2',
        'feasibility_score' => 'decimal:2',
    ];

    /**
     * Schedule type constants
     */
    const TYPE_DAILY = 'daily';
    const TYPE_WEEKLY = 'weekly';
    const TYPE_FULL = 'full';

    /**
     * Status constants
     */
    const STATUS_DRAFT = 'draft';
    const STATUS_ACTIVE = 'active';
    const STATUS_COMPLETED = 'completed';
    const STATUS_ARCHIVED = 'archived';

    /**
     * Get the user that owns the schedule
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the academic year
     */
    public function academicYear(): BelongsTo
    {
        return $this->belongsTo(AcademicYear::class);
    }

    /**
     * Get the academic stream
     */
    public function academicStream(): BelongsTo
    {
        return $this->belongsTo(AcademicStream::class);
    }

    /**
     * Get all study sessions for this schedule
     */
    public function studySessions(): HasMany
    {
        return $this->hasMany(PlannerStudySession::class, 'schedule_id');
    }

    /**
     * Scope to get only active schedules
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope to get schedules by status
     */
    public function scopeByStatus($query, string $status)
    {
        return $query->where('status', $status);
    }

    /**
     * Scope to get current schedules (active and within date range)
     */
    public function scopeCurrent($query)
    {
        return $query->where('is_active', true)
            ->where('start_date', '<=', now())
            ->where('end_date', '>=', now());
    }

    /**
     * Check if schedule is active
     */
    public function isActive(): bool
    {
        return $this->is_active && $this->status === self::STATUS_ACTIVE;
    }

    /**
     * Check if schedule is within its date range
     */
    public function isWithinDateRange(): bool
    {
        $now = now()->startOfDay();
        return $now->gte($this->start_date) && $now->lte($this->end_date);
    }

    /**
     * Get days remaining in schedule
     */
    public function getDaysRemaining(): int
    {
        if ($this->end_date->isPast()) {
            return 0;
        }
        return now()->diffInDays($this->end_date);
    }

    /**
     * Calculate and update completion rate
     */
    public function updateCompletionRate(): void
    {
        if ($this->total_sessions > 0) {
            $this->completion_rate = ($this->completed_sessions / $this->total_sessions) * 100;
            $this->save();
        }
    }

    /**
     * Activate this schedule and deactivate others for the same user
     */
    public function activate(): void
    {
        // Deactivate all other schedules for this user
        self::where('user_id', $this->user_id)
            ->where('id', '!=', $this->id)
            ->update(['is_active' => false, 'status' => self::STATUS_ARCHIVED]);

        // Activate this schedule
        $this->is_active = true;
        $this->status = self::STATUS_ACTIVE;
        $this->activated_at = now();
        $this->save();
    }

    /**
     * Archive this schedule
     */
    public function archive(): void
    {
        $this->is_active = false;
        $this->status = self::STATUS_ARCHIVED;
        $this->save();
    }
}
