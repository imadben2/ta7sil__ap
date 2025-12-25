@extends('layouts.admin')

@section('title', 'الإعدادات')
@section('page-title', 'الإعدادات')

@section('content')
<div class="container mx-auto px-4" style="font-family: 'Cairo', sans-serif; direction: rtl;">
    <!-- Page Header -->
    <div class="bg-gradient-to-r from-blue-600 to-indigo-600 rounded-xl shadow-lg p-8 mb-6">
        <div class="flex items-center justify-between">
            <div class="flex items-center gap-4">
                <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center">
                    <i class="fas fa-cog text-3xl text-white"></i>
                </div>
                <div>
                    <h1 class="text-3xl font-bold text-white mb-2">الإعدادات</h1>
                    <p class="text-blue-100">إدارة وتخصيص تفضيلاتك الشخصية</p>
                </div>
            </div>
            <a href="{{ route('admin.profile.index') }}" class="px-6 py-3 bg-white bg-opacity-20 hover:bg-opacity-30 text-white rounded-lg font-bold transition-all">
                <i class="fas fa-arrow-right ml-2"></i>
                رجوع
            </a>
        </div>
    </div>

    <form action="{{ route('admin.settings.update') }}" method="POST" id="settingsForm">
        @csrf
        @method('PUT')

        <div class="grid grid-cols-12 gap-6">
            <!-- Left Column (Main Settings) - 8 columns -->
            <div class="col-span-12 lg:col-span-8 space-y-6">

                <!-- App Settings (Version Control) -->
                <div class="bg-white rounded-xl shadow-lg overflow-hidden">
                    <div class="bg-gradient-to-r from-emerald-500 to-emerald-600 px-6 py-4">
                        <h2 class="text-xl font-bold text-white flex items-center gap-2">
                            <i class="fas fa-mobile-alt"></i>
                            إعدادات التطبيق
                        </h2>
                    </div>

                    <div class="p-6 space-y-4">
                        <!-- Minimum App Version -->
                        <div>
                            <label class="block text-sm font-bold text-gray-700 mb-2">الحد الأدنى لإصدار التطبيق</label>
                            <div class="relative">
                                <input type="text" name="min_app_version" value="{{ $appSettings['min_app_version'] ?? '1.0' }}"
                                       placeholder="مثال: 1.0 أو 1.2.3"
                                       pattern="^\d+(\.\d+)*$"
                                       class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500">
                                <div class="absolute left-3 top-1/2 transform -translate-y-1/2">
                                    <i class="fas fa-code-branch text-gray-400"></i>
                                </div>
                            </div>
                            <p class="text-sm text-gray-500 mt-2">
                                <i class="fas fa-info-circle text-emerald-500 ml-1"></i>
                                المستخدمون الذين لديهم إصدار أقدم من هذا الرقم سيُطلب منهم تحديث التطبيق
                            </p>
                        </div>

                        <!-- Warning Box -->
                        <div class="bg-amber-50 border border-amber-200 rounded-xl p-4">
                            <div class="flex items-start gap-3">
                                <i class="fas fa-exclamation-triangle text-amber-600 text-xl mt-1"></i>
                                <div>
                                    <h4 class="font-bold text-amber-800 mb-1">تنبيه مهم</h4>
                                    <p class="text-sm text-amber-700">
                                        تغيير هذا الرقم سيمنع المستخدمين الذين لديهم إصدار أقدم من استخدام التطبيق حتى يقوموا بالتحديث.
                                        تأكد من رفع الإصدار الجديد على المتجر قبل تغيير هذا الرقم.
                                    </p>
                                </div>
                            </div>
                        </div>

                        <div class="border-t border-gray-200 my-4"></div>

                        <!-- Timezone Setting -->
                        <div>
                            <label class="block text-sm font-bold text-gray-700 mb-2">
                                <i class="fas fa-globe text-emerald-500 ml-1"></i>
                                المنطقة الزمنية
                            </label>
                            <div class="relative">
                                <select name="timezone" class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500">
                                    @foreach($timezones as $tz => $label)
                                        <option value="{{ $tz }}" {{ ($appSettings['timezone'] ?? 'Africa/Algiers') === $tz ? 'selected' : '' }}>{{ $label }}</option>
                                    @endforeach
                                </select>
                            </div>
                            <p class="text-sm text-gray-500 mt-2">
                                <i class="fas fa-info-circle text-emerald-500 ml-1"></i>
                                المنطقة الزمنية المستخدمة لعرض التواريخ والأوقات في لوحة التحكم
                            </p>
                            <div class="mt-3 p-3 bg-emerald-50 border border-emerald-200 rounded-lg">
                                <p class="text-sm text-emerald-700">
                                    <i class="fas fa-clock ml-1"></i>
                                    <strong>الوقت الحالي:</strong>
                                    <span id="currentTime">{{ now()->timezone($appSettings['timezone'] ?? 'Africa/Algiers')->format('Y-m-d H:i:s') }}</span>
                                </p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Google Sign-In Settings -->
                <div class="bg-white rounded-xl shadow-lg overflow-hidden">
                    <div class="bg-gradient-to-r from-red-500 to-yellow-500 px-6 py-4">
                        <h2 class="text-xl font-bold text-white flex items-center gap-2">
                            <svg class="w-6 h-6" viewBox="0 0 24 24" fill="currentColor">
                                <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
                                <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
                                <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05"/>
                                <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
                            </svg>
                            تسجيل الدخول بحساب Google
                        </h2>
                    </div>

                    <div class="p-6 space-y-6">
                        <!-- Enable/Disable Google Sign-In -->
                        <div class="flex items-center justify-between p-4 bg-gradient-to-r from-red-50 to-yellow-50 rounded-xl border border-red-100">
                            <div class="flex items-center gap-4">
                                <div class="w-14 h-14 bg-white rounded-xl shadow flex items-center justify-center">
                                    <svg class="w-8 h-8" viewBox="0 0 24 24">
                                        <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
                                        <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
                                        <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05"/>
                                        <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
                                    </svg>
                                </div>
                                <div>
                                    <p class="font-bold text-gray-900 text-lg">تفعيل تسجيل الدخول بـ Google</p>
                                    <p class="text-sm text-gray-600">السماح للمستخدمين بتسجيل الدخول باستخدام حساب Google</p>
                                </div>
                            </div>
                            <label class="relative inline-flex items-center cursor-pointer">
                                <input type="checkbox" name="google_signin_enabled" value="1"
                                       {{ ($googleSettings['enabled'] ?? false) ? 'checked' : '' }}
                                       class="sr-only peer" id="google-signin-toggle">
                                <div class="w-14 h-7 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-red-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-6 after:w-6 after:transition-all peer-checked:bg-gradient-to-r peer-checked:from-red-500 peer-checked:to-yellow-500"></div>
                            </label>
                        </div>

                        <div id="google-settings" class="{{ ($googleSettings['enabled'] ?? false) ? '' : 'opacity-50 pointer-events-none' }}">
                            <!-- Info Box -->
                            <div class="bg-blue-50 border border-blue-200 rounded-xl p-4 mb-6">
                                <div class="flex items-start gap-3">
                                    <i class="fas fa-info-circle text-blue-600 text-xl mt-1"></i>
                                    <div>
                                        <h4 class="font-bold text-blue-800 mb-2">كيفية الحصول على معرفات Google Client IDs</h4>
                                        <ol class="text-sm text-blue-700 space-y-2 list-decimal list-inside">
                                            <li>اذهب إلى <a href="https://console.cloud.google.com/" target="_blank" class="underline font-semibold hover:text-blue-900">Google Cloud Console</a></li>
                                            <li>أنشئ مشروعاً جديداً أو اختر مشروعاً موجوداً</li>
                                            <li>اذهب إلى <strong>APIs & Services</strong> → <strong>Credentials</strong></li>
                                            <li>انقر على <strong>Create Credentials</strong> → <strong>OAuth Client ID</strong></li>
                                            <li>أنشئ 3 معرفات: Web Application, Android, iOS</li>
                                        </ol>
                                    </div>
                                </div>
                            </div>

                            <!-- Web Client ID -->
                            <div class="mb-5">
                                <label class="block text-sm font-bold text-gray-700 mb-2">
                                    <i class="fas fa-globe text-blue-500 ml-1"></i>
                                    معرف العميل للويب (Web Client ID)
                                </label>
                                <div class="relative">
                                    <input type="text" name="google_client_id" value="{{ $googleSettings['client_id'] ?? '' }}"
                                           placeholder="مثال: 123456789-abcdefghijk.apps.googleusercontent.com"
                                           dir="ltr"
                                           class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 font-mono text-sm">
                                    <div class="absolute left-3 top-1/2 transform -translate-y-1/2">
                                        <i class="fas fa-key text-gray-400"></i>
                                    </div>
                                </div>
                                <p class="text-sm text-gray-500 mt-2">
                                    <i class="fas fa-lightbulb text-yellow-500 ml-1"></i>
                                    <strong>الاستخدام:</strong> يُستخدم للتحقق من الرموز (tokens) على الخادم. اختر "Web application" عند إنشاء المعرف.
                                </p>
                            </div>

                            <!-- Android Client ID -->
                            <div class="mb-5">
                                <label class="block text-sm font-bold text-gray-700 mb-2">
                                    <i class="fab fa-android text-green-500 ml-1"></i>
                                    معرف العميل لنظام Android
                                </label>
                                <div class="relative">
                                    <input type="text" name="google_android_client_id" value="{{ $googleSettings['android_client_id'] ?? '' }}"
                                           placeholder="مثال: 123456789-xyzwvuts.apps.googleusercontent.com"
                                           dir="ltr"
                                           class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-green-500 focus:border-green-500 font-mono text-sm">
                                    <div class="absolute left-3 top-1/2 transform -translate-y-1/2">
                                        <i class="fas fa-mobile-alt text-gray-400"></i>
                                    </div>
                                </div>
                                <div class="mt-2 p-3 bg-green-50 border border-green-200 rounded-lg">
                                    <p class="text-sm text-green-700">
                                        <i class="fas fa-info-circle ml-1"></i>
                                        <strong>ملاحظة مهمة:</strong> عند إنشاء معرف Android:
                                    </p>
                                    <ul class="text-sm text-green-600 mt-2 space-y-1 list-disc list-inside mr-4">
                                        <li>اختر "Android" كنوع التطبيق</li>
                                        <li>أدخل Package Name: <code class="bg-green-100 px-1 rounded" dir="ltr">com.memoedu.app</code></li>
                                        <li>أدخل SHA-1 Certificate Fingerprint (من keystore الإنتاج)</li>
                                    </ul>
                                </div>
                            </div>

                            <!-- iOS Client ID -->
                            <div class="mb-5">
                                <label class="block text-sm font-bold text-gray-700 mb-2">
                                    <i class="fab fa-apple text-gray-700 ml-1"></i>
                                    معرف العميل لنظام iOS
                                </label>
                                <div class="relative">
                                    <input type="text" name="google_ios_client_id" value="{{ $googleSettings['ios_client_id'] ?? '' }}"
                                           placeholder="مثال: 123456789-qwertyuiop.apps.googleusercontent.com"
                                           dir="ltr"
                                           class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-gray-500 focus:border-gray-500 font-mono text-sm">
                                    <div class="absolute left-3 top-1/2 transform -translate-y-1/2">
                                        <i class="fas fa-mobile-alt text-gray-400"></i>
                                    </div>
                                </div>
                                <div class="mt-2 p-3 bg-gray-50 border border-gray-200 rounded-lg">
                                    <p class="text-sm text-gray-700">
                                        <i class="fas fa-info-circle ml-1"></i>
                                        <strong>ملاحظة مهمة:</strong> عند إنشاء معرف iOS:
                                    </p>
                                    <ul class="text-sm text-gray-600 mt-2 space-y-1 list-disc list-inside mr-4">
                                        <li>اختر "iOS" كنوع التطبيق</li>
                                        <li>أدخل Bundle ID: <code class="bg-gray-100 px-1 rounded" dir="ltr">com.memoedu.app</code></li>
                                        <li>أضف URL Scheme في Info.plist</li>
                                    </ul>
                                </div>
                            </div>

                            <!-- Warning Box -->
                            <div class="bg-amber-50 border border-amber-200 rounded-xl p-4">
                                <div class="flex items-start gap-3">
                                    <i class="fas fa-exclamation-triangle text-amber-600 text-xl mt-1"></i>
                                    <div>
                                        <h4 class="font-bold text-amber-800 mb-1">تنبيهات أمنية</h4>
                                        <ul class="text-sm text-amber-700 space-y-1 list-disc list-inside">
                                            <li>لا تشارك هذه المعرفات في الأماكن العامة</li>
                                            <li>تأكد من تقييد المعرفات بالنطاقات والتطبيقات المسموح بها فقط</li>
                                            <li>راجع الإعدادات الأمنية في Google Cloud Console بانتظام</li>
                                            <li>فعّل OAuth consent screen بشكل صحيح</li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Notifications Settings -->
                <div class="bg-white rounded-xl shadow-lg overflow-hidden">
                    <div class="bg-gradient-to-r from-blue-500 to-blue-600 px-6 py-4">
                        <h2 class="text-xl font-bold text-white flex items-center gap-2">
                            <i class="fas fa-bell"></i>
                            إعدادات الإشعارات
                        </h2>
                    </div>

                    <div class="p-6 space-y-4">
                        <!-- Notification Types -->
                        <div>
                            <h3 class="text-lg font-bold text-gray-900 mb-4">أنواع الإشعارات</h3>
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                @php
                                    $notificationTypes = [
                                        ['name' => 'notify_new_memo', 'label' => 'محتوى جديد', 'icon' => 'file-alt', 'color' => 'blue'],
                                        ['name' => 'notify_memo_due', 'label' => 'موعد المذاكرة', 'icon' => 'clock', 'color' => 'orange'],
                                        ['name' => 'notify_revision_reminder', 'label' => 'تذكير المراجعة', 'icon' => 'redo', 'color' => 'purple'],
                                        ['name' => 'notify_achievement', 'label' => 'الإنجازات', 'icon' => 'trophy', 'color' => 'yellow'],
                                        ['name' => 'notify_prayer_time', 'label' => 'أوقات الصلاة', 'icon' => 'moon', 'color' => 'green'],
                                        ['name' => 'notify_daily_goal', 'label' => 'الهدف اليومي', 'icon' => 'bullseye', 'color' => 'red'],
                                    ];
                                @endphp

                                @foreach($notificationTypes as $type)
                                <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-all">
                                    <div class="flex items-center gap-3">
                                        <div class="w-10 h-10 bg-{{ $type['color'] }}-100 rounded-lg flex items-center justify-center">
                                            <i class="fas fa-{{ $type['icon'] }} text-{{ $type['color'] }}-600"></i>
                                        </div>
                                        <span class="font-semibold text-gray-800">{{ $type['label'] }}</span>
                                    </div>
                                    <label class="relative inline-flex items-center cursor-pointer">
                                        <input type="checkbox" name="{{ $type['name'] }}" value="1"
                                               {{ ($userSettings->{$type['name']} ?? true) ? 'checked' : '' }}
                                               class="sr-only peer">
                                        <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                                    </label>
                                </div>
                                @endforeach
                            </div>
                        </div>

                        <div class="border-t border-gray-200 my-4"></div>

                        <!-- Notification Channels -->
                        <div>
                            <h3 class="text-lg font-bold text-gray-900 mb-4">قنوات الإشعارات</h3>
                            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                                @php
                                    $channels = [
                                        ['name' => 'notify_push', 'label' => 'إشعارات التطبيق', 'icon' => 'mobile-alt', 'color' => 'blue'],
                                        ['name' => 'notify_email', 'label' => 'البريد الإلكتروني', 'icon' => 'envelope', 'color' => 'green'],
                                        ['name' => 'notify_sms', 'label' => 'الرسائل النصية', 'icon' => 'sms', 'color' => 'purple'],
                                    ];
                                @endphp

                                @foreach($channels as $channel)
                                <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-all">
                                    <div class="flex flex-col items-center gap-2 w-full">
                                        <div class="w-12 h-12 bg-{{ $channel['color'] }}-100 rounded-lg flex items-center justify-center">
                                            <i class="fas fa-{{ $channel['icon'] }} text-xl text-{{ $channel['color'] }}-600"></i>
                                        </div>
                                        <span class="font-semibold text-sm text-gray-800">{{ $channel['label'] }}</span>
                                        <label class="relative inline-flex items-center cursor-pointer">
                                            <input type="checkbox" name="{{ $channel['name'] }}" value="1"
                                                   {{ ($userSettings->{$channel['name']} ?? ($channel['name'] === 'notify_push')) ? 'checked' : '' }}
                                                   class="sr-only peer">
                                            <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                                        </label>
                                    </div>
                                </div>
                                @endforeach
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Prayer Times Settings -->
                <div class="bg-white rounded-xl shadow-lg overflow-hidden">
                    <div class="bg-gradient-to-r from-green-500 to-green-600 px-6 py-4">
                        <h2 class="text-xl font-bold text-white flex items-center gap-2">
                            <i class="fas fa-mosque"></i>
                            إعدادات أوقات الصلاة
                        </h2>
                    </div>

                    <div class="p-6 space-y-4">
                        <!-- Enable Prayer Times -->
                        <div class="flex items-center justify-between p-4 bg-green-50 rounded-lg">
                            <div class="flex items-center gap-3">
                                <div class="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                                    <i class="fas fa-moon text-2xl text-green-600"></i>
                                </div>
                                <div>
                                    <p class="font-bold text-gray-900">تفعيل أوقات الصلاة</p>
                                    <p class="text-sm text-gray-600">عرض أوقات الصلاة في التطبيق</p>
                                </div>
                            </div>
                            <label class="relative inline-flex items-center cursor-pointer">
                                <input type="checkbox" name="prayer_times_enabled" value="1"
                                       {{ ($userSettings->prayer_times_enabled ?? false) ? 'checked' : '' }}
                                       class="sr-only peer" id="prayer-times-toggle">
                                <div class="w-14 h-7 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-green-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-6 after:w-6 after:transition-all peer-checked:bg-green-600"></div>
                            </label>
                        </div>

                        <div id="prayer-settings" class="{{ ($userSettings->prayer_times_enabled ?? false) ? '' : 'hidden' }}">
                            <!-- Calculation Method -->
                            <div class="mb-4">
                                <label class="block text-sm font-bold text-gray-700 mb-2">طريقة الحساب</label>
                                <select name="calculation_method" class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-green-500 focus:border-green-500">
                                    <option value="egyptian" {{ ($userSettings->calculation_method ?? 'egyptian') === 'egyptian' ? 'selected' : '' }}>الهيئة العامة المصرية للمساحة</option>
                                    <option value="mwl" {{ ($userSettings->calculation_method ?? '') === 'mwl' ? 'selected' : '' }}>رابطة العالم الإسلامي</option>
                                    <option value="isna" {{ ($userSettings->calculation_method ?? '') === 'isna' ? 'selected' : '' }}>الجمعية الإسلامية لأمريكا الشمالية</option>
                                    <option value="umm_alqura" {{ ($userSettings->calculation_method ?? '') === 'umm_alqura' ? 'selected' : '' }}>أم القرى - مكة المكرمة</option>
                                </select>
                            </div>

                            <!-- Madhab -->
                            <div class="mb-4">
                                <label class="block text-sm font-bold text-gray-700 mb-2">المذهب</label>
                                <div class="grid grid-cols-2 gap-4">
                                    <label class="relative cursor-pointer">
                                        <input type="radio" name="madhab" value="shafi"
                                               {{ ($userSettings->madhab ?? 'shafi') === 'shafi' ? 'checked' : '' }}
                                               class="sr-only peer">
                                        <div class="p-4 border-2 border-gray-200 rounded-xl peer-checked:border-green-600 peer-checked:bg-green-50 hover:border-green-300 transition-all text-center">
                                            <span class="font-semibold">الشافعي</span>
                                        </div>
                                    </label>
                                    <label class="relative cursor-pointer">
                                        <input type="radio" name="madhab" value="hanafi"
                                               {{ ($userSettings->madhab ?? '') === 'hanafi' ? 'checked' : '' }}
                                               class="sr-only peer">
                                        <div class="p-4 border-2 border-gray-200 rounded-xl peer-checked:border-green-600 peer-checked:bg-green-50 hover:border-green-300 transition-all text-center">
                                            <span class="font-semibold">الحنفي</span>
                                        </div>
                                    </label>
                                </div>
                            </div>

                            <!-- Prayer Notifications -->
                            <div>
                                <label class="block text-sm font-bold text-gray-700 mb-3">إشعارات الصلوات</label>
                                <div class="grid grid-cols-2 md:grid-cols-5 gap-3">
                                    @php
                                        $prayers = ['fajr' => 'الفجر', 'dhuhr' => 'الظهر', 'asr' => 'العصر', 'maghrib' => 'المغرب', 'isha' => 'العشاء'];
                                    @endphp

                                    @foreach($prayers as $key => $name)
                                    <div class="flex flex-col items-center gap-2 p-3 bg-gray-50 rounded-lg">
                                        <span class="text-sm font-semibold">{{ $name }}</span>
                                        <label class="relative inline-flex items-center cursor-pointer">
                                            <input type="checkbox" name="notify_{{ $key }}" value="1"
                                                   {{ ($userSettings->{'notify_'.$key} ?? false) ? 'checked' : '' }}
                                                   class="sr-only peer">
                                            <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-green-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-green-600"></div>
                                        </label>
                                    </div>
                                    @endforeach
                                </div>

                                <div class="mt-4">
                                    <label class="block text-sm font-bold text-gray-700 mb-2">التنبيه قبل الصلاة بـ</label>
                                    <select name="prayer_notification_before" class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-green-500 focus:border-green-500">
                                        <option value="5" {{ ($userSettings->prayer_notification_before ?? 15) == 5 ? 'selected' : '' }}>5 دقائق</option>
                                        <option value="10" {{ ($userSettings->prayer_notification_before ?? 15) == 10 ? 'selected' : '' }}>10 دقائق</option>
                                        <option value="15" {{ ($userSettings->prayer_notification_before ?? 15) == 15 ? 'selected' : '' }}>15 دقيقة</option>
                                        <option value="30" {{ ($userSettings->prayer_notification_before ?? 15) == 30 ? 'selected' : '' }}>30 دقيقة</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Appearance Settings -->
                <div class="bg-white rounded-xl shadow-lg overflow-hidden">
                    <div class="bg-gradient-to-r from-purple-500 to-purple-600 px-6 py-4">
                        <h2 class="text-xl font-bold text-white flex items-center gap-2">
                            <i class="fas fa-palette"></i>
                            إعدادات المظهر
                        </h2>
                    </div>

                    <div class="p-6 space-y-6">
                        <!-- Theme Selection -->
                        <div>
                            <label class="block text-sm font-bold text-gray-700 mb-3">المظهر</label>
                            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                                <label class="relative cursor-pointer">
                                    <input type="radio" name="theme" value="light"
                                           {{ ($userSettings->theme ?? 'system') === 'light' ? 'checked' : '' }}
                                           class="sr-only peer">
                                    <div class="p-6 border-2 border-gray-200 rounded-xl peer-checked:border-purple-600 peer-checked:bg-purple-50 hover:border-purple-300 transition-all">
                                        <div class="flex flex-col items-center gap-3">
                                            <i class="fas fa-sun text-4xl text-yellow-500"></i>
                                            <span class="font-semibold">فاتح</span>
                                        </div>
                                    </div>
                                </label>

                                <label class="relative cursor-pointer">
                                    <input type="radio" name="theme" value="dark"
                                           {{ ($userSettings->theme ?? 'system') === 'dark' ? 'checked' : '' }}
                                           class="sr-only peer">
                                    <div class="p-6 border-2 border-gray-200 rounded-xl peer-checked:border-purple-600 peer-checked:bg-purple-50 hover:border-purple-300 transition-all">
                                        <div class="flex flex-col items-center gap-3">
                                            <i class="fas fa-moon text-4xl text-indigo-600"></i>
                                            <span class="font-semibold">داكن</span>
                                        </div>
                                    </div>
                                </label>

                                <label class="relative cursor-pointer">
                                    <input type="radio" name="theme" value="system"
                                           {{ ($userSettings->theme ?? 'system') === 'system' ? 'checked' : '' }}
                                           class="sr-only peer">
                                    <div class="p-6 border-2 border-gray-200 rounded-xl peer-checked:border-purple-600 peer-checked:bg-purple-50 hover:border-purple-300 transition-all">
                                        <div class="flex flex-col items-center gap-3">
                                            <i class="fas fa-adjust text-4xl text-gray-600"></i>
                                            <span class="font-semibold">تلقائي</span>
                                        </div>
                                    </div>
                                </label>
                            </div>
                        </div>

                        <!-- Primary Color -->
                        <div>
                            <label class="block text-sm font-bold text-gray-700 mb-3">اللون الأساسي</label>
                            <div class="grid grid-cols-4 md:grid-cols-6 gap-3">
                                @php
                                    $colors = [
                                        'blue' => '#3B82F6',
                                        'green' => '#10B981',
                                        'purple' => '#8B5CF6',
                                        'red' => '#EF4444',
                                        'orange' => '#F97316',
                                        'pink' => '#EC4899',
                                        'indigo' => '#6366F1',
                                        'teal' => '#14B8A6',
                                    ];
                                @endphp

                                @foreach($colors as $colorName => $colorCode)
                                <label class="relative cursor-pointer">
                                    <input type="radio" name="primary_color" value="{{ $colorName }}"
                                           {{ ($userSettings->primary_color ?? 'blue') === $colorName ? 'checked' : '' }}
                                           class="sr-only peer">
                                    <div class="w-full h-16 rounded-xl border-4 border-gray-200 peer-checked:border-gray-900 hover:scale-110 transition-all" style="background-color: {{ $colorCode }}">
                                        <div class="w-full h-full flex items-center justify-center">
                                            <i class="fas fa-check text-white text-2xl opacity-0 peer-checked:opacity-100"></i>
                                        </div>
                                    </div>
                                </label>
                                @endforeach
                            </div>
                        </div>

                        <!-- Language -->
                        <div>
                            <label class="block text-sm font-bold text-gray-700 mb-3">لغة الواجهة</label>
                            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                                <label class="relative cursor-pointer">
                                    <input type="radio" name="language" value="ar"
                                           {{ ($userSettings->language ?? 'ar') === 'ar' ? 'checked' : '' }}
                                           class="sr-only peer">
                                    <div class="p-4 border-2 border-gray-200 rounded-xl peer-checked:border-purple-600 peer-checked:bg-purple-50 hover:border-purple-300 transition-all">
                                        <div class="flex items-center gap-3">
                                            <div class="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center text-2xl">
                                                🇩🇿
                                            </div>
                                            <span class="font-semibold">العربية</span>
                                        </div>
                                    </div>
                                </label>

                                <label class="relative cursor-pointer">
                                    <input type="radio" name="language" value="fr"
                                           {{ ($userSettings->language ?? 'ar') === 'fr' ? 'checked' : '' }}
                                           class="sr-only peer">
                                    <div class="p-4 border-2 border-gray-200 rounded-xl peer-checked:border-purple-600 peer-checked:bg-purple-50 hover:border-purple-300 transition-all">
                                        <div class="flex items-center gap-3">
                                            <div class="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center text-2xl">
                                                🇫🇷
                                            </div>
                                            <span class="font-semibold">Français</span>
                                        </div>
                                    </div>
                                </label>

                                <label class="relative cursor-pointer">
                                    <input type="radio" name="language" value="en"
                                           {{ ($userSettings->language ?? 'ar') === 'en' ? 'checked' : '' }}
                                           class="sr-only peer">
                                    <div class="p-4 border-2 border-gray-200 rounded-xl peer-checked:border-purple-600 peer-checked:bg-purple-50 hover:border-purple-300 transition-all">
                                        <div class="flex items-center gap-3">
                                            <div class="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center text-2xl">
                                                🇬🇧
                                            </div>
                                            <span class="font-semibold">English</span>
                                        </div>
                                    </div>
                                </label>
                            </div>
                        </div>

                        <!-- RTL Mode -->
                        <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                            <div class="flex items-center gap-3">
                                <div class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                                    <i class="fas fa-align-right text-xl text-purple-600"></i>
                                </div>
                                <div>
                                    <p class="font-bold text-gray-900">وضع RTL</p>
                                    <p class="text-sm text-gray-600">الكتابة من اليمين إلى اليسار</p>
                                </div>
                            </div>
                            <label class="relative inline-flex items-center cursor-pointer">
                                <input type="checkbox" name="rtl_mode" value="1"
                                       {{ ($userSettings->rtl_mode ?? true) ? 'checked' : '' }}
                                       class="sr-only peer">
                                <div class="w-14 h-7 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-purple-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-6 after:w-6 after:transition-all peer-checked:bg-purple-600"></div>
                            </label>
                        </div>
                    </div>
                </div>

                <!-- Study Settings -->
                <div class="bg-white rounded-xl shadow-lg overflow-hidden">
                    <div class="bg-gradient-to-r from-orange-500 to-orange-600 px-6 py-4">
                        <h2 class="text-xl font-bold text-white flex items-center gap-2">
                            <i class="fas fa-book-reader"></i>
                            إعدادات الدراسة
                        </h2>
                    </div>

                    <div class="p-6 space-y-4">
                        <!-- Daily Goal -->
                        <div>
                            <label class="block text-sm font-bold text-gray-700 mb-2">الهدف اليومي (بالدقائق)</label>
                            <div class="relative">
                                <input type="number" name="daily_goal_minutes" value="{{ $userSettings->daily_goal_minutes ?? 120 }}" min="15" max="600" step="15"
                                       class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-orange-500 focus:border-orange-500">
                                <div class="absolute left-3 top-1/2 transform -translate-y-1/2">
                                    <i class="fas fa-clock text-gray-400"></i>
                                </div>
                            </div>
                            <p class="text-sm text-gray-500 mt-2">الوقت المستهدف للدراسة يومياً</p>
                        </div>

                        <!-- First Day of Week -->
                        <div>
                            <label class="block text-sm font-bold text-gray-700 mb-2">أول يوم في الأسبوع</label>
                            <select name="first_day_of_week" class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-orange-500 focus:border-orange-500">
                                <option value="saturday" {{ ($userSettings->first_day_of_week ?? 'saturday') === 'saturday' ? 'selected' : '' }}>السبت</option>
                                <option value="sunday" {{ ($userSettings->first_day_of_week ?? 'saturday') === 'sunday' ? 'selected' : '' }}>الأحد</option>
                                <option value="monday" {{ ($userSettings->first_day_of_week ?? 'saturday') === 'monday' ? 'selected' : '' }}>الاثنين</option>
                            </select>
                        </div>

                        <!-- Show Streak Reminder -->
                        <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                            <div class="flex items-center gap-3">
                                <div class="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
                                    <i class="fas fa-fire text-xl text-orange-600"></i>
                                </div>
                                <div>
                                    <p class="font-bold text-gray-900">تذكير السلسلة</p>
                                    <p class="text-sm text-gray-600">إظهار تذكير للحفاظ على سلسلة الأيام</p>
                                </div>
                            </div>
                            <label class="relative inline-flex items-center cursor-pointer">
                                <input type="checkbox" name="show_streak_reminder" value="1"
                                       {{ ($userSettings->show_streak_reminder ?? true) ? 'checked' : '' }}
                                       class="sr-only peer">
                                <div class="w-14 h-7 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-orange-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-6 after:w-6 after:transition-all peer-checked:bg-orange-600"></div>
                            </label>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Right Column (Quick Settings & Info) - 4 columns -->
            <div class="col-span-12 lg:col-span-4 space-y-6">

                <!-- Quick Actions -->
                <div class="bg-white rounded-xl shadow-lg overflow-hidden sticky top-6">
                    <div class="bg-gradient-to-r from-indigo-500 to-indigo-600 px-6 py-4">
                        <h2 class="text-xl font-bold text-white flex items-center gap-2">
                            <i class="fas fa-bolt"></i>
                            إجراءات سريعة
                        </h2>
                    </div>

                    <div class="p-6 space-y-3">
                        <button type="submit" class="w-full px-6 py-3 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white rounded-xl font-bold shadow-lg transition-all">
                            <i class="fas fa-save ml-2"></i>
                            حفظ جميع التغييرات
                        </button>

                        <button type="button" onclick="resetSettings()" class="w-full px-6 py-3 border-2 border-gray-300 rounded-xl text-gray-700 hover:bg-gray-50 font-bold transition-all">
                            <i class="fas fa-undo ml-2"></i>
                            إعادة تعيين
                        </button>

                        <a href="{{ route('admin.profile.index') }}" class="block w-full px-6 py-3 border-2 border-gray-300 rounded-xl text-gray-700 hover:bg-gray-50 font-bold transition-all text-center">
                            <i class="fas fa-times ml-2"></i>
                            إلغاء
                        </a>
                    </div>
                </div>

                <!-- Privacy Settings -->
                <div class="bg-white rounded-xl shadow-lg overflow-hidden">
                    <div class="bg-gradient-to-r from-red-500 to-red-600 px-6 py-4">
                        <h2 class="text-xl font-bold text-white flex items-center gap-2">
                            <i class="fas fa-shield-alt"></i>
                            الخصوصية
                        </h2>
                    </div>

                    <div class="p-6 space-y-3">
                        @php
                            $privacySettings = [
                                ['name' => 'profile_public', 'label' => 'الملف العام', 'icon' => 'globe'],
                                ['name' => 'show_statistics', 'label' => 'عرض الإحصائيات', 'icon' => 'chart-bar'],
                                ['name' => 'allow_friend_requests', 'label' => 'طلبات الصداقة', 'icon' => 'user-friends'],
                            ];
                        @endphp

                        @foreach($privacySettings as $setting)
                        <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                            <div class="flex items-center gap-2">
                                <i class="fas fa-{{ $setting['icon'] }} text-red-600"></i>
                                <span class="text-sm font-semibold">{{ $setting['label'] }}</span>
                            </div>
                            <label class="relative inline-flex items-center cursor-pointer">
                                <input type="checkbox" name="{{ $setting['name'] }}" value="1"
                                       {{ ($userSettings->{$setting['name']} ?? ($setting['name'] === 'show_statistics')) ? 'checked' : '' }}
                                       class="sr-only peer">
                                <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-red-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-red-600"></div>
                            </label>
                        </div>
                        @endforeach
                    </div>
                </div>

                <!-- Storage Link -->
                <div class="bg-white rounded-xl shadow-lg overflow-hidden">
                    <div class="bg-gradient-to-r from-cyan-500 to-cyan-600 px-6 py-4">
                        <h2 class="text-xl font-bold text-white flex items-center gap-2">
                            <i class="fas fa-link"></i>
                            رابط التخزين (Storage Link)
                        </h2>
                    </div>

                    <div class="p-6 space-y-4">
                        <div class="bg-cyan-50 border border-cyan-200 rounded-xl p-4 mb-4">
                            <div class="flex items-start gap-3">
                                <i class="fas fa-info-circle text-cyan-600 text-xl mt-1"></i>
                                <div>
                                    <h4 class="font-bold text-cyan-800 mb-1">ما هو رابط التخزين؟</h4>
                                    <p class="text-sm text-cyan-700">
                                        رابط التخزين يربط مجلد <code class="bg-cyan-100 px-1 rounded">storage/app/public</code> بمجلد <code class="bg-cyan-100 px-1 rounded">public/storage</code>
                                        لإتاحة الوصول للملفات (الصور، الفيديوهات، إلخ) عبر الويب.
                                    </p>
                                </div>
                            </div>
                        </div>

                        <div id="storage-link-status" class="p-4 rounded-xl border-2">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-3">
                                    <div id="storage-status-icon" class="w-12 h-12 rounded-lg flex items-center justify-center">
                                        <i class="fas fa-spinner fa-spin text-xl text-gray-400"></i>
                                    </div>
                                    <div>
                                        <p id="storage-status-text" class="font-bold text-gray-900">جاري التحقق...</p>
                                        <p id="storage-status-desc" class="text-sm text-gray-600">التحقق من حالة رابط التخزين</p>
                                    </div>
                                </div>
                                <button type="button" id="storage-link-btn" onclick="createStorageLink()" disabled
                                        class="px-4 py-2 bg-cyan-600 hover:bg-cyan-700 text-white rounded-lg font-bold transition-all disabled:opacity-50 disabled:cursor-not-allowed">
                                    <i class="fas fa-link ml-1"></i>
                                    إنشاء الرابط
                                </button>
                            </div>
                        </div>

                        <div class="bg-amber-50 border border-amber-200 rounded-xl p-4">
                            <div class="flex items-start gap-3">
                                <i class="fas fa-exclamation-triangle text-amber-600 text-xl mt-1"></i>
                                <div>
                                    <h4 class="font-bold text-amber-800 mb-1">ملاحظة للخوادم</h4>
                                    <p class="text-sm text-amber-700">
                                        في بعض الخوادم (مثل shared hosting)، قد لا تعمل الروابط الرمزية.
                                        في هذه الحالة، يمكنك نسخ الملفات يدوياً أو تغيير إعدادات <code class="bg-amber-100 px-1 rounded">filesystems.php</code>.
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Data & Storage -->
                <div class="bg-white rounded-xl shadow-lg overflow-hidden">
                    <div class="bg-gradient-to-r from-teal-500 to-teal-600 px-6 py-4">
                        <h2 class="text-xl font-bold text-white flex items-center gap-2">
                            <i class="fas fa-database"></i>
                            البيانات والتخزين
                        </h2>
                    </div>

                    <div class="p-6 space-y-4">
                        <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                            <div class="flex items-center gap-2">
                                <i class="fas fa-cloud-upload-alt text-teal-600"></i>
                                <span class="text-sm font-semibold">النسخ الاحتياطي التلقائي</span>
                            </div>
                            <label class="relative inline-flex items-center cursor-pointer">
                                <input type="checkbox" name="auto_backup" value="1"
                                       {{ ($userSettings->auto_backup ?? false) ? 'checked' : '' }}
                                       class="sr-only peer">
                                <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-teal-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-teal-600"></div>
                            </label>
                        </div>

                        <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                            <div class="flex items-center gap-2">
                                <i class="fas fa-wifi text-teal-600"></i>
                                <span class="text-sm font-semibold">تنزيل عبر Wi-Fi فقط</span>
                            </div>
                            <label class="relative inline-flex items-center cursor-pointer">
                                <input type="checkbox" name="download_on_wifi_only" value="1"
                                       {{ ($userSettings->download_on_wifi_only ?? true) ? 'checked' : '' }}
                                       class="sr-only peer">
                                <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-teal-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-teal-600"></div>
                            </label>
                        </div>

                        <div>
                            <label class="block text-sm font-bold text-gray-700 mb-2">تكرار النسخ الاحتياطي</label>
                            <select name="backup_frequency" class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-teal-500 focus:border-teal-500">
                                <option value="daily" {{ ($userSettings->backup_frequency ?? 'weekly') === 'daily' ? 'selected' : '' }}>يومي</option>
                                <option value="weekly" {{ ($userSettings->backup_frequency ?? 'weekly') === 'weekly' ? 'selected' : '' }}>أسبوعي</option>
                                <option value="monthly" {{ ($userSettings->backup_frequency ?? 'weekly') === 'monthly' ? 'selected' : '' }}>شهري</option>
                            </select>
                        </div>
                    </div>
                </div>

                <!-- Information Panel -->
                <div class="bg-blue-50 border border-blue-200 rounded-xl p-6">
                    <div class="flex items-start gap-3">
                        <i class="fas fa-info-circle text-blue-600 text-xl mt-1"></i>
                        <div>
                            <h4 class="font-bold text-gray-900 mb-2">معلومات</h4>
                            <ul class="space-y-2 text-sm text-gray-600">
                                <li class="flex items-start gap-2">
                                    <i class="fas fa-check text-blue-600 mt-1"></i>
                                    <span>سيتم حفظ جميع الإعدادات تلقائياً</span>
                                </li>
                                <li class="flex items-start gap-2">
                                    <i class="fas fa-check text-blue-600 mt-1"></i>
                                    <span>التغييرات تُطبق فوراً على جميع الأجهزة</span>
                                </li>
                                <li class="flex items-start gap-2">
                                    <i class="fas fa-check text-blue-600 mt-1"></i>
                                    <span>يمكنك إعادة تعيين الإعدادات إلى الوضع الافتراضي في أي وقت</span>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</div>

