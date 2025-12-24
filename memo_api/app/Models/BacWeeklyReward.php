<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class BacWeeklyReward extends Model
{
    protected $fillable = [
        'academic_stream_id',
        'week_number',
        'title_ar',
        'description_ar',
        'movie_title',
        'movie_image',
    ];

    protected $casts = [
        'week_number' => 'integer',
    ];

    /**
     * Get the academic stream that owns this reward.
     */
    public function academicStream(): BelongsTo
    {
        return $this->belongsTo(AcademicStream::class);
    }

    /**
     * Scope to filter by stream.
     */
    public function scopeByStream($query, $streamId)
    {
        return $query->where('academic_stream_id', $streamId);
    }
}
