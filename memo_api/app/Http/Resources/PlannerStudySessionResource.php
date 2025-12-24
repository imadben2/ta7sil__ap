<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PlannerStudySessionResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'schedule_id' => $this->schedule_id,
            'subject_id' => $this->subject_id,
            'chapter_id' => $this->chapter_id,

            // Content linking (NEW)
            'subject_planner_content_id' => $this->subject_planner_content_id,
            'has_content' => $this->has_content ?? true,
            'content_phase' => $this->content_phase,
            'is_spaced_review' => $this->is_spaced_review ?? false,
            'original_topic_test_session_id' => $this->original_topic_test_session_id,

            // Content details (NEW)
            'content' => $this->whenLoaded('subjectPlannerContent', function () {
                return [
                    'id' => $this->subjectPlannerContent->id,
                    'title_ar' => $this->subjectPlannerContent->title_ar,
                    'level' => $this->subjectPlannerContent->level,
                    'parent_title' => $this->getParentTitleChain(),
                    'full_path' => $this->subjectPlannerContent->full_path,
                    'difficulty_level' => $this->subjectPlannerContent->difficulty_level,
                    'estimated_duration_minutes' => $this->subjectPlannerContent->estimated_duration_minutes,
                    'is_bac_priority' => $this->subjectPlannerContent->is_bac_priority,
                    'requires_understanding' => $this->subjectPlannerContent->requires_understanding,
                    'requires_review' => $this->subjectPlannerContent->requires_review,
                    'requires_theory_practice' => $this->subjectPlannerContent->requires_theory_practice,
                    'requires_exercise_practice' => $this->subjectPlannerContent->requires_exercise_practice,
                ];
            }),

            // Scheduling
            'scheduled_date' => $this->scheduled_date?->format('Y-m-d'),
            'scheduled_start_time' => $this->scheduled_start_time,
            'scheduled_end_time' => $this->scheduled_end_time,
            'duration_minutes' => $this->duration_minutes,

            // Content suggestion (legacy)
            'suggested_content_id' => $this->suggested_content_id,
            'suggested_content_type' => $this->suggested_content_type,
            'content_title' => $this->content_title,
            'content_suggestion' => $this->content_suggestion,
            'topic_name' => $this->topic_name,

            // Session properties
            'session_type' => $this->session_type,
            'required_energy_level' => $this->required_energy_level,
            'estimated_energy_level' => $this->estimated_energy_level,
            'priority_score' => $this->priority_score,
            'is_pinned' => $this->is_pinned,
            'is_break' => $this->is_break,
            'is_prayer_time' => $this->is_prayer_time,

            // Pomodoro settings
            'use_pomodoro_technique' => $this->use_pomodoro_technique,
            'pomodoro_duration_minutes' => $this->pomodoro_duration_minutes,

            // Status tracking
            'status' => $this->status,
            'actual_start_time' => $this->actual_start_time?->toISOString(),
            'actual_end_time' => $this->actual_end_time?->toISOString(),
            'actual_duration_minutes' => $this->actual_duration_minutes,

            // Pomodoro tracking
            'current_pomodoro_count' => $this->current_pomodoro_count,
            'total_pomodoros_planned' => $this->total_pomodoros_planned,
            'pause_count' => $this->pause_count,

            // User interaction
            'user_notes' => $this->user_notes,
            'skip_reason' => $this->skip_reason,
            'completion_percentage' => $this->completion_percentage,
            'mood' => $this->mood,

            // Points & gamification
            'points_earned' => $this->points_earned,

            // Relationships
            'subject' => $this->whenLoaded('subject', function () {
                return [
                    'id' => $this->subject->id,
                    'name' => $this->subject->name,
                    'name_ar' => $this->subject->name_ar,
                    'slug' => $this->subject->slug,
                    'color' => $this->subject->color,
                    'icon' => $this->subject->icon,
                    'coefficient' => $this->subject->coefficient,
                ];
            }),

            // Algorithm fields from promt.md
            'is_late' => $this->is_late ?? false,
            'is_mock_test' => $this->is_mock_test ?? false,
            'is_language_daily' => $this->is_language_daily ?? false,
            'score' => $this->score,
            'priority_score_calculated' => $this->priority_score_calculated,
            'subject_category' => $this->subject_category ?? $this->subject?->category,
            'due_date' => $this->due_date?->format('Y-m-d'),

            // Timestamps
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }

    /**
     * Get the parent title chain for content context
     */
    protected function getParentTitleChain(): ?string
    {
        if (!$this->subjectPlannerContent) {
            return null;
        }

        $content = $this->subjectPlannerContent;
        $titles = [];

        if ($content->parent) {
            $titles[] = $content->parent->title_ar;

            if ($content->parent->parent) {
                array_unshift($titles, $content->parent->parent->title_ar);
            }
        }

        return empty($titles) ? null : implode(' > ', $titles);
    }
}