@push('scripts')
<script>
// Google Sign-In toggle
document.getElementById('google-signin-toggle').addEventListener('change', function() {
    const googleSettings = document.getElementById('google-settings');
    if (this.checked) {
        googleSettings.classList.remove('opacity-50', 'pointer-events-none');
    } else {
        googleSettings.classList.add('opacity-50', 'pointer-events-none');
    }
});

// Prayer times toggle
document.getElementById('prayer-times-toggle').addEventListener('change', function() {
    const prayerSettings = document.getElementById('prayer-settings');
    if (this.checked) {
        prayerSettings.classList.remove('hidden');
    } else {
        prayerSettings.classList.add('hidden');
    }
});

// Reset settings
function resetSettings() {
    if (confirm('هل أنت متأكد من إعادة تعيين جميع الإعدادات إلى الوضع الافتراضي؟')) {
        // Reload the page
        window.location.reload();
    }
}

// Form submission with loading state
document.getElementById('settingsForm').addEventListener('submit', function(e) {
    const submitButton = this.querySelector('button[type="submit"]');
    submitButton.disabled = true;
    submitButton.innerHTML = '<i class="fas fa-spinner fa-spin ml-2"></i>جاري الحفظ...';
});

// Auto-save notification (optional)
let saveTimeout;
const formInputs = document.querySelectorAll('#settingsForm input, #settingsForm select');
formInputs.forEach(input => {
    input.addEventListener('change', function() {
        clearTimeout(saveTimeout);
        // Show indicator that changes are pending
        const submitButton = document.querySelector('button[type="submit"]');
        submitButton.classList.add('animate-pulse');

        saveTimeout = setTimeout(() => {
            submitButton.classList.remove('animate-pulse');
        }, 2000);
    });
});

