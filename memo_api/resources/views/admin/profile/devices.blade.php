@extends('layouts.admin')

@section('title', 'إدارة الأجهزة')
@section('page-title', 'إدارة الأجهزة')

@section('content')
<div class="max-w-4xl mx-auto" style="font-family: 'Cairo', sans-serif; direction: rtl;">
    <!-- Header -->
    <div class="bg-gradient-to-r from-blue-600 to-indigo-600 rounded-xl shadow-lg p-8 mb-6">
        <div class="flex items-center gap-4">
            <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center">
                <i class="fas fa-mobile-alt text-3xl text-white"></i>
            </div>
            <div class="flex-1">
                <h1 class="text-3xl font-bold text-white mb-2">إدارة الأجهزة</h1>
                <p class="text-blue-100">الأجهزة المرتبطة بحسابك</p>
            </div>
            <a href="{{ route('admin.profile.index') }}" class="px-6 py-3 bg-white bg-opacity-20 hover:bg-opacity-30 text-white rounded-lg font-bold transition-all">
                <i class="fas fa-arrow-right ml-2"></i>
                رجوع
            </a>
        </div>
    </div>

    <!-- Current Device -->
    <div class="bg-white rounded-xl shadow-lg overflow-hidden mb-6">
        <div class="bg-gradient-to-r from-green-500 to-green-600 px-6 py-4">
            <h2 class="text-xl font-bold text-white flex items-center gap-2">
                <i class="fas fa-check-circle"></i>
                الجهاز الحالي
            </h2>
        </div>

        <div class="p-6">
            <div class="flex items-start gap-4">
                <div class="w-16 h-16 bg-green-100 rounded-xl flex items-center justify-center flex-shrink-0">
                    <i class="fas fa-mobile-alt text-3xl text-green-600"></i>
                </div>
                <div class="flex-1">
                    <h3 class="text-xl font-bold text-gray-900 mb-2">{{ $currentDevice['name'] ?? 'جهاز غير معروف' }}</h3>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div class="flex items-center gap-2 text-gray-600">
                            <i class="fas fa-fingerprint text-blue-600"></i>
                            <span class="text-sm"><strong>المعرف:</strong> {{ $currentDevice['id'] ?? 'غير متوفر' }}</span>
                        </div>
                        <div class="flex items-center gap-2 text-gray-600">
                            <i class="fas fa-desktop text-blue-600"></i>
                            <span class="text-sm"><strong>المنصة:</strong> {{ $currentDevice['platform'] ?? 'Unknown' }}</span>
                        </div>
                        <div class="flex items-center gap-2 text-gray-600">
                            <i class="fas fa-clock text-blue-600"></i>
                            <span class="text-sm"><strong>آخر استخدام:</strong> {{ $currentDevice['last_used']->diffForHumans() }}</span>
                        </div>
                        <div class="flex items-center gap-2">
                            <span class="px-3 py-1 bg-green-100 text-green-700 rounded-full text-xs font-bold">
                                <i class="fas fa-circle text-green-500 text-xs ml-1"></i>
                                نشط الآن
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Information Panel -->
    <div class="bg-blue-50 border border-blue-200 rounded-xl p-6">
        <div class="flex items-start gap-3">
            <i class="fas fa-info-circle text-blue-600 text-xl mt-1"></i>
            <div>
                <h4 class="font-bold text-gray-900 mb-2">معلومات هامة</h4>
                <div class="space-y-2 text-sm text-gray-600">
                    <p><i class="fas fa-shield-alt text-blue-600 ml-2"></i>يمكنك استخدام حسابك على جهاز واحد فقط في نفس الوقت</p>
                    <p><i class="fas fa-sync text-blue-600 ml-2"></i>تسجيل الدخول من جهاز جديد سيقوم بتسجيل الخروج من الجهاز السابق</p>
                    <p><i class="fas fa-lock text-blue-600 ml-2"></i>هذا الإجراء يساعد في حماية حسابك من الاستخدام غير المصرح به</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Device Security Tips -->
    <div class="mt-6 bg-white rounded-xl shadow-lg p-6">
        <h3 class="text-lg font-bold text-gray-900 mb-4 flex items-center gap-2">
            <i class="fas fa-lightbulb text-yellow-500"></i>
            نصائح الأمان
        </h3>
        <div class="space-y-3">
            <div class="flex items-start gap-3 p-3 bg-gray-50 rounded-lg">
                <i class="fas fa-check-circle text-green-600 mt-1"></i>
                <div>
                    <p class="font-semibold text-gray-900">لا تشارك معلومات تسجيل الدخول</p>
                    <p class="text-sm text-gray-600">احتفظ باسم المستخدم وكلمة المرور الخاصة بك آمنة ولا تشاركها مع أي شخص</p>
                </div>
            </div>
            <div class="flex items-start gap-3 p-3 bg-gray-50 rounded-lg">
                <i class="fas fa-check-circle text-green-600 mt-1"></i>
                <div>
                    <p class="font-semibold text-gray-900">استخدم كلمة مرور قوية</p>
                    <p class="text-sm text-gray-600">تأكد من أن كلمة المرور تحتوي على أحرف كبيرة وصغيرة وأرقام ورموز</p>
                </div>
            </div>
            <div class="flex items-start gap-3 p-3 bg-gray-50 rounded-lg">
                <i class="fas fa-check-circle text-green-600 mt-1"></i>
                <div>
                    <p class="font-semibold text-gray-900">سجل الخروج عند الانتهاء</p>
                    <p class="text-sm text-gray-600">خاصة إذا كنت تستخدم جهازاً مشتركاً أو عاماً</p>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
