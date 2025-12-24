@extends('layouts.admin')

@section('title', 'المواد الدراسية')
@section('page-title', 'المواد الدراسية')
@section('page-description', 'إدارة المواد الدراسية لجميع المراحل التعليمية')

@push('styles')
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.7/css/jquery.dataTables.min.css">
<link rel="stylesheet" href="https://cdn.datatables.net/responsive/2.5.0/css/responsive.dataTables.min.css">
<style>
    .dataTables_wrapper .dataTables_length select,
    .dataTables_wrapper .dataTables_filter input {
        padding: 0.5rem;
        border: 1px solid #d1d5db;
        border-radius: 0.5rem;
        font-size: 0.875rem;
    }
    .dataTables_wrapper .dataTables_paginate .paginate_button {
        padding: 0.5rem 1rem;
        margin: 0 0.25rem;
        border-radius: 0.375rem;
    }
    .dataTables_wrapper .dataTables_paginate .paginate_button.current {
        background: #3b82f6 !important;
        color: white !important;
        border-color: #3b82f6 !important;
    }
    .dataTables_wrapper .dataTables_info {
        font-size: 0.875rem;
        color: #6b7280;
    }
    table.dataTable thead th {
        background: #f9fafb;
        font-weight: 600;
        color: #374151;
        padding: 1rem;
        border-bottom: 2px solid #e5e7eb;
    }
    table.dataTable tbody tr:hover {
        background-color: #f9fafb;
    }
</style>
@endpush

@section('content')
<div class="p-8">

    <!-- Success Message -->
    @if(session('success'))
    <div class="mb-6 bg-green-100 border-r-4 border-green-500 text-green-700 p-4 rounded-lg shadow-sm" role="alert">
        <div class="flex items-center">
            <i class="fas fa-check-circle mr-3 text-lg"></i>
            <p class="font-medium">{{ session('success') }}</p>
        </div>
    </div>
    @endif

    <!-- Filters Card -->
    <div class="bg-white rounded-xl shadow-sm p-6 mb-6">
        <div class="flex justify-between items-center mb-6">
            <h3 class="text-xl font-bold text-gray-800">
                <i class="fas fa-filter mr-2 text-blue-600"></i>
                تصفية المواد
            </h3>
            <a href="{{ route('admin.subjects.create') }}"
               class="bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white px-6 py-3 rounded-lg shadow-md hover:shadow-lg transition-all duration-200 font-medium">
                <i class="fas fa-plus mr-2"></i>
                إضافة مادة جديدة
            </a>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <!-- Phase Filter -->
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">الطور</label>
                <select id="phase_filter" class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all">
                    <option value="">كل الأطوار</option>
                    @foreach($phases as $phase)
                    <option value="{{ $phase->id }}">{{ $phase->name_ar }}</option>
                    @endforeach
                </select>
            </div>

            <!-- Year Filter -->
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">السنة</label>
                <select id="year_filter" class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all">
                    <option value="">كل السنوات</option>
                    @foreach($years as $year)
                    <option value="{{ $year->id }}" data-phase="{{ $year->academic_phase_id }}">{{ $year->name_ar }}</option>
                    @endforeach
                </select>
            </div>

            <!-- Stream Filter -->
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">الشعبة</label>
                <select id="stream_filter" class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all">
                    <option value="">كل الشعب</option>
                    @foreach($streams as $stream)
                    <option value="{{ $stream->id }}" data-year="{{ $stream->academic_year_id }}">{{ $stream->name_ar }}</option>
                    @endforeach
                </select>
            </div>
        </div>
    </div>

    <!-- DataTable Card -->
    <div class="bg-white rounded-xl shadow-sm overflow-hidden">
        <div class="p-6">
            <table id="subjects-table" class="w-full display responsive nowrap" style="width:100%">
                <thead>
                    <tr>
                        <th class="text-right">المادة</th>
                        <th class="text-right">الطور / السنة / الشعبة</th>
                        <th class="text-right">المعامل</th>
                        <th class="text-right">المحتويات</th>
                        <th class="text-right">الحالة</th>
                        <th class="text-right">الإجراءات</th>
                    </tr>
                </thead>
            </table>
        </div>
    </div>

</div>

