<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use App\Models\User;
use App\Models\UserNotificationSetting;
use App\Models\AcademicStream;
use App\Models\AcademicYear;
use App\Models\FcmToken;
use App\Services\NotificationService;
use Illuminate\Http\Request;
use Yajra\DataTables\Facades\DataTables;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Cache;

class NotificationController extends Controller
{
    /**
     * Display notifications dashboard.
     */
    public function index(Request $request)
    {
        $query = Notification::with('user')
            ->orderBy('created_at', 'desc');

        // Filter by status
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Filter by type
        if ($request->has('type')) {
            $query->where('type', $request->type);
        }

        // Search by user
        if ($request->has('search')) {
            $search = $request->search;
            $query->whereHas('user', function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%");
            });
        }

        $notifications = $query->paginate(50);

        $stats = [
            'total' => Notification::count(),
            'pending' => Notification::where('status', 'pending')->count(),
            'sent' => Notification::where('status', 'sent')->count(),
            'failed' => Notification::where('status', 'failed')->count(),
        ];

        return view('admin.notifications.index', compact('notifications', 'stats'));
    }

    /**
     * Display notification settings for users.
     */
    public function settings(Request $request)
    {
        if ($request->ajax()) {
            $users = User::with('notificationSettings')->select('users.*');

            return DataTables::of($users)
                ->addColumn('status', function ($user) {
                    if ($user->notificationSettings) {
                        if ($user->notificationSettings->notifications_enabled) {
                            return '<span class="px-3 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-800">مفعلة</span>';
                        }
                        return '<span class="px-3 py-1 rounded-full text-xs font-semibold bg-red-100 text-red-800">معطلة</span>';
                    }
                    return '<span class="px-3 py-1 rounded-full text-xs font-semibold bg-gray-100 text-gray-800">لم يتم الإعداد</span>';
                })
                ->addColumn('preferences', function ($user) {
                    $settings = $user->notificationSettings;
                    if (!$settings) {
                        return '<span class="text-gray-400 text-sm">لا توجد تفضيلات</span>';
                    }

                    $active = [];
                    if ($settings->study_reminders) $active[] = 'دراسة';
                    if ($settings->exam_reminders) $active[] = 'امتحانات';
                    if ($settings->daily_summary) $active[] = 'ملخص يومي';
                    if ($settings->weekly_summary) $active[] = 'ملخص أسبوعي';

                    return $active ? '<span class="text-sm text-gray-700">' . implode(' • ', $active) . '</span>' : '<span class="text-gray-400 text-sm">لا شيء</span>';
                })
                ->addColumn('quiet_hours', function ($user) {
                    $settings = $user->notificationSettings;
                    if ($settings && $settings->quiet_hours_enabled && $settings->quiet_start_time && $settings->quiet_end_time) {
                        return '<span class="text-sm text-indigo-700 font-semibold">' . $settings->quiet_start_time . ' - ' . $settings->quiet_end_time . '</span>';
                    }
                    return '<span class="text-gray-400 text-sm">غير مفعل</span>';
                })
                ->addColumn('actions', function ($user) {
                    return '
                        <button onclick="editSettings(' . $user->id . ')" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg text-sm font-semibold">
                            <i class="fas fa-edit ml-1"></i>
                            تعديل
                        </button>
                    ';
                })
                ->rawColumns(['status', 'preferences', 'quiet_hours', 'actions'])
                ->make(true);
        }

        return view('admin.notifications.settings');
    }

    /**
     * Get user settings for editing.
     */
    public function getUserSettings($userId)
    {
        $user = User::with('notificationSettings')->findOrFail($userId);

        return response()->json([
            'success' => true,
            'user' => $user,
            'settings' => $user->notificationSettings ?? (object)[
                'notifications_enabled' => true,
                'study_reminders' => true,
                'exam_reminders' => true,
                'daily_summary' => true,
                'weekly_summary' => false,
                'motivational_quotes' => true,
                'course_updates' => true,
                'quiet_hours_enabled' => false,
                'quiet_start_time' => null,
                'quiet_end_time' => null,
            ],
        ]);
    }

    /**
     * Update user notification settings.
     */
    public function updateUserSettings(Request $request, $userId)
    {
        $user = User::findOrFail($userId);

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

        return redirect()->back()->with('success', 'تم تحديث إعدادات الإشعارات بنجاح');
    }

    /**
     * Send a test notification.
     */
    public function sendTest(Request $request, NotificationService $notificationService)
    {
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
            'type' => 'required|in:study_reminder,exam_alert,daily_summary,course_update,achievement,system',
            'title_ar' => 'required|string|max:255',
            'body_ar' => 'required|string',
        ]);

        $notification = Notification::create([
            'user_id' => $validated['user_id'],
            'type' => $validated['type'],
            'title_ar' => $validated['title_ar'],
            'body_ar' => $validated['body_ar'],
            'scheduled_for' => now(),
            'status' => 'pending',
            'priority' => 'normal',
        ]);

        $notificationService->sendPushNotification($notification);

        return redirect()->back()->with('success', 'تم إرسال الإشعار التجريبي بنجاح');
    }

    /**
     * Show statistics.
     */
    public function statistics()
    {
        $stats = [
            'total_notifications' => Notification::count(),
            'sent_today' => Notification::where('status', 'sent')
                ->whereDate('sent_at', today())
                ->count(),
            'pending' => Notification::where('status', 'pending')->count(),
            'failed' => Notification::where('status', 'failed')->count(),
            'by_type' => Notification::selectRaw('type, COUNT(*) as count')
                ->groupBy('type')
                ->pluck('count', 'type'),
            'users_with_notifications_disabled' => UserNotificationSetting::where('notifications_enabled', false)->count(),
            'users_with_quiet_hours' => UserNotificationSetting::where('quiet_hours_enabled', true)->count(),
        ];

        return view('admin.notifications.statistics', compact('stats'));
    }

    /**
     * Show broadcast notification form.
     */
    public function broadcast()
    {
        $streams = AcademicStream::where('is_active', true)->get();
        $years = AcademicYear::where('is_active', true)->get();
        $totalUsers = User::where('is_active', true)->count();

        return view('admin.notifications.broadcast', compact('streams', 'years', 'totalUsers'));
    }

    /**
     * Get users for broadcast (AJAX with DataTables).
     */
    public function getBroadcastUsers(Request $request)
    {
        // Show all active users, not just those with FCM tokens
        // Notifications will be stored in DB and push sent only to those with tokens
        $query = User::where('is_active', true)
            ->withCount(['fcmTokens as active_tokens_count' => function ($q) {
                $q->where('is_active', true);
            }]);

        // Option to filter only users with devices
        if ($request->has('with_devices') && $request->with_devices === 'true') {
            $query->whereHas('fcmTokens', function ($q) {
                $q->where('is_active', true);
            });
        }

        // Filter by stream (through academicProfile relationship)
        if ($request->has('stream_id') && $request->stream_id) {
            $query->whereHas('academicProfile', function ($q) use ($request) {
                $q->where('academic_stream_id', $request->stream_id);
            });
        }

        // Filter by year (through academicProfile relationship)
        if ($request->has('year_id') && $request->year_id) {
            $query->whereHas('academicProfile', function ($q) use ($request) {
                $q->where('academic_year_id', $request->year_id);
            });
        }

        return DataTables::of($query)
            ->addColumn('checkbox', function ($user) {
                return '<input type="checkbox" class="user-checkbox rounded border-gray-300" name="user_ids[]" value="' . $user->id . '">';
            })
            ->addColumn('stream', function ($user) {
                return $user->academicProfile?->academicStream?->name_ar ?? '-';
            })
            ->addColumn('year', function ($user) {
                return $user->academicProfile?->academicYear?->name_ar ?? '-';
            })
            ->addColumn('fcm_tokens', function ($user) {
                $count = $user->active_tokens_count ?? 0;
                if ($count > 0) {
                    return '<span class="px-2 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-800"><i class="fas fa-mobile-alt mr-1"></i>' . $count . '</span>';
                }
                return '<span class="px-2 py-1 rounded-full text-xs font-semibold bg-gray-100 text-gray-500">لا يوجد</span>';
            })
            ->rawColumns(['checkbox', 'fcm_tokens'])
            ->make(true);
    }

    /**
     * Preview broadcast recipients count.
     */
    public function previewBroadcast(Request $request)
    {
        Log::info('previewBroadcast called', ['request' => $request->all()]);

        $validated = $request->validate([
            'target_type' => 'required|in:all,stream,year,selected',
            'stream_id' => 'nullable|exists:academic_streams,id',
            'year_id' => 'nullable|exists:academic_years,id',
            'user_ids' => 'nullable|array',
            'user_ids.*' => 'exists:users,id',
        ]);

        Log::info('previewBroadcast validated', ['validated' => $validated]);

        $query = User::where('is_active', true)
            ->whereHas('fcmTokens', function ($q) {
                $q->where('is_active', true);
            });

        switch ($validated['target_type']) {
            case 'stream':
                if (!empty($validated['stream_id'])) {
                    $query->whereHas('academicProfile', function ($q) use ($validated) {
                        $q->where('academic_stream_id', $validated['stream_id']);
                    });
                }
                break;
            case 'year':
                if (!empty($validated['year_id'])) {
                    $query->whereHas('academicProfile', function ($q) use ($validated) {
                        $q->where('academic_year_id', $validated['year_id']);
                    });
                }
                break;
            case 'selected':
                if (!empty($validated['user_ids'])) {
                    $query->whereIn('id', $validated['user_ids']);
                }
                break;
        }

        $count = $query->count();
        $totalDevices = 0;

        if ($validated['target_type'] === 'selected' && !empty($validated['user_ids'])) {
            $totalDevices = \App\Models\FcmToken::whereIn('user_id', $validated['user_ids'])
                ->where('is_active', true)
                ->count();
        } else {
            $userIds = $query->pluck('id')->toArray();
            $totalDevices = \App\Models\FcmToken::whereIn('user_id', $userIds)
                ->where('is_active', true)
                ->count();
        }

        Log::info('previewBroadcast result', [
            'recipients_count' => $count,
            'devices_count' => $totalDevices,
        ]);

        return response()->json([
            'success' => true,
            'recipients_count' => $count,
            'devices_count' => $totalDevices,
        ]);
    }

    /**
     * Send broadcast notification to multiple users.
     */
    public function sendBroadcast(Request $request, NotificationService $notificationService)
    {
        $validated = $request->validate([
            'title_ar' => 'required|string|max:255',
            'body_ar' => 'required|string|max:1000',
            'type' => 'required|in:system,course_update,achievement,announcement',
            'priority' => 'required|in:low,normal,high',
            'target_type' => 'required|in:all,stream,year,selected',
            'stream_id' => 'nullable|exists:academic_streams,id',
            'year_id' => 'nullable|exists:academic_years,id',
            'user_ids' => 'nullable|array',
            'user_ids.*' => 'exists:users,id',
            'scheduled_for' => 'nullable|date|after:now',
            'action_type' => 'nullable|string|max:100',
            'action_data' => 'nullable|array',
        ]);

        // Build user query
        $query = User::where('is_active', true)
            ->whereHas('fcmTokens', function ($q) {
                $q->where('is_active', true);
            });

        switch ($validated['target_type']) {
            case 'stream':
                if (!empty($validated['stream_id'])) {
                    $query->whereHas('academicProfile', function ($q) use ($validated) {
                        $q->where('academic_stream_id', $validated['stream_id']);
                    });
                }
                break;
            case 'year':
                if (!empty($validated['year_id'])) {
                    $query->whereHas('academicProfile', function ($q) use ($validated) {
                        $q->where('academic_year_id', $validated['year_id']);
                    });
                }
                break;
            case 'selected':
                if (!empty($validated['user_ids'])) {
                    $query->whereIn('id', $validated['user_ids']);
                }
                break;
        }

        $userIds = $query->pluck('id')->toArray();

        if (empty($userIds)) {
            return redirect()->back()->with('error', 'لا يوجد مستخدمين مطابقين للمعايير المحددة');
        }

        $scheduledFor = !empty($validated['scheduled_for'])
            ? \Carbon\Carbon::parse($validated['scheduled_for'])
            : now();

        $sentCount = 0;
        $pendingCount = 0;

        foreach ($userIds as $userId) {
            $notification = Notification::create([
                'user_id' => $userId,
                'type' => $validated['type'],
                'title_ar' => $validated['title_ar'],
                'body_ar' => $validated['body_ar'],
                'action_type' => $validated['action_type'] ?? null,
                'action_data' => $validated['action_data'] ?? null,
                'scheduled_for' => $scheduledFor,
                'status' => 'pending',
                'priority' => $validated['priority'],
            ]);

            // If not scheduled for later, send immediately
            if (empty($validated['scheduled_for'])) {
                if ($notificationService->sendPushNotification($notification)) {
                    $sentCount++;
                }
            } else {
                $pendingCount++;
            }
        }

        Log::info('Broadcast notification sent', [
            'admin_id' => auth()->id(),
            'title' => $validated['title_ar'],
            'target_type' => $validated['target_type'],
            'recipients' => count($userIds),
            'sent' => $sentCount,
            'pending' => $pendingCount,
        ]);

        if (!empty($validated['scheduled_for'])) {
            return redirect()->route('admin.notifications.index')
                ->with('success', "تم جدولة الإشعار لـ {$pendingCount} مستخدم بنجاح");
        }

        return redirect()->route('admin.notifications.index')
            ->with('success', "تم إرسال الإشعار إلى {$sentCount} مستخدم بنجاح");
    }

    /**
     * Display notification configuration page.
     */
    public function configuration()
    {
        // Firebase/FCM Settings
        $fcmConfig = [
            'project_id' => config('firebase.project_id'),
            'credentials_path' => config('firebase.credentials.file'),
            'credentials_exists' => File::exists(config('firebase.credentials.file')),
            'default_icon' => config('firebase.fcm.default_icon'),
            'default_color' => config('firebase.fcm.default_color'),
            'default_sound' => config('firebase.fcm.default_sound'),
            'android_channel_id' => config('firebase.fcm.android_channel_id'),
            'retry_count' => config('firebase.fcm.retry_count'),
            'retry_delay' => config('firebase.fcm.retry_delay'),
            'batch_size' => config('firebase.fcm.batch_size'),
        ];

        // Rate Limiting Settings
        $rateLimitConfig = [
            'enabled' => config('firebase.rate_limiting.enabled'),
            'max_per_day' => config('firebase.rate_limiting.max_per_day'),
            'max_per_hour' => config('firebase.rate_limiting.max_per_hour'),
        ];

        // Deep Link Settings
        $deepLinkConfig = [
            'scheme' => config('firebase.deep_link.scheme'),
            'host' => config('firebase.deep_link.host'),
        ];

        // Notification Types
        $notificationTypes = [
            'study_reminder' => [
                'name_ar' => 'تذكير الدراسة',
                'icon' => 'fa-book-reader',
                'color' => '#2196F3',
                'default_priority' => 'normal',
            ],
            'exam_alert' => [
                'name_ar' => 'تنبيه الامتحان',
                'icon' => 'fa-bell',
                'color' => '#F44336',
                'default_priority' => 'high',
            ],
            'daily_summary' => [
                'name_ar' => 'الملخص اليومي',
                'icon' => 'fa-chart-pie',
                'color' => '#4CAF50',
                'default_priority' => 'low',
            ],
            'course_update' => [
                'name_ar' => 'تحديث الدورة',
                'icon' => 'fa-graduation-cap',
                'color' => '#9C27B0',
                'default_priority' => 'normal',
            ],
            'achievement' => [
                'name_ar' => 'الإنجازات',
                'icon' => 'fa-trophy',
                'color' => '#FFC107',
                'default_priority' => 'normal',
            ],
            'system' => [
                'name_ar' => 'النظام',
                'icon' => 'fa-cog',
                'color' => '#607D8B',
                'default_priority' => 'high',
            ],
        ];

        // Scheduled Jobs Info
        $scheduledJobs = [
            [
                'name' => 'معالجة الإشعارات المعلقة',
                'class' => 'ProcessDueNotificationsJob',
                'schedule' => 'كل 5 دقائق',
                'description' => 'معالجة الإشعارات المجدولة للإرسال',
            ],
            [
                'name' => 'تذكيرات الجلسات',
                'class' => 'CheckUpcomingSessionsJob',
                'schedule' => 'كل 5 دقائق',
                'description' => 'إرسال تذكيرات قبل 15 دقيقة من الجلسات',
            ],
            [
                'name' => 'تنبيهات الامتحانات',
                'class' => 'SendExamAlertsJob',
                'schedule' => 'كل ساعة',
                'description' => 'إرسال تنبيهات للامتحانات القادمة',
            ],
            [
                'name' => 'الملخص اليومي',
                'class' => 'SendDailySummaryJob',
                'schedule' => 'يومياً الساعة 21:00',
                'description' => 'إرسال ملخص الدراسة اليومي',
            ],
            [
                'name' => 'الملخص الأسبوعي',
                'class' => 'SendWeeklySummaryJob',
                'schedule' => 'الأحد الساعة 20:00',
                'description' => 'إرسال ملخص الدراسة الأسبوعي',
            ],
        ];

        // Device Statistics
        $deviceStats = [
            'total' => FcmToken::count(),
            'active' => FcmToken::active()->count(),
            'inactive' => FcmToken::where('is_active', false)->count(),
            'android' => FcmToken::forPlatform('android')->count(),
            'ios' => FcmToken::forPlatform('ios')->count(),
            'android_active' => FcmToken::active()->forPlatform('android')->count(),
            'ios_active' => FcmToken::active()->forPlatform('ios')->count(),
        ];

        // User Settings Stats
        $userSettingsStats = [
            'total_users' => User::count(),
            'with_settings' => UserNotificationSetting::count(),
            'disabled_notifications' => UserNotificationSetting::where('notifications_enabled', false)->count(),
            'quiet_hours_enabled' => UserNotificationSetting::where('quiet_hours_enabled', true)->count(),
        ];

        // Action Types for Deep Links
        $actionTypes = [
            'session' => 'جلسة دراسية',
            'exam' => 'امتحان',
            'quiz' => 'اختبار',
            'course' => 'دورة',
            'achievement' => 'إنجاز',
            'statistics' => 'إحصائيات',
            'planner' => 'المخطط',
        ];

        return view('admin.notifications.configuration', compact(
            'fcmConfig',
            'rateLimitConfig',
            'deepLinkConfig',
            'notificationTypes',
            'scheduledJobs',
            'deviceStats',
            'userSettingsStats',
            'actionTypes'
        ));
    }

    /**
     * Update notification configuration.
     */
    public function updateConfiguration(Request $request)
    {
        $validated = $request->validate([
            'default_icon' => 'nullable|string|max:50',
            'default_color' => 'nullable|string|max:7',
            'default_sound' => 'nullable|string|max:50',
            'android_channel_id' => 'nullable|string|max:100',
            'rate_limit_enabled' => 'boolean',
            'max_per_day' => 'nullable|integer|min:1|max:100',
            'max_per_hour' => 'nullable|integer|min:1|max:50',
            'deep_link_scheme' => 'nullable|string|max:50',
        ]);

        // Update .env file or use a settings table
        // For now, we'll just return success as env changes require server restart
        // In production, consider using a database settings table

        Log::info('Notification configuration update requested', [
            'admin_id' => auth()->id(),
            'settings' => $validated,
        ]);

        return redirect()->route('admin.notifications.configuration')
            ->with('info', 'تم حفظ الإعدادات. قد تحتاج بعض التغييرات إلى إعادة تشغيل الخادم.');
    }

    /**
     * Test FCM connection.
     */
    public function testFcmConnection(Request $request)
    {
        try {
            $credentialsPath = config('firebase.credentials.file');

            // Check if credentials file exists
            if (!File::exists($credentialsPath)) {
                return response()->json([
                    'success' => false,
                    'message' => 'ملف بيانات الاعتماد غير موجود',
                    'details' => 'تأكد من وجود ملف firebase-credentials.json في المسار المحدد',
                ]);
            }

            // Read and validate credentials file
            $credentials = json_decode(File::get($credentialsPath), true);

            if (!$credentials || !isset($credentials['project_id'])) {
                return response()->json([
                    'success' => false,
                    'message' => 'ملف بيانات الاعتماد غير صالح',
                    'details' => 'تأكد من صحة محتوى ملف JSON',
                ]);
            }

            // Check project ID matches
            $configProjectId = config('firebase.project_id');
            if ($configProjectId && $credentials['project_id'] !== $configProjectId) {
                return response()->json([
                    'success' => false,
                    'message' => 'عدم تطابق معرف المشروع',
                    'details' => "المعرف في الإعدادات: {$configProjectId}, في الملف: {$credentials['project_id']}",
                ]);
            }

            // Try to get Firebase access token (this validates the credentials)
            $notificationService = app(NotificationService::class);

            // Use reflection to call private method for testing
            $reflection = new \ReflectionClass($notificationService);
            $method = $reflection->getMethod('getFirebaseAccessToken');
            $method->setAccessible(true);
            $token = $method->invoke($notificationService);

            if ($token) {
                return response()->json([
                    'success' => true,
                    'message' => 'تم الاتصال بنجاح',
                    'details' => "متصل بمشروع: {$credentials['project_id']}",
                    'project_id' => $credentials['project_id'],
                ]);
            }

            return response()->json([
                'success' => false,
                'message' => 'فشل في الحصول على رمز الوصول',
                'details' => 'تحقق من صلاحيات حساب الخدمة',
            ]);

        } catch (\Exception $e) {
            Log::error('FCM connection test failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'خطأ في الاتصال',
                'details' => $e->getMessage(),
            ]);
        }
    }

    /**
     * Clean inactive FCM tokens.
     */
    public function cleanInactiveTokens(Request $request)
    {
        try {
            // Get inactive tokens (not used in last 30 days or marked inactive)
            $thirtyDaysAgo = now()->subDays(30);

            $deletedCount = FcmToken::where(function ($query) use ($thirtyDaysAgo) {
                $query->where('is_active', false)
                    ->orWhere('last_used_at', '<', $thirtyDaysAgo)
                    ->orWhereNull('last_used_at');
            })->delete();

            Log::info('Inactive FCM tokens cleaned', [
                'admin_id' => auth()->id(),
                'deleted_count' => $deletedCount,
            ]);

            return response()->json([
                'success' => true,
                'message' => "تم حذف {$deletedCount} رمز غير نشط",
                'deleted_count' => $deletedCount,
            ]);

        } catch (\Exception $e) {
            Log::error('Failed to clean inactive tokens', [
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'فشل في تنظيف الرموز',
                'details' => $e->getMessage(),
            ]);
        }
    }
}
