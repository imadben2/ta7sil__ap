<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserSettings extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'user_id',
        // Notification Settings
        'notify_new_memo',
        'notify_memo_due',
        'notify_revision_reminder',
        'notify_achievement',
        'notify_prayer_time',
        'notify_daily_goal',
        // Notification Channels
        'notify_push',
        'notify_email',
        'notify_sms',
        // Prayer Times Settings
        'prayer_times_enabled',
        'calculation_method',
        'madhab',
        'fajr_adjustment',
        'dhuhr_adjustment',
        'asr_adjustment',
        'maghrib_adjustment',
        'isha_adjustment',
        // Prayer Notifications
        'notify_fajr',
        'notify_dhuhr',
        'notify_asr',
        'notify_maghrib',
        'notify_isha',
        'prayer_notification_before',
        // App Preferences
        'language',
        'theme',
        'primary_color',
        'rtl_mode',
        'preferred_video_player',
        // Study Settings
        'daily_goal_minutes',
        'show_streak_reminder',
        'first_day_of_week',
        // Privacy Settings
        'profile_public',
        'show_statistics',
        'allow_friend_requests',
        // Data & Storage
        'auto_backup',
        'download_on_wifi_only',
        'backup_frequency',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'notify_new_memo' => 'boolean',
        'notify_memo_due' => 'boolean',
        'notify_revision_reminder' => 'boolean',
        'notify_achievement' => 'boolean',
        'notify_prayer_time' => 'boolean',
        'notify_daily_goal' => 'boolean',
        'notify_push' => 'boolean',
        'notify_email' => 'boolean',
        'notify_sms' => 'boolean',
        'prayer_times_enabled' => 'boolean',
        'fajr_adjustment' => 'integer',
        'dhuhr_adjustment' => 'integer',
        'asr_adjustment' => 'integer',
        'maghrib_adjustment' => 'integer',
        'isha_adjustment' => 'integer',
        'notify_fajr' => 'boolean',
        'notify_dhuhr' => 'boolean',
        'notify_asr' => 'boolean',
        'notify_maghrib' => 'boolean',
        'notify_isha' => 'boolean',
        'prayer_notification_before' => 'integer',
        'rtl_mode' => 'boolean',
        'daily_goal_minutes' => 'integer',
        'show_streak_reminder' => 'boolean',
        'profile_public' => 'boolean',
        'show_statistics' => 'boolean',
        'allow_friend_requests' => 'boolean',
        'auto_backup' => 'boolean',
        'download_on_wifi_only' => 'boolean',
    ];

    /**
     * Get the user that owns the settings.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get notification settings grouped.
     *
     * @return array
     */
    public function getNotificationSettings(): array
    {
        return [
            'types' => [
                'new_memo' => $this->notify_new_memo,
                'memo_due' => $this->notify_memo_due,
                'revision_reminder' => $this->notify_revision_reminder,
                'achievement' => $this->notify_achievement,
                'prayer_time' => $this->notify_prayer_time,
                'daily_goal' => $this->notify_daily_goal,
            ],
            'channels' => [
                'push' => $this->notify_push,
                'email' => $this->notify_email,
                'sms' => $this->notify_sms,
            ],
        ];
    }

    /**
     * Get prayer times settings grouped.
     *
     * @return array
     */
    public function getPrayerTimesSettings(): array
    {
        return [
            'enabled' => $this->prayer_times_enabled,
            'calculation_method' => $this->calculation_method,
            'madhab' => $this->madhab,
            'adjustments' => [
                'fajr' => $this->fajr_adjustment,
                'dhuhr' => $this->dhuhr_adjustment,
                'asr' => $this->asr_adjustment,
                'maghrib' => $this->maghrib_adjustment,
                'isha' => $this->isha_adjustment,
            ],
            'notifications' => [
                'fajr' => $this->notify_fajr,
                'dhuhr' => $this->notify_dhuhr,
                'asr' => $this->notify_asr,
                'maghrib' => $this->notify_maghrib,
                'isha' => $this->notify_isha,
                'before_minutes' => $this->prayer_notification_before,
            ],
        ];
    }

    /**
     * Get app preferences grouped.
     *
     * @return array
     */
    public function getAppPreferences(): array
    {
        return [
            'language' => $this->language,
            'theme' => $this->theme,
            'primary_color' => $this->primary_color,
            'rtl_mode' => $this->rtl_mode,
            'preferred_video_player' => $this->preferred_video_player,
        ];
    }

    /**
     * Get study settings grouped.
     *
     * @return array
     */
    public function getStudySettings(): array
    {
        return [
            'daily_goal_minutes' => $this->daily_goal_minutes,
            'show_streak_reminder' => $this->show_streak_reminder,
            'first_day_of_week' => $this->first_day_of_week,
        ];
    }

    /**
     * Get privacy settings grouped.
     *
     * @return array
     */
    public function getPrivacySettings(): array
    {
        return [
            'profile_public' => $this->profile_public,
            'show_statistics' => $this->show_statistics,
            'allow_friend_requests' => $this->allow_friend_requests,
        ];
    }
}
