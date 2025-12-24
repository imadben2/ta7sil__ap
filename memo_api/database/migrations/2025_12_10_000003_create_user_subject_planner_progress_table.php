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
        Schema::create('user_subject_planner_progress', function (Blueprint $table) {
            $table->id();

            // User and Content References
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('subject_planner_content_id')->constrained('subject_planner_content')->onDelete('cascade');

            // Progress Status
            $table->enum('status', ['not_started', 'in_progress', 'completed', 'mastered'])->default('not_started');

            // Study Stages Completion
            $table->boolean('understanding_completed')->default(false)->comment('الفهم phase completed');
            $table->boolean('review_completed')->default(false)->comment('المراجعة phase completed');
            $table->boolean('theory_practice_completed')->default(false)->comment('الحل النظري phase completed');
            $table->boolean('exercise_practice_completed')->default(false)->comment('حل التمارين phase completed');

            // Performance Metrics
            $table->unsignedTinyInteger('completion_percentage')->default(0)->comment('0-100');
            $table->unsignedTinyInteger('mastery_score')->default(0)->comment('0-100, based on quiz/test performance');
            $table->unsignedInteger('time_spent_minutes')->default(0)->comment('Total time spent studying this content');

            // Repetition Tracking (Spaced Repetition)
            $table->unsignedInteger('study_count')->default(0)->comment('How many times this content has been studied');
            $table->timestamp('last_studied_at')->nullable();
            $table->timestamp('next_review_at')->nullable()->comment('Scheduled date for next review (spaced repetition)');

            $table->timestamps();

            // Unique Constraint
            $table->unique(['user_id', 'subject_planner_content_id'], 'unique_user_content');

            // Indexes
            $table->index(['status', 'completion_percentage'], 'idx_status');
            $table->index('next_review_at', 'idx_next_review');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_subject_planner_progress');
    }
};
