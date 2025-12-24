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
        Schema::create('planner_study_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('schedule_id')->constrained('planner_schedules')->onDelete('cascade');
            $table->foreignId('subject_id')->constrained('subjects');
            $table->foreignId('chapter_id')->nullable()->constrained('chapters');

            // Scheduling
            $table->date('scheduled_date');
            $table->time('scheduled_start_time');
            $table->time('scheduled_end_time');
            $table->integer('duration_minutes');

            // Content suggestion
            $table->string('suggested_content_id')->nullable();
            $table->enum('suggested_content_type', ['video', 'pdf', 'html', 'quiz', 'exercise', 'mixed'])->nullable();
            $table->string('content_title')->nullable();
            $table->text('content_suggestion')->nullable();
            $table->string('topic_name')->nullable();

            // Session properties
            $table->enum('session_type', ['study', 'regular', 'revision', 'practice', 'exam', 'longRevision'])->default('study');
            $table->enum('required_energy_level', ['veryLow', 'low', 'medium', 'high'])->default('medium');
            $table->enum('estimated_energy_level', ['veryLow', 'low', 'medium', 'high'])->nullable();
            $table->integer('priority_score')->default(0);
            $table->boolean('is_pinned')->default(false);
            $table->boolean('is_break')->default(false);
            $table->boolean('is_prayer_time')->default(false);

            // Pomodoro settings
            $table->boolean('use_pomodoro_technique')->default(true);
            $table->integer('pomodoro_duration_minutes')->nullable();

            // Status tracking
            $table->enum('status', ['scheduled', 'inProgress', 'paused', 'completed', 'missed', 'skipped'])->default('scheduled');
            $table->timestamp('actual_start_time')->nullable();
            $table->timestamp('actual_end_time')->nullable();
            $table->integer('actual_duration_minutes')->nullable();

            // Pomodoro tracking
            $table->integer('current_pomodoro_count')->default(0);
            $table->integer('total_pomodoros_planned')->default(0);
            $table->integer('pause_count')->default(0);

            // User interaction
            $table->text('user_notes')->nullable();
            $table->string('skip_reason')->nullable();
            $table->integer('completion_percentage')->nullable();
            $table->enum('mood', ['positive', 'neutral', 'negative'])->nullable();

            // Points & gamification
            $table->integer('points_earned')->nullable();

            $table->timestamps();

            // Indexes
            $table->index(['user_id', 'scheduled_date']);
            $table->index(['schedule_id', 'status']);
            $table->index(['subject_id', 'status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('planner_study_sessions');
    }
};
