<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * This migration merges study_schedules into planner_schedules,
     * adding missing columns and migrating existing data.
     */
    public function up(): void
    {
        // Step 1: Add missing columns from study_schedules to planner_schedules
        Schema::table('planner_schedules', function (Blueprint $table) {
            // From study_schedules - add if not exists
            if (!Schema::hasColumn('planner_schedules', 'schedule_type')) {
                $table->string('schedule_type')->default('weekly')->after('academic_stream_id');
            }
            if (!Schema::hasColumn('planner_schedules', 'status')) {
                $table->string('status')->default('active')->after('is_active');
            }
            if (!Schema::hasColumn('planner_schedules', 'generation_algorithm_version')) {
                $table->string('generation_algorithm_version')->default('v2.0')->after('status');
            }
            if (!Schema::hasColumn('planner_schedules', 'total_study_hours')) {
                $table->decimal('total_study_hours', 5, 2)->default(0)->after('generation_algorithm_version');
            }
            if (!Schema::hasColumn('planner_schedules', 'subjects_covered')) {
                $table->json('subjects_covered')->nullable()->after('total_study_hours');
            }
            if (!Schema::hasColumn('planner_schedules', 'feasibility_score')) {
                $table->decimal('feasibility_score', 3, 2)->default(0)->after('subjects_covered');
            }
            if (!Schema::hasColumn('planner_schedules', 'generated_at')) {
                $table->timestamp('generated_at')->nullable()->after('feasibility_score');
            }
            if (!Schema::hasColumn('planner_schedules', 'activated_at')) {
                $table->timestamp('activated_at')->nullable()->after('generated_at');
            }
            // Add soft deletes for historical data preservation
            if (!Schema::hasColumn('planner_schedules', 'deleted_at')) {
                $table->softDeletes();
            }
        });

        // Step 2: Migrate data from study_schedules to planner_schedules if study_schedules exists
        if (Schema::hasTable('study_schedules')) {
            $studySchedules = DB::table('study_schedules')->get();

            foreach ($studySchedules as $schedule) {
                // Check if already migrated (by user_id and start_date)
                $exists = DB::table('planner_schedules')
                    ->where('user_id', $schedule->user_id)
                    ->where('start_date', $schedule->start_date)
                    ->where('end_date', $schedule->end_date)
                    ->exists();

                if (!$exists) {
                    DB::table('planner_schedules')->insert([
                        'user_id' => $schedule->user_id,
                        'academic_year_id' => 1, // Default, should be updated
                        'academic_stream_id' => 1, // Default, should be updated
                        'start_date' => $schedule->start_date,
                        'end_date' => $schedule->end_date,
                        'is_active' => $schedule->status === 'active',
                        'schedule_type' => $schedule->schedule_type,
                        'status' => $schedule->status,
                        'generation_algorithm_version' => $schedule->generation_algorithm_version,
                        'total_study_hours' => $schedule->total_study_hours,
                        'subjects_covered' => $schedule->subjects_covered,
                        'feasibility_score' => $schedule->feasibility_score,
                        'generated_at' => $schedule->generated_at,
                        'activated_at' => $schedule->activated_at,
                        'created_at' => $schedule->created_at,
                        'updated_at' => $schedule->updated_at,
                    ]);
                }
            }
        }

        // Step 3: Add index for better performance
        Schema::table('planner_schedules', function (Blueprint $table) {
            // Add composite index for common queries
            $table->index(['user_id', 'status', 'start_date'], 'planner_schedules_user_status_date_idx');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('planner_schedules', function (Blueprint $table) {
            // Drop added columns
            $columns = [
                'schedule_type', 'status', 'generation_algorithm_version',
                'total_study_hours', 'subjects_covered', 'feasibility_score',
                'generated_at', 'activated_at', 'deleted_at'
            ];

            foreach ($columns as $column) {
                if (Schema::hasColumn('planner_schedules', $column)) {
                    $table->dropColumn($column);
                }
            }

            // Drop index
            $table->dropIndex('planner_schedules_user_status_date_idx');
        });
    }
};
