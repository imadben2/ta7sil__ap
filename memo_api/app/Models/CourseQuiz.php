<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CourseQuiz extends Model
{
    protected $fillable = [
        'course_module_id',
        'quiz_id',
        'order',
        'is_required',
        'passing_score',
    ];

    protected $casts = [
        'course_module_id' => 'integer',
        'quiz_id' => 'integer',
        'order' => 'integer',
        'is_required' => 'boolean',
        'passing_score' => 'integer',
    ];

    // Relationships
    public function module(): BelongsTo
    {
        return $this->belongsTo(CourseModule::class, 'course_module_id');
    }

    public function quiz(): BelongsTo
    {
        return $this->belongsTo(Quiz::class);
    }
}
