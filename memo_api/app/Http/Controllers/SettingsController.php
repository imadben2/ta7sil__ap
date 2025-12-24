<?php

namespace App\Http\Controllers;

use App\Http\Requests\UpdateSettingsRequest;
use App\Http\Resources\UserSettingsResource;
use App\Models\UserSettings;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SettingsController extends Controller
{
    /**
     * Get user settings.
     */
    public function getSettings(Request $request): JsonResponse
    {
        $user = $request->user();
        $settings = $user->settings;

        // Create default settings if they don't exist
        if (!$settings) {
            $settings = UserSettings::create(['user_id' => $user->id]);
        }

        return response()->json([
            'success' => true,
            'data' => new UserSettingsResource($settings),
        ]);
    }

    /**
     * Update all settings.
     */
    public function updateSettings(UpdateSettingsRequest $request): JsonResponse
    {
        $user = $request->user();
        $settings = $user->settings;

        if (!$settings) {
            $settings = UserSettings::create(['user_id' => $user->id]);
        }

        // Log incoming request
        \Log::info('🎬 SettingsController: Incoming settings update request', [
            'user_id' => $user->id,
            'request_data' => $request->validated(),
        ]);

        \Log::info('🎬 SettingsController: Current preferred_video_player', [
            'value' => $settings->preferred_video_player,
        ]);

        $settings->update($request->validated());

        \Log::info('🎬 SettingsController: Updated preferred_video_player', [
            'value' => $settings->fresh()->preferred_video_player,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث الإعدادات بنجاح',
            'data' => new UserSettingsResource($settings->fresh()),
        ]);
    }

    /**
     * Update notification settings.
     */
    public function updateNotificationSettings(Request $request): JsonResponse
    {
        $user = $request->user();
        $settings = $user->settings ?? UserSettings::create(['user_id' => $user->id]);

        $validated = $request->validate([
            'notify_new_memo' => 'sometimes|boolean',
            'notify_memo_due' => 'sometimes|boolean',
            'notify_revision_reminder' => 'sometimes|boolean',
            'notify_achievement' => 'sometimes|boolean',
            'notify_prayer_time' => 'sometimes|boolean',
            'notify_daily_goal' => 'sometimes|boolean',
            'notify_push' => 'sometimes|boolean',
            'notify_email' => 'sometimes|boolean',
            'notify_sms' => 'sometimes|boolean',
        ]);

        $settings->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث إعدادات الإشعارات بنجاح',
            'data' => $settings->getNotificationSettings(),
        ]);
    }

    /**
     * Update prayer times settings.
     */
    public function updatePrayerTimesSettings(Request $request): JsonResponse
    {
        $user = $request->user();
        $settings = $user->settings ?? UserSettings::create(['user_id' => $user->id]);

        $validated = $request->validate([
            'prayer_times_enabled' => 'sometimes|boolean',
            'calculation_method' => 'sometimes|in:egyptian,mwl,isna,makkah,karachi,tehran,jafari',
            'madhab' => 'sometimes|in:shafi,hanafi',
            'fajr_adjustment' => 'sometimes|integer|between:-30,30',
            'dhuhr_adjustment' => 'sometimes|integer|between:-30,30',
            'asr_adjustment' => 'sometimes|integer|between:-30,30',
            'maghrib_adjustment' => 'sometimes|integer|between:-30,30',
            'isha_adjustment' => 'sometimes|integer|between:-30,30',
            'notify_fajr' => 'sometimes|boolean',
            'notify_dhuhr' => 'sometimes|boolean',
            'notify_asr' => 'sometimes|boolean',
            'notify_maghrib' => 'sometimes|boolean',
            'notify_isha' => 'sometimes|boolean',
            'prayer_notification_before' => 'sometimes|integer|between:0,60',
        ]);

        $settings->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث إعدادات أوقات الصلاة بنجاح',
            'data' => $settings->getPrayerTimesSettings(),
        ]);
    }

    /**
     * Update language preference.
     */
    public function updateLanguage(Request $request): JsonResponse
    {
        $user = $request->user();
        $settings = $user->settings ?? UserSettings::create(['user_id' => $user->id]);

        $validated = $request->validate([
            'language' => 'required|in:ar,en,fr',
        ]);

        $settings->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث اللغة بنجاح',
            'data' => [
                'language' => $settings->language,
            ],
        ]);
    }

    /**
     * Update theme preference.
     */
    public function updateTheme(Request $request): JsonResponse
    {
        $user = $request->user();
        $settings = $user->settings ?? UserSettings::create(['user_id' => $user->id]);

        $validated = $request->validate([
            'theme' => 'required|in:light,dark,system',
            'primary_color' => 'sometimes|string|max:50',
        ]);

        $settings->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث المظهر بنجاح',
            'data' => [
                'theme' => $settings->theme,
                'primary_color' => $settings->primary_color,
            ],
        ]);
    }

    /**
     * Update study settings.
     */
    public function updateStudySettings(Request $request): JsonResponse
    {
        $user = $request->user();
        $settings = $user->settings ?? UserSettings::create(['user_id' => $user->id]);

        $validated = $request->validate([
            'daily_goal_minutes' => 'sometimes|integer|between:0,1440',
            'show_streak_reminder' => 'sometimes|boolean',
            'first_day_of_week' => 'sometimes|in:saturday,sunday,monday',
        ]);

        $settings->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث إعدادات الدراسة بنجاح',
            'data' => $settings->getStudySettings(),
        ]);
    }

    /**
     * Update privacy settings.
     */
    public function updatePrivacySettings(Request $request): JsonResponse
    {
        $user = $request->user();
        $settings = $user->settings ?? UserSettings::create(['user_id' => $user->id]);

        $validated = $request->validate([
            'profile_public' => 'sometimes|boolean',
            'show_statistics' => 'sometimes|boolean',
            'allow_friend_requests' => 'sometimes|boolean',
        ]);

        $settings->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث إعدادات الخصوصية بنجاح',
            'data' => $settings->getPrivacySettings(),
        ]);
    }
}
