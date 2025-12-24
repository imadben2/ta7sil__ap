@extends('layouts.admin')

@section('title', 'تفاصيل الاشتراك')
@section('page-title', 'تفاصيل الاشتراك #' . $subscription->id)

@section('content')
<div class="max-w-7xl mx-auto space-y-6" style="font-family: 'Cairo', sans-serif; direction: rtl;">
    <!-- Enhanced Header with Gradient -->
    <div class="bg-gradient-to-r from-cyan-600 to-blue-600 rounded-xl shadow-lg p-6">
        <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
            <div class="flex items-center gap-4">
                <a href="{{ route('admin.subscriptions.index') }}"
                   class="w-12 h-12 bg-white bg-opacity-20 hover:bg-opacity-30 rounded-lg flex items-center justify-center text-white transition-all">
                    <i class="fas fa-arrow-right text-xl"></i>
                </a>
                <div class="text-white">
                    <h2 class="text-2xl font-bold mb-1">تفاصيل الاشتراك #{{ $subscription->id }}</h2>
                    <p class="text-cyan-100">عرض وإدارة تفاصيل اشتراك الطالب</p>
                </div>
            </div>
            <div class="flex gap-3 flex-wrap">
                @if($subscription->status === 'active')
                    <form action="{{ route('admin.subscriptions.suspend', $subscription) }}" method="POST" class="inline">
                        @csrf
                        <button type="submit" onclick="return confirm('هل أنت متأكد من تعليق هذا الاشتراك؟')"
                                class="px-5 py-3 bg-yellow-500 hover:bg-yellow-600 text-white rounded-lg flex items-center gap-2 shadow-md font-semibold transition-all">
                            <i class="fas fa-pause-circle"></i>
                            <span>تعليق</span>
                        </button>
                    </form>
                @elseif($subscription->status === 'suspended')
                    <form action="{{ route('admin.subscriptions.activate', $subscription) }}" method="POST" class="inline">
                        @csrf
                        <button type="submit"
                                class="px-5 py-3 bg-green-500 hover:bg-green-600 text-white rounded-lg flex items-center gap-2 shadow-md font-semibold transition-all">
                            <i class="fas fa-play-circle"></i>
                            <span>تفعيل</span>
                        </button>
                    </form>
                @endif

                <button onclick="showExtendModal()"
                        class="px-5 py-3 bg-white text-cyan-600 hover:bg-cyan-50 rounded-lg flex items-center gap-2 shadow-md font-semibold transition-all">
                    <i class="fas fa-calendar-plus"></i>
                    <span>تمديد الاشتراك</span>
                </button>
            </div>
        </div>
    </div>

    <!-- Status Banner with Gradient -->
    <div class="
        @if($subscription->status === 'active') bg-gradient-to-r from-green-500 to-green-600
        @elseif($subscription->status === 'suspended') bg-gradient-to-r from-yellow-500 to-orange-500
        @elseif($subscription->status === 'expired') bg-gradient-to-r from-red-500 to-red-600
        @else bg-gradient-to-r from-gray-500 to-gray-600
        @endif
        rounded-xl shadow-lg p-6">
        <div class="flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
            <div class="text-white">
                <h3 class="text-2xl font-bold mb-2 flex items-center gap-2">
                    @if($subscription->status === 'active')
                        <i class="fas fa-check-circle"></i>اشتراك نشط
                    @elseif($subscription->status === 'suspended')
                        <i class="fas fa-pause-circle"></i>اشتراك معلق
                    @elseif($subscription->status === 'expired')
                        <i class="fas fa-times-circle"></i>اشتراك منتهي
                    @else
                        <i class="fas fa-circle"></i>{{ $subscription->status }}
                    @endif
                </h3>
                <p class="
                    @if($subscription->status === 'active') text-green-100
                    @elseif($subscription->status === 'suspended') text-yellow-100
                    @elseif($subscription->status === 'expired') text-red-100
                    @else text-gray-100
                    @endif
                    text-lg">
                    @if($subscription->expires_at)
                        @if($subscription->status === 'active')
                            {{ $subscription->expires_at->diffForHumans() }} {{ $subscription->expires_at->isFuture() ? 'للانتهاء' : 'منذ الانتهاء' }}
                        @else
                            انتهى في {{ $subscription->expires_at->format('Y-m-d') }}
                        @endif
                    @else
                        اشتراك دائم
                    @endif
                </p>
            </div>
            <div>
                @if($subscription->status === 'active')
                    <div class="px-6 py-3 bg-white bg-opacity-20 rounded-lg text-white font-bold text-lg shadow-md">
                        <i class="fas fa-check-circle ml-2"></i>نشط
                    </div>
                @elseif($subscription->status === 'suspended')
                    <div class="px-6 py-3 bg-white bg-opacity-20 rounded-lg text-white font-bold text-lg shadow-md">
                        <i class="fas fa-pause-circle ml-2"></i>معلق
                    </div>
                @elseif($subscription->status === 'expired')
                    <div class="px-6 py-3 bg-white bg-opacity-20 rounded-lg text-white font-bold text-lg shadow-md">
                        <i class="fas fa-times-circle ml-2"></i>منتهي
                    </div>
                @else
                    <div class="px-6 py-3 bg-white bg-opacity-20 rounded-lg text-white font-bold text-lg shadow-md">
                        {{ $subscription->status }}
                    </div>
                @endif
            </div>
        </div>
    </div>

    <!-- Student Information Card -->
    <div class="bg-white rounded-xl shadow-md overflow-hidden">
        <div class="bg-gradient-to-r from-blue-50 to-indigo-50 px-6 py-4 border-b-2 border-blue-200">
            <h3 class="text-xl font-bold text-blue-900 flex items-center gap-2">
                <i class="fas fa-user-graduate"></i>
                معلومات الطالب
            </h3>
        </div>

        <div class="p-6">
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div class="bg-gradient-to-br from-blue-50 to-blue-100 rounded-lg p-4">
                    <label class="block text-sm font-semibold text-blue-700 mb-2 flex items-center gap-2">
                        <i class="fas fa-user"></i>
                        الاسم الكامل
                    </label>
                    <p class="text-lg text-blue-900 font-bold">{{ $subscription->user->full_name_ar }}</p>
                </div>
                <div class="bg-gradient-to-br from-purple-50 to-purple-100 rounded-lg p-4">
                    <label class="block text-sm font-semibold text-purple-700 mb-2 flex items-center gap-2">
                        <i class="fas fa-envelope"></i>
                        البريد الإلكتروني
                    </label>
                    <p class="text-lg text-purple-900 font-semibold">{{ $subscription->user->email }}</p>
                </div>
                <div class="bg-gradient-to-br from-green-50 to-green-100 rounded-lg p-4">
                    <label class="block text-sm font-semibold text-green-700 mb-2 flex items-center gap-2">
                        <i class="fas fa-phone"></i>
                        رقم الهاتف
                    </label>
                    <p class="text-lg text-green-900 font-semibold">{{ $subscription->user->phone ?? 'غير متوفر' }}</p>
                </div>
            </div>
            <div class="mt-6">
                <a href="{{ route('admin.users.show', $subscription->user) }}"
                   class="inline-flex items-center gap-2 px-5 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-semibold shadow-md transition-all">
                    <i class="fas fa-user"></i>
                    <span>عرض ملف الطالب الكامل</span>
                </a>
            </div>
        </div>
    </div>

    <!-- Subscription Type & Content Card -->
    <div class="bg-white rounded-xl shadow-md overflow-hidden">
        <div class="bg-gradient-to-r from-purple-50 to-pink-50 px-6 py-4 border-b-2 border-purple-200">
            <h3 class="text-xl font-bold text-purple-900 flex items-center gap-2">
                <i class="fas fa-box-open"></i>
                نوع الاشتراك والمحتوى
            </h3>
        </div>
        <div class="p-6 space-y-6">

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div class="bg-gradient-to-br from-indigo-50 to-indigo-100 rounded-lg p-5">
                    <label class="block text-sm font-bold text-indigo-700 mb-3 flex items-center gap-2">
                        <i class="fas fa-tags"></i>
                        نوع الاشتراك
                    </label>
                    <p class="text-xl text-indigo-900 font-bold flex items-center gap-2">
                        @if($subscription->course)
                            <i class="fas fa-video"></i>دورة واحدة
                        @elseif($subscription->package)
                            <i class="fas fa-box"></i>باقة اشتراك
                        @else
                            <i class="fas fa-infinity"></i>اشتراك شامل
                        @endif
                    </p>
                </div>
                <div class="bg-gradient-to-br from-pink-50 to-pink-100 rounded-lg p-5">
                    <label class="block text-sm font-bold text-pink-700 mb-3 flex items-center gap-2">
                        <i class="fas fa-hand-holding-usd"></i>
                        طريقة الاشتراك
                    </label>
                    <div>
                        <span class="inline-flex px-4 py-2 rounded-lg text-base font-bold shadow-sm
                            @if($subscription->subscription_method === 'payment_receipt') bg-blue-500 text-white
                            @elseif($subscription->subscription_method === 'subscription_code') bg-purple-500 text-white
                            @elseif($subscription->subscription_method === 'admin_grant') bg-green-500 text-white
                            @else bg-gray-500 text-white
                            @endif">
                            @if($subscription->subscription_method === 'payment_receipt')
                                <i class="fas fa-receipt ml-2"></i>إيصال دفع
                            @elseif($subscription->subscription_method === 'subscription_code')
                                <i class="fas fa-ticket-alt ml-2"></i>كود اشتراك
                            @elseif($subscription->subscription_method === 'admin_grant')
                                <i class="fas fa-gift ml-2"></i>منحة إدارية
                            @else
                                {{ $subscription->subscription_method }}
                            @endif
                        </span>
                    </div>
                </div>
            </div>

            <!-- Course or Package Details -->
            @if($subscription->course)
                <div class="bg-gradient-to-br from-blue-50 to-blue-100 border-2 border-blue-200 rounded-xl p-6 shadow-sm">
                    <h4 class="text-xl font-bold text-blue-900 mb-4 flex items-center gap-2">
                        <i class="fas fa-video"></i>
                        معلومات الدورة
                    </h4>
                    <div class="flex items-start gap-5">
                        @if($subscription->course->thumbnail_url)
                            <img src="{{ Storage::url($subscription->course->thumbnail_url) }}"
                                 class="w-32 h-32 rounded-xl object-cover shadow-md border-2 border-blue-300">
                        @endif
                        <div class="flex-1">
                            <p class="text-xl font-bold text-blue-900 mb-2">{{ $subscription->course->title_ar }}</p>
                            <p class="text-base text-blue-700 mb-3 flex items-center gap-2">
                                <i class="fas fa-chalkboard-teacher"></i>
                                {{ $subscription->course->instructor_name }}
                            </p>
                            <div class="flex items-center gap-5 flex-wrap">
                                <span class="px-3 py-1 bg-white rounded-lg text-sm font-semibold text-blue-700 shadow-sm">
                                    <i class="fas fa-book ml-1"></i>{{ $subscription->course->modules_count }} وحدة
                                </span>
                                <span class="px-3 py-1 bg-white rounded-lg text-sm font-semibold text-blue-700 shadow-sm">
                                    <i class="fas fa-play-circle ml-1"></i>{{ $subscription->course->lessons_count }} درس
                                </span>
                                @if($subscription->course->duration_hours)
                                    <span class="px-3 py-1 bg-white rounded-lg text-sm font-semibold text-blue-700 shadow-sm">
                                        <i class="fas fa-clock ml-1"></i>{{ $subscription->course->duration_hours }} ساعة
                                    </span>
                                @endif
                            </div>
                            <a href="{{ route('admin.courses.show', $subscription->course) }}"
                               class="inline-flex items-center gap-2 mt-4 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-semibold shadow-md transition-all">
                                <i class="fas fa-external-link-alt"></i>
                                <span>عرض تفاصيل الدورة</span>
                            </a>
                        </div>
                    </div>
                </div>
            @elseif($subscription->package)
                <div class="bg-gradient-to-br from-purple-50 to-purple-100 border-2 border-purple-200 rounded-xl p-6 shadow-sm">
                    <h4 class="text-xl font-bold text-purple-900 mb-4 flex items-center gap-2">
                        <i class="fas fa-box"></i>
                        معلومات الباقة: {{ $subscription->package->name_ar }}
                    </h4>
                    <p class="text-base text-purple-700 mb-4">{{ $subscription->package->description_ar }}</p>
                    <div class="space-y-3">
                        <h5 class="text-lg font-bold text-purple-900">الدورات المتضمنة ({{ $subscription->package->courses->count() }}):</h5>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                            @foreach($subscription->package->courses as $course)
                                <div class="flex items-center gap-3 bg-white rounded-lg p-3 shadow-sm border border-purple-200">
                                    <i class="fas fa-check-circle text-green-500 text-lg"></i>
                                    <span class="font-semibold text-purple-900">{{ $course->title_ar }}</span>
                                </div>
                            @endforeach
                        </div>
                    </div>
                    <a href="{{ route('admin.subscriptions.packages.edit', $subscription->package) }}"
                       class="inline-flex items-center gap-2 mt-4 px-4 py-2 bg-purple-600 hover:bg-purple-700 text-white rounded-lg font-semibold shadow-md transition-all">
                        <i class="fas fa-external-link-alt"></i>
                        <span>عرض تفاصيل الباقة</span>
                    </a>
                </div>
            @endif
        </div>
    </div>

    <!-- Timeline Card -->
    <div class="bg-white rounded-xl shadow-md overflow-hidden">
        <div class="bg-gradient-to-r from-orange-50 to-yellow-50 px-6 py-4 border-b-2 border-orange-200">
            <h3 class="text-xl font-bold text-orange-900 flex items-center gap-2">
                <i class="fas fa-calendar-alt"></i>
                الجدول الزمني
            </h3>
        </div>
        <div class="p-6">
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div class="bg-gradient-to-br from-gray-50 to-gray-100 rounded-xl p-5 border-2 border-gray-200">
                    <label class="block text-sm font-bold text-gray-700 mb-3 flex items-center gap-2">
                        <i class="fas fa-calendar-plus"></i>
                        تاريخ الاشتراك
                    </label>
                    <p class="text-2xl font-bold text-gray-900 mb-1">
                        {{ $subscription->created_at->format('Y-m-d') }}
                    </p>
                    <p class="text-sm text-gray-600">{{ $subscription->created_at->diffForHumans() }}</p>
                </div>
                <div class="bg-gradient-to-br from-green-50 to-green-100 rounded-xl p-5 border-2 border-green-200">
                    <label class="block text-sm font-bold text-green-700 mb-3 flex items-center gap-2">
                        <i class="fas fa-play-circle"></i>
                        تاريخ التفعيل
                    </label>
                    <p class="text-2xl font-bold text-green-900 mb-1">
                        {{ $subscription->started_at ? $subscription->started_at->format('Y-m-d') : 'لم يفعل بعد' }}
                    </p>
                    @if($subscription->started_at)
                        <p class="text-sm text-green-600">{{ $subscription->started_at->diffForHumans() }}</p>
                    @endif
                </div>
                <div class="bg-gradient-to-br from-blue-50 to-blue-100 rounded-xl p-5 border-2 border-blue-200">
                    <label class="block text-sm font-bold text-blue-700 mb-3 flex items-center gap-2">
                        <i class="fas fa-calendar-times"></i>
                        تاريخ الانتهاء
                    </label>
                    <p class="text-2xl font-bold text-blue-900 mb-1">
                        {{ $subscription->expires_at ? $subscription->expires_at->format('Y-m-d') : 'دائم' }}
                    </p>
                    @if($subscription->expires_at)
                        <p class="text-sm text-blue-600">{{ $subscription->expires_at->diffForHumans() }}</p>
                    @endif
                </div>
            </div>
        </div>
    </div>

    <!-- Payment Receipt / Code / Grant Information -->
    @if($subscription->subscription_method === 'payment_receipt' && $subscription->receipt)
        <div class="bg-white rounded-xl shadow-md overflow-hidden">
            <div class="bg-gradient-to-r from-blue-50 to-cyan-50 px-6 py-4 border-b-2 border-blue-200">
                <h3 class="text-xl font-bold text-blue-900 flex items-center gap-2">
                    <i class="fas fa-receipt"></i>
                    إيصال الدفع المرتبط
                </h3>
            </div>
            <div class="p-6">
                <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
                    <div class="bg-gradient-to-br from-green-50 to-green-100 rounded-lg p-4">
                        <label class="block text-sm font-bold text-green-700 mb-2">المبلغ</label>
                        <p class="text-2xl font-bold text-green-900">{{ number_format($subscription->receipt->amount_dzd) }} دج</p>
                    </div>
                    <div class="bg-gradient-to-br from-blue-50 to-blue-100 rounded-lg p-4">
                        <label class="block text-sm font-bold text-blue-700 mb-2">تاريخ الإرسال</label>
                        <p class="text-lg font-semibold text-blue-900">{{ $subscription->receipt->submitted_at->format('Y-m-d') }}</p>
                    </div>
                    <div class="bg-gradient-to-br from-purple-50 to-purple-100 rounded-lg p-4">
                        <label class="block text-sm font-bold text-purple-700 mb-2">تاريخ القبول</label>
                        <p class="text-lg font-semibold text-purple-900">{{ $subscription->receipt->reviewed_at?->format('Y-m-d') ?? '-' }}</p>
                    </div>
                    <div class="bg-gradient-to-br from-green-50 to-green-100 rounded-lg p-4">
                        <label class="block text-sm font-bold text-green-700 mb-2">الحالة</label>
                        <span class="inline-block px-3 py-1 text-sm font-bold rounded-full bg-green-500 text-white shadow-sm">
                            <i class="fas fa-check ml-1"></i>مقبول
                        </span>
                    </div>
                </div>
                <a href="{{ route('admin.payment-receipts.show', $subscription->receipt) }}"
                   class="inline-flex items-center gap-2 mt-6 px-5 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-semibold shadow-md transition-all">
                    <i class="fas fa-external-link-alt"></i>
                    <span>عرض تفاصيل الإيصال</span>
                </a>
            </div>
        </div>
    @endif

    @if($subscription->subscription_method === 'subscription_code' && $subscription->code)
        <div class="bg-white rounded-xl shadow-md overflow-hidden">
            <div class="bg-gradient-to-r from-purple-50 to-pink-50 px-6 py-4 border-b-2 border-purple-200">
                <h3 class="text-xl font-bold text-purple-900 flex items-center gap-2">
                    <i class="fas fa-ticket-alt"></i>
                    كود الاشتراك المستخدم
                </h3>
            </div>
            <div class="p-6">
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <div class="bg-gradient-to-br from-purple-50 to-purple-100 rounded-lg p-5">
                        <label class="block text-sm font-bold text-purple-700 mb-2">الكود</label>
                        <p class="text-2xl font-mono font-bold text-purple-900">{{ $subscription->code->code }}</p>
                    </div>
                    <div class="bg-gradient-to-br from-pink-50 to-pink-100 rounded-lg p-5">
                        <label class="block text-sm font-bold text-pink-700 mb-2">نوع الكود</label>
                        <p class="text-lg font-semibold text-pink-900">{{ $subscription->code->code_type }}</p>
                    </div>
                    <div class="bg-gradient-to-br from-indigo-50 to-indigo-100 rounded-lg p-5">
                        <label class="block text-sm font-bold text-indigo-700 mb-2">تاريخ الاستخدام</label>
                        <p class="text-lg font-semibold text-indigo-900">{{ $subscription->created_at->format('Y-m-d') }}</p>
                    </div>
                </div>
            </div>
        </div>
    @endif

    @if($subscription->subscription_method === 'admin_grant')
        <div class="bg-white rounded-xl shadow-md overflow-hidden">
            <div class="bg-gradient-to-r from-green-50 to-teal-50 px-6 py-4 border-b-2 border-green-200">
                <h3 class="text-xl font-bold text-green-900 flex items-center gap-2">
                    <i class="fas fa-gift"></i>
                    منحة إدارية
                </h3>
            </div>
            <div class="p-6">
                <p class="text-lg text-green-700 mb-4">تم منح هذا الاشتراك من قبل الإدارة كهدية أو منحة خاصة</p>
                @if($subscription->admin_notes)
                    <div class="bg-gradient-to-br from-green-50 to-green-100 rounded-lg p-5 border-2 border-green-200">
                        <label class="block text-sm font-bold text-green-800 mb-3">ملاحظات الإدارة:</label>
                        <p class="text-base text-green-900 font-semibold">{{ $subscription->admin_notes }}</p>
                    </div>
                @endif
            </div>
        </div>
    @endif

    <!-- Activity Log -->
    <div class="bg-white rounded-xl shadow-md overflow-hidden">
        <div class="bg-gradient-to-r from-gray-50 to-slate-50 px-6 py-4 border-b-2 border-gray-200">
            <h3 class="text-xl font-bold text-gray-900 flex items-center gap-2">
                <i class="fas fa-history"></i>
                سجل النشاط
            </h3>
        </div>
        <div class="p-6">
            <div class="space-y-4">
                <div class="flex items-start gap-4 p-4 bg-blue-50 rounded-lg border-r-4 border-blue-500">
                    <div class="w-10 h-10 bg-blue-500 rounded-full flex items-center justify-center text-white flex-shrink-0">
                        <i class="fas fa-plus"></i>
                    </div>
                    <div class="flex-1">
                        <p class="font-bold text-blue-900 mb-1">تم إنشاء الاشتراك</p>
                        <p class="text-sm text-blue-700">{{ $subscription->created_at->format('Y-m-d H:i') }}</p>
                        <p class="text-xs text-blue-600 mt-1">{{ $subscription->created_at->diffForHumans() }}</p>
                    </div>
                </div>
                @if($subscription->started_at)
                    <div class="flex items-start gap-4 p-4 bg-green-50 rounded-lg border-r-4 border-green-500">
                        <div class="w-10 h-10 bg-green-500 rounded-full flex items-center justify-center text-white flex-shrink-0">
                            <i class="fas fa-check"></i>
                        </div>
                        <div class="flex-1">
                            <p class="font-bold text-green-900 mb-1">تم تفعيل الاشتراك</p>
                            <p class="text-sm text-green-700">{{ $subscription->started_at->format('Y-m-d H:i') }}</p>
                            <p class="text-xs text-green-600 mt-1">{{ $subscription->started_at->diffForHumans() }}</p>
                        </div>
                    </div>
                @endif
                @if($subscription->status === 'expired')
                    <div class="flex items-start gap-4 p-4 bg-red-50 rounded-lg border-r-4 border-red-500">
                        <div class="w-10 h-10 bg-red-500 rounded-full flex items-center justify-center text-white flex-shrink-0">
                            <i class="fas fa-times"></i>
                        </div>
                        <div class="flex-1">
                            <p class="font-bold text-red-900 mb-1">انتهى الاشتراك</p>
                            <p class="text-sm text-red-700">{{ $subscription->expires_at->format('Y-m-d H:i') }}</p>
                            <p class="text-xs text-red-600 mt-1">{{ $subscription->expires_at->diffForHumans() }}</p>
                        </div>
                    </div>
                @endif
            </div>
        </div>
    </div>
