@extends('layouts.admin')

@section('title', 'إدارة الكويزات')
@section('page-title', 'إدارة الكويزات')
@section('page-description', 'عرض وإدارة جميع الكويزات التعليمية')

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
<div class="space-y-6">

    <!-- Header Actions -->
    <div class="flex items-center justify-between">
        <div>
            <h3 class="text-lg font-semibold text-gray-800">
                <i class="fas fa-clipboard-list mr-2 text-purple-600"></i>
                إدارة الكويزات
            </h3>
        </div>
        <div class="flex gap-3">
            <a href="{{ route('admin.quizzes.import') }}" class="px-6 py-2 bg-gradient-to-r from-purple-600 to-purple-700 hover:from-purple-700 hover:to-purple-800 text-white rounded-lg shadow-md hover:shadow-lg transition-all duration-200">
                <i class="fas fa-file-excel mr-2"></i>
                استيراد من Excel
            </a>
            <a href="{{ route('admin.quizzes.create') }}" class="px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors">
                <i class="fas fa-plus mr-2"></i>
                إنشاء كويز جديد
            </a>
        </div>
    </div>

    <!-- Filters -->
    <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">
            <i class="fas fa-filter text-purple-600 mr-2"></i>
            تصفية النتائج
        </h3>

        <div class="grid grid-cols-1 md:grid-cols-4 gap-4" id="filters-form">
            <!-- Subject Filter -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">المادة الدراسية</label>
                <select id="filter-subject" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500">
                    <option value="">جميع المواد</option>
                    @foreach($subjects as $subject)
                        <option value="{{ $subject->id }}">{{ $subject->name_ar }}</option>
                    @endforeach
                </select>
            </div>

            <!-- Difficulty Filter -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">مستوى الصعوبة</label>
                <select id="filter-difficulty" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500">
                    <option value="">جميع المستويات</option>
                    <option value="easy">سهل</option>
                    <option value="medium">متوسط</option>
                    <option value="hard">صعب</option>
                </select>
            </div>

            <!-- Type Filter -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">نوع الكويز</label>
                <select id="filter-type" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500">
                    <option value="">جميع الأنواع</option>
                    <option value="practice">تدريبي</option>
                    <option value="timed">موقوت</option>
                    <option value="exam">اختبار</option>
                </select>
            </div>

            <!-- Status Filter -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">الحالة</label>
                <select id="filter-status" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500">
                    <option value="">جميع الحالات</option>
                    <option value="published">منشور</option>
                    <option value="draft">مسودة</option>
                </select>
            </div>

            <!-- Actions -->
            <div class="flex items-end gap-2 md:col-span-4">
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

    <!-- Quizzes DataTable -->
    <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">
            <i class="fas fa-list text-purple-600 mr-2"></i>
            قائمة الكويزات
        </h3>

        <div class="overflow-x-auto">
            <table id="quizzes-table" class="min-w-full divide-y divide-gray-200 display responsive nowrap" style="width:100%">
                <thead class="bg-gray-50">
                    <tr>
                        <th>العنوان</th>
                        <th>المادة</th>
                        <th>النوع</th>
                        <th>الصعوبة</th>
                        <th>الأسئلة</th>
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
    var table = $('#quizzes-table').DataTable({
        processing: true,
        serverSide: true,
        ajax: {
            url: "{{ route('admin.quizzes.index') }}",
            data: function(d) {
                d.subject_id = $('#filter-subject').val();
                d.difficulty = $('#filter-difficulty').val();
                d.type = $('#filter-type').val();
                d.status = $('#filter-status').val();
            }
        },
        columns: [
            { data: 'title', name: 'title_ar', orderable: true },
            { data: 'subject', name: 'subject.name_ar', orderable: true },
            { data: 'type', name: 'quiz_type', orderable: true },
            { data: 'difficulty', name: 'difficulty_level', orderable: true },
            { data: 'questions', name: 'questions_count', orderable: true },
            { data: 'stats', name: 'total_attempts', orderable: true },
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
        $('#filter-difficulty').val('');
        $('#filter-type').val('');
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
