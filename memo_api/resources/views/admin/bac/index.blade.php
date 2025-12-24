@extends('layouts.admin')

@section('title', 'إدارة أرشيف البكالوريا')
@section('page-title', 'أرشيف البكالوريا')
@section('page-description', 'إدارة مواضيع البكالوريا السابقة')

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
    <!-- Success/Error Messages -->
    @if (session('success') || session('error'))
    <div class="{{ session('success') ? 'bg-green-100 border-green-500 text-green-700' : 'bg-red-100 border-red-500 text-red-700' }} border-r-4 p-4 rounded-lg shadow-sm">
        <div class="flex items-center">
            <i class="fas {{ session('success') ? 'fa-check-circle' : 'fa-exclamation-circle' }} mr-3 text-lg"></i>
            <p>{{ session('success') ?? session('error') }}</p>
        </div>
    </div>
    @endif

    <!-- Header Actions -->
    <div class="flex items-center justify-between">
        <div class="flex gap-3">
            <a href="{{ route('admin.bac.create') }}" class="px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors">
                <i class="fas fa-plus mr-2"></i>
                إضافة موضوع جديد
            </a>
            <a href="{{ route('admin.bac.years') }}" class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
                <i class="fas fa-calendar mr-2"></i>
                إدارة السنوات
            </a>
            <a href="{{ route('admin.bac.statistics') }}" class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors">
                <i class="fas fa-chart-bar mr-2"></i>
                الإحصائيات
            </a>
        </div>
    </div>

    <!-- Filters -->
    <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">
            <i class="fas fa-filter text-blue-600 mr-2"></i>
            تصفية النتائج
        </h3>

        <div class="grid grid-cols-1 md:grid-cols-4 gap-4" id="filters-form">
            <!-- Year Filter -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">السنة</label>
                <select id="filter-year" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                    <option value="">جميع السنوات</option>
                    @foreach($years as $year)
                        <option value="{{ $year->id }}">{{ $year->year }}</option>
                    @endforeach
                </select>
            </div>

            <!-- Session Filter -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">الدورة</label>
                <select id="filter-session" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                    <option value="">جميع الدورات</option>
                    @foreach($sessions as $session)
                        <option value="{{ $session->id }}">{{ $session->name_ar }}</option>
                    @endforeach
                </select>
            </div>

            <!-- Stream Filter -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">الشعبة</label>
                <select id="filter-stream" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                    <option value="">جميع الشعب</option>
                    @foreach($streams as $stream)
                        <option value="{{ $stream->id }}">{{ $stream->name_ar }}</option>
                    @endforeach
                </select>
            </div>

            <!-- Subject Filter (depends on Stream) -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">المادة</label>
                <select id="filter-subject" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500" disabled>
                    <option value="">اختر الشعبة أولاً</option>
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

    <!-- BAC Subjects DataTable -->
    <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">
            <i class="fas fa-list text-blue-600 mr-2"></i>
            قائمة المواضيع
        </h3>

        <div class="overflow-x-auto">
            <table id="bac-table" class="min-w-full divide-y divide-gray-200 display responsive nowrap" style="width:100%">
                <thead class="bg-gray-50">
                    <tr>
                        <th>العنوان</th>
                        <th>السنة</th>
                        <th>الدورة</th>
                        <th>المادة</th>
                        <th>الشعبة</th>
                        <th>المدة</th>
                        <th>الإحصائيات</th>
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
    var table = $('#bac-table').DataTable({
        processing: true,
        serverSide: true,
        ajax: {
            url: "{{ route('admin.bac.index') }}",
            data: function(d) {
                d.year_id = $('#filter-year').val();
                d.session_id = $('#filter-session').val();
                d.subject_id = $('#filter-subject').val();
                d.stream_id = $('#filter-stream').val();
            }
        },
        columns: [
            { data: 'title', name: 'title_ar', orderable: true },
            { data: 'year', name: 'bacYear.year', orderable: true },
            { data: 'session', name: 'bacSession.name_ar', orderable: true },
            { data: 'subject', name: 'subject.name_ar', orderable: true },
            { data: 'stream', name: 'academicStream.name_ar', orderable: true },
            { data: 'duration', name: 'duration_minutes', orderable: true },
            { data: 'stats', name: 'views_count', orderable: true },
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
        order: [[1, 'desc']], // Sort by year descending
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
        $('#filter-year').val('');
        $('#filter-session').val('');
        $('#filter-stream').val('');
        $('#filter-subject').html('<option value="">اختر الشعبة أولاً</option>').prop('disabled', true);
        table.ajax.reload();
    });

    // Also reload on Enter key in filter selects
    $('#filters-form select').on('change', function(e) {
        if (e.keyCode === 13) {
            table.ajax.reload();
        }
    });

    // Load subjects when stream is selected (AJAX dependency)
    $('#filter-stream').on('change', function() {
        const streamId = $(this).val();
        const subjectSelect = $('#filter-subject');

        // Reset subject dropdown
        subjectSelect.html('<option value="">جميع المواد</option>');

        if (!streamId) {
            subjectSelect.prop('disabled', true);
            subjectSelect.html('<option value="">اختر الشعبة أولاً</option>');
            return;
        }

        // Fetch subjects for selected stream
        fetch(`/admin/bac/ajax/subjects/${streamId}`)
            .then(response => response.json())
            .then(subjects => {
                subjectSelect.html('<option value="">جميع المواد</option>');
                subjects.forEach(subject => {
                    subjectSelect.append(`<option value="${subject.id}">${subject.name_ar}</option>`);
                });
                subjectSelect.prop('disabled', false);
            })
            .catch(error => {
                console.error('Error loading subjects:', error);
                subjectSelect.html('<option value="">خطأ في التحميل</option>');
            });
    });
});
</script>
@endpush
