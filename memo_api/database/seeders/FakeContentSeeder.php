<?php

namespace Database\Seeders;

use App\Models\Content;
use App\Models\ContentChapter;
use App\Models\ContentType;
use App\Models\Subject;
use Illuminate\Database\Seeder;

class FakeContentSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get all subjects and content types
        $subjects = Subject::all();
        $contentTypes = ContentType::all();

        if ($subjects->isEmpty() || $contentTypes->isEmpty()) {
            $this->command->warn('Required subjects or content types not found.');
            return;
        }

        $lessonType = $contentTypes->firstWhere('slug', 'lesson');
        $summaryType = $contentTypes->firstWhere('slug', 'summary');
        $exercisesType = $contentTypes->firstWhere('slug', 'exercise');
        $testType = $contentTypes->firstWhere('slug', 'test');

        // Arabic content titles and descriptions
        $contentTitles = [
            'lesson' => [
                'الدرس التمهيدي',
                'الدرس الأول - المفاهيم الأساسية',
                'الدرس الثاني - التطبيقات العملية',
                'الدرس الثالث - الحالات الخاصة',
                'الدرس الرابع - التحليل المعمق',
                'مقدمة في الموضوع',
                'المبادئ الأساسية',
                'التقنيات المتقدمة',
                'دراسة الحالات',
                'التطبيقات النظرية',
            ],
            'summary' => [
                'ملخص شامل للوحدة',
                'ملخص المفاهيم الأساسية',
                'ملخص التطبيقات',
                'ملخص القوانين والنظريات',
                'مراجعة عامة',
            ],
            'exercises' => [
                'سلسلة تمارين محلولة',
                'تمارين تطبيقية',
                'تمارين متنوعة',
                'تمارين للمراجعة',
                'تمارين الامتحانات',
            ],
            'test' => [
                'اختبار تقييمي',
                'اختبار الوحدة',
                'امتحان تجريبي',
                'اختبار شامل',
                'تقييم نهائي',
            ],
        ];

        $contentDescriptions = [
            'شرح مفصل للموضوع مع أمثلة توضيحية',
            'دراسة معمقة للمفاهيم الأساسية',
            'تطبيقات عملية ونماذج محلولة',
            'تحليل شامل للموضوع بطريقة مبسطة',
            'مراجعة كاملة مع التركيز على النقاط المهمة',
            'شرح تفصيلي مع رسومات توضيحية',
            'دروس مبسطة للفهم السريع',
            'محتوى تعليمي متكامل',
            'شرح بالأمثلة والتطبيقات',
            'دراسة شاملة للموضوع',
        ];

        $contentBodies = [
            '<h2>المقدمة</h2><p>في هذا الدرس سنتعرف على المفاهيم الأساسية والمبادئ الرئيسية.</p><h3>العناصر الأساسية</h3><ul><li>النقطة الأولى</li><li>النقطة الثانية</li><li>النقطة الثالثة</li></ul><h3>التطبيقات</h3><p>سنقوم بدراسة عدة تطبيقات عملية توضح هذه المفاهيم.</p>',
            '<h2>الموضوع</h2><p>يعتبر هذا الموضوع من المواضيع الهامة التي يجب على الطالب إتقانها.</p><h3>الشرح</h3><p>نبدأ بالتعريفات الأساسية ثم ننتقل إلى الأمثلة التوضيحية.</p><h3>الخلاصة</h3><p>في النهاية، يجب التركيز على فهم المبادئ الأساسية.</p>',
            '<h2>الدرس</h2><p>هذا درس شامل يغطي جميع جوانب الموضوع.</p><h3>القوانين الأساسية</h3><ol><li>القانون الأول</li><li>القانون الثاني</li><li>القانون الثالث</li></ol><h3>أمثلة محلولة</h3><p>مثال 1: ...<br>الحل: ...</p>',
            '<h2>المحتوى التعليمي</h2><p>سنتناول في هذا الدرس مختلف جوانب الموضوع بطريقة منهجية.</p><h3>النقاط الرئيسية</h3><p>يجب التركيز على فهم النقاط التالية بشكل جيد.</p>',
            '<h2>ملخص</h2><p>هذا ملخص شامل لجميع المفاهيم المدروسة.</p><ul><li>المفهوم الأول</li><li>المفهوم الثاني</li><li>المفهوم الثالث</li></ul><p>للمراجعة النهائية، يجب التركيز على هذه النقاط.</p>',
        ];

        $tags = [
            ['دروس', 'شرح', 'تعليم'],
            ['مراجعة', 'ملخصات', 'امتحانات'],
            ['تمارين', 'حلول', 'تطبيقات'],
            ['اختبارات', 'تقييم', 'امتحان'],
            ['مفاهيم', 'أساسيات', 'نظريات'],
            ['تطبيق', 'عملي', 'أمثلة'],
        ];

        $difficultyLevels = ['easy', 'medium', 'hard'];

        $createdContents = 0;

        // Create chapters and contents for each subject
        foreach ($subjects as $subject) {
            // Create 2-3 chapters per subject
            $chaptersCount = rand(2, 3);

            for ($chapterNum = 1; $chapterNum <= $chaptersCount; $chapterNum++) {
                $chapter = ContentChapter::create([
                    'subject_id' => $subject->id,
                    'title_ar' => "الوحدة {$chapterNum} - " . $subject->name_ar,
                    'slug' => $subject->slug . '-chapter-' . $chapterNum,
                    'description_ar' => 'وحدة تعليمية تغطي موضوعات ' . $subject->name_ar,
                    'order' => $chapterNum,
                    'is_active' => true,
                ]);

                // Create different types of content for each chapter
                $contentOrder = 1;

                // Lessons (3-5 per chapter)
                if ($lessonType) {
                    $lessonsCount = rand(3, 5);
                    for ($i = 0; $i < $lessonsCount; $i++) {
                        Content::create([
                            'subject_id' => $subject->id,
                            'content_type_id' => $lessonType->id,
                            'chapter_id' => $chapter->id,
                            'title_ar' => $contentTitles['lesson'][$i % count($contentTitles['lesson'])],
                            'slug' => $subject->slug . '-' . $chapter->id . '-lesson-' . ($i + 1),
                            'description_ar' => $contentDescriptions[array_rand($contentDescriptions)],
                            'content_body_ar' => $contentBodies[array_rand($contentBodies)],
                            'difficulty_level' => $difficultyLevels[array_rand($difficultyLevels)],
                            'estimated_duration_minutes' => rand(20, 60),
                            'order' => $contentOrder++,
                            'is_published' => rand(0, 10) > 1, // 90% published
                            'published_at' => now()->subDays(rand(1, 30)),
                            'is_premium' => rand(0, 10) > 7, // 30% premium
                            'tags' => json_encode($tags[array_rand($tags)]),
                            'views_count' => rand(50, 500),
                            'downloads_count' => rand(10, 200),
                        ]);
                        $createdContents++;
                    }
                }

                // Summary (1 per chapter)
                if ($summaryType) {
                    Content::create([
                        'subject_id' => $subject->id,
                        'content_type_id' => $summaryType->id,
                        'chapter_id' => $chapter->id,
                        'title_ar' => $contentTitles['summary'][array_rand($contentTitles['summary'])],
                        'slug' => $subject->slug . '-' . $chapter->id . '-summary',
                        'description_ar' => $contentDescriptions[array_rand($contentDescriptions)],
                        'content_body_ar' => $contentBodies[array_rand($contentBodies)],
                        'difficulty_level' => 'easy',
                        'estimated_duration_minutes' => rand(15, 30),
                        'order' => $contentOrder++,
                        'is_published' => true,
                        'published_at' => now()->subDays(rand(1, 30)),
                        'is_premium' => false,
                        'tags' => json_encode(['ملخص', 'مراجعة', $subject->name_ar]),
                        'views_count' => rand(100, 800),
                        'downloads_count' => rand(50, 400),
                    ]);
                    $createdContents++;
                }

                // Exercises (2-3 per chapter)
                if ($exercisesType) {
                    $exercisesCount = rand(2, 3);
                    for ($i = 0; $i < $exercisesCount; $i++) {
                        Content::create([
                            'subject_id' => $subject->id,
                            'content_type_id' => $exercisesType->id,
                            'chapter_id' => $chapter->id,
                            'title_ar' => $contentTitles['exercises'][$i % count($contentTitles['exercises'])],
                            'slug' => $subject->slug . '-' . $chapter->id . '-exercises-' . ($i + 1),
                            'description_ar' => $contentDescriptions[array_rand($contentDescriptions)],
                            'content_body_ar' => '<h2>التمارين</h2><p>تمرين 1: ...</p><p>تمرين 2: ...</p><p>تمرين 3: ...</p><h3>الحلول</h3><p>حل التمرين 1: ...</p>',
                            'difficulty_level' => $difficultyLevels[array_rand($difficultyLevels)],
                            'estimated_duration_minutes' => rand(30, 90),
                            'order' => $contentOrder++,
                            'is_published' => true,
                            'published_at' => now()->subDays(rand(1, 30)),
                            'is_premium' => rand(0, 10) > 6, // 40% premium
                            'tags' => json_encode(['تمارين', 'حلول', $subject->name_ar]),
                            'views_count' => rand(80, 600),
                            'downloads_count' => rand(30, 300),
                        ]);
                        $createdContents++;
                    }
                }

                // Test (1 per chapter)
                if ($testType) {
                    Content::create([
                        'subject_id' => $subject->id,
                        'content_type_id' => $testType->id,
                        'chapter_id' => $chapter->id,
                        'title_ar' => $contentTitles['test'][array_rand($contentTitles['test'])],
                        'slug' => $subject->slug . '-' . $chapter->id . '-test',
                        'description_ar' => 'اختبار تقييمي شامل للوحدة',
                        'content_body_ar' => '<h2>الاختبار</h2><p>السؤال 1: ...</p><p>السؤال 2: ...</p><p>السؤال 3: ...</p>',
                        'difficulty_level' => $difficultyLevels[array_rand($difficultyLevels)],
                        'estimated_duration_minutes' => rand(60, 120),
                        'order' => $contentOrder++,
                        'is_published' => rand(0, 10) > 2, // 80% published
                        'published_at' => now()->subDays(rand(1, 30)),
                        'is_premium' => rand(0, 10) > 5, // 50% premium
                        'tags' => json_encode(['اختبار', 'تقييم', $subject->name_ar]),
                        'views_count' => rand(60, 400),
                        'downloads_count' => rand(20, 250),
                    ]);
                    $createdContents++;
                }
            }
        }

        $this->command->info("✓ Created {$createdContents} fake contents successfully!");
        $this->command->info("✓ Subjects used: " . $subjects->count());
        $this->command->info("✓ Content types used: " . $contentTypes->count());
    }
}
