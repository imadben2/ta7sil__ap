<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Facades\URL;

class CourseLesson extends Model
{
    protected $fillable = [
        'course_module_id',
        'title_ar',
        'description_ar',
        'order',
        'content_type', // video, document, quiz, text
        'video_type',
        'video_url',
        'video_duration_seconds',
        'video_thumbnail_url',
        'quiz_id',
        'document_path',
        'document_type',
        'has_attachments',
        'content_text_ar',
        'is_free_preview',
        'is_published',
    ];

    protected $casts = [
        'course_module_id' => 'integer',
        'order' => 'integer',
        'quiz_id' => 'integer',
        'video_duration_seconds' => 'integer',
        'has_attachments' => 'boolean',
        'is_free_preview' => 'boolean',
        'is_published' => 'boolean',
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

    public function attachments(): HasMany
    {
        return $this->hasMany(CourseLessonAttachment::class);
    }

    public function userProgress(): HasMany
    {
        return $this->hasMany(UserLessonProgress::class);
    }

    // Helper methods
    public function getSignedVideoUrl(int $expiresInMinutes = 60): string
    {
        if ($this->video_type === 'youtube') {
            return $this->video_url;
        }

        return URL::temporarySignedRoute(
            'lesson.video',
            now()->addMinutes($expiresInMinutes),
            ['lesson' => $this->id, 'video' => basename($this->video_url)]
        );
    }

    public function getDurationFormatted(): string
    {
        $minutes = floor($this->video_duration_seconds / 60);
        $seconds = $this->video_duration_seconds % 60;

        return sprintf('%02d:%02d', $minutes, $seconds);
    }

    public function isAccessibleByUser(User $user): bool
    {
        // Free preview lessons are accessible to everyone
        if ($this->is_free_preview) {
            return true;
        }

        // Check if user has subscription to the course
        $course = $this->module->course;

        return UserSubscription::where('user_id', $user->id)
            ->where('course_id', $course->id)
            ->where('status', 'active')
            ->where(function ($query) {
                $query->whereNull('expires_at')
                    ->orWhere('expires_at', '>', now());
            })
            ->exists();
    }
}
