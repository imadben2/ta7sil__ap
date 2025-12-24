<?php
/**
 * Insert correct Day 57 data
 */

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\DB;

echo "Inserting correct Day 57 data...\n";

$streamId = DB::table('academic_streams')
    ->where('slug', 'management-economics')
    ->value('id');

$subjects = DB::table('subjects')
    ->whereIn('slug', ['accounting', 'mathematics', 'french'])
    ->pluck('id', 'slug')
    ->toArray();

// Day 57 correct data
$dayData = [
    'day_number' => 57,
    'day_type' => 'study',
    'title_ar' => null,
    'subjects' => [
        [
            'slug' => 'accounting',
            'topics' => [
                ['topic_ar' => 'مراجعة كل ما درسناه من بداية السنة إلى نهايتها', 'task_type' => 'review'],
                ['topic_ar' => 'وحدها نبدأ في حل وضعيات اليوم', 'task_type' => 'solve'],
            ]
        ],
        [
            'slug' => 'mathematics',
            'topics' => [
                ['topic_ar' => 'حل موضوع بكالوريا 2020 - تمرين 1، 2، 3، 4، 5', 'task_type' => 'solve'],
                ['topic_ar' => 'مراجعة الدوال اللوغارتمية والأسية', 'task_type' => 'review'],
            ]
        ],
        [
            'slug' => 'french',
            'topics' => [
                ['topic_ar' => 'حل موضوع بكالوريا 2019 كاملا', 'task_type' => 'solve'],
                ['topic_ar' => 'مراجعة تقنيات الكتابة', 'task_type' => 'review'],
            ]
        ],
    ]
];

// Insert day
$dayId = DB::table('bac_study_days')->insertGetId([
    'academic_stream_id' => $streamId,
    'day_number' => $dayData['day_number'],
    'day_type' => $dayData['day_type'],
    'title_ar' => $dayData['title_ar'],
    'is_active' => true,
    'created_at' => now(),
    'updated_at' => now(),
]);

echo "✓ Day 57 created with ID: {$dayId}\n";

// Insert subjects
foreach ($dayData['subjects'] as $order => $subjectData) {
    $subjectSlug = $subjectData['slug'];

    if (!isset($subjects[$subjectSlug])) {
        echo "⚠️  Subject '{$subjectSlug}' not found, skipping...\n";
        continue;
    }

    $daySubjectId = DB::table('bac_study_day_subjects')->insertGetId([
        'bac_study_day_id' => $dayId,
        'subject_id' => $subjects[$subjectSlug],
        'order' => $order + 1,
        'created_at' => now(),
        'updated_at' => now(),
    ]);

    echo "  ✓ Subject '{$subjectSlug}' added\n";

    // Insert topics
    foreach ($subjectData['topics'] as $topicOrder => $topicData) {
        DB::table('bac_study_day_topics')->insert([
            'bac_study_day_subject_id' => $daySubjectId,
            'topic_ar' => $topicData['topic_ar'],
            'task_type' => $topicData['task_type'],
            'order' => $topicOrder + 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        echo "    - Topic: {$topicData['topic_ar']} ({$topicData['task_type']})\n";
    }
}

echo "\n✅ Day 57 inserted successfully!\n";
