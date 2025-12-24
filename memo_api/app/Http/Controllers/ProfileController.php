<?php

namespace App\Http\Controllers;

use App\Http\Requests\UpdateProfileRequest;
use App\Http\Requests\ChangePasswordRequest;
use App\Http\Resources\ProfileResource;
use App\Http\Resources\UserStatsResource;
use App\Models\UserProfile;
use App\Models\UserAcademicProfile;
use App\Models\Subject;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Intervention\Image\Facades\Image;

class ProfileController extends Controller
{
    /**
     * Get user profile.
     *
     * GET /api/profile
     */
    public function getProfile()
    {
        $user = auth()->user()->load([
            'userProfile',
            'academicProfile.academicYear',
            'academicProfile.academicStream',
            'subjects',
            'stats',
            'settings',
        ]);

        return response()->json([
            'success' => true,
            'data' => new ProfileResource($user),
        ]);
    }

    /**
     * Update user profile.
     *
     * PUT /api/profile
     */
    public function updateProfile(UpdateProfileRequest $request)
    {
        $validated = $request->validated();
        $user = auth()->user();

        // Handle photo upload
        if ($request->hasFile('photo')) {
            // Delete old photo if exists
            if ($user->photo_url && Storage::disk('public')->exists($user->photo_url)) {
                Storage::disk('public')->delete($user->photo_url);
            }

            $photo = $request->file('photo');
            $filename = 'profile_' . $user->id . '_' . time() . '.' . $photo->getClientOriginalExtension();
            $path = $photo->storeAs('profiles', $filename, 'public');

            // Optionally compress image (requires intervention/image package)
            // $img = Image::make(storage_path('app/public/' . $path));
            // $img->fit(500, 500)->save();

            $validated['photo_url'] = $path;
        }

        // Update user basic info
        $userFields = ['name', 'email', 'phone_number', 'photo_url', 'bio',
                       'date_of_birth', 'gender', 'city', 'country', 'timezone',
                       'latitude', 'longitude'];

        $userData = array_intersect_key($validated, array_flip($userFields));

        if (!empty($userData)) {
            $user->update($userData);
        }

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث الملف الشخصي بنجاح',
            'data' => new ProfileResource($user->fresh()->load(['stats', 'settings'])),
        ]);
    }

    /**
     * Update academic profile.
     *
     * POST /api/profile/academic
     */
    public function updateAcademicProfile(Request $request)
    {
        $validated = $request->validate([
            'academic_phase_id' => 'required|exists:academic_phases,id',
            'academic_year_id' => 'required|exists:academic_years,id',
            'stream_id' => 'nullable|exists:academic_streams,id',
        ]);

        $user = auth()->user();

        // Update or create academic profile
        UserAcademicProfile::updateOrCreate(
            ['user_id' => $user->id],
            [
                'academic_phase_id' => $validated['academic_phase_id'],
                'academic_year_id' => $validated['academic_year_id'],
                'academic_stream_id' => $validated['stream_id'] ?? null,
            ]
        );

        // Refresh user with academic profile
        $user = $user->fresh()->load('academicProfile');

        // Flatten academic profile data into user object for Flutter compatibility
        $userData = $user->toArray();
        if ($user->academicProfile) {
            $userData['academic_phase_id'] = $user->academicProfile->academic_phase_id;
            $userData['academic_year_id'] = $user->academicProfile->academic_year_id;
            $userData['stream_id'] = $user->academicProfile->academic_stream_id;
        }

        return response()->json([
            'success' => true,
            'message' => 'Academic profile updated successfully',
            'data' => $userData,
        ]);
    }

    /**
     * Get user's selected subjects.
     *
     * GET /api/profile/subjects
     */
    public function getSubjects()
    {
        $subjects = auth()->user()->subjects()->with('academicStream')->get();

        return response()->json([
            'success' => true,
            'data' => $subjects,
        ]);
    }

    /**
     * Update user's selected subjects.
     *
     * POST /api/profile/subjects
     */
    public function updateSubjects(Request $request)
    {
        $validated = $request->validate([
            'subject_ids' => 'required|array',
            'subject_ids.*' => 'exists:subjects,id',
        ]);

        $user = auth()->user();

        // Verify all subjects belong to user's stream
        if ($user->academicProfile && $user->academicProfile->academic_stream_id) {
            $invalidSubjects = Subject::whereIn('id', $validated['subject_ids'])
                ->where('academic_stream_id', '!=', $user->academicProfile->academic_stream_id)
                ->exists();

            if ($invalidSubjects) {
                return response()->json([
                    'success' => false,
                    'message' => 'One or more subjects do not belong to your academic stream',
                ], 400);
            }
        }

        // Sync subjects
        $user->subjects()->sync($validated['subject_ids']);

        return response()->json([
            'success' => true,
            'message' => 'Subjects updated successfully',
            'data' => $user->subjects()->with('academicStream')->get(),
        ]);
    }

    /**
     * Change password.
     *
     * POST /api/profile/change-password
     */
    public function changePassword(ChangePasswordRequest $request)
    {
        $validated = $request->validated();
        $user = auth()->user();

        if (!Hash::check($validated['current_password'], $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'كلمة المرور الحالية غير صحيحة',
            ], 400);
        }

        $user->update([
            'password' => Hash::make($validated['new_password']),
        ]);

        // Optionally logout from all other devices
        if ($request->boolean('logout_others', false)) {
            $user->tokens()->where('id', '!=', $user->currentAccessToken()->id)->delete();
        }

        return response()->json([
            'success' => true,
            'message' => 'تم تغيير كلمة المرور بنجاح',
        ]);
    }

    /**
     * Get user statistics.
     *
     * GET /api/profile/stats
     */
    public function getStats()
    {
        $user = auth()->user();
        $stats = $user->stats;

        if (!$stats) {
            return response()->json([
                'success' => true,
                'data' => [
                    'total_study_time_minutes' => 0,
                    'total_sessions' => 0,
                    'contents_completed' => 0,
                    'quizzes_completed' => 0,
                    'average_quiz_score' => 0,
                    'current_streak_days' => 0,
                    'longest_streak_days' => 0,
                    'total_points' => 0,
                    'achievements_unlocked' => 0,
                ],
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => new UserStatsResource($stats),
        ]);
    }

    /**
     * Delete account.
     *
     * POST /api/profile/delete-account
     */
    public function deleteAccount(Request $request)
    {
        $validated = $request->validate([
            'password' => 'required',
            'confirmation' => 'required|in:DELETE',
            'reason' => 'nullable|string|max:500',
        ]);

        $user = auth()->user();

        if (!Hash::check($validated['password'], $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'كلمة المرور غير صحيحة',
            ], 400);
        }

        // Delete profile photo if exists
        if ($user->photo_url && Storage::disk('public')->exists($user->photo_url)) {
            Storage::disk('public')->delete($user->photo_url);
        }

        // Delete all tokens and sessions
        $user->tokens()->delete();
        $user->deviceSessions()->delete();

        // Soft delete user (can be recovered by admin)
        // If you want hard delete, use $user->forceDelete();
        $user->delete();

        return response()->json([
            'success' => true,
            'message' => 'تم حذف الحساب بنجاح',
        ]);
    }

    /**
     * Upload profile photo separately.
     *
     * POST /api/profile/photo
     */
    public function uploadPhoto(Request $request)
    {
        $request->validate([
            'photo' => 'required|image|mimes:jpeg,png,jpg,webp|max:2048',
        ]);

        $user = auth()->user();

        // Delete old photo if exists
        if ($user->photo_url && Storage::disk('public')->exists($user->photo_url)) {
            Storage::disk('public')->delete($user->photo_url);
        }

        $photo = $request->file('photo');
        $filename = 'profile_' . $user->id . '_' . time() . '.' . $photo->getClientOriginalExtension();
        $path = $photo->storeAs('profiles', $filename, 'public');

        $user->update(['photo_url' => $path]);

        return response()->json([
            'success' => true,
            'message' => 'تم رفع الصورة بنجاح',
            'data' => new ProfileResource($user->fresh()->load(['stats', 'settings'])),
        ]);
    }

    /**
     * Export user data (GDPR compliance).
     *
     * POST /api/profile/export
     */
    public function exportData(Request $request)
    {
        $user = auth()->user()->load([
            'userProfile',
            'academicProfile',
            'subjects',
            'stats',
            'settings',
            'studySessions',
            'contentProgress',
            'quizAttempts',
            'achievements',
        ]);

        $exportData = [
            'personal_info' => [
                'name' => $user->name,
                'email' => $user->email,
                'phone_number' => $user->phone_number,
                'date_of_birth' => $user->date_of_birth,
                'gender' => $user->gender,
                'city' => $user->city,
                'country' => $user->country,
            ],
            'academic_profile' => $user->academicProfile,
            'subjects' => $user->subjects,
            'statistics' => $user->stats,
            'settings' => $user->settings,
            'study_sessions' => $user->studySessions,
            'content_progress' => $user->contentProgress,
            'quiz_attempts' => $user->quizAttempts,
            'achievements' => $user->achievements,
            'export_date' => now()->format('Y-m-d H:i:s'),
        ];

        return response()->json([
            'success' => true,
            'data' => $exportData,
            'message' => 'تم تصدير البيانات بنجاح',
        ]);
    }
}
