<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class StudySession extends Model
{
    protected $fillable = [
        'user_id',
        'study_schedule_id',
        'subject_id',
        'chapter_id',
        'suggested_content_id',
        'suggested_content_type',
        'content_title',
        'scheduled_date',
        'scheduled_start_time',
        'scheduled_end_time',
        'estimated_duration_minutes',
        'required_energy_level',
        'session_type',
        'status',
        'actual_start_time',
        'actual_end_time',
        'actual_duration_minutes',
        'completion_percentage',
        'user_notes',
        'skipped_reason',
        'is_pinned',
        'priority_score',
        'priority_level', // Keep for backward compatibility
        'points_earned',
        'mood',
    ];

    protected $casts = [
        'scheduled_date' => 'date',
        'actual_start_time' => 'datetime',
        'actual_end_time' => 'datetime',
        'estimated_duration_minutes' => 'integer',
        'actual_duration_minutes' => 'integer',
        'completion_percentage' => 'integer',
        'is_pinned' => 'boolean',
        'priority_level' => 'integer',
        'priority_score' => 'integer',
    ];

    protected $appends = ['scheduled_start', 'scheduled_end', 'planned_duration_minutes', 'session_date', 'session_start_time', 'session_end_time', 'duration_minutes'];

    /**
     * Backward compatibility: session_date accessor
     */
    public function getSessionDateAttribute()
    {
        return $this->scheduled_date;
    }

    /**
     * Backward compatibility: session_start_time accessor
     */
    public function getSessionStartTimeAttribute()
    {
        return $this->scheduled_start_time;
    }

    /**
     * Backward compatibility: session_end_time accessor
     */
    public function getSessionEndTimeAttribute()
    {
        return $this->scheduled_end_time;
    }

    /**
     * Backward compatibility: duration_minutes accessor
     */
    public function getDurationMinutesAttribute()
    {
        return $this->estimated_duration_minutes;
    }

    /**
     * Get scheduled start datetime accessor
     */
    public function getScheduledStartAttribute()
    {
        if (!$this->scheduled_date || !$this->scheduled_start_time) {
            return null;
        }
        return \Carbon\Carbon::parse($this->scheduled_date->format('Y-m-d') . ' ' . $this->scheduled_start_time);
    }

    /**
     * Get scheduled end datetime accessor
     */
    public function getScheduledEndAttribute()
    {
        if (!$this->scheduled_date || !$this->scheduled_end_time) {
            return null;
        }
        return \Carbon\Carbon::parse($this->scheduled_date->format('Y-m-d') . ' ' . $this->scheduled_end_time);
    }

    /**
     * Get planned duration accessor (alias for estimated_duration_minutes)
     */
    public function getPlannedDurationMinutesAttribute()
    {
        return $this->estimated_duration_minutes;
    }

    /**
     * Get actual start accessor (alias for actual_start_time)
     */
    public function getActualStartAttribute()
    {
        return $this->actual_start_time;
    }

    /**
     * Get actual end accessor (alias for actual_end_time)
     */
    public function getActualEndAttribute()
    {
        return $this->actual_end_time;
    }

    /**
     * Get the user.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the study schedule.
     */
    public function studySchedule(): BelongsTo
    {
        return $this->belongsTo(StudySchedule::class);
    }

    /**
     * Get the subject.
     */
    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    /**
     * Get the suggested content.
     */
    public function suggestedContent(): BelongsTo
    {
        return $this->belongsTo(Content::class, 'suggested_content_id');
    }

    /**
     * Get the chapter for this session.
     */
    public function chapter(): BelongsTo
    {
        return $this->belongsTo(ContentChapter::class, 'chapter_id');
    }

    /**
     * Get the session activities.
     */
    public function activities(): HasMany
    {
        return $this->hasMany(SessionActivity::class);
    }

    /**
     * Get subject name accessor (for API responses)
     */
    public function getSubjectNameAttribute()
    {
        return $this->subject ? $this->subject->name_ar : null;
    }

    /**
     * Get chapter name accessor (for API responses)
     */
    public function getChapterNameAttribute()
    {
        return $this->chapter ? $this->chapter->title : null;
    }

    public function isCompleted(): bool
    {
        return $this->status === 'completed';
    }

    public function isMissed(): bool
    {
        return $this->status === 'missed';
    }

    public function isScheduled(): bool
    {
        return $this->status === 'scheduled';
    }

    public function scopeUpcoming($query)
    {
        return $query->where('status', 'scheduled')
            ->where('scheduled_date', '>', now()->toDateString());
    }

    public function scopeToday($query)
    {
        return $query->whereDate('scheduled_date', today());
    }

    public function scopeMissed($query)
    {
        return $query->where('status', 'missed');
    }
}
