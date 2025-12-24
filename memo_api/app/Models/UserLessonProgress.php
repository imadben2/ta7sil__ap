<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserLessonProgress extends Model
{
    protected $fillable = [
        'user_id',
        'course_lesson_id',
        'watch_time_seconds',
        'video_duration_seconds',
        'is_completed',
        'completed_at',
        'last_position_seconds',
        'last_watched_at',
    ];

    protected $casts = [
        'user_id' => 'integer',
        'course_lesson_id' => 'integer',
        'watch_time_seconds' => 'integer',
        'video_duration_seconds' => 'integer',
        'is_completed' => 'boolean',
        'completed_at' => 'datetime',
        'last_position_seconds' => 'integer',
        'last_watched_at' => 'datetime',
    ];

    // Relationships
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function lesson(): BelongsTo
    {
        return $this->belongsTo(CourseLesson::class, 'course_lesson_id');
    }

    // Helper methods
    public function getProgressPercentage(): float
    {
        if ($this->video_duration_seconds === 0) {
            return 0;
        }

        return min(100, ($this->watch_time_seconds / $this->video_duration_seconds) * 100);
    }

    public function updateWatchTime(int $positionSeconds): void
    {
        $this->last_position_seconds = $positionSeconds;
        $this->last_watched_at = now();

        // Update watch time if position is greater than current
        if ($positionSeconds > $this->watch_time_seconds) {
            $this->watch_time_seconds = $positionSeconds;
        }

        // Check if should be marked as completed (watched 90% or more)
        $progressPercentage = $this->getProgressPercentage();
        if ($progressPercentage >= 90 && !$this->is_completed) {
            $this->markAsCompleted();
        }

        $this->save();
    }

    public function markAsCompleted(): void
    {
        $this->is_completed = true;
        $this->completed_at = now();
        $this->save();

        // Update course progress
        $courseId = $this->lesson->module->course_id;
        $userCourseProgress = UserCourseProgress::firstOrCreate([
            'user_id' => $this->user_id,
            'course_id' => $courseId,
        ]);

        $userCourseProgress->markLessonComplete();
    }

    public function getFormattedPosition(): string
    {
        $minutes = floor($this->last_position_seconds / 60);
        $seconds = $this->last_position_seconds % 60;

        return sprintf('%02d:%02d', $minutes, $seconds);
    }

    public function getFormattedWatchTime(): string
    {
        $minutes = floor($this->watch_time_seconds / 60);
        $seconds = $this->watch_time_seconds % 60;

        return sprintf('%02d:%02d', $minutes, $seconds);
    }
}
