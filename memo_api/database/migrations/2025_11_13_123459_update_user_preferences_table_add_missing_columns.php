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
        Schema::table('user_preferences', function (Blueprint $table) {
            // Remove old columns that are not in the model
            $table->dropColumn([
                'language',
                'email_notifications',
                'push_notifications',
                'pomodoro_break',
                'study_start_time',
                'study_end_time',
                'sleep_start_time',
                'sleep_end_time',
                'prayer_notifications'
            ]);

            // Add new notification columns
            $table->boolean('study_session_reminders')->default(true)->after('notifications_enabled');
            $table->boolean('exam_reminders')->default(true)->after('study_session_reminders');
            $table->boolean('daily_summary')->default(true)->after('exam_reminders');
            $table->boolean('weekly_summary')->default(true)->after('daily_summary');

            // Add font size
            $table->enum('font_size', ['small', 'medium', 'large'])->default('medium')->after('theme');

            // Rename and add pomodoro columns
            $table->integer('short_break_duration')->default(5)->after('pomodoro_duration');
            $table->integer('long_break_duration')->default(15)->after('short_break_duration');
            $table->integer('sessions_before_long_break')->default(4)->after('long_break_duration');

            // Add ramadan mode
            $table->boolean('ramadan_mode_enabled')->default(false)->after('sessions_before_long_break');

            // Add other preferences
            $table->boolean('motivational_quotes_enabled')->default(true)->after('ramadan_mode_enabled');
            $table->boolean('sound_effects_enabled')->default(true)->after('motivational_quotes_enabled');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('user_preferences', function (Blueprint $table) {
            // Remove new columns
            $table->dropColumn([
                'study_session_reminders',
                'exam_reminders',
                'daily_summary',
                'weekly_summary',
                'font_size',
                'short_break_duration',
                'long_break_duration',
                'sessions_before_long_break',
                'ramadan_mode_enabled',
                'motivational_quotes_enabled',
                'sound_effects_enabled'
            ]);

            // Re-add old columns
            $table->enum('language', ['ar', 'fr', 'en'])->default('ar');
            $table->boolean('email_notifications')->default(true);
            $table->boolean('push_notifications')->default(true);
            $table->integer('pomodoro_break')->default(5);
            $table->time('study_start_time')->default('08:00');
            $table->time('study_end_time')->default('22:00');
            $table->time('sleep_start_time')->default('23:00');
            $table->time('sleep_end_time')->default('06:00');
            $table->boolean('prayer_notifications')->default(true);
        });
    }
};
