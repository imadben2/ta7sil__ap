<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateSettingsRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            // Notification Settings
            'notify_new_memo' => ['sometimes', 'boolean'],
            'notify_memo_due' => ['sometimes', 'boolean'],
            'notify_revision_reminder' => ['sometimes', 'boolean'],
            'notify_achievement' => ['sometimes', 'boolean'],
            'notify_prayer_time' => ['sometimes', 'boolean'],
            'notify_daily_goal' => ['sometimes', 'boolean'],

            // Notification Channels
            'notify_push' => ['sometimes', 'boolean'],
            'notify_email' => ['sometimes', 'boolean'],
            'notify_sms' => ['sometimes', 'boolean'],

            // Prayer Times Settings
            'prayer_times_enabled' => ['sometimes', 'boolean'],
            'calculation_method' => ['sometimes', Rule::in(['egyptian', 'mwl', 'isna', 'makkah', 'karachi', 'tehran', 'jafari'])],
            'madhab' => ['sometimes', Rule::in(['shafi', 'hanafi'])],
            'fajr_adjustment' => ['sometimes', 'integer', 'between:-30,30'],
            'dhuhr_adjustment' => ['sometimes', 'integer', 'between:-30,30'],
            'asr_adjustment' => ['sometimes', 'integer', 'between:-30,30'],
            'maghrib_adjustment' => ['sometimes', 'integer', 'between:-30,30'],
            'isha_adjustment' => ['sometimes', 'integer', 'between:-30,30'],

            // Prayer Notifications
            'notify_fajr' => ['sometimes', 'boolean'],
            'notify_dhuhr' => ['sometimes', 'boolean'],
            'notify_asr' => ['sometimes', 'boolean'],
            'notify_maghrib' => ['sometimes', 'boolean'],
            'notify_isha' => ['sometimes', 'boolean'],
            'prayer_notification_before' => ['sometimes', 'integer', 'between:0,60'],

            // App Preferences
            'language' => ['sometimes', Rule::in(['ar', 'en', 'fr'])],
            'theme' => ['sometimes', Rule::in(['light', 'dark', 'system'])],
            'primary_color' => ['sometimes', 'string', 'max:50'],
            'rtl_mode' => ['sometimes', 'boolean'],
            'preferred_video_player' => ['sometimes', Rule::in(['chewie', 'media_kit', 'simple_youtube', 'omni', 'orax_video_player'])],

            // Study Settings
            'daily_goal_minutes' => ['sometimes', 'integer', 'between:0,1440'],
            'show_streak_reminder' => ['sometimes', 'boolean'],
            'first_day_of_week' => ['sometimes', Rule::in(['saturday', 'sunday', 'monday'])],

            // Privacy Settings
            'profile_public' => ['sometimes', 'boolean'],
            'show_statistics' => ['sometimes', 'boolean'],
            'allow_friend_requests' => ['sometimes', 'boolean'],

            // Data & Storage
            'auto_backup' => ['sometimes', 'boolean'],
            'download_on_wifi_only' => ['sometimes', 'boolean'],
            'backup_frequency' => ['sometimes', Rule::in(['daily', 'weekly', 'monthly'])],
        ];
    }

    /**
     * Get custom attributes for validator errors.
     *
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return [
            'language' => 'اللغة',
            'theme' => 'المظهر',
            'daily_goal_minutes' => 'الهدف اليومي',
            'calculation_method' => 'طريقة الحساب',
            'madhab' => 'المذهب',
        ];
    }
}
