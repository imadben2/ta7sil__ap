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
            // Basic Info
            'id' => $this->id,
            'subject_id' => $this->subject_id,
            'title_ar' => $this->title_ar ?? '',
            'slug' => $this->slug ?? '',
            'description_ar' => $this->description_ar ?? '',
            'short_description_ar' => $this->short_description_ar ?? '',

            // Learning Content
            'what_you_will_learn' => $this->what_you_will_learn ?? [],
            'requirements' => $this->requirements ?? [],
            'target_audience' => $this->target_audience ?? [],

            // Media
            'thumbnail_url' => $this->thumbnail_url ?? '',
            'thumbnail_full_url' => $this->thumbnail_full_url,
            'promo_video_url' => $this->trailer_video_url,
            'trailer_video_type' => $this->trailer_video_type ?? 'youtube',

            // Subject & Level
            'subject_name' => $this->subject->name_ar ?? '',
            'level' => $this->level ?? 'beginner',

            // Pricing
            'price_dzd' => (int) ($this->price_dzd ?? 0),
            'is_free_access' => (bool) $this->is_free,

            // Duration
            'duration_days' => (int) ($this->duration_days ?? 30),
            'duration_minutes' => (int) $durationMinutes,

            // Stats
            'modules_count' => (int) $modules->count(),
            'lessons_count' => (int) $lessonsCount,
            'students_enrolled' => (int) ($this->enrollment_count ?? 0),
            'view_count' => (int) ($this->view_count ?? 0),
            'rating' => (float) ($this->average_rating ?? 0),
            'reviews_count' => (int) ($this->total_reviews ?? 0),

            // Settings
            'is_published' => (bool) $this->is_published,
            'is_featured' => (bool) $this->is_featured,
            'certificate_available' => (bool) ($this->certificate_available ?? true),

            // Tags
            'tags' => $this->tags ?? [],

            // Timestamps
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'published_at' => $this->published_at,
        ];
    }
}
