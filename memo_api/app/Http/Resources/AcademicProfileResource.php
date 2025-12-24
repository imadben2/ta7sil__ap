<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AcademicProfileResource extends JsonResource
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
            'education_level' => $this->education_level,
            'grade' => $this->grade,
            'specialization' => $this->specialization,
            'school_name' => $this->school_name,
            'target_score' => $this->target_score,
            'exam_date' => $this->exam_date?->format('Y-m-d'),
            'study_system' => $this->study_system,
        ];
    }
}
