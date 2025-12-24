<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\BacYear;
use App\Models\BacSession;
use App\Models\BacSubject;
use App\Models\BacSubjectChapter;
use App\Models\Subject;
use App\Models\AcademicStream;

class BacDataSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $this->command->info('🚀 Starting BAC data seeding...');

        // Create BAC Sessions - GLOBAL (shared across ALL years)
        // Only 1 session needed: Normal (main session for all years)
        $this->command->info('📝 Creating BAC sessions (GLOBAL - shared across all years)...');
        $sessions = [
            ['name_ar' => 'الدورة العادية', 'slug' => 'normal', 'session_type' => 'main'],
        ];

        $createdSessions = [];
        foreach ($sessions as $sessionData) {
            $session = BacSession::firstOrCreate(
                ['slug' => $sessionData['slug']],
                $sessionData
            );
            $createdSessions[] = $session;
            $this->command->info("  ✓ Session: {$sessionData['name_ar']} (Global - all years)");
        }

        // Create BAC Years
        $this->command->info('📅 Creating BAC years...');
        $years = [2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024];
        $createdYears = [];

        foreach ($years as $year) {
            $bacYear = BacYear::firstOrCreate(
                ['year' => $year],
                ['is_active' => $year >= 2020]
            );
            $createdYears[] = $bacYear;
            $status = $bacYear->is_active ? '✅ Active' : '🔒 Inactive';
            $this->command->info("  ✓ Year: {$year} {$status}");
        }

        // Get existing subjects and streams
        $subjects = Subject::all();
        $streams = AcademicStream::all();

        if ($subjects->isEmpty() || $streams->isEmpty()) {
            $this->command->warn('⚠️  No subjects or streams found. Creating sample data...');

            // Create a sample stream if none exist
            if ($streams->isEmpty()) {
                $year = \App\Models\AcademicYear::first();
                if (!$year) {
                    $this->command->error('❌ No academic year found. Please seed academic data first.');
                    return;
                }

                $stream = AcademicStream::create([
                    'academic_year_id' => $year->id,
                    'name_ar' => 'علوم تجريبية',
                    'slug' => 'sciences',
                    'description_ar' => 'شعبة العلوم التجريبية',
                    'order' => 1,
                    'is_active' => true,
                ]);
                $streams = collect([$stream]);
            }

            // Create sample subjects if none exist
            if ($subjects->isEmpty()) {
                $sampleSubjects = [
                    ['name_ar' => 'الرياضيات', 'slug' => 'mathematics', 'color' => '#FF6B6B', 'coefficient' => 7],
                    ['name_ar' => 'الفيزياء', 'slug' => 'physics', 'color' => '#4ECDC4', 'coefficient' => 6],
                    ['name_ar' => 'العلوم الطبيعية', 'slug' => 'natural-sciences', 'color' => '#45B7D1', 'coefficient' => 6],
                    ['name_ar' => 'اللغة العربية', 'slug' => 'arabic', 'color' => '#96CEB4', 'coefficient' => 5],
                    ['name_ar' => 'اللغة الفرنسية', 'slug' => 'french', 'color' => '#FFEAA7', 'coefficient' => 3],
                ];

                foreach ($sampleSubjects as $subjectData) {
                    $stream = $streams->first();
                    $subjects[] = Subject::create([
                        'academic_stream_id' => $stream->id,
                        'academic_year_id' => $stream->academic_year_id,
                        'name_ar' => $subjectData['name_ar'],
                        'slug' => $subjectData['slug'],
                        'description_ar' => 'مادة ' . $subjectData['name_ar'],
                        'color' => $subjectData['color'],
                        'coefficient' => $subjectData['coefficient'],
                        'order' => count($subjects) + 1,
                        'is_active' => true,
                    ]);
                }
                $subjects = collect($subjects);
            }
        }

        // Create BAC Subjects with realistic data
        $this->command->info('📚 Creating BAC subjects...');
        $totalSubjects = 0;

        foreach ($createdYears as $bacYear) {
            foreach ($createdSessions as $session) {
                // Create 3-5 BAC subjects per year/session combination
                $numSubjects = rand(3, 5);

                for ($i = 0; $i < $numSubjects; $i++) {
                    $subject = $subjects->random();
                    $stream = $streams->random();

                    $hasCorrection = rand(0, 100) < 70; // 70% chance of having correction

                    $bacSubject = BacSubject::create([
                        'bac_year_id' => $bacYear->id,
                        'bac_session_id' => $session->id,
                        'subject_id' => $subject->id,
                        'academic_stream_id' => $stream->id,
                        'title_ar' => "امتحان {$subject->name_ar} - {$bacYear->year} - {$session->name_ar}",
                        'file_path' => "bac/subjects/{$bacYear->year}/{$session->slug}/{$subject->slug}.pdf",
                        'correction_file_path' => $hasCorrection ? "bac/corrections/{$bacYear->year}/{$session->slug}/{$subject->slug}_correction.pdf" : null,
                        'duration_minutes' => collect([120, 180, 240])->random(),
                        'views_count' => rand(50, 1000),
                        'downloads_count' => rand(20, 500),
                    ]);

                    // Create 2-4 chapters for each BAC subject
                    $chapterTitles = [
                        'الأعداد المركبة',
                        'الدوال الأسية',
                        'الدوال اللوغاريتمية',
                        'المتتاليات',
                        'الهندسة الفضائية',
                        'الاحتمالات',
                        'التكامل',
                        'المعادلات التفاضلية',
                        'الميكانيك',
                        'الكهرباء',
                    ];

                    $numChapters = rand(2, 4);
                    $selectedChapters = collect($chapterTitles)->random($numChapters);

                    foreach ($selectedChapters as $index => $chapterTitle) {
                        BacSubjectChapter::create([
                            'bac_subject_id' => $bacSubject->id,
                            'title_ar' => $chapterTitle,
                            'order' => $index + 1,
                        ]);
                    }

                    $totalSubjects++;
                }
            }
        }

        $this->command->info("  ✓ Created {$totalSubjects} BAC subjects with chapters");

        // Summary
        $this->command->newLine();
        $this->command->info('✅ BAC Data Seeding Summary:');
        $this->command->table(
            ['Category', 'Count'],
            [
                ['BAC Years', count($createdYears)],
                ['BAC Sessions', count($createdSessions)],
                ['BAC Subjects', $totalSubjects],
                ['Total Chapters', BacSubjectChapter::count()],
            ]
        );

        $this->command->newLine();
        $this->command->info('🎉 BAC data seeding completed successfully!');
        $this->command->info('🔗 You can now access the admin panel at: http://127.0.0.1:8085/admin/bac');
    }
}
