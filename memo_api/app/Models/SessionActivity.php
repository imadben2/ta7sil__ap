<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SessionActivity extends Model
{
    protected $fillable = [
        'study_session_id',
        'activity_type',
        'activity_time',
        'metadata',
    ];

    protected $casts = [
        'activity_time' => 'datetime',
        'metadata' => 'array',
    ];

    public function studySession(): BelongsTo
    {
        return $this->belongsTo(StudySession::class);
    }

    public function isStart(): bool
    {
        return $this->activity_type === 'start';
    }

    public function isPause(): bool
    {
        return $this->activity_type === 'pause';
    }

    public function isResume(): bool
    {
        return $this->activity_type === 'resume';
    }

    public function isComplete(): bool
    {
        return $this->activity_type === 'complete';
    }
}