</div>

<!-- Enhanced Extend Subscription Modal -->
<div id="extendModal" class="hidden fixed inset-0 bg-black bg-opacity-60 backdrop-blur-sm z-50 flex items-center justify-center p-4" style="font-family: 'Cairo', sans-serif; direction: rtl;">
    <div class="bg-white rounded-2xl shadow-2xl max-w-md w-full overflow-hidden">
        <!-- Modal Header -->
        <div class="bg-gradient-to-r from-cyan-600 to-blue-600 px-6 py-5">
            <div class="flex justify-between items-center">
                <div class="flex items-center gap-3 text-white">
                    <div class="w-12 h-12 bg-white bg-opacity-20 rounded-xl flex items-center justify-center">
                        <i class="fas fa-calendar-plus text-xl"></i>
                    </div>
                    <h3 class="text-xl font-bold">تمديد الاشتراك</h3>
                </div>
                <button onclick="hideExtendModal()" class="text-white hover:bg-white hover:bg-opacity-20 w-10 h-10 rounded-lg transition-all">
                    <i class="fas fa-times text-xl"></i>
                </button>
            </div>
        </div>

        <!-- Modal Body -->
        <form action="{{ route('admin.subscriptions.extend', $subscription) }}" method="POST" class="p-6">
            @csrf
            @method('PUT')
            <div class="mb-6">
                <label class="block text-sm font-bold text-gray-700 mb-3 flex items-center gap-2">
                    <i class="fas fa-calendar-week text-cyan-600"></i>
                    عدد الأيام الإضافية <span class="text-red-500">*</span>
                </label>
                <input type="number" name="days" value="30" min="1" required
                       class="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:ring-2 focus:ring-cyan-500 focus:border-cyan-500 transition-all text-lg font-semibold"
                       placeholder="30">
                <p class="text-xs text-gray-500 mt-2">أدخل عدد الأيام التي تريد إضافتها إلى الاشتراك</p>
            </div>
            <div class="mb-6">
                <label class="block text-sm font-bold text-gray-700 mb-3 flex items-center gap-2">
                    <i class="fas fa-sticky-note text-cyan-600"></i>
                    ملاحظات (اختياري)
                </label>
                <textarea name="notes" rows="4"
                          class="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:ring-2 focus:ring-cyan-500 focus:border-cyan-500 transition-all"
                          placeholder="سبب التمديد أو ملاحظات إضافية..."></textarea>
            </div>
            <div class="flex gap-3">
                <button type="button" onclick="hideExtendModal()"
                        class="flex-1 px-5 py-3 border-2 border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 font-semibold transition-all">
                    <i class="fas fa-times ml-2"></i>إلغاء
                </button>
                <button type="submit"
                        class="flex-1 px-5 py-3 bg-gradient-to-r from-cyan-600 to-blue-600 hover:from-cyan-700 hover:to-blue-700 text-white rounded-lg font-bold shadow-md transition-all">
                    <i class="fas fa-check ml-2"></i>تأكيد التمديد
                </button>
            </div>
        </form>
    </div>
</div>

<script>
function showExtendModal() {
    document.getElementById('extendModal').classList.remove('hidden');
}
function hideExtendModal() {
    document.getElementById('extendModal').classList.add('hidden');
}
// Close modal on ESC key
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        hideExtendModal();
    }
});
// Close modal on background click
document.getElementById('extendModal')?.addEventListener('click', function(e) {
    if (e.target === this) {
        hideExtendModal();
    }
});
</script>
@endsection
