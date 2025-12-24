<?php

namespace Database\Seeders;

use App\Models\Content;
use App\Models\ContentChapter;
use App\Models\ContentType;
use App\Models\Subject;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class ContentSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get subjects and content types
        $mathSubject = Subject::where('slug', 'math')->first();
        $physicsSubject = Subject::where('slug', 'physics')->first();
        $arabicSubject = Subject::where('slug', 'arabic')->first();

        $lessonType = ContentType::where('slug', 'lesson')->first();
        $summaryType = ContentType::where('slug', 'summary')->first();
        $exercisesType = ContentType::where('slug', 'exercises')->first();
        $testType = ContentType::where('slug', 'test')->first();

        if (!$mathSubject || !$lessonType) {
            $this->command->warn('Required subjects or content types not found. Run AcademicStructureSeeder and ContentTypesSeeder first.');
            return;
        }

        // Create chapters for Math
        $mathChapter1 = ContentChapter::create([
            'subject_id' => $mathSubject->id,
            'title_ar' => 'الدوال العددية',
            'slug' => 'numerical-functions',
            'description_ar' => 'دراسة الدوال العددية وخصائصها',
            'order' => 1,
            'is_active' => true,
        ]);

        $mathChapter2 = ContentChapter::create([
            'subject_id' => $mathSubject->id,
            'title_ar' => 'المتتاليات العددية',
            'slug' => 'sequences',
            'description_ar' => 'دراسة المتتاليات العددية والنهايات',
            'order' => 2,
            'is_active' => true,
        ]);

        // Math content
        $mathContents = [
            // Chapter 1: Numerical Functions
            [
                'subject_id' => $mathSubject->id,
                'content_type_id' => $lessonType->id,
                'content_chapter_id' => $mathChapter1->id,
                'title_ar' => 'تعريف الدالة العددية',
                'slug' => 'definition-of-numerical-function',
                'description_ar' => 'درس تمهيدي حول مفهوم الدالة العددية ومجموعة التعريف',
                'content_body_ar' => '<h2>تعريف الدالة</h2><p>الدالة العددية هي علاقة تربط كل عنصر من مجموعة الانطلاق بعنصر وحيد من مجموعة الوصول.</p>',
                'difficulty_level' => 'easy',
                'estimated_duration_minutes' => 30,
                'order' => 1,
                'is_published' => true,
                'published_at' => now(),
                'tags' => json_encode(['الدوال', 'التعريف', 'الأساسيات']),
            ],
            [
                'subject_id' => $mathSubject->id,
                'content_type_id' => $lessonType->id,
                'content_chapter_id' => $mathChapter1->id,
                'title_ar' => 'العمليات على الدوال',
                'slug' => 'operations-on-functions',
                'description_ar' => 'الجمع والطرح والضرب والقسمة للدوال العددية',
                'content_body_ar' => '<h2>العمليات على الدوال</h2><p>يمكن إجراء عمليات حسابية على الدوال العددية مثل الجمع والطرح والضرب.</p>',
                'difficulty_level' => 'medium',
                'estimated_duration_minutes' => 45,
                'order' => 2,
                'is_published' => true,
                'published_at' => now(),
                'tags' => json_encode(['الدوال', 'العمليات الحسابية']),
            ],
            [
                'subject_id' => $mathSubject->id,
                'content_type_id' => $summaryType->id,
                'content_chapter_id' => $mathChapter1->id,
                'title_ar' => 'ملخص الدوال العددية',
                'slug' => 'summary-numerical-functions',
                'description_ar' => 'ملخص شامل لدروس الدوال العددية',
                'content_body_ar' => '<h2>ملخص</h2><ul><li>تعريف الدالة</li><li>مجموعة التعريف</li><li>العمليات</li></ul>',
                'difficulty_level' => 'easy',
                'estimated_duration_minutes' => 20,
                'order' => 3,
                'is_published' => true,
                'published_at' => now(),
                'tags' => json_encode(['ملخص', 'الدوال', 'مراجعة']),
            ],
            [
                'subject_id' => $mathSubject->id,
                'content_type_id' => $exercisesType->id,
                'content_chapter_id' => $mathChapter1->id,
                'title_ar' => 'سلسلة تمارين حول الدوال',
                'slug' => 'exercises-numerical-functions',
                'description_ar' => 'تمارين محلولة حول الدوال العددية',
                'content_body_ar' => '<h2>تمارين</h2><p>تمرين 1: احسب مجموعة تعريف الدالة...</p>',
                'difficulty_level' => 'medium',
                'estimated_duration_minutes' => 60,
                'order' => 4,
                'is_published' => true,
                'published_at' => now(),
                'tags' => json_encode(['تمارين', 'الدوال', 'حلول']),
            ],

            // Chapter 2: Sequences
            [
                'subject_id' => $mathSubject->id,
                'content_type_id' => $lessonType->id,
                'content_chapter_id' => $mathChapter2->id,
                'title_ar' => 'تعريف المتتالية العددية',
                'slug' => 'definition-of-sequence',
                'description_ar' => 'المتتاليات العددية وطرق تعريفها',
                'content_body_ar' => '<h2>المتتالية العددية</h2><p>المتتالية هي دالة معرفة على مجموعة الأعداد الطبيعية.</p>',
                'difficulty_level' => 'easy',
                'estimated_duration_minutes' => 35,
                'order' => 1,
                'is_published' => true,
                'published_at' => now(),
                'tags' => json_encode(['المتتاليات', 'التعريف']),
            ],
            [
                'subject_id' => $mathSubject->id,
                'content_type_id' => $lessonType->id,
                'content_chapter_id' => $mathChapter2->id,
                'title_ar' => 'نهاية متتالية',
                'slug' => 'limit-of-sequence',
                'description_ar' => 'دراسة نهاية المتتاليات العددية',
                'content_body_ar' => '<h2>نهاية المتتالية</h2><p>دراسة سلوك المتتالية عندما تؤول n إلى ما لا نهاية.</p>',
                'difficulty_level' => 'hard',
                'estimated_duration_minutes' => 50,
                'order' => 2,
                'is_published' => true,
                'published_at' => now(),
                'tags' => json_encode(['المتتاليات', 'النهايات']),
            ],
        ];

        foreach ($mathContents as $contentData) {
            Content::create($contentData);
        }

        // Physics content (if physics subject exists)
        if ($physicsSubject) {
            $physicsChapter = ContentChapter::create([
                'subject_id' => $physicsSubject->id,
                'title_ar' => 'المتابعة الزمنية لتحول كيميائي',
                'slug' => 'chemical-kinetics',
                'description_ar' => 'دراسة سرعة التفاعلات الكيميائية',
                'order' => 1,
                'is_active' => true,
            ]);

            $physicsContents = [
                [
                    'subject_id' => $physicsSubject->id,
                    'content_type_id' => $lessonType->id,
                    'content_chapter_id' => $physicsChapter->id,
                    'title_ar' => 'سرعة التفاعل الكيميائي',
                    'slug' => 'reaction-rate',
                    'description_ar' => 'تعريف وحساب سرعة التفاعل الكيميائي',
                    'content_body_ar' => '<h2>سرعة التفاعل</h2><p>السرعة اللحظية للتفاعل الكيميائي هي...</p>',
                    'difficulty_level' => 'medium',
                    'estimated_duration_minutes' => 40,
                    'order' => 1,
                    'is_published' => true,
                    'published_at' => now(),
                    'tags' => json_encode(['الفيزياء', 'الكيمياء', 'السرعة']),
                ],
                [
                    'subject_id' => $physicsSubject->id,
                    'content_type_id' => $exercisesType->id,
                    'content_chapter_id' => $physicsChapter->id,
                    'title_ar' => 'تمارين حول سرعة التفاعل',
                    'slug' => 'exercises-reaction-rate',
                    'description_ar' => 'تمارين محلولة ومقترحة',
                    'content_body_ar' => '<h2>تمارين</h2><p>تمرين 1: احسب السرعة اللحظية...</p>',
                    'difficulty_level' => 'medium',
                    'estimated_duration_minutes' => 55,
                    'order' => 2,
                    'is_published' => true,
                    'published_at' => now(),
                    'tags' => json_encode(['تمارين', 'الفيزياء']),
                ],
            ];

            foreach ($physicsContents as $contentData) {
                Content::create($contentData);
            }
        }

        // Arabic content (if arabic subject exists)
        if ($arabicSubject) {
            $arabicChapter = ContentChapter::create([
                'subject_id' => $arabicSubject->id,
                'title_ar' => 'الأدب العربي في العصر الجاهلي',
                'slug' => 'pre-islamic-literature',
                'description_ar' => 'دراسة خصائص الأدب الجاهلي',
                'order' => 1,
                'is_active' => true,
            ]);

            $arabicContents = [
                [
                    'subject_id' => $arabicSubject->id,
                    'content_type_id' => $lessonType->id,
                    'content_chapter_id' => $arabicChapter->id,
                    'title_ar' => 'الشعر الجاهلي',
                    'slug' => 'pre-islamic-poetry',
                    'description_ar' => 'خصائص ومميزات الشعر الجاهلي',
                    'content_body_ar' => '<h2>الشعر الجاهلي</h2><p>امتاز الشعر الجاهلي بالصدق في التعبير...</p>',
                    'difficulty_level' => 'easy',
                    'estimated_duration_minutes' => 35,
                    'order' => 1,
                    'is_published' => true,
                    'published_at' => now(),
                    'tags' => json_encode(['أدب', 'شعر', 'جاهلي']),
                ],
                [
                    'subject_id' => $arabicSubject->id,
                    'content_type_id' => $summaryType->id,
                    'content_chapter_id' => $arabicChapter->id,
                    'title_ar' => 'ملخص الأدب الجاهلي',
                    'slug' => 'summary-pre-islamic-literature',
                    'description_ar' => 'ملخص شامل للأدب الجاهلي',
                    'content_body_ar' => '<h2>ملخص</h2><ul><li>الشعر</li><li>النثر</li><li>الخطابة</li></ul>',
                    'difficulty_level' => 'easy',
                    'estimated_duration_minutes' => 25,
                    'order' => 2,
                    'is_published' => true,
                    'published_at' => now(),
                    'tags' => json_encode(['ملخص', 'أدب', 'مراجعة']),
                ],
            ];

            foreach ($arabicContents as $contentData) {
                Content::create($contentData);
            }
        }

        $this->command->info('Content seeded successfully!');
        $this->command->info('Created:');
        $this->command->info('- ' . count($mathContents) . ' Math contents');
        if ($physicsSubject) {
            $this->command->info('- 2 Physics contents');
        }
        if ($arabicSubject) {
            $this->command->info('- 2 Arabic contents');
        }
    }
}
