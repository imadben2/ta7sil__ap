<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * Add 'unit_test' session type that was missing from the enum.
     * Required for ContentAllocationService::SESSION_UNIT_TEST
     */
    public function up(): void
    {
        // Add unit_test to the session_type enum
        DB::statement("ALTER TABLE planner_study_sessions MODIFY COLUMN session_type ENUM('study', 'regular', 'revision', 'practice', 'exam', 'longRevision', 'lesson_review', 'exercises', 'topic_test', 'unit_test', 'spaced_review', 'language_daily', 'mock_test') DEFAULT 'study'");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Remove unit_test from the enum (revert to previous state)
        DB::statement("ALTER TABLE planner_study_sessions MODIFY COLUMN session_type ENUM('study', 'regular', 'revision', 'practice', 'exam', 'longRevision', 'lesson_review', 'exercises', 'topic_test', 'spaced_review', 'language_daily', 'mock_test') DEFAULT 'study'");
    }
};
