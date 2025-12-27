<?php

require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

// First show table structure
echo "Table Structure:\n";
$columns = DB::select("DESCRIBE course_lessons");
foreach($columns as $col) {
    echo "  {$col->Field} ({$col->Type})\n";
}

echo "\n" . str_repeat('=', 100) . "\n\n";

// Get lessons for course 17
$lessons = App\Models\CourseLesson::whereHas('module', function($q) {
    $q->where('course_id', 17);
})->get();

echo "Course 17 Lessons:\n";
echo str_repeat('-', 100) . "\n";

foreach($lessons as $l) {
    echo "ID: {$l->id}\n";
    echo "  video_url: {$l->video_url}\n";
    echo str_repeat('-', 100) . "\n";
}

echo "\nTotal lessons: " . $lessons->count() . "\n";
