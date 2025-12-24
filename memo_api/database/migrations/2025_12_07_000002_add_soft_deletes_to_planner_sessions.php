<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * Adds soft deletes to planner_study_sessions table to preserve historical data.
     */
    public function up(): void
    {
        Schema::table('planner_study_sessions', function (Blueprint $table) {
            if (!Schema::hasColumn('planner_study_sessions', 'deleted_at')) {
                $table->softDeletes();
            }
        });

        // Also add to planner_exams for consistency
        if (Schema::hasTable('planner_exams')) {
            Schema::table('planner_exams', function (Blueprint $table) {
                if (!Schema::hasColumn('planner_exams', 'deleted_at')) {
                    $table->softDeletes();
                }
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('planner_study_sessions', function (Blueprint $table) {
            $table->dropSoftDeletes();
        });

        if (Schema::hasTable('planner_exams')) {
            Schema::table('planner_exams', function (Blueprint $table) {
                $table->dropSoftDeletes();
            });
        }
    }
};
