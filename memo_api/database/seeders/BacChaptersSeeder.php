<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\BacSubject;
use App\Models\BacSubjectChapter;

class BacChaptersSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $this->command->info('📚 Creating BAC subject chapters...');

        $chapterTitles = [
            // Mathématiques
            'الأعداد المركبة',
            'الدوال الأسية',
            'الدوال اللوغاريتمية',
            'المتتاليات',
            'الهندسة الفضائية',
            'الاحتمالات',
            'التكامل',
            'المعادلات التفاضلية',

            // Physique
            'الميكانيك',
            'الكهرباء',
            'المغناطيسية',
            'الموجات',
            'البصريات',
            'الطاقة',

            // Sciences naturelles
            'الوراثة',
            'التطور',
            'المناعة',
            'الخلية',
            'التنفس الخلوي',
            'التركيب الضوئي',

            // Langue arabe
            'النصوص الأدبية',
            'القواعد',
            'البلاغة',
            'العروض',
            'التعبير الكتابي',

            // Général
            'الفصل الأول',
            'الفصل الثاني',
            'الفصل الثالث',
            'الفصل الرابع',
        ];

        $bacSubjects = BacSubject::all();
        $totalChapters = 0;

        foreach ($bacSubjects as $bacSubject) {
            // Create 2-5 random chapters for each BAC subject
            $numChapters = rand(2, 5);
            $selectedChapters = collect($chapterTitles)->random(min($numChapters, count($chapterTitles)));

            foreach ($selectedChapters as $index => $chapterTitle) {
                BacSubjectChapter::create([
                    'bac_subject_id' => $bacSubject->id,
                    'title_ar' => $chapterTitle,
                    'order' => $index + 1,
                ]);
                $totalChapters++;
            }
        }

        $this->command->info("✅ Created {$totalChapters} chapters for " . $bacSubjects->count() . " BAC subjects");
    }
}
