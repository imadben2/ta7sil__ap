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
        // Update user_notification_settings table
        Schema::table('user_notification_settings', function (Blueprint $table) {
            // Rename exam_alerts to exam_reminders if exam_alerts exists
            if (Schema::hasColumn('user_notification_settings', 'exam_alerts')) {
                $table->renameColumn('exam_alerts', 'exam_reminders');
            }

            // Drop old columns if they exist
            if (Schema::hasColumn('user_notification_settings', 'achievement_notifications')) {
                $table->dropColumn('achievement_notifications');
            }
            if (Schema::hasColumn('user_notification_settings', 'course_notifications')) {
                $table->dropColumn('course_notifications');
            }
            if (Schema::hasColumn('user_notification_settings', 'quiet_mode_enabled')) {
                $table->dropColumn('quiet_mode_enabled');
            }
        });

        // Add new columns to user_notification_settings
        Schema::table('user_notification_settings', function (Blueprint $table) {
            if (!Schema::hasColumn('user_notification_settings', 'notifications_enabled')) {
                $table->boolean('notifications_enabled')->default(true)->after('user_id');
            }
            if (!Schema::hasColumn('user_notification_settings', 'exam_reminders')) {
                $table->boolean('exam_reminders')->default(true)->after('study_reminders');
            }
            if (!Schema::hasColumn('user_notification_settings', 'daily_summary')) {
                $table->boolean('daily_summary')->default(true)->after('exam_reminders');
            }
            if (!Schema::hasColumn('user_notification_settings', 'weekly_summary')) {
                $table->boolean('weekly_summary')->default(false)->after('daily_summary');
            }
            if (!Schema::hasColumn('user_notification_settings', 'motivational_quotes')) {
                $table->boolean('motivational_quotes')->default(true)->after('weekly_summary');
            }
            if (!Schema::hasColumn('user_notification_settings', 'course_updates')) {
                $table->boolean('course_updates')->default(true)->after('motivational_quotes');
            }
            if (!Schema::hasColumn('user_notification_settings', 'quiet_hours_enabled')) {
                $table->boolean('quiet_hours_enabled')->default(false)->after('course_updates');
            }
            if (!Schema::hasColumn('user_notification_settings', 'quiet_start_time')) {
                $table->time('quiet_start_time')->nullable()->after('quiet_hours_enabled');
            }
            if (!Schema::hasColumn('user_notification_settings', 'quiet_end_time')) {
                $table->time('quiet_end_time')->nullable()->after('quiet_start_time');
            }
        });

        // Update notifications table - drop index first
        if (Schema::hasColumn('notifications', 'type')) {
            Schema::table('notifications', function (Blueprint $table) {
                $table->dropIndex('notifications_user_id_type_read_at_index');
            });
        }

        // Drop and recreate type column as enum
        if (Schema::hasColumn('notifications', 'type')) {
            Schema::table('notifications', function (Blueprint $table) {
                $table->dropColumn('type');
            });
        }

        // Add new columns to notifications
        Schema::table('notifications', function (Blueprint $table) {
            if (!Schema::hasColumn('notifications', 'type')) {
                $table->enum('type', ['study_reminder', 'exam_alert', 'daily_summary', 'course_update', 'achievement', 'system'])->after('user_id');
            }
            if (!Schema::hasColumn('notifications', 'action_type')) {
                $table->string('action_type')->nullable()->after('body_ar');
            }
            if (!Schema::hasColumn('notifications', 'action_data')) {
                $table->json('action_data')->nullable()->after('action_type');
            }
            if (!Schema::hasColumn('notifications', 'scheduled_for')) {
                $table->timestamp('scheduled_for')->nullable()->after('action_data');
            }
            if (!Schema::hasColumn('notifications', 'status')) {
                $table->enum('status', ['pending', 'sent', 'failed'])->default('pending')->after('sent_at');
            }
            if (!Schema::hasColumn('notifications', 'priority')) {
                $table->enum('priority', ['low', 'normal', 'high'])->default('normal')->after('status');
            }
        });

        // Drop old data column from notifications
        if (Schema::hasColumn('notifications', 'data')) {
            Schema::table('notifications', function (Blueprint $table) {
                $table->dropColumn('data');
            });
        }

        // Add indexes to notifications
        Schema::table('notifications', function (Blueprint $table) {
            $table->index(['user_id', 'status']);
            $table->index(['scheduled_for', 'status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('user_notification_settings', function (Blueprint $table) {
            $table->dropColumn([
                'notifications_enabled', 'exam_reminders', 'daily_summary',
                'weekly_summary', 'motivational_quotes', 'course_updates',
                'quiet_hours_enabled', 'quiet_start_time', 'quiet_end_time'
            ]);

            $table->boolean('exam_alerts')->default(true)->after('study_reminders');
            $table->boolean('achievement_notifications')->default(true)->after('exam_alerts');
            $table->boolean('course_notifications')->default(true)->after('achievement_notifications');
            $table->boolean('quiet_mode_enabled')->default(true)->after('course_notifications');
        });

        Schema::table('notifications', function (Blueprint $table) {
            $table->dropColumn(['action_type', 'action_data', 'scheduled_for', 'status', 'priority']);
            $table->dropIndex(['user_id', 'status']);
            $table->dropIndex(['scheduled_for', 'status']);
            $table->text('data')->nullable();
        });

        Schema::table('notifications', function (Blueprint $table) {
            $table->dropColumn('type');
            $table->string('type')->after('user_id');
        });
    }
};
