<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserCourseProgress extends Model
{
    protected $fillable = [
        'user_id',
        'course_id',
        'completed_lessons',
        'total_lessons',
        'completed_quizzes',
        'total_quizzes',
        'progress_percentage',
        'total_watch_time_minutes',
        'last_accessed_at',
        'status',
        'completed_at',
    ];

    protected $casts = [
        'user_id' => 'integer',
        'course_id' => 'integer',
        'completed_lessons' => 'integer',
        'total_lessons' => 'integer',
        'completed_quizzes' => 'integer',
        'total_quizzes' => 'integer',
        'progress_percentage' => 'decimal:2',
        'total_watch_time_minutes' => 'integer',
        'last_accessed_at' => 'datetime',
        'completed_at' => 'datetime',
    ];

    // Relationships
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function course(): BelongsTo
    {
        return $this->belongsTo(Course::class);
    }

    // Helper methods
    public function isCompleted(): bool
    {
        return $this->status === 'completed';
    }

    public function isInProgress(): bool
    {
        return $this->status === 'in_progress';
    }

    public function isNotStarted(): bool
    {
        return $this->status === 'not_started';
    }

    public function updateProgress(): void
    {
        $course = $this->course;

        // Calculate total items
        $this->total_lessons = $course->total_lessons;
        $this->total_quizzes = $course->total_quizzes;

        // Calculate progress percentage
        $totalItems = $this->total_lessons + $this->total_quizzes;
        $completedItems = $this->completed_lessons + $this->completed_quizzes;

        if ($totalItems > 0) {
            $this->progress_percentage = ($completedItems / $totalItems) * 100;
        } else {
            $this->progress_percentage = 0;
        }

        // Update status
        if ($this->progress_percentage === 0) {
            $this->status = 'not_started';
        } elseif ($this->progress_percentage >= 100) {
            $this->status = 'completed';
            if (!$this->completed_at) {
                $this->completed_at = now();
            }
        } else {
            $this->status = 'in_progress';
        }

        $this->save();
    }

    public function markLessonComplete(): void
    {
        $this->increment('completed_lessons');
        $this->last_accessed_at = now();
        $this->updateProgress();
    }

    public function markQuizComplete(): void
    {
        $this->increment('completed_quizzes');
        $this->last_accessed_at = now();
        $this->updateProgress();
    }

    public function addWatchTime(int $seconds): void
    {
        $minutes = ceil($seconds / 60);
        $this->increment('total_watch_time_minutes', $minutes);
        $this->last_accessed_at = now();
        $this->save();
    }

    public function getFormattedWatchTime(): string
    {
        $minutes = $this->total_watch_time_minutes;

        if ($minutes < 60) {
            return $minutes . ' دقيقة';
        }

        $hours = floor($minutes / 60);
        $remainingMinutes = $minutes % 60;

        if ($remainingMinutes === 0) {
            return $hours . ' ساعة';
        }

        return $hours . ' ساعة و ' . $remainingMinutes . ' دقيقة';
    }
}