// Update current time display when timezone changes
const timezoneSelect = document.querySelector('select[name="timezone"]');
if (timezoneSelect) {
    timezoneSelect.addEventListener('change', function() {
        const selectedTimezone = this.value;
        const currentTimeSpan = document.getElementById('currentTime');
        if (currentTimeSpan) {
            // Show loading
            currentTimeSpan.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';

            // Format time in selected timezone using JavaScript
            try {
                const now = new Date();
                const options = {
                    timeZone: selectedTimezone,
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit',
                    hour12: false
                };
                const formatter = new Intl.DateTimeFormat('en-CA', options);
                const parts = formatter.formatToParts(now);
                const formatted = `${parts.find(p => p.type === 'year').value}-${parts.find(p => p.type === 'month').value}-${parts.find(p => p.type === 'day').value} ${parts.find(p => p.type === 'hour').value}:${parts.find(p => p.type === 'minute').value}:${parts.find(p => p.type === 'second').value}`;
                currentTimeSpan.textContent = formatted;
            } catch (e) {
                currentTimeSpan.textContent = 'خطأ في عرض الوقت';
            }
        }
    });
}

// Storage Link Functions
function checkStorageLink() {
    fetch('{{ route("admin.storage.check") }}')
        .then(response => response.json())
        .then(data => {
            updateStorageLinkUI(data.exists, data.message);
        })
        .catch(error => {
            updateStorageLinkUI(false, 'حدث خطأ أثناء التحقق');
        });
}

