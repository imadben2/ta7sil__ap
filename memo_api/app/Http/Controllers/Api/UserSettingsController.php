<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\UserSettings;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;

class UserSettingsController extends Controller
{
    /**
     * Get user settings
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        // Get or create user settings
        $settings = UserSettings::firstOrCreate(
            ['user_id' => $user->id],
            [
                // Default values will be set by database defaults
            ]
        );

        return response()->json([
            'success' => true,
            'data' => [
                'settings' => $settings,
            ],
        ]);
    }

    /**
     * Update user settings
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function update(Request $request): JsonResponse
    {
        $user = $request->user();

        // Log incoming request
        \Log::info('🎬 API: Incoming settings update request', [
            'user_id' => $user->id,
            'request_data' => $request->all(),
        ]);

        // Validate request
        $validator = Validator::make($request->all(), [
            // Notification Settings
            'notify_new_memo' => 'sometimes|boolean',
            'notify_memo_due' => 'sometimes|boolean',
            'notify_revision_reminder' => 'sometimes|boolean',
            'notify_achievement' => 'sometimes|boolean',
            'notify_prayer_time' => 'sometimes|boolean',
            'notify_daily_goal' => 'sometimes|boolean',
            // Notification Channels
            'notify_push' => 'sometimes|boolean',
            'notify_email' => 'sometimes|boolean',
            'notify_sms' => 'sometimes|boolean',
            // Prayer Times Settings
            'prayer_times_enabled' => 'sometimes|boolean',
            'calculation_method' => 'sometimes|string|in:egyptian,mwl,isna,karachi,makkah,tehran',
            'madhab' => 'sometimes|string|in:shafi,hanafi',
            'fajr_adjustment' => 'sometimes|integer|between:-30,30',
            'dhuhr_adjustment' => 'sometimes|integer|between:-30,30',
            'asr_adjustment' => 'sometimes|integer|between:-30,30',
            'maghrib_adjustment' => 'sometimes|integer|between:-30,30',
            'isha_adjustment' => 'sometimes|integer|between:-30,30',
            // Prayer Notifications
            'notify_fajr' => 'sometimes|boolean',
            'notify_dhuhr' => 'sometimes|boolean',
            'notify_asr' => 'sometimes|boolean',
            'notify_maghrib' => 'sometimes|boolean',
            'notify_isha' => 'sometimes|boolean',
            'prayer_notification_before' => 'sometimes|integer|between:0,60',
            // App Preferences
            'language' => 'sometimes|string|in:ar,fr,en',
            'theme' => 'sometimes|string|in:light,dark,system',
            'primary_color' => 'sometimes|string',
            'rtl_mode' => 'sometimes|boolean',
            'preferred_video_player' => 'sometimes|string|in:chewie,media_kit,simple_youtube,omni,orax_video_player',
            // Study Settings
            'daily_goal_minutes' => 'sometimes|integer|min:0|max:1440',
            'show_streak_reminder' => 'sometimes|boolean',
            'first_day_of_week' => 'sometimes|string|in:saturday,sunday,monday',
            // Privacy Settings
            'profile_public' => 'sometimes|boolean',
            'show_statistics' => 'sometimes|boolean',
            'allow_friend_requests' => 'sometimes|boolean',
            // Data & Storage
            'auto_backup' => 'sometimes|boolean',
            'download_on_wifi_only' => 'sometimes|boolean',
            'backup_frequency' => 'sometimes|string|in:daily,weekly,monthly',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        // Get or create user settings
        $settings = UserSettings::firstOrCreate(
            ['user_id' => $user->id]
        );

        \Log::info('🎬 API: Settings found/created', [
            'settings_id' => $settings->id,
            'current_preferred_video_player' => $settings->preferred_video_player,
        ]);

        // Update settings
        $dataToUpdate = $request->only(array_keys($validator->validated()));
        \Log::info('🎬 API: Updating settings with data', ['data' => $dataToUpdate]);

        $settings->update($dataToUpdate);

        \Log::info('🎬 API: Settings updated successfully', [
            'new_preferred_video_player' => $settings->fresh()->preferred_video_player,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Settings updated successfully',
            'data' => [
                'settings' => $settings->fresh(),
            ],
        ]);
    }
}
