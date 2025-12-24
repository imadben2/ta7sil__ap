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
        Schema::create('user_lesson_progress', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('course_lesson_id')->constrained('course_lessons')->onDelete('cascade');

            // Video progress
            $table->integer('watch_time_seconds')->default(0);
            $table->integer('video_duration_seconds');
            $table->boolean('is_completed')->default(false);
            $table->timestamp('completed_at')->nullable();

            // Resume position
            $table->integer('last_position_seconds')->default(0);
            $table->timestamp('last_watched_at')->nullable();

            $table->timestamps();

            $table->unique(['user_id', 'course_lesson_id']);
            $table->index(['user_id', 'is_completed']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_lesson_progress');
    }
};
