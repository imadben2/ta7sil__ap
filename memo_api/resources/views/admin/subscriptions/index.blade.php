@extends('layouts.admin')

@section('title', 'الاشتراكات')
@section('page-title', 'إدارة الاشتراكات')

@push('styles')
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.7/css/jquery.dataTables.min.css">
<link rel="stylesheet" href="https://cdn.datatables.net/responsive/2.5.0/css/responsive.dataTables.min.css">
<style>
    /* RTL Support for DataTables */
    .dataTables_wrapper {
        direction: rtl;
    }
    .dataTables_filter {
        text-align: left !important;
    }
    .dataTables_paginate {
        text-align: left !important;
    }
    .dataTables_info {
        text-align: right !important;
    }
    table.dataTable thead th {
        text-align: right !important;
    }
    table.dataTable tbody td {
        text-align: right !important;
    }
    /* Custom styling */
    .dataTables_wrapper .dataTables_length select,
    .dataTables_wrapper .dataTables_filter input {
        border: 1px solid #d1d5db;
        border-radius: 0.5rem;
        padding: 0.5rem 1rem;
    }
    .dataTables_wrapper .dataTables_paginate .paginate_button {
        padding: 0.25rem 0.75rem;
        margin: 0 0.25rem;
        border-radius: 0.375rem;
    }
    .dataTables_wrapper .dataTables_paginate .paginate_button.current {
        background: #0891b2 !important;
        color: white !important;
        border: 1px solid #0891b2 !important;
    }
</style>
@endpush

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

    <!-- Enhanced Header with Gradient -->
    <div class="bg-gradient-to-r from-cyan-600 to-blue-600 rounded-xl shadow-lg p-6">
        <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
            <div class="text-white">
                <h2 class="text-2xl font-bold mb-2">إدارة اشتراكات الطلاب</h2>
                <p class="text-cyan-100">متابعة شاملة لجميع الاشتراكات النشطة والمنتهية</p>
            </div>
            <a href="{{ route('admin.exports.subscriptions') }}"
               class="bg-white text-cyan-600 hover:bg-cyan-50 px-6 py-3 rounded-lg flex items-center gap-2 transition-all shadow-md hover:shadow-lg font-semibold">
                <i class="fas fa-file-download"></i>
                <span>تصدير الاشتراكات</span>
            </a>
        </div>
    </div>

    <!-- Filters -->
    <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">
            <i class="fas fa-filter text-cyan-600 mr-2"></i>
            تصفية النتائج
        </h3>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-4" id="filters-form">
            <!-- Course Filter -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">الدورة</label>
                <select id="filter-course" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500 focus:border-cyan-500">
                    <option value="">جميع الدورات</option>
                    @foreach($courses as $course)
                        <option value="{{ $course->id }}">{{ $course->title_ar }}</option>
                    @endforeach
                </select>
            </div>

            <!-- Status Filter -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">الحالة</label>
                <select id="filter-status" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500 focus:border-cyan-500">
                    <option value="">جميع الحالات</option>
                    <option value="active">نشط</option>
                    <option value="expired">منتهي</option>
                    <option value="inactive">غير نشط</option>
                </select>
            </div>

            <!-- Subscription Method Filter -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">طريقة الاشتراك</label>
                <select id="filter-method" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500 focus:border-cyan-500">
                    <option value="">جميع الطرق</option>
                    <option value="payment_receipt">إيصال دفع</option>
                    <option value="subscription_code">كود اشتراك</option>
                    <option value="manual">يدوي</option>
                </select>
            </div>

            <!-- Actions -->
            <div class="flex items-end gap-2 md:col-span-3">
                <button type="button" id="apply-filters" class="px-6 py-2 bg-cyan-600 text-white rounded-lg hover:bg-cyan-700 transition-colors">
                    <i class="fas fa-search mr-2"></i>
                    بحث
                </button>
                <button type="button" id="reset-filters" class="px-6 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors">
                    <i class="fas fa-times mr-2"></i>
                    إعادة تعيين
                </button>
            </div>
        </div>
    </div>

    <!-- Subscriptions DataTable -->
    <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">
            <i class="fas fa-list text-cyan-600 mr-2"></i>
            قائمة الاشتراكات
        </h3>

        <div class="overflow-x-auto">
            <table id="subscriptions-table" class="min-w-full divide-y divide-gray-200 display responsive nowrap" style="width:100%">
                <thead class="bg-gray-50">
                    <tr>
                        <th>معلومات الطالب</th>
                        <th>النوع</th>
                        <th>التفاصيل</th>
                        <th>التواريخ</th>
                        <th>الحالة</th>
                        <th>الإجراءات</th>
                    </tr>
                </thead>
            </table>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/responsive/2.5.0/js/dataTables.responsive.min.js"></script>

<script>
$(document).ready(function() {
    // Auto-hide success/error messages after 5 seconds (only alert messages, not status badges)
    setTimeout(function() {
        $('.border-r-4').filter('[class*="bg-green-100"], [class*="bg-red-100"]').fadeOut('slow');
    }, 5000);


    // Initialize DataTable
    var table = $('#subscriptions-table').DataTable({
        processing: true,
        serverSide: true,
        ajax: {
            url: "{{ route('admin.subscriptions.index') }}",
            data: function(d) {
                d.course_id = $('#filter-course').val();
                d.status = $('#filter-status').val();
                d.subscription_method = $('#filter-method').val();
            }
        },
        columns: [
            { data: 'user_info', name: 'user.name', orderable: true },
            { data: 'subscription_type', name: 'subscription_type', orderable: false, searchable: false },
            { data: 'details', name: 'course.title_ar', orderable: true },
            { data: 'dates', name: 'started_at', orderable: true },
            { data: 'status_badge', name: 'status', orderable: true },
            { data: 'actions', name: 'actions', orderable: false, searchable: false }
        ],
        language: {
            "url": "//cdn.datatables.net/plug-ins/1.13.7/i18n/ar.json",
            "search": "بحث:",
            "lengthMenu": "عرض _MENU_ سجلات لكل صفحة",
            "info": "عرض _START_ إلى _END_ من أصل _TOTAL_ سجل",
            "infoEmpty": "لا توجد سجلات",
            "infoFiltered": "(تمت التصفية من _MAX_ سجل إجمالي)",
            "paginate": {
                "first": "الأول",
                "last": "الأخير",
                "next": "التالي",
                "previous": "السابق"
            },
            "processing": "جاري المعالجة..."
        },
        order: [[3, 'desc']], // Sort by dates descending
        pageLength: 10,
        responsive: true,
        autoWidth: false
    });

    // Apply filters
    $('#apply-filters').on('click', function() {
        table.ajax.reload();
    });

    // Reset filters
    $('#reset-filters').on('click', function() {
        $('#filter-course').val('');
        $('#filter-status').val('');
        $('#filter-method').val('');
        table.ajax.reload();
    });

    // Also reload on Enter key in filter selects
    $('#filters-form select').on('change', function(e) {
        if (e.keyCode === 13) {
            table.ajax.reload();
        }
    });

    // Reload DataTable after form submissions (suspend, reactivate, etc.)
    $(document).on('submit', 'form[action*="suspend"], form[action*="reactivate"]', function(e) {
        // Let the form submit normally, but ensure page reloads completely
        return true;
    });
});
</script>
@endpush
