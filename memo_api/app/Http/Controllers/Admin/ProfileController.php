<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AppSetting;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rules\Password;

class ProfileController extends Controller
{
    /**
     * Display the user's profile
     */
    public function index()
    {
        return view('admin.profile.index');
    }

    /**
     * Show the form for editing the profile
     */
    public function edit()
    {
        return view('admin.profile.edit');
    }

    /**
     * Update the user's profile information
     */
    public function update(Request $request)
    {
        $user = Auth::user();

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users,email,' . $user->id],
            'phone' => ['nullable', 'string', 'max:20'],
            'date_of_birth' => ['nullable', 'date'],
            'bio' => ['nullable', 'string', 'max:500'],
            'profile_picture' => ['nullable', 'image', 'max:2048'], // 2MB max
        ]);

        // Handle profile picture upload
        if ($request->hasFile('profile_picture')) {
            // Delete old picture if exists
            if ($user->profile_picture) {
                Storage::delete($user->profile_picture);
            }

            $path = $request->file('profile_picture')->store('profile-pictures', 'public');
            $validated['profile_picture'] = $path;
        }

        $user->update($validated);

        return redirect()
            ->route('admin.profile.index')
            ->with('success', 'تم تحديث الملف الشخصي بنجاح');
    }

    /**
     * Update profile picture
     */
    public function updatePicture(Request $request)
    {
        $request->validate([
            'profile_picture' => ['required', 'image', 'max:2048'],
        ]);

        $user = Auth::user();

        // Delete old picture if exists
        if ($user->profile_picture) {
            Storage::delete($user->profile_picture);
        }

        $path = $request->file('profile_picture')->store('profile-pictures', 'public');
        $user->update(['profile_picture' => $path]);

        return redirect()
            ->route('admin.profile.index')
            ->with('success', 'تم تحديث صورة الملف الشخصي بنجاح');
    }

    /**
     * Delete profile picture
     */
    public function deletePicture()
    {
        $user = Auth::user();

        if ($user->profile_picture) {
            Storage::delete($user->profile_picture);
            $user->update(['profile_picture' => null]);
        }

        return redirect()
            ->route('admin.profile.index')
            ->with('success', 'تم حذف صورة الملف الشخصي بنجاح');
    }

    /**
     * Show the form for changing password
     */
    public function showChangePassword()
    {
        return view('admin.profile.change-password');
    }

    /**
     * Update the user's password
     */
    public function updatePassword(Request $request)
    {
        $validated = $request->validate([
            'current_password' => ['required', 'string'],
            'new_password' => ['required', 'string', Password::min(8)->mixedCase()->numbers()->symbols(), 'confirmed'],
        ]);

        $user = Auth::user();

        // Verify current password
        if (!Hash::check($request->current_password, $user->password)) {
            return back()->withErrors(['current_password' => 'كلمة المرور الحالية غير صحيحة']);
        }

        // Update password
        $user->update([
            'password' => Hash::make($request->new_password),
        ]);

        return redirect()
            ->route('admin.profile.index')
            ->with('success', 'تم تحديث كلمة المرور بنجاح');
    }

    /**
     * Show device management page
     */
    public function devices()
    {
        $user = Auth::user();

        return view('admin.profile.devices', [
            'currentDevice' => [
                'id' => $user->device_id,
                'name' => $user->device_name,
                'platform' => $user->device_platform ?? 'Unknown',
                'last_used' => $user->last_login_at ?? now(),
            ],
        ]);
    }

    /**
     * Show activity log
     */
    public function activity()
    {
        return view('admin.profile.activity');
    }

    /**
     * Show settings page
     */
    public function settings()
    {
        $user = Auth::user();

        // Get or create user settings
        $userSettings = $user->settings()->firstOrCreate(
            ['user_id' => $user->id],
            [
                // Notification Settings
                'notify_new_memo' => true,
                'notify_memo_due' => true,
                'notify_revision_reminder' => true,
                'notify_achievement' => true,
                'notify_prayer_time' => false,
                'notify_daily_goal' => true,

                // Notification Channels
                'notify_push' => true,
                'notify_email' => false,
                'notify_sms' => false,

                // Prayer Times
                'prayer_times_enabled' => false,
                'calculation_method' => 'egyptian',
                'madhab' => 'shafi',
                'prayer_notification_before' => 15,

                // Appearance
                'language' => 'ar',
                'theme' => 'system',
                'primary_color' => 'blue',
                'rtl_mode' => true,

                // Study Settings
                'daily_goal_minutes' => 120,
                'show_streak_reminder' => true,
                'first_day_of_week' => 'saturday',

                // Privacy
                'profile_public' => false,
                'show_statistics' => true,
                'allow_friend_requests' => true,

                // Data & Storage
                'auto_backup' => false,
                'download_on_wifi_only' => true,
                'backup_frequency' => 'weekly',
            ]
        );

        // Get app settings
        $appSettings = [
            'min_app_version' => AppSetting::getMinAppVersion(),
            'timezone' => AppSetting::getTimezone(),
        ];

        // Get Google Sign-In settings
        $googleSettings = AppSetting::getGoogleSettings();

        // Get list of common timezones
        $timezones = [
            'Africa/Algiers' => 'الجزائر (UTC+1)',
            'Africa/Cairo' => 'مصر (UTC+2)',
            'Africa/Casablanca' => 'المغرب (UTC+0/+1)',
            'Africa/Tunis' => 'تونس (UTC+1)',
            'Africa/Tripoli' => 'ليبيا (UTC+2)',
            'Asia/Riyadh' => 'السعودية (UTC+3)',
            'Asia/Dubai' => 'الإمارات (UTC+4)',
            'Asia/Kuwait' => 'الكويت (UTC+3)',
            'Asia/Qatar' => 'قطر (UTC+3)',
            'Asia/Bahrain' => 'البحرين (UTC+3)',
            'Asia/Amman' => 'الأردن (UTC+2/+3)',
            'Asia/Baghdad' => 'العراق (UTC+3)',
            'Asia/Beirut' => 'لبنان (UTC+2/+3)',
            'Asia/Damascus' => 'سوريا (UTC+2/+3)',
            'Asia/Jerusalem' => 'فلسطين (UTC+2/+3)',
            'Europe/Paris' => 'فرنسا (UTC+1/+2)',
            'Europe/London' => 'بريطانيا (UTC+0/+1)',
            'UTC' => 'التوقيت العالمي (UTC)',
        ];

        return view('admin.profile.settings', compact('userSettings', 'appSettings', 'timezones', 'googleSettings'));
    }

    /**
     * Update settings
     */
    public function updateSettings(Request $request)
    {
        $validated = $request->validate([
            // App Settings
            'min_app_version' => ['nullable', 'string', 'regex:/^\d+(\.\d+)*$/'],
            'timezone' => ['nullable', 'string', 'timezone'],

            // Google Sign-In Settings
            'google_signin_enabled' => ['nullable', 'boolean'],
            'google_client_id' => ['nullable', 'string', 'max:255'],
            'google_ios_client_id' => ['nullable', 'string', 'max:255'],
            'google_android_client_id' => ['nullable', 'string', 'max:255'],

            // Notification Types
            'notify_new_memo' => ['nullable', 'boolean'],
            'notify_memo_due' => ['nullable', 'boolean'],
            'notify_revision_reminder' => ['nullable', 'boolean'],
            'notify_achievement' => ['nullable', 'boolean'],
            'notify_prayer_time' => ['nullable', 'boolean'],
            'notify_daily_goal' => ['nullable', 'boolean'],

            // Notification Channels
            'notify_push' => ['nullable', 'boolean'],
            'notify_email' => ['nullable', 'boolean'],
            'notify_sms' => ['nullable', 'boolean'],

            // Prayer Times Settings
            'prayer_times_enabled' => ['nullable', 'boolean'],
            'calculation_method' => ['nullable', 'string', 'in:egyptian,mwl,isna,umm_alqura'],
            'madhab' => ['nullable', 'string', 'in:shafi,hanafi'],
            'notify_fajr' => ['nullable', 'boolean'],
            'notify_dhuhr' => ['nullable', 'boolean'],
            'notify_asr' => ['nullable', 'boolean'],
            'notify_maghrib' => ['nullable', 'boolean'],
            'notify_isha' => ['nullable', 'boolean'],
            'prayer_notification_before' => ['nullable', 'integer', 'in:5,10,15,30'],

            // Appearance Settings
            'theme' => ['nullable', 'string', 'in:light,dark,system'],
            'primary_color' => ['nullable', 'string', 'in:blue,green,purple,red,orange,pink,indigo,teal'],
            'language' => ['nullable', 'string', 'in:ar,en,fr'],
            'rtl_mode' => ['nullable', 'boolean'],

            // Study Settings
            'daily_goal_minutes' => ['nullable', 'integer', 'min:15', 'max:600'],
            'first_day_of_week' => ['nullable', 'string', 'in:saturday,sunday,monday'],
            'show_streak_reminder' => ['nullable', 'boolean'],

            // Privacy Settings
            'profile_public' => ['nullable', 'boolean'],
            'show_statistics' => ['nullable', 'boolean'],
            'allow_friend_requests' => ['nullable', 'boolean'],

            // Data & Storage Settings
            'auto_backup' => ['nullable', 'boolean'],
            'download_on_wifi_only' => ['nullable', 'boolean'],
            'backup_frequency' => ['nullable', 'string', 'in:daily,weekly,monthly'],
        ]);

        // Update app settings (min_app_version)
        if ($request->filled('min_app_version')) {
            AppSetting::setValue('min_app_version', $request->input('min_app_version'));
        }

        // Update timezone setting
        if ($request->filled('timezone')) {
            AppSetting::setTimezone($request->input('timezone'));
        }

        // Update Google Sign-In settings
        AppSetting::updateGoogleSettings([
            'enabled' => $request->has('google_signin_enabled'),
            'client_id' => $request->input('google_client_id'),
            'ios_client_id' => $request->input('google_ios_client_id'),
            'android_client_id' => $request->input('google_android_client_id'),
        ]);

        $user = Auth::user();

        // Convert checkbox values (checkboxes not checked won't be in request)
        $booleanFields = [
            'notify_new_memo', 'notify_memo_due', 'notify_revision_reminder', 'notify_achievement',
            'notify_prayer_time', 'notify_daily_goal', 'notify_push', 'notify_email', 'notify_sms',
            'prayer_times_enabled', 'notify_fajr', 'notify_dhuhr', 'notify_asr', 'notify_maghrib',
            'notify_isha', 'rtl_mode', 'show_streak_reminder', 'profile_public', 'show_statistics',
            'allow_friend_requests', 'auto_backup', 'download_on_wifi_only'
        ];

        foreach ($booleanFields as $field) {
            $validated[$field] = $request->has($field) ? true : false;
        }

        // Update or create user settings
        $user->settings()->updateOrCreate(
            ['user_id' => $user->id],
            $validated
        );

        return back()->with('success', 'تم تحديث الإعدادات بنجاح');
    }
}
