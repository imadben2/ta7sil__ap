<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserContentProgress extends Model
{
    protected $fillable = [
        'user_id',
        'content_id',
        'status',
        'progress_percentage',
        'time_spent_seconds',
        'is_completed',
        'started_at',
        'completed_at',
        'last_accessed_at',
    ];

    protected $casts = [
        'is_completed' => 'boolean',
        'started_at' => 'datetime',
        'completed_at' => 'datetime',
        'last_accessed_at' => 'datetime',
    ];

    /**
     * Get the user.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the content.
     */
    public function content(): BelongsTo
    {
        return $this->belongsTo(Content::class);
    }

    /**
     * Scope a query to only include completed progress.
     */
    public function scopeCompleted($query)
    {
        return $query->where('is_completed', true);
    }

    /**
     * Scope a query to only include in-progress content.
     */
    public function scopeInProgress($query)
    {
        return $query->where('is_completed', false)
            ->where('progress_percentage', '>', 0);
    }
}