function updateStorageLinkUI(exists, message) {
    const statusDiv = document.getElementById('storage-link-status');
    const statusIcon = document.getElementById('storage-status-icon');
    const statusText = document.getElementById('storage-status-text');
    const statusDesc = document.getElementById('storage-status-desc');
    const btn = document.getElementById('storage-link-btn');

    if (exists) {
        statusDiv.classList.remove('border-red-200', 'bg-red-50', 'border-gray-200');
        statusDiv.classList.add('border-green-200', 'bg-green-50');
        statusIcon.innerHTML = '<i class="fas fa-check-circle text-2xl text-green-600"></i>';
        statusIcon.classList.remove('bg-red-100', 'bg-gray-100');
        statusIcon.classList.add('bg-green-100');
        statusText.textContent = 'رابط التخزين نشط';
        statusText.classList.remove('text-red-600');
        statusText.classList.add('text-green-600');
        statusDesc.textContent = message || 'الرابط يعمل بشكل صحيح';
        btn.textContent = 'إعادة إنشاء';
        btn.innerHTML = '<i class="fas fa-redo ml-1"></i> إعادة إنشاء';
        btn.classList.remove('bg-cyan-600', 'hover:bg-cyan-700');
        btn.classList.add('bg-gray-500', 'hover:bg-gray-600');
    } else {
        statusDiv.classList.remove('border-green-200', 'bg-green-50', 'border-gray-200');
        statusDiv.classList.add('border-red-200', 'bg-red-50');
        statusIcon.innerHTML = '<i class="fas fa-exclamation-circle text-2xl text-red-600"></i>';
        statusIcon.classList.remove('bg-green-100', 'bg-gray-100');
        statusIcon.classList.add('bg-red-100');
        statusText.textContent = 'رابط التخزين غير موجود';
        statusText.classList.remove('text-green-600');
        statusText.classList.add('text-red-600');
        statusDesc.textContent = message || 'الملفات لن تظهر بشكل صحيح';
        btn.innerHTML = '<i class="fas fa-link ml-1"></i> إنشاء الرابط';
        btn.classList.remove('bg-gray-500', 'hover:bg-gray-600');
        btn.classList.add('bg-cyan-600', 'hover:bg-cyan-700');
    }
    btn.disabled = false;
}

