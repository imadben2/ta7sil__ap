@extends('layouts.admin')

@section('title', 'إدارة الرعاة')
@section('page-title', 'إدارة الرعاة')
@section('page-description', 'إدارة الرعاة والأساتذة في قسم "هاد التطبيق برعاية"')

@section('content')
<div class="space-y-6">
    <!-- Section Toggle Card -->
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
        <div class="flex items-center justify-between">
            <div class="flex items-center gap-4">
                <div class="w-14 h-14 rounded-2xl {{ $sectionEnabled ? 'bg-purple-100' : 'bg-gray-100' }} flex items-center justify-center">
                    <i class="fas fa-broadcast-tower text-2xl {{ $sectionEnabled ? 'text-purple-600' : 'text-gray-400' }}"></i>
                </div>
                <div>
                    <h4 class="text-lg font-bold text-gray-900">إظهار قسم الرعاة في التطبيق</h4>
                    <p class="text-sm text-gray-500 mt-1">تفعيل أو تعطيل قسم "هاد التطبيق برعاية" في التطبيق</p>
                </div>
            </div>
            <label class="relative inline-flex items-center cursor-pointer">
                <input type="checkbox"
                       id="sectionToggle"
                       class="sr-only peer"
                       {{ $sectionEnabled ? 'checked' : '' }}>
                <div class="w-14 h-8 bg-gray-200 peer-checked:bg-purple-600 rounded-full peer peer-focus:ring-4 peer-focus:ring-purple-300 transition-colors after:content-[''] after:absolute after:top-[4px] after:right-[4px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-6 after:w-6 after:transition-all peer-checked:after:translate-x-[-24px]"></div>
            </label>
        </div>
        <div id="sectionStatus" class="mt-4 px-4 py-2 rounded-lg {{ $sectionEnabled ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-700' }} text-sm">
            <i class="fas {{ $sectionEnabled ? 'fa-check-circle' : 'fa-times-circle' }} ml-2"></i>
            {{ $sectionEnabled ? 'القسم مفعل حالياً ويظهر في التطبيق' : 'القسم معطل حالياً ولا يظهر في التطبيق' }}
        </div>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
        <!-- Total Sponsors -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm text-gray-500 mb-1">إجمالي الرعاة</p>
                    <p class="text-3xl font-bold text-gray-900">{{ number_format($stats['total']) }}</p>
                </div>
                <div class="w-14 h-14 rounded-2xl bg-purple-100 flex items-center justify-center">
                    <i class="fas fa-users text-2xl text-purple-600"></i>
                </div>
            </div>
        </div>

        <!-- Active Sponsors -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm text-gray-500 mb-1">الرعاة النشطين</p>
                    <p class="text-3xl font-bold text-green-600">{{ number_format($stats['active']) }}</p>
                </div>
                <div class="w-14 h-14 rounded-2xl bg-green-100 flex items-center justify-center">
                    <i class="fas fa-check-circle text-2xl text-green-600"></i>
                </div>
            </div>
        </div>

        <!-- Inactive Sponsors -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm text-gray-500 mb-1">الرعاة المعطلين</p>
                    <p class="text-3xl font-bold text-red-600">{{ number_format($stats['inactive']) }}</p>
                </div>
                <div class="w-14 h-14 rounded-2xl bg-red-100 flex items-center justify-center">
                    <i class="fas fa-times-circle text-2xl text-red-600"></i>
                </div>
            </div>
        </div>

        <!-- Total Clicks -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm text-gray-500 mb-1">إجمالي النقرات</p>
                    <p class="text-3xl font-bold text-blue-600">{{ number_format($stats['total_clicks']) }}</p>
                </div>
                <div class="w-14 h-14 rounded-2xl bg-blue-100 flex items-center justify-center">
                    <i class="fas fa-mouse-pointer text-2xl text-blue-600"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Main Content Card -->
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100">
        <!-- Header -->
        <div class="p-6 border-b border-gray-100">
            <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                <div>
                    <h3 class="text-xl font-bold text-gray-900">قائمة الرعاة</h3>
                    <p class="text-sm text-gray-500 mt-1">الأساتذة والرعاة الظاهرين في التطبيق</p>
                </div>
                <div class="flex items-center gap-3">
                    <!-- Filter -->
                    <select id="statusFilter" class="px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent">
                        <option value="">جميع الحالات</option>
                        <option value="active">نشط</option>
                        <option value="inactive">معطل</option>
                    </select>
                    <!-- Add Button -->
                    <a href="{{ route('admin.sponsors.create') }}"
                       class="inline-flex items-center gap-2 px-5 py-2.5 bg-gradient-to-l from-purple-600 to-purple-700 text-white rounded-xl hover:from-purple-700 hover:to-purple-800 transition-all shadow-lg shadow-purple-500/25">
                        <i class="fas fa-plus"></i>
                        <span>إضافة راعي</span>
                    </a>
                </div>
            </div>
        </div>

        <!-- Table -->
        <div class="overflow-x-auto">
            <table id="sponsorsTable" class="w-full">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-6 py-4 text-right text-xs font-bold text-gray-600 uppercase tracking-wider">الراعي</th>
                        <th class="px-6 py-4 text-right text-xs font-bold text-gray-600 uppercase tracking-wider">التخصص</th>
                        <th class="px-6 py-4 text-center text-xs font-bold text-gray-600 uppercase tracking-wider">الروابط</th>
                        <th class="px-6 py-4 text-center text-xs font-bold text-gray-600 uppercase tracking-wider">النقرات</th>
                        <th class="px-6 py-4 text-center text-xs font-bold text-gray-600 uppercase tracking-wider">الترتيب</th>
                        <th class="px-6 py-4 text-center text-xs font-bold text-gray-600 uppercase tracking-wider">الحالة</th>
                        <th class="px-6 py-4 text-center text-xs font-bold text-gray-600 uppercase tracking-wider">الإجراءات</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100">
                </tbody>
            </table>
        </div>
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
                <form id="deleteForm" method="POST" class="inline">
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
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css">
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>

