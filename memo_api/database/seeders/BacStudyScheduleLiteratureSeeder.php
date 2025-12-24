<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class BacStudyScheduleLiteratureSeeder extends Seeder
{
    /**
     * Run the database seeds.
     * BAC Study Schedule for آداب وفلسفة (Literature & Philosophy) - Patch 01: Days 1-14
     */
    public function run(): void
    {
        // Get literature-philosophy stream ID
        $streamId = DB::table('academic_streams')->where('slug', 'literature-philosophy')->value('id');

        if (!$streamId) {
            $this->command->error('Stream literature-philosophy not found! Run AcademicStructureSeeder first.');
            return;
        }

        // Get all subject IDs (subjects are shared across streams)
        $subjects = DB::table('subjects')
            ->pluck('id', 'slug')
            ->toArray();

        $this->command->info('Seeding BAC Study Schedule for literature-philosophy (آداب وفلسفة)...');
        $this->command->info('Available subjects: ' . implode(', ', array_keys($subjects)));

        // Study schedule data - combine all batches
        $days = array_merge(
            $this->getBatch1Days(),  // Days 1-14
            $this->getBatch2Days(),  // Days 15-28
            $this->getBatch3Days(),  // Days 29-42
            $this->getBatch4Days(),  // Days 43-56
            $this->getBatch5Days(),  // Days 57-70
            $this->getBatch6Days(),  // Days 71-84
            $this->getBatch7Days()   // Days 85-98
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

        $this->command->info('BAC Study Schedule (Literature) Patch 01 seeded successfully!');
        $this->command->info('- ' . count($days) . ' study days created (Days 1-14)');
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
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'النثر العلمي و النثر العلمي المتأدب', 'task_type' => 'study'],
                            ['topic_ar' => 'بلاغة التشبيه و الإستعارة (المكنية و التصريحية)', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'المتتاليات (تعريف المتتالية + طرق توليد متتالية: عبارة الحد العام + علاقة تراجعية)', 'task_type' => 'study'],
                            ['topic_ar' => 'اتجاه تغير متتالية + المتتالية المحدودة + البرهان بالتراجع', 'task_type' => 'study'],
                            ['topic_ar' => 'تقارب و تباعد متتالية + نهاية متتالية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'حفظ درس العقيدة الإسلامية وأثرها على الفرد والمجتمع', 'task_type' => 'memorize'],
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
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'التعرف على جميع منهجيات كتابة مقال فلسفي', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس المشكلة العلمية والإشكالية الفلسفية', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة ملخص للدرس مع أقوال الفلاسفة و آرائهم', 'task_type' => 'study'],
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
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'الإطلاع على وحدة La famiglia', 'task_type' => 'study'],
                            ['topic_ar' => 'حفظ عدد كافي من الجمل و الكلمات الخاصة بالوحدة', 'task_type' => 'memorize'],
                            ['topic_ar' => 'الاطلاع على مختلف الأعياد و المناسبات الإيطالية و الجزائرية', 'task_type' => 'study'],
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
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'حفظ بروز الصراع وتشكل العالم + المصطلحات', 'task_type' => 'memorize'],
                            ['topic_ar' => 'حفظ الشخصيات الأمريكية', 'task_type' => 'memorize'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'فهم وحدة Ancient Civilisations', 'task_type' => 'study'],
                            ['topic_ar' => 'أهم إنجازات الحضارات وأسباب السقوط والانهيار', 'task_type' => 'study'],
                            ['topic_ar' => 'التركيز على أهم المصطلحات كتابة الأفكار وتلخيص الدرس على شكل خرائط ذهنية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'التعرف على جميع منهجيات كتابة مقال فلسفي', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس الإحساس والإدراك مع كتابة ملخص للدرس مع أقوال وآراء الفلاسفة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط لمقالة أساس الإدراك', 'task_type' => 'study'],
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
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'الإعراب اللفظي و الإعراب التقديري', 'task_type' => 'study'],
                            ['topic_ar' => 'الشعر الديني: المديح و الزهد', 'task_type' => 'study'],
                            ['topic_ar' => 'أحكام التمييز و الحال و الفرق بينهما', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'المتتاليات الحسابية', 'task_type' => 'study'],
                            ['topic_ar' => 'خواص المتتالية الحسابية: تعريفها + عبارة الحد العام + العلاقة بين حدين', 'task_type' => 'study'],
                            ['topic_ar' => 'الوسيط الحسابي + اتجاه تغير + حدود متتالية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس العقيدة الإسلامية وأثرها على الفرد والمجتمع', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس وسائل القرآن الكريم في تثبيت العقيدة الإسلامية', 'task_type' => 'memorize'],
                            ['topic_ar' => 'حفظ درس العقل في القرآن الكريم', 'task_type' => 'memorize'],
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
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مخطط لمقالة المقارنة بين العلم والفلسفة', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس الرياضيات مع كتابة ملخص للدرس مع أقوال الفلاسفة وآراء الطرفين', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'Les valeurs des deux points', 'task_type' => 'study'],
                            ['topic_ar' => 'Les visées communicatives', 'task_type' => 'study'],
                            ['topic_ar' => 'Le type de l\'auteur', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'Aggettivi e pronomi possessivi', 'task_type' => 'study'],
                            ['topic_ar' => 'I possessivi con i nomi di parentela', 'task_type' => 'study'],
                            ['topic_ar' => 'حل عدد كافي من التطبيقات', 'task_type' => 'exercise'],
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
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس بروز الصراع وتشكل العالم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار الشخصيات الأمريكية', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس إشكالية التقدم والتخلف + المصطلحات والخرائط', 'task_type' => 'memorize'],
                            ['topic_ar' => 'حفظ تواريخ 1945 - الوحدة 1', 'task_type' => 'memorize'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'درس قواعد: الأزمنة', 'task_type' => 'study'],
                            ['topic_ar' => 'كيفية كتابة فقرة', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول أساس الإدراك', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط عوامل الادراك', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 07 ====================
            [
                'day_number' => 7,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول عوامل الادراك', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط لمقالة التمييز بين الإحساس و الإدراك', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار ت1: بروز الصراع وتشكل العالم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار ج1: إشكالية التقدم والتخلف', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ ت1: مساعي الانفراج الدولي', 'task_type' => 'memorize'],
                            ['topic_ar' => 'تكرار الشخصيات الأمريكية', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة النثر العلمي و النثر العلمي المتأدب', 'task_type' => 'review'],
                            ['topic_ar' => 'المدرسة الكلاسيكية (أدب المنفى)', 'task_type' => 'study'],
                            ['topic_ar' => 'معاني إذا، إذ و إعرابها + تمارين', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار العقيدة الإسلامية وأثرها على الفرد والمجتمع', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار وسائل القرآن الكريم في تثبيت العقيدة الإسلامية', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ الإسلام والرسالات السماوية - كامل', 'task_type' => 'memorize'],
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
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة الشعر الديني: المديح و الزهد', 'task_type' => 'review'],
                            ['topic_ar' => 'المدرسة الرومانسية أدب المهجر (تعريف + خصائص...)', 'task_type' => 'study'],
                            ['topic_ar' => 'الجمل التي لها محل من الإعراب', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'المتتالية الهندسية', 'task_type' => 'study'],
                            ['topic_ar' => 'خواص المتتالية الهندسية: تعريفها + عبارة الحد العام + العلاقة بين حدين', 'task_type' => 'study'],
                            ['topic_ar' => 'الوسيط الهندسي + اتجاه تغير + حدود متتالية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الإسلام والرسالات السماوية - كامل', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس العقل في القرآن الكريم', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس مقاصد الشريعة الإسلامية', 'task_type' => 'memorize'],
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
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول المقارنة بين العلم والفلسفة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط لمقالة أهمية الفلسفة', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'La question de synthèse / de réflexion', 'task_type' => 'study'],
                            ['topic_ar' => 'Le champ lexical', 'task_type' => 'study'],
                            ['topic_ar' => 'La nominalisation', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'Aggettivi e pronomi interrogativi ed esclamativi', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة فقرة حول الفرق بين العائلة الإيطالية والجزائرية', 'task_type' => 'study'],
                            ['topic_ar' => 'وصف العائلة والفرق بين الأعياد و المناسبات الإيطالية و الجزائرية', 'task_type' => 'study'],
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
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس مساعي الانفراج الدولي', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1945 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ الشخصيات السوفياتية', 'task_type' => 'memorize'],
                            ['topic_ar' => 'حفظ درس المبادلات والتنقلات في العالم + المصطلحات والخرائط', 'task_type' => 'memorize'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'فهم درس After /before/until/as soon as بتمارين', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس Concession بتمارين', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول التمييز بين الإحساس والادراك', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس اللغة والفكر مع كتابة ملخص للدرس مع أقوال وآراء الفلاسفة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط علاقة اللغة بالفكر', 'task_type' => 'study'],
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
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'المدرسة الرومانسية أدب المهجر 02', 'task_type' => 'study'],
                            ['topic_ar' => 'عوامل الهجرة مواضيع أدب المهجر كالشوق إلى الوطن والدعوة إلى التأمل في الطبيعة', 'task_type' => 'study'],
                            ['topic_ar' => 'مراجعة المدرسة الرومانسية أدب المهجر', 'task_type' => 'review'],
                            ['topic_ar' => 'الجمل التي ليس لها محل من الإعراب', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل 3 تمارين حول المتتاليات', 'task_type' => 'exercise'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس وسائل القرآن الكريم في تثبيت العقيدة الإسلامية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الإسلام والرسالات السماوية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس العقل في القرآن الكريم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس مقاصد الشريعة الإسلامية', 'task_type' => 'review'],
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
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول أهمية الفلسفة', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس اللغة والفكر مع كتابة ملخص للدرس مع أقوال وآراء الفلاسفة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط علاقة اللغة بالفكر', 'task_type' => 'study'],
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
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'L\'imperfetto - Passato prossimo o imperfetto?', 'task_type' => 'study'],
                            ['topic_ar' => 'Il passato prossimo Ausiliare essere / avere / participi passati irregolari', 'task_type' => 'study'],
                            ['topic_ar' => 'ركز على L\'imperfetto والحالات التي نستعمله فيها والفرق بينه وبين', 'task_type' => 'study'],
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
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس إشكالية التقدم والتخلف', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس مساعي الانفراج الدولي', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس المبادلات والتنقلات في العالم', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ الشخصيات السوفياتية', 'task_type' => 'memorize'],
                            ['topic_ar' => 'تكرار تواريخ 1945 - الوحدة 1', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'فهم درس Past habit / ability / obligation', 'task_type' => 'study'],
                            ['topic_ar' => 'مراجعة « s » & « ed » Final', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول أساس الإدراك', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة مقالة حول علاقة اللغة بالفكر', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط لمقالة علاقة الدال بالمدلول', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 14 ====================
            [
                'day_number' => 14,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول عوامل الادراك', 'task_type' => 'review'],
                            ['topic_ar' => 'قراءة مقالة حول علاقة اللغة بالفكر', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة مقالة حول علاقة الدال بالمدلول', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس بروز الصراع وتشكل العالم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس مساعي الانفراج الدولي', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس المبادلات والتنقلات في العالم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار الشخصيات الأمريكية + السوفياتية', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا 2017 الدورة الأولى', 'task_type' => 'solve'],
                            ['topic_ar' => 'شعبة آداب و فلسفة إيليا أبو ماضي شعر', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'استرجاع درس العقيدة الإسلامية وأثرها على الفرد والمجتمع', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الإسلام والرسالات السماوية - كامل', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس مقاصد الشريعة الإسلامية', 'task_type' => 'review'],
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
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة', 'task_type' => 'review'],
                            ['topic_ar' => 'حل موضوع بكالوريا 2014 شعبة آداب وفلسفة - النويري', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل موضوع بكالوريا 2010 شعبة آداب وفلسفة - البوصيري', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'الموافقات', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'حفظ درس منهج الإسلام في محاربة الانحراف والجريمة', 'task_type' => 'memorize'],
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
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول علاقة الأنا بالغير', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط لمقالة أساس التعرف على الأنا', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'Le renvoi des pronoms', 'task_type' => 'study'],
                            ['topic_ar' => 'les rapports logiques', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'مدخل إلى وحدة L\'ambiente', 'task_type' => 'study'],
                            ['topic_ar' => 'التعرف على عدد من الكلمات الخاصة بالتلوث/ كوكب الأرض و المخاطر التي تهدده', 'task_type' => 'study'],
                            ['topic_ar' => 'l\'imperativo diretto affermativo e negativo (verbi regolari e irregolari)', 'task_type' => 'study'],
                            ['topic_ar' => 'Avverbi di modo in mente', 'task_type' => 'study'],
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
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار تواريخ 1945 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس من الثنائية إلى الأحادية القطبية', 'task_type' => 'memorize'],
                            ['topic_ar' => 'حفظ شخصيات العالم الثالث', 'task_type' => 'memorize'],
                            ['topic_ar' => 'حفظ تواريخ 1947 - الوحدة 1', 'task_type' => 'memorize'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'فهم درس Passive & Active', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة فقرة في الوحدة الأولى', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول التمييز بين الإحساس والادراك', 'task_type' => 'review'],
                            ['topic_ar' => 'قراءة مقالة حول علاقة الدال بالمدلول', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة مخطط لمقالة وظائف اللغة', 'task_type' => 'study'],
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
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'الالتزام + الشعر الاجتماعي', 'task_type' => 'study'],
                            ['topic_ar' => 'تطبيقات حول الإعراب اللفظي و الإعراب التقديري', 'task_type' => 'exercise'],
                            ['topic_ar' => 'موضوع بكالوريا 2012 شعبة آداب و فلسفة', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل 3 تمارين حول الموافقات', 'task_type' => 'exercise'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس منهج الإسلام في محاربة الانحراف والجريمة', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس المساواة أمام أحكام الشريعة الإسلامية', 'task_type' => 'memorize'],
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
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول أهمية الفلسفة', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس اللغة والفكر مع كتابة ملخص للدرس مع أقوال وآراء الفلاسفة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط علاقة اللغة بالفكر', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'Le compte rendu', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'Avverbi di modo in mente', 'task_type' => 'study'],
                            ['topic_ar' => 'Aggettivi e pronomi indefiniti (poco, molto, tanto, troppo, tutto, ogni, qualche, alcuno, nessuno, niente, nulla, qualcuno, ciascuno, ognuno, qualcosa, qualsiasi.)', 'task_type' => 'study'],
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
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس من الثنائية إلى الأحادية القطبية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس شخصيات العالم الثالث', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس تواريخ 1945 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس تواريخ 1947 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس مصادر القوة الاقتصادية للوم.أ', 'task_type' => 'memorize'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'تعلم كيفية الإجابة على أسئلة النص', 'task_type' => 'study'],
                            ['topic_ar' => 'مراجعة', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول وظائف اللغة', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس الشعور واللاشعور مع كتابة ملخص للدرس مع أقوال وآراء الفلاسفة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط لمقالة أساس الحياة النفسية', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 21 ====================
            [
                'day_number' => 21,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول عوامل الادراك', 'task_type' => 'review'],
                            ['topic_ar' => 'قراءة مقالة حول وظائف اللغة', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة مقالة حول أساس الحياة النفسية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس بروز الصراع وتشكل العالم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس مساعي الانفراج الدولي', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس المبادلات والتنقلات في العالم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار الشخصيات الأمريكية + السوفياتية', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'القضية الفلسطينية', 'task_type' => 'study'],
                            ['topic_ar' => 'موضوع بكالوريا 2017 الدورة الثانية', 'task_type' => 'solve'],
                            ['topic_ar' => 'شعبة آداب وفلسفة صلاح عبد الصبور شعر', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس منهج الإسلام في محاربة الانحراف والجريمة', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس المساواة أمام أحكام الشريعة الإسلامية', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس الصحة النفسية والجسمية في القرآن الكريم', 'task_type' => 'memorize'],
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
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'الثورة الجزائرية', 'task_type' => 'study'],
                            ['topic_ar' => 'مراجعة النثر العلمي والنثر العلمي المتأدب', 'task_type' => 'review'],
                            ['topic_ar' => 'أحكام البدل وعطف البيان', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة المتتاليات + الموافقات', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس مقاصد الشريعة الإسلامية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الصحة النفسية والجسمية في القرآن الكريم', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس الإجماع - القياس - المصالح المرسلة', 'task_type' => 'memorize'],
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
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول علاقة الأنا بالغير', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط لمقالة أساس التعرف على الأنا', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'BAC 2021 lettres et philosophie sujet 01', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'Il verbo bisognare alla terza persona + infinito', 'task_type' => 'study'],
                            ['topic_ar' => 'مراجعة كل القواعد التي تم دراستها', 'task_type' => 'review'],
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
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس مساعي الإنفراج الدولي', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس من تبلور الوعي إلى الثورة الجزائرية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار الشخصيات الأمريكية', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس ظاهرة التكتل وأثرها في قوة الاتحاد الأوروبي', 'task_type' => 'memorize'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا حول Ancient Civilizations', 'task_type' => 'solve'],
                            ['topic_ar' => 'مع ضبط الوقت + كتابة المصطلحات الجديدة بعد الحل', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة فقرة حول The factors that threaten our modern civilization', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول أساس الحياة النفسية', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة مخطط لمقالة اللاشعور (نظرية علمية أو فلسفية)', 'task_type' => 'study'],
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
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'موضوع بكالوريا 2011 شعبة آداب وفلسفة عبد السلام حبيب شعر', 'task_type' => 'solve'],
                            ['topic_ar' => 'بلاغة الكناية + المحسنات البديعية', 'task_type' => 'study'],
                            ['topic_ar' => 'أحكام لولا و لوما و لو + إعرابها', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل 2 تمارين حول المتتاليات', 'task_type' => 'exercise'],
                            ['topic_ar' => 'حل 2 تمارين حول الموافقات', 'task_type' => 'exercise'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس وسائل القرآن الكريم في تثبيت العقيدة الإسلامية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس المساواة أمام أحكام الشريعة الإسلامية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الصحة النفسية والجسمية في القرآن الكريم', 'task_type' => 'review'],
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
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول أساس التعرف على الأنا', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس اللغة والفكر مع كتابة ملخص للدرس مع أقوال وآراء الفلاسفة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط علاقة اللغة بالفكر', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'تصحيح موضوع البكالوريا للحصة الماضية', 'task_type' => 'review'],
                            ['topic_ar' => 'مراجعة جميع دروس التي تم دراستها', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'كتابة فقرة تتحدث فيها حول المخاطر التي تهدد كوكب الأرض', 'task_type' => 'study'],
                            ['topic_ar' => 'والحلول المقترحة لحماية الكوكب', 'task_type' => 'study'],
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
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس المبادلات والتنقلات في العالم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس مصادر القوة الاقتصادية للوم.أ', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس من تبلور الوعي إلى الثورة الجزائرية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس ظاهرة التكتل وأثرها في قوة الاتحاد الأوروبي', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا حول Ancient Civilizations', 'task_type' => 'solve'],
                            ['topic_ar' => 'مع ضبط الوقت + كتابة المصطلحات الجديدة بعد الحل', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة فقرة حول The factors that led to the collapse of ancient civilizations', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مخطط أثر المكبوتات على الانسان', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول اللاشعور (نظرية علمية أو فلسفية)', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 28 ====================
            [
                'day_number' => 28,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'فهم درس الذاكرة والخيال مع كتابة ملخص للدرس مع أقوال وآراء الفلاسفة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول اللاشعور (نظرية علمية أو فلسفية)', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول أثر المكبوتات على الانسان', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس إشكالية التقدم والتخلف', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس من تبلور الوعي إلى الثورة الجزائرية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس ظاهرة التكتل وأثرها في قوة الاتحاد الأوروبي', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار شخصيات العالم الثالث', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1947 - الوحدة 1', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'ظاهرة الحزن والألم', 'task_type' => 'study'],
                            ['topic_ar' => 'مراجعة القضية الفلسطينية', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الإسلام والرسالات السماوية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الصحة النفسية والجسمية في القرآن الكريم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الإجماع - القياس - المصالح المرسلة', 'task_type' => 'review'],
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
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مخطط لمقالة قيمة العادة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول طبيعة الذاكرة', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'La cause et la conséquence', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'Combinazioni / I verbi pronominali', 'task_type' => 'study'],
                            ['topic_ar' => 'Il futuro semplice', 'task_type' => 'study'],
                            ['topic_ar' => 'L\'ipotesi della realtà', 'task_type' => 'study'],
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
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس مصادر القوة الاقتصادية للوم.أ', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس ظاهرة التكتل وأثرها في قوة الاتحاد الأوروبي', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس العمل المسلح ورد فعل الاستعمار', 'task_type' => 'memorize'],
                            ['topic_ar' => 'تكرار تواريخ 1956 - 1958 - الوحدة 2', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'فهم محتوى وحدة Ethics in Business', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة الأفكار و تلخيص الوحدة و إستعمال الخرائط الذهنية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول قيمة العادة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط لمقالة طبيعة العادة وعوامل اكتسابها', 'task_type' => 'study'],
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
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'الرمز والأسطورة', 'task_type' => 'study'],
                            ['topic_ar' => 'تطبيقات حول الإعراب اللفظي و الإعراب التقديري', 'task_type' => 'exercise'],
                            ['topic_ar' => 'مراجعة ظاهرة الحزن والألم', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'الدالة كثيرة الحدود', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'حفظ درس القيم في القرآن الكريم', 'task_type' => 'memorize'],
                            ['topic_ar' => 'تكرار درس الوقف في الإسلام', 'task_type' => 'review'],
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
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول قيمة العادة', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة مقالة حول طبيعة العادة وعوامل اكتسابها', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس الحرية والمسؤولية مع كتابة ملخص للدرس مع أقوال وآراء الفلاسفة', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'Discours direct et indirect', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'Espressioni colloquiali', 'task_type' => 'study'],
                            ['topic_ar' => '(Aproposito, ci credo bene, ma tu guarda, non vedo l\'ora, com no!)', 'task_type' => 'study'],
                            ['topic_ar' => 'Il condizionale presente', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم فقرة Aprender idioma + مصطلحات', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس القواعد El gerundio', 'task_type' => 'study'],
                            ['topic_ar' => 'ودرس El gerundio (perífrasis)', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 33 ====================
            [
                'day_number' => 33,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول وظائف اللغة', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس الحرية والمسؤولية مع كتابة ملخص للدرس مع أقوال وآراء الفلاسفة', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'La voix active et passive', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'I verbi: volerci / metterci', 'task_type' => 'study'],
                            ['topic_ar' => '(Il tempo che ci vuole... Il tempo che ci metto...)', 'task_type' => 'study'],
                            ['topic_ar' => 'L\'uso di "ci" e "ne"', 'task_type' => 'study'],
                            ['topic_ar' => '(ci locativo / ne partitivo)', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم فقرة El buen ciudadano + مصطلحات', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس القواعد Por y Para مع التمارين', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم فقرة Los derechos del niño + مصطلحات', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 34 ====================
            [
                'day_number' => 34,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس العمل المسلح ورد فعل الاستعمار', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1956 - 1958 - الوحدة 2', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس العلاقة بين السكان والتنمية في شرق وجنوب شرق آسيا', 'task_type' => 'memorize'],
                            ['topic_ar' => 'حفظ الشخصيات الجزائرية', 'task_type' => 'memorize'],
                            ['topic_ar' => 'حفظ تواريخ 1949 - الوحدة 1', 'task_type' => 'memorize'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'فهم محتوى وحدة Ethics in Business', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة الأفكار و تلخيص الوحدة و إستعمال الخرائط الذهنية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مخطط لمقالة عوامل الابداع', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول طبيعة الذاكرة', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس العادة والإرادة مع كتابة ملخص للدرس مع أقوال وآراء الفلاسفة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط لمقالة قيمة العادة', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 35 ====================
            [
                'day_number' => 35,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مخطط لمقالة قيمة النسيان', 'task_type' => 'study'],
                            ['topic_ar' => 'قراءة مقالة حول أساس الإدراك', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة مخطط لمقالة طبيعة العادة وعوامل اكتسابها', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول قيمة العادة', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس العمل المسلح ورد فعل الاستعمار', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس العلاقة بين السكان والتنمية في شرق وجنوب شرق آسيا', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس استعادة السيادة الوطنية وبناء الدولة الجزائرية', 'task_type' => 'memorize'],
                            ['topic_ar' => 'تكرار تواريخ 1949 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1956 - 1958 - الوحدة 2', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة المدرسة الرومانسية أدب المهجر', 'task_type' => 'review'],
                            ['topic_ar' => 'موضوع بكالوريا 2012 شعبة آداب و فلسفة نزار قباني شعر', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس القيم في القرآن الكريم', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس الوقف في الإسلام', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 36 ====================
            [
                'day_number' => 36,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'الرمز والأسطورة', 'task_type' => 'study'],
                            ['topic_ar' => 'تطبيقات حول الإعراب اللفظي والإعراب التقديري', 'task_type' => 'exercise'],
                            ['topic_ar' => 'مراجعة ظاهرة الحزن والألم', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة لكل الدروس (قوانين + الأسئلة المتكررة)', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس وسائل القرآن الكريم في تثبيت العقيدة الإسلامية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الإجماع - القياس - المصالح المرسلة', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الوقف في الإسلام', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 37 ====================
            [
                'day_number' => 37,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول عوامل الادراك', 'task_type' => 'review'],
                            ['topic_ar' => 'قراءة مقالة حول وظائف اللغة', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة مخطط لمقالة الحرية والحتمية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'La voix active et passive', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'I verbi: volerci / metterci', 'task_type' => 'study'],
                            ['topic_ar' => '(Il tempo che ci vuole... Il tempo che ci metto...)', 'task_type' => 'study'],
                            ['topic_ar' => 'L\'uso di "ci" e "ne"', 'task_type' => 'study'],
                            ['topic_ar' => '(ci locativo / ne partitivo)', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم فقرة El buen ciudadano + مصطلحات', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس القواعد Por y Para مع التمارين', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم فقرة Los derechos del niño + مصطلحات', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 38 ====================
            [
                'day_number' => 38,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس من تبلور الوعي إلى الثورة الجزائرية', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ شخصيات العالم الثالث', 'task_type' => 'memorize'],
                            ['topic_ar' => 'حفظ تواريخ 1947 - الوحدة 1', 'task_type' => 'memorize'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'فهم درس Types of conditionals 4', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس Provided that/ providing that/ as long as بتمارين', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مخطط لمقالة طبيعة الفعل الإرادي ومميزاته', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول طبيعة العادة وعوامل اكتسابها', 'task_type' => 'study'],
                            ['topic_ar' => 'قراءة مقالة حول قيمة العادة', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 39 ====================
            [
                'day_number' => 39,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'بلاغة المجاز المرسل و العقلي', 'task_type' => 'study'],
                            ['topic_ar' => 'الأساليب البلاغية', 'task_type' => 'study'],
                            ['topic_ar' => 'مراجعة النثر العلمي و النثر العلمي المتأدب', 'task_type' => 'review'],
                            ['topic_ar' => 'الهمزة المزيدة في أول الأمر خاص بلغات.أ', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل تمرين حول المتتاليات', 'task_type' => 'exercise'],
                            ['topic_ar' => 'حل تمرين حول الموافقات', 'task_type' => 'exercise'],
                            ['topic_ar' => 'حل تمرين حول الدالة كثيرة الحدود', 'task_type' => 'exercise'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس المساواة أمام أحكام الشريعة الإسلامية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس القيم في القرآن الكريم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الوقف في الإسلام', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 40 ====================
            [
                'day_number' => 40,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول الحرية والحتمية', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط لمقالة لمشكلة الجزاء', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس العنف والتسامح مع كتابة ملخص للدرس مع أقوال وآراء الفلاسفة', 'task_type' => 'study'],
                            ['topic_ar' => 'حل موضوع بكالوريا BAC 2020 scientifique sujet 01', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'كتابة فقرة يقارن فيها بين المطبخ الإيطالي والجزائري', 'task_type' => 'study'],
                            ['topic_ar' => 'مركزا على العادات الغذائية', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم فقرة Medio ambiente مع المصطلحات', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم الدرس La oración sujeto impersonal مع التمارين', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 41 ====================
            [
                'day_number' => 41,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس العلاقة بين السكان والتنمية في شرق وجنوب شرق آسيا', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس استعادة السيادة الوطنية وبناء الدولة الجزائرية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الاقتصاد الجزائري في العالم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1947 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ الشخصيات الفرنسية', 'task_type' => 'memorize'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'درس Expressing advice + It\'s high time / It\'s about time', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس So..that / Such...that بتمارين', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مخطط لمقالة التكيف مع العالم الخارجي، هل يتم بالعادة أو الإرادة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول طبيعة الفعل الإرادي ومميزاته', 'task_type' => 'study'],
                            ['topic_ar' => 'قراءة مقالة حول طبيعة العادة وعوامل اكتسابها', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 42 ====================
            [
                'day_number' => 42,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول علاقة اللغة بالفكر', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة مخطط لمقالة المقارنة بين العادة والإرادة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول التكيف مع العالم الخارجي، هل يتم بالعادة أو الإرادة', 'task_type' => 'study'],
                            ['topic_ar' => 'قراءة مقالة حول طبيعة الفعل الإرادي ومميزاته', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس مصادر القوة الاقتصادية للوم.أ', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس ظاهرة التكتل وأثرها في قوة الاتحاد الأوروبي', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس العمل المسلح ورد فعل الاستعمار', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس استعادة السيادة الوطنية وبناء الدولة الجزائرية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الشخصيات الفرنسية', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ الشخصيات الجزائرية', 'task_type' => 'memorize'],
                        ]
                    ],
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة المدرسة الكلاسيكية (أدب المنفى)', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس منهج الإسلام في محاربة الانحراف والجريمة', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس المساواة أمام أحكام الشريعة الإسلامية', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس الصحة النفسية والجسمية في القرآن الكريم', 'task_type' => 'memorize'],
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
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'القصة والمسرحية', 'task_type' => 'study'],
                            ['topic_ar' => 'معاني الأحرف المشبهة بالفعل (إن و أخواتها) خاص بـآ.ف', 'task_type' => 'study'],
                            ['topic_ar' => 'مراجعة الثورة الجزائرية', 'task_type' => 'review'],
                            ['topic_ar' => 'المسند والمسند إليه خاص بـآ.ف', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'الدالة التناظرية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس مقاصد الشريعة الإسلامية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس مدخل إلى علم الميراث', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس الورثة وطرق ميراثهم', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 44 ====================
            [
                'day_number' => 44,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول مشكلة الجزاء', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط لمقالة العنف والتسامح', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس العولمة مع كتابة ملخص للدرس مع أقوال وآراء الفلاسفة', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع BAC 2021 langues sujet 01', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'مدخل إلى الوحدة La moda italiana', 'task_type' => 'study'],
                            ['topic_ar' => 'يحاول التلميذ تعلم أسماء الملابس و الماركات الإيطالية المشهورة (ملابس/اكسسوارات...)', 'task_type' => 'study'],
                            ['topic_ar' => 'Aggettivi e pronomi dimostrativi', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم فقرة La lectura مع المصطلحات', 'task_type' => 'study'],
                            ['topic_ar' => 'حل موضوع بكالوريا كامل', 'task_type' => 'solve'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 45 ====================
            [
                'day_number' => 45,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس بروز الصراع وتشكل العالم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الاقتصاد الجزائري في العالم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار الشخصيات الأمريكية', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس تأثير الجزائر وإسهامها في حركات التحرر', 'task_type' => 'memorize'],
                            ['topic_ar' => 'حفظ تواريخ 1950 - 1956 - الوحدة', 'task_type' => 'memorize'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'فهم درس Wish بتمارين', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس prefix / Root/ Suffix بتمارين', 'task_type' => 'study'],
                            ['topic_ar' => 'يمكن الإستعانة بمواضيع البكالوريا و حل مواضيع التي تحتوي على هذا الجدول', 'task_type' => 'study'],
                            ['topic_ar' => '(حل التمرين الجدول فقط)', 'task_type' => 'exercise'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول علاقة الدال بالمدلول', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة مقالة حول المقارنة بين العادة والإرادة', 'task_type' => 'study'],
                            ['topic_ar' => 'قراءة مقالة حول التكيف مع العالم الخارجي، هل يتم بالعادة أو الإرادة', 'task_type' => 'review'],
                            ['topic_ar' => 'فهم درس الأخلاق مع كتابة ملخص للدرس مع أقوال وآراء الفلاسفة', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 46 ====================
            [
                'day_number' => 46,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'الجموع في اللغة العربية خاص بـآ.ف', 'task_type' => 'study'],
                            ['topic_ar' => 'الفضلة و إعرابها', 'task_type' => 'study'],
                            ['topic_ar' => 'العروض: بحر الوافر، الكامل، الهزج، الرجز، الرمل، المتقارب، المتدارك، الطويل', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل 2 تمارين حول المتتاليات', 'task_type' => 'exercise'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار مدخل إلى علم الميراث', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الورثة وطرق ميراثهم', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 47 ====================
            [
                'day_number' => 47,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول العنف والتسامح', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط لمقالة قيمة العولمة (سلبية أو إيجابية)', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'BAC 2018 langues sujet 01', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'حل تمارين في درس Aggettivi e pronomi dimostrativi', 'task_type' => 'exercise'],
                            ['topic_ar' => 'مراجعة مصطلحات الوحدة + القواعد + مراجعة أفكار فقرات الوحدة الأولى', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 48 ====================
            [
                'day_number' => 48,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
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
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'فهم درس Verb/ Noun/ Adj بتمارين', 'task_type' => 'study'],
                            ['topic_ar' => 'يمكن الإستعانة بمواضيع البكالوريا وحل مواضيع التي تحتوي على هذا الجدول', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول وظائف اللغة', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة مخطط لمقالة طبيعة الأخلاق', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 49 ====================
            [
                'day_number' => 49,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول عوامل الادراك', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة مخطط لمقالة أساس ومعيار الأخلاق', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول طبيعة الأخلاق', 'task_type' => 'study'],
                            ['topic_ar' => 'قراءة مقالة حول طبيعة الأخلاق', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس تأثير الجزائر وإسهامها في حركات التحرر', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس العالم الثالث بين تراجع الاستعمار التقليدي واستمرارية حركات التحرر', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ وش دائرة الجزائر في حوض البحر الأبيض المتوسط', 'task_type' => 'memorize'],
                            ['topic_ar' => 'تكرار الشخصيات الفرنسية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ السكان والتنمية في الهند + التنمية في البرازيل', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس العالم الثالث', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار سنوات 1945 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1961-1963 - الوحدة 1', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة المقال', 'task_type' => 'review'],
                            ['topic_ar' => 'مراجعة بلاغة الكناية', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الصحة النفسية والجسمية في القرآن الكريم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس مدخل إلى علم الميراث', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الورثة وطرق ميراثهم', 'task_type' => 'review'],
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
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع موضوع بكالوريا 2022', 'task_type' => 'solve'],
                            ['topic_ar' => 'شعبة لغات أجنبية محمود سامي البارودي شعر', 'task_type' => 'study'],
                            ['topic_ar' => 'حل موضوع بكالوريا 2019 شعبة لغات أجنبية', 'task_type' => 'solve'],
                            ['topic_ar' => 'نازك الملائكة شعر', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'الاحتمالات', 'task_type' => 'study'],
                            ['topic_ar' => 'التجربة العشوائية + مجموع الامكانيات + الحادثة + طرق العد', 'task_type' => 'study'],
                            ['topic_ar' => '(قائمة، ترتيبة، تبديلة، توفيقة) + كيفية الحساب بالآلة الحاسبة + الأمل الرياضي', 'task_type' => 'study'],
                            ['topic_ar' => 'و التباين و الانحراف المعياري لمتغير عشوائي + دستور ثنائي الحد', 'task_type' => 'study'],
                            ['topic_ar' => '+ دستور الاحتمالات الكلية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الإسلام والرسالات السماوية - الدين عند الله', 'task_type' => 'review'],
                            ['topic_ar' => 'الإسلام + اليهودية + النصرانية + الإسلام الرسالة الخاتمة', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 51 ====================
            [
                'day_number' => 51,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مخطط لمقالة حول حقيقة العولمة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول قيمة العولمة (سلبية أو إيجابية)', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'La structure d\'un texte argumentatif', 'task_type' => 'study'],
                            ['topic_ar' => 'Le champ lexical de l\'argumentation', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'درس I gradi dell\'aggettivo', 'task_type' => 'study'],
                            ['topic_ar' => 'حل موضوع بكالوريا 2018', 'task_type' => 'solve'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 52 ====================
            [
                'day_number' => 52,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس مساعي الانفراج الدولي', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس العلاقة بين السكان والتنمية في شرق وجنوب شرق آسيا', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ تواريخ 1956 - 1958 - الوحدة 2', 'task_type' => 'memorize'],
                            ['topic_ar' => 'تكرار درس العالم الثالث بين تراجع الاستعمار التقليدي واستمرارية حركات التحرر', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'فهم درس Expressing cause & result & purpose بتمارين', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس Unless بتمارين', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول علاقة اللغة بالفكر', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة مقالة حول أساس ومعيار الأخلاق', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس العدالة مع كتابة ملخص للدرس مع أقوال وآراء الفلاسفة', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 53 ====================
            [
                'day_number' => 53,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا 2017 الدورة الأولى', 'task_type' => 'solve'],
                            ['topic_ar' => 'شعبة لغات أجنبية - زيادة مقال', 'task_type' => 'study'],
                            ['topic_ar' => 'حل موضوع بكالوريا 2022', 'task_type' => 'solve'],
                            ['topic_ar' => 'شعبة آداب وفلسفة شوقي ضيف مقال', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل 3 تمارين حول الاحتمالات', 'task_type' => 'exercise'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس القيم في القرآن الكريم', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس الربا وأحكامه', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 54 ====================
            [
                'day_number' => 54,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول أصل المفاهيم الرياضية', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس الرياضيات مع كتابة ملخص للدرس مع أقوال وآراء الفلاسفة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط لمقالة أصل المفاهيم الرياضية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'Le lexique de l\'argumentation', 'task_type' => 'study'],
                            ['topic_ar' => 'Les articulateurs', 'task_type' => 'study'],
                            ['topic_ar' => 'La visée communicative', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'حل تمارين حول درس I gradi dell\'aggettivo', 'task_type' => 'exercise'],
                            ['topic_ar' => 'كتابة فقرة حول ما تم دراسته في وحدة المودا الإيطالية', 'task_type' => 'study'],
                            ['topic_ar' => 'حل موضوع بكالوريا 2019', 'task_type' => 'solve'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 55 ====================
            [
                'day_number' => 55,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس المبادلات والتنقلات في العالم', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس القضية الفلسطينية', 'task_type' => 'memorize'],
                            ['topic_ar' => 'تكرار درس الجزائر في حوض البحر الأبيض المتوسط', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس العالم الثالث بين تراجع الاستعمار التقليدي', 'task_type' => 'review'],
                            ['topic_ar' => 'واستمرارية حركات التحرر', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ تواريخ 1972 - 1991 - الوحدة 1', 'task_type' => 'memorize'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا حول وحدة Ethics in Business', 'task_type' => 'solve'],
                            ['topic_ar' => 'كتابة فقرة حول How to fight corruption', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول وظائف اللغة', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة مخطط لمقالة طبيعة الأخلاق', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 56 ====================
            [
                'day_number' => 56,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مخطط لمقالة التفاوت والمساواة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول الحقوق والواجبات', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس إشكالية التقدم والتخلف', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس استعادة السيادة الوطنية وبناء الدولة الجزائرية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الاقتصاد الجزائري في العالم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس العالم الثالث بين تراجع الاستعمار التقليدي', 'task_type' => 'review'],
                            ['topic_ar' => 'واستمرارية حركات التحرر', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1972 - 1991 - الوحدة 1', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة للدروس', 'task_type' => 'review'],
                            ['topic_ar' => 'مراجعة شاملة للقواعد', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الوقف في الإسلام', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الربا وأحكامه', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
        ];
    }

    /**
     * Batch 5: Days 57-70 (Weeks 9-10)
     */
    private function getBatch5Days(): array
    {
        return [
            // ==================== Day 57 ====================
            [
                'day_number' => 57,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا 2022', 'task_type' => 'solve'],
                            ['topic_ar' => 'شعبة آداب وفلسفة ابن نباتة المصري شعر', 'task_type' => 'study'],
                            ['topic_ar' => 'حل موضوع بكالوريا 2022', 'task_type' => 'solve'],
                            ['topic_ar' => 'شعبة لغات أجنبية القزويني نثر', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'الإحصاء', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الورثة وطرق ميراثهم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس منهج الإسلام في محاربة الانحراف والجريمة', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 58 ====================
            [
                'day_number' => 58,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول أصل المفاهيم الرياضية', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط لمقالة اليقين الرياضي', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط لمقالة مقارنة بين الرياضيات الكلاسيكية والرياضيات المعاصرة', 'task_type' => 'study'],
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
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'مدخل للوحدة I mezzi di diffusione 05', 'task_type' => 'study'],
                            ['topic_ar' => 'حفظ أكبر عدد من الكلمات و الجمل التي تتحدث عن التكنولوجيا', 'task_type' => 'memorize'],
                            ['topic_ar' => 'و وسائل الاتصال الحديثة و التحدث أيضا عن إيجابياتها و سلبياتها', 'task_type' => 'study'],
                            ['topic_ar' => 'حل موضوع بكالوريا 2020', 'task_type' => 'solve'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 59 ====================
            [
                'day_number' => 59,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس تأثير الجزائر وإسهامها في حركات التحرر', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس السكان والتنمية في الهند + التنمية في البرازيل', 'task_type' => 'memorize'],
                            ['topic_ar' => 'تكرار درس القضية الفلسطينية', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ تواريخ 1961-1963 - الوحدة 1', 'task_type' => 'memorize'],
                            ['topic_ar' => 'تكرار تواريخ 1972 - 1991 - الوحدة 1', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا حول وحدة Ethics in Business Child labour', 'task_type' => 'solve'],
                            ['topic_ar' => 'كتابة فقرة حول Causes of Child labour + How to eradicate it', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول التفاوت والمساواة', 'task_type' => 'study'],
                            ['topic_ar' => 'قراءة مقالة الحقوق والواجبات', 'task_type' => 'review'],
                            ['topic_ar' => 'فهم درس الأسرة مع كتابة ملخص للدرس مع أقوال وآراء الفلاسفة', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 60 ====================
            [
                'day_number' => 60,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'موضوع بكالوريا 2011 للشعب العلمية مفدي زكريا', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل موضوع بكالوريا 2019', 'task_type' => 'solve'],
                            ['topic_ar' => 'شعبة آداب وفلسفة أحمد أمين مقال', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل 3 تمارين حول الإحصاء', 'task_type' => 'exercise'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس العقل في القرآن الكريم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الربا وأحكامه', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس من المعاملات المالية الجائزة', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 61 ====================
            [
                'day_number' => 61,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول اليقين الرياضي', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة مقارنة بين الرياضيات الكلاسيكية والرياضيات المعاصرة', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'Le lexique de l\'argumentation', 'task_type' => 'study'],
                            ['topic_ar' => 'Les articulateurs', 'task_type' => 'study'],
                            ['topic_ar' => 'La visée communicative', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'Espressioni', 'task_type' => 'study'],
                            ['topic_ar' => 'al volo, come non mai, lascia stare, lascia perdere, che sfiga, come mai', 'task_type' => 'study'],
                            ['topic_ar' => 'L\'uso di "meno", espressioni con "meno"', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم محتوى الوحدة الثالثة Ambito cientifico', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم فقرة La tecnología مع المصطلحات', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس القواعد La voz passiva y activa', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 62 ====================
            [
                'day_number' => 62,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار من الثنائية إلى الأحادية القطبية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار السكان والتنمية في الهند + التنمية في البرازيل', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ الشخصيات الجزائرية', 'task_type' => 'memorize'],
                            ['topic_ar' => 'تكرار تواريخ 1949 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1961-1963 - الوحدة 1', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا حول وحدة Ethics in Business', 'task_type' => 'solve'],
                            ['topic_ar' => 'كتابة فقرة حول How to fight corruption', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول التمييز بين الإحساس والادراك', 'task_type' => 'review'],
                            ['topic_ar' => 'قراءة مقالة التفاوت والمساواة', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة مخطط لمقالة وجود الأسرة', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 63 ====================
            [
                'day_number' => 63,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول أساس الإدراك', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة مخطط لمقالة وظائف الأسرة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول وجود الأسرة', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس السكان والتنمية في الهند + التنمية في البرازيل', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار شخصيات العالم الثالث', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1945 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1961-1963 - الوحدة 2', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة للدروس والقواعد', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس المساواة أمام أحكام الشريعة الإسلامية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس مدخل إلى علم الميراث', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس من المعاملات المالية الجائزة', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 64 ====================
            [
                'day_number' => 64,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'موضوع بكالوريا 2021', 'task_type' => 'solve'],
                            ['topic_ar' => 'شعبة لغات أجنبية فدوى طوقان شعر', 'task_type' => 'study'],
                            ['topic_ar' => 'موضوع بكالوريا 2019', 'task_type' => 'solve'],
                            ['topic_ar' => 'شعبة آداب و فلسفة سليمان العيسى شعر', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة', 'task_type' => 'review'],
                            ['topic_ar' => '(تنظيم الملخصات والقوانين وأيضا الأسئلة المتكررة وطرق الإجابة عليها)', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'حفظ درس الحرية الشخصية ومدى ارتباطها بحقوق الانسان', 'task_type' => 'memorize'],
                            ['topic_ar' => 'تكرار درس الإجماع - القياس - المصالح المرسلة', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 65 ====================
            [
                'day_number' => 65,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'فهم درس علوم المادة الجامدة وعلوم المادة الحية مع كتابة', 'task_type' => 'study'],
                            ['topic_ar' => 'ملخص للدرس مع أقوال وآراء الفلاسفة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط لمقال الفرضية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'Le compte rendu du texte argumentatif', 'task_type' => 'study'],
                            ['topic_ar' => 'la structure d\'un texte exhortatif', 'task_type' => 'study'],
                            ['topic_ar' => 'les verbes de modalité', 'task_type' => 'study'],
                            ['topic_ar' => 'les verbes performatifs', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'مراجعة لكل الدروس', 'task_type' => 'review'],
                            ['topic_ar' => 'فهم فقرة El mejor invento مع المصطلحات', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس القواعد La oración concesiva مع التمارين', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 66 ====================
            [
                'day_number' => 66,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الجزائر في حوض البحر الأبيض المتوسط', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس القضية الفلسطينية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1947 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1943-1947 - الوحدة 2', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ تواريخ 1960 - 1961 - الوحدة 2', 'task_type' => 'memorize'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'فهم محتوى وحدة Education', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة الأفكار و تلخيص الوحدة بإستعمال الخرائط الذهنية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول التمييز بين الإحساس والادراك', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة مقالة وظائف الأسرة', 'task_type' => 'study'],
                            ['topic_ar' => 'قراءة مقالة وجود الأسرة', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 67 ====================
            [
                'day_number' => 67,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'موضوع بكالوريا 2017 الدورة الثانية', 'task_type' => 'solve'],
                            ['topic_ar' => 'شعبة لغات أجنبية أمل دنقل شعر', 'task_type' => 'study'],
                            ['topic_ar' => 'موضوع بكالوريا 2020 شعبة لغات أجنبية', 'task_type' => 'solve'],
                            ['topic_ar' => 'توفيق الحكيم مقال', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2017 - موضوع 01', 'task_type' => 'solve'],
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

            // ==================== Day 68 ====================
            [
                'day_number' => 68,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مخطط لمقال الاستقراء', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول الفرضية', 'task_type' => 'study'],
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
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'حل تمارين في درس Aggettivi e pronomi dimostrativi', 'task_type' => 'exercise'],
                            ['topic_ar' => 'فهم فقرة El móvil مع المصطلحات', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس القواعد Los verbos de opinión مع التمارين', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 69 ====================
            [
                'day_number' => 69,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الجزائر في حوض البحر الأبيض المتوسط', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس القضية الفلسطينية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1947 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1943-1947 - الوحدة 2', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ تواريخ 1960 - 1961 - الوحدة 2', 'task_type' => 'memorize'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'فهم درس Expressing similarities and differences بتمارين', 'task_type' => 'study'],
                            ['topic_ar' => 'اكتساب مفردات جديدة خاصة بالوحدة', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة وظائف الأسرة', 'task_type' => 'review'],
                            ['topic_ar' => 'فهم درس الأنظمة الاقتصادية مع كتابة ملخص للدرس مع أقوال وآراء الفلاسفة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط لمقالة الشغل', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 70 ====================
            [
                'day_number' => 70,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مخطط لمقالة الاقتصاد الأمثل', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول الشغل', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس علوم المادة الجامدة والمادة الحية مع كتابة', 'task_type' => 'study'],
                            ['topic_ar' => 'ملخص للدرس مع أقوال وآراء الفلاسفة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط ومقالة حول التجربة والعلم', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس مصادر القوة الاقتصادية للوم.أ', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس ظاهرة التكتل وأثرها في قوة الاتحاد الأوروبي', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس العمل المسلح ورد فعل الاستعمار', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1972 - 1991 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1943-1947 - الوحدة 2', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1960 - 1961 - الوحدة 2', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة للدروس والقواعد', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الصحة النفسية والجسمية في القرآن الكريم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الحرية الشخصية ومدى ارتباطها بحقوق الانسان', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
        ];
    }

    /**
     * Batch 6: Days 71-84 (Weeks 11-12)
     */
    private function getBatch6Days(): array
    {
        return [
            // ==================== Day 71 ====================
            [
                'day_number' => 71,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'موضوع بكالوريا 2018', 'task_type' => 'solve'],
                            ['topic_ar' => 'شعبة لغات أجنبية أحمد شوقي شعر', 'task_type' => 'study'],
                            ['topic_ar' => 'موضوع بكالوريا 2014', 'task_type' => 'solve'],
                            ['topic_ar' => 'شعبة آداب و فلسفة بلقاسم خمار شعر', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2017 - موضوع 02', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس مقاصد الشريعة الإسلامية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الحرية الشخصية ومدى ارتباطها بحقوق الانسان', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس النسب، التبني، الكفالة', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 72 ====================
            [
                'day_number' => 72,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مخطط لمقالة التجربة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول الاستقراء', 'task_type' => 'study'],
                            ['topic_ar' => 'قراءة مقالة الفرضية', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'Le mode impératif', 'task_type' => 'study'],
                            ['topic_ar' => 'Le rapport logique de but', 'task_type' => 'study'],
                            ['topic_ar' => 'Les valeurs de subjonctif', 'task_type' => 'study'],
                            ['topic_ar' => 'Le compte rendu', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'I pronomi diretti nei tempi semplici, tempi composti', 'task_type' => 'study'],
                            ['topic_ar' => 'e con i verbi modali', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم فقرة Internet مع المصطلحات', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس القواعد La oración causal مع التمارين', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 73 ====================
            [
                'day_number' => 73,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس بروز الصراع وتشكل العالم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس السكان والتنمية في الهند + التنمية في البرازيل', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1950 - 1956 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ تواريخ 1955-1950 - الوحدة 2', 'task_type' => 'memorize'],
                            ['topic_ar' => 'تكرار تواريخ 1960 - 1961 - الوحدة 2', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'فهم درس Asking Questions بتمارين', 'task_type' => 'study'],
                            ['topic_ar' => 'حل موضوع بكالوريا', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول الاقتصاد الأمثل', 'task_type' => 'study'],
                            ['topic_ar' => 'قراءة مقالة الشغل', 'task_type' => 'review'],
                            ['topic_ar' => 'فهم درس الأنظمة السياسية مع كتابة ملخص للدرس مع أقوال وآراء الفلاسفة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط ومقالة حول البيولوجيا', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 74 ====================
            [
                'day_number' => 74,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'موضوع بكالوريا 2014 شعبة لغات أجنبية', 'task_type' => 'solve'],
                            ['topic_ar' => 'أحمد حجازي شعر', 'task_type' => 'study'],
                            ['topic_ar' => 'موضوع بكالوريا 2016', 'task_type' => 'solve'],
                            ['topic_ar' => 'شعبة لغات أجنبية عبد الله الركيبي مقال', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2018 - موضوع 01', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الربا وأحكامه', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس النسب، التبني، الكفالة', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس العلاقات الاجتماعية بين المسلمين وغيرهم', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 75 ====================
            [
                'day_number' => 75,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مخطط لمقالة التجربة والعلم', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول التجربة', 'task_type' => 'study'],
                            ['topic_ar' => 'قراءة مقالة الاستقراء', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا 2019 علميين الموضوع 01', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل موضوع بكالوريا 2018 لغات الموضوع 01', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'مراجعة القواعد و الدروس السابقة', 'task_type' => 'review'],
                            ['topic_ar' => 'فهم زمن El imperativo negativo', 'task_type' => 'study'],
                            ['topic_ar' => 'مراجعة أفكار فقرات الوحدة الثالثة', 'task_type' => 'review'],
                            ['topic_ar' => 'مراجعة دروس القواعد', 'task_type' => 'review'],
                            ['topic_ar' => 'مراجعة مصطلحات الوحدة', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 76 ====================
            [
                'day_number' => 76,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس العلاقة بين السكان والتنمية في شرق وجنوب شرق آسيا', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس القضية الفلسطينية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1949 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1955-1950 - الوحدة 2', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'فهم درس Direct & Indirect Speech بتمارين', 'task_type' => 'study'],
                            ['topic_ar' => 'حل موضوع حول وحدة Ethics in Business', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة الاقتصاد الأمثل', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة مخطط لمقالة الحكم السياسي', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط ومقالة حول علوم النفس', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط ومقالة حول علم الاجتماع', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 77 ====================
            [
                'day_number' => 77,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول عوامل الادراك', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة مقالة حول الحكم السياسي', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط لمقالة الديموقراطية', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار الشخصيات السوفياتية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1955-1950 - الوحدة 2', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1960 - 1961 - الوحدة 2', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس العالم الثالث بين تراجع الاستعمار التقليدي', 'task_type' => 'review'],
                            ['topic_ar' => 'واستمرارية حركات التحرر', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة للدروس والقواعد', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس وسائل القرآن الكريم في تثبيت العقيدة الإسلامية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس العلاقات الاجتماعية بين المسلمين وغيرهم', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ درس خطبة حجة الوداع', 'task_type' => 'memorize'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 78 ====================
            [
                'day_number' => 78,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'موضوع بكالوريا 2010', 'task_type' => 'solve'],
                            ['topic_ar' => 'شعبة لغات أجنبية إليا أبو ماضي شعر', 'task_type' => 'study'],
                            ['topic_ar' => 'موضوع بكالوريا 2015', 'task_type' => 'solve'],
                            ['topic_ar' => 'شعبة لغات أجنبية عبد الوهاب البياتي شعر', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2018 - موضوع 02', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس مدخل الى علم الميراث', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الورثة وطرق ميراثهم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس النسب، التبني، الكفالة', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس خطبة حجة الوداع', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 79 ====================
            [
                'day_number' => 79,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مخطط لمقالة الحتمية واللاحتمية', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول التجربة والعلم', 'task_type' => 'study'],
                            ['topic_ar' => 'قراءة مقالة حول التجربة', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا 2022 علميين الموضوع 01', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل موضوع بكالوريا 2021 لغات الموضوع 02', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'حل تمارين حول درس', 'task_type' => 'exercise'],
                            ['topic_ar' => 'I pronomi diretti nei tempi semplici, tempi composti e con', 'task_type' => 'study'],
                            ['topic_ar' => 'i verbi modali', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة فقرة حول وسائل التواصل و التكنولوجيا الحديثة مع إبراز مميزاتها', 'task_type' => 'study'],
                            ['topic_ar' => 'و إعطاء رأيك فيها', 'task_type' => 'study'],
                            ['topic_ar' => 'حل موضوع بكالوريا 2021', 'task_type' => 'solve'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 80 ====================
            [
                'day_number' => 80,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس مساعي الانفراج الدولي', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار شخصيات العالم الثالث', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1956 - 1958 - الوحدة 2', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1960 - 1961 - الوحدة 2', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بخصوص وحدة Education', 'task_type' => 'solve'],
                            ['topic_ar' => 'كتابة فقرة مقترحة حول', 'task_type' => 'study'],
                            ['topic_ar' => 'Ways to improve our educational system', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مخطط مقالة علاقة سياسية بالأخلاق', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول الديموقراطية', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط لمقالة أساس معيار الحقيقة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول طبيعة الحقيقة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط و مقالة حول عوامل الإبداع الفني', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 81 ====================
            [
                'day_number' => 81,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'موضوع بكالوريا 2017 الدورة الأولى', 'task_type' => 'solve'],
                            ['topic_ar' => 'شعبة لغات أجنبية القشقندي شعر', 'task_type' => 'study'],
                            ['topic_ar' => 'موضوع بكالوريا 2009', 'task_type' => 'solve'],
                            ['topic_ar' => 'شعبة لغات أجنبية محمد باوية شعر', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2019 - موضوع 01', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس القيم في القرآن الكريم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس من المعاملات المالية الجائزة', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الحرية الشخصية ومدى ارتباطها بحقوق الانسان', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 82 ====================
            [
                'day_number' => 82,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول التجربة والعلم', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة مقالة حول الحتمية واللاحتمية', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط لمقالة البيولوجيا', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا 2019 لغات الموضوع 02', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل موضوع بكالوريا 2021 لغات الموضوع 1', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'مدخل للوحدة Lo sport', 'task_type' => 'study'],
                            ['topic_ar' => 'تعلم مصطلحات و جمل حول الرياضة مع التركيز على كرة القدم', 'task_type' => 'study'],
                            ['topic_ar' => 'Pronomi indiretti', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم محتوى الوحدة الرابعة Ambito laboral', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم فقرة El trabajo infantil مع المصطلحات', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس القواعد La oración final', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 83 ====================
            [
                'day_number' => 83,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس المبادلات والتنقلات في العالم', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ الشخصيات الجزائرية', 'task_type' => 'memorize'],
                            ['topic_ar' => 'تكرار تواريخ 1943-1947 - الوحدة 2', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ تواريخ 1962 - الوحدة 2', 'task_type' => 'memorize'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع حول وحدة Ancient Civilizations', 'task_type' => 'solve'],
                            ['topic_ar' => 'كتابة فقرة حول Ancient Civilizations', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول علاقة سياسية بالأخلاق', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس الحقيقة مع كتابة ملخص للدرس مع أقوال وآراء الفلاسفة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول أساس معيار الحقيقة', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس العلوم الإنسانية مع كتابة ملخص للدرس مع أقوال وآراء الفلاسفة', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 84 ====================
            [
                'day_number' => 84,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مخطط لمقالة طبيعة الحقيقة', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس التجربة الفنية مع كتابة ملخص للدرس مع أقوال وآراء الفلاسفة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط لمقالة تبرير الاستقراء', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس إشكالية التقدم والتخلف', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الشخصيات الأمريكية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1961-1963 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1962 - الوحدة 2', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة للدروس والقواعد', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس منهج الإسلام في محاربة الانحراف والجريمة', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الوقف في الإسلام', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس العلاقات الاجتماعية بين المسلمين وغيرهم', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
        ];
    }

    /**
     * Batch 7: Days 85-98 (Weeks 13-14) - FINAL BATCH
     */
    private function getBatch7Days(): array
    {
        return [
            // ==================== Day 85 ====================
            [
                'day_number' => 85,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'حل موضوعين مقترحين / أشبال الأمة', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2019 - موضوع 02', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل بكالوريا 2020 - موضوع 01', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الإجماع - القياس - المصالح المرسلة', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الوقف في الإسلام', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الحرية الشخصية ومدى ارتباطها بحقوق الانسان', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 86 ====================
            [
                'day_number' => 86,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة حول الحتمية واللاحتمية', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة مقالة حول البيولوجيا', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا 2019 لغات الموضوع 02', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل موضوع بكالوريا 2018 لغات الموضوع 2', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'حل تمارين Pronomi indiretti', 'task_type' => 'exercise'],
                            ['topic_ar' => 'مراجعة دروس القواعد', 'task_type' => 'review'],
                            ['topic_ar' => 'مدخل للوحدة La salute 07', 'task_type' => 'study'],
                            ['topic_ar' => 'محاولة حفظ أكبر عدد من الكلمات والجمل المتعلقة بالصحة والطب كأسماء الاختصاصات والأدوات الطبية', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم فقرة Elegir carrera مع المصطلحات', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس Las preposiciones', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 87 ====================
            [
                'day_number' => 87,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الاقتصاد الجزائري في العالم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1945 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1955-1950 - الوحدة 2', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1962 - الوحدة 2', 'task_type' => 'review'],
                            ['topic_ar' => 'حفظ تواريخ 1965 - 1989 - الوحدة', 'task_type' => 'memorize'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بخصوص وحدة Education', 'task_type' => 'solve'],
                            ['topic_ar' => 'كتابة فقرة مقترحة', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة طبيعة الحقيقة', 'task_type' => 'review'],
                            ['topic_ar' => 'قراءة مقالة حول أساس معيار الحقيقة', 'task_type' => 'review'],
                            ['topic_ar' => 'فهم درس الرياضيات مع كتابة ملخص للدرس مع أقوال وآراء الفلاسفة', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول تبرير الاستقراء', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 88 ====================
            [
                'day_number' => 88,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'حل موضوعين مقترحين / أشبال الأمة', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2020 - موضوع 02', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل بكالوريا 2021 - موضوع 01', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الربا وأحكامه', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس من المعاملات المالية الجائزة', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس النسب، التبني، الكفالة', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 89 ====================
            [
                'day_number' => 89,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول المنطق الصوري', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط لمقالة قيمة المنطق الصوري', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا 2020 لغات الموضوع 02', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل موضوع بكالوريا 2021 علميين الموضوع 1', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'Pronomi indiretti con i verbi modali', 'task_type' => 'study'],
                            ['topic_ar' => 'مراجعة دروس القواعد', 'task_type' => 'review'],
                            ['topic_ar' => 'مدخل للوحدة La salute 07', 'task_type' => 'study'],
                            ['topic_ar' => 'محاولة حفظ أكبر عدد من الكلمات والجمل المتعلقة بالصحة والطب كأسماء الاختصاصات والأدوات الطبية', 'task_type' => 'memorize'],
                            ['topic_ar' => 'فهم فقرة Elegir carrera مع المصطلحات', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس Las preposiciones', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 90 ====================
            [
                'day_number' => 90,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس تأثير الجزائر واسهامها في حركات التحرر', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1947 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1972 - 1991 - الوحدة', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1960 - 1961 - الوحدة 2', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1965 - 1989 - الوحدة 2', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع حول وحدة Ethics in Business', 'task_type' => 'solve'],
                            ['topic_ar' => 'مع كتابة الفقرة', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مخطط لمقالة أصل المفاهيم الرياضية', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط و مقالة حول الحتمية و اللاحتمية', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 91 ====================
            [
                'day_number' => 91,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مخطط لمقالة اليقين الرياضي', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول أصل المفاهيم الرياضية', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط لمقالة الفرضية', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مخطط ومقالة حول التاريخ', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس من الثنائية إلى الأحادية القطبية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس استعادة السيادة الوطنية وبناء الدولة الجزائرية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1950 - 1956 - الوحدة 1', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1962 - الوحدة 2', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1965 - 1989 - الوحدة 2', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة للدروس والقواعد', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس العقيدة الإسلامية وأثرها على الفرد والمجتمع', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الورثة وطرق ميراثهم', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 92 ====================
            [
                'day_number' => 92,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'حل مواضيع الباكالوريات السابقة', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل مواضيع أشبال الأمة', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2021 - موضوع 02', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل بكالوريا 2022 - موضوع 01', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار القيم في القرآن الكريم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار خطبة حجة الوداع', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 93 ====================
            [
                'day_number' => 93,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة لكل المقالات', 'task_type' => 'review'],
                            ['topic_ar' => 'فهم درس المنطق الصوري مع كتابة ملخص للدرس مع أقوال الفلاسفة', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا 2020 لغات الموضوع 1', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل موضوع بكالوريا 2015 علميين الموضوع 1', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'كتابة فقرة تتحدث فيها عن رياضتك المفضلة', 'task_type' => 'study'],
                            ['topic_ar' => 'يمكنك أيضا محاولة كتابة فقرة حول الفرق بين الرياضة في إيطاليا و الجزائر', 'task_type' => 'study'],
                            ['topic_ar' => 'Plurali irregolari', 'task_type' => 'study'],
                            ['topic_ar' => 'مع التركيز على تحويل أعضاء الجسم من المفرد الى الجمع', 'task_type' => 'study'],
                            ['topic_ar' => 'L\'imperativo con i pronomi', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم فقرة Mujer y trabajo مع المصطلحات', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس القواعد Comparación irreal', 'task_type' => 'study'],
                            ['topic_ar' => 'فهم درس Pasa al pasado', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 94 ====================
            [
                'day_number' => 94,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار 7 مصادر القوة الاقتصادية للوم.أ', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1965 - 1989 - الوحدة 2', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع حول وحدة Civilizations', 'task_type' => 'solve'],
                            ['topic_ar' => 'مع كتابة الفقرة', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مخطط لمقالة المقارنة - معاصرة أو كلاسيكية', 'task_type' => 'study'],
                            ['topic_ar' => 'كتابة مقالة حول اليقين الرياضي', 'task_type' => 'study'],
                            ['topic_ar' => 'قراءة مقالة أصل المفاهيم الرياضية', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 95 ====================
            [
                'day_number' => 95,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'حل موضوعين مقترحين / أشبال الأمة', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'mathematics',
                        'topics' => [
                            ['topic_ar' => 'حل بكالوريا 2022 - موضوع 02', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الصحة النفسية والجسمية في القرآن الكريم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس مدخل الى علم الميراث', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 96 ====================
            [
                'day_number' => 96,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة لكل المقالات', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'french',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا 2021 علوم الموضوع 2', 'task_type' => 'solve'],
                            ['topic_ar' => 'حل موضوع بكالوريا 2021 آداب وفلسفة الموضوع 1', 'task_type' => 'solve'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بكالوريا', 'task_type' => 'solve'],
                            ['topic_ar' => 'كتابة فقرة تتحدث فيها عن نصائح وإرشادات للمحافظة على', 'task_type' => 'study'],
                            ['topic_ar' => 'سلامة الجسم و صحته كممارسة الرياضة و اتباع حمية غذائية', 'task_type' => 'study'],
                            ['topic_ar' => 'حل مواضيع بكالوريا ومواضيع مقترحة', 'task_type' => 'solve'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 97 ====================
            [
                'day_number' => 97,
                'day_type' => 'review',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس ظاهرة التكتل وأثرها في قوة الاتحاد الأوروبي', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس العالم الثالث بين تراجع الاستعمار التقليدي', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'english',
                        'topics' => [
                            ['topic_ar' => 'حل موضوع بخصوص وحدة Education', 'task_type' => 'solve'],
                            ['topic_ar' => 'كتابة فقرة مقترحة', 'task_type' => 'study'],
                        ]
                    ],
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'كتابة مقالة حول المقارنة - معاصرة أو كلاسيكية', 'task_type' => 'study'],
                            ['topic_ar' => 'قراءة مقالة اليقين الرياضي', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة مقالة حول الفرضية', 'task_type' => 'study'],
                        ]
                    ],
                ]
            ],

            // ==================== Day 98 ====================
            [
                'day_number' => 98,
                'day_type' => 'study',
                'title_ar' => null,
                'subjects' => [
                    [
                        'slug' => 'philosophy',
                        'topics' => [
                            ['topic_ar' => 'قراءة مقالة المقارنة - معاصرة أو كلاسيكية', 'task_type' => 'review'],
                            ['topic_ar' => 'كتابة مقالة حول أصل المفاهيم الرياضية', 'task_type' => 'study'],
                            ['topic_ar' => 'قراءة مقالة حول أصل المفاهيم الرياضية', 'task_type' => 'review'],
                            ['topic_ar' => 'قراءة مقالة الفرضية', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'history-geography',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس من تبلور الوعي الى الثورة الجزائرية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس الجزائر في حوض البحر الأبيض المتوسط', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار حفظ الشخصيات الجزائرية', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ 1955-1950 - الوحدة 2', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار تواريخ الوحدة 3', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'arabic',
                        'topics' => [
                            ['topic_ar' => 'مراجعة شاملة', 'task_type' => 'review'],
                        ]
                    ],
                    [
                        'slug' => 'islamic-education',
                        'topics' => [
                            ['topic_ar' => 'تكرار درس الصحة النفسية والجسمية في القرآن الكريم', 'task_type' => 'review'],
                            ['topic_ar' => 'تكرار درس مدخل الى علم الميراث', 'task_type' => 'review'],
                        ]
                    ],
                ]
            ],
        ];
    }
}
