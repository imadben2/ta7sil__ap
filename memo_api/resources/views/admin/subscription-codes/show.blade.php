@extends('layouts.admin')

@section('title', 'تفاصيل الكود')
@section('page-title', 'تفاصيل كود الاشتراك')

@section('content')
<div class="space-y-6" style="font-family: 'Cairo', sans-serif; direction: rtl;">
    <!-- Success/Error Messages -->
    @if (session('success') || session('error'))
    <div class="{{ session('success') ? 'bg-green-100 border-green-500 text-green-700' : 'bg-red-100 border-red-500 text-red-700' }} border-r-4 p-4 rounded-lg shadow-sm">
        <div class="flex items-center">
            <i class="fas {{ session('success') ? 'fa-check-circle' : 'fa-exclamation-circle' }} mr-3 text-lg"></i>
            <p>{{ session('success') ?? session('error') }}</p>
        </div>
    </div>
    @endif

    <!-- Header with Gradient -->
    <div class="bg-gradient-to-r from-purple-600 to-pink-600 rounded-xl shadow-lg p-6">
        <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
            <div class="text-white">
                <h2 class="text-2xl font-bold mb-2">تفاصيل الكود</h2>
                <p class="text-purple-100">عرض المعلومات الكاملة لكود الاشتراك وإحصائيات الاستخدام</p>
            </div>
            <div class="flex gap-2">
                <a href="{{ route('admin.subscription-codes.index') }}"
                   class="bg-white text-purple-600 hover:bg-purple-50 px-6 py-3 rounded-lg flex items-center gap-2 transition-all shadow-md hover:shadow-lg font-semibold">
                    <i class="fas fa-arrow-right"></i>
                    <span>رجوع</span>
                </a>
            </div>
        </div>
    </div>

    <!-- Code Details Card -->
    <div class="bg-white rounded-lg shadow-md p-6">
        <div class="flex items-center justify-between mb-6 pb-4 border-b">
            <h3 class="text-xl font-bold text-gray-900">
                <i class="fas fa-ticket-alt text-purple-600 mr-2"></i>
                معلومات الكود
            </h3>
            <div class="flex gap-2">
                @if($code->is_active)
                <span class="px-4 py-2 bg-green-100 text-green-700 rounded-lg font-semibold">
                    <i class="fas fa-check-circle mr-1"></i>
                    نشط
                </span>
                @else
                <span class="px-4 py-2 bg-red-100 text-red-700 rounded-lg font-semibold">
                    <i class="fas fa-times-circle mr-1"></i>
                    معطل
                </span>
                @endif
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Code Display -->
            <div class="col-span-full">
                <div class="bg-gradient-to-r from-purple-50 to-pink-50 rounded-lg p-6 border-2 border-purple-200">
                    <p class="text-sm text-gray-600 mb-2">الكود</p>
                    <p class="text-3xl font-mono font-bold text-purple-700">{{ $code->code }}</p>
                </div>
            </div>

            <!-- Code Type -->
            <div>
                <p class="text-sm text-gray-600 mb-2">
                    <i class="fas fa-tag text-gray-400 mr-1"></i>
                    نوع الكود
                </p>
                <p class="text-lg font-semibold text-gray-900">
                    @switch($code->code_type)
                        @case('single_course')
                            <span class="px-3 py-1 bg-blue-100 text-blue-700 rounded-lg">دورة واحدة</span>
                            @break
                        @case('package')
                            <span class="px-3 py-1 bg-purple-100 text-purple-700 rounded-lg">باقة</span>
                            @break
                        @case('general')
                            <span class="px-3 py-1 bg-green-100 text-green-700 rounded-lg">عام</span>
                            @break
                        @default
                            <span class="px-3 py-1 bg-gray-100 text-gray-700 rounded-lg">غير محدد</span>
                    @endswitch
                </p>
            </div>

            <!-- Course/Package -->
            <div>
                <p class="text-sm text-gray-600 mb-2">
                    <i class="fas fa-book text-gray-400 mr-1"></i>
                    @if($code->code_type === 'single_course')
                        الدورة
                    @elseif($code->code_type === 'package')
                        الباقة
                    @else
                        العنصر
                    @endif
                </p>
                <p class="text-lg font-semibold text-gray-900">
                    @if($code->course)
                        {{ $code->course->title_ar }}
                    @elseif($code->package)
                        {{ $code->package->name_ar }}
                    @else
                        <span class="text-gray-400">لا يوجد</span>
                    @endif
                </p>
            </div>

            <!-- Max Uses -->
            <div>
                <p class="text-sm text-gray-600 mb-2">
                    <i class="fas fa-infinity text-gray-400 mr-1"></i>
                    الحد الأقصى للاستخدام
                </p>
                <p class="text-lg font-semibold text-gray-900">
                    @if($code->max_uses === 999999)
                        <span class="text-blue-600">غير محدود</span>
                    @else
                        {{ $code->max_uses }} مرات
                    @endif
                </p>
            </div>

            <!-- Current Uses -->
            <div>
                <p class="text-sm text-gray-600 mb-2">
                    <i class="fas fa-chart-line text-gray-400 mr-1"></i>
                    عدد مرات الاستخدام
                </p>
                <p class="text-lg font-semibold text-gray-900">
                    {{ $code->current_uses }} مرة
                </p>
            </div>

            <!-- Remaining Uses -->
            <div>
                <p class="text-sm text-gray-600 mb-2">
                    <i class="fas fa-battery-half text-gray-400 mr-1"></i>
                    الاستخدامات المتبقية
                </p>
                <p class="text-lg font-semibold text-gray-900">
                    @if($code->max_uses === 999999)
                        <span class="text-blue-600">غير محدود</span>
                    @else
                        {{ $code->getRemainingUses() }} مرة
                    @endif
                </p>
            </div>

            <!-- Expires At -->
            <div>
                <p class="text-sm text-gray-600 mb-2">
                    <i class="fas fa-calendar-times text-gray-400 mr-1"></i>
                    تاريخ الانتهاء
                </p>
                <p class="text-lg font-semibold text-gray-900">
                    @if($code->expires_at)
                        {{ $code->expires_at->format('Y-m-d H:i') }}
                        @if($code->expires_at->isPast())
                            <span class="text-red-600 text-sm">(منتهي)</span>
                        @endif
                    @else
                        <span class="text-blue-600">لا ينتهي</span>
                    @endif
                </p>
            </div>

            <!-- Creator -->
            <div>
                <p class="text-sm text-gray-600 mb-2">
                    <i class="fas fa-user text-gray-400 mr-1"></i>
                    المنشئ
                </p>
                <p class="text-lg font-semibold text-gray-900">
                    @if($code->creator)
                        {{ $code->creator->full_name }}
                    @else
                        <span class="text-gray-400">غير معروف</span>
                    @endif
                </p>
            </div>

            <!-- Created At -->
            <div>
                <p class="text-sm text-gray-600 mb-2">
                    <i class="fas fa-clock text-gray-400 mr-1"></i>
                    تاريخ الإنشاء
                </p>
                <p class="text-lg font-semibold text-gray-900">
                    {{ $code->created_at->format('Y-m-d H:i') }}
                </p>
            </div>

            <!-- List Reference -->
            @if($code->list_id)
            <div>
                <p class="text-sm text-gray-600 mb-2">
                    <i class="fas fa-list text-gray-400 mr-1"></i>
                    القائمة
                </p>
                <p class="text-lg font-semibold text-gray-900">
                    @if($code->list)
                        <a href="{{ route('admin.subscription-code-lists.show', $code->list) }}"
                           class="text-purple-600 hover:text-purple-800 underline">
                            {{ $code->list->name }}
                        </a>
                    @else
                        <span class="text-gray-400">غير معروف</span>
                    @endif
                </p>
            </div>
            @endif
        </div>
    </div>

    <!-- Statistics Card -->
    @if(isset($stats))
    <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-xl font-bold text-gray-900 mb-6 pb-4 border-b">
            <i class="fas fa-chart-bar text-purple-600 mr-2"></i>
            إحصائيات الاستخدام
        </h3>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <!-- Total Uses -->
            <div class="bg-gradient-to-br from-blue-50 to-blue-100 rounded-lg p-6">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-sm text-blue-700 mb-2">إجمالي الاستخدام</p>
                        <p class="text-3xl font-bold text-blue-800">{{ $stats['total_uses'] ?? 0 }}</p>
                    </div>
                    <div class="w-14 h-14 bg-blue-200 rounded-lg flex items-center justify-center">
                        <i class="fas fa-users text-blue-700 text-2xl"></i>
                    </div>
                </div>
            </div>

            <!-- Success Rate -->
            <div class="bg-gradient-to-br from-green-50 to-green-100 rounded-lg p-6">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-sm text-green-700 mb-2">نسبة النجاح</p>
                        <p class="text-3xl font-bold text-green-800">{{ $stats['success_rate'] ?? '0%' }}</p>
                    </div>
                    <div class="w-14 h-14 bg-green-200 rounded-lg flex items-center justify-center">
                        <i class="fas fa-check-circle text-green-700 text-2xl"></i>
                    </div>
                </div>
            </div>

            <!-- Remaining Capacity -->
            <div class="bg-gradient-to-br from-orange-50 to-orange-100 rounded-lg p-6">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-sm text-orange-700 mb-2">السعة المتبقية</p>
                        <p class="text-3xl font-bold text-orange-800">{{ $stats['remaining_capacity'] ?? 'غير محدود' }}</p>
                    </div>
                    <div class="w-14 h-14 bg-orange-200 rounded-lg flex items-center justify-center">
                        <i class="fas fa-battery-three-quarters text-orange-700 text-2xl"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
    @endif

    <!-- Students Who Used This Code -->
    @if($code->userSubscriptions && $code->userSubscriptions->count() > 0)
    <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-xl font-bold text-gray-900 mb-6 pb-4 border-b">
            <i class="fas fa-users text-purple-600 mr-2"></i>
            الطلاب الذين استخدموا هذا الكود
            <span class="text-sm font-normal text-gray-600">({{ $code->userSubscriptions->count() }} طالب)</span>
        </h3>

        <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                            الطالب
                        </th>
                        <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                            البريد الإلكتروني
                        </th>
                        <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                            الدورة
                        </th>
                        <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                            تاريخ التفعيل
                        </th>
                        <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                            تاريخ الانتهاء
                        </th>
                        <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                            الحالة
                        </th>
                        <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                            الإجراءات
                        </th>
                    </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                    @foreach($code->userSubscriptions as $subscription)
                    <tr class="hover:bg-gray-50 transition-colors">
                        <td class="px-6 py-4 whitespace-nowrap">
                            <div class="flex items-center">
                                <div class="flex-shrink-0 h-10 w-10 bg-purple-100 rounded-full flex items-center justify-center">
                                    <i class="fas fa-user text-purple-600"></i>
                                </div>
                                <div class="mr-4">
                                    <div class="text-sm font-medium text-gray-900">
                                        {{ $subscription->user->full_name ?? 'غير معروف' }}
                                    </div>
                                    <div class="text-sm text-gray-500">
                                        #{{ $subscription->user_id }}
                                    </div>
                                </div>
                            </div>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <div class="text-sm text-gray-900">{{ $subscription->user->email ?? 'N/A' }}</div>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <div class="text-sm text-gray-900">
                                {{ $subscription->course->title_ar ?? 'N/A' }}
                            </div>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <div class="text-sm text-gray-900">
                                {{ $subscription->activated_at ? $subscription->activated_at->format('Y-m-d H:i') : 'N/A' }}
                            </div>
                            <div class="text-xs text-gray-500">
                                {{ $subscription->activated_at ? $subscription->activated_at->diffForHumans() : '' }}
                            </div>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <div class="text-sm text-gray-900">
                                {{ $subscription->expires_at ? $subscription->expires_at->format('Y-m-d') : 'دائم' }}
                            </div>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            @if($subscription->is_active && (!$subscription->expires_at || !$subscription->expires_at->isPast()))
                                <span class="px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                                    <i class="fas fa-check-circle mr-1"></i>
                                    نشط
                                </span>
                            @elseif($subscription->expires_at && $subscription->expires_at->isPast())
                                <span class="px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">
                                    <i class="fas fa-times-circle mr-1"></i>
                                    منتهي
                                </span>
                            @else
                                <span class="px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-100 text-gray-800">
                                    <i class="fas fa-pause-circle mr-1"></i>
                                    معطل
                                </span>
                            @endif
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm">
                            <a href="{{ route('admin.users.show', $subscription->user_id) }}"
                               class="text-purple-600 hover:text-purple-900 font-semibold"
                               title="عرض ملف الطالب">
                                <i class="fas fa-eye"></i>
                                عرض
                            </a>
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
    @else
    <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-xl font-bold text-gray-900 mb-6 pb-4 border-b">
            <i class="fas fa-users text-purple-600 mr-2"></i>
            الطلاب الذين استخدموا هذا الكود
        </h3>
        <div class="text-center py-12">
            <div class="inline-flex items-center justify-center w-16 h-16 bg-gray-100 rounded-full mb-4">
                <i class="fas fa-inbox text-gray-400 text-2xl"></i>
            </div>
            <p class="text-gray-500 text-lg">لم يتم استخدام هذا الكود بعد</p>
            <p class="text-gray-400 text-sm mt-2">سيظهر هنا قائمة الطلاب عند استخدام الكود</p>
        </div>
    </div>
    @endif

    <!-- Actions Card -->
    <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-xl font-bold text-gray-900 mb-6 pb-4 border-b">
            <i class="fas fa-cogs text-purple-600 mr-2"></i>
            الإجراءات
        </h3>

        <div class="flex flex-wrap gap-3">
            @if($code->is_active)
            <form action="{{ route('admin.subscription-codes.deactivate', $code) }}" method="POST" class="inline">
                @csrf
                <button type="submit"
                        onclick="return confirm('هل أنت متأكد من تعطيل هذا الكود؟')"
                        class="px-6 py-3 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors font-semibold">
                    <i class="fas fa-ban mr-2"></i>
                    تعطيل الكود
                </button>
            </form>
            @else
            <form action="{{ route('admin.subscription-codes.activate', $code) }}" method="POST" class="inline">
                @csrf
                <button type="submit"
                        class="px-6 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors font-semibold">
                    <i class="fas fa-check-circle mr-2"></i>
                    تفعيل الكود
                </button>
            </form>
            @endif

            <button onclick="copyCode()"
                    class="px-6 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors font-semibold">
                <i class="fas fa-copy mr-2"></i>
                نسخ الكود
            </button>

            <a href="{{ route('admin.subscription-codes.index') }}"
               class="px-6 py-3 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors font-semibold">
                <i class="fas fa-arrow-right mr-2"></i>
                العودة للقائمة
            </a>
        </div>
    </div>
</div>

@push('scripts')
<script>
function copyCode() {
    const code = "{{ $code->code }}";
    navigator.clipboard.writeText(code).then(() => {
        // Show success message
        const alertDiv = document.createElement('div');
        alertDiv.className = 'fixed top-4 left-1/2 transform -translate-x-1/2 bg-green-100 border-green-500 text-green-700 border-r-4 p-4 rounded-lg shadow-lg z-50';
        alertDiv.innerHTML = '<div class="flex items-center"><i class="fas fa-check-circle mr-3 text-lg"></i><p>تم نسخ الكود بنجاح!</p></div>';
        document.body.appendChild(alertDiv);

        setTimeout(() => {
            alertDiv.remove();
        }, 3000);
    }).catch(err => {
        alert('فشل نسخ الكود');
        console.error('Failed to copy:', err);
    });
}

// Auto-hide success/error messages
setTimeout(function() {
    const alerts = document.querySelectorAll('.border-r-4');
    alerts.forEach(alert => {
        alert.style.transition = 'opacity 0.5s';
        alert.style.opacity = '0';
        setTimeout(() => alert.remove(), 500);
    });
}, 5000);
</script>
@endpush
@endsection
