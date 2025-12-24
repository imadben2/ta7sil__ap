@extends('layouts.admin')

@section('title', 'قوائم أكواد الاشتراك')
@section('page-title', 'إدارة قوائم أكواد الاشتراك')

@push('styles')
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.7/css/jquery.dataTables.min.css">
<link rel="stylesheet" href="https://cdn.datatables.net/responsive/2.5.0/css/responsive.dataTables.min.css">
<style>
    /* RTL Support for DataTables */
    .dataTables_wrapper { direction: rtl; }
    .dataTables_filter { text-align: left !important; }
    .dataTables_paginate { text-align: left !important; }
    .dataTables_info { text-align: right !important; }
    table.dataTable thead th { text-align: right !important; }
    table.dataTable tbody td { text-align: right !important; }
    .dataTables_wrapper .dataTables_paginate .paginate_button.current {
        background: #7c3aed !important;
        color: white !important;
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

    <!-- Enhanced Header -->
    <div class="bg-gradient-to-r from-indigo-600 to-purple-600 rounded-xl shadow-lg p-6">
        <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
            <div class="text-white">
                <h2 class="text-2xl font-bold mb-2">قوائم أكواد الاشتراك</h2>
                <p class="text-indigo-100">عرض وإدارة مجموعات الأكواد المُنظمة</p>
            </div>
            <div class="flex gap-2">
                <a href="{{ route('admin.subscription-codes.create') }}"
                   class="bg-white text-indigo-600 hover:bg-indigo-50 px-6 py-3 rounded-lg flex items-center gap-2 transition-all shadow-md hover:shadow-lg font-semibold">
                    <i class="fas fa-plus"></i>
                    <span>إنشاء قائمة جديدة</span>
                </a>
                <a href="{{ route('admin.subscription-codes.index') }}"
                   class="bg-white text-indigo-600 hover:bg-indigo-50 px-6 py-3 rounded-lg flex items-center gap-2 transition-all shadow-md hover:shadow-lg font-semibold">
                    <i class="fas fa-list"></i>
                    <span>جميع الأكواد</span>
                </a>
            </div>
        </div>
    </div>

    <!-- Statistics Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-600 text-sm mb-1">إجمالي القوائم</p>
                    <p class="text-2xl font-bold text-indigo-600">{{ $stats['total_lists'] }}</p>
                </div>
                <div class="w-12 h-12 bg-indigo-100 rounded-lg flex items-center justify-center">
                    <i class="fas fa-layer-group text-indigo-600 text-xl"></i>
                </div>
            </div>
        </div>
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-600 text-sm mb-1">إجمالي الأكواد في القوائم</p>
                    <p class="text-2xl font-bold text-purple-600">{{ $stats['total_codes'] }}</p>
                </div>
                <div class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                    <i class="fas fa-ticket-alt text-purple-600 text-xl"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Filters -->
    <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">
            <i class="fas fa-filter text-indigo-600 mr-2"></i>
            تصفية النتائج
        </h3>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-4" id="filters-form">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">نوع الكود</label>
                <select id="filter-code-type" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500">
                    <option value="">جميع الأنواع</option>
                    <option value="single_course">دورة واحدة</option>
                    <option value="package">باقة</option>
                    <option value="general">عام</option>
                </select>
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">الدورة</label>
                <select id="filter-course" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500">
                    <option value="">جميع الدورات</option>
                    @foreach($courses as $course)
                        <option value="{{ $course->id }}">{{ $course->title_ar }}</option>
                    @endforeach
                </select>
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">الباقة</label>
                <select id="filter-package" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500">
                    <option value="">جميع الباقات</option>
                    @foreach($packages as $package)
                        <option value="{{ $package->id }}">{{ $package->name_ar }}</option>
                    @endforeach
                </select>
            </div>

            <div class="flex items-end gap-2 md:col-span-3">
                <button type="button" id="apply-filters" class="px-6 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors">
                    <i class="fas fa-search mr-2"></i> بحث
                </button>
                <button type="button" id="reset-filters" class="px-6 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors">
                    <i class="fas fa-times mr-2"></i> إعادة تعيين
                </button>
            </div>
        </div>
    </div>

    <!-- Lists DataTable -->
    <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">
            <i class="fas fa-list text-indigo-600 mr-2"></i>
            قائمة المجموعات
        </h3>

        <div class="overflow-x-auto">
            <table id="lists-table" class="min-w-full divide-y divide-gray-200 display responsive nowrap" style="width:100%">
                <thead class="bg-gray-50">
                    <tr>
                        <th>اسم القائمة</th>
                        <th>النوع</th>
                        <th>الدورة/الباقة</th>
                        <th>الإحصائيات</th>
                        <th>الإيرادات</th>
                        <th>تاريخ الإنشاء</th>
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
    setTimeout(function() {
        $('.border-r-4').fadeOut('slow');
    }, 5000);

    var table = $('#lists-table').DataTable({
        processing: true,
        serverSide: true,
        ajax: {
            url: "{{ route('admin.subscription-code-lists.index') }}",
            data: function(d) {
                d.code_type = $('#filter-code-type').val();
                d.course_id = $('#filter-course').val();
                d.package_id = $('#filter-package').val();
            }
        },
        columns: [
            { data: 'name_display', name: 'name', orderable: true },
            { data: 'type_badge', name: 'code_type', orderable: true },
            { data: 'item', name: 'course.title_ar', orderable: false },
            { data: 'stats', name: 'total_codes', orderable: true },
            { data: 'revenue', name: 'revenue', orderable: false },
            { data: 'created', name: 'created_at', orderable: true },
            { data: 'actions', name: 'actions', orderable: false, searchable: false }
        ],
        language: {
            "url": "//cdn.datatables.net/plug-ins/1.13.7/i18n/ar.json"
        },
        order: [[5, 'desc']],
        pageLength: 10,
        responsive: true
    });

    $('#apply-filters').on('click', function() { table.ajax.reload(); });
    $('#reset-filters').on('click', function() {
        $('#filter-code-type, #filter-course, #filter-package').val('');
        table.ajax.reload();
    });
});
</script>
@endpush