<script>
let table;

$(document).ready(function() {
    table = $('#sponsorsTable').DataTable({
        processing: true,
        serverSide: true,
        ajax: {
            url: '{{ route("admin.sponsors.index") }}',
            data: function(d) {
                d.status = $('#statusFilter').val();
            }
        },
        columns: [
            { data: 'sponsor_info', name: 'name_ar', orderable: true },
            { data: 'specialty_badge', name: 'specialty', orderable: true },
            { data: 'social_links_display', name: 'social_links', orderable: false, className: 'text-center' },
            { data: 'click_count_display', name: 'click_count', orderable: true, className: 'text-center' },
            { data: 'display_order', name: 'display_order', orderable: true, className: 'text-center' },
            { data: 'status_badge', name: 'is_active', orderable: true, className: 'text-center' },
            { data: 'actions', name: 'actions', orderable: false, searchable: false, className: 'text-center' }
        ],
        order: [[4, 'asc']],
        language: {
            url: '//cdn.datatables.net/plug-ins/1.13.6/i18n/ar.json',
            processing: '<div class="flex items-center justify-center py-4"><i class="fas fa-spinner fa-spin text-2xl text-purple-600"></i></div>'
        },
        drawCallback: function() {
            // Add styling after draw
            $('#sponsorsTable tbody tr').addClass('hover:bg-gray-50 transition-colors');
        }
    });

    // Filter change
    $('#statusFilter').on('change', function() {
        table.ajax.reload();
    });

    // Section toggle
    $('#sectionToggle').on('change', function() {
        const isChecked = $(this).is(':checked');
        toggleSection();
    });
});

function toggleSection() {
    $.ajax({
        url: '{{ route("admin.sponsors.toggle-section") }}',
        method: 'POST',
        data: {
            _token: '{{ csrf_token() }}'
        },
        success: function(response) {
            if (response.success) {
                showToast(response.message, 'success');

                // Update UI
                const statusDiv = $('#sectionStatus');
                const iconDiv = $('#sectionToggle').closest('.flex').find('.w-14.h-14');

                if (response.enabled) {
                    statusDiv.removeClass('bg-red-50 text-red-700').addClass('bg-green-50 text-green-700');
                    statusDiv.html('<i class="fas fa-check-circle ml-2"></i>القسم مفعل حالياً ويظهر في التطبيق');
                    iconDiv.removeClass('bg-gray-100').addClass('bg-purple-100');
                    iconDiv.find('i').removeClass('text-gray-400').addClass('text-purple-600');
                } else {
                    statusDiv.removeClass('bg-green-50 text-green-700').addClass('bg-red-50 text-red-700');
                    statusDiv.html('<i class="fas fa-times-circle ml-2"></i>القسم معطل حالياً ولا يظهر في التطبيق');
                    iconDiv.removeClass('bg-purple-100').addClass('bg-gray-100');
                    iconDiv.find('i').removeClass('text-purple-600').addClass('text-gray-400');
                }
            }
        },
        error: function() {
            showToast('حدث خطأ أثناء تحديث الإعدادات', 'error');
            // Revert the toggle
            $('#sectionToggle').prop('checked', !$('#sectionToggle').is(':checked'));
        }
    });
}

function confirmDelete(id) {
    $('#deleteForm').attr('action', '/admin/sponsors/' + id);
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
                table.ajax.reload(null, false);
                showToast(response.message, 'success');
            }
        },
        error: function() {
            showToast('حدث خطأ أثناء تحديث الحالة', 'error');
        }
    });
}

function resetClicks(id) {
    if (!confirm('هل تريد إعادة تعيين عداد النقرات إلى صفر؟')) return;

    $.ajax({
        url: '/admin/sponsors/' + id + '/reset-clicks',
        method: 'POST',
        data: {
            _token: '{{ csrf_token() }}'
        },
        success: function(response) {
            if (response.success) {
                table.ajax.reload(null, false);
                showToast(response.message, 'success');
            }
        },
        error: function() {
            showToast('حدث خطأ أثناء إعادة التعيين', 'error');
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

<style>
/* DataTables RTL styling */
#sponsorsTable_wrapper .dataTables_filter {
    float: right !important;
    text-align: right !important;
}
#sponsorsTable_wrapper .dataTables_length {
    float: left !important;
}
#sponsorsTable_wrapper .dataTables_info {
    float: right !important;
}
#sponsorsTable_wrapper .dataTables_paginate {
    float: left !important;
}
#sponsorsTable_wrapper input,
#sponsorsTable_wrapper select {
    border: 1px solid #e5e7eb;
    border-radius: 0.5rem;
    padding: 0.5rem 1rem;
}
#sponsorsTable_wrapper .dataTables_paginate .paginate_button {
    border-radius: 0.5rem !important;
    margin: 0 2px;
}
#sponsorsTable_wrapper .dataTables_paginate .paginate_button.current {
    background: linear-gradient(to left, #9333ea, #7c3aed) !important;
    border-color: #9333ea !important;
    color: white !important;
}
</style>
@endpush
