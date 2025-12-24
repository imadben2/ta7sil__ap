<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CourseLessonAttachment extends Model
{
    protected $fillable = [
        'course_lesson_id',
        'file_name',
        'file_path',
        'file_type',
        'file_size_kb',
    ];

    protected $casts = [
        'course_lesson_id' => 'integer',
        'file_size_kb' => 'integer',
    ];

    // Relationships
    public function lesson(): BelongsTo
    {
        return $this->belongsTo(CourseLesson::class, 'course_lesson_id');
    }

    // Helper methods
    public function getFileSizeFormatted(): string
    {
        $sizeKb = $this->file_size_kb;

        if ($sizeKb < 1024) {
            return $sizeKb . ' KB';
        }

        $sizeMb = round($sizeKb / 1024, 2);
        return $sizeMb . ' MB';
    }

    public function getDownloadUrl(): string
    {
        return route('attachment.download', ['attachment' => $this->id]);
    }
}
