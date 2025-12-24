<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PlannerExam extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'subject_id',
        'title',
        'description',
        'exam_date',
        'exam_time',
        'duration_minutes',
        'location',
        'score',
        'max_score',
        'percentage',
        'grade',
        'notes',
        'triggered_adaptation',
        'adaptation_triggered_at',
    ];

    protected $casts = [
        'exam_date' => 'date',
        'score' => 'float',
        'max_score' => 'float',
        'percentage' => 'float',
        'duration_minutes' => 'integer',
        'triggered_adaptation' => 'boolean',
        'adaptation_triggered_at' => 'datetime',
    ];

    /**
     * Get the user that owns the exam
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the subject for this exam
     */
    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    /**
     * Scope for upcoming exams
     */
    public function scopeUpcoming($query)
    {
        return $query->where('exam_date', '>=', today())->orderBy('exam_date');
    }

    /**
     * Scope for past exams
     */
    public function scopePast($query)
    {
        return $query->where('exam_date', '<', today())->orderBy('exam_date', 'desc');
    }
}
