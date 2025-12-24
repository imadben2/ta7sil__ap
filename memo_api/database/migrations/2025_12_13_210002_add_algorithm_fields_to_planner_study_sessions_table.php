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
        Schema::table('planner_study_sessions', function (Blueprint $table) {
            // Algorithm tracking fields from promt.md
            $table->boolean('is_late')->default(false)->after('is_spaced_review')
                  ->comment('Session was missed and rescheduled');
            $table->boolean('is_mock_test')->default(false)->after('is_late')
                  ->comment('Weekly mock test session');
            $table->boolean('is_language_daily')->default(false)->after('is_mock_test')
                  ->comment('Daily language guarantee session');
            $table->integer('score')->nullable()->after('is_language_daily')
                  ->comment('Test score 0-100 for TOPIC_TEST sessions');
            $table->float('priority_score_calculated')->nullable()->after('score')
                  ->comment('Full priority formula result from promt.md');
            $table->string('subject_category', 20)->nullable()->after('priority_score_calculated')
                  ->comment('Cached subject category for quick access');
            $table->date('due_date')->nullable()->after('subject_category')
                  ->comment('For spaced reviews - the date this session is due');

            // Indexes for algorithm queries
            $table->index(['is_mock_test', 'scheduled_date'], 'idx_mock_tests');
            $table->index(['is_language_daily', 'scheduled_date'], 'idx_language_daily');
            $table->index(['is_late', 'status'], 'idx_late_sessions');
            $table->index(['due_date', 'status'], 'idx_due_sessions');
        });

        // Add new session types to the enum
        // Note: In MySQL, we need to modify the enum. In PostgreSQL, this is different.
        // This is a workaround for MySQL enum modification
        DB::statement("ALTER TABLE planner_study_sessions MODIFY COLUMN session_type ENUM('study', 'regular', 'revision', 'practice', 'exam', 'longRevision', 'lesson_review', 'exercises', 'topic_test', 'spaced_review', 'language_daily', 'mock_test') DEFAULT 'study'");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('planner_study_sessions', function (Blueprint $table) {
            $table->dropIndex('idx_mock_tests');
            $table->dropIndex('idx_language_daily');
            $table->dropIndex('idx_late_sessions');
            $table->dropIndex('idx_due_sessions');
            $table->dropColumn([
                'is_late',
                'is_mock_test',
                'is_language_daily',
                'score',
                'priority_score_calculated',
                'subject_category',
                'due_date',
            ]);
        });

        // Revert enum to original
        DB::statement("ALTER TABLE planner_study_sessions MODIFY COLUMN session_type ENUM('study', 'regular', 'revision', 'practice', 'exam', 'longRevision') DEFAULT 'study'");
    }
};
