<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Lightweight resource for course lists - includes all course info but no modules/lessons details.
 * Uses pre-calculated counts to avoid N+1 queries.
 */
class CourseListResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        // Use pre-loaded counts if available, otherwise use cached values from course table
        $modulesCount = $this->whenLoaded('modules', fn() => $this->modules->where('is_published', true)->count(), $this->modules_count ?? 0);
        $lessonsCount = $this->lessons_count ?? 0;
        $durationMinutes = $this->duration_minutes ?? 0;

        // If modules are loaded with lessons, calculate from them
        if ($this->relationLoaded('modules') && $this->modules->isNotEmpty()) {
            $publishedModules = $this->modules->where('is_published', true);
            $modulesCount = $publishedModules->count();

            // Only calculate lessons if they're loaded on modules
            if ($publishedModules->first() && $publishedModules->first()->relationLoaded('lessons')) {
                $lessonsCount = $publishedModules->sum(fn($m) => $m->lessons->where('is_published', true)->count());
                $durationMinutes = $publishedModules->sum(fn($m) => $m->lessons->where('is_published', true)->sum('video_duration_seconds')) / 60;
            }
        }

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
            'subject_name' => $this->whenLoaded('subject', fn() => $this->subject->name_ar ?? '', ''),
            'level' => $this->level ?? 'beginner',

            // Pricing
            'price_dzd' => (int) ($this->price_dzd ?? 0),
            'is_free_access' => (bool) $this->is_free,

            // Duration
            'duration_days' => (int) ($this->duration_days ?? 30),
            'duration_minutes' => (int) $durationMinutes,

            // Stats (using pre-calculated or cached values)
            'modules_count' => (int) $modulesCount,
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
