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
        Schema::table('exam_schedule', function (Blueprint $table) {
            // Add target_score field
            $table->decimal('target_score', 5, 2)->nullable()->after('preparation_days_before');

            // Add chapters_covered JSON field
            $table->json('chapters_covered')->nullable()->after('target_score');

            // Rename estimated_duration_minutes to duration_minutes
            $table->renameColumn('estimated_duration_minutes', 'duration_minutes');
        });

        // Update enum for exam_type (add 'quiz', change 'final' to 'final_exam')
        DB::statement("ALTER TABLE exam_schedule MODIFY COLUMN exam_type ENUM('quiz', 'test', 'exam', 'final_exam') DEFAULT 'test'");

        // Convert importance_level from integer to enum
        // First, add new enum column
        DB::statement("ALTER TABLE exam_schedule
            ADD COLUMN importance_level_enum ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium' AFTER importance_level"
        );

        // Migrate data from integer to enum
        DB::statement("UPDATE exam_schedule SET
            importance_level_enum = CASE
                WHEN importance_level >= 9 THEN 'critical'
                WHEN importance_level >= 7 THEN 'high'
                WHEN importance_level >= 4 THEN 'medium'
                ELSE 'low'
            END"
        );

        // Drop old integer column and rename enum column
        Schema::table('exam_schedule', function (Blueprint $table) {
            $table->dropColumn('importance_level');
        });

        DB::statement("ALTER TABLE exam_schedule CHANGE COLUMN importance_level_enum importance_level ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium'");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Revert exam_type enum
        DB::statement("ALTER TABLE exam_schedule MODIFY COLUMN exam_type ENUM('test', 'exam', 'final') DEFAULT 'test'");

        // Convert importance_level back from enum to integer
        DB::statement("ALTER TABLE exam_schedule
            ADD COLUMN importance_level_int INTEGER DEFAULT 5 AFTER importance_level"
        );

        DB::statement("UPDATE exam_schedule SET
            importance_level_int = CASE importance_level
                WHEN 'critical' THEN 10
                WHEN 'high' THEN 8
                WHEN 'medium' THEN 5
                WHEN 'low' THEN 3
            END"
        );

        Schema::table('exam_schedule', function (Blueprint $table) {
            $table->dropColumn('importance_level');
        });

        DB::statement("ALTER TABLE exam_schedule CHANGE COLUMN importance_level_int importance_level INTEGER DEFAULT 5");

        Schema::table('exam_schedule', function (Blueprint $table) {
            // Drop new fields
            $table->dropColumn(['target_score', 'chapters_covered']);

            // Rename back duration_minutes to estimated_duration_minutes
            $table->renameColumn('duration_minutes', 'estimated_duration_minutes');
        });
    }
};
