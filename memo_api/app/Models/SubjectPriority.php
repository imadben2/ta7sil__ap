<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SubjectPriority extends Model
{
    protected $fillable = [
        'user_id',
        'subject_id',
        'coefficient_score',
        'exam_proximity_score',
        'difficulty_score',
        'performance_gap_score',
        'historical_performance_gap_score',
        'inactivity_score',
        'total_priority_score',
        'last_calculated_at',
        'calculated_at',
    ];

    protected $casts = [
        'coefficient_score' => 'decimal:2',
        'exam_proximity_score' => 'decimal:2',
        'difficulty_score' => 'decimal:2',
        'performance_gap_score' => 'decimal:2',
        'historical_performance_gap_score' => 'decimal:2',
        'inactivity_score' => 'decimal:2',
        'total_priority_score' => 'decimal:2',
        'last_calculated_at' => 'datetime',
        'calculated_at' => 'datetime',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }
}
