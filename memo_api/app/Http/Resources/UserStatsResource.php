<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserStatsResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'overview' => [
                'total_study_hours' => round($this->total_study_minutes / 60, 1),
                'total_study_minutes' => $this->total_study_minutes,
                'current_streak' => $this->current_streak,
                'longest_streak' => $this->longest_streak,
                'total_memos' => $this->total_memos,
                'completed_memos' => $this->completed_memos,
            ],
            'progress' => [
                'completion_rate' => $this->total_memos > 0
                    ? round(($this->completed_memos / $this->total_memos) * 100, 1)
                    : 0,
                'avg_daily_minutes' => $this->avg_daily_minutes,
            ],
            'achievements' => [
                'total_achievements' => $this->total_achievements ?? 0,
                'unlocked_achievements' => $this->unlocked_achievements ?? 0,
            ],
            'last_activity' => [
                'last_study_at' => $this->last_study_at?->format('Y-m-d H:i:s'),
                'last_memo_at' => $this->last_memo_created_at?->format('Y-m-d H:i:s'),
            ],
        ];
    }
}
