<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('study_sessions', function (Blueprint $table) {
            // Add chapter_id reference
            $table->foreignId('chapter_id')->nullable()->after('subject_id')->constrained()->onDelete('set null');

            // Add content_title field
            $table->string('content_title')->nullable()->after('suggested_content_type');

            // Add completion_percentage field
            $table->integer('completion_percentage')->nullable()->default(0)->after('actual_duration_minutes');

            // Rename priority_level to priority_score
            $table->renameColumn('priority_level', 'priority_score');
        });

        // Update enum values for required_energy_level
        DB::statement("ALTER TABLE study_sessions MODIFY COLUMN required_energy_level ENUM('veryLow', 'low', 'medium', 'high') DEFAULT 'medium'");

        // Update enum values for session_type
        DB::statement("ALTER TABLE study_sessions MODIFY COLUMN session_type ENUM('study', 'revision', 'practice', 'longRevision', 'test') DEFAULT 'study'");

        // Update enum values for status
        DB::statement("ALTER TABLE study_sessions MODIFY COLUMN status ENUM('scheduled', 'inProgress', 'paused', 'completed', 'missed', 'skipped') DEFAULT 'scheduled'");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('study_sessions', function (Blueprint $table) {
            // Remove added fields
            $table->dropForeign(['chapter_id']);
            $table->dropColumn(['chapter_id', 'content_title', 'completion_percentage']);

            // Rename back priority_score to priority_level
            $table->renameColumn('priority_score', 'priority_level');
        });

        // Revert enum values for required_energy_level
        DB::statement("ALTER TABLE study_sessions MODIFY COLUMN required_energy_level ENUM('low', 'medium', 'high') DEFAULT 'medium'");

        // Revert enum values for session_type
        DB::statement("ALTER TABLE study_sessions MODIFY COLUMN session_type ENUM('learning', 'revision', 'practice', 'test') DEFAULT 'learning'");

        // Revert enum values for status
        DB::statement("ALTER TABLE study_sessions MODIFY COLUMN status ENUM('scheduled', 'in_progress', 'completed', 'missed', 'rescheduled') DEFAULT 'scheduled'");
    }
};
