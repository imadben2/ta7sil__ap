<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Carbon\Carbon;

class ExamSchedule extends Model
{
    protected $table = 'exam_schedule';

    protected $fillable = [
        'user_id',
        'subject_id',
        'exam_type',
        'exam_date',
        'exam_time',
        'duration_minutes',
        'estimated_duration_minutes', // Keep for backward compatibility
        'importance_level',
        'preparation_days_before',
        'target_score',
        'is_completed',
        'actual_score',
        'chapters_covered',
    ];

    protected $casts = [
        'exam_date' => 'date',
        'is_completed' => 'boolean',
        'actual_score' => 'decimal:2',
        'target_score' => 'decimal:2',
        'importance_level' => 'string', // Now enum after migration
        'preparation_days_before' => 'integer',
        'duration_minutes' => 'integer',
        'estimated_duration_minutes' => 'integer',
        'chapters_covered' => 'array',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    public function daysUntilExam(): int
    {
        return Carbon::today()->diffInDays($this->exam_date, false);
    }

    public function isUpcoming(): bool
    {
        return !$this->is_completed && $this->exam_date->isFuture();
    }
}
