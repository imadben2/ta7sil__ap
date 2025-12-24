<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class BacStudyScheduleSeeder extends Seeder
{
    /**
     * Run the database seeds.
     * BAC Study Schedule for 98 days - Sciences Expérimentales
     */
    public function run(): void
    {
        // Get sciences-exp stream ID
        $streamId = DB::table('academic_streams')->where('slug', 'sciences-exp')->value('id');

        if (!$streamId) {
            $this->command->error('Stream sciences-exp not found! Run AcademicStructureSeeder first.');
            return;
        }

        // Get subject IDs
        $subjects = DB::table('subjects')
            ->where('academic_stream_id', $streamId)
            ->pluck('id', 'slug')
            ->toArray();

        $this->command->info('Seeding BAC Study Schedule for sciences-exp...');

        // Study schedule data (98 days)
        $days = $this->getStudyDays();

        foreach ($days as $dayData) {
            // Create study day
            $dayId = DB::table('bac_study_days')->insertGetId([
                'academic_stream_id' => $streamId,
                'day_number' => $dayData['day_number'],
                'day_type' => $dayData['day_type'],
                'title_ar' => $dayData['title_ar'] ?? null,
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // Create day subjects and topics
            if (isset($dayData['subjects'])) {
                $subjectOrder = 1;
                foreach ($dayData['subjects'] as $subjectData) {
                    $subjectId = $subjects[$subjectData['slug']] ?? null;

                    if (!$subjectId) {
                        $this->command->warn("Subject {$subjectData['slug']} not found, skipping...");
                        continue;
                    }

                    $daySubjectId = DB::table('bac_study_day_subjects')->insertGetId([
                        'bac_study_day_id' => $dayId,
                        'subject_id' => $subjectId,
                        'order' => $subjectOrder++,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);

                    // Create topics
                    $topicOrder = 1;
                    foreach ($subjectData['topics'] as $topic) {
                        DB::table('bac_study_day_topics')->insert([
                            'bac_study_day_subject_id' => $daySubjectId,
                            'topic_ar' => $topic['topic_ar'],
                            'description_ar' => $topic['description_ar'] ?? null,
                            'task_type' => $topic['task_type'] ?? 'study',
                            'order' => $topicOrder++,
                            'created_at' => now(),
                            'updated_at' => now(),
                        ]);
                    }
                }
            }
        }

        // Seed weekly rewards
        $this->seedWeeklyRewards($streamId);

        $this->command->info('BAC Study Schedule seeded successfully!');
        $this->command->info('- ' . count($days) . ' study days created');
    }

    /**
     * Get all study days data
     */
    private function getStudyDays(): array
    {
        return array_merge(
            $this->getBatch1Days(), // Days 1-14
            $this->getBatch2Days(), // Days 15-28
            $this->getBatch3Days(), // Days 29-42
            $this->getBatch4Days(), // Days 43-56
            $this->getBatch5Days(), // Days 57-70
            $this->getBatch6Days(), // Days 71-84
            $this->getBatch7Days(), // Days 85-98
        );
    }

    /**
     * Batch 1: Days 1-15
     */
    private function getBatch1Days(): array
    {
        return [
            // Day 01
            [
                'day_number' => 1,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'الاستنساخ (شروطه، مراحله)', 'task_type' => 'study'],
                            ['topic_ar' => 'تنشيط الأحماض الأمينية', 'task_type' => 'study'],
                            ['topic_ar' => 'الريبوزوم (دوره و بنيته)', 'task_type' => 'study'],
                            ['topic_ar' => 'الترجمة (شروطها، مراحلها)', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'Les caractéristiques d\'un texte d\'Histoire', 'task_type' => 'study'],
                            ['topic_ar' => 'L\'ordre chronologique', 'task_type' => 'study'],
                            ['topic_ar' => 'La subjectivité / l\'objectivité', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'حفظ دروس بروز الصراع وتشكل العالم', 'task_type' => 'memorize'],
                            ['topic_ar' => 'حفظ المصطلحات + دراسة الشخصيات الأمريكية', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
            // Day 02 - Not visible in images, placeholder
            [
                'day_number' => 2,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => []
            ],
            // Day 03 - Not visible in images, placeholder
            [
                'day_number' => 3,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => []
            ],
            // Day 04 - مراجعة (قراءة فقط)
            [
                'day_number' => 4,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'مراجعة العلوم الطبيعية', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'Les valeurs des deux points', 'task_type' => 'study'],
                            ['topic_ar' => 'Les visées communicatives', 'task_type' => 'study'],
                            ['topic_ar' => 'Le type de l\'auteur', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار دروس الصراع وتشكل العالم + دراسة الشخصيات الأمريكية', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ تواريخ 1945 - الوحدة 1', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
            // Day 05 - مراجعة (قراءة فقط)
            [
                'day_number' => 5,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'رسم البيان + المماس', 'task_type' => 'study'],
                            ['topic_ar' => 'حل تمرين شامل حول الدوال العددية', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-english',
                        'topics' => [
                            ['topic_ar' => 'درس اللغة الانجليزية Tenses', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'درس العقيدة الإسلامية', 'task_type' => 'study'],
                            ['topic_ar' => 'درس وسائل القرآن الكريم', 'task_type' => 'study'],
                            ['topic_ar' => 'حفظ درس العقل في القرآن الكريم', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
            // Day 06 - مراجعة (قراءة فقط)
            [
                'day_number' => 6,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'فهم دروس الفيزياء', 'task_type' => 'study'],
                            ['topic_ar' => 'حل 3 تمارين بكالوريا 2012 رياضي', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل تمرين بكالوريا 2014 علمي', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل بكالوريا 2020 علمي', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-philosophy',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع فلسفة', 'task_type' => 'solve'],
                        ]
                    ],
                ]
            ],
            // Day 07
            [
                'day_number' => 7,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'مراجعة نص علمي: تخمين حول تركيب البروتين', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة نص علمي حول تركيب البروتين', 'task_type' => 'exercise'],
                            ['topic_ar' => 'حل 3 تمارين حول تركيب البروتين', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'الدالة الأسية: حساب المشتقة الثانية', 'task_type' => 'study'],
                            ['topic_ar' => 'المشتقة و التغيرات + جدول التغيرات', 'task_type' => 'study'],
                            ['topic_ar' => 'النهايات + تشكيل و تحليل', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار بروز الصراع + تشكيل العالم', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس مساعي الانفراج الدولي', 'task_type' => 'memorize'],
                            ['topic_ar' => 'تكرار درس درس الشخصيات الأمريكية', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس وسائل القرآن الكريم', 'task_type' => 'review'],
                            ['topic_ar' => 'درس الإسلام والرسالات السماوية', 'task_type' => 'study'],
                            ['topic_ar' => 'حفظ درس الإسلام والرسالات السماوية', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
            // Day 08
            [
                'day_number' => 8,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'تابع: الإنزيم (دوره، أنواعه، ومراحله)', 'task_type' => 'study'],
                            ['topic_ar' => 'التفاعل الإنزيمي وعلاقته', 'task_type' => 'study'],
                            ['topic_ar' => 'حركية الإنزيم', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'La question de synthèse / de réflexion', 'task_type' => 'study'],
                            ['topic_ar' => 'Le champ lexical', 'task_type' => 'study'],
                            ['topic_ar' => 'La nominalisation', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار تواريخ مساعي الانفراج 1945 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس شخصيات من العالم الثالث - الوحدة 1', 'task_type' => 'memorize'],
                            ['topic_ar' => 'حفظ تواريخ العالم 1947 - الوحدة 1', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
            // Day 09 - مراجعة (قراءة فقط)
            [
                'day_number' => 9,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل 2 تمارين حول الدوال الأسية', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-english',
                        'topics' => [
                            ['topic_ar' => 'فهم وكتابة ملخص', 'task_type' => 'study'],
                            ['topic_ar' => 'child labour (causes, consequences, solutions)', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الإسلام والرسالات السماوية', 'task_type' => 'review'],
                            ['topic_ar' => 'درس العمل والإنتاج في الإسلام', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],
            // Day 10 - مراجعة (قراءة فقط)
            [
                'day_number' => 10,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'فهم درس البروتوكول + التعاقب', 'task_type' => 'study'],
                            ['topic_ar' => 'قياس التوجيه + حل 2 تمارين بكالوريا 2014، باك 2020 رياضي', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-arabic',
                        'topics' => [
                            ['topic_ar' => 'حل تمارين بكالوريا 2015 رياضي', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-philosophy',
                        'topics' => [
                            ['topic_ar' => 'مراجعة درس الشعور واللاشعور', 'task_type' => 'review'],
                            ['topic_ar' => 'فهم وتحليل: الشعور و اللاشعور', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط لمقالة فلسفية', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],
            // Day 11 - مراجعة (قراءة فقط)
            [
                'day_number' => 11,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'الوظائف المثبطة على النشاط الإنزيمي', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة نص علمي + حل تمرين حول تركيب البروتين', 'task_type' => 'exercise'],
                            ['topic_ar' => 'مراجعة + حل تمرين', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'Les procédés explicatifs', 'task_type' => 'study'],
                            ['topic_ar' => 'Les substituts lexicaux et grammaticaux', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس مساعي الانفراج الدولي', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس المصالحات والتفاوض في الوحدة 1', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 12 - مراجعة (قراءة فقط)
            [
                'day_number' => 12,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'المتتالية + المشتقة', 'task_type' => 'study'],
                            ['topic_ar' => 'حساب النهايات + جدول تغيرات + حل تمارين', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-english',
                        'topics' => [
                            ['topic_ar' => 'Expressing wish', 'task_type' => 'study'],
                            ['topic_ar' => 'Prefix / Root / Suffix', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار تشريع القرآن الكريم', 'task_type' => 'review'],
                            ['topic_ar' => 'درس الإسلام والرسالات السماوية', 'task_type' => 'study'],
                            ['topic_ar' => 'تكرار درس الإسلام وأسس مقاصد الشريعة الإسلامية', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 13 - مراجعة (قراءة فقط)
            [
                'day_number' => 13,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'فهم المتابعة الزمنية بكالوريا 2015 رياضي', 'task_type' => 'study'],
                            ['topic_ar' => 'حل 2 تمارين بكالوريا 2014 + حل تمرين حول التفاعل', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-arabic',
                        'topics' => [
                            ['topic_ar' => 'حل تمرين اللغة العربية', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-philosophy',
                        'topics' => [
                            ['topic_ar' => 'فهم مقالة فلسفية حول الشعور', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة فلسفية مع الطريقة الجدلية', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],
            // Day 14
            [
                'day_number' => 14,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة حول تركيب البروتين', 'task_type' => 'review'],
                            ['topic_ar' => 'حل 3 تمارين حول تركيب البروتين', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'حل تمرين بكالوريا 2013 رياضي', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل تمرين بكالوريا 2010 ع.ت + حل باك 2011 ع.ت', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس العمل والإنتاج في الإسلام', 'task_type' => 'review'],
                            ['topic_ar' => 'درس الربا وأحكامه ورأسها على السماوية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس مساعي الانفراج + انهيارات', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار الوحدة 1 كاملة', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 15
            [
                'day_number' => 15,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'خطوط الدفاع: البنية CMH', 'task_type' => 'study'],
                            ['topic_ar' => 'الذات: بنية CMH و مستضد', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'Le renvoi des pronoms', 'task_type' => 'study'],
                            ['topic_ar' => 'Les rapports logiques', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار تواريخ 1945 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس شخصيات من العالم الثالث - الوحدة 1', 'task_type' => 'memorize'],
                            ['topic_ar' => 'حفظ تواريخ العالم 1947 - الوحدة 1', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
        ];
    }

    /**
     * Batch 2: Days 16-28
     */
    private function getBatch2Days(): array
    {
        return [
            // Day 16 - قراءة فقط
            [
                'day_number' => 16,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'الرياضيات: المتتاليات ومراجعة الدوال اللوغاريتمية', 'task_type' => 'review'],
                            ['topic_ar' => 'حل 2 تمارين حول الدوال اللوغاريتمية', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-english',
                        'topics' => [
                            ['topic_ar' => 'Tenses مراجعة', 'task_type' => 'review'],
                            ['topic_ar' => 'Direct & Indirect speech', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الإصلاح في الإسلام', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس منهج الإسلام في محاربة الآفات الاجتماعية', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
            // Day 17 - قراءة فقط
            [
                'day_number' => 17,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة المتابعة الزمنية', 'task_type' => 'review'],
                            ['topic_ar' => 'المتابعة الزمنية: الحجمية والمواصلة المواصفاتية', 'task_type' => 'study'],
                            ['topic_ar' => 'المتابعة الزمنية + تحديد خصائص التغيرات', 'task_type' => 'study'],
                            ['topic_ar' => 'المتابعة الزمنية: قوانين، قوانين + رسم كل كبير حركة التحولات', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'اللغة الفرنسية + أدب وفلسفة والرياضيات', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول المقارنة بين المقاربة والرياضيات', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],
            // Day 18 - قراءة فقط
            [
                'day_number' => 18,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'العلوم: ABO و RH وخصائصها', 'task_type' => 'study'],
                            ['topic_ar' => 'مراجعة خصائص توافقية', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'Le compte rendu', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس من تبلور إلى الثورة الجزائرية - الوحدة 2', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس شخصيات من العالم - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ تواريخ 1945 - 1947 - الوحدة الاقتصادية الثانية', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
            // Day 19 - قراءة فقط
            [
                'day_number' => 19,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'المتتاليات: تعريفها + عبارة الحد العام + العلاقة بين حدين + الوسيط الحسابي', 'task_type' => 'study'],
                            ['topic_ar' => 'طبيعة المتتالية + المتتالية + المتتالية متقاربة', 'task_type' => 'study'],
                            ['topic_ar' => 'عقلانية متقاربة + نهاية متتالية + اتجاه تغير + حدود متتالية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-english',
                        'topics' => [
                            ['topic_ar' => 'تعلم كيفية كتابة فقرة تأطيرها', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم جدول زمن: verb / noun', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الإصلاح في الإسلام', 'task_type' => 'review'],
                            ['topic_ar' => 'درس مراجعة الشريعة الإسلامية والأحكام', 'task_type' => 'study'],
                            ['topic_ar' => 'حفظ درس المساواة أمام أحكام الشريعة الإسلامية', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
            // Day 20 - قراءة فقط (باك 2015 ع.ت)
            [
                'day_number' => 20,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة تمرين و الكلاسيك', 'task_type' => 'review'],
                            ['topic_ar' => 'حركة كوكب و كواكب + حركة كوكب قمر صناعي حول كوكب حركية', 'task_type' => 'study'],
                            ['topic_ar' => 'مراجعة حركة كلفون + مرونة خطيين + مرونية أفقية', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-arabic',
                        'topics' => [
                            ['topic_ar' => 'اللغة العربية: حل تمرين', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة فقرة مقالة حول الشعور واللاشعور + بنيتها أيضا', 'task_type' => 'exercise'],
                            ['topic_ar' => 'مقالة مخطط حول الشعور واللاشعور + المقاربات اليوم', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],
            // Day 21 - نسبة التقدم 21%
            [
                'day_number' => 21,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'العلوم + مخطط حول تركيب الأجسام', 'task_type' => 'study'],
                            ['topic_ar' => 'فص عضوين حول الأجسام', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل تمرين حول الدوال + حل تمرين', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الإسلام والرسالات السماوية في أحكام وشريعة القرآن الكريم', 'task_type' => 'review'],
                            ['topic_ar' => 'مراجعة أدلة وجوب العمل الصناعي وإتقان أمام القضية المعنوية في القرآن الكريم', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار: من الثانية إلى الثالثة، الاقتصادية، القضية، اليومية أي شيء + شخصيات الوحدة الثانية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس من مصادر مشيخة الأزهرية إلى الثورة التحريرية الوحدة 2', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 22
            [
                'day_number' => 22,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'اللاذات: الجسم المضاد (طبيعته، دوره، مصدره، جينيته)', 'task_type' => 'study'],
                            ['topic_ar' => 'المعقد المناعي وآلية التخلص منه', 'task_type' => 'study'],
                            ['topic_ar' => 'حل 2 تمارين مناعة - الذات واللاذات', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا', 'task_type' => 'solve'],
                            ['topic_ar' => 'BAC 2021 lettres et philosophie sujet 01', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس مساعي الانفراج الدولي', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس من تبلور الوعي إلى الثورة الجزائرية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار الشخصيات الأمريكية', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس ظاهرة التكتل وأثرها في قوة الاتحاد الأوروبي', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
            // Day 23
            [
                'day_number' => 23,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'خواص المتتالية الحسابية / الهندسية', 'task_type' => 'study'],
                            ['topic_ar' => 'تعريفها + عبارة الحد العام + العلاقة بين حدين + الوسيط الحسابي', 'task_type' => 'study'],
                            ['topic_ar' => '+ اتجاه تغير + حدود متتالية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-english',
                        'topics' => [
                            ['topic_ar' => 'Asking questions', 'task_type' => 'study'],
                            ['topic_ar' => 'Final « ed » Final « s »', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس مقاصد الشريعة الإسلامية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الصحة النفسية والجسمية في القرآن الكريم', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس الإجماع - القياس - المصالح المرسلة', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
            // Day 24
            [
                'day_number' => 24,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'حل 2 تمارين في السقوط الشاقولي (باك 2018 رياضي، باك 2015 رياضي)', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل تمرين في السقوط الحر (باك 2022 ع.ت)', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل تمرين شامل لكل من السقوط الشاقولي و الحر (باك 2013 ع.ت)', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-arabic',
                        'topics' => [
                            ['topic_ar' => 'موضوع بكالوريا 2019 للشعب العلمية - إيليا أبو ماضي', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول المقارنة بين العلم والفلسفة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط لمقالة مقارنة بين الرياضيات الكلاسيكية و الرياضيات المعاصرة', 'task_type' => 'exercise'],
                            ['topic_ar' => 'كتابة مقالة حول اليقين الرياضي', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],
            // Day 25 - قراءة فقط
            [
                'day_number' => 25,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'العلوم الطبيعية: الاستجابة المناعية الخلطية LB', 'task_type' => 'study'],
                            ['topic_ar' => 'مراحل الاستجابة المناعية الخلطية LB + LB المنشطة للذاكرة', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'مراجعة موضوع جميع الكلوريا للدروس التي تم دراستها', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس ظاهرة التكتل في العالم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس من تبلور إلى الثورة الجزائرية والاستقلال اقتصاديات الأوروبية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار شخصيات الوحدة الجزائرية', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس مصادر من تبلور الوعي الوطني إلى الثورة التحريرية', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
            // Day 26 - قراءة فقط
            [
                'day_number' => 26,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل 3 تمارين شاملة حول المتتاليات', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-english',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع فقرة الانجليزية', 'task_type' => 'solve'],
                            ['topic_ar' => 'Ethics in Business', 'task_type' => 'study'],
                            ['topic_ar' => 'How to fight corruption?', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس وسائل القرآن الكريم', 'task_type' => 'review'],
                            ['topic_ar' => 'درس الصحة النفسية والجسمية في القرآن الكريم', 'task_type' => 'study'],
                            ['topic_ar' => 'تكرار درس العقيدة الإسلامية', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة تشريع القرآن الكريم في الشريعة الإسلامية في أحكام والإيمان والقيم', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],
            // Day 27 - قراءة فقط
            [
                'day_number' => 27,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة حركة دالة الطاقة و حفظها وما تناقص', 'task_type' => 'review'],
                            ['topic_ar' => 'مراجعة التيني على مبدأ حفظها+ حركة نواس مخمد، ليونة على حركية', 'task_type' => 'review'],
                            ['topic_ar' => 'تقرير القوى: أنواعها (باك 2013 ع.ت)', 'task_type' => 'study'],
                            ['topic_ar' => 'تمرين نص قضي: باك 2012 رياضي', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-arabic',
                        'topics' => [
                            ['topic_ar' => 'اللغة العربية: أسلوب المفعول واللمفعول + تمرين', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم موضوع الموضوعيون والرومانسيين اليهود - أبا ماهر', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-philosophy',
                        'topics' => [
                            ['topic_ar' => 'مقالة مقارنة بين المادة الكلاسيكية', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],
            // Day 28 - نسبة التقدم 28%
            [
                'day_number' => 28,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'الاستجابة المناعية الخلوية LT', 'task_type' => 'study'],
                            ['topic_ar' => 'مراحل الاستجابة الخلوية LT باختلافها', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'حل تمرين شامل + حل تمرين حركة وحركة، جولات وباك', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل تمرين: باك 2017 ع.ت + دورة 2011 رياضي', 'task_type' => 'solve'],
                            ['topic_ar' => 'أقص و أقص من: حل باك 2014 رياضي', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الإسلام والرسالات السماوية والصحة المعنوية والجسمية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الإجماع القياس - المصالح المرسلة', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار إشكالية التنمية الذكية ال إلى وتأثيرها على الأفريقية', 'task_type' => 'review'],
                            ['topic_ar' => 'تشكل كلاشينات العالم 1991 - 1947', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار ظاهرة التكتل العالم الأوروبي وأثرها في قوة الاتحاد الأوروبي الوحدة 3', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
        ];
    }

    /**
     * Batch 3: Days 29-42
     */
    private function getBatch3Days(): array
    {
        return [
            // Day 29
            [
                'day_number' => 29,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'آلية عمل LT + خصائص الأجسام', 'task_type' => 'study'],
                            ['topic_ar' => 'حل 2 تمارين تدريب حول حول الأجسام', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'les temps de la conjugaison', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس من الثانية إلى الوحدة 2', 'task_type' => 'review'],
                            ['topic_ar' => 'تواريخ: تواريخ من 1947 - 1956 - الوحدة 2', 'task_type' => 'memorize'],
                            ['topic_ar' => 'حفظ تواريخ: 1947 - 1956 المسلح الجزائري', 'task_type' => 'memorize'],
                            ['topic_ar' => 'حفظ الشخصيات الجزائرية', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
            // Day 30 - قراءة فقط
            [
                'day_number' => 30,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'الدوال الكاملة: التكامل + التكامل باستعمال التكامل', 'task_type' => 'study'],
                            ['topic_ar' => 'المعادلات: مساحة، مساحة، حساب التكامل', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم التكامل + التدرب حساب المتوسط + حساب الدوال الأصلية وحساب التكامل', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-english',
                        'topics' => [
                            ['topic_ar' => 'Safety first & advertising', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم وحدة الأنترنت والرسالة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة الأفكار و تنظيم الأجوبة الكتابية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس منهج الإسلام في محاربة الآفات الاجتماعية - اليوم', 'task_type' => 'review'],
                            ['topic_ar' => 'درس الإجماع - القياس - المصالح المرسلة', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],
            // Day 31 - قراءة فقط
            [
                'day_number' => 31,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'فهم دراسة حركة بنية قوة ثابتة الربيعية', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم و طرق بناء المعادلات التفاضلية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-arabic',
                        'topics' => [
                            ['topic_ar' => 'الالتزام موضوع بكالوريا 2009 للشعب العلمية', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول أصل لحظة الفلسفية', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة مخطط حول الفلسفة', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],
            // Day 32 - قراءة فقط
            [
                'day_number' => 32,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة للمناعة', 'task_type' => 'review'],
                            ['topic_ar' => 'حل 2 تمارين مناعة تركيب', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'Discours direct et indirect', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس العمل المسلح ودور دول 1956 - 1958 والشخصيات 2', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار المصالحة الجزائرية بين الجزائريين والوطنية 1', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ تواريخ 1949 - الوحدة 1', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
            // Day 33 - قراءة فقط
            [
                'day_number' => 33,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'الأعداد والحساب: القسمة في Z / التكامل', 'task_type' => 'study'],
                            ['topic_ar' => 'القسمة الأقليدية + الدوال الأصلية وحساب التكامل', 'task_type' => 'study'],
                            ['topic_ar' => 'حل تمرينين في المتتاليات', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-english',
                        'topics' => [
                            ['topic_ar' => 'Conditional type 1 & 2', 'task_type' => 'study'],
                            ['topic_ar' => 'Provided that / as long as ... / Unless', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس العقل في القرآن الكريم', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس القيم في القرآن الكريم', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
            // Day 34 - قراءة فقط
            [
                'day_number' => 34,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'الفيزياء: قذيفة وقذيفة حركة دائرية حول مرجعي باك', 'task_type' => 'study'],
                            ['topic_ar' => 'تمرين حولهم باك: حركة + باك السقطة 2018 ع.ت', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل باك 2010، 01، 02، 03 حركة: باك 2016 ع.ت', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-arabic',
                        'topics' => [
                            ['topic_ar' => 'اللغة العربية: أسس بن هشام للمشكلة', 'task_type' => 'study'],
                            ['topic_ar' => 'موضوع: بكالوريا 2011 للعب العلمية', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مخطط مقالة حول المشكلة', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],
            // Day 35 - نسبة التقدم 35%
            [
                'day_number' => 35,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'دور البنيات: الجهاز المحيط', 'task_type' => 'study'],
                            ['topic_ar' => 'آلية تحقيق + مخطط عصبي', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'الرياضيات: شامل أفقي وأعداد', 'task_type' => 'study'],
                            ['topic_ar' => 'حل تمرينين حول المتتاليات', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس القيم في القرآن الكريم', 'task_type' => 'review'],
                            ['topic_ar' => 'درس الوقف في الإسلام', 'task_type' => 'study'],
                            ['topic_ar' => 'حفظ درس مدخل إلى علم الاقتصاد', 'task_type' => 'memorize'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس العلاقة بين المستعمر في شرق و جنوب شرق آسيا', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الاقتصادية في شرق الدولة الجزائرية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس السياسة والاقتصادية ويناء الدولة - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ تواريخ 1949 - 1956 - 1958 - الوحدة 2', 'task_type' => 'memorize'],
                            ['topic_ar' => 'تكرار تواريخ 1956 - 1958', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 36 - قراءة فقط
            [
                'day_number' => 36,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'العلوم: حل تمرين', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة الاستجابة المناعية الخلوية الخلطية', 'task_type' => 'review'],
                            ['topic_ar' => 'مراجعة التعاون بين الخلايا الأجسامية', 'task_type' => 'review'],
                            ['topic_ar' => 'حل 2 تمارين حول الأجسام', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'La voix active et passive', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس من ميلاد استعادة الاستقلال 1945 - 1949 الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار الثورة الجزائرية الثورية الوطنية ويناء العالم', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ تواريخ 1949 - الوحدة 1', 'task_type' => 'memorize'],
                            ['topic_ar' => 'تكرار تواريخ', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 37 - قراءة فقط
            [
                'day_number' => 37,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'الاحتمالات: مجموع الاحتمالات + الاحتمال الشرطي', 'task_type' => 'study'],
                            ['topic_ar' => 'الاحتمال الكلي + مراجعة ومتابعة وتحضير التمارين قبل ثاني', 'task_type' => 'study'],
                            ['topic_ar' => 'القيمة المتوقعة + الانحراف المعياري + مصفوفة الاحتمالات الكثيرة', 'task_type' => 'study'],
                            ['topic_ar' => 'و الإجابة المعيارية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-english',
                        'topics' => [
                            ['topic_ar' => 'Expressing cause & result', 'task_type' => 'study'],
                            ['topic_ar' => 'Passive & active voice', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس وسائل القرآن الكريم + الإجماع - القرآن - المصالح المرسلة', 'task_type' => 'review'],
                            ['topic_ar' => 'درس الربا وأحكامه - الوقف في الإسلام', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],
            // Day 38 - قراءة فقط
            [
                'day_number' => 38,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة المعادلات التفاضلية باك 2016 رياضي', 'task_type' => 'review'],
                            ['topic_ar' => 'المعادلات RC (استقبالها)', 'task_type' => 'study'],
                            ['topic_ar' => 'باك 2013 ع.ت رياضي: باك + شهادة مختلفة', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل 02 تمارين جول رياضي + شريح مختلفة', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-arabic',
                        'topics' => [
                            ['topic_ar' => 'اللغة العربية: باك التجريبية', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل تمارين جول شريج مختلفة', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-philosophy',
                        'topics' => [
                            ['topic_ar' => 'الفلسفة: لائحة الشريعة واستقرار التجريبية', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول الاستقراء التجريبية', 'task_type' => 'exercise'],
                            ['topic_ar' => 'قراءة مقالة حول الاستقراء', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],
            // Day 39 - قراءة فقط
            [
                'day_number' => 39,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'العلوم: قصد المناعة SIDA واللاذات', 'task_type' => 'study'],
                            ['topic_ar' => 'مرض فقدان المناعة + مخطط حول تركيب الأجسام', 'task_type' => 'study'],
                            ['topic_ar' => 'فص عضوين + حل تمرين حول البروتين', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا', 'task_type' => 'solve'],
                            ['topic_ar' => 'BAC 2020 scientifique sujet 01', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس العلاقة بين المستعمر، الاقتصاد، الاستثمار', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس السياسة المسلحة الجزائرية - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1947 - الشخصيات، الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ الشخصيات الجزائرية - الوحدة 1', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
            // Day 40 - قراءة فقط
            [
                'day_number' => 40,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل 3 تمرين حول الدوال الأصلية وحساب التكامل', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-english',
                        'topics' => [
                            ['topic_ar' => 'Similarities & differences', 'task_type' => 'study'],
                            ['topic_ar' => 'Concession', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس أحكام الشريعة الإسلامية', 'task_type' => 'review'],
                            ['topic_ar' => 'درس المساواة أمام أحكام القرآن الكريم الإسلام', 'task_type' => 'study'],
                            ['topic_ar' => 'تكرار درس الوقف في الإسلام', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس القيم في القرآن الإسلام', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 41 - قراءة فقط
            [
                'day_number' => 41,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'الفيزياء: مراجعة تمرين RL', 'task_type' => 'review'],
                            ['topic_ar' => 'مراجعة تمرين كل جوانب RL والفيزي و القطبي (باك 2015 رياضي)', 'task_type' => 'review'],
                            ['topic_ar' => 'RL حلقة باك 2012 رياضي قطعي 1 و 2', 'task_type' => 'solve'],
                            ['topic_ar' => 'الفيزي و القطبي (دورة المستوى المعدني) باك 2017 رياضي', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-arabic',
                        'topics' => [
                            ['topic_ar' => 'اللغة العربية: أدب', 'task_type' => 'study'],
                            ['topic_ar' => 'موضوع بكالوريا 2015 للشعب العلمية', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مخطط مقالة حول المشكلة', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],
            // Day 42 - نسبة التقدم 42%
            [
                'day_number' => 42,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'العلوم الطبيعية: VIH فيروس المناعة', 'task_type' => 'study'],
                            ['topic_ar' => 'VIH حصة الإصابة تمارين حول المناعة', 'task_type' => 'study'],
                            ['topic_ar' => 'حل 3 تمارين حركة المناعة', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'الفيزياء: مراجعة تمارين حفظ و التموجات حمض', 'task_type' => 'review'],
                            ['topic_ar' => 'الأقصى المقلوب: الحساب و التفاعل x, max, 4, 14 ثابت الاتزان Q', 'task_type' => 'study'],
                            ['topic_ar' => 'مراجعة تخامل أشكال كل فهم الكيمياء كلاسيكية و التوازن الكيميائي', 'task_type' => 'review'],
                            ['topic_ar' => 'مراجعة و توازن PH', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس العقيدة الإسلامية، الوقف في الإسلام', 'task_type' => 'review'],
                            ['topic_ar' => 'درس الربا وأحكامه + درس مدخل إلى علم الاقتصاد', 'task_type' => 'study'],
                            ['topic_ar' => 'حفظ درس الاجتهاد في الإسلام', 'task_type' => 'memorize'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس خامة الثورة وأثرها على الاتحاد و الاستعمار', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار الاقتصاديات في فعل الوطنية والتشييد', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الثورة والتكتل المسلح + استعادة الدولة الوطنية', 'task_type' => 'review'],
                            ['topic_ar' => 'درس مصادر الثورة المسلح استعادة الوطنية ويناء الدولة الجزائرية', 'task_type' => 'study'],
                            ['topic_ar' => 'حفظ الشخصيات الجزائرية', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
        ];
    }

    /**
     * Batch 4: Days 43-56
     */
    private function getBatch4Days(): array
    {
        return [
            // Day 43 - خاص ع.ت
            [
                'day_number' => 43,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'العلوم الطبيعية: الجهاز العصبي', 'task_type' => 'study'],
                            ['topic_ar' => 'المخ: تخطيطه وحماره ومصدر', 'task_type' => 'study'],
                            ['topic_ar' => 'البصر: كيون الرؤية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا', 'task_type' => 'solve'],
                            ['topic_ar' => 'BAC 2021 langues sujet 01', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار بروز الاقتصاد، وتشكل العالم الجزائرية', 'task_type' => 'review'],
                            ['topic_ar' => 'درس الشخصيات: الأثر الجزائري و رسالتها في والمتوسط 1956', 'task_type' => 'study'],
                            ['topic_ar' => 'تكرار درس أثر الجزائر 1950 - 1956', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ تواريخ', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
            // Day 44 - Not visible, placeholder
            [
                'day_number' => 44,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => []
            ],
            // Day 45 - قراءة فقط
            [
                'day_number' => 45,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'حل 02 تمارين حول حمض في الماء (باك 2016 رياضي)', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل تمرين حول المحلول أساسي: باك 2015 ع.ت', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل تمرين حول تفاعل حمض أساسي: باك 2010 رياضي', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل تمرين حول تفاعل حمض أساسي (باك 2015 رياضي)', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-arabic',
                        'topics' => [
                            ['topic_ar' => 'اللغة العربية: أسلوب المصدر و الشرط والعالم', 'task_type' => 'study'],
                            ['topic_ar' => 'الأدب الجزائرية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مخطط مقالة حول البيولوجية والجسمية', 'task_type' => 'exercise'],
                            ['topic_ar' => 'كتابة مقالة حول البيولوجية', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],
            // Day 46 - قراءة فقط (خاص ع.ت)
            [
                'day_number' => 46,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'العلوم الطبيعية: تصحيح العمل ومصدره', 'task_type' => 'study'],
                            ['topic_ar' => 'آلية عمون الهضم والحركات البشرية', 'task_type' => 'study'],
                            ['topic_ar' => 'كيفون الهضم: آلية المنظمة والرؤية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'BAC 2018 langues sujet 01', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس أثر الجزائر، في البحر الأبيض المتوسط', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الشخصيات الجزائرية 1949 - 1950', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ - 1956', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 47 - قراءة فقط
            [
                'day_number' => 47,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'الأعداد المركبة: المعادلة + الشكل الأسي والجبري والمثلثي', 'task_type' => 'study'],
                            ['topic_ar' => '+ الدوران و الأسي + و التشابه + طريقة المعادلة (... الخ)', 'task_type' => 'study'],
                            ['topic_ar' => '+ التحويلات النقطية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-english',
                        'topics' => [
                            ['topic_ar' => 'Astronomy فهم وتلخيص', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'كتابة الأفكار و تلخيص', 'task_type' => 'study'],
                            ['topic_ar' => 'تكرار مدخل إلى الدولة والدولة ووطرق ميراثهم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار علم ميراثهم', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 48 - Not visible, placeholder
            [
                'day_number' => 48,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => []
            ],
            // Day 49 - خاص ع.ت - نسبة التقدم 50%
            [
                'day_number' => 49,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'العلوم الطبيعية: الدماغ العصبي', 'task_type' => 'study'],
                            ['topic_ar' => 'الإدماج: مساحة العصبي وآلية الأحساس و الاتصال المركب', 'task_type' => 'study'],
                            ['topic_ar' => 'المشبك + 2 تمارين في المشبك', 'task_type' => 'study'],
                            ['topic_ar' => 'حل 2 تمارين حول الأعداد المركبة', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'الرياضيات: تمارين حول الأعداد المركبة', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل 2 تمارين حول الأعداد المركبة', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'التربية الإسلامية: درس الصحة النفسية إلى علم الميراثهم', 'task_type' => 'study'],
                            ['topic_ar' => 'تكرار درس مدخل الدولة وطرق ميراثهم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس درس الدولة الوطنية ووطرق ميراثهم', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار حركات التحرر', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار والمستعمرة والتقليدي والمتوسط', 'task_type' => 'review'],
                            ['topic_ar' => 'درس تأثير الجزائر الثالث في حوض البحر - الأبيض + التنمية في الوحدة 1', 'task_type' => 'study'],
                            ['topic_ar' => 'تكرار درس الجزائر 1945 - 1961 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس السكان والتنمية في البرازيل', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ تواريخ 1961 - 1963 - الوحدة 1', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
            // Day 50 - خاص ع.ت
            [
                'day_number' => 50,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'العلوم الطبيعية: خاصيتها، شروطها، مقرها، شروطها', 'task_type' => 'study'],
                            ['topic_ar' => 'المشابك: التغيرات حول المناعة', 'task_type' => 'study'],
                            ['topic_ar' => 'التركيب + 3 تمارين حول المناعة', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'La structure d\'un texte argumentatif', 'task_type' => 'study'],
                            ['topic_ar' => 'Le champ lexical de l\'argumentation', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الدولي الانفراج بين آسيا', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار مساعي درس درس جنوب شرق آسيا', 'task_type' => 'review'],
                            ['topic_ar' => 'شرق و جنوب وتواريخ 1950 - 1956 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ بين الثالث والاستعمار', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس العالم والاستعمار حركات التحرر', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 51 - Not visible, placeholder
            [
                'day_number' => 51,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => []
            ],
            // Day 52 - قراءة فقط
            [
                'day_number' => 52,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'الفيزياء: و التباطؤ', 'task_type' => 'study'],
                            ['topic_ar' => 'مراجعة و تفاعلي: أنواع، ثابت الإدماج', 'task_type' => 'review'],
                            ['topic_ar' => 'قانون التباطؤ بالكرون', 'task_type' => 'study'],
                            ['topic_ar' => 'الاندماج: تاريخ و الإندماج', 'task_type' => 'study'],
                            ['topic_ar' => 'مراجعة بالكرون: الاشعاعي، تاريخ و طاقة الربط الأولية', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-arabic',
                        'topics' => [
                            ['topic_ar' => 'اللغة العربية: الأدب الاجتماعي', 'task_type' => 'study'],
                            ['topic_ar' => 'أشعار الإيمان و عظة البيان', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول المشكلة والاستقراء', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول حول البيولوجية', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],
            // Day 53 - قراءة فقط (خاص ع.ت)
            [
                'day_number' => 53,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'العلوم الطبيعية: تشريعها، مقرها، شروطها، العصبي', 'task_type' => 'study'],
                            ['topic_ar' => 'المراجعة + مراجعة كرسي في الميراثهم', 'task_type' => 'review'],
                            ['topic_ar' => 'حل 2 تمارين', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'La visée communicative', 'task_type' => 'study'],
                            ['topic_ar' => 'Le lexique de l\'argumentation', 'task_type' => 'study'],
                            ['topic_ar' => 'Les articulateurs', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'درس المشكلات و تطلعات في العالم', 'task_type' => 'study'],
                            ['topic_ar' => 'تكرار درس المشكلة الفلسطينية: جوهر البحر الأبيض المتوسط', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الجزائر في العالم الثالث - حركات 1991 - 1972', 'task_type' => 'review'],
                            ['topic_ar' => 'والمستعمرة وتأثير حركات - الوحدة 1', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 54 - قراءة فقط
            [
                'day_number' => 54,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'الرياضيات: معادلات + الجداء السلمي', 'task_type' => 'study'],
                            ['topic_ar' => 'الهندسة في الفضاء', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-english',
                        'topics' => [
                            ['topic_ar' => 'The importance of ethics in Business', 'task_type' => 'study'],
                            ['topic_ar' => 'Ethics in Business الموضوع حول', 'task_type' => 'study'],
                            ['topic_ar' => 'حل مقترح قصة حول', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس القيم في القرآن الكريم', 'task_type' => 'review'],
                            ['topic_ar' => 'درس الربا وأحكامه', 'task_type' => 'study'],
                            ['topic_ar' => 'حفظ درس الربا وأحكامه', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
            // Day 55 - Not visible, placeholder
            [
                'day_number' => 55,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => []
            ],
            // Day 56 - Not visible, placeholder
            [
                'day_number' => 56,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => []
            ],
        ];
    }

    /**
     * Batch 5: Days 57-70
     */
    private function getBatch5Days(): array
    {
        return [
            // Day 57
            [
                'day_number' => 57,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'الاتصال العصبي: المشبك ودوره', 'task_type' => 'study'],
                            ['topic_ar' => 'آلية النقل المشبكي', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'Les stratégies argumentatives', 'task_type' => 'study'],
                            ['topic_ar' => 'L\'opposition et la concession', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس جذور الحركة في الجزائر والمتوسط', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس القضية الفلسطينية والصراع العربي الإسرائيلي', 'task_type' => 'memorize'],
                            ['topic_ar' => 'تكرار درس التنمية في البرازيل', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ تواريخ 1963، 1961، 1972 - الوحدة 1', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
            // Day 58 - مراجعة (قراءة فقط)
            [
                'day_number' => 58,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة + موضوع 01', 'task_type' => 'review'],
                            ['topic_ar' => 'حل بكالوريا 2023 موضوع 01', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-english',
                        'topics' => [
                            ['topic_ar' => 'Safety first & advertising', 'task_type' => 'study'],
                            ['topic_ar' => 'How to keep healthy?', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الزكاة وأحكامها', 'task_type' => 'review'],
                            ['topic_ar' => 'درس منهج الإسلام في محاربة الآفات الاجتماعية', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],
            // Day 59 - مراجعة (قراءة فقط)
            [
                'day_number' => 59,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'حل 03 تمارين باك 2013، 2014 رياضي', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة تمارين حول الأشعة', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-arabic',
                        'topics' => [
                            ['topic_ar' => 'حل 03 تمارين رياضي', 'task_type' => 'solve'],
                            ['topic_ar' => 'باك 2016 رياضي', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-philosophy',
                        'topics' => [
                            ['topic_ar' => 'بناء مقالة الكتابة + الاحتمالات على النفس', 'task_type' => 'exercise'],
                            ['topic_ar' => 'كتابة مخطط مقالة حول التاريخ', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],
            // Day 60 - مراجعة (قراءة فقط)
            [
                'day_number' => 60,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'التنفس: الأكسدة الإرجاعية ومراحلها', 'task_type' => 'study'],
                            ['topic_ar' => 'مراجعة التنفس الخلوي: غشاء الميتوكوندري', 'task_type' => 'review'],
                            ['topic_ar' => 'حل 2 تمارين حول التنفس', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'Le lexique de l\'argumentation', 'task_type' => 'study'],
                            ['topic_ar' => 'Les articulateurs', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار من التنمية الخارجية في الهند + الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس السكان والتنمية في شرق وجنوب شرق آسيا الجزائرية الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ تواريخ 1949، 1961، 1963 - الوحدة 1', 'task_type' => 'memorize'],
                            ['topic_ar' => 'تكرار تواريخ', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 61 - مراجعة (قراءة فقط)
            [
                'day_number' => 61,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2017 + موضوع 01', 'task_type' => 'solve'],
                            ['topic_ar' => 'تصحيح بكالوريا 2023 موضوع 01', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-english',
                        'topics' => [
                            ['topic_ar' => 'Expressing advice', 'task_type' => 'study'],
                            ['topic_ar' => 'It\'s high time / It\'s about time', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس العقل في القرآن الكريم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الربا وأحكامه', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس من المعاملات المالية المشروعة', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
            // Day 62 - مراجعة (قراءة فقط)
            [
                'day_number' => 62,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة تفاعل الأكسدة الإرجاعية', 'task_type' => 'review'],
                            ['topic_ar' => 'حل تمارين حول الأعمدة', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-arabic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة تفاعل حول الملخصات', 'task_type' => 'review'],
                            ['topic_ar' => 'موضوع بكالوريا 2012 للشعب العلمية - مقال', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول العلم والفلسفة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول التاريخ', 'task_type' => 'exercise'],
                            ['topic_ar' => 'قراءة مقالة حول التاريخ', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],
            // Day 63 - نسبة التقدم 63%
            [
                'day_number' => 63,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'العلاقة بين البناء الضوئي والتنفس: مراحل ومقارنة', 'task_type' => 'study'],
                            ['topic_ar' => 'التخمر: مراحله وصفاته', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2018 + موضوع 01', 'task_type' => 'solve'],
                            ['topic_ar' => 'تصحيح بكالوريا 2017', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس المساواة أمام أحكام الشريعة', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس أحكام الميراث: خالد على المعاملات المالية', 'task_type' => 'review'],
                            ['topic_ar' => 'درس من المعاملات المالية المشروعة', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس التنمية والتكتل في العالم 1945', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس شخصيات 1945 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1961، 1963 - الوحدة 1', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 64
            [
                'day_number' => 64,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'حل تمارين بكالوريا (تقاطعي) - موضوع 01', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل بكالوريا 2024 (المتأخر) - حل تمارين المناعة', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'Le compte rendu du texte argumentatif', 'task_type' => 'study'],
                            ['topic_ar' => 'La structure d\'un texte exhortatif', 'task_type' => 'study'],
                            ['topic_ar' => 'Les verbes de modalité', 'task_type' => 'study'],
                            ['topic_ar' => 'Les verbes performatifs', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الثورة الجزائرية - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس تبلور الوعي الوطني الجزائري - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ الشخصيات 1961، 1963 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ تواريخ 1943، 1947، 1956، 1958 - الوحدة 2', 'task_type' => 'memorize'],
                            ['topic_ar' => 'تكرار تواريخ - اليوم', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 65 - مراجعة (قراءة فقط)
            [
                'day_number' => 65,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2019 موضوع 01', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل بكالوريا 2018 موضوع', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-english',
                        'topics' => [
                            ['topic_ar' => 'Description of the moon', 'task_type' => 'study'],
                            ['topic_ar' => 'Astronomy', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة فقرة حول Astronomy', 'task_type' => 'exercise'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'حفظ درس حقوق الإنسان', 'task_type' => 'memorize'],
                            ['topic_ar' => 'تكرار درس الربا وأحكامه - المصالح المرسلة', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 66 - مراجعة (قراءة فقط)
            [
                'day_number' => 66,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2020 على الموقع (موضوع 01) وتصحيحه', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-arabic',
                        'topics' => [
                            ['topic_ar' => 'الشعر الحر: أدوات الاتساق والانسجام والعاطفة', 'task_type' => 'study'],
                            ['topic_ar' => 'أدوات الحجاج الحديث: أدوات وأساليب', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة درس الشعور واللاشعور والقيم', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس الشعور والتحليل مع الأخلاق', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط للمقالة أخرى اليوم', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],
            // Day 67
            [
                'day_number' => 67,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة للتحولات الطاقوية', 'task_type' => 'review'],
                            ['topic_ar' => 'حل تمارين بكالوريا حول التحولات', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا شامل', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الثورة الجزائرية والقضايا الدولية', 'task_type' => 'review'],
                            ['topic_ar' => 'مراجعة شاملة للوحدة 1 و 2', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 68 - مراجعة (قراءة فقط)
            [
                'day_number' => 68,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا شامل', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة الدوال والمتتاليات', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-english',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة للقواعد', 'task_type' => 'review'],
                            ['topic_ar' => 'حل موضوع بكالوريا', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة للدروس', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 69 - مراجعة (قراءة فقط)
            [
                'day_number' => 69,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا شامل', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة الكيمياء والفيزياء', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-arabic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة للأدب والنصوص', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-philosophy',
                        'topics' => [
                            ['topic_ar' => 'مراجعة المقالات والمخططات', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 70 - نسبة التقدم 70%
            [
                'day_number' => 70,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'مراجعة عامة: تركيب البروتين والمناعة', 'task_type' => 'review'],
                            ['topic_ar' => 'حل تمارين شاملة', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الاحتمالات والأعداد المركبة', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة لجميع الدروس', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'مراجعة عامة للوحدات', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار التواريخ والشخصيات', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
        ];
    }

    /**
     * Batch 6: Days 71-84
     */
    private function getBatch6Days(): array
    {
        return [
            // Day 71
            [
                'day_number' => 71,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'تصحيح بكالوريا 2024 - موضوع 02', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل بكالوريا 2019 - موضوع 02', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل تمارين (التناقض الملاحظة خلال حل البكالوريات)', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'Le mode impératif', 'task_type' => 'study'],
                            ['topic_ar' => 'Le rapport logique de but', 'task_type' => 'study'],
                            ['topic_ar' => 'Les valeurs de subjonctif', 'task_type' => 'study'],
                            ['topic_ar' => 'Le compte rendu', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس بروز الصراع وتشكل العالم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس السكان والتنمية في الهند + التنمية في البرازيل', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1950 - 1956 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ تواريخ 1955-1950 - الوحدة 2', 'task_type' => 'memorize'],
                            ['topic_ar' => 'تكرار تواريخ 1960 - 1961 - الوحدة 2', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 72 - مراجعة (قراءة فقط)
            [
                'day_number' => 72,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2021 - موضوع 01', 'task_type' => 'solve'],
                            ['topic_ar' => 'تصحيح بكالوريا 2020 - موضوع 01', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-english',
                        'topics' => [
                            ['topic_ar' => 'فهم وحدة Astronomy', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة الأفكار و تلخيص الوحدة و إستعمال الخرائط الذهنية', 'task_type' => 'exercise'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس مقاصد الشريعة الإسلامية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الحرية الشخصية ومدى ارتباطها بحقوق الانسان', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس النسب، التبني، الكفالة', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 73 - مراجعة (قراءة فقط)
            [
                'day_number' => 73,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2021 (موضوع 02) شعبة رياضي', 'task_type' => 'solve'],
                            ['topic_ar' => 'ثم الوقوف على الأخطاء و تصحيحها', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-arabic',
                        'topics' => [
                            ['topic_ar' => 'بلاغة المجاز المرسل والعقلي', 'task_type' => 'study'],
                            ['topic_ar' => 'الأساليب البلاغية', 'task_type' => 'study'],
                            ['topic_ar' => 'القصة والمسرحية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول الاستقراء', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول علاقة الأنا بالغير', 'task_type' => 'exercise'],
                            ['topic_ar' => 'كتابة مخطط لمقالة الحرية والحتمية', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],
            // Day 74 - مراجعة (قراءة فقط)
            [
                'day_number' => 74,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'تصحيح بكالوريا 2022 - موضوع 02', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل بكالوريا 2023 - موضوع 01', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل تمارين (التناقض الملاحظة خلال حل البكالوريات)', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا 2019 علميين الموضوع 2', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل موضوع بكالوريا 2018 لغات الموضوع 1', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس العلاقة بين السكان والتنمية في شرق و جنوب شرق آسيا', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس القضية الفلسطينية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1949 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1950-1955 - الوحدة 2', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 75 - مراجعة (قراءة فقط)
            [
                'day_number' => 75,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2021 - موضوع 02', 'task_type' => 'solve'],
                            ['topic_ar' => 'تصحيح بكالوريا 2021 - موضوع 01', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-english',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع Astronomy', 'task_type' => 'solve'],
                            ['topic_ar' => 'كتابة فقرة حول The benefits and drawbacks of space exploration', 'task_type' => 'exercise'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الربا وأحكامه', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس النسب، التبني، الكفالة', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس العلاقات الاجتماعية بين المسلمين وغيرهم', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
            // Day 76 - مراجعة (قراءة فقط)
            [
                'day_number' => 76,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2021 (موضوع 02) شعبة ع.ت', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-arabic',
                        'topics' => [
                            ['topic_ar' => 'موضوع بكالوريا 2015 للشعب العلمية', 'task_type' => 'solve'],
                            ['topic_ar' => 'البشير الإبراهيمي مقال', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول أصل المفاهيم الرياضية', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط لمقالة لمشكلة الجزاء', 'task_type' => 'exercise'],
                            ['topic_ar' => 'كتابة مقالة حول الحرية والحتمية', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],
            // Day 77 - نسبة التقدم 77%
            [
                'day_number' => 77,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'تصحيح بكالوريا 2017 - موضوع 01', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل بكالوريا 2018 - موضوع 01', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'تصحيح بكالوريا 2023 - موضوع 01', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل بكالوريا 2020 - موضوع 01', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس وسائل القرآن الكريم في تثبيت العقيدة الإسلامية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس العلاقات الاجتماعية بين المسلمين وغيرهم', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس خطبة حجة الوداع', 'task_type' => 'memorize'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار الشخصيات السوفياتية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1955-1950 - الوحدة 2', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1960 - 1961 - الوحدة 2', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس العالم الثالث بين تراجع الاستعمار التقليدي واستمرارية حركات التحرر', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 78
            [
                'day_number' => 78,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2022 - موضوع 01', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة شاملة للوحدات', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا 2020', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة شاملة للقواعد', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الثورة الجزائرية والقضايا الدولية', 'task_type' => 'review'],
                            ['topic_ar' => 'مراجعة الشخصيات والتواريخ', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 79 - مراجعة (قراءة فقط)
            [
                'day_number' => 79,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2022 - موضوع 01', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة الدوال والاحتمالات', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-english',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا شامل', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة القواعد والمفردات', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة للدروس', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس خطبة حجة الوداع', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 80 - مراجعة (قراءة فقط)
            [
                'day_number' => 80,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2022 - موضوع 01', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة شاملة للفيزياء والكيمياء', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-arabic',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا شامل', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة الأدب والبلاغة', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-philosophy',
                        'topics' => [
                            ['topic_ar' => 'مراجعة المقالات والمخططات', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة مقالة شاملة', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],
            // Day 81
            [
                'day_number' => 81,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2023 - موضوع 02', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة تركيب البروتين والمناعة', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2023 - موضوع 02', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة المتتاليات والأعداد المركبة', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة للوحدات', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار التواريخ والشخصيات', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 82 - مراجعة (قراءة فقط)
            [
                'day_number' => 82,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2023 - موضوع 01', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة الميكانيك والكهرباء', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا 2021', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة شاملة', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة لجميع الدروس', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 83 - مراجعة (قراءة فقط)
            [
                'day_number' => 83,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2024 - موضوع 01', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة شاملة', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-english',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا 2023', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة شاملة', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-arabic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة للأدب', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-philosophy',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة للمقالات', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 84 - نسبة التقدم 84%
            [
                'day_number' => 84,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'مراجعة عامة شاملة', 'task_type' => 'review'],
                            ['topic_ar' => 'حل تمارين متنوعة', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة عامة شاملة', 'task_type' => 'review'],
                            ['topic_ar' => 'حل تمارين متنوعة', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة لجميع الدروس', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'مراجعة عامة للوحدات', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار التواريخ والشخصيات', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
        ];
    }

    /**
     * Batch 7: Days 85-98
     */
    private function getBatch7Days(): array
    {
        return [
            // Day 85
            [
                'day_number' => 85,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'تصحيح بكالوريا 2022 - موضوع 01', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل بكالوريا 2021 - موضوع 01', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل تمارين (التناقض الملاحظة خلال حل البكالوريات)', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا 2019 لغات الموضوع 02', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل موضوع بكالوريا 2018 لغات الموضوع 02', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الاقتصاد الجزائري في العالم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1945 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1955-1950 - الوحدة 2', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1962 - الوحدة 2', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ تواريخ 1965 - 1989 - الوحدة 02', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
            // Day 86 - مراجعة (قراءة فقط)
            [
                'day_number' => 86,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2017 - موضوع 02', 'task_type' => 'solve'],
                            ['topic_ar' => 'تصحيح بكالوريا 2018 - موضوع 02', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-english',
                        'topics' => [
                            ['topic_ar' => 'مراجعة دروس القواعد + الإجابة على أسئلة النص', 'task_type' => 'review'],
                            ['topic_ar' => 'حل موضوع Feelings and emotions', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الإجماع - القياس - المصالح المرسلة', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الوقف في الإسلام', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الحرية الشخصية ومدى إرتباطها بحقوق الانسان', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 87
            [
                'day_number' => 87,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2024 - موضوع 02', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة شاملة للوحدات', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا 2022 - موضوع 01', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة شاملة للقواعد', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الثورة الجزائرية والقضايا الدولية', 'task_type' => 'review'],
                            ['topic_ar' => 'مراجعة الشخصيات والتواريخ', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 88 - مراجعة (قراءة فقط)
            [
                'day_number' => 88,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2022 - موضوع 02', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة الدوال والاحتمالات', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-english',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا شامل', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة القواعد والمفردات', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة للدروس', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 89 - مراجعة (قراءة فقط)
            [
                'day_number' => 89,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2023 - موضوع 02', 'task_type' => 'solve'],
                            ['topic_ar' => 'تصحيح بكالوريا 2017 - موضوع 02', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-english',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع Safety first & advertising', 'task_type' => 'solve'],
                            ['topic_ar' => 'كتابة فقرة حول The advantages and disadvantage of advertising', 'task_type' => 'exercise'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الربا وأحكامه', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس من المعاملات المالية الجائزة', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس النسب، التبني، الكفالة', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 90 - مراجعة (قراءة فقط)
            [
                'day_number' => 90,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2022 (موضوع 01) شعبة ع.ت', 'task_type' => 'solve'],
                            ['topic_ar' => 'ثم الوقوف على الأخطاء و تصحيحها', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-arabic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة للقواعد والدروس - قراءة فقط من الملخص', 'task_type' => 'review'],
                            ['topic_ar' => 'موضوع بكالوريا للشعب العلمية 2008 إيليا أبو ماضي شعر', 'task_type' => 'solve'],
                            ['topic_ar' => 'موضوع بكالوريا للشعب العلمية 2022 يوسف إدريس مقال', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول الاستقراء', 'task_type' => 'study'],
                            ['topic_ar' => 'قراءة مقالة حول الحتمية واللاحتمية', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس المنطق الصوري مع كتابة ملخص للدرس مع أقوال الفلاسفة', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],
            // Day 91 - نسبة التقدم 91%
            [
                'day_number' => 91,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'تصحيح بكالوريا 2022 - موضوع 02', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل بكالوريا 2021 - موضوع 02', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'تصحيح بكالوريا 2023 - موضوع 02', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة شاملة + حل بكالوريا أجنبية 1', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس العقيدة الإسلامية وأثرها على الفرد والمجتمع', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الورثة وطرق ميراثهم', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس من الثنائية إلى الأحادية القطبية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس استعادة السيادة الوطنية وبناء الدولة الجزائرية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1950 - 1956 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1962 - الوحدة 2', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1965 - 1989 - الوحدة 2', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 92
            [
                'day_number' => 92,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'تصحيح بكالوريا 2021 - موضوع 02', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة شاملة + حل بكالوريا أجنبية 01', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا 2020 لغات الموضوع 1', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل موضوع بكالوريا 2015 علميين الموضوع 1', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس مصادر القوة الاقتصادية للو.م.أ', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1965 - 1989 - الوحدة 2', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 93 - يوم راحة أو مراجعة ذاتية
            [
                'day_number' => 93,
                'day_type' => 'review',
                'title_ar' => 'مراجعة ذاتية',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة: المناعة والتحولات الطاقوية', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة: الميكانيك والكيمياء', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة: الدوال والمتتاليات', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 94 - مراجعة (قراءة فقط)
            [
                'day_number' => 94,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2023 (موضوع 01) شعبة رياضي', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-arabic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة للقواعد والدروس - قراءة فقط من الملخص', 'task_type' => 'review'],
                            ['topic_ar' => 'موضوع بكالوريا للشعب العلمية 2013 لميخائيل نعيمة مقال', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مخطط لمقالة قيمة المنطق الصوري', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],
            // Day 95 - مراجعة (قراءة فقط)
            [
                'day_number' => 95,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'تصحيح بكالوريا أجنبية 01', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة شاملة + حل بكالوريا أجنبية 02', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-french',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا 2021 علوم الموضوع 2', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل موضوع بكالوريا 2021 آداب وفلسفة الموضوع 1', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس ظاهرة التكتل وأثرها في قوة الاتحاد الأوروبي', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس العالم الثالث بين تراجع الاستعمار التقليدي', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 96 - مراجعة (قراءة فقط)
            [
                'day_number' => 96,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'تصحيح بكالوريا أجنبية 02', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة شاملة + حل بكالوريا أجنبية 03', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-english',
                        'topics' => [
                            ['topic_ar' => 'مراجعة دروس القواعد + الإجابة على أسئلة النص', 'task_type' => 'review'],
                            ['topic_ar' => 'حل موضوع Ethics in Business', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الصحة النفسية والجسمية في القرآن الكريم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس مدخل إلى علم الميراث', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
            // Day 97 - مراجعة (قراءة فقط)
            [
                'day_number' => 97,
                'day_type' => 'review',
                'title_ar' => 'مراجعة',
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2023 (موضوع 02) شعبة ع.ت', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-arabic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة للقواعد والدروس - قراءة فقط من الملخص', 'task_type' => 'review'],
                            ['topic_ar' => 'حل موضوع بكالوريا للشعب العلمية 2017 الدورة الأولى محمد بوزيدي شعر', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول التجربة والعلم', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول المنطق الصوري', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],
            // Day 98 - نسبة التقدم 98%
            [
                'day_number' => 98,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'sciences-exp-biology',
                        'topics' => [
                            ['topic_ar' => 'تصحيح بكالوريا أجنبية 02', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة شاملة وتنظيم الملخصات', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-physics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2023 (موضوع 02) شعبة رياضي', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-islamic',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الصحة النفسية والجسمية في القرآن الكريم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس مدخل إلى علم الميراث', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2021 - موضوع 02', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'sciences-exp-history-geo',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس من تبلور الوعي إلى الثورة الجزائرية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الجزائر في حوض البحر الأبيض المتوسط', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار حفظ الشخصيات الجزائرية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1955-1950 - الوحدة 2', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ الوحدة 3', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
        ];
    }

    /**
     * Seed weekly rewards (14 weeks)
     */
    private function seedWeeklyRewards(int $streamId): void
    {
        $rewards = [
            // Week 1 - Bad Genius
            [
                'week_number' => 1,
                'title_ar' => 'مكافأة الأسبوع 01',
                'description_ar' => 'بعد الانتهاء من جميع مهام الأسبوع والمراجعة، يمكنك الاستمتاع بمشاهدة فيلم أو مسلسل. اختر ما يناسبك واستمتع بوقتك مع جميل من هذه المكافأة.',
                'movie_title' => 'Bad Genius',
                'movie_image' => null,
            ],
            // Week 2 - The Boy Who Harnessed the Wind
            [
                'week_number' => 2,
                'title_ar' => 'مكافأة الأسبوع 02',
                'description_ar' => 'بعد الانتهاء من جميع مهام الأسبوع والمراجعة، يمكنك الاستمتاع بمشاهدة فيلم أو مسلسل. اختر ما يناسبك واستمتع بوقتك مع جميل من هذه المكافأة.',
                'movie_title' => 'The Boy Who Harnessed the Wind',
                'movie_image' => null,
            ],
            // Week 3 - MEG 2: The Trench
            [
                'week_number' => 3,
                'title_ar' => 'مكافأة الأسبوع 03',
                'description_ar' => 'بعد الانتهاء من جميع مهام الأسبوع، قم بالترفيه عن نفسك لكسر روتين الدراسة والضغط. يمكنك الاستمتاع بنشاط رياضي، أو مشاهدة فيلم ممتع، أو الجلوس مع العائلة... إلخ. أقترح عليك مشاهدة فيلم جميل جداً كجزء من هذه المكافأة.',
                'movie_title' => 'MEG 2: The Trench',
                'movie_image' => null,
            ],
            // Week 4 - Inception
            [
                'week_number' => 4,
                'title_ar' => 'مكافأة الأسبوع 04',
                'description_ar' => 'بعد الانتهاء من جميع مهام الأسبوع والضغط، قم بالترفيه عن نفسك لكسر روتين الدراسة. يمكنك الاستمتاع بنشاط رياضي، أو مشاهدة فيلم ممتع، أو الجلوس مع العائلة... إلخ. أقترح عليك مشاهدة فيلم جميل جداً كجزء من هذه المكافأة. رحلة إلى داخل عقول و أفكار نومهم، يعرض الفيلم أفكار كثيرة و عميقة أثناء نومهم.',
                'movie_title' => 'Inception',
                'movie_image' => null,
            ],
            // Week 5 - True Spirit
            [
                'week_number' => 5,
                'title_ar' => 'مكافأة الأسبوع 05',
                'description_ar' => 'بعد الانتهاء من جميع مهام الأسبوع، قم بالترفيه عن نفسك لكسر روتين الدراسة والضغط. يمكنك الاستمتاع بنشاط رياضي، أو مشاهدة فيلم ممتع، أو الجلوس مع العائلة... إلخ. أقترح عليك مشاهدة فيلم جميل جداً كجزء من هذه المكافأة. فيلم من قصة حقيقية لأصغر فتاة أبحرت حول العالم لمدة 210 يوم.',
                'movie_title' => 'True Spirit',
                'movie_image' => null,
            ],
            // Week 6 - Contratiempo
            [
                'week_number' => 6,
                'title_ar' => 'مكافأة الأسبوع 06',
                'description_ar' => 'بعد الانتهاء من جميع مهام الأسبوع، قم بالترفيه عن نفسك لكسر روتين الدراسة والضغط. يمكنك الاستمتاع بنشاط رياضي، أو مشاهدة فيلم ممتع، أو الجلوس مع العائلة... إلخ. أقترح عليك مشاهدة فيلم جميل جداً كجزء من هذه المكافأة. فيلم إسباني احتيال حول رجل أعمال وقتل امرأة و إطار وزوجها بجريمة قتلية، مليء بالأحداث و مفاجآت غير متوقعة.',
                'movie_title' => 'Contratiempo',
                'movie_image' => null,
            ],
            // Week 7
            [
                'week_number' => 7,
                'title_ar' => 'مكافأة الأسبوع 07',
                'description_ar' => 'بعد الانتهاء من جميع مهام الأسبوع، قم بالترفيه عن نفسك لكسر روتين الدراسة والضغط. يمكنك الاستمتاع بنشاط رياضي، أو مشاهدة فيلم ممتع، أو الجلوس مع العائلة... إلخ.',
                'movie_title' => null,
                'movie_image' => null,
            ],
            // Week 8
            [
                'week_number' => 8,
                'title_ar' => 'مكافأة الأسبوع 08',
                'description_ar' => 'بعد الانتهاء من جميع مهام الأسبوع، قم بالترفيه عن نفسك لكسر روتين الدراسة والضغط. يمكنك الاستمتاع بنشاط رياضي، أو مشاهدة فيلم ممتع، أو الجلوس مع العائلة... إلخ.',
                'movie_title' => null,
                'movie_image' => null,
            ],
        ];

        foreach ($rewards as $reward) {
            DB::table('bac_weekly_rewards')->insert([
                'academic_stream_id' => $streamId,
                'week_number' => $reward['week_number'],
                'title_ar' => $reward['title_ar'],
                'description_ar' => $reward['description_ar'] ?? null,
                'movie_title' => $reward['movie_title'] ?? null,
                'movie_image' => $reward['movie_image'] ?? null,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}
