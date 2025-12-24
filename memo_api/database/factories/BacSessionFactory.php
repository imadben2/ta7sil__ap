<?php

namespace Database\Factories;

use App\Models\BacSession;
use Illuminate\Database\Eloquent\Factories\Factory;

class BacSessionFactory extends Factory
{
    protected $model = BacSession::class;

    public function definition(): array
    {
        $sessions = [
            ['name_ar' => 'الدورة العادية', 'slug' => 'normal'],
            ['name_ar' => 'دورة الاستدراك', 'slug' => 'makeup'],
            ['name_ar' => 'الدورة الاستثنائية', 'slug' => 'exceptional'],
        ];

        $session = $this->faker->randomElement($sessions);

        return [
            'name_ar' => $session['name_ar'],
            'slug' => $session['slug'],
        ];
    }
}
