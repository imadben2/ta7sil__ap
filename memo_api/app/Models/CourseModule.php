<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class CourseModule extends Model
{
    protected $fillable = [
        'course_id',
        'title_ar',
        'description_ar',
        'order',
        'is_published',
    ];

    protected $casts = [
        'course_id' => 'integer',
        'order' => 'integer',
        'is_published' => 'boolean',
    ];

    // Relationships
    public function course(): BelongsTo
    {
        return $this->belongsTo(Course::class);
    }

    public function lessons(): HasMany
    {
        return $this->hasMany(CourseLesson::class)->orderBy('order');
    }

    public function quizzes(): HasMany
    {
        return $this->hasMany(CourseQuiz::class)->orderBy('order');
    }

    // Helper methods
    public function getLessonCount(): int
    {
        return $this->lessons()->count();
    }

    public function getQuizCount(): int
    {
        return $this->quizzes()->count();
    }

    public function getTotalDurationMinutes(): int
    {
        return $this->lessons()->sum('video_duration_seconds') / 60;
    }
}
