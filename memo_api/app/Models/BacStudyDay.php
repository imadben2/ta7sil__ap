<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class BacStudyDay extends Model
{
    protected $fillable = [
        'academic_stream_id',
        'day_number',
        'day_type',
        'title_ar',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'day_number' => 'integer',
    ];

    /**
     * Get the academic stream that owns this study day.
     */
    public function academicStream(): BelongsTo
    {
        return $this->belongsTo(AcademicStream::class);
    }

    /**
     * Get the subjects for this study day.
     */
    public function daySubjects(): HasMany
    {
        return $this->hasMany(BacStudyDaySubject::class)->orderBy('order');
    }

    /**
     * Scope to filter by stream.
     */
    public function scopeByStream($query, $streamId)
    {
        return $query->where('academic_stream_id', $streamId);
    }

    /**
     * Scope to filter active days.
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope to filter by day type.
     */
    public function scopeByType($query, $type)
    {
        return $query->where('day_type', $type);
    }

    /**
     * Get week number for this day.
     */
    public function getWeekNumberAttribute(): int
    {
        return (int) ceil($this->day_number / 7);
    }
}
