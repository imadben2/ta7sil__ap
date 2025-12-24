<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * Add importance and difficulty columns for session tracking
     */
    public function up(): void
    {
        Schema::table('planner_study_sessions', function (Blueprint $table) {
            $table->integer('importance')->default(3)->after('priority_score')
                  ->comment('Session importance 1-5');
            $table->integer('difficulty')->default(3)->after('importance')
                  ->comment('Session difficulty 1-5');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('planner_study_sessions', function (Blueprint $table) {
            $table->dropColumn(['importance', 'difficulty']);
        });
    }
};