function createStorageLink() {
    const btn = document.getElementById('storage-link-btn');
    btn.disabled = true;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin ml-1"></i> جاري الإنشاء...';

    fetch('{{ route("admin.storage.link") }}', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': '{{ csrf_token() }}'
        }
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            updateStorageLinkUI(true, data.message);
            showToast('success', data.message);
        } else {
            updateStorageLinkUI(false, data.message);
            showToast('error', data.message);
        }
    })
    .catch(error => {
        updateStorageLinkUI(false, 'حدث خطأ أثناء إنشاء الرابط');
        showToast('error', 'حدث خطأ أثناء إنشاء الرابط');
    });
}

function showToast(type, message) {
    const toast = document.createElement('div');
    toast.className = `fixed bottom-4 left-4 px-6 py-3 rounded-xl shadow-lg z-50 flex items-center gap-3 transform transition-all duration-300 ${type === 'success' ? 'bg-green-600' : 'bg-red-600'} text-white`;
    toast.innerHTML = `
        <i class="fas ${type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle'}"></i>
        <span>${message}</span>
    `;
    document.body.appendChild(toast);
    setTimeout(() => {
        toast.classList.add('opacity-0', 'translate-y-2');
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

// Check storage link on page load
document.addEventListener('DOMContentLoaded', function() {
    checkStorageLink();
});
</script>
@endpush
@endsection
