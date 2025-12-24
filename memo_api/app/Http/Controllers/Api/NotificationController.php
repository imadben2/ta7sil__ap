<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\FcmToken;
use App\Models\Notification;
use App\Models\UserNotificationSetting;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class NotificationController extends Controller
{
    /**
     * Get user notifications with pagination.
     *
     * @param  Request  $request
     * @return JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $query = Notification::where('user_id', $user->id)
            ->orderBy('created_at', 'desc');

        // Filter by read/unread
        if ($request->has('filter')) {
            if ($request->filter === 'unread') {
                $query->whereNull('read_at');
            } elseif ($request->filter === 'read') {
                $query->whereNotNull('read_at');
            }
        }

        // Filter by type
        if ($request->has('type')) {
            $query->where('type', $request->type);
        }

        $notifications = $query->paginate($request->get('per_page', 20));

        return response()->json([
            'success' => true,
            'data' => $notifications,
            'unread_count' => Notification::where('user_id', $user->id)
                ->whereNull('read_at')
                ->count(),
        ]);
    }

    /**
     * Mark notification as read.
     *
     * @param  int  $id
     * @param  Request  $request
     * @return JsonResponse
     */
    public function markAsRead(int $id, Request $request): JsonResponse
    {
        $user = $request->user();

        $notification = Notification::where('id', $id)
            ->where('user_id', $user->id)
            ->firstOrFail();

        $notification->markAsRead();

        return response()->json([
            'success' => true,
            'message' => 'Notification marked as read',
            'data' => $notification,
        ]);
    }

    /**
     * Mark all notifications as read.
     *
     * @param  Request  $request
     * @return JsonResponse
     */
    public function markAllAsRead(Request $request): JsonResponse
    {
        $user = $request->user();

        $count = Notification::where('user_id', $user->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return response()->json([
            'success' => true,
            'message' => "{$count} notifications marked as read",
            'count' => $count,
        ]);
    }

    /**
     * Get user notification settings.
     *
     * @param  Request  $request
     * @return JsonResponse
     */
    public function getSettings(Request $request): JsonResponse
    {
        $user = $request->user();

        $settings = $user->notificationSettings;

        if (!$settings) {
            // Create default settings if not exist
            $settings = UserNotificationSetting::create([
                'user_id' => $user->id,
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => $settings,
        ]);
    }

    /**
     * Update user notification settings.
     *
     * @param  Request  $request
     * @return JsonResponse
     */
    public function updateSettings(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'notifications_enabled' => 'sometimes|boolean',
            'study_reminders' => 'sometimes|boolean',
            'exam_reminders' => 'sometimes|boolean',
            'daily_summary' => 'sometimes|boolean',
            'weekly_summary' => 'sometimes|boolean',
            'motivational_quotes' => 'sometimes|boolean',
            'course_updates' => 'sometimes|boolean',
            'quiet_hours_enabled' => 'sometimes|boolean',
            'quiet_start_time' => 'nullable|date_format:H:i',
            'quiet_end_time' => 'nullable|date_format:H:i',
        ]);

        $settings = $user->notificationSettings;

        if (!$settings) {
            $settings = UserNotificationSetting::create(array_merge(
                ['user_id' => $user->id],
                $validated
            ));
        } else {
            $settings->update($validated);
        }

        return response()->json([
            'success' => true,
            'message' => 'Notification settings updated successfully',
            'data' => $settings->fresh(),
        ]);
    }

    /**
     * Delete a notification.
     *
     * @param  int  $id
     * @param  Request  $request
     * @return JsonResponse
     */
    public function destroy(int $id, Request $request): JsonResponse
    {
        $user = $request->user();

        $notification = Notification::where('id', $id)
            ->where('user_id', $user->id)
            ->firstOrFail();

        $notification->delete();

        return response()->json([
            'success' => true,
            'message' => 'Notification deleted successfully',
        ]);
    }

    /**
     * Get unread notification count.
     *
     * @param  Request  $request
     * @return JsonResponse
     */
    public function unreadCount(Request $request): JsonResponse
    {
        $user = $request->user();

        $count = Notification::where('user_id', $user->id)
            ->whereNull('read_at')
            ->count();

        return response()->json([
            'success' => true,
            'count' => $count,
        ]);
    }

    /**
     * Register FCM device token.
     *
     * @param  Request  $request
     * @return JsonResponse
     */
    public function registerDevice(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'fcm_token' => 'required|string|max:255',
            'device_uuid' => 'required|string|max:255',
            'device_platform' => 'required|in:android,ios',
        ]);

        try {
            // Check if token already exists for any user
            $existingToken = FcmToken::where('token', $validated['fcm_token'])->first();

            if ($existingToken) {
                // If token exists for different user, update ownership
                if ($existingToken->user_id !== $user->id) {
                    $existingToken->update([
                        'user_id' => $user->id,
                        'device_uuid' => $validated['device_uuid'],
                        'device_platform' => $validated['device_platform'],
                        'is_active' => true,
                        'last_used_at' => now(),
                    ]);
                } else {
                    // Token exists for same user, just update
                    $existingToken->update([
                        'device_uuid' => $validated['device_uuid'],
                        'device_platform' => $validated['device_platform'],
                        'is_active' => true,
                        'last_used_at' => now(),
                    ]);
                }

                $fcmToken = $existingToken;
            } else {
                // Check if device already has a token for this user
                $existingDeviceToken = FcmToken::where('user_id', $user->id)
                    ->where('device_uuid', $validated['device_uuid'])
                    ->first();

                if ($existingDeviceToken) {
                    // Update existing device token
                    $existingDeviceToken->update([
                        'token' => $validated['fcm_token'],
                        'device_platform' => $validated['device_platform'],
                        'is_active' => true,
                        'last_used_at' => now(),
                    ]);
                    $fcmToken = $existingDeviceToken;
                } else {
                    // Create new token
                    $fcmToken = FcmToken::create([
                        'user_id' => $user->id,
                        'token' => $validated['fcm_token'],
                        'device_uuid' => $validated['device_uuid'],
                        'device_platform' => $validated['device_platform'],
                        'is_active' => true,
                        'last_used_at' => now(),
                    ]);
                }
            }

            // Ensure user has notification settings
            if (!$user->notificationSettings) {
                UserNotificationSetting::create([
                    'user_id' => $user->id,
                ]);
            }

            Log::info("FCM token registered for user {$user->id}", [
                'device_uuid' => $validated['device_uuid'],
                'platform' => $validated['device_platform'],
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Device registered successfully',
                'data' => [
                    'token_id' => $fcmToken->id,
                    'is_active' => $fcmToken->is_active,
                ],
            ]);

        } catch (\Exception $e) {
            Log::error("Failed to register FCM token", [
                'user_id' => $user->id,
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to register device',
            ], 500);
        }
    }

    /**
     * Unregister FCM device token (logout).
     *
     * @param  Request  $request
     * @return JsonResponse
     */
    public function unregisterDevice(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'device_uuid' => 'required|string|max:255',
        ]);

        try {
            $deleted = FcmToken::where('user_id', $user->id)
                ->where('device_uuid', $validated['device_uuid'])
                ->update(['is_active' => false]);

            Log::info("FCM token unregistered for user {$user->id}", [
                'device_uuid' => $validated['device_uuid'],
                'tokens_deactivated' => $deleted,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Device unregistered successfully',
                'tokens_deactivated' => $deleted,
            ]);

        } catch (\Exception $e) {
            Log::error("Failed to unregister FCM token", [
                'user_id' => $user->id,
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to unregister device',
            ], 500);
        }
    }

    /**
     * Refresh FCM token (when token changes).
     *
     * @param  Request  $request
     * @return JsonResponse
     */
    public function refreshToken(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'old_token' => 'required|string|max:255',
            'new_token' => 'required|string|max:255',
        ]);

        try {
            $fcmToken = FcmToken::where('user_id', $user->id)
                ->where('token', $validated['old_token'])
                ->first();

            if ($fcmToken) {
                $fcmToken->update([
                    'token' => $validated['new_token'],
                    'is_active' => true,
                    'last_used_at' => now(),
                ]);

                Log::info("FCM token refreshed for user {$user->id}");

                return response()->json([
                    'success' => true,
                    'message' => 'Token refreshed successfully',
                ]);
            }

            return response()->json([
                'success' => false,
                'message' => 'Old token not found',
            ], 404);

        } catch (\Exception $e) {
            Log::error("Failed to refresh FCM token", [
                'user_id' => $user->id,
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to refresh token',
            ], 500);
        }
    }

    /**
     * Get user's registered devices.
     *
     * @param  Request  $request
     * @return JsonResponse
     */
    public function getDevices(Request $request): JsonResponse
    {
        $user = $request->user();

        $devices = FcmToken::where('user_id', $user->id)
            ->select('id', 'device_uuid', 'device_platform', 'is_active', 'last_used_at', 'created_at')
            ->orderBy('last_used_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $devices,
        ]);
    }
}
