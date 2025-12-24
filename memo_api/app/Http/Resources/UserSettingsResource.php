<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserSettingsResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'notifications' => [
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
            ],
            'prayer_times' => [
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
            ],
            'app_preferences' => [
                'language' => $this->language,
                'theme' => $this->theme,
                'primary_color' => $this->primary_color,
                'rtl_mode' => $this->rtl_mode,
                'preferred_video_player' => $this->preferred_video_player,
            ],
            'study_settings' => [
                'daily_goal_minutes' => $this->daily_goal_minutes,
                'show_streak_reminder' => $this->show_streak_reminder,
                'first_day_of_week' => $this->first_day_of_week,
            ],
            'privacy' => [
                'profile_public' => $this->profile_public,
                'show_statistics' => $this->show_statistics,
                'allow_friend_requests' => $this->allow_friend_requests,
            ],
            'data_storage' => [
                'auto_backup' => $this->auto_backup,
                'download_on_wifi_only' => $this->download_on_wifi_only,
                'backup_frequency' => $this->backup_frequency,
            ],
        ];
    }
}
