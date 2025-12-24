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
        Schema::create('user_settings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');

            // Notification Settings
            $table->boolean('notify_new_memo')->default(true);
            $table->boolean('notify_memo_due')->default(true);
            $table->boolean('notify_revision_reminder')->default(true);
            $table->boolean('notify_achievement')->default(true);
            $table->boolean('notify_prayer_time')->default(false);
            $table->boolean('notify_daily_goal')->default(true);

            // Notification Channels
            $table->boolean('notify_push')->default(true);
            $table->boolean('notify_email')->default(false);
            $table->boolean('notify_sms')->default(false);

            // Prayer Times Settings
            $table->boolean('prayer_times_enabled')->default(false);
            $table->string('calculation_method')->default('egyptian'); // egyptian, mwl, isna, etc.
            $table->string('madhab')->default('shafi'); // shafi, hanafi
            $table->integer('fajr_adjustment')->default(0); // minutes
            $table->integer('dhuhr_adjustment')->default(0);
            $table->integer('asr_adjustment')->default(0);
            $table->integer('maghrib_adjustment')->default(0);
            $table->integer('isha_adjustment')->default(0);

            // Prayer Notifications
            $table->boolean('notify_fajr')->default(false);
            $table->boolean('notify_dhuhr')->default(false);
            $table->boolean('notify_asr')->default(false);
            $table->boolean('notify_maghrib')->default(false);
            $table->boolean('notify_isha')->default(false);
            $table->integer('prayer_notification_before')->default(15); // minutes before prayer

            // App Preferences
            $table->string('language')->default('ar'); // ar, fr, en
            $table->string('theme')->default('system'); // light, dark, system
            $table->string('primary_color')->default('blue');
            $table->boolean('rtl_mode')->default(true);

            // Study Settings
            $table->integer('daily_goal_minutes')->default(120);
            $table->boolean('show_streak_reminder')->default(true);
            $table->string('first_day_of_week')->default('saturday'); // saturday, sunday, monday

            // Privacy Settings
            $table->boolean('profile_public')->default(false);
            $table->boolean('show_statistics')->default(true);
            $table->boolean('allow_friend_requests')->default(true);

            // Data & Storage
            $table->boolean('auto_backup')->default(false);
            $table->boolean('download_on_wifi_only')->default(true);
            $table->string('backup_frequency')->default('weekly'); // daily, weekly, monthly

            $table->timestamps();

            // Indexes
            $table->unique('user_id');
            $table->index('language');
            $table->index('theme');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_settings');
    }
};
