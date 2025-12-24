@extends('layouts.admin')

@section('title', 'إعدادات الإشعارات')

@section('content')
<div class="min-h-screen bg-gray-50">
    <div class="px-4 sm:px-6 lg:px-8 py-8">
        <!-- Header -->
        <div class="mb-8">
            <div class="flex justify-between items-center mb-4">
                <div>
                    <h1 class="text-3xl font-bold text-gray-900">
                        <i class="fas fa-sliders-h text-purple-600 ml-3"></i>
                        إعدادات الإشعارات والـ Push Notifications
                    </h1>
                    <p class="text-gray-600 mt-1">تكوين نظام الإشعارات وخدمة Firebase Cloud Messaging</p>
                </div>
                <a href="{{ route('admin.notifications.index') }}" class="bg-gray-600 hover:bg-gray-700 text-white px-6 py-3 rounded-lg shadow-md font-semibold transition-colors">
                    <i class="fas fa-arrow-right ml-2"></i>
                    العودة
                </a>
            </div>
        </div>

        <!-- Alerts -->
        @if(session('success'))
        <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded-lg mb-6">
            <i class="fas fa-check-circle ml-2"></i>
            {{ session('success') }}
        </div>
        @endif

        @if(session('info'))
        <div class="bg-blue-100 border border-blue-400 text-blue-700 px-4 py-3 rounded-lg mb-6">
            <i class="fas fa-info-circle ml-2"></i>
            {{ session('info') }}
        </div>
        @endif

        @if(session('error'))
        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded-lg mb-6">
            <i class="fas fa-exclamation-circle ml-2"></i>
            {{ session('error') }}
        </div>
        @endif

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <!-- Main Content - 2 columns -->
            <div class="lg:col-span-2 space-y-8">

                <!-- Section 1: Firebase Cloud Messaging -->
                <div class="bg-white rounded-xl shadow-md overflow-hidden">
                    <div class="bg-gradient-to-r from-orange-500 to-orange-600 px-6 py-4">
                        <h2 class="text-xl font-bold text-white flex items-center">
                            <i class="fas fa-fire ml-3"></i>
                            Firebase Cloud Messaging (FCM)
                        </h2>
                    </div>
                    <div class="p-6">
                        <!-- Connection Status -->
                        <div class="mb-6 p-4 rounded-lg {{ $fcmConfig['credentials_exists'] ? 'bg-green-50 border border-green-200' : 'bg-red-50 border border-red-200' }}">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center">
                                    @if($fcmConfig['credentials_exists'])
                                        <div class="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center">
                                            <i class="fas fa-check-circle text-green-600 text-2xl"></i>
                                        </div>
                                        <div class="mr-4">
                                            <p class="font-semibold text-green-800">بيانات الاعتماد موجودة</p>
                                            <p class="text-sm text-green-600">Project ID: {{ $fcmConfig['project_id'] ?? 'غير محدد' }}</p>
                                        </div>
                                    @else
                                        <div class="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center">
                                            <i class="fas fa-times-circle text-red-600 text-2xl"></i>
                                        </div>
                                        <div class="mr-4">
                                            <p class="font-semibold text-red-800">بيانات الاعتماد غير موجودة</p>
                                            <p class="text-sm text-red-600">يرجى إضافة ملف firebase-credentials.json</p>
                                        </div>
                                    @endif
                                </div>
                                <button type="button" id="testFcmBtn" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors">
                                    <i class="fas fa-plug ml-2"></i>
                                    اختبار الاتصال
                                </button>
                            </div>
                            <div id="fcmTestResult" class="mt-4 hidden"></div>
                        </div>

                        <!-- FCM Settings Grid -->
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">
                                    <i class="fas fa-image ml-1 text-gray-400"></i>
                                    أيقونة الإشعار الافتراضية
                                </label>
                                <input type="text" value="{{ $fcmConfig['default_icon'] }}" readonly
                                       class="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 text-gray-600">
                                <p class="text-xs text-gray-500 mt-1">اسم ملف الأيقونة في تطبيق Android</p>
                            </div>

                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">
                                    <i class="fas fa-palette ml-1 text-gray-400"></i>
                                    لون الإشعار الافتراضي
                                </label>
                                <div class="flex items-center gap-3">
                                    <input type="color" value="{{ $fcmConfig['default_color'] }}" disabled
                                           class="w-12 h-10 rounded border border-gray-300 cursor-not-allowed">
                                    <input type="text" value="{{ $fcmConfig['default_color'] }}" readonly
                                           class="flex-1 px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 text-gray-600">
                                </div>
                            </div>

                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">
                                    <i class="fas fa-volume-up ml-1 text-gray-400"></i>
                                    صوت الإشعار الافتراضي
                                </label>
                                <input type="text" value="{{ $fcmConfig['default_sound'] }}" readonly
                                       class="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 text-gray-600">
                            </div>

                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">
                                    <i class="fab fa-android ml-1 text-green-500"></i>
                                    معرف قناة Android
                                </label>
                                <input type="text" value="{{ $fcmConfig['android_channel_id'] }}" readonly
                                       class="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 text-gray-600">
                            </div>
                        </div>

                        <!-- Technical Settings -->
                        <div class="mt-6 pt-6 border-t border-gray-200">
                            <h3 class="font-semibold text-gray-800 mb-4">
                                <i class="fas fa-cogs ml-2 text-gray-500"></i>
                                الإعدادات التقنية
                            </h3>
                            <div class="grid grid-cols-3 gap-4">
                                <div class="bg-gray-50 rounded-lg p-4 text-center">
                                    <p class="text-2xl font-bold text-gray-800">{{ $fcmConfig['retry_count'] }}</p>
                                    <p class="text-sm text-gray-500">محاولات الإعادة</p>
                                </div>
                                <div class="bg-gray-50 rounded-lg p-4 text-center">
                                    <p class="text-2xl font-bold text-gray-800">{{ $fcmConfig['retry_delay'] }}ms</p>
                                    <p class="text-sm text-gray-500">تأخير الإعادة</p>
                                </div>
                                <div class="bg-gray-50 rounded-lg p-4 text-center">
                                    <p class="text-2xl font-bold text-gray-800">{{ $fcmConfig['batch_size'] }}</p>
                                    <p class="text-sm text-gray-500">حجم الدفعة</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Section 2: Rate Limiting -->
                <div class="bg-white rounded-xl shadow-md overflow-hidden">
                    <div class="bg-gradient-to-r from-yellow-500 to-yellow-600 px-6 py-4">
                        <h2 class="text-xl font-bold text-white flex items-center">
                            <i class="fas fa-tachometer-alt ml-3"></i>
                            الحد الأقصى للإشعارات (Rate Limiting)
                        </h2>
                    </div>
                    <div class="p-6">
                        <div class="flex items-center justify-between mb-6 p-4 {{ $rateLimitConfig['enabled'] ? 'bg-green-50 border border-green-200' : 'bg-gray-50 border border-gray-200' }} rounded-lg">
                            <div class="flex items-center">
                                <div class="w-10 h-10 {{ $rateLimitConfig['enabled'] ? 'bg-green-100' : 'bg-gray-100' }} rounded-full flex items-center justify-center">
                                    <i class="fas {{ $rateLimitConfig['enabled'] ? 'fa-check text-green-600' : 'fa-times text-gray-600' }}"></i>
                                </div>
                                <div class="mr-3">
                                    <p class="font-semibold {{ $rateLimitConfig['enabled'] ? 'text-green-800' : 'text-gray-800' }}">
                                        {{ $rateLimitConfig['enabled'] ? 'الحد الأقصى مفعل' : 'الحد الأقصى معطل' }}
                                    </p>
                                    <p class="text-sm {{ $rateLimitConfig['enabled'] ? 'text-green-600' : 'text-gray-600' }}">
                                        يمنع إرسال إشعارات مفرطة للمستخدمين
                                    </p>
                                </div>
                            </div>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div class="bg-blue-50 border border-blue-200 rounded-xl p-6 text-center">
                                <div class="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                                    <i class="fas fa-calendar-day text-blue-600 text-2xl"></i>
                                </div>
                                <p class="text-4xl font-bold text-blue-800">{{ $rateLimitConfig['max_per_day'] }}</p>
                                <p class="text-blue-600 mt-2">إشعار / مستخدم / يوم</p>
                            </div>

                            <div class="bg-purple-50 border border-purple-200 rounded-xl p-6 text-center">
                                <div class="w-16 h-16 bg-purple-100 rounded-full flex items-center justify-center mx-auto mb-4">
                                    <i class="fas fa-clock text-purple-600 text-2xl"></i>
                                </div>
                                <p class="text-4xl font-bold text-purple-800">{{ $rateLimitConfig['max_per_hour'] }}</p>
                                <p class="text-purple-600 mt-2">إشعار / مستخدم / ساعة</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Section 3: Notification Types -->
                <div class="bg-white rounded-xl shadow-md overflow-hidden">
                    <div class="bg-gradient-to-r from-blue-500 to-blue-600 px-6 py-4">
                        <h2 class="text-xl font-bold text-white flex items-center">
                            <i class="fas fa-tags ml-3"></i>
                            أنواع الإشعارات
                        </h2>
                    </div>
                    <div class="p-6">
                        <div class="overflow-x-auto">
                            <table class="w-full">
                                <thead>
                                    <tr class="border-b border-gray-200">
                                        <th class="text-right py-3 px-4 font-semibold text-gray-700">النوع</th>
                                        <th class="text-center py-3 px-4 font-semibold text-gray-700">الأيقونة</th>
                                        <th class="text-center py-3 px-4 font-semibold text-gray-700">اللون</th>
                                        <th class="text-center py-3 px-4 font-semibold text-gray-700">الأولوية</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @foreach($notificationTypes as $type => $info)
                                    <tr class="border-b border-gray-100 hover:bg-gray-50">
                                        <td class="py-4 px-4">
                                            <div class="flex items-center">
                                                <div class="w-10 h-10 rounded-lg flex items-center justify-center" style="background-color: {{ $info['color'] }}20">
                                                    <i class="fas {{ $info['icon'] }}" style="color: {{ $info['color'] }}"></i>
                                                </div>
                                                <div class="mr-3">
                                                    <p class="font-semibold text-gray-800">{{ $info['name_ar'] }}</p>
                                                    <p class="text-xs text-gray-500">{{ $type }}</p>
                                                </div>
                                            </div>
                                        </td>
                                        <td class="py-4 px-4 text-center">
                                            <i class="fas {{ $info['icon'] }} text-xl" style="color: {{ $info['color'] }}"></i>
                                        </td>
                                        <td class="py-4 px-4 text-center">
                                            <div class="flex items-center justify-center gap-2">
                                                <span class="w-6 h-6 rounded" style="background-color: {{ $info['color'] }}"></span>
                                                <span class="text-sm text-gray-600">{{ $info['color'] }}</span>
                                            </div>
                                        </td>
                                        <td class="py-4 px-4 text-center">
                                            @php
                                                $priorityColors = [
                                                    'low' => 'bg-gray-100 text-gray-700',
                                                    'normal' => 'bg-blue-100 text-blue-700',
                                                    'high' => 'bg-red-100 text-red-700',
                                                ];
                                                $priorityLabels = [
                                                    'low' => 'منخفضة',
                                                    'normal' => 'عادية',
                                                    'high' => 'عالية',
                                                ];
                                            @endphp
                                            <span class="px-3 py-1 rounded-full text-sm font-medium {{ $priorityColors[$info['default_priority']] }}">
                                                {{ $priorityLabels[$info['default_priority']] }}
                                            </span>
                                        </td>
                                    </tr>
                                    @endforeach
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Section 4: Deep Link Configuration -->
                <div class="bg-white rounded-xl shadow-md overflow-hidden">
                    <div class="bg-gradient-to-r from-indigo-500 to-indigo-600 px-6 py-4">
                        <h2 class="text-xl font-bold text-white flex items-center">
                            <i class="fas fa-link ml-3"></i>
                            إعدادات الروابط العميقة (Deep Links)
                        </h2>
                    </div>
                    <div class="p-6">
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">URL Scheme</label>
                                <div class="flex items-center">
                                    <span class="bg-gray-100 border border-gray-300 border-l-0 rounded-r-lg px-4 py-2 text-gray-500">://</span>
                                    <input type="text" value="{{ $deepLinkConfig['scheme'] }}" readonly
                                           class="flex-1 px-4 py-2 border border-gray-300 rounded-l-lg bg-gray-50 text-gray-600">
                                </div>
                                <p class="text-xs text-gray-500 mt-1">مثال: {{ $deepLinkConfig['scheme'] }}://course/123</p>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">Host (اختياري)</label>
                                <input type="text" value="{{ $deepLinkConfig['host'] ?: 'غير محدد' }}" readonly
                                       class="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 text-gray-600">
                            </div>
                        </div>

                        <h3 class="font-semibold text-gray-800 mb-4">أنواع الإجراءات المتاحة</h3>
                        <div class="flex flex-wrap gap-2">
                            @foreach($actionTypes as $action => $label)
                            <span class="bg-indigo-50 text-indigo-700 px-3 py-1.5 rounded-lg text-sm border border-indigo-200">
                                <i class="fas fa-arrow-left ml-1 text-xs"></i>
                                {{ $label }} ({{ $action }})
                            </span>
                            @endforeach
                        </div>
                    </div>
                </div>

                <!-- Section 5: Scheduled Jobs -->
                <div class="bg-white rounded-xl shadow-md overflow-hidden">
                    <div class="bg-gradient-to-r from-teal-500 to-teal-600 px-6 py-4">
                        <h2 class="text-xl font-bold text-white flex items-center">
                            <i class="fas fa-clock ml-3"></i>
                            المهام المجدولة (Scheduled Jobs)
                        </h2>
                    </div>
                    <div class="p-6">
                        <div class="space-y-4">
                            @foreach($scheduledJobs as $job)
                            <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg border border-gray-200 hover:bg-gray-100 transition-colors">
                                <div class="flex items-center">
                                    <div class="w-12 h-12 bg-teal-100 rounded-full flex items-center justify-center">
                                        <i class="fas fa-cog text-teal-600"></i>
                                    </div>
                                    <div class="mr-4">
                                        <p class="font-semibold text-gray-800">{{ $job['name'] }}</p>
                                        <p class="text-sm text-gray-500">{{ $job['description'] }}</p>
                                    </div>
                                </div>
                                <div class="text-left">
                                    <span class="bg-teal-100 text-teal-700 px-3 py-1 rounded-full text-sm font-medium">
                                        <i class="fas fa-redo ml-1"></i>
                                        {{ $job['schedule'] }}
                                    </span>
                                </div>
                            </div>
                            @endforeach
                        </div>

                        <div class="mt-6 p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
                            <div class="flex items-start">
                                <i class="fas fa-info-circle text-yellow-600 mt-1 ml-3"></i>
                                <div>
                                    <p class="font-semibold text-yellow-800">ملاحظة</p>
                                    <p class="text-sm text-yellow-700">تأكد من تشغيل Laravel Scheduler على الخادم باستخدام Cron Job:</p>
                                    <code class="block mt-2 bg-yellow-100 p-2 rounded text-xs text-yellow-900 font-mono" dir="ltr">
                                        * * * * * cd /path-to-project && php artisan schedule:run >> /dev/null 2>&1
                                    </code>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

            </div>

            <!-- Sidebar - 1 column -->
            <div class="space-y-8">

                <!-- Device Statistics -->
                <div class="bg-white rounded-xl shadow-md overflow-hidden">
                    <div class="bg-gradient-to-r from-green-500 to-green-600 px-6 py-4">
                        <h2 class="text-xl font-bold text-white flex items-center">
                            <i class="fas fa-mobile-alt ml-3"></i>
                            إحصائيات الأجهزة
                        </h2>
                    </div>
                    <div class="p-6">
                        <!-- Total Devices -->
                        <div class="text-center mb-6">
                            <p class="text-5xl font-bold text-gray-800">{{ number_format($deviceStats['total']) }}</p>
                            <p class="text-gray-500">إجمالي الأجهزة المسجلة</p>
                        </div>

                        <!-- Active vs Inactive -->
                        <div class="grid grid-cols-2 gap-4 mb-6">
                            <div class="bg-green-50 rounded-lg p-4 text-center border border-green-200">
                                <p class="text-3xl font-bold text-green-600">{{ number_format($deviceStats['active']) }}</p>
                                <p class="text-sm text-green-700">نشط</p>
                            </div>
                            <div class="bg-gray-50 rounded-lg p-4 text-center border border-gray-200">
                                <p class="text-3xl font-bold text-gray-600">{{ number_format($deviceStats['inactive']) }}</p>
                                <p class="text-sm text-gray-700">غير نشط</p>
                            </div>
                        </div>

                        <!-- Platform Breakdown -->
                        <h3 class="font-semibold text-gray-700 mb-4">حسب المنصة</h3>
                        <div class="space-y-4">
                            <!-- Android -->
                            <div class="flex items-center justify-between p-3 bg-green-50 rounded-lg border border-green-200">
                                <div class="flex items-center">
                                    <div class="w-10 h-10 bg-green-100 rounded-full flex items-center justify-center">
                                        <i class="fab fa-android text-green-600 text-xl"></i>
                                    </div>
                                    <span class="mr-3 font-medium text-green-800">Android</span>
                                </div>
                                <div class="text-left">
                                    <p class="font-bold text-green-700">{{ number_format($deviceStats['android']) }}</p>
                                    <p class="text-xs text-green-600">{{ $deviceStats['android_active'] }} نشط</p>
                                </div>
                            </div>

                            <!-- iOS -->
                            <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg border border-gray-200">
                                <div class="flex items-center">
                                    <div class="w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center">
                                        <i class="fab fa-apple text-gray-700 text-xl"></i>
                                    </div>
                                    <span class="mr-3 font-medium text-gray-800">iOS</span>
                                </div>
                                <div class="text-left">
                                    <p class="font-bold text-gray-700">{{ number_format($deviceStats['ios']) }}</p>
                                    <p class="text-xs text-gray-600">{{ $deviceStats['ios_active'] }} نشط</p>
                                </div>
                            </div>
                        </div>

                        <!-- Clean Tokens Button -->
                        <button type="button" id="cleanTokensBtn" class="w-full mt-6 bg-red-50 hover:bg-red-100 text-red-700 border border-red-200 px-4 py-3 rounded-lg transition-colors font-medium">
                            <i class="fas fa-broom ml-2"></i>
                            تنظيف الرموز غير النشطة
                        </button>
                        <p class="text-xs text-gray-500 mt-2 text-center">يحذف الرموز غير المستخدمة منذ 30 يوم</p>
                        <div id="cleanTokensResult" class="mt-4 hidden"></div>
                    </div>
                </div>

                <!-- User Settings Stats -->
                <div class="bg-white rounded-xl shadow-md overflow-hidden">
                    <div class="bg-gradient-to-r from-purple-500 to-purple-600 px-6 py-4">
                        <h2 class="text-xl font-bold text-white flex items-center">
                            <i class="fas fa-users-cog ml-3"></i>
                            إعدادات المستخدمين
                        </h2>
                    </div>
                    <div class="p-6">
                        <div class="space-y-4">
                            <div class="flex items-center justify-between p-3 bg-blue-50 rounded-lg border border-blue-200">
                                <span class="text-blue-700">إجمالي المستخدمين</span>
                                <span class="font-bold text-blue-800">{{ number_format($userSettingsStats['total_users']) }}</span>
                            </div>

                            <div class="flex items-center justify-between p-3 bg-green-50 rounded-lg border border-green-200">
                                <span class="text-green-700">لديهم إعدادات</span>
                                <span class="font-bold text-green-800">{{ number_format($userSettingsStats['with_settings']) }}</span>
                            </div>

                            <div class="flex items-center justify-between p-3 bg-red-50 rounded-lg border border-red-200">
                                <span class="text-red-700">أوقفوا الإشعارات</span>
                                <span class="font-bold text-red-800">{{ number_format($userSettingsStats['disabled_notifications']) }}</span>
                            </div>

                            <div class="flex items-center justify-between p-3 bg-yellow-50 rounded-lg border border-yellow-200">
                                <span class="text-yellow-700">ساعات الهدوء مفعلة</span>
                                <span class="font-bold text-yellow-800">{{ number_format($userSettingsStats['quiet_hours_enabled']) }}</span>
                            </div>
                        </div>

                        <a href="{{ route('admin.notifications.settings') }}" class="block mt-6 text-center bg-purple-600 hover:bg-purple-700 text-white px-4 py-3 rounded-lg transition-colors font-medium">
                            <i class="fas fa-cog ml-2"></i>
                            إدارة إعدادات المستخدمين
                        </a>
                    </div>
                </div>

                <!-- Quick Actions -->
                <div class="bg-white rounded-xl shadow-md overflow-hidden">
                    <div class="bg-gradient-to-r from-gray-700 to-gray-800 px-6 py-4">
                        <h2 class="text-xl font-bold text-white flex items-center">
                            <i class="fas fa-bolt ml-3"></i>
                            إجراءات سريعة
                        </h2>
                    </div>
                    <div class="p-6 space-y-3">
                        <a href="{{ route('admin.notifications.broadcast') }}" class="flex items-center justify-between p-3 bg-blue-50 hover:bg-blue-100 rounded-lg border border-blue-200 transition-colors">
                            <span class="flex items-center text-blue-700">
                                <i class="fas fa-paper-plane ml-2"></i>
                                إرسال إشعار جماعي
                            </span>
                            <i class="fas fa-chevron-left text-blue-400"></i>
                        </a>

                        <a href="{{ route('admin.notifications.statistics') }}" class="flex items-center justify-between p-3 bg-green-50 hover:bg-green-100 rounded-lg border border-green-200 transition-colors">
                            <span class="flex items-center text-green-700">
                                <i class="fas fa-chart-bar ml-2"></i>
                                عرض الإحصائيات
                            </span>
                            <i class="fas fa-chevron-left text-green-400"></i>
                        </a>

                        <a href="{{ route('admin.notifications.index') }}" class="flex items-center justify-between p-3 bg-purple-50 hover:bg-purple-100 rounded-lg border border-purple-200 transition-colors">
                            <span class="flex items-center text-purple-700">
                                <i class="fas fa-list ml-2"></i>
                                جميع الإشعارات
                            </span>
                            <i class="fas fa-chevron-left text-purple-400"></i>
                        </a>
                    </div>
                </div>

            </div>
        </div>

    </div>
