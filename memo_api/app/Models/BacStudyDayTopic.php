<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class BacStudyDayTopic extends Model
{
    protected $fillable = [
        'bac_study_day_subject_id',
        'topic_ar',
        'description_ar',
        'task_type',
        'order',
    ];

    protected $casts = [
        'order' => 'integer',
    ];

    /**
     * Get the day subject that owns this topic.
     */
    public function daySubject(): BelongsTo
    {
        return $this->belongsTo(BacStudyDaySubject::class, 'bac_study_day_subject_id');
    }

    /**
     * Get user progress records for this topic.
     */
    public function userProgress(): HasMany
    {
        return $this->hasMany(UserBacStudyProgress::class);
    }

    /**
     * Check if a specific user has completed this topic.
     */
    public function isCompletedByUser($userId): bool
    {
        return $this->userProgress()
            ->where('user_id', $userId)
            ->where('is_completed', true)
            ->exists();
    }
}
