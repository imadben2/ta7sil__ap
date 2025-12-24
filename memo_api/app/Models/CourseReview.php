<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CourseReview extends Model
{
    protected $fillable = [
        'user_id',
        'course_id',
        'rating',
        'review_text_ar',
        'is_approved',
    ];

    protected $casts = [
        'user_id' => 'integer',
        'course_id' => 'integer',
        'rating' => 'integer',
        'is_approved' => 'boolean',
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
    public function approve(): void
    {
        $this->is_approved = true;
        $this->save();

        // Update course statistics
        $this->course->updateStatistics();
    }

    public function reject(): void
    {
        $this->is_approved = false;
        $this->save();

        // Update course statistics
        $this->course->updateStatistics();
    }

    public function getStarsHtml(): string
    {
        $html = '';
        for ($i = 1; $i <= 5; $i++) {
            if ($i <= $this->rating) {
                $html .= '<span class="text-yellow-400">★</span>';
            } else {
                $html .= '<span class="text-gray-300">★</span>';
            }
        }
        return $html;
    }

    public function getRatingText(): string
    {
        return match ($this->rating) {
            5 => 'ممتاز',
            4 => 'جيد جداً',
            3 => 'جيد',
            2 => 'مقبول',
            1 => 'ضعيف',
            default => 'غير معروف',
        };
    }
}
