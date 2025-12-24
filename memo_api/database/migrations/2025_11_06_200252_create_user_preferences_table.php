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
        Schema::create('user_preferences', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->onDelete('cascade');

            // UI Preferences
            $table->enum('language', ['ar', 'fr', 'en'])->default('ar');
            $table->enum('theme', ['light', 'dark', 'auto'])->default('light');

            // Notifications
            $table->boolean('notifications_enabled')->default(true);
            $table->boolean('email_notifications')->default(true);
            $table->boolean('push_notifications')->default(true);

            // Study Settings
            $table->integer('pomodoro_duration')->default(25); // minutes
            $table->integer('pomodoro_break')->default(5); // minutes
            $table->time('study_start_time')->default('08:00');
            $table->time('study_end_time')->default('22:00');
            $table->time('sleep_start_time')->default('23:00');
            $table->time('sleep_end_time')->default('06:00');

            // Prayer
            $table->boolean('prayer_notifications')->default(true);

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_preferences');
    }
};
