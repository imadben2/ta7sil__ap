@extends('layouts.admin')

@section('title', 'إدارة البطاقات التعليمية')
@section('page-title', 'البطاقات التعليمية')
@section('page-description', 'إدارة مجموعات البطاقات التعليمية بنظام التكرار المتباعد')

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
        background: #ec4899 !important;
        color: white !important;
        border: 1px solid #ec4899 !important;
    }
</style>
@endpush

@section('content')
<div class="p-6">

    @if (session('success') || session('error'))
    <div class="mb-6 {{ session('success') ? 'bg-green-100 border-green-500 text-green-700' : 'bg-red-100 border-red-500 text-red-700' }} border-r-4 p-4 rounded">
        <div class="flex items-center">
            <i class="fas {{ session('success') ? 'fa-check-circle' : 'fa-exclamation-circle' }} mr-3"></i>
            <p>{{ session('success') ?? session('error') }}</p>
        </div>
    </div>
    @endif

    <!-- Header -->
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-6">
        <div>
            <h1 class="text-2xl font-bold text-gray-900">
                <i class="fas fa-layer-group mr-2 text-pink-600"></i>
                البطاقات التعليمية
            </h1>
            <p class="text-gray-600 mt-1">إدارة مجموعات البطاقات التعليمية بنظام التكرار المتباعد</p>
        </div>
        <a href="{{ route('admin.flashcard-decks.create') }}"
           class="inline-flex items-center gap-2 px-5 py-2.5 bg-gradient-to-l from-pink-500 to-pink-600 text-white rounded-xl font-bold shadow-lg hover:shadow-xl transition-all">
            <i class="fas fa-plus"></i>
            إنشاء مجموعة جديدة
        </a>
    </div>

    <!-- Statistics Cards -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div class="bg-white rounded-xl shadow-sm p-5 border-r-4 border-pink-500">
            <div class="flex items-center gap-4">
                <div class="w-12 h-12 bg-pink-100 rounded-xl flex items-center justify-center">
                    <i class="fas fa-layer-group text-pink-600 text-xl"></i>
                </div>
                <div>
                    <p class="text-gray-500 text-sm">إجمالي المجموعات</p>
                    <p class="text-2xl font-bold text-gray-900">{{ number_format($stats['total_decks']) }}</p>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm p-5 border-r-4 border-green-500">
            <div class="flex items-center gap-4">
                <div class="w-12 h-12 bg-green-100 rounded-xl flex items-center justify-center">
                    <i class="fas fa-check-circle text-green-600 text-xl"></i>
                </div>
                <div>
                    <p class="text-gray-500 text-sm">المنشورة</p>
                    <p class="text-2xl font-bold text-gray-900">{{ number_format($stats['published_decks']) }}</p>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm p-5 border-r-4 border-blue-500">
            <div class="flex items-center gap-4">
                <div class="w-12 h-12 bg-blue-100 rounded-xl flex items-center justify-center">
                    <i class="fas fa-clone text-blue-600 text-xl"></i>
                </div>
                <div>
                    <p class="text-gray-500 text-sm">إجمالي البطاقات</p>
                    <p class="text-2xl font-bold text-gray-900">{{ number_format($stats['total_cards']) }}</p>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm p-5 border-r-4 border-purple-500">
            <div class="flex items-center gap-4">
                <div class="w-12 h-12 bg-purple-100 rounded-xl flex items-center justify-center">
                    <i class="fas fa-sync text-purple-600 text-xl"></i>
                </div>
                <div>
                    <p class="text-gray-500 text-sm">جلسات المراجعة</p>
                    <p class="text-2xl font-bold text-gray-900">{{ number_format($stats['total_reviews']) }}</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Filters -->
    <div class="bg-white rounded-xl shadow-sm p-6 mb-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">
            <i class="fas fa-filter text-pink-600 mr-2"></i>
            تصفية النتائج
        </h3>

        <div class="grid grid-cols-1 md:grid-cols-5 gap-4" id="filters-form">
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">المادة</label>
                <select id="filter_subject" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500">
                    <option value="">كل المواد</option>
                    @foreach($subjects as $subject)
                        <option value="{{ $subject->id }}">{{ $subject->name_ar }}</option>
                    @endforeach
                </select>
            </div>

            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">الشعبة</label>
                <select id="filter_stream" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500">
                    <option value="">كل الشعب</option>
                    @foreach($streams as $stream)
                        <option value="{{ $stream->id }}">{{ $stream->name_ar }}</option>
                    @endforeach
                </select>
            </div>

            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">الصعوبة</label>
                <select id="filter_difficulty" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500">
                    <option value="">كل المستويات</option>
                    <option value="easy">سهل</option>
                    <option value="medium">متوسط</option>
                    <option value="hard">صعب</option>
                </select>
            </div>

            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">الحالة</label>
                <select id="filter_status" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500">
                    <option value="">الكل</option>
                    <option value="published">منشور</option>
                    <option value="draft">مسودة</option>
                </select>
            </div>

            <div class="flex items-end gap-2">
                <button type="button" id="apply-filters" class="px-6 py-2 bg-pink-600 text-white rounded-lg hover:bg-pink-700 transition-colors">
                    <i class="fas fa-search mr-2"></i>
                    بحث
                </button>
                <button type="button" id="btn_reset_filters" class="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors">
                    <i class="fas fa-times mr-1"></i>
                    إعادة
                </button>
            </div>
        </div>
    </div>

    <!-- Data Table -->
    <div class="bg-white rounded-xl shadow-sm p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">
            <i class="fas fa-list text-pink-600 mr-2"></i>
            قائمة المجموعات
        </h3>

        <div class="overflow-x-auto">
            <table id="decks_table" class="min-w-full divide-y divide-gray-200 display responsive nowrap" style="width:100%">
                <thead class="bg-gray-50">
                    <tr>
                        <th>العنوان</th>
                        <th>المادة</th>
                        <th>الشعبة</th>
                        <th>الصعوبة</th>
                        <th>البطاقات</th>
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
    var table = $('#decks_table').DataTable({
        processing: true,
        serverSide: true,
        ajax: {
            url: "{{ route('admin.flashcard-decks.index') }}",
            data: function(d) {
                d.subject_id = $('#filter_subject').val();
                d.stream_id = $('#filter_stream').val();
                d.difficulty = $('#filter_difficulty').val();
                d.status = $('#filter_status').val();
            }
        },
        columns: [
            { data: 'title', name: 'title_ar', orderable: true },
            { data: 'subject', name: 'subject.name_ar', orderable: true },
            { data: 'stream', name: 'academicStreams.name_ar', orderable: false },
            { data: 'difficulty', name: 'difficulty_level', orderable: true },
            { data: 'cards', name: 'total_cards', orderable: true },
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
        order: [[0, 'asc']],
        pageLength: 10,
        responsive: true,
        autoWidth: false
    });

    // Apply filters
    $('#apply-filters').on('click', function() {
        table.ajax.reload();
    });

    // Reset filters
    $('#btn_reset_filters').on('click', function() {
        $('#filter_subject').val('');
        $('#filter_stream').val('');
        $('#filter_difficulty').val('');
        $('#filter_status').val('');
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
