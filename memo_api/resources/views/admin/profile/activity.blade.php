@extends('layouts.admin')

@section('title', 'سجل النشاط')
@section('page-title', 'سجل النشاط')

@section('content')
<div class="max-w-6xl mx-auto" style="font-family: 'Cairo', sans-serif; direction: rtl;">
    <!-- Header -->
    <div class="bg-gradient-to-r from-blue-600 to-indigo-600 rounded-xl shadow-lg p-8 mb-6">
        <div class="flex items-center gap-4">
            <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center">
                <i class="fas fa-history text-3xl text-white"></i>
            </div>
            <div class="flex-1">
                <h1 class="text-3xl font-bold text-white mb-2">سجل النشاط</h1>
                <p class="text-blue-100">تتبع جميع نشاطاتك على المنصة</p>
            </div>
            <a href="{{ route('admin.profile.index') }}" class="px-6 py-3 bg-white bg-opacity-20 hover:bg-opacity-30 text-white rounded-lg font-bold transition-all">
                <i class="fas fa-arrow-right ml-2"></i>
                رجوع
            </a>
        </div>
    </div>

    <!-- Activity Timeline -->
    <div class="bg-white rounded-xl shadow-lg p-6">
        <h2 class="text-xl font-bold text-gray-900 mb-6 flex items-center gap-2">
            <i class="fas fa-stream text-blue-600"></i>
            النشاطات الأخيرة
        </h2>

        <div class="relative">
            <!-- Timeline Line -->
            <div class="absolute right-8 top-0 bottom-0 w-0.5 bg-gray-200"></div>

            <!-- Activity Items -->
            <div class="space-y-6">
                <!-- Login Activity -->
                <div class="relative flex items-start gap-4">
                    <div class="relative z-10 w-16 h-16 bg-green-100 rounded-xl flex items-center justify-center flex-shrink-0">
                        <i class="fas fa-sign-in-alt text-2xl text-green-600"></i>
                    </div>
                    <div class="flex-1 bg-gray-50 rounded-lg p-4">
                        <div class="flex items-start justify-between">
                            <div>
                                <h3 class="font-bold text-gray-900 mb-1">تسجيل دخول</h3>
                                <p class="text-sm text-gray-600">تم تسجيل الدخول بنجاح من جهاز {{ auth()->user()->device_name ?? 'غير معروف' }}</p>
                                <p class="text-xs text-gray-500 mt-2">
                                    <i class="fas fa-clock ml-1"></i>
                                    {{ auth()->user()->last_login_at ? auth()->user()->last_login_at->format('Y-m-d H:i') : 'الآن' }}
                                </p>
                            </div>
                            <span class="px-3 py-1 bg-green-100 text-green-700 rounded-full text-xs font-bold">نجح</span>
                        </div>
                    </div>
                </div>

                <!-- Profile Update Activity -->
                <div class="relative flex items-start gap-4">
                    <div class="relative z-10 w-16 h-16 bg-blue-100 rounded-xl flex items-center justify-center flex-shrink-0">
                        <i class="fas fa-user-edit text-2xl text-blue-600"></i>
                    </div>
                    <div class="flex-1 bg-gray-50 rounded-lg p-4">
                        <div class="flex items-start justify-between">
                            <div>
                                <h3 class="font-bold text-gray-900 mb-1">تحديث الملف الشخصي</h3>
                                <p class="text-sm text-gray-600">تم تحديث معلومات الملف الشخصي</p>
                                <p class="text-xs text-gray-500 mt-2">
                                    <i class="fas fa-clock ml-1"></i>
                                    {{ auth()->user()->updated_at->format('Y-m-d H:i') }}
                                </p>
                            </div>
                            <span class="px-3 py-1 bg-blue-100 text-blue-700 rounded-full text-xs font-bold">معلومات</span>
                        </div>
                    </div>
                </div>

                <!-- Account Created Activity -->
                <div class="relative flex items-start gap-4">
                    <div class="relative z-10 w-16 h-16 bg-purple-100 rounded-xl flex items-center justify-center flex-shrink-0">
                        <i class="fas fa-user-plus text-2xl text-purple-600"></i>
                    </div>
                    <div class="flex-1 bg-gray-50 rounded-lg p-4">
                        <div class="flex items-start justify-between">
                            <div>
                                <h3 class="font-bold text-gray-900 mb-1">إنشاء الحساب</h3>
                                <p class="text-sm text-gray-600">تم إنشاء حسابك بنجاح على المنصة</p>
                                <p class="text-xs text-gray-500 mt-2">
                                    <i class="fas fa-clock ml-1"></i>
                                    {{ auth()->user()->created_at->format('Y-m-d H:i') }}
                                </p>
                            </div>
                            <span class="px-3 py-1 bg-purple-100 text-purple-700 rounded-full text-xs font-bold">معلم</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Empty State (if no more activities) -->
        <div class="mt-8 text-center py-8">
            <i class="fas fa-check-circle text-6xl text-gray-300 mb-4"></i>
            <p class="text-gray-500 font-semibold">لا توجد نشاطات إضافية</p>
            <p class="text-sm text-gray-400 mt-2">سيتم عرض جميع نشاطاتك المستقبلية هنا</p>
        </div>
    </div>

    <!-- Activity Statistics -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mt-6">
        <div class="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-blue-100 text-sm mb-1">مدة العضوية</p>
                    <p class="text-2xl font-bold">{{ auth()->user()->created_at->diffInDays(now()) }} يوم</p>
                </div>
                <div class="w-14 h-14 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                    <i class="fas fa-calendar text-2xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-gradient-to-br from-green-500 to-green-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-green-100 text-sm mb-1">آخر نشاط</p>
                    <p class="text-xl font-bold">{{ auth()->user()->last_login_at ? auth()->user()->last_login_at->diffForHumans() : 'الآن' }}</p>
                </div>
                <div class="w-14 h-14 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                    <i class="fas fa-clock text-2xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-gradient-to-br from-purple-500 to-purple-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-purple-100 text-sm mb-1">الحالة</p>
                    <p class="text-xl font-bold">نشط</p>
                </div>
                <div class="w-14 h-14 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                    <i class="fas fa-check-circle text-2xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-gradient-to-br from-orange-500 to-orange-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-orange-100 text-sm mb-1">مستوى الأمان</p>
                    <p class="text-xl font-bold">جيد</p>
                </div>
                <div class="w-14 h-14 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                    <i class="fas fa-shield-alt text-2xl"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Information -->
    <div class="mt-6 bg-blue-50 border border-blue-200 rounded-xl p-6">
        <div class="flex items-start gap-3">
            <i class="fas fa-info-circle text-blue-600 text-xl mt-1"></i>
            <div>
                <h4 class="font-bold text-gray-900 mb-2">حول سجل النشاط</h4>
                <p class="text-sm text-gray-600">يتم تسجيل جميع نشاطاتك على المنصة بشكل تلقائي لضمان أمان حسابك. يمكنك مراجعة هذا السجل في أي وقت للتحقق من النشاطات التي تمت على حسابك.</p>
            </div>
        </div>
    </div>
</div>
@endsection
