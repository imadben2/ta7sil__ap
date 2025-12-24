<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class StudySchedule extends Model
{
    protected $fillable = [
        'user_id',
        'schedule_type',
        'start_date',
        'end_date',
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
        'total_study_hours' => 'decimal:2',
        'subjects_covered' => 'array',
        'feasibility_score' => 'decimal:2',
        'generated_at' => 'datetime',
        'activated_at' => 'datetime',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function studySessions(): HasMany
    {
        return $this->hasMany(StudySession::class);
    }

    public function isActive(): bool
    {
        return $this->status === 'active';
    }

    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }
}
