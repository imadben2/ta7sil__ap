<?php

namespace Database\Seeders;

use App\Models\Subject;
use App\Models\SubjectStream;
use App\Models\AcademicStream;
use Illuminate\Database\Seeder;

class SubjectStreamCoefficientsSeeder extends Seeder
{
    /**
     * Algerian Baccalaureate coefficients per stream
     * Stream IDs:
     * 1 = علوم تجريبية (Sciences Expérimentales)
     * 2 = رياضيات (Mathématiques)
     * 3 = تقني رياضي (Technique Mathématiques)
     * 4 = تسيير واقتصاد (Gestion et Économie)
     * 5 = آداب وفلسفة (Lettres et Philosophie)
     * 6 = لغات أجنبية (Langues Étrangères)
     */
    public function run(): void
    {
        // Coefficients by subject slug => [stream_id => coefficient]
        $coefficients = [
            // Common subjects across streams
            'arabic' => [
                1 => 3,  // Sciences
                2 => 3,  // Maths
                3 => 2,  // Technique
                4 => 3,  // Gestion
                5 => 5,  // Lettres - high
                6 => 3,  // Langues
            ],
            'french' => [
                1 => 2,
                2 => 2,
                3 => 2,
                4 => 2,
                5 => 3,
                6 => 4, // Langues - higher
            ],
            'english' => [
                1 => 2,
                2 => 2,
                3 => 2,
                4 => 2,
                5 => 2,
                6 => 4, // Langues - higher
            ],
            'islamic' => [
                1 => 2,
                2 => 2,
                3 => 2,
                4 => 2,
                5 => 2,
                6 => 2,
            ],
            'history_geo' => [
                1 => 2,
                2 => 2,
                3 => 2,
                4 => 3,
                5 => 4,
                6 => 3,
            ],
            'philosophy' => [
                1 => 2,
                2 => 2,
                3 => 2,
                4 => 2,
                5 => 6, // Lettres - very high
                6 => 3,
            ],
            'maths' => [
                1 => 5,
                2 => 7, // Maths stream - highest
                3 => 5,
                4 => 3,
                5 => 2,
                6 => 2,
            ],
            'physics' => [
                1 => 5,
                2 => 6,
                3 => 5,
                4 => 2,
                5 => 2,
                6 => 2,
            ],
            'biology' => [
                1 => 6, // Sciences - highest
                2 => 4,
            ],
            // Stream-specific subjects
            'electrical_eng' => [
                3 => 5, // Only Technique
            ],
            'mechanical_eng' => [
                3 => 5, // Only Technique
            ],
            'process_eng' => [
                3 => 5, // Only Technique
            ],
            'economy' => [
                4 => 6, // Only Gestion
            ],
            'accounting' => [
                4 => 5, // Only Gestion
            ],
            'law' => [
                4 => 3, // Only Gestion
            ],
        ];

        // Subject name mapping to find subjects
        $subjectNames = [
            'arabic' => 'اللغة العربية',
            'french' => 'اللغة الفرنسية',
            'english' => 'اللغة الإنجليزية',
            'islamic' => 'التربية الإسلامية',
            'history_geo' => 'التاريخ والجغرافيا',
            'philosophy' => 'الفلسفة',
            'maths' => 'الرياضيات',
            'physics' => 'العلوم الفيزيائية',
            'biology' => 'علوم الطبيعة والحياة',
            'electrical_eng' => 'الهندسة الكهربائية',
            'mechanical_eng' => 'الهندسة الميكانيكية',
            'process_eng' => 'هندسة الطرائق',
            'economy' => 'الاقتصاد',
            'accounting' => 'المحاسبة',
            'law' => 'القانون',
        ];

        // Categories per subject
        $categories = [
            'arabic' => SubjectStream::CATEGORY_LANGUAGE,
            'french' => SubjectStream::CATEGORY_LANGUAGE,
            'english' => SubjectStream::CATEGORY_LANGUAGE,
            'islamic' => SubjectStream::CATEGORY_MEMORIZATION,
            'history_geo' => SubjectStream::CATEGORY_MEMORIZATION,
            'philosophy' => SubjectStream::CATEGORY_MEMORIZATION,
            'maths' => SubjectStream::CATEGORY_HARD_CORE,
            'physics' => SubjectStream::CATEGORY_HARD_CORE,
            'biology' => SubjectStream::CATEGORY_HARD_CORE,
            'electrical_eng' => SubjectStream::CATEGORY_HARD_CORE,
            'mechanical_eng' => SubjectStream::CATEGORY_HARD_CORE,
            'process_eng' => SubjectStream::CATEGORY_HARD_CORE,
            'economy' => SubjectStream::CATEGORY_HARD_CORE,
            'accounting' => SubjectStream::CATEGORY_HARD_CORE,
            'law' => SubjectStream::CATEGORY_MEMORIZATION,
        ];

        foreach ($coefficients as $subjectKey => $streamCoefs) {
            $subjectName = $subjectNames[$subjectKey] ?? null;
            if (!$subjectName) {
                $this->command->warn("No name mapping for: {$subjectKey}");
                continue;
            }

            $subject = Subject::where('name_ar', $subjectName)->first();
            if (!$subject) {
                $this->command->warn("Subject not found: {$subjectName}");
                continue;
            }

            foreach ($streamCoefs as $streamId => $coef) {
                SubjectStream::updateOrCreate(
                    [
                        'subject_id' => $subject->id,
                        'academic_stream_id' => $streamId,
                    ],
                    [
                        'coefficient' => $coef,
                        'category' => $categories[$subjectKey] ?? SubjectStream::CATEGORY_OTHER,
                        'is_active' => true,
                    ]
                );
                $this->command->info("✅ {$subjectName} (stream {$streamId}): coef {$coef}");
            }
        }
    }
}
