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
        Schema::table('planner_settings', function (Blueprint $table) {
            // Add new Pomodoro field
            $table->integer('pomodoros_before_long_break')->default(4)->after('long_break');

            // Add prayer city field
            $table->string('city_for_prayer')->default('Algiers')->after('prayer_duration_minutes');

            // Add performance adaptation field
            $table->boolean('adapt_to_performance_enabled')->default(true)->after('smart_content_suggestions');

            // Add individual priority weights
            $table->integer('coefficient_weight')->default(40)->after('priority_formula');
            $table->integer('exam_proximity_weight')->default(25)->after('coefficient_weight');
            $table->integer('difficulty_weight')->default(15)->after('exam_proximity_weight');
            $table->integer('inactivity_weight')->default(10)->after('difficulty_weight');
            $table->integer('performance_gap_weight')->default(10)->after('inactivity_weight');

            // Add study limits
            $table->integer('max_study_hours_per_day')->default(8)->after('performance_gap_weight');
            $table->integer('min_break_between_sessions')->default(10)->after('max_study_hours_per_day');

            // Rename exercise_start_time to exercise_time
            $table->renameColumn('exercise_start_time', 'exercise_time');
        });

        // Convert energy level enums to integers (1-10)
        // First, add new integer columns
        DB::statement("ALTER TABLE planner_settings
            ADD COLUMN morning_energy_level INTEGER DEFAULT 7 AFTER night_energy,
            ADD COLUMN afternoon_energy_level INTEGER DEFAULT 6 AFTER morning_energy_level,
            ADD COLUMN evening_energy_level INTEGER DEFAULT 8 AFTER afternoon_energy_level,
            ADD COLUMN night_energy_level INTEGER DEFAULT 4 AFTER evening_energy_level"
        );

        // Migrate data from enum to integer
        DB::statement("UPDATE planner_settings SET
            morning_energy_level = CASE morning_energy
                WHEN 'low' THEN 3
                WHEN 'medium' THEN 6
                WHEN 'high' THEN 9
            END,
            afternoon_energy_level = CASE afternoon_energy
                WHEN 'low' THEN 3
                WHEN 'medium' THEN 6
                WHEN 'high' THEN 9
            END,
            evening_energy_level = CASE evening_energy
                WHEN 'low' THEN 3
                WHEN 'medium' THEN 6
                WHEN 'high' THEN 9
            END,
            night_energy_level = CASE night_energy
                WHEN 'low' THEN 3
                WHEN 'medium' THEN 6
                WHEN 'high' THEN 9
            END"
        );

        // Drop old enum columns
        Schema::table('planner_settings', function (Blueprint $table) {
            $table->dropColumn(['morning_energy', 'afternoon_energy', 'evening_energy', 'night_energy']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Add back enum columns
        Schema::table('planner_settings', function (Blueprint $table) {
            $table->enum('morning_energy', ['low', 'medium', 'high'])->default('high')->after('exercise_duration_minutes');
            $table->enum('afternoon_energy', ['low', 'medium', 'high'])->default('medium')->after('morning_energy');
            $table->enum('evening_energy', ['low', 'medium', 'high'])->default('medium')->after('afternoon_energy');
            $table->enum('night_energy', ['low', 'medium', 'high'])->default('low')->after('evening_energy');
        });

        // Migrate integer data back to enum
        DB::statement("UPDATE planner_settings SET
            morning_energy = CASE
                WHEN morning_energy_level >= 7 THEN 'high'
                WHEN morning_energy_level >= 4 THEN 'medium'
                ELSE 'low'
            END,
            afternoon_energy = CASE
                WHEN afternoon_energy_level >= 7 THEN 'high'
                WHEN afternoon_energy_level >= 4 THEN 'medium'
                ELSE 'low'
            END,
            evening_energy = CASE
                WHEN evening_energy_level >= 7 THEN 'high'
                WHEN evening_energy_level >= 4 THEN 'medium'
                ELSE 'low'
            END,
            night_energy = CASE
                WHEN night_energy_level >= 7 THEN 'high'
                WHEN night_energy_level >= 4 THEN 'medium'
                ELSE 'low'
            END"
        );

        Schema::table('planner_settings', function (Blueprint $table) {
            // Drop new columns
            $table->dropColumn([
                'pomodoros_before_long_break',
                'city_for_prayer',
                'adapt_to_performance_enabled',
                'coefficient_weight',
                'exam_proximity_weight',
                'difficulty_weight',
                'inactivity_weight',
                'performance_gap_weight',
                'max_study_hours_per_day',
                'min_break_between_sessions',
                'morning_energy_level',
                'afternoon_energy_level',
                'evening_energy_level',
                'night_energy_level'
            ]);

            // Rename back exercise_time to exercise_start_time
            $table->renameColumn('exercise_time', 'exercise_start_time');
        });
    }
};
