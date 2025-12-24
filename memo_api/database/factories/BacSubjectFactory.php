<?php

namespace Database\Factories;

use App\Models\BacSubject;
use App\Models\BacYear;
use App\Models\BacSession;
use App\Models\Subject;
use App\Models\AcademicStream;
use Illuminate\Database\Eloquent\Factories\Factory;

class BacSubjectFactory extends Factory
{
    protected $model = BacSubject::class;

    public function definition(): array
    {
        $subjects = [
            'الرياضيات',
            'الفيزياء',
            'العلوم الطبيعية',
            'اللغة العربية',
            'اللغة الفرنسية',
            'اللغة الإنجليزية',
            'التاريخ والجغرافيا',
            'الفلسفة',
            'العلوم الإسلامية',
        ];

        return [
            'bac_year_id' => BacYear::factory(),
            'bac_session_id' => BacSession::factory(),
            'subject_id' => Subject::inRandomOrder()->first()?->id ?? null,
            'academic_stream_id' => AcademicStream::inRandomOrder()->first()?->id ?? null,
            'title_ar' => $this->faker->randomElement($subjects),
            'file_path' => 'bac/subjects/' . $this->faker->uuid() . '.pdf',
            'correction_file_path' => $this->faker->boolean(70) ? 'bac/corrections/' . $this->faker->uuid() . '.pdf' : null,
            'duration_minutes' => $this->faker->randomElement([120, 180, 240]),
            'views_count' => $this->faker->numberBetween(0, 1000),
            'downloads_count' => $this->faker->numberBetween(0, 500),
        ];
    }

    public function withCorrection(): static
    {
        return $this->state(fn (array $attributes) => [
            'correction_file_path' => 'bac/corrections/' . $this->faker->uuid() . '.pdf',
        ]);
    }

    public function withoutCorrection(): static
    {
        return $this->state(fn (array $attributes) => [
            'correction_file_path' => null,
        ]);
    }
}
