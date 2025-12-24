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
        Schema::create('planner_settings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->onDelete('cascade');

            // Study time range
            $table->time('study_start_time')->default('17:30');
            $table->time('study_end_time')->default('22:30');

            // Sleep time
            $table->time('sleep_start_time')->default('23:00');
            $table->time('sleep_end_time')->default('06:00');

            // Exercise/Sport
            $table->boolean('exercise_enabled')->default(false);
            $table->json('exercise_days')->nullable(); // [1,3,5] - Monday, Wednesday, Friday
            $table->time('exercise_start_time')->nullable();
            $table->integer('exercise_duration_minutes')->nullable();

            // Energy levels by time slot
            $table->enum('morning_energy', ['low', 'medium', 'high'])->default('high');
            $table->enum('afternoon_energy', ['low', 'medium', 'high'])->default('medium');
            $table->enum('evening_energy', ['low', 'medium', 'high'])->default('medium');
            $table->enum('night_energy', ['low', 'medium', 'high'])->default('low');

            // Pomodoro technique
            $table->boolean('use_pomodoro')->default(true);
            $table->integer('pomodoro_duration')->default(25); // minutes
            $table->integer('short_break')->default(5); // minutes
            $table->integer('long_break')->default(15); // minutes

            // Algorithm settings
            $table->json('priority_formula')->nullable(); // Weights for priority factors
            $table->boolean('auto_reschedule_missed')->default(true);
            $table->boolean('smart_content_suggestions')->default(true);

            // Prayer times
            $table->boolean('enable_prayer_times')->default(true);
            $table->integer('prayer_duration_minutes')->default(15);

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('planner_settings');
    }
};
