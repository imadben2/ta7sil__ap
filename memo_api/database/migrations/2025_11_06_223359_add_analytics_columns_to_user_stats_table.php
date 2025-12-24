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
        Schema::table('user_stats', function (Blueprint $table) {
            // Add analytics columns if they don't exist
            if (!Schema::hasColumn('user_stats', 'total_sessions')) {
                $table->integer('total_sessions')->default(0)->after('total_study_minutes');
            }
            if (!Schema::hasColumn('user_stats', 'total_quizzes_taken')) {
                $table->integer('total_quizzes_taken')->default(0)->after('total_quizzes_completed');
            }
            if (!Schema::hasColumn('user_stats', 'total_quizzes_passed')) {
                $table->integer('total_quizzes_passed')->default(0)->after('total_quizzes_taken');
            }
            if (!Schema::hasColumn('user_stats', 'average_quiz_score')) {
                $table->decimal('average_quiz_score', 5, 2)->default(0)->after('total_quizzes_passed');
            }
            if (!Schema::hasColumn('user_stats', 'total_content_viewed')) {
                $table->integer('total_content_viewed')->default(0)->after('total_contents_completed');
            }
            if (!Schema::hasColumn('user_stats', 'current_streak_days')) {
                $table->integer('current_streak_days')->default(0)->after('current_month_minutes');
            }
            if (!Schema::hasColumn('user_stats', 'longest_streak_days')) {
                $table->integer('longest_streak_days')->default(0)->after('current_streak_days');
            }
            if (!Schema::hasColumn('user_stats', 'last_study_date')) {
                $table->date('last_study_date')->nullable()->after('longest_streak_days');
            }
            if (!Schema::hasColumn('user_stats', 'level')) {
                $table->integer('level')->default(1)->after('last_study_date');
            }
            if (!Schema::hasColumn('user_stats', 'experience_points')) {
                $table->integer('experience_points')->default(0)->after('level');
            }
            if (!Schema::hasColumn('user_stats', 'gamification_points')) {
                $table->integer('gamification_points')->default(0)->after('experience_points');
            }
            if (!Schema::hasColumn('user_stats', 'total_achievements_unlocked')) {
                $table->integer('total_achievements_unlocked')->default(0)->after('gamification_points');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('user_stats', function (Blueprint $table) {
            $table->dropColumn([
                'total_sessions',
                'total_quizzes_taken',
                'total_quizzes_passed',
                'average_quiz_score',
                'total_content_viewed',
                'current_streak_days',
                'longest_streak_days',
                'last_study_date',
                'level',
                'experience_points',
                'gamification_points',
                'total_achievements_unlocked',
            ]);
        });
    }
};
