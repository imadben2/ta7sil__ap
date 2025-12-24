<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class BacStudyDaySubject extends Model
{
    protected $fillable = [
        'bac_study_day_id',
        'subject_id',
        'order',
    ];

    protected $casts = [
        'order' => 'integer',
    ];

    /**
     * Get the study day that owns this record.
     */
    public function studyDay(): BelongsTo
    {
        return $this->belongsTo(BacStudyDay::class, 'bac_study_day_id');
    }

    /**
     * Get the subject.
     */
    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    /**
     * Get the topics for this day subject.
     */
    public function topics(): HasMany
    {
        return $this->hasMany(BacStudyDayTopic::class)->orderBy('order');
    }
}
