@extends('layouts.admin')

@section('title', 'عرض الراعي')
@section('page-title', 'عرض الراعي')
@section('page-description', 'تفاصيل الراعي "{{ $sponsor->name_ar }}"')

@section('content')
<div class="max-w-4xl mx-auto space-y-6">
    <!-- Header Card -->
    <div class="bg-gradient-to-l from-purple-600 to-purple-800 rounded-2xl shadow-xl text-white p-8">
        <div class="flex items-center gap-3 mb-6">
            <a href="{{ route('admin.sponsors.index') }}"
               class="w-10 h-10 rounded-xl bg-white/20 hover:bg-white/30 flex items-center justify-center transition-colors">
                <i class="fas fa-arrow-right"></i>
            </a>
            <span class="text-purple-200">العودة للقائمة</span>
        </div>

        <div class="flex flex-col md:flex-row items-center gap-8">
            <!-- Photo -->
            <div class="flex-shrink-0">
                <img src="{{ $sponsor->photo_url }}"
                     alt="{{ $sponsor->name_ar }}"
                     class="w-32 h-32 rounded-full object-cover border-4 border-white shadow-xl">
            </div>

            <!-- Info -->
            <div class="flex-1 text-center md:text-right">
                <h2 class="text-3xl font-bold mb-2">{{ $sponsor->name_ar }}</h2>
                @if($sponsor->title)
                    <p class="text-purple-200 text-lg mb-2">{{ $sponsor->title }}</p>
                @endif
                @if($sponsor->specialty)
                    <span class="inline-block px-4 py-1.5 bg-white/20 rounded-full text-sm">
                        {{ $sponsor->specialty }}
                    </span>
                @endif
            </div>

            <!-- Status -->
            <div class="flex-shrink-0">
                @if($sponsor->is_active)
                    <span class="inline-flex items-center gap-2 px-4 py-2 bg-green-500 rounded-xl text-sm font-medium">
                        <i class="fas fa-check-circle"></i>
                        نشط
                    </span>
                @else
                    <span class="inline-flex items-center gap-2 px-4 py-2 bg-red-500 rounded-xl text-sm font-medium">
                        <i class="fas fa-times-circle"></i>
                        معطل
                    </span>
                @endif
            </div>
        </div>
    </div>

    <!-- Click Statistics -->
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100">
        <div class="p-6 border-b border-gray-100">
            <h3 class="text-lg font-bold text-gray-900 flex items-center gap-2">
                <i class="fas fa-chart-bar text-purple-600"></i>
                إحصائيات النقرات
            </h3>
        </div>
        <div class="p-6">
            <div class="grid grid-cols-2 md:grid-cols-5 gap-4">
                <!-- Total Clicks -->
                <div class="bg-gradient-to-br from-purple-50 to-purple-100 rounded-2xl p-4 border border-purple-200">
                    <div class="flex items-center gap-2 mb-2">
                        <i class="fas fa-mouse-pointer text-purple-600"></i>
                        <span class="text-xs font-medium text-purple-600">إجمالي</span>
                    </div>
                    <p class="text-2xl font-bold text-purple-700">{{ number_format($sponsor->click_count) }}</p>
                </div>

                <!-- YouTube Clicks -->
                <div class="bg-gradient-to-br from-red-50 to-red-100 rounded-2xl p-4 border border-red-200">
                    <div class="flex items-center gap-2 mb-2">
                        <i class="fab fa-youtube text-red-500"></i>
                        <span class="text-xs font-medium text-red-600">YouTube</span>
                    </div>
                    <p class="text-2xl font-bold text-red-700">{{ number_format($sponsor->youtube_clicks ?? 0) }}</p>
                </div>

                <!-- Facebook Clicks -->
                <div class="bg-gradient-to-br from-blue-50 to-blue-100 rounded-2xl p-4 border border-blue-200">
                    <div class="flex items-center gap-2 mb-2">
                        <i class="fab fa-facebook text-blue-600"></i>
                        <span class="text-xs font-medium text-blue-600">Facebook</span>
                    </div>
                    <p class="text-2xl font-bold text-blue-700">{{ number_format($sponsor->facebook_clicks ?? 0) }}</p>
                </div>

                <!-- Instagram Clicks -->
                <div class="bg-gradient-to-br from-pink-50 to-pink-100 rounded-2xl p-4 border border-pink-200">
                    <div class="flex items-center gap-2 mb-2">
                        <i class="fab fa-instagram text-pink-500"></i>
                        <span class="text-xs font-medium text-pink-600">Instagram</span>
                    </div>
                    <p class="text-2xl font-bold text-pink-700">{{ number_format($sponsor->instagram_clicks ?? 0) }}</p>
                </div>

                <!-- Telegram Clicks -->
                <div class="bg-gradient-to-br from-cyan-50 to-cyan-100 rounded-2xl p-4 border border-cyan-200">
                    <div class="flex items-center gap-2 mb-2">
                        <i class="fab fa-telegram text-cyan-500"></i>
                        <span class="text-xs font-medium text-cyan-600">Telegram</span>
                    </div>
                    <p class="text-2xl font-bold text-cyan-700">{{ number_format($sponsor->telegram_clicks ?? 0) }}</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Info Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm text-gray-500 mb-1">ترتيب العرض</p>
                    <p class="text-3xl font-bold text-blue-600">{{ $sponsor->display_order }}</p>
                </div>
                <div class="w-14 h-14 rounded-2xl bg-blue-100 flex items-center justify-center">
                    <i class="fas fa-sort-numeric-down text-2xl text-blue-600"></i>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm text-gray-500 mb-1">تاريخ الإضافة</p>
                    <p class="text-lg font-bold text-gray-700">{{ $sponsor->created_at->format('Y/m/d') }}</p>
                    <p class="text-xs text-gray-400">{{ $sponsor->created_at->diffForHumans() }}</p>
                </div>
                <div class="w-14 h-14 rounded-2xl bg-gray-100 flex items-center justify-center">
                    <i class="fas fa-calendar text-2xl text-gray-600"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Social Links Section -->
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100">
        <div class="p-6 border-b border-gray-100">
            <h3 class="text-lg font-bold text-gray-900 flex items-center gap-2">
                <i class="fas fa-share-alt text-purple-600"></i>
                روابط التواصل الاجتماعي
            </h3>
        </div>
        <div class="p-6">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <!-- YouTube -->
                <div class="flex items-center gap-3 p-4 bg-red-50 rounded-xl border border-red-100">
                    <div class="w-10 h-10 rounded-xl bg-red-500 flex items-center justify-center flex-shrink-0">
                        <i class="fab fa-youtube text-white text-lg"></i>
                    </div>
                    <div class="flex-1 min-w-0">
                        <p class="text-xs font-medium text-red-600 mb-1">YouTube</p>
                        @if($sponsor->youtube_link)
                            <a href="{{ $sponsor->youtube_link }}" target="_blank" class="text-sm text-gray-700 hover:text-red-600 truncate block">
                                {{ $sponsor->youtube_link }}
                                <i class="fas fa-external-link-alt text-xs mr-1"></i>
                            </a>
                        @else
                            <span class="text-sm text-gray-400">لا يوجد رابط</span>
                        @endif
                    </div>
                </div>

                <!-- Facebook -->
                <div class="flex items-center gap-3 p-4 bg-blue-50 rounded-xl border border-blue-100">
                    <div class="w-10 h-10 rounded-xl bg-blue-600 flex items-center justify-center flex-shrink-0">
                        <i class="fab fa-facebook-f text-white text-lg"></i>
                    </div>
                    <div class="flex-1 min-w-0">
                        <p class="text-xs font-medium text-blue-600 mb-1">Facebook</p>
                        @if($sponsor->facebook_link)
                            <a href="{{ $sponsor->facebook_link }}" target="_blank" class="text-sm text-gray-700 hover:text-blue-600 truncate block">
                                {{ $sponsor->facebook_link }}
                                <i class="fas fa-external-link-alt text-xs mr-1"></i>
                            </a>
                        @else
                            <span class="text-sm text-gray-400">لا يوجد رابط</span>
                        @endif
                    </div>
                </div>

                <!-- Instagram -->
                <div class="flex items-center gap-3 p-4 bg-pink-50 rounded-xl border border-pink-100">
                    <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-purple-500 via-pink-500 to-orange-400 flex items-center justify-center flex-shrink-0">
                        <i class="fab fa-instagram text-white text-lg"></i>
                    </div>
                    <div class="flex-1 min-w-0">
                        <p class="text-xs font-medium text-pink-600 mb-1">Instagram</p>
                        @if($sponsor->instagram_link)
                            <a href="{{ $sponsor->instagram_link }}" target="_blank" class="text-sm text-gray-700 hover:text-pink-600 truncate block">
                                {{ $sponsor->instagram_link }}
                                <i class="fas fa-external-link-alt text-xs mr-1"></i>
                            </a>
                        @else
                            <span class="text-sm text-gray-400">لا يوجد رابط</span>
                        @endif
                    </div>
                </div>

                <!-- Telegram -->
                <div class="flex items-center gap-3 p-4 bg-cyan-50 rounded-xl border border-cyan-100">
                    <div class="w-10 h-10 rounded-xl bg-cyan-500 flex items-center justify-center flex-shrink-0">
                        <i class="fab fa-telegram-plane text-white text-lg"></i>
                    </div>
                    <div class="flex-1 min-w-0">
                        <p class="text-xs font-medium text-cyan-600 mb-1">Telegram</p>
                        @if($sponsor->telegram_link)
                            <a href="{{ $sponsor->telegram_link }}" target="_blank" class="text-sm text-gray-700 hover:text-cyan-600 truncate block">
                                {{ $sponsor->telegram_link }}
                                <i class="fas fa-external-link-alt text-xs mr-1"></i>
                            </a>
                        @else
                            <span class="text-sm text-gray-400">لا يوجد رابط</span>
                        @endif
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Details Card -->
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100">
        <div class="p-6 border-b border-gray-100">
            <h3 class="text-lg font-bold text-gray-900">تفاصيل الراعي</h3>
        </div>
        <div class="p-6 space-y-6">
            <!-- Photo URL -->
            <div>
                <label class="block text-sm font-semibold text-gray-500 mb-2">رابط الصورة</label>
                <div class="flex items-center gap-3">
                    <input type="text"
                           value="{{ $sponsor->photo_url }}"
                           readonly
                           class="flex-1 px-4 py-2 bg-gray-50 border border-gray-200 rounded-xl text-sm text-gray-600">
                    <button onclick="copyToClipboard('{{ $sponsor->photo_url }}')"
                            class="px-4 py-2 bg-gray-100 hover:bg-gray-200 rounded-xl transition-colors">
                        <i class="fas fa-copy text-gray-600"></i>
                    </button>
                </div>
            </div>

            <!-- Timestamps -->
            <div class="grid grid-cols-2 gap-6">
                <div>
                    <label class="block text-sm font-semibold text-gray-500 mb-2">تاريخ الإنشاء</label>
                    <p class="text-gray-700">{{ $sponsor->created_at->format('Y-m-d H:i:s') }}</p>
                </div>
                <div>
                    <label class="block text-sm font-semibold text-gray-500 mb-2">آخر تحديث</label>
                    <p class="text-gray-700">{{ $sponsor->updated_at->format('Y-m-d H:i:s') }}</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Actions -->
    <div class="flex flex-wrap items-center justify-between gap-4 bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
        <div class="flex flex-wrap items-center gap-3">
            <a href="{{ route('admin.sponsors.edit', $sponsor) }}"
               class="inline-flex items-center gap-2 px-5 py-2.5 bg-blue-600 text-white rounded-xl hover:bg-blue-700 transition-colors">
                <i class="fas fa-edit"></i>
                <span>تعديل</span>
            </a>
            <button onclick="toggleStatus({{ $sponsor->id }})"
                    class="inline-flex items-center gap-2 px-5 py-2.5 {{ $sponsor->is_active ? 'bg-yellow-500 hover:bg-yellow-600' : 'bg-green-500 hover:bg-green-600' }} text-white rounded-xl transition-colors">
                <i class="fas {{ $sponsor->is_active ? 'fa-toggle-off' : 'fa-toggle-on' }}"></i>
                <span>{{ $sponsor->is_active ? 'تعطيل' : 'تفعيل' }}</span>
            </button>
            <button onclick="resetClicks()"
                    class="inline-flex items-center gap-2 px-5 py-2.5 bg-orange-500 text-white rounded-xl hover:bg-orange-600 transition-colors">
                <i class="fas fa-undo"></i>
                <span>إعادة تعيين النقرات</span>
            </button>
        </div>
        <button onclick="confirmDelete({{ $sponsor->id }})"
                class="inline-flex items-center gap-2 px-5 py-2.5 bg-red-600 text-white rounded-xl hover:bg-red-700 transition-colors">
            <i class="fas fa-trash"></i>
            <span>حذف</span>
        </button>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div id="deleteModal" class="fixed inset-0 bg-black/50 z-50 hidden items-center justify-center">
    <div class="bg-white rounded-2xl p-6 max-w-md w-full mx-4">
        <div class="text-center">
            <div class="w-16 h-16 rounded-full bg-red-100 flex items-center justify-center mx-auto mb-4">
                <i class="fas fa-trash-alt text-2xl text-red-600"></i>
            </div>
            <h3 class="text-xl font-bold text-gray-900 mb-2">تأكيد الحذف</h3>
            <p class="text-gray-500 mb-6">هل أنت متأكد من حذف هذا الراعي؟ لا يمكن التراجع عن هذا الإجراء.</p>
            <div class="flex gap-3 justify-center">
                <button onclick="closeDeleteModal()" class="px-6 py-2.5 border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors">
                    إلغاء
                </button>
                <form action="{{ route('admin.sponsors.destroy', $sponsor) }}" method="POST" class="inline">
                    @csrf
                    @method('DELETE')
                    <button type="submit" class="px-6 py-2.5 bg-red-600 text-white rounded-xl hover:bg-red-700 transition-colors">
                        حذف
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
function copyToClipboard(text) {
    navigator.clipboard.writeText(text).then(function() {
        showToast('تم نسخ الرابط', 'success');
    });
}