@push('scripts')
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/responsive/2.5.0/js/dataTables.responsive.min.js"></script>

<script>
$(document).ready(function() {
    // Initialize DataTable
    var table = $('#subjects-table').DataTable({
        processing: true,
        serverSide: true,
        ajax: {
            url: '{{ route('admin.subjects.index') }}',
            data: function(d) {
                d.phase_id = $('#phase_filter').val();
                d.year_id = $('#year_filter').val();
                d.stream_id = $('#stream_filter').val();
            }
        },
        columns: [
            { data: 'subject_info', name: 'name_ar', orderable: true },
            { data: 'academic_info', name: 'academic_info', orderable: false },
            { data: 'coefficient_badge', name: 'coefficient', orderable: true },
            { data: 'contents_count', name: 'contents_count', orderable: true },
            { data: 'status', name: 'is_active', orderable: true },
            { data: 'actions', name: 'actions', orderable: false, searchable: false }
        ],
        pageLength: 10,
        lengthMenu: [[10, 25, 50, 100], [10, 25, 50, 100]],
        language: {
            url: '//cdn.datatables.net/plug-ins/1.13.7/i18n/ar.json',
            processing: '<div class="text-blue-600"><i class="fas fa-spinner fa-spin text-2xl"></i><br>جاري التحميل...</div>',
            search: 'بحث:',
            lengthMenu: 'عرض _MENU_ صف',
            info: 'عرض _START_ إلى _END_ من أصل _TOTAL_ مادة',
            infoEmpty: 'لا توجد مواد',
            infoFiltered: '(تصفية من _MAX_ مادة)',
            zeroRecords: 'لم يتم العثور على مواد مطابقة',
            emptyTable: 'لا توجد مواد دراسية',
            paginate: {
                first: 'الأول',
                previous: 'السابق',
                next: 'التالي',
                last: 'الأخير'
            }
        },
        responsive: true,
        order: [[0, 'asc']],
        drawCallback: function() {
            // Initialize delete confirmations
            $('.delete-form').on('submit', function(e) {
                if (!confirm('هل أنت متأكد من حذف هذه المادة؟')) {
                    e.preventDefault();
                    return false;
                }
            });
        }
    });

    // Cascading dropdowns with AJAX
    const phaseFilter = $('#phase_filter');
    const yearFilter = $('#year_filter');
    const streamFilter = $('#stream_filter');

    // Store original options
    const allYears = yearFilter.find('option').clone();
    const allStreams = streamFilter.find('option').clone();

    // Phase change - load years
    phaseFilter.on('change', function() {
        const phaseId = $(this).val();

        yearFilter.html('<option value="">كل السنوات</option>');
        streamFilter.html('<option value="">كل الشعب</option>');

        if (!phaseId) {
            yearFilter.append(allYears.clone().not(':first'));
            table.draw();
            return;
        }

        yearFilter.html('<option value="">جاري التحميل...</option>');

        $.get(`/admin/subjects/ajax/years/${phaseId}`, function(years) {
            yearFilter.html('<option value="">كل السنوات</option>');
            years.forEach(function(year) {
                yearFilter.append(`<option value="${year.id}" data-phase="${phaseId}">${year.name_ar}</option>`);
            });
            table.draw();
        }).fail(function() {
            yearFilter.html('<option value="">خطأ في التحميل</option>');
        });
    });

    // Year change - load streams
    yearFilter.on('change', function() {
        const yearId = $(this).val();

        streamFilter.html('<option value="">كل الشعب</option>');

        if (!yearId) {
            table.draw();
            return;
        }

        streamFilter.html('<option value="">جاري التحميل...</option>');

        $.get(`/admin/subjects/ajax/streams/${yearId}`, function(streams) {
            streamFilter.html('<option value="">كل الشعب</option>');
            streams.forEach(function(stream) {
                streamFilter.append(`<option value="${stream.id}" data-year="${yearId}">${stream.name_ar}</option>`);
            });
            table.draw();
        }).fail(function() {
            streamFilter.html('<option value="">خطأ في التحميل</option>');
        });
    });

    // Stream change - reload table
    streamFilter.on('change', function() {
        table.draw();
    });
});
</script>
@endpush
@endsection
