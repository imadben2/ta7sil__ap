<?php
/**
 * Delete incorrect Patch 05 data (Days 57-70) for Management-Economics stream
 */

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\DB;

echo "Starting deletion of Patch 05 (Days 57-70) for management-economics stream...\n";

// Get stream ID
$streamId = DB::table('academic_streams')
    ->where('slug', 'management-economics')
    ->value('id');

if (!$streamId) {
    echo "❌ Stream 'management-economics' not found!\n";
    exit(1);
}

echo "✓ Found stream ID: {$streamId}\n";

// Get days 57-70
$days = DB::table('bac_study_days')
    ->where('academic_stream_id', $streamId)
    ->whereBetween('day_number', [57, 70])
    ->get();

echo "✓ Found {$days->count()} days to delete\n";

foreach ($days as $day) {
    echo "\nDeleting Day {$day->day_number}...\n";

    // Get day subjects
    $daySubjects = DB::table('bac_study_day_subjects')
        ->where('bac_study_day_id', $day->id)
        ->get();

    echo "  - {$daySubjects->count()} subject assignments\n";

    // Delete topics for each subject
    foreach ($daySubjects as $daySubject) {
        $topicsDeleted = DB::table('bac_study_day_topics')
            ->where('bac_study_day_subject_id', $daySubject->id)
            ->delete();
        echo "    - Deleted {$topicsDeleted} topics for subject ID {$daySubject->subject_id}\n";
    }

    // Delete day subjects
    $subjectsDeleted = DB::table('bac_study_day_subjects')
        ->where('bac_study_day_id', $day->id)
        ->delete();
    echo "  - Deleted {$subjectsDeleted} subject assignments\n";

    // Delete day
    DB::table('bac_study_days')->where('id', $day->id)->delete();
    echo "  ✓ Day {$day->day_number} deleted\n";
}

echo "\n✅ Deletion complete!\n";

// Verify
$remaining = DB::table('bac_study_days')
    ->where('academic_stream_id', $streamId)
    ->whereBetween('day_number', [57, 70])
    ->count();

echo "\nVerification: {$remaining} days remaining (should be 0)\n";

if ($remaining == 0) {
    echo "✅ All Patch 05 data successfully deleted!\n";
} else {
    echo "⚠️ Warning: {$remaining} days still remain!\n";
}