function confirmDelete(id) {
    $('#deleteModal').removeClass('hidden').addClass('flex');
}

function closeDeleteModal() {
    $('#deleteModal').removeClass('flex').addClass('hidden');
}

function toggleStatus(id) {
    $.ajax({
        url: '/admin/sponsors/' + id + '/toggle-status',
        method: 'POST',
        data: {
            _token: '{{ csrf_token() }}'
        },
        success: function(response) {
            if (response.success) {
                showToast(response.message, 'success');
                setTimeout(() => location.reload(), 1000);
            }
        },
        error: function() {
            showToast('حدث خطأ أثناء تحديث الحالة', 'error');
        }
    });
}

function resetClicks() {
    Swal.fire({
        title: 'إعادة تعيين النقرات',
        text: 'هل أنت متأكد من إعادة تعيين جميع عدادات النقرات لهذا الراعي؟',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#f97316',
        cancelButtonColor: '#6b7280',
        confirmButtonText: 'نعم، إعادة تعيين',
        cancelButtonText: 'إلغاء'
    }).then((result) => {
        if (result.isConfirmed) {
            $.ajax({
                url: '/admin/sponsors/{{ $sponsor->id }}/reset-clicks',
                method: 'POST',
                data: {
                    _token: '{{ csrf_token() }}'
                },
                success: function(response) {
                    if (response.success) {
                        Swal.fire({
                            icon: 'success',
                            title: 'تم!',
                            text: response.message,
                            confirmButtonText: 'حسناً'
                        }).then(() => location.reload());
                    }
                },
                error: function() {
                    Swal.fire({
                        icon: 'error',
                        title: 'خطأ',
                        text: 'حدث خطأ أثناء إعادة تعيين النقرات',
                        confirmButtonText: 'حسناً'
                    });
                }
            });
        }
    });
}

function showToast(message, type) {
    const bgColor = type === 'success' ? 'bg-green-500' : 'bg-red-500';
    const toast = $('<div class="fixed bottom-4 left-4 ' + bgColor + ' text-white px-6 py-3 rounded-xl shadow-lg z-50">' + message + '</div>');
    $('body').append(toast);
    setTimeout(() => toast.fadeOut(() => toast.remove()), 3000);
}

// Close modal on click outside
$('#deleteModal').on('click', function(e) {
    if (e.target === this) {
        closeDeleteModal();
    }
});
</script>
@endpush
