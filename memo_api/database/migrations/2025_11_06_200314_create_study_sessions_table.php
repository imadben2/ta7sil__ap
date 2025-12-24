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
        Schema::create('study_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('study_schedule_id')->nullable()->constrained()->onDelete('set null');
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('subject_id')->constrained()->onDelete('cascade');

            // Timing
            $table->date('scheduled_date');
            $table->time('scheduled_start_time');
            $table->time('scheduled_end_time');
            $table->integer('estimated_duration_minutes');

            // Suggested content
            $table->foreignId('suggested_content_id')->nullable()->constrained('contents')->onDelete('set null');
            $table->enum('suggested_content_type', ['lesson', 'summary', 'exercise', 'test', 'quiz'])->nullable();

            // Energy and type
            $table->enum('required_energy_level', ['low', 'medium', 'high'])->default('medium');
            $table->enum('session_type', ['learning', 'revision', 'practice', 'test'])->default('learning');

            // Status and execution
            $table->enum('status', ['scheduled', 'in_progress', 'completed', 'missed', 'rescheduled'])->default('scheduled');
            $table->timestamp('actual_start_time')->nullable();
            $table->timestamp('actual_end_time')->nullable();
            $table->integer('actual_duration_minutes')->nullable();

            // Notes
            $table->text('user_notes')->nullable();
            $table->text('skipped_reason')->nullable();

            // Metadata
            $table->boolean('is_pinned')->default(false); // Don't move during regeneration
            $table->integer('priority_level')->default(5); // 1-10

            $table->timestamps();

            $table->index(['user_id', 'scheduled_date', 'status']);
            $table->index(['subject_id', 'scheduled_date']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('study_sessions');
    }
};
