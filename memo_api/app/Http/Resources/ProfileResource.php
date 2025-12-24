<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProfileResource extends JsonResource
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
            'name' => $this->name,
            'email' => $this->email,
            'phone_number' => $this->phone_number,
            'photo_url' => $this->photo_url ? url('storage/' . $this->photo_url) : null,
            'bio' => $this->bio,
            'date_of_birth' => $this->date_of_birth?->format('Y-m-d'),
            'age' => $this->date_of_birth ? $this->date_of_birth->age : null,
            'gender' => $this->gender,
            'city' => $this->city,
            'country' => $this->country,
            'timezone' => $this->timezone,
            'location' => [
                'latitude' => $this->latitude,
                'longitude' => $this->longitude,
            ],
            'academic_profile' => new AcademicProfileResource($this->whenLoaded('academicProfile')),
            'stats' => new UserStatsResource($this->whenLoaded('stats')),
            'settings' => new UserSettingsResource($this->whenLoaded('settings')),
            'subjects' => SubjectResource::collection($this->whenLoaded('subjects')),
            'login_count' => $this->login_count,
            'last_login_at' => $this->last_login_at?->format('Y-m-d H:i:s'),
            'is_active' => $this->is_active,
            'email_verified_at' => $this->email_verified_at?->format('Y-m-d H:i:s'),
            'created_at' => $this->created_at->format('Y-m-d H:i:s'),
            'updated_at' => $this->updated_at->format('Y-m-d H:i:s'),
        ];
    }
}
