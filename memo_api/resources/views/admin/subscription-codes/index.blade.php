@extends('layouts.admin')

@section('title', 'أكواد الاشتراك')
@section('page-title', 'إدارة أكواد الاشتراك')

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
        background: #7c3aed !important;
        color: white !important;
        border: 1px solid #7c3aed !important;
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

    <!-- Generated Codes Display -->
    @if (session('generated_codes'))
    <div class="bg-purple-50 border-r-4 border-purple-500 p-4 rounded-lg shadow-sm">
        <h3 class="text-lg font-bold text-purple-900 mb-3">
            <i class="fas fa-ticket-alt mr-2"></i>
            الأكواد المُولَّدة
        </h3>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-2">
            @foreach(session('generated_codes') as $code)
                <div class="bg-white p-3 rounded-lg border border-purple-200">
                    <code class="text-sm font-mono font-bold text-purple-700">{{ $code->code }}</code>
                </div>
            @endforeach
        </div>
    </div>
    @endif

    <!-- Enhanced Header with Gradient -->
    <div class="bg-gradient-to-r from-purple-600 to-pink-600 rounded-xl shadow-lg p-6">
        <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
            <div class="text-white">
                <h2 class="text-2xl font-bold mb-2">إدارة أكواد الاشتراك</h2>
                <p class="text-purple-100">إنشاء ومتابعة جميع أكواد الاشتراك للدورات والباقات</p>
            </div>
            <div class="flex gap-2">
                <a href="{{ route('admin.subscription-codes.create') }}"
                   class="bg-white text-purple-600 hover:bg-purple-50 px-6 py-3 rounded-lg flex items-center gap-2 transition-all shadow-md hover:shadow-lg font-semibold">
                    <i class="fas fa-plus"></i>
                    <span>توليد أكواد جديدة</span>
                </a>
                <a href="{{ route('admin.exports.codes') }}"
                   class="bg-white text-purple-600 hover:bg-purple-50 px-6 py-3 rounded-lg flex items-center gap-2 transition-all shadow-md hover:shadow-lg font-semibold">
                    <i class="fas fa-file-download"></i>
                    <span>تصدير</span>
                </a>
            </div>
        </div>
    </div>

    <!-- Statistics Cards -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-600 text-sm mb-1">إجمالي الأكواد</p>
                    <p class="text-2xl font-bold text-purple-600">{{ $stats['total'] }}</p>
                </div>
                <div class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                    <i class="fas fa-ticket-alt text-purple-600 text-xl"></i>
                </div>
            </div>
        </div>
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-600 text-sm mb-1">النشطة</p>
                    <p class="text-2xl font-bold text-green-600">{{ $stats['active'] }}</p>
                </div>
                <div class="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                    <i class="fas fa-check-circle text-green-600 text-xl"></i>
                </div>
            </div>
        </div>
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-600 text-sm mb-1">المنتهية</p>
                    <p class="text-2xl font-bold text-red-600">{{ $stats['expired'] }}</p>
                </div>
                <div class="w-12 h-12 bg-red-100 rounded-lg flex items-center justify-center">
                    <i class="fas fa-clock text-red-600 text-xl"></i>
                </div>
            </div>
        </div>
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-600 text-sm mb-1">المستخدمة بالكامل</p>
                    <p class="text-2xl font-bold text-orange-600">{{ $stats['fully_used'] }}</p>
                </div>
                <div class="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
                    <i class="fas fa-ban text-orange-600 text-xl"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Filters -->
    <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">
            <i class="fas fa-filter text-purple-600 mr-2"></i>
            تصفية النتائج
        </h3>

        <div class="grid grid-cols-1 md:grid-cols-5 gap-4" id="filters-form">
            <!-- Code Type Filter -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">نوع الكود</label>
                <select id="filter-code-type" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500">
                    <option value="">جميع الأنواع</option>
                    <option value="single_course">دورة واحدة</option>
                    <option value="package">باقة</option>
                    <option value="general">عام</option>
                </select>
            </div>

            <!-- Course Filter -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">الدورة</label>
                <select id="filter-course" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500">
                    <option value="">جميع الدورات</option>
                    @foreach($courses as $course)
                        <option value="{{ $course->id }}">{{ $course->title_ar }}</option>
                    @endforeach
                </select>
            </div>

            <!-- Package Filter -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">الباقة</label>
                <select id="filter-package" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500">
                    <option value="">جميع الباقات</option>
                    @foreach($packages as $package)
                        <option value="{{ $package->id }}">{{ $package->name_ar }}</option>
                    @endforeach
                </select>
            </div>

            <!-- Active Status Filter -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">حالة التفعيل</label>
                <select id="filter-active" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500">
                    <option value="">الكل</option>
                    <option value="1">مفعل</option>
                    <option value="0">معطل</option>
                </select>
            </div>

            <!-- Validity Filter -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">الصلاحية</label>
                <select id="filter-validity" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500">
                    <option value="">الكل</option>
                    <option value="valid">صالح</option>
                    <option value="expired">منتهي</option>
                    <option value="fully_used">مستخدم بالكامل</option>
                </select>
            </div>

            <!-- Actions -->
            <div class="flex items-end gap-2 md:col-span-5">
                <button type="button" id="apply-filters" class="px-6 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors">
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

    <!-- Codes DataTable -->
    <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">
            <i class="fas fa-list text-purple-600 mr-2"></i>
            قائمة الأكواد
        </h3>

        <div class="overflow-x-auto">
            <table id="codes-table" class="min-w-full divide-y divide-gray-200 display responsive nowrap" style="width:100%">
                <thead class="bg-gray-50">
                    <tr>
                        <th>الكود</th>
                        <th>النوع</th>
                        <th>الدورة/الباقة</th>
                        <th>الاستخدامات</th>
                        <th>تاريخ الانتهاء</th>
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
        $('.border-r-4').filter('[class*="bg-green-100"], [class*="bg-red-100"], [class*="bg-purple-50"]').fadeOut('slow');
    }, 5000);

    // Initialize DataTable
    var table = $('#codes-table').DataTable({
        processing: true,
        serverSide: true,
        ajax: {
            url: "{{ route('admin.subscription-codes.index') }}",
            data: function(d) {
                d.code_type = $('#filter-code-type').val();
                d.course_id = $('#filter-course').val();
                d.package_id = $('#filter-package').val();
                d.is_active = $('#filter-active').val();
                d.validity = $('#filter-validity').val();
            }
        },
        columns: [
            { data: 'code_display', name: 'code', orderable: true },
            { data: 'type_badge', name: 'code_type', orderable: true },
            { data: 'item', name: 'course.title_ar', orderable: false },
            { data: 'usage', name: 'current_uses', orderable: true },
            { data: 'expiry', name: 'expires_at', orderable: true },
            { data: 'status_badge', name: 'is_active', orderable: true },
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
        order: [[0, 'desc']], // Sort by code descending
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
        $('#filter-code-type').val('');
        $('#filter-course').val('');
        $('#filter-package').val('');
        $('#filter-active').val('');
        $('#filter-validity').val('');
        table.ajax.reload();
    });

    // Reload on Enter key
    $('#filters-form input, #filters-form select').on('keypress', function(e) {
        if (e.keyCode === 13) {
            table.ajax.reload();
        }
    });
});
</script>
@endpush
