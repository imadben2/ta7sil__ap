<?php

namespace Database\Factories;

use App\Models\BacSubjectChapter;
use App\Models\BacSubject;
use Illuminate\Database\Eloquent\Factories\Factory;

class BacSubjectChapterFactory extends Factory
{
    protected $model = BacSubjectChapter::class;

    public function definition(): array
    {
        $chapters = [
            'الأعداد المركبة',
            'الدوال الأسية',
            'الدوال اللوغاريتمية',
            'المتتاليات',
            'الهندسة الفضائية',
            'الاحتمالات',
            'التكامل',
            'المعادلات التفاضلية',
        ];

        return [
            'bac_subject_id' => BacSubject::factory(),
            'title_ar' => $this->faker->randomElement($chapters),
            'order' => $this->faker->numberBetween(1, 10),
        ];
    }
}
