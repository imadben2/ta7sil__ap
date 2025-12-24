@extends('layouts.admin')

@section('title', 'المحتوى التعليمي')
@section('page-title', 'المحتوى التعليمي')
@section('page-description', 'إدارة المحتوى التعليمي (دروس، ملخصات، تمارين، اختبارات)')

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
        background: #2563eb !important;
        color: white !important;
        border: 1px solid #2563eb !important;
    }
</style>
@endpush

@section('content')
<div class="p-8">

    @if (session('success') || session('error'))
    <div class="mb-6 {{ session('success') ? 'bg-green-100 border-green-500 text-green-700' : 'bg-red-100 border-red-500 text-red-700' }} border-r-4 p-4 rounded">
        <div class="flex items-center">
            <i class="fas {{ session('success') ? 'fa-check-circle' : 'fa-exclamation-circle' }} mr-3"></i>
            <p>{{ session('success') ?? session('error') }}</p>
        </div>
    </div>
    @endif

    <!-- Header Actions -->
    <div class="flex items-center justify-between mb-6">
        <div>
            <h3 class="text-lg font-semibold text-gray-800">
                <i class="fas fa-book mr-2 text-blue-600"></i>
                المحتوى التعليمي
            </h3>
        </div>
        <a href="{{ route('admin.contents.create') }}"
           class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg transition-colors">
            <i class="fas fa-plus mr-2"></i>
            إضافة محتوى جديد
        </a>
    </div>

    <!-- Filters -->
    <div class="bg-white rounded-lg shadow-md p-6 mb-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">
            <i class="fas fa-filter text-blue-600 mr-2"></i>
            تصفية النتائج
        </h3>

        <div class="grid grid-cols-1 md:grid-cols-4 gap-4" id="filters-form">
            <!-- Subject Filter -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">المادة</label>
                <select id="filter-subject" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                    <option value="">كل المواد</option>
                    @foreach($subjects as $subject)
                        <option value="{{ $subject->id }}">{{ $subject->name_ar }}</option>
                    @endforeach
                </select>
            </div>

            <!-- Content Type Filter -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">نوع المحتوى</label>
                <select id="filter-type" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                    <option value="">كل الأنواع</option>
                    @foreach($contentTypes as $type)
                        <option value="{{ $type->id }}">{{ $type->name_ar }}</option>
                    @endforeach
                </select>
            </div>

            <!-- Difficulty Filter -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">مستوى الصعوبة</label>
                <select id="filter-difficulty" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                    <option value="">جميع المستويات</option>
                    <option value="easy">سهل</option>
                    <option value="medium">متوسط</option>
                    <option value="hard">صعب</option>
                </select>
            </div>

            <!-- Status Filter -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">الحالة</label>
                <select id="filter-status" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                    <option value="">جميع الحالات</option>
                    <option value="published">منشور</option>
                    <option value="draft">مسودة</option>
                </select>
            </div>

            <!-- Actions -->
            <div class="flex items-end gap-2 md:col-span-4">
                <button type="button" id="apply-filters" class="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
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

    <!-- Contents DataTable -->
    <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">
            <i class="fas fa-list text-blue-600 mr-2"></i>
            قائمة المحتوى
        </h3>

        <div class="overflow-x-auto">
            <table id="contents-table" class="min-w-full divide-y divide-gray-200 display responsive nowrap" style="width:100%">
                <thead class="bg-gray-50">
                    <tr>
                        <th>العنوان</th>
                        <th>المادة</th>
                        <th>النوع</th>
                        <th>الصعوبة</th>
                        <th>الإحصائيات</th>
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
    // Initialize DataTable
    var table = $('#contents-table').DataTable({
        processing: true,
        serverSide: true,
        ajax: {
            url: "{{ route('admin.contents.index') }}",
            data: function(d) {
                d.subject_id = $('#filter-subject').val();
                d.content_type_id = $('#filter-type').val();
                d.difficulty = $('#filter-difficulty').val();
                d.status = $('#filter-status').val();
            }
        },
        columns: [
            { data: 'title', name: 'title_ar', orderable: true },
            { data: 'subject', name: 'subject.name_ar', orderable: true },
            { data: 'type', name: 'contentType.name_ar', orderable: true },
            { data: 'difficulty', name: 'difficulty_level', orderable: true },
            { data: 'stats', name: 'views_count', orderable: true },
            { data: 'status', name: 'is_published', orderable: true },
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
        order: [[0, 'desc']], // Sort by title descending
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
        $('#filter-subject').val('');
        $('#filter-type').val('');
        $('#filter-difficulty').val('');
        $('#filter-status').val('');
        table.ajax.reload();
    });

    // Also reload on Enter key in filter selects
    $('#filters-form select').on('change', function(e) {
        if (e.keyCode === 13) {
            table.ajax.reload();
        }
    });
});
</script>
@endpush
