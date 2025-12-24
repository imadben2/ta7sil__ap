<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\DB;

echo "Fixing Day 57...\n";

$streamId = DB::table('academic_streams')->where('slug', 'management-economics')->value('id');
$subjects = DB::table('subjects')->pluck('id', 'slug')->toArray();

// Insert Day 57 with ONLY accounting, mathematics, french
$dayId = DB::table('bac_study_days')->insertGetId([
    'academic_stream_id' => $streamId,
    'day_number' => 57,
    'day_type' => 'study',
    'title_ar' => null,
    'is_active' => true,
    'created_at' => now(),
    'updated_at' => now(),
]);

// 1. Accounting
$daySubjectId = DB::table('bac_study_day_subjects')->insertGetId([
    'bac_study_day_id' => $dayId,
    'subject_id' => $subjects['accounting'],
    'order' => 1,
    'created_at' => now(),
    'updated_at' => now(),
]);

DB::table('bac_study_day_topics')->insert([
    ['bac_study_day_subject_id' => $daySubjectId, 'topic_ar' => 'مراجعة كل ما درسناه من بداية السنة إلى نهايتها', 'task_type' => 'review', 'order' => 1, 'created_at' => now(), 'updated_at' => now()],
    ['bac_study_day_subject_id' => $daySubjectId, 'topic_ar' => 'وحدها نبدأ في حل وضعيات اليوم', 'task_type' => 'solve', 'order' => 2, 'created_at' => now(), 'updated_at' => now()],
]);

// 2. Mathematics - 5 exercises
$daySubjectId = DB::table('bac_study_day_subjects')->insertGetId([
    'bac_study_day_id' => $dayId,
    'subject_id' => $subjects['mathematics'],
    'order' => 2,
    'created_at' => now(),
    'updated_at' => now(),
]);

DB::table('bac_study_day_topics')->insert([
    ['bac_study_day_subject_id' => $daySubjectId, 'topic_ar' => 'حل موضوع بكالوريا 2020 - تمرين 1', 'task_type' => 'solve', 'order' => 1, 'created_at' => now(), 'updated_at' => now()],
    ['bac_study_day_subject_id' => $daySubjectId, 'topic_ar' => 'حل موضوع بكالوريا 2020 - تمرين 2', 'task_type' => 'solve', 'order' => 2, 'created_at' => now(), 'updated_at' => now()],
    ['bac_study_day_subject_id' => $daySubjectId, 'topic_ar' => 'حل موضوع بكالوريا 2020 - تمرين 3', 'task_type' => 'solve', 'order' => 3, 'created_at' => now(), 'updated_at' => now()],
    ['bac_study_day_subject_id' => $daySubjectId, 'topic_ar' => 'حل موضوع بكالوريا 2020 - تمرين 4', 'task_type' => 'solve', 'order' => 4, 'created_at' => now(), 'updated_at' => now()],
    ['bac_study_day_subject_id' => $daySubjectId, 'topic_ar' => 'حل موضوع بكالوريا 2020 - تمرين 5', 'task_type' => 'solve', 'order' => 5, 'created_at' => now(), 'updated_at' => now()],
]);

// 3. French
$daySubjectId = DB::table('bac_study_day_subjects')->insertGetId([
    'bac_study_day_id' => $dayId,
    'subject_id' => $subjects['french'],
    'order' => 3,
    'created_at' => now(),
    'updated_at' => now(),
]);

DB::table('bac_study_day_topics')->insert([
    ['bac_study_day_subject_id' => $daySubjectId, 'topic_ar' => 'حل موضوع بكالوريا 2019', 'task_type' => 'solve', 'order' => 1, 'created_at' => now(), 'updated_at' => now()],
]);

echo "✅ Day 57 fixed with 3 subjects: accounting, mathematics (5 topics), french\n";