</div>
@endsection

@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', function() {
    // Test FCM Connection
    const testFcmBtn = document.getElementById('testFcmBtn');
    const fcmTestResult = document.getElementById('fcmTestResult');

    testFcmBtn.addEventListener('click', function() {
        testFcmBtn.disabled = true;
        testFcmBtn.innerHTML = '<i class="fas fa-spinner fa-spin ml-2"></i> جاري الاختبار...';
        fcmTestResult.classList.add('hidden');

        fetch('{{ route("admin.notifications.configuration.test-fcm") }}', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': '{{ csrf_token() }}'
            }
        })
        .then(response => response.json())
        .then(data => {
            fcmTestResult.classList.remove('hidden');
            if (data.success) {
                fcmTestResult.innerHTML = `
                    <div class="bg-green-100 border border-green-300 text-green-700 px-4 py-3 rounded-lg">
                        <i class="fas fa-check-circle ml-2"></i>
                        <strong>${data.message}</strong>
                        <p class="text-sm mt-1">${data.details}</p>
                    </div>
                `;
            } else {
                fcmTestResult.innerHTML = `
                    <div class="bg-red-100 border border-red-300 text-red-700 px-4 py-3 rounded-lg">
                        <i class="fas fa-times-circle ml-2"></i>
                        <strong>${data.message}</strong>
                        <p class="text-sm mt-1">${data.details}</p>
                    </div>
                `;
            }
        })
        .catch(error => {
            fcmTestResult.classList.remove('hidden');
            fcmTestResult.innerHTML = `
                <div class="bg-red-100 border border-red-300 text-red-700 px-4 py-3 rounded-lg">
                    <i class="fas fa-exclamation-triangle ml-2"></i>
                    <strong>خطأ في الاتصال</strong>
                    <p class="text-sm mt-1">${error.message}</p>
                </div>
            `;
        })
        .finally(() => {
            testFcmBtn.disabled = false;
            testFcmBtn.innerHTML = '<i class="fas fa-plug ml-2"></i> اختبار الاتصال';
        });
    });

    // Clean Inactive Tokens
    const cleanTokensBtn = document.getElementById('cleanTokensBtn');
    const cleanTokensResult = document.getElementById('cleanTokensResult');

    cleanTokensBtn.addEventListener('click', function() {
        if (!confirm('هل أنت متأكد من حذف الرموز غير النشطة؟')) {
            return;
        }

        cleanTokensBtn.disabled = true;
        cleanTokensBtn.innerHTML = '<i class="fas fa-spinner fa-spin ml-2"></i> جاري التنظيف...';
        cleanTokensResult.classList.add('hidden');

        fetch('{{ route("admin.notifications.configuration.clean-tokens") }}', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': '{{ csrf_token() }}'
            }
        })
        .then(response => response.json())
        .then(data => {
            cleanTokensResult.classList.remove('hidden');
            if (data.success) {
                cleanTokensResult.innerHTML = `
                    <div class="bg-green-100 border border-green-300 text-green-700 px-4 py-3 rounded-lg text-center">
                        <i class="fas fa-check-circle ml-2"></i>
                        ${data.message}
                    </div>
                `;
                // Reload page after 2 seconds to update stats
                setTimeout(() => location.reload(), 2000);
            } else {
                cleanTokensResult.innerHTML = `
                    <div class="bg-red-100 border border-red-300 text-red-700 px-4 py-3 rounded-lg text-center">
                        <i class="fas fa-times-circle ml-2"></i>
                        ${data.message}
                    </div>
                `;
            }
        })
        .catch(error => {
            cleanTokensResult.classList.remove('hidden');
            cleanTokensResult.innerHTML = `
                <div class="bg-red-100 border border-red-300 text-red-700 px-4 py-3 rounded-lg text-center">
                    <i class="fas fa-exclamation-triangle ml-2"></i>
                    خطأ في التنظيف
                </div>
            `;
        })
        .finally(() => {
            cleanTokensBtn.disabled = false;
            cleanTokensBtn.innerHTML = '<i class="fas fa-broom ml-2"></i> تنظيف الرموز غير النشطة';
        });
    });
});
</script>
@endpush
