<?php

require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

// Delete all quizzes from the import (IDs 648-655)
echo "Deleting imported quizzes and their questions..." . PHP_EOL;

DB::beginTransaction();

try {
    // Delete quiz questions first
    $deletedQuestions = App\Models\QuizQuestion::whereIn('quiz_id', [648, 649, 650, 651, 652, 653, 654, 655])->delete();
    echo "Deleted {$deletedQuestions} questions" . PHP_EOL;

    // Delete quizzes
    $deletedQuizzes = App\Models\Quiz::whereIn('id', [648, 649, 650, 651, 652, 653, 654, 655])->delete();
    echo "Deleted {$deletedQuizzes} quizzes" . PHP_EOL;

    // Delete any quiz attempts for these quizzes
    $deletedAttempts = App\Models\QuizAttempt::whereIn('quiz_id', [648, 649, 650, 651, 652, 653, 654, 655])->delete();
    echo "Deleted {$deletedAttempts} attempts" . PHP_EOL;

    DB::commit();
    echo "Done! Quizzes deleted successfully." . PHP_EOL;

} catch (Exception $e) {
    DB::rollBack();
    echo "Error: " . $e->getMessage() . PHP_EOL;
}
