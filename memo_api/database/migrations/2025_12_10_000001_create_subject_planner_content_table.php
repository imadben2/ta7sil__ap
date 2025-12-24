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
        Schema::create('subject_planner_content', function (Blueprint $table) {
            $table->id();

            // Academic Context Links
            $table->foreignId('academic_phase_id')->constrained('academic_phases')->onDelete('cascade');
            $table->foreignId('academic_year_id')->constrained('academic_years')->onDelete('cascade');
            $table->foreignId('academic_stream_id')->nullable()->constrained('academic_streams')->onDelete('cascade');
            $table->foreignId('subject_id')->constrained('subjects')->onDelete('cascade');

            // Hierarchical Organization
            $table->foreignId('parent_id')->nullable()->constrained('subject_planner_content')->onDelete('cascade');
            $table->enum('level', ['learning_axis', 'unit', 'topic', 'subtopic', 'learning_objective']);

            // Content Identification
            $table->string('code', 50)->nullable()->comment('e.g., U1, U1.T1, LA1.U2.T3');
            $table->string('title_ar')->comment('Arabic title of the content item');
            $table->text('description_ar')->nullable();

            // Ordering
            $table->unsignedInteger('order')->default(0);

            // Study Metadata
            $table->enum('content_type', ['theory', 'exercise', 'review', 'memorization', 'practice', 'exam_prep'])->nullable();
            $table->enum('difficulty_level', ['easy', 'medium', 'hard'])->default('medium');
            $table->unsignedInteger('estimated_duration_minutes')->nullable()->comment('Estimated study time in minutes');

            // Repetition Schedule (based on curriculum structure)
            $table->boolean('requires_understanding')->default(true)->comment('الفهم - Understanding phase required');
            $table->boolean('requires_review')->default(true)->comment('المراجعة - Review phase required');
            $table->boolean('requires_theory_practice')->default(false)->comment('الحل النظري - Theory practice required');
            $table->boolean('requires_exercise_practice')->default(false)->comment('حل التمارين - Exercise practice required');

            // Learning Objectives & Competencies
            $table->json('learning_objectives')->nullable()->comment('Array of specific learning objectives');
            $table->json('competencies')->nullable()->comment('Array of competencies/skills to acquire');
            $table->json('prerequisites')->nullable()->comment('Array of content IDs that must be studied first');

            // Content Linking
            $table->json('related_content_ids')->nullable()->comment('Links to contents table items');
            $table->foreignId('related_chapter_id')->nullable()->constrained('content_chapters')->onDelete('set null');

            // BAC Exam Mapping
            $table->json('bac_exam_years')->nullable()->comment('Years this content appeared in BAC exams, e.g., ["2024", "2023"]');
            $table->boolean('is_bac_priority')->default(false)->comment('High priority for BAC preparation');
            $table->unsignedInteger('bac_frequency')->default(0)->comment('How often this appears in BAC exams');

            // Status & Visibility
            $table->boolean('is_active')->default(true);
            $table->boolean('is_published')->default(false);
            $table->timestamp('published_at')->nullable();

            // Tracking
            $table->foreignId('created_by')->nullable()->constrained('users')->onDelete('set null');
            $table->foreignId('updated_by')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamps();
            $table->softDeletes();

            // Indexes
            $table->index(['academic_phase_id', 'academic_year_id', 'academic_stream_id', 'subject_id'], 'idx_academic_context');
            $table->index(['parent_id', 'level', 'order'], 'idx_hierarchy');
            $table->index(['is_bac_priority', 'bac_frequency'], 'idx_bac_priority');
            $table->index(['is_published', 'is_active'], 'idx_published');
            $table->index(['content_type', 'difficulty_level'], 'idx_content_type');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('subject_planner_content');
    }
};
