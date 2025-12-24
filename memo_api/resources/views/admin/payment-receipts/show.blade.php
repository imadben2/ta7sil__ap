@extends('layouts.admin')

@section('title', 'تفاصيل إيصال الدفع')
@section('page-title', 'تفاصيل إيصال الدفع #' . $receipt->id)

@section('content')
<div class="max-w-5xl mx-auto space-y-6">
    <!-- Header Actions -->
    <div class="flex justify-between items-center">
        <a href="{{ route('admin.payment-receipts.index') }}"
           class="text-blue-600 hover:text-blue-800 flex items-center gap-2">
            <i class="fas fa-arrow-right"></i>
            <span>العودة إلى القائمة</span>
        </a>

        <div class="flex gap-2">
            @if($receipt->status === 'pending')
                <form action="{{ route('admin.payment-receipts.approve', $receipt) }}" method="POST" class="inline">
                    @csrf
                    <button type="submit"
                            class="px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg flex items-center gap-2">
                        <i class="fas fa-check-circle"></i>
                        <span>قبول الإيصال</span>
                    </button>
                </form>
                <button onclick="showRejectModal()"
                        class="px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded-lg flex items-center gap-2">
                    <i class="fas fa-times-circle"></i>
                    <span>رفض الإيصال</span>
                </button>
            @endif
            <a href="{{ route('admin.payment-receipts.download', $receipt) }}" target="_blank"
               class="px-4 py-2 bg-purple-600 hover:bg-purple-700 text-white rounded-lg flex items-center gap-2">
                <i class="fas fa-download"></i>
                <span>تحميل الإيصال</span>
            </a>
        </div>
    </div>

    <!-- Receipt Details -->
    <div class="bg-white rounded-lg shadow-sm overflow-hidden">
        <!-- Status Banner -->
        <div class="px-6 py-4 border-b
            @if($receipt->status === 'pending') bg-yellow-50 border-yellow-200
            @elseif($receipt->status === 'approved') bg-green-50 border-green-200
            @else bg-red-50 border-red-200
            @endif">
            <div class="flex items-center justify-between">
                <div>
                    <h3 class="text-lg font-semibold
                        @if($receipt->status === 'pending') text-yellow-800
                        @elseif($receipt->status === 'approved') text-green-800
                        @else text-red-800
                        @endif">
                        @if($receipt->status === 'pending')
                            إيصال معلق - بانتظار المراجعة
                        @elseif($receipt->status === 'approved')
                            إيصال مقبول - تم التفعيل بنجاح
                        @else
                            إيصال مرفوض
                        @endif
                    </h3>
                    <p class="text-sm mt-1
                        @if($receipt->status === 'pending') text-yellow-700
                        @elseif($receipt->status === 'approved') text-green-700
                        @else text-red-700
                        @endif">
                        @if($receipt->status === 'approved')
                            تاريخ القبول: {{ $receipt->reviewed_at?->format('Y-m-d H:i') }}
                        @elseif($receipt->status === 'rejected')
                            تاريخ الرفض: {{ $receipt->reviewed_at?->format('Y-m-d H:i') }}
                        @else
                            تاريخ الإرسال: {{ $receipt->submitted_at->format('Y-m-d H:i') }}
                        @endif
                    </p>
                </div>
                <div>
                    @if($receipt->status === 'pending')
                        <span class="px-4 py-2 text-sm font-semibold rounded-full bg-yellow-100 text-yellow-800">
                            معلق
                        </span>
                    @elseif($receipt->status === 'approved')
                        <span class="px-4 py-2 text-sm font-semibold rounded-full bg-green-100 text-green-800">
                            مقبول
                        </span>
                    @else
                        <span class="px-4 py-2 text-sm font-semibold rounded-full bg-red-100 text-red-800">
                            مرفوض
                        </span>
                    @endif
                </div>
            </div>
        </div>

        <!-- Main Content -->
        <div class="p-6 space-y-6">
            <!-- Student Information -->
            <div>
                <h3 class="text-lg font-semibold text-gray-900 mb-4 border-b pb-2">معلومات الطالب</h3>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-500">الاسم الكامل</label>
                        <p class="mt-1 text-gray-900 font-semibold">{{ $receipt->user->full_name_ar }}</p>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-500">البريد الإلكتروني</label>
                        <p class="mt-1 text-gray-900">{{ $receipt->user->email }}</p>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-500">رقم الهاتف</label>
                        <p class="mt-1 text-gray-900">{{ $receipt->user->phone ?? 'غير متوفر' }}</p>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-500">رقم الطالب</label>
                        <p class="mt-1 text-gray-900 font-mono">#{{ $receipt->user->id }}</p>
                    </div>
                </div>
            </div>

            <!-- Course/Package Information -->
            <div>
                <h3 class="text-lg font-semibold text-gray-900 mb-4 border-b pb-2">تفاصيل الاشتراك</h3>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-500">نوع الاشتراك</label>
                        <p class="mt-1 text-gray-900 font-semibold">
                            @if($receipt->course)
                                <i class="fas fa-video text-blue-600 ml-2"></i>دورة واحدة
                            @else
                                <i class="fas fa-box text-purple-600 ml-2"></i>باقة اشتراك
                            @endif
                        </p>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-500">
                            {{ $receipt->course ? 'الدورة' : 'الباقة' }}
                        </label>
                        <p class="mt-1 text-gray-900 font-semibold">
                            {{ $receipt->course ? $receipt->course->title_ar : $receipt->package->name_ar }}
                        </p>
                    </div>
                    @if($receipt->package)
                        <div class="md:col-span-2">
                            <label class="block text-sm font-medium text-gray-500">الدورات المتضمنة في الباقة</label>
                            <div class="mt-2 flex flex-wrap gap-2">
                                @foreach($receipt->package->courses as $course)
                                    <span class="px-3 py-1 bg-blue-100 text-blue-800 text-sm rounded-full">
                                        {{ $course->title_ar }}
                                    </span>
                                @endforeach
                            </div>
                        </div>
                    @endif
                </div>
            </div>

            <!-- Payment Information -->
            <div>
                <h3 class="text-lg font-semibold text-gray-900 mb-4 border-b pb-2">معلومات الدفع</h3>
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div class="bg-blue-50 rounded-lg p-4">
                        <label class="block text-sm font-medium text-blue-700">المبلغ المدفوع</label>
                        <p class="mt-1 text-2xl font-bold text-blue-900">{{ number_format($receipt->amount_dzd) }} دج</p>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-500">طريقة الدفع</label>
                        <p class="mt-1 text-gray-900">{{ $receipt->payment_method ?? 'تحويل بنكي' }}</p>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-500">تاريخ الإرسال</label>
                        <p class="mt-1 text-gray-900">{{ $receipt->submitted_at->format('Y-m-d H:i') }}</p>
                    </div>
                </div>
            </div>

            <!-- Receipt Image -->
            <div>
                <h3 class="text-lg font-semibold text-gray-900 mb-4 border-b pb-2">صورة الإيصال</h3>
                <div class="bg-gray-50 rounded-lg p-4 flex justify-center">
                    @if($receipt->receipt_image_url)
                        <img src="{{ Storage::url($receipt->receipt_image_url) }}"
                             alt="Receipt"
                             class="max-w-full max-h-96 rounded-lg shadow-md cursor-pointer hover:shadow-xl transition-shadow"
                             onclick="window.open(this.src, '_blank')">
                    @else
                        <div class="text-center text-gray-500 py-12">
                            <i class="fas fa-file-image text-6xl mb-4"></i>
                            <p>لا توجد صورة للإيصال</p>
                        </div>
                    @endif
                </div>
                <p class="text-sm text-gray-500 text-center mt-2">
                    <i class="fas fa-info-circle ml-1"></i>
                    انقر على الصورة لعرضها بالحجم الكامل
                </p>
            </div>

            <!-- Notes -->
            @if($receipt->notes)
                <div>
                    <h3 class="text-lg font-semibold text-gray-900 mb-4 border-b pb-2">ملاحظات الطالب</h3>
                    <div class="bg-gray-50 rounded-lg p-4">
                        <p class="text-gray-700">{{ $receipt->notes }}</p>
                    </div>
                </div>
            @endif

            <!-- Admin Notes/Rejection Reason -->
            @if($receipt->rejection_reason)
                <div>
                    <h3 class="text-lg font-semibold text-gray-900 mb-4 border-b pb-2">سبب الرفض</h3>
                    <div class="bg-red-50 border border-red-200 rounded-lg p-4">
                        <p class="text-red-800">{{ $receipt->rejection_reason }}</p>
                        @if($receipt->reviewed_by)
                            <p class="text-sm text-red-600 mt-2">
                                راجعه: {{ $receipt->reviewer->full_name_ar ?? 'مسؤول النظام' }}
                            </p>
                        @endif
                    </div>
                </div>
            @endif

            <!-- Review Information -->
            @if($receipt->status !== 'pending')
                <div>
                    <h3 class="text-lg font-semibold text-gray-900 mb-4 border-b pb-2">معلومات المراجعة</h3>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-medium text-gray-500">تمت المراجعة بواسطة</label>
                            <p class="mt-1 text-gray-900">{{ $receipt->reviewer->full_name_ar ?? 'مسؤول النظام' }}</p>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-500">تاريخ المراجعة</label>
                            <p class="mt-1 text-gray-900">{{ $receipt->reviewed_at?->format('Y-m-d H:i') }}</p>
                        </div>
                    </div>
                </div>
            @endif

            <!-- Related Subscription -->
            @if($receipt->status === 'approved' && $receipt->subscription)
                <div class="bg-green-50 border border-green-200 rounded-lg p-4">
                    <h3 class="text-lg font-semibold text-green-900 mb-3">
                        <i class="fas fa-check-circle ml-2"></i>
                        تم تفعيل الاشتراك بنجاح
                    </h3>
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                        <div>
                            <label class="block text-sm font-medium text-green-700">تاريخ البدء</label>
                            <p class="mt-1 text-green-900 font-semibold">{{ $receipt->subscription->started_at?->format('Y-m-d') }}</p>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-green-700">تاريخ الانتهاء</label>
                            <p class="mt-1 text-green-900 font-semibold">
                                {{ $receipt->subscription->expires_at?->format('Y-m-d') ?? 'دائم' }}
                            </p>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-green-700">الحالة</label>
                            <p class="mt-1">
                                <span class="px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">
                                    {{ $receipt->subscription->status }}
                                </span>
                            </p>
                        </div>
                    </div>
                    <a href="{{ route('admin.subscriptions.show', $receipt->subscription) }}"
                       class="inline-flex items-center gap-2 mt-4 text-green-700 hover:text-green-900">
                        <i class="fas fa-external-link-alt"></i>
                        <span>عرض تفاصيل الاشتراك</span>
                    </a>
                </div>
            @endif
        </div>
    </div>
</div>

<!-- Reject Modal -->
@if($receipt->status === 'pending')
<div id="rejectModal" class="hidden fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center p-4">
    <div class="bg-white rounded-lg shadow-xl max-w-md w-full p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">رفض إيصال الدفع</h3>
        <form action="{{ route('admin.payment-receipts.reject', $receipt) }}" method="POST">
            @csrf
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 mb-2">سبب الرفض *</label>
                <textarea name="rejection_reason" rows="4" required
                          class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500"
                          placeholder="اشرح للطالب سبب رفض الإيصال..."></textarea>
            </div>
            <div class="flex justify-end gap-3">
                <button type="button" onclick="hideRejectModal()"
                        class="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50">
                    إلغاء
                </button>
                <button type="submit"
                        class="px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded-lg">
                    تأكيد الرفض
                </button>
            </div>
        </form>
    </div>
</div>

<script>
function showRejectModal() {
    document.getElementById('rejectModal').classList.remove('hidden');
}
function hideRejectModal() {
    document.getElementById('rejectModal').classList.add('hidden');
}
</script>
@endif
@endsection
