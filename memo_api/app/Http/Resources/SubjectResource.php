<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SubjectResource extends JsonResource
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
            'name_ar' => $this->name_ar,
            'name_en' => $this->name_en,
            'name_fr' => $this->name_fr,
            'code' => $this->code,
            'color' => $this->color,
            'icon' => $this->icon,
            'education_level' => $this->education_level,
            'grade' => $this->grade,
            'is_active' => $this->is_active,
        ];
    }
}
