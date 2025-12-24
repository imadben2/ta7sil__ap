<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PlannerSubject extends Model
{
    use HasFactory;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'planner_subjects';

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'user_id',
        'subject_id',
        'difficulty_level',
        'last_year_average',
        'priority',
        'progress_percentage',
        'is_active',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'difficulty_level' => 'integer',
        'last_year_average' => 'decimal:2',
        'progress_percentage' => 'integer',
        'is_active' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Get the user that owns the planner subject.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the subject details.
     */
    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    /**
     * Scope a query to only include active planner subjects.
     *
     * @param  \Illuminate\Database\Eloquent\Builder  $query
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope a query to only include subjects for a specific user.
     *
     * @param  \Illuminate\Database\Eloquent\Builder  $query
     * @param  int  $userId
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeForUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    /**
     * Scope a query to filter by priority.
     *
     * @param  \Illuminate\Database\Eloquent\Builder  $query
     * @param  string  $priority
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeByPriority($query, $priority)
    {
        return $query->where('priority', $priority);
    }

    /**
     * Get priority color for UI.
     *
     * @return string
     */
    public function getPriorityColorAttribute(): string
    {
        return match($this->priority) {
            'critical' => '#EF4444',
            'high' => '#F59E0B',
            'medium' => '#EAB308',
            'low' => '#10B981',
            default => '#6B7280',
        };
    }

    /**
     * Validation rules for creating/updating planner subjects.
     *
     * @return array
     */
    public static function validationRules(): array
    {
        return [
            'user_id' => 'required|exists:users,id',
            'subject_id' => 'required|exists:subjects,id',
            'difficulty_level' => 'nullable|integer|min:1|max:5',
            'last_year_average' => 'nullable|numeric|min:0|max:20',
            'priority' => 'nullable|in:low,medium,high,critical',
            'progress_percentage' => 'nullable|integer|min:0|max:100',
            'is_active' => 'nullable|boolean',
        ];
    }
}
