<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\BacSubject;
use App\Models\BacYear;
use App\Models\BacSession;
use App\Models\Subject;
use App\Models\AcademicStream;

class BacSubjectsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create BAC years if they don't exist
        $years = [];
        foreach ([2023, 2022, 2021, 2020, 2019] as $year) {
            $years[] = BacYear::firstOrCreate(
                ['year' => $year],
                ['is_active' => true]
            );
        }

        // Create BAC sessions if they don't exist
        $sessions = [];
        $sessionNames = [
            ['name_ar' => 'دورة عادية', 'slug' => 'regular-session'],
            ['name_ar' => 'دورة استدراكية', 'slug' => 'makeup-session'],
        ];

        foreach ($sessionNames as $sessionData) {
            $sessions[] = BacSession::firstOrCreate(
                ['slug' => $sessionData['slug']],
                $sessionData
            );
        }

        // Get some subjects and streams
        $subjects = Subject::take(10)->get();
        $streams = AcademicStream::all();

        if ($subjects->isEmpty() || $streams->isEmpty()) {
            $this->command->warn('Please seed subjects and academic streams first!');
            return;
        }

        // Create 50 fake BAC subjects
        $titles = [
            'موضوع الرياضيات - المعادلات التفاضلية',
            'موضوع الفيزياء - الكهرومغناطيسية',
            'موضوع العلوم الطبيعية - الوراثة',
            'موضوع اللغة العربية - النصوص الأدبية',
            'موضوع اللغة الإنجليزية - القواعد المتقدمة',
            'موضوع الفلسفة - الأخلاق والقيم',
            'موضوع التاريخ - الثورة الجزائرية',
            'موضوع الجغرافيا - الموارد الطبيعية',
            'موضوع الاقتصاد - النظريات الاقتصادية',
            'موضوع القانون - الدستور الجزائري',
            'موضوع الرياضيات - الدوال اللوغاريتمية',
            'موضوع الفيزياء - الميكانيك الكلاسيكي',
            'موضوع الكيمياء - الكيمياء العضوية',
            'موضوع العلوم - التفاعلات الكيميائية',
            'موضوع اللغة الفرنسية - التعبير الكتابي',
            'موضوع الإحصاء - الاحتمالات',
            'موضوع الهندسة - الهندسة الفضائية',
            'موضوع البيولوجيا - الخلية والوراثة',
            'موضوع التكنولوجيا - البرمجة الأساسية',
            'موضوع الأدب العربي - الشعر الجاهلي',
        ];

        for ($i = 0; $i < 50; $i++) {
            $year = $years[array_rand($years)];
            $session = $sessions[array_rand($sessions)];
            $subject = $subjects->random();
            $stream = $streams->random();

            BacSubject::create([
                'bac_year_id' => $year->id,
                'bac_session_id' => $session->id,
                'subject_id' => $subject->id,
                'academic_stream_id' => $stream->id,
                'title_ar' => $titles[$i % count($titles)] . ' - ' . $year->year,
                'duration_minutes' => [120, 150, 180, 240][array_rand([120, 150, 180, 240])],
                'file_path' => 'bac_subjects/fake_subject_' . ($i + 1) . '.pdf',
                'correction_file_path' => rand(0, 1) ? 'bac_subjects/corrections/fake_correction_' . ($i + 1) . '.pdf' : null,
                'views_count' => rand(50, 500),
                'downloads_count' => rand(10, 200),
            ]);
        }

        $this->command->info('50 fake BAC subjects created successfully!');
    }
}
