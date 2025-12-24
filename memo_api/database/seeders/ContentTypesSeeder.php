<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ContentTypesSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $contentTypes = [
            ['name_ar' => 'درس', 'slug' => 'lesson', 'icon' => 'book-open'],
            ['name_ar' => 'ملخص', 'slug' => 'summary', 'icon' => 'file-text'],
            ['name_ar' => 'سلسلة تمارين', 'slug' => 'exercises', 'icon' => 'edit'],
            ['name_ar' => 'فرض', 'slug' => 'homework', 'icon' => 'clipboard'],
            ['name_ar' => 'اختبار', 'slug' => 'exam', 'icon' => 'file-check'],
            ['name_ar' => 'فيديو شرح', 'slug' => 'video', 'icon' => 'play-circle'],
            ['name_ar' => 'مسائل محلولة', 'slug' => 'solved-problems', 'icon' => 'check-circle'],
            ['name_ar' => 'بطاقات مراجعة', 'slug' => 'flashcards', 'icon' => 'layers'],
            ['name_ar' => 'خرائط ذهنية', 'slug' => 'mind-maps', 'icon' => 'share-2'],
            ['name_ar' => 'تطبيقات عملية', 'slug' => 'practical-apps', 'icon' => 'cpu'],
        ];

        foreach ($contentTypes as $contentType) {
            DB::table('content_types')->insert($contentType);
        }

        $this->command->info('Content types seeded successfully!');
        $this->command->info('- ' . count($contentTypes) . ' content types created');
    }
}
