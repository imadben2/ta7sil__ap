<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('planner_study_sessions', function (Blueprint $table) {
            // Link to subject_planner_content for curriculum-based sessions
            $table->foreignId('subject_planner_content_id')
                  ->nullable()
                  ->after('chapter_id')
                  ->constrained('subject_planner_content')
                  ->nullOnDelete();

            // Flag to indicate if content exists for this subject
            // false = "سيتم اضافة المحتوى قريبا"
            $table->boolean('has_content')->default(true)->after('subject_planner_content_id');

            // Current phase to complete: understanding, review, theory_practice, exercise_practice, test
            $table->string('content_phase', 50)->nullable()->after('has_content');

            // Flag for spaced repetition review sessions
            $table->boolean('is_spaced_review')->default(false)->after('content_phase');

            // Reference to original topic test (for linking spaced reviews)
            $table->foreignId('original_topic_test_session_id')
                  ->nullable()
                  ->after('is_spaced_review')
                  ->constrained('planner_study_sessions')
                  ->nullOnDelete();

            // Index for efficient content queries
            $table->index(['subject_planner_content_id', 'content_phase'], 'idx_session_content');
            $table->index(['is_spaced_review', 'scheduled_date'], 'idx_spaced_reviews');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('planner_study_sessions', function (Blueprint $table) {
            $table->dropIndex('idx_session_content');
            $table->dropIndex('idx_spaced_reviews');
            $table->dropForeign(['original_topic_test_session_id']);
            $table->dropForeign(['subject_planner_content_id']);
            $table->dropColumn([
                'subject_planner_content_id',
                'has_content',
                'content_phase',
                'is_spaced_review',
                'original_topic_test_session_id',
            ]);
        });
    }
};
