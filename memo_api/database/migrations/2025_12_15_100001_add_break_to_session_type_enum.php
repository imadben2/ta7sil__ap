<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * Adds 'break' to the session_type enum to allow break sessions.
     */
    public function up(): void
    {
        // Modify the enum to include 'break'
        DB::statement("ALTER TABLE planner_study_sessions MODIFY COLUMN session_type ENUM('study', 'regular', 'revision', 'practice', 'exam', 'longRevision', 'break', 'lesson_review', 'exercises', 'topic_test', 'spaced_review', 'language_daily', 'mock_test', 'unit_test') DEFAULT 'study'");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Remove 'break' from the enum (this may fail if there are break sessions)
        DB::statement("ALTER TABLE planner_study_sessions MODIFY COLUMN session_type ENUM('study', 'regular', 'revision', 'practice', 'exam', 'longRevision') DEFAULT 'study'");
    }
};
