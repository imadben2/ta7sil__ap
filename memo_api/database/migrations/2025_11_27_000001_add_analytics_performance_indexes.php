<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * These indexes optimize analytics queries for:
     * - Weak areas detection
     * - Subject-specific analytics
     * - Progress tracking
     * - Heatmap generation
     */
    public function up(): void
    {
        // Quiz attempts indexes for analytics
        Schema::table('quiz_attempts', function (Blueprint $table) {
            // For date range queries in analytics (user + date + status)
            $table->index(['user_id', 'started_at', 'status'], 'qa_analytics_date_index');

            // For score-based analytics queries
            $table->index(['user_id', 'status', 'score_percentage'], 'qa_score_analytics_index');
        });

        // Study sessions indexes for analytics
        Schema::table('study_sessions', function (Blueprint $table) {
            // For heatmap queries - date aggregation
            $table->index(['user_id', 'status', 'scheduled_date'], 'ss_heatmap_index');

            // For subject breakdown queries
            $table->index(['user_id', 'subject_id', 'status', 'scheduled_date'], 'ss_subject_analytics_index');
        });

        // Quizzes index for joining with quiz attempts
        Schema::table('quizzes', function (Blueprint $table) {
            // For joining quiz attempts with subject/chapter filtering
            $table->index(['subject_id', 'chapter_id'], 'quizzes_subject_chapter_index');
        });

        // Content chapters index
        Schema::table('content_chapters', function (Blueprint $table) {
            // For weak area analysis
            $table->index(['subject_id', 'is_active', 'order'], 'chapters_subject_active_index');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('quiz_attempts', function (Blueprint $table) {
            $table->dropIndex('qa_analytics_date_index');
            $table->dropIndex('qa_score_analytics_index');
        });

        Schema::table('study_sessions', function (Blueprint $table) {
            $table->dropIndex('ss_heatmap_index');
            $table->dropIndex('ss_subject_analytics_index');
        });

        Schema::table('quizzes', function (Blueprint $table) {
            $table->dropIndex('quizzes_subject_chapter_index');
        });

        Schema::table('content_chapters', function (Blueprint $table) {
            $table->dropIndex('chapters_subject_active_index');
        });
    }
};
