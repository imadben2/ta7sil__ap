<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserBacStudyProgress extends Model
{
    protected $table = 'user_bac_study_progress';

    protected $fillable = [
        'user_id',
        'bac_study_day_topic_id',
        'is_completed',
        'completed_at',
    ];

    protected $casts = [
        'is_completed' => 'boolean',
        'completed_at' => 'datetime',
    ];

    /**
     * Get the user that owns this progress.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the topic for this progress.
     */
    public function topic(): BelongsTo
    {
        return $this->belongsTo(BacStudyDayTopic::class, 'bac_study_day_topic_id');
    }

    /**
     * Scope to filter by user.
     */
    public function scopeByUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    /**
     * Scope to filter completed items.
     */
    public function scopeCompleted($query)
    {
        return $query->where('is_completed', true);
    }
}
