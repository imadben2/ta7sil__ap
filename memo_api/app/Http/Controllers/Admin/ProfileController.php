<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AppSetting;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\File;
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

        // Get video player settings
        $videoPlayerSettings = AppSetting::getVideoPlayerSettings();

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

        return view('admin.profile.settings', compact('userSettings', 'appSettings', 'timezones', 'googleSettings', 'videoPlayerSettings'));
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

            // Video Players Settings
            'video_player_chewie_enabled' => ['nullable', 'boolean'],
            'video_player_media_kit_enabled' => ['nullable', 'boolean'],
            'video_player_simple_youtube_enabled' => ['nullable', 'boolean'],
            'video_player_omni_enabled' => ['nullable', 'boolean'],
            'video_player_orax_enabled' => ['nullable', 'boolean'],
            'default_upload_player' => ['nullable', 'string', 'in:chewie,media_kit,simple_youtube,omni,orax'],
            'default_youtube_player' => ['nullable', 'string', 'in:chewie,media_kit,simple_youtube,omni,orax'],

            // Video Players Support Type (youtube, upload, both)
            'video_player_chewie_supports' => ['nullable', 'string', 'in:youtube,upload,both'],
            'video_player_media_kit_supports' => ['nullable', 'string', 'in:youtube,upload,both'],
            'video_player_simple_youtube_supports' => ['nullable', 'string', 'in:youtube,upload,both'],
            'video_player_omni_supports' => ['nullable', 'string', 'in:youtube,upload,both'],
            'video_player_orax_supports' => ['nullable', 'string', 'in:youtube,upload,both'],
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

        // Update video player settings
        AppSetting::updateVideoPlayerSettings([
            'chewie_enabled' => $request->has('video_player_chewie_enabled'),
            'media_kit_enabled' => $request->has('video_player_media_kit_enabled'),
            'simple_youtube_enabled' => $request->has('video_player_simple_youtube_enabled'),
            'omni_enabled' => $request->has('video_player_omni_enabled'),
            'orax_enabled' => $request->has('video_player_orax_enabled'),
            'default_upload_player' => $request->input('default_upload_player', 'chewie'),
            'default_youtube_player' => $request->input('default_youtube_player', 'simple_youtube'),
            // Support types (youtube, upload, both)
            'chewie_supports' => $request->input('video_player_chewie_supports', 'upload'),
            'media_kit_supports' => $request->input('video_player_media_kit_supports', 'upload'),
            'simple_youtube_supports' => $request->input('video_player_simple_youtube_supports', 'youtube'),
            'omni_supports' => $request->input('video_player_omni_supports', 'both'),
            'orax_supports' => $request->input('video_player_orax_supports', 'both'),
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

    /**
     * Check if storage link exists
     */
    public function checkStorageLink()
    {
        $storagePath = public_path('storage');
        $targetPath = storage_path('app/public');

        $exists = false;
        $message = '';

        if (is_link($storagePath)) {
            // It's a symbolic link
            $linkTarget = readlink($storagePath);
            if ($linkTarget === $targetPath || realpath($storagePath) === realpath($targetPath)) {
                $exists = true;
                $message = 'الرابط الرمزي يعمل بشكل صحيح';
            } else {
                $message = 'الرابط موجود لكنه يشير إلى مسار خاطئ';
            }
        } elseif (is_dir($storagePath)) {
            // It's a directory (not a link)
            $message = 'المجلد موجود كمجلد عادي وليس رابط رمزي';
        } else {
            $message = 'رابط التخزين غير موجود';
        }

        return response()->json([
            'exists' => $exists,
            'message' => $message,
            'storage_path' => $storagePath,
            'target_path' => $targetPath,
        ]);
    }

    /**
     * List custom symlinks in storage/app/public/courses/videos
     */
    public function listSymlinks()
    {
        $videosPath = storage_path('app/public/courses/videos');
        $symlinks = [];

        if (File::exists($videosPath)) {
            $items = File::directories($videosPath);

            foreach ($items as $item) {
                $name = basename($item);
                $isLink = is_link($item) || (PHP_OS_FAMILY === 'Windows' && $this->isJunction($item));

                if ($isLink || File::isDirectory($item)) {
                    $target = null;
                    $valid = false;

                    if (is_link($item)) {
                        $target = readlink($item);
                        $valid = File::exists($target);
                    } elseif (PHP_OS_FAMILY === 'Windows' && $this->isJunction($item)) {
                        $target = $this->getJunctionTarget($item);
                        $valid = $target && File::exists($target);
                    } else {
                        // Regular directory
                        $target = $item;
                        $valid = true;
                    }

                    $symlinks[] = [
                        'name' => $name,
                        'path' => $item,
                        'target' => $target,
                        'valid' => $valid,
                        'is_link' => $isLink,
                    ];
                }
            }
        }

        return response()->json(['symlinks' => $symlinks]);
    }

    /**
     * Create a custom symlink
     */
    public function createSymlink(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255|regex:/^[a-zA-Z0-9_\-]+$/',
            'source' => 'required|string|max:500',
        ]);

        $name = $request->input('name');
        $source = $request->input('source');

        // Ensure videos directory exists
        $videosPath = storage_path('app/public/courses/videos');
        if (!File::exists($videosPath)) {
            File::makeDirectory($videosPath, 0755, true);
        }

        $linkPath = $videosPath . DIRECTORY_SEPARATOR . $name;

        // Check if source exists
        if (!File::exists($source)) {
            return response()->json([
                'success' => false,
                'message' => 'المجلد المصدر غير موجود: ' . $source,
            ]);
        }

        // Check if link already exists
        if (File::exists($linkPath) || is_link($linkPath)) {
            return response()->json([
                'success' => false,
                'message' => 'يوجد مجلد أو رابط بنفس الاسم بالفعل',
            ]);
        }

        try {
            if (PHP_OS_FAMILY === 'Windows') {
                // Use junction on Windows (doesn't require admin)
                $command = 'mklink /J "' . $linkPath . '" "' . $source . '"';
                exec($command, $output, $returnVar);

                if ($returnVar !== 0) {
                    // Try symlink as fallback
                    $command = 'mklink /D "' . $linkPath . '" "' . $source . '"';
                    exec($command, $output, $returnVar);
                }

                if ($returnVar !== 0) {
                    throw new \Exception('فشل في إنشاء الرابط. تأكد من تشغيل الخادم كمسؤول.');
                }
            } else {
                symlink($source, $linkPath);
            }

            return response()->json([
                'success' => true,
                'message' => 'تم إنشاء الرابط الرمزي بنجاح!',
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ: ' . $e->getMessage(),
            ]);
        }
    }

    /**
     * Delete a custom symlink
     */
    public function deleteSymlink(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
        ]);

        $name = $request->input('name');
        $videosPath = storage_path('app/public/courses/videos');
        $linkPath = $videosPath . DIRECTORY_SEPARATOR . $name;

        if (!File::exists($linkPath) && !is_link($linkPath)) {
            return response()->json([
                'success' => false,
                'message' => 'الرابط غير موجود',
            ]);
        }

        try {
            if (is_link($linkPath)) {
                unlink($linkPath);
            } elseif (PHP_OS_FAMILY === 'Windows' && $this->isJunction($linkPath)) {
                // Remove junction on Windows
                rmdir($linkPath);
            } else {
                // Don't delete regular directories
                return response()->json([
                    'success' => false,
                    'message' => 'هذا مجلد عادي وليس رابط رمزي. لا يمكن حذفه من هنا.',
                ]);
            }

            return response()->json([
                'success' => true,
                'message' => 'تم حذف الرابط بنجاح!',
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ: ' . $e->getMessage(),
            ]);
        }
    }

    /**
     * Check if a path is a Windows junction
     */
    private function isJunction($path)
    {
        if (PHP_OS_FAMILY !== 'Windows') {
            return false;
        }

        $attr = @shell_exec('fsutil reparsepoint query "' . $path . '" 2>nul');
        return strpos($attr, 'Symbolic Link') !== false || strpos($attr, 'Mount Point') !== false;
    }

    /**
     * Get junction target on Windows
     */
    private function getJunctionTarget($path)
    {
        if (PHP_OS_FAMILY !== 'Windows') {
            return null;
        }

        $output = @shell_exec('fsutil reparsepoint query "' . $path . '" 2>nul');
        if (preg_match('/Print Name:\s*(.+)/i', $output, $matches)) {
            return trim($matches[1]);
        }

        // Alternative method using dir
        $output = @shell_exec('dir "' . dirname($path) . '" 2>nul');
        if (preg_match('/<JUNCTION>\s+' . preg_quote(basename($path), '/') . '\s+\[(.+?)\]/i', $output, $matches)) {
            return trim($matches[1]);
        }

        return null;
    }

    /**
     * Check all symlinks status (from filesystems.php links config)
     */
    public function checkAllSymlinks()
    {
        $links = config('filesystems.links', [
            public_path('storage') => storage_path('app/public'),
        ]);

        $results = [];

        foreach ($links as $link => $target) {
            $exists = false;
            $linkName = basename($link);

            if (is_link($link)) {
                $exists = true;
            } elseif (PHP_OS_FAMILY === 'Windows' && is_dir($link)) {
                // Check if it's a junction on Windows
                $exists = $this->isJunction($link);
            }

            $results[] = [
                'name' => $linkName,
                'link' => $link,
                'target' => $target,
                'exists' => $exists,
            ];
        }

        return response()->json(['links' => $results]);
    }

    /**
     * Fix/Create all symlinks from filesystems.php links config
     */
    public function fixAllSymlinks()
    {
        $links = config('filesystems.links', [
            public_path('storage') => storage_path('app/public'),
        ]);

        $created = 0;
        $skipped = 0;
        $errors = [];

        foreach ($links as $link => $target) {
            // Check if link already exists and is valid
            if (is_link($link) || (PHP_OS_FAMILY === 'Windows' && is_dir($link) && $this->isJunction($link))) {
                $skipped++;
                continue;
            }

            // Make sure target directory exists
            if (!File::exists($target)) {
                File::makeDirectory($target, 0755, true);
            }

            // Remove broken link or directory if exists
            if (file_exists($link) || is_link($link)) {
                if (is_link($link)) {
                    if (PHP_OS_FAMILY === 'Windows') {
                        @rmdir($link);
                    } else {
                        @unlink($link);
                    }
                } elseif (is_dir($link)) {
                    // Don't remove regular directories - just report error
                    $errors[] = basename($link) . ' هو مجلد عادي وليس رابط رمزي';
                    continue;
                }
            }

            try {
                if (PHP_OS_FAMILY === 'Windows') {
                    // Try junction first (doesn't require admin)
                    $command = 'mklink /J "' . $link . '" "' . $target . '"';
                    exec($command, $output, $returnVar);

                    if ($returnVar !== 0) {
                        // Try symlink as fallback
                        $command = 'mklink /D "' . $link . '" "' . $target . '"';
                        exec($command, $output, $returnVar);
                    }

                    if ($returnVar === 0) {
                        $created++;
                    } else {
                        $errors[] = basename($link) . ' - فشل في الإنشاء';
                    }
                } else {
                    symlink($target, $link);
                    $created++;
                }
            } catch (\Exception $e) {
                $errors[] = basename($link) . ' - ' . $e->getMessage();
            }
        }

        $message = "تم إنشاء {$created} رابط، تم تخطي {$skipped} رابط موجود";
        if (!empty($errors)) {
            $message .= '. أخطاء: ' . implode(', ', $errors);
        }

        return response()->json([
            'success' => empty($errors) || $created > 0,
            'message' => $message,
            'created' => $created,
            'skipped' => $skipped,
            'errors' => $errors,
        ]);
    }

    /**
     * Create storage link
     */
    public function createStorageLink()
    {
        try {
            $storagePath = public_path('storage');
            $targetPath = storage_path('app/public');

            // Check if it already exists
            if (file_exists($storagePath) || is_link($storagePath)) {
                // Remove existing link or directory
                if (is_link($storagePath)) {
                    // Remove symlink
                    if (PHP_OS_FAMILY === 'Windows') {
                        // On Windows, use rmdir for directory links
                        @rmdir($storagePath);
                    } else {
                        @unlink($storagePath);
                    }
                } elseif (is_dir($storagePath)) {
                    // If it's a regular directory, don't remove it - just warn
                    return response()->json([
                        'success' => false,
                        'message' => 'المجلد public/storage موجود كمجلد عادي. يرجى حذفه يدوياً أولاً.',
                    ]);
                }
            }

            // Make sure target directory exists
            if (!File::exists($targetPath)) {
                File::makeDirectory($targetPath, 0755, true);
            }

            // Create the symbolic link
            if (PHP_OS_FAMILY === 'Windows') {
                // On Windows, try using mklink (requires admin or developer mode)
                $command = 'mklink /D "' . $storagePath . '" "' . $targetPath . '"';
                exec($command, $output, $returnVar);

                if ($returnVar !== 0) {
                    // Try using junction as fallback
                    $junctionCommand = 'mklink /J "' . $storagePath . '" "' . $targetPath . '"';
                    exec($junctionCommand, $output, $returnVar);

                    if ($returnVar !== 0) {
                        // Use Laravel's storage:link as last resort
                        Artisan::call('storage:link');
                    }
                }
            } else {
                // On Unix-like systems
                symlink($targetPath, $storagePath);
            }

            // Verify the link was created
            if (is_link($storagePath) || (is_dir($storagePath) && PHP_OS_FAMILY === 'Windows')) {
                return response()->json([
                    'success' => true,
                    'message' => 'تم إنشاء رابط التخزين بنجاح!',
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'فشل في إنشاء رابط التخزين. جرب تشغيل: php artisan storage:link',
                ]);
            }

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ: ' . $e->getMessage(),
            ]);
        }
    }
}
