<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class BacStudyScheduleManagementSeeder extends Seeder
{
    /**
     * Run the database seeds.
     * BAC Study Schedule for تسيير واقتصاد (Management & Economics) - Patch 01: Days 1-14
     */
    public function run(): void
    {
        // Get management-economics stream ID
        $streamId = DB::table('academic_streams')->where('slug', 'management-economics')->value('id');

        if (!$streamId) {
            $this->command->error('Stream management-economics not found! Run AcademicStructureSeeder first.');
            return;
        }

        // Get all subject IDs (subjects are shared across streams)
        $subjects = DB::table('subjects')
            ->pluck('id', 'slug')
            ->toArray();

        $this->command->info('Seeding BAC Study Schedule for management-economics (تسيير واقتصاد)...');
        $this->command->info('Available subjects: ' . implode(', ', array_keys($subjects)));

        // Study schedule data - combine all batches
        $days = array_merge(
            $this->getBatch1Days(),  // Days 1-14
            $this->getBatch2Days(),  // Days 15-28
            $this->getBatch3Days(),  // Days 29-42
            $this->getBatch4Days(),  // Days 43-56
            $this->getBatch5Days()   // Days 57-70
        );

        foreach ($days as $dayData) {
            // Check if day already exists
            $existingDay = DB::table('bac_study_days')
                ->where('academic_stream_id', $streamId)
                ->where('day_number', $dayData['day_number'])
                ->first();

            if ($existingDay) {
                $this->command->warn("Day {$dayData['day_number']} already exists, skipping...");
                continue;
            }

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

        $this->command->info('BAC Study Schedule (Management) seeded successfully!');
        $this->command->info('- ' . count($days) . ' study days created');
    }

    /**
     * Batch 1: Days 1-14 (First 2 weeks)
     */
    private function getBatch1Days(): array
    {
        return [
            // ==================== Day 01 ====================
            [
                'day_number' => 1,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'الوحدة 01: تقديم أعمال نهاية السنة', 'task_type' => 'study'],
                            ['topic_ar' => 'الوحدة 02: الإهتلاكات وفقص قيمة التثبيتات (الإهتلاك الخطي دون حساب + مراجعة للقوانين ومخطط الإهتلاك)', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'Les caractéristiques d\'un texte d\'Histoire', 'task_type' => 'study'],
                            ['topic_ar' => 'L\'ordre chronologique', 'task_type' => 'study'],
                            ['topic_ar' => 'La subjectivité / l\'objectivité', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'حفظ بروز الصراع وتشكل العالم + المصطلحات', 'task_type' => 'memorize'],
                            ['topic_ar' => 'حفظ الشخصيات الأمريكية', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 02 ====================
            [
                'day_number' => 2,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'المتتاليات: تعريف المتتالية + طرق توليد متتالية (عبارة الحد العام + علاقة تراجعية)', 'task_type' => 'study'],
                            ['topic_ar' => 'اتجاه تغير متتالية + المتتالية المحدودة + البرهان بالتراجع', 'task_type' => 'study'],
                            ['topic_ar' => 'تقارب و تباعد متتالية + نهاية متتالية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'Ethics in Business Part 1: فهم محتوى وحدة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة الأفكار وتلخيص الوحدة باستعمال الخرائط الذهنية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'العقيدة الإسلامية وأثرها على الفرد والمجتمع', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 03 ====================
            [
                'day_number' => 3,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'economics',
                        'topics' => [
                            ['topic_ar' => 'الوحدة 1: النقود', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'law',
                        'topics' => [
                            ['topic_ar' => 'الوحدة 1: عقد البيع', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'النثر العلمي و النثر العلمي المتأدب', 'task_type' => 'study'],
                            ['topic_ar' => 'الإعراب اللفظي', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'التعرف على جميع منهجيات كتابة مقال فلسفي', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 04 ====================
            [
                'day_number' => 4,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'الوحدة 2: إهتلاك التثبيتات المعنوية والعينية', 'task_type' => 'study'],
                            ['topic_ar' => 'التنازل عن التثبيتات + حل تمارين', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'مراجعة ما تم دراسته', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار ما حفظته + إضافة مصطلحات جديدة', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'تكرار ما حفظته في الرياضيات', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 05 ====================
            [
                'day_number' => 5,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 2: إهتلاك التثبيتات', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'economics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 1: النقود', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'law',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 1: عقد البيع', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'فهم نموذج سؤال بطريقة الإستقصاء بالوضع', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول الإحساس والإدراك مع التصحيح', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 06 ====================
            [
                'day_number' => 6,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'الوحدة 2: خسائر القيمة عن المخزونات والحقوق', 'task_type' => 'study'],
                            ['topic_ar' => 'الميزانية الوظيفية والنسب والمؤشرات', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'Le compte rendu', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار سريع حفظ سنتي 1945-1947', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ نضيح الجزائر والمستعمرة للوحدة 1', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 07 - Week 01 Reward ====================
            [
                'day_number' => 7,
                'day_type' => 'review',
                'title_ar' => 'مكافأة الأسبوع 01',
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'مراجعة جميع ما تمت دراسته خلال الأسبوع', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'economics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة ما تم دراسته', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'law',
                        'topics' => [
                            ['topic_ar' => 'مراجعة ما تم دراسته', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 08 ====================
            [
                'day_number' => 8,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'الوحدة 3: الأجور + سندات المساهمة', 'task_type' => 'study'],
                            ['topic_ar' => 'حل 3 تمارين', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة ما تم دراسته سابقا', 'task_type' => 'review'],
                            ['topic_ar' => 'حل تمارين وتكرارات', 'task_type' => 'solve'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 09 ====================
            [
                'day_number' => 9,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 3 كاملة', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'economics',
                        'topics' => [
                            ['topic_ar' => 'الوحدة 2: سعر الصرف', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'law',
                        'topics' => [
                            ['topic_ar' => 'الوحدة 2: عقد الإيجار', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 10 ====================
            [
                'day_number' => 10,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'مراجعة ما تم دراسته خلال يوم أمس (قراءة فقط)', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل 3 تمارين', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة الدروس', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'Conditional type 01 / 02 جرامر', 'task_type' => 'study'],
                            ['topic_ar' => 'Provided that / providing that / as long as', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 11 ====================
            [
                'day_number' => 11,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'الوحدة 5 الإهتلاكات والمؤونات: تسجيل قيود', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'Les procédés explicatifs', 'task_type' => 'study'],
                            ['topic_ar' => 'Les substituts lexicaux et grammaticaux', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'الأسئلة حول الشعور بالأنا والشعور (تحليل وجدان)', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 12 ====================
            [
                'day_number' => 12,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'الوحدة 3: تسوية سندات المساهمة', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'المستوى المعيشي والتطور الاقتصادي والاجتماعي في الجزائر', 'task_type' => 'study'],
                            ['topic_ar' => 'تكرار المصطلحات', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'economics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 2: سعر الصرف', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 13 ====================
            [
                'day_number' => 13,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'economics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 2: سعر الصرف + حل تمرين', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 1: نص تواصلي + حل تمرين', 'task_type' => 'review'],
                            ['topic_ar' => 'الوحدة 2 بناء الفعل للمعلوم وللمجهول', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'فهم نموذج سؤال بمقارنة والمقارنة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول اللغة والفكر', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 14 - Week 02 Reward ====================
            [
                'day_number' => 14,
                'day_type' => 'review',
                'title_ar' => 'مكافأة الأسبوع 02',
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'مراجعة جميع الوحدات المدروسة', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'Le rappel des pronoms', 'task_type' => 'study'],
                            ['topic_ar' => 'Les rapports logiques', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تاريخ ثورة 1945، الحركة الاستقلالية للجزائر الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ تواريخ 1947', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
        ];
    }

    /**
     * Batch 2: Days 15-28 (Weeks 3-4)
     */
    private function getBatch2Days(): array
    {
        return [
            // ==================== Day 15 ====================
            [
                'day_number' => 15,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'الوحدة 3: سندات المساهمة (تكملة)', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'Le rappel des pronoms', 'task_type' => 'study'],
                            ['topic_ar' => 'Les rapports logiques', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تاريخ ثورة 1945، الحركة الاستقلالية للجزائر الوحدة 1', 'task_type' => 'study'],
                            ['topic_ar' => 'حفظ تواريخ 1947', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 16 ====================
            [
                'day_number' => 16,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'مراجعة ما تم دراسته خلال يوم أمس', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل تمارين متنوعة في المتتاليات', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'Unless / With - فهم درس جرامر', 'task_type' => 'study'],
                            ['topic_ar' => 'مراجعة الوحدة الأولى', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الدرس الأول والثاني', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 17 ====================
            [
                'day_number' => 17,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'economics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 1-3: تكملة المراجعات', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'الوحدة 5-6: إعداد الكشوف المالية', 'task_type' => 'study'],
                            ['topic_ar' => 'مراجعة الوحدة 1-5 سريعة', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة النصوص الأدبية', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة فلسفية مع التصحيح', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 18 ====================
            [
                'day_number' => 18,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'الوحدة 4: خسائر القيمة عن الحقوق', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الحرب الباردة', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ مصطلحات الوحدة الثانية', 'task_type' => 'memorize'],
                        ]
                    ],
                    [
                        'slug' => 'law',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 1-2', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 19 ====================
            [
                'day_number' => 19,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'الوحدة 4: إستمرار خسائر القيمة', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة ما تم دراسته سابقا', 'task_type' => 'review'],
                            ['topic_ar' => 'حل تمارين إضافية', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'It\'s high time / It\'s about time - expressing advice', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس جرامر جديد', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 20 ====================
            [
                'day_number' => 20,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'economics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 3: البورصة', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'law',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 5: عقد الشركة', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة المدروسة', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة مقالة حول الشعور بالأنا', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 21 - Week 03 Reward ====================
            [
                'day_number' => 21,
                'day_type' => 'review',
                'title_ar' => 'مكافأة الأسبوع 03',
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة لما تمت دراسته', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'economics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'law',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 22 ====================
            [
                'day_number' => 22,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'الوحدة 6: تسوية المخزونات', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا سابق', 'task_type' => 'solve'],
                            ['topic_ar' => 'كتابة sujet 01', 'task_type' => 'exercise'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار سريع منهجية الأطروحة الأمريكية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار المصطلحات والشخصيات', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 23 ====================
            [
                'day_number' => 23,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'الدوال اللوغاريتمية: تعريف + خصائص', 'task_type' => 'study'],
                            ['topic_ar' => 'حساب النهايات والاشتقاق', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'Expressing cause & result & purpose', 'task_type' => 'study'],
                            ['topic_ar' => 'مراجعة الوحدة كاملة', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الدروس المدروسة', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ المصطلحات الإسلامية', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 24 ====================
            [
                'day_number' => 24,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'economics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 4-5', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 4-6 للغة العربية', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالات سابقة للبكالوريا 2019', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول مختلف المقاربات', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 25 ====================
            [
                'day_number' => 25,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 7: تسجيل القيود المحاسبية', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'Discours direct et indirect', 'task_type' => 'study'],
                            ['topic_ar' => 'الوحدة 2 للغة الفرنسية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل 3 تمارين', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة الدروس', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 26 ====================
            [
                'day_number' => 26,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'مراجعة ما تم دراسته خلال يوم أمس', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'حل تمرين جرامر + active & passive voice', 'task_type' => 'solve'],
                            ['topic_ar' => 'فهم درس جرامر: that, what', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس ملتقى المصالح والاتفاقيات', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ المصطلحات الجديدة', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 27 ====================
            [
                'day_number' => 27,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'economics',
                        'topics' => [
                            ['topic_ar' => 'الوحدة 5-6: التجارة الخارجية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'الوحدة 5: التسويات الجردية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'law',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 5: عقد العمل', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 28 - Week 04 Reward ====================
            [
                'day_number' => 28,
                'day_type' => 'review',
                'title_ar' => 'مكافأة الأسبوع 04',
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 5: خسائر القيمة والتسويات', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار تواريخ 1947-1956 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار توزيع الوحدة 1958 والمساءلة الوطنية للوحدة 2', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'Les temps de la conjugaison', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],
        ];
    }

    /**
     * Batch 3: Days 29-42 (Weeks 5-6)
     */
    private function getBatch3Days(): array
    {
        return [
            // ==================== Day 29 ====================
            [
                'day_number' => 29,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'الوحدة 6: تسوية الأغلفة', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'Les temps de la conjugaison (تكملة)', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار سريع من مراحل الأطروحة 1947-1956 الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار توزيع الوحدة 1958 والمسائلة الوطنية للوحدة 2', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 30 ====================
            [
                'day_number' => 30,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل 3 تمارين حول المتتاليات', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة الدروس', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'Ethics in Business - How to fight corruption', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة فقرة حول الفساد', 'task_type' => 'exercise'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الدروس السابقة', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 31 ====================
            [
                'day_number' => 31,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'economics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 3: المؤسسات المالية', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 4 للغة العربية', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالات سابقة للبكالوريا 2009', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول مختلف المقاربات', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 32 ====================
            [
                'day_number' => 32,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'مراجعة ما تم دراسته خلال يوم أمس', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'Discours direct et indirect', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس التحولات الكبرى بعد 1958 - الوحدة 2', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ تواريخ 1956 - 1958 والسلام', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 33 ====================
            [
                'day_number' => 33,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'الوحدة 7: جدول حسابات النتائج', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'The importance of ethics in business - مقال متوسط', 'task_type' => 'study'],
                            ['topic_ar' => 'حل تمرين جرامر', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الدروس السابقة', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 34 ====================
            [
                'day_number' => 34,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'economics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 4-5: التجارة والميزان', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'law',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 3: عقد الإيجار', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 5-6: الأدب والنصوص', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 35 - Week 05 Reward ====================
            [
                'day_number' => 35,
                'day_type' => 'review',
                'title_ar' => 'مكافأة الأسبوع 05',
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 8: الأجور والمستخدمين', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'La voix active et passive', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'حفظ تواريخ 1945-1949', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 36 ====================
            [
                'day_number' => 36,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'الوحدة 10: إعداد الميزانية الختامية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل تمارين في الدوال اللوغاريتمية', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'موضوع بكالوريا 2015 - الشخصية والهوية', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول الأنا والآخر', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 37 ====================
            [
                'day_number' => 37,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'الدوال اللوغاريتمية: الاشتقاق والتكامل', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'Safety First and Advertising', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم الأفكار والمصطلحات الجديدة', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار مدخل إلى علم الميراث', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار الورثة وطرق ميراثهم', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 38 ====================
            [
                'day_number' => 38,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'economics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 3: القطاع المالي', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'law',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 2-3: العقود القانونية', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'أسلوب النداء والتعجب والتوكيد', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول الشعور واللاشعور', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 39 ====================
            [
                'day_number' => 39,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'مراجعة ما تم دراسته خلال يوم أمس (قراءة فقط)', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'BAC 2018 langues sujet 01', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس تأثير الجزائر وإسهامها في حركات التحرر', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس الجزائر في حوض البحر الأبيض المتوسط', 'task_type' => 'memorize'],
                            ['topic_ar' => 'تكرار الشخصيات السوفياتية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1949 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1950 - 1956', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 40 ====================
            [
                'day_number' => 40,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل 3 تمارين', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة حول المتتاليات', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'Expressing certainty, possibility and remote possibility', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس جرامر', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'درس أصحاب الفروض والعصبات', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 41 ====================
            [
                'day_number' => 41,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'economics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 1: النقود', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'law',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 3: العقود المدنية', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'مراجعة التيار والقانون للشخصية', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة مقالة حول الأخلاق والسياسة', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 42 - Week 06 Reward ====================
            [
                'day_number' => 42,
                'day_type' => 'review',
                'title_ar' => 'مكافأة الأسبوع 06',
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'الوحدة 9-10: إعداد الكشوف المالية', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'BAC 2021 langues sujet 01', 'task_type' => 'solve'],
                            ['topic_ar' => 'تكرار درس مؤشرات التحليل المقالي', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'حفظ مؤشرات وملامح الأطروحة للوحدة 1', 'task_type' => 'memorize'],
                            ['topic_ar' => 'حفظ شخصيات 1956 - وثيقة 1', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
        ];
    }

    /**
     * Batch 4: Days 43-56 (Weeks 7-8)
     */
    private function getBatch4Days(): array
    {
        return [
            // ==================== Day 43 ====================
            [
                'day_number' => 43,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'الوحدة 11: تحليل الميزانية الوظيفية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'La structure d\'un texte argumentatif', 'task_type' => 'study'],
                            ['topic_ar' => 'L\'opposition et la concession', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'حفظ المصطلحات الجغرافية', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 44 ====================
            [
                'day_number' => 44,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل تمارين متنوعة', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة الدروس السابقة', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'Present simple, modals, requests and orders', 'task_type' => 'study'],
                            ['topic_ar' => 'First, at first, at last... درس جرامر', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الدروس السابقة', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 45 ====================
            [
                'day_number' => 45,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'economics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 5: السوق المالي', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'law',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 6: عقود خاصة', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'الوحدة 7: الشعر العربي الحديث', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول الحرية والمسؤولية', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 46 ====================
            [
                'day_number' => 46,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'الوحدة 9-8: تحليل النتائج حسب الطبيعة والوظيفة', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'BAC 2018 langues sujet 01', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس تأثير الجزائر وإسهامها في حركات التحرر', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس الجزائر في حوض البحر الأبيض المتوسط', 'task_type' => 'memorize'],
                            ['topic_ar' => 'تكرار الشخصيات السوفياتية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1949-1950', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1950 - 1956', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 47 ====================
            [
                'day_number' => 47,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'الاحتمالات: الحادثة العشوائية + مجموع الاحتمالات', 'task_type' => 'study'],
                            ['topic_ar' => 'قانون تركيب والتوافقيق + كيفية الحساب بالآلة الحاسبة', 'task_type' => 'study'],
                            ['topic_ar' => 'والانحراف المعياري لمتغير عشوائي ومستوى الحد والتباين', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'Safety First & Advertising وحدة', 'task_type' => 'study'],
                            ['topic_ar' => 'Why do people consume fast food? حل موضوع حول', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'الإسلام والرسالات السماوية - الدين عند الله الإسلام', 'task_type' => 'study'],
                            ['topic_ar' => 'تكرار الإرسال السماوية - الإسلام الرسالة الخاتمة', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 48 ====================
            [
                'day_number' => 48,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'economics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 2: السوق والميزان التجاري', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'law',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 6: عقود العمل', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول المسؤولية والجزاء', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول العدالة والمساواة', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 49 - Week 07 Reward ====================
            [
                'day_number' => 49,
                'day_type' => 'review',
                'title_ar' => 'مكافأة الأسبوع 07',
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 10: إعداد الكشوف المالية', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'حفظ تواريخ 1961-1963 - الوحدة 1', 'task_type' => 'memorize'],
                            ['topic_ar' => 'حفظ تواريخ 1963-1972 - الوحدة 2', 'task_type' => 'memorize'],
                            ['topic_ar' => 'تكرار تواريخ 1958 - 1963', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 50 ====================
            [
                'day_number' => 50,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'الوحدة 12: التحليل المالي', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'Le compte rendu d\'un texte argumentatif', 'task_type' => 'study'],
                            ['topic_ar' => 'Les verbes performatifs', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'حفظ تواريخ 1961-1963 الوحدة 1', 'task_type' => 'memorize'],
                            ['topic_ar' => 'حفظ تواريخ 1963-1972 الوحدة 2', 'task_type' => 'memorize'],
                            ['topic_ar' => 'تكرار تواريخ 1958 - 1963', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 51 ====================
            [
                'day_number' => 51,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل 2 تمارين حول الاحتمالات', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة كل ما تم دراسته خلال الأيام السابقة', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'Safety First & Advertising وحدة', 'task_type' => 'study'],
                            ['topic_ar' => 'Why do people consume fast food?', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'الإسلام والرسالات السماوية', 'task_type' => 'review'],
                            ['topic_ar' => 'الدين عند الله الإسلام', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 52 ====================
            [
                'day_number' => 52,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'economics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 3: السوق والميزان', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'law',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 6: عقود خاصة', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'أكمل إثراء الرصيد اللغوي', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة فقرة حول المسألة والعلاقة', 'task_type' => 'exercise'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'مراجعة ما تم دراسته', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 53 ====================
            [
                'day_number' => 53,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'مراجعة ما تم دراسته سابقا (قراءة فقط)', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 17 وحدة الأخيرة', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة فقرة بالفرنسية', 'task_type' => 'exercise'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس شخصيات 1945-1965 الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1965-1966 الوحدة 1', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 54 ====================
            [
                'day_number' => 54,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 13-14-15: الاقتصاد', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل 3 تمارين', 'task_type' => 'solve'],
                            ['topic_ar' => 'مراجعة الدروس السابقة', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول الأخلاق', 'task_type' => 'exercise'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 55 ====================
            [
                'day_number' => 55,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 19-22 الاقتصاد', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'law',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الوحدة 14-15-16', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'موضوع بكالوريا 2017 حل كتابي', 'task_type' => 'solve'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 56 - Week 08 Reward ====================
            [
                'day_number' => 56,
                'day_type' => 'review',
                'title_ar' => 'مكافأة الأسبوع 08',
                'subjects' => [
                    [
                        'slug' => 'accounting',
                        'topics' => [
                            ['topic_ar' => 'الوحدة 12: التحليل المالي', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'Les stratégies argumentatives', 'task_type' => 'study'],
                            ['topic_ar' => 'L\'opposition et la concession', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس سياسة التنمية في الجزائر', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ تواريخ 1961-1981 الوحدة 1', 'task_type' => 'memorize'],
                            ['topic_ar' => 'حفظ تواريخ 1961-1963 الوحدة 2', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],
        ];
    }

    /**
     * Batch 5: Days 57-70 (Weeks 9-10)
     */
/**
 * Batch 5: Days 57-70 (Weeks 9-10)
 * Extracted CORRECTLY from images 31-38
 */
private function getBatch5Days(): array
{
    return [
        // ==================== Day 57 (Image 31 - يمين) ====================
        [
            'day_number' => 57,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                [
                    'slug' => 'accounting',
                    'topics' => [
                        ['topic_ar' => 'الوحدة 12 القروض', 'task_type' => 'study'],
                    ]
                ],
                [
                    'slug' => 'french',
                    'topics' => [
                        ['topic_ar' => 'Les stratégies argumentatives', 'task_type' => 'study'],
                        ['topic_ar' => 'L\'opposition et la concession', 'task_type' => 'study'],
                    ]
                ],
                [
                    'slug' => 'history-geography',
                    'topics' => [
                        ['topic_ar' => 'تكرار دروس مشكلة الغذاء في الهند، التنمية في البرازيل', 'task_type' => 'review'],
                        ['topic_ar' => 'تكرار تواريخ 1945، 1961 - الوحدة 2', 'task_type' => 'memorize'],
                        ['topic_ar' => 'تكرار تواريخ 1962، 1972، 1989، 1991 - الوحدة 1', 'task_type' => 'memorize'],
                    ]
                ],
            ]
        ],

        // ==================== Day 58 (Image 32 - bottom) ====================
        [
            'day_number' => 58,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                [
                    'slug' => 'mathematics',
                    'topics' => [
                        ['topic_ar' => 'الاشتقاقية (تابع)', 'task_type' => 'study'],
                        ['topic_ar' => 'حل موضوع خلاف حول الاشتقاقية', 'task_type' => 'solve'],
                    ]
                ],
                [
                    'slug' => 'english',
                    'topics' => [
                        ['topic_ar' => 'Safety First & Advertising', 'task_type' => 'study'],
                        ['topic_ar' => 'The advantages and disadvantages of Advertising', 'task_type' => 'study'],
                    ]
                ],
                [
                    'slug' => 'arabic',
                    'topics' => [
                        ['topic_ar' => 'مراجعة كل ما تم دراسته', 'task_type' => 'review'],
                    ]
                ],
                [
                    'slug' => 'philosophy',
                    'topics' => [
                        ['topic_ar' => 'مراجعة كل ما تم دراسته خلال اليوم', 'task_type' => 'review'],
                    ]
                ],
            ]
        ],

        // ==================== Day 59 (Image 32 - top) ====================
        [
            'day_number' => 59,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                [
                    'slug' => 'accounting',
                    'topics' => [
                        ['topic_ar' => 'مراجعة الوحدة 3-4-5 الاهتلاك الثابت', 'task_type' => 'review'],
                        ['topic_ar' => 'مراجعة الوحدة 6 و 7 و 8 (الاهتلاك)', 'task_type' => 'review'],
                        ['topic_ar' => 'مراجعة التسوية', 'task_type' => 'review'],
                    ]
                ],
                [
                    'slug' => 'arabic',
                    'topics' => [
                        ['topic_ar' => 'مراجعة البناء الفكري دراسة النص والشعر', 'task_type' => 'review'],
                        ['topic_ar' => 'حل موضوع متعدد', 'task_type' => 'solve'],
                    ]
                ],
                [
                    'slug' => 'philosophy',
                    'topics' => [
                        ['topic_ar' => 'كتابة مقالة مختلفة', 'task_type' => 'exercise'],
                        ['topic_ar' => 'مراجعة كل مقالة طريقة علم التاريخ', 'task_type' => 'review'],
                    ]
                ],
            ]
        ],

        // ==================== Day 60 (Image 33 - bottom) ====================
        [
            'day_number' => 60,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                [
                    'slug' => 'economics',
                    'topics' => [
                        ['topic_ar' => 'مراجعة الوحدة 1-2-3 الاقتصاد', 'task_type' => 'review'],
                    ]
                ],
                [
                    'slug' => 'french',
                    'topics' => [
                        ['topic_ar' => 'Le lexique de l\'argumentation', 'task_type' => 'study'],
                        ['topic_ar' => 'Les articulateurs', 'task_type' => 'study'],
                    ]
                ],
                [
                    'slug' => 'islamic-education',
                    'topics' => [
                        ['topic_ar' => 'مراجعة الإعداد الخلقي في الإسلام', 'task_type' => 'review'],
                        ['topic_ar' => 'مراجعة الوحدة 1 والوحدة 2', 'task_type' => 'review'],
                        ['topic_ar' => 'تكرار تواريخ 1945 - 1961 - الوحدة 2', 'task_type' => 'memorize'],
                    ]
                ],
            ]
        ],

        // ==================== Day 61 (Image 33 - top) ====================
        [
            'day_number' => 61,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                [
                    'slug' => 'mathematics',
                    'topics' => [
                        ['topic_ar' => 'مراجعة الاشتقاقية', 'task_type' => 'review'],
                    ]
                ],
                [
                    'slug' => 'english',
                    'topics' => [
                        ['topic_ar' => 'Safety First & Advertising', 'task_type' => 'study'],
                        ['topic_ar' => 'The advantages and disadvantages of advertising', 'task_type' => 'study'],
                    ]
                ],
                [
                    'slug' => 'arabic',
                    'topics' => [
                        ['topic_ar' => 'موضوع مقترح حول القضية (مقالة)', 'task_type' => 'exercise'],
                    ]
                ],
                [
                    'slug' => 'philosophy',
                    'topics' => [
                        ['topic_ar' => 'كتابة مقالة حول القضية', 'task_type' => 'exercise'],
                        ['topic_ar' => 'التمييز بين المشكلة والإشكالية', 'task_type' => 'study'],
                    ]
                ],
            ]
        ],

        // ==================== Day 62 (Image 34 - bottom) ====================
        [
            'day_number' => 62,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                [
                    'slug' => 'accounting',
                    'topics' => [
                        ['topic_ar' => 'مراجعة كل ما تم دراسته', 'task_type' => 'review'],
                    ]
                ],
                [
                    'slug' => 'economics',
                    'topics' => [
                        ['topic_ar' => 'مراجعة الوحدة 4-5-6 الاقتصاد', 'task_type' => 'review'],
                    ]
                ],
                [
                    'slug' => 'law',
                    'topics' => [
                        ['topic_ar' => 'موضوع 2017 (وضعيات ومسائل)', 'task_type' => 'solve'],
                    ]
                ],
            ]
        ],

        // ==================== Day 63 (Image 34 - top) ====================
        [
            'day_number' => 63,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                [
                    'slug' => 'accounting',
                    'topics' => [
                        ['topic_ar' => 'الوحدة 13-14-15-16-17 المحاسبة التحليلية', 'task_type' => 'study'],
                    ]
                ],
                [
                    'slug' => 'french',
                    'topics' => [
                        ['topic_ar' => 'حل موضوع بكالوريا', 'task_type' => 'solve'],
                        ['topic_ar' => 'الموضوع المختار للدراسة القبلية', 'task_type' => 'study'],
                    ]
                ],
                [
                    'slug' => 'history-geography',
                    'topics' => [
                        ['topic_ar' => 'تكرار تواريخ دروس 1945 الصهيونية وقضايا', 'task_type' => 'memorize'],
                        ['topic_ar' => 'تكرار 1947، تكرار الوحدة 1: 1949-1', 'task_type' => 'memorize'],
                        ['topic_ar' => 'تكرار الوحدة 2: 1961-1965', 'task_type' => 'memorize'],
                    ]
                ],
            ]
        ],

        // ==================== Day 64 (Image 35 - top) ====================
        [
            'day_number' => 64,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                [
                    'slug' => 'accounting',
                    'topics' => [
                        ['topic_ar' => 'الوحدة 11-15 المحاسبة', 'task_type' => 'study'],
                    ]
                ],
                [
                    'slug' => 'french',
                    'topics' => [
                        ['topic_ar' => 'Le compte rendu de texte argumentatif', 'task_type' => 'study'],
                        ['topic_ar' => 'Les verbes performatifs', 'task_type' => 'study'],
                    ]
                ],
                [
                    'slug' => 'history-geography',
                    'topics' => [
                        ['topic_ar' => 'تكرار الوحدة 1: 1980 - 1990', 'task_type' => 'memorize'],
                        ['topic_ar' => 'تكرار الوحدة 2: 1943 - 1948', 'task_type' => 'memorize'],
                        ['topic_ar' => 'تكرار الوحدة 3', 'task_type' => 'memorize'],
                    ]
                ],
            ]
        ],

        // ==================== Day 65 (Image 36 - bottom) ====================
        [
            'day_number' => 65,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                [
                    'slug' => 'mathematics',
                    'topics' => [
                        ['topic_ar' => 'حل بكالوريا 2017', 'task_type' => 'solve'],
                    ]
                ],
                [
                    'slug' => 'english',
                    'topics' => [
                        ['topic_ar' => 'Ethics in Business', 'task_type' => 'study'],
                        ['topic_ar' => 'The consequences of counterfeiting - موضوع 01', 'task_type' => 'solve'],
                    ]
                ],
                [
                    'slug' => 'arabic',
                    'topics' => [
                        ['topic_ar' => 'موضوع بكالوريا حول الشعر', 'task_type' => 'solve'],
                        ['topic_ar' => 'حل شق شق وحدة مختارة', 'task_type' => 'solve'],
                    ]
                ],
                [
                    'slug' => 'philosophy',
                    'topics' => [
                        ['topic_ar' => 'مراجعة كل ما تم دراسته', 'task_type' => 'review'],
                    ]
                ],
            ]
        ],

        // ==================== Day 66 (Image 36 - top) ====================
        [
            'day_number' => 66,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                [
                    'slug' => 'accounting',
                    'topics' => [
                        ['topic_ar' => 'مراجعة الوحدة 10-11 المحاسبة', 'task_type' => 'review'],
                        ['topic_ar' => 'حل موضوع بكالوريا مركب مجموع الوحدات', 'task_type' => 'solve'],
                    ]
                ],
                [
                    'slug' => 'economics',
                    'topics' => [
                        ['topic_ar' => 'مراجعة شاملة', 'task_type' => 'review'],
                        ['topic_ar' => 'حل موضوع بكالوريا', 'task_type' => 'solve'],
                    ]
                ],
                [
                    'slug' => 'law',
                    'topics' => [
                        ['topic_ar' => 'مراجعة شاملة', 'task_type' => 'review'],
                        ['topic_ar' => 'حل موضوع الاختصاصات', 'task_type' => 'solve'],
                    ]
                ],
                [
                    'slug' => 'history-geography',
                    'topics' => [
                        ['topic_ar' => 'تكرار دروس السكان والتنمية في الهند - التنمية في البرازيل', 'task_type' => 'review'],
                        ['topic_ar' => 'تكرار تواريخ 1950 - 1956 - الوحدة 1', 'task_type' => 'memorize'],
                        ['topic_ar' => 'حفظ تواريخ 1955-1950', 'task_type' => 'memorize'],
                        ['topic_ar' => 'حفظ تواريخ 1960 - 1961 - الوحدة 2', 'task_type' => 'memorize'],
                    ]
                ],
            ]
        ],

        // ==================== Day 67 (Image 37 - right) ====================
        [
            'day_number' => 67,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                [
                    'slug' => 'accounting',
                    'topics' => [
                        ['topic_ar' => 'مراجعة نهائية (موضوع شامل لكل الوحدات)', 'task_type' => 'review'],
                    ]
                ],
                [
                    'slug' => 'french',
                    'topics' => [
                        ['topic_ar' => 'حل موضوع بكالوريا 2022 علميين الموضوع 2', 'task_type' => 'solve'],
                        ['topic_ar' => 'حل موضوع بكالوريا 2022 لغات الموضوع 1', 'task_type' => 'solve'],
                    ]
                ],
                [
                    'slug' => 'history-geography',
                    'topics' => [
                        ['topic_ar' => 'تكرار درس الجزائر في حوض البحر الأبيض المتوسط', 'task_type' => 'review'],
                        ['topic_ar' => 'تكرار درس القضية الفلسطينية', 'task_type' => 'review'],
                        ['topic_ar' => 'تكرار تواريخ 1947 - الوحدة 1', 'task_type' => 'memorize'],
                        ['topic_ar' => 'تكرار تواريخ 1943 - 1947 - الوحدة 2', 'task_type' => 'memorize'],
                        ['topic_ar' => 'حفظ تواريخ 1960 - 1961 - الوحدة 2', 'task_type' => 'memorize'],
                    ]
                ],
            ]
        ],

        // ==================== Day 68 (Image 37 - left) ====================
        [
            'day_number' => 68,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                [
                    'slug' => 'mathematics',
                    'topics' => [
                        ['topic_ar' => 'حل بكالوريا 2017 - موضوع 02', 'task_type' => 'solve'],
                    ]
                ],
                [
                    'slug' => 'english',
                    'topics' => [
                        ['topic_ar' => 'Ethics in Business (Child labour)', 'task_type' => 'study'],
                        ['topic_ar' => 'حل موضوع حول وحدة Child labour', 'task_type' => 'solve'],
                        ['topic_ar' => 'Causes of Child labour + How to eradicate it - كتابة فقرة', 'task_type' => 'exercise'],
                    ]
                ],
                [
                    'slug' => 'islamic-education',
                    'topics' => [
                        ['topic_ar' => 'تكرار درس من المعاملات المالية الجائزة', 'task_type' => 'review'],
                        ['topic_ar' => 'تكرار درس الحرية الشخصية ومدى ارتباطها بحقوق الانسان', 'task_type' => 'review'],
                    ]
                ],
            ]
        ],

        // ==================== Day 69 (Image 38 - right) ====================
        [
            'day_number' => 69,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                [
                    'slug' => 'economics',
                    'topics' => [
                        ['topic_ar' => 'الوحدة 11 التمويل', 'task_type' => 'study'],
                    ]
                ],
                [
                    'slug' => 'law',
                    'topics' => [
                        ['topic_ar' => 'مواضيع شاملة (وضعيات ومسندات)', 'task_type' => 'solve'],
                    ]
                ],
                [
                    'slug' => 'arabic',
                    'topics' => [
                        ['topic_ar' => 'موضوع بكالوريا 2015 للشعب العلمية - مفدي زكريا', 'task_type' => 'solve'],
                    ]
                ],
                [
                    'slug' => 'philosophy',
                    'topics' => [
                        ['topic_ar' => 'كتابة مقالة حول علم النفس', 'task_type' => 'exercise'],
                        ['topic_ar' => 'كتابة مخطط لمقالة مصادر المعرفة', 'task_type' => 'exercise'],
                    ]
                ],
            ]
        ],

        // ==================== Day 70 (Image 38 - left) ====================
        [
            'day_number' => 70,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                [
                    'slug' => 'accounting',
                    'topics' => [
                        ['topic_ar' => 'مراجعة نهائية (موضوع شامل لكل الوحدات)', 'task_type' => 'review'],
                    ]
                ],
                [
                    'slug' => 'islamic-education',
                    'topics' => [
                        ['topic_ar' => 'تكرار درس الصحة النفسية والجسمية في القرآن الكريم', 'task_type' => 'review'],
                        ['topic_ar' => 'تكرار درس الحرية الشخصية ومدى ارتباطها بحقوق الانسان', 'task_type' => 'review'],
                    ]
                ],
                [
                    'slug' => 'history-geography',
                    'topics' => [
                        ['topic_ar' => 'تكرار درس مصادر القوة الاقتصادية للولايات', 'task_type' => 'review'],
                        ['topic_ar' => 'تكرار درس ظاهرة التكتل وأثرها في قوة الاتحاد الأوربي', 'task_type' => 'review'],
                        ['topic_ar' => 'تكرار درس العمل المسلح ورد فعل الاستعمار', 'task_type' => 'review'],
                        ['topic_ar' => 'تكرار تواريخ 1972 - 1991 - الوحدة 1', 'task_type' => 'memorize'],
                        ['topic_ar' => 'تكرار تواريخ 1943-1947 - الوحدة 2', 'task_type' => 'memorize'],
                        ['topic_ar' => 'تكرار تواريخ 1960 - 1961 - الوحدة 2', 'task_type' => 'memorize'],
                    ]
                ],
            ]
        ],
    ];
}
}
