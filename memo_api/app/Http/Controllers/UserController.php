<?php

namespace App\Http\Controllers;

use App\Services\UserService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Models\UserPreferences;
use App\Models\UserActivityLog;

class UserController extends Controller
{
    protected $userService;

    public function __construct(UserService $userService)
    {
        $this->userService = $userService;
    }

    /**
     * Get complete user profile.
     *
     * GET /api/v1/user/profile
     */
    public function getProfile()
    {
        $user = auth()->user()->load([
            'userProfile',
            'academicProfile.academicYear',
            'academicProfile.academicStream',
            'stats',
        ]);

        return response()->json([
            'success' => true,
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'avatar_url' => $user->profile_image,
                    'phone' => $user->phone,
                    'device_name' => $user->device_name,
                ],
                'academic_profile' => [
                    'phase' => $user->academicProfile?->academicYear?->academicPhase?->name_ar,
                    'year' => $user->academicProfile?->academicYear?->name_ar,
                    'stream' => $user->academicProfile?->academicStream?->name_ar,
                ],
                'stats' => [
                    'total_study_hours' => round(($user->stats->total_study_minutes ?? 0) / 60, 1),
                    'current_streak' => $user->stats->current_streak_days ?? 0,
                    'level' => $user->stats->level ?? 1,
                    'points' => $user->stats->gamification_points ?? 0,
                ],
            ],
        ]);
    }

    /**
     * Update user profile.
     *
     * PUT /api/v1/user/profile
     */
    public function updateProfile(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'nullable|string|min:3|max:255',
            'phone' => 'nullable|string|regex:/^\+213[0-9]{9}$/',
            'birth_date' => 'nullable|date|before:today',
            'gender' => 'nullable|in:male,female',
            'wilaya' => 'nullable|string|max:100',
            'city' => 'nullable|string|max:100',
            'bio' => 'nullable|string|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $this->userService->updateProfile(auth()->user(), $validator->validated());

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data' => $user,
        ]);
    }

    /**
     * Upload user avatar.
     *
     * POST /api/v1/user/avatar
     */
    public function uploadAvatar(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'avatar' => 'required|image|mimes:jpg,jpeg,png|max:2048', // 2MB max
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $avatarUrl = $this->userService->uploadAvatar(auth()->user(), $request->file('avatar'));

        return response()->json([
            'success' => true,
            'message' => 'Avatar uploaded successfully',
            'data' => [
                'avatar_url' => $avatarUrl,
            ],
        ]);
    }

    /**
     * Delete user avatar.
     *
     * DELETE /api/v1/user/avatar
     */
    public function deleteAvatar()
    {
        $deleted = $this->userService->deleteAvatar(auth()->user());

        return response()->json([
            'success' => $deleted,
            'message' => $deleted ? 'Avatar deleted successfully' : 'No avatar to delete',
        ]);
    }

    /**
     * Get user preferences.
     *
     * GET /api/v1/user/preferences
     */
    public function getPreferences()
    {
        $preferences = UserPreferences::firstOrCreate(['user_id' => auth()->id()]);

        return response()->json([
            'success' => true,
            'data' => $preferences,
        ]);
    }

    /**
     * Update user preferences.
     *
     * PUT /api/v1/user/preferences
     */
    public function updatePreferences(Request $request)
    {
        $validator = Validator::make($request->all(), [
            // Notifications
            'notifications_enabled' => 'nullable|boolean',
            'study_session_reminders' => 'nullable|boolean',
            'exam_reminders' => 'nullable|boolean',
            'daily_summary' => 'nullable|boolean',
            'weekly_summary' => 'nullable|boolean',
            // Display
            'theme' => 'nullable|in:light,dark,auto',
            'font_size' => 'nullable|in:small,medium,large',
            // Pomodoro
            'pomodoro_duration' => 'nullable|integer|min:15|max:60',
            'short_break_duration' => 'nullable|integer|min:5|max:20',
            'long_break_duration' => 'nullable|integer|min:10|max:30',
            'sessions_before_long_break' => 'nullable|integer|min:2|max:8',
            // Ramadan mode
            'ramadan_mode_enabled' => 'nullable|boolean',
            // Other
            'motivational_quotes_enabled' => 'nullable|boolean',
            'sound_effects_enabled' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $preferences = $this->userService->updatePreferences(auth()->user(), $validator->validated());

        return response()->json([
            'success' => true,
            'message' => 'Preferences updated successfully',
            'data' => $preferences,
        ]);
    }

    /**
     * Get user activity log.
     *
     * GET /api/v1/user/activity
     */
    public function getActivity(Request $request)
    {
        $perPage = $request->get('per_page', 20);
        $type = $request->get('type');

        $query = auth()->user()->activityLogs()->latest();

        if ($type) {
            $query->ofType($type);
        }

        $activities = $query->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $activities,
        ]);
    }

    /**
     * Export user data (GDPR compliance).
     *
     * GET /api/v1/user/export
     */
    public function exportData()
    {
        $jsonData = $this->userService->exportUserData(auth()->user());

        UserActivityLog::log(
            auth()->id(),
            'data_export',
            'User requested data export'
        );

        return response()->json([
            'success' => true,
            'data' => json_decode($jsonData, true),
        ]);
    }

    /**
     * Sync user data (offline sync).
     *
     * GET /api/v1/user/sync
     */
    public function getSyncData()
    {
        $user = auth()->user()->load([
            'userProfile',
            'academicProfile',
            'preferences',
            'subjects',
            'stats',
        ]);

        // Get recent data (last 30 days)
        $recentSessions = $user->studySessions()
            ->where('created_at', '>=', now()->subDays(30))
            ->with('subject')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'profile' => $user->toArray(),
                'recent_sessions' => $recentSessions,
                'sync_timestamp' => now()->toIso8601String(),
            ],
        ]);
    }

    /**
     * Post sync data (offline sync).
     *
     * POST /api/v1/user/sync
     */
    public function postSyncData(Request $request)
    {
        $result = $this->userService->syncUserData(auth()->user(), $request->all());

        return response()->json([
            'success' => true,
            'message' => 'Data synchronized successfully',
            'data' => $result,
        ]);
    }
}
