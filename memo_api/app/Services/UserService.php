<?php

namespace App\Services;

use App\Models\User;
use App\Models\UserProfile;
use App\Models\UserPreferences;
use App\Models\UserActivityLog;
use App\Models\UserSubject;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Intervention\Image\Facades\Image;
use Carbon\Carbon;

class UserService
{
    /**
     * Create a new user with profile.
     */
    public function createUser(array $data): User
    {
        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
            'phone' => $data['phone'] ?? null,
            'role' => $data['role'] ?? 'student',
            'is_active' => $data['is_active'] ?? true,
        ]);

        // Create user profile
        if (isset($data['date_of_birth']) || isset($data['gender']) || isset($data['wilaya'])) {
            UserProfile::create([
                'user_id' => $user->id,
                'date_of_birth' => $data['date_of_birth'] ?? null,
                'gender' => $data['gender'] ?? null,
                'wilaya' => $data['wilaya'] ?? null,
                'city' => $data['city'] ?? null,
            ]);
        }

        // Create default preferences
        UserPreferences::create(['user_id' => $user->id]);

        // Log activity
        UserActivityLog::log($user->id, UserActivityLog::TYPE_LOGIN, 'User account created');

        return $user->fresh(['userProfile', 'academicProfile']);
    }

    /**
     * Update user profile.
     */
    public function updateProfile(User $user, array $data): User
    {
        // Update user table
        $user->update(array_filter([
            'name' => $data['name'] ?? $user->name,
            'phone' => $data['phone'] ?? $user->phone,
        ]));

        // Update or create profile
        $profileData = array_filter([
            'date_of_birth' => $data['date_of_birth'] ?? null,
            'gender' => $data['gender'] ?? null,
            'wilaya' => $data['wilaya'] ?? null,
            'city' => $data['city'] ?? null,
            'bio' => $data['bio'] ?? null,
        ], fn($value) => !is_null($value));

        if (!empty($profileData)) {
            UserProfile::updateOrCreate(
                ['user_id' => $user->id],
                $profileData
            );
        }

        // Log activity
        UserActivityLog::log($user->id, UserActivityLog::TYPE_PROFILE_UPDATE, 'Profile updated');

        return $user->fresh(['userProfile']);
    }

    /**
     * Update user preferences.
     */
    public function updatePreferences(User $user, array $data): UserPreferences
    {
        $preferences = UserPreferences::firstOrCreate(['user_id' => $user->id]);

        $preferences->update(array_filter($data, fn($value) => !is_null($value)));

        return $preferences->fresh();
    }

    /**
     * Upload and process user avatar.
     */
    public function uploadAvatar(User $user, UploadedFile $file): string
    {
        // Delete old avatar if exists
        if ($user->profile_image) {
            $this->deleteAvatar($user);
        }

        // Generate unique filename
        $filename = 'avatar_' . $user->id . '_' . time() . '.' . $file->extension();
        $path = 'avatars/' . $filename;

        // Resize and save image (requires intervention/image package)
        // For now, we'll just store the file directly
        // In production, you would use Image::make($file)->fit(300, 300)->save(...)

        $file->storeAs('public/avatars', $filename);

        // Update user record
        $avatarUrl = Storage::url('avatars/' . $filename);
        $user->update(['profile_image' => $avatarUrl]);

        // Log activity
        UserActivityLog::log($user->id, UserActivityLog::TYPE_PROFILE_UPDATE, 'Avatar uploaded');

        return $avatarUrl;
    }

    /**
     * Delete user avatar.
     */
    public function deleteAvatar(User $user): bool
    {
        if ($user->profile_image) {
            $path = str_replace('/storage/', 'public/', $user->profile_image);

            if (Storage::exists($path)) {
                Storage::delete($path);
            }

            $user->update(['profile_image' => null]);

            // Log activity
            UserActivityLog::log($user->id, UserActivityLog::TYPE_PROFILE_UPDATE, 'Avatar deleted');

            return true;
        }

        return false;
    }

    /**
     * Calculate user statistics for a given period.
     */
    public function calculateUserStats(User $user, string $period = 'all'): array
    {
        $stats = $user->stats ?? new \App\Models\UserStats(['user_id' => $user->id]);

        $startDate = $this->getPeriodStartDate($period);

        // Get study sessions for period
        $studySessions = $user->studySessions()
            ->when($startDate, fn($q) => $q->where('created_at', '>=', $startDate))
            ->get();

        // Use actual_duration_minutes for completed sessions, estimated_duration_minutes for others
        $totalMinutes = $studySessions->sum(function ($session) {
            return $session->actual_duration_minutes ?? $session->estimated_duration_minutes ?? 0;
        });
        $sessionsCompleted = $studySessions->count();
        $averageDuration = $sessionsCompleted > 0 ? round($totalMinutes / $sessionsCompleted) : 0;

        // Get subjects breakdown
        $subjectsBreakdown = $user->studySessions()
            ->when($startDate, fn($q) => $q->where('created_at', '>=', $startDate))
            ->selectRaw('subject_id, SUM(COALESCE(actual_duration_minutes, estimated_duration_minutes, 0)) as total_minutes')
            ->groupBy('subject_id')
            ->with('subject:id,name_ar')
            ->get()
            ->map(function ($item) use ($totalMinutes) {
                return [
                    'subject' => $item->subject->name_ar ?? 'مادة غير معروفة',
                    'minutes' => $item->total_minutes,
                    'percentage' => $totalMinutes > 0 ? round(($item->total_minutes / $totalMinutes) * 100, 1) : 0,
                ];
            })
            ->sortByDesc('minutes')
            ->values()
            ->toArray();

        return [
            'overview' => [
                'total_study_hours' => round($stats->total_study_minutes / 60, 1),
                'current_streak' => $stats->current_streak_days,
                'longest_streak' => $stats->longest_streak_days,
                'level' => $stats->level,
                'points' => $stats->gamification_points,
                'next_level_points' => $this->getNextLevelPoints($stats->level),
            ],
            'period_stats' => [
                'period' => $period,
                'study_minutes' => $totalMinutes,
                'sessions_completed' => $sessionsCompleted,
                'average_session_duration' => $averageDuration,
                'best_subject' => $subjectsBreakdown[0]['subject'] ?? null,
            ],
            'subjects_breakdown' => $subjectsBreakdown,
        ];
    }

    /**
     * Get heatmap data for productivity calendar.
     */
    public function getHeatmapData(User $user, Carbon $start, Carbon $end): array
    {
        $sessions = $user->studySessions()
            ->whereBetween('started_at', [$start, $end])
            ->selectRaw('DATE(started_at) as date, SUM(duration_minutes) as minutes, COUNT(*) as sessions')
            ->groupBy('date')
            ->get();

        return $sessions->map(function ($item) {
            $intensity = 'low';
            if ($item->minutes >= 120) $intensity = 'very_high';
            elseif ($item->minutes >= 90) $intensity = 'high';
            elseif ($item->minutes >= 60) $intensity = 'medium';

            return [
                'date' => $item->date,
                'minutes' => $item->minutes,
                'sessions' => $item->sessions,
                'intensity' => $intensity,
            ];
        })->toArray();
    }

    /**
     * Sync user data (for offline sync).
     */
    public function syncUserData(User $user, array $data): array
    {
        // This is a placeholder for complex sync logic
        // In production, you would:
        // 1. Compare timestamps
        // 2. Resolve conflicts
        // 3. Merge data intelligently
        // 4. Return synchronized state

        return [
            'success' => true,
            'conflicts_resolved' => 0,
            'data_updated' => [],
        ];
    }

    /**
     * Deactivate user account.
     */
    public function deactivateUser(User $user, string $reason): bool
    {
        $user->update([
            'is_active' => false,
            'is_banned' => true,
            'banned_reason' => $reason,
            'banned_at' => now(),
        ]);

        // Revoke all tokens
        $user->tokens()->delete();

        // Log activity
        UserActivityLog::log($user->id, 'account_deactivated', $reason);

        return true;
    }

    /**
     * Export user data (GDPR compliance).
     */
    public function exportUserData(User $user): string
    {
        $data = [
            'user' => $user->toArray(),
            'profile' => $user->userProfile?->toArray(),
            'academic_profile' => $user->academicProfile?->toArray(),
            'preferences' => $user->preferences?->toArray(),
            'subjects' => $user->subjects->toArray(),
            'stats' => $user->stats?->toArray(),
            'study_sessions' => $user->studySessions()->recent(90)->get()->toArray(),
            'activity_log' => $user->activityLogs()->recent(90)->get()->toArray(),
        ];

        return json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    }

    /**
     * Get period start date.
     */
    private function getPeriodStartDate(string $period): ?Carbon
    {
        return match($period) {
            'week' => now()->startOfWeek(),
            'month' => now()->startOfMonth(),
            'year' => now()->startOfYear(),
            default => null,
        };
    }

    /**
     * Get points required for next level.
     */
    private function getNextLevelPoints(?int $currentLevel): int
    {
        // Default to level 1 if null
        $currentLevel = $currentLevel ?? 1;

        $levels = [
            1 => 100,
            2 => 300,
            3 => 600,
            4 => 1000,
            5 => 1500,
            6 => 2100,
            7 => 2800,
            8 => 3600,
            9 => 4500,
            10 => 5500,
        ];

        return $levels[$currentLevel + 1] ?? ($currentLevel + 1) * 1000;
    }
}
