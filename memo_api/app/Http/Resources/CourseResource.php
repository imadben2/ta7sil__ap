<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CourseResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        // Calculate course statistics
        $modules = $this->modules()->where('is_published', true)->get();
        $lessonsCount = $modules->sum(function ($module) {
            return $module->lessons()->where('is_published', true)->count();
        });
        $durationMinutes = $modules->sum(function ($module) {
            return $module->lessons()->where('is_published', true)->sum('video_duration_seconds');
        }) / 60;

        return [
            'id' => $this->id,
            'subject_id' => $this->subject_id,
            'title_ar' => $this->title_ar ?? '',
            'slug' => $this->slug ?? '',
            'description_ar' => $this->description_ar ?? '',
            'short_description' => $this->short_description_ar ?? '',
            'thumbnail_url' => $this->thumbnail_url ?? '',
            'preview_video_url' => $this->trailer_video_url, // Nullable
            'subject_name' => $this->subject->name_ar ?? '',
            'instructor_id' => 0, // No instructor ID in current schema
            'instructor_name' => $this->instructor_name ?? '',
            'teacher_avatar' => $this->instructor_photo_url, // Nullable
            'price_dzd' => (float) ($this->price_dzd ?? 0),
            'discount_percentage' => null, // Not in current schema
            'final_price' => (float) ($this->price_dzd ?? 0),
            'duration_minutes' => (int) ($durationMinutes),
            'lessons_count' => (int) $lessonsCount,
            'modules_count' => (int) $modules->count(),
            'students_enrolled' => (int) ($this->enrollment_count ?? 0),
            'rating' => (float) ($this->average_rating ?? 0),
            'reviews_count' => (int) ($this->total_reviews ?? 0),
            'is_purchased' => false, // Will be set by controller
            'is_featured' => (bool) $this->is_featured,
            'certificate_template' => null,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
