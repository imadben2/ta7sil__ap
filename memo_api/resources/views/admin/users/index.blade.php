@extends('layouts.admin')

@section('title', 'المستخدمون')
@section('page-title', 'إدارة المستخدمين')
@section('page-description', 'عرض وإدارة جميع المستخدمين في النظام')

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

    @if(session('error'))
    <div class="mb-6 bg-red-100 border-r-4 border-red-500 text-red-700 p-4 rounded-lg shadow-sm" role="alert">
        <div class="flex items-center">
            <i class="fas fa-exclamation-circle mr-3 text-lg"></i>
            <p class="font-medium">{{ session('error') }}</p>
        </div>
    </div>
    @endif

    <!-- Filters Card -->
    <div class="bg-white rounded-xl shadow-sm p-6 mb-6">
        <div class="flex justify-between items-center mb-6">
            <h3 class="text-xl font-bold text-gray-800">
                <i class="fas fa-filter mr-2 text-blue-600"></i>
                تصفية المستخدمين
            </h3>
            <div class="flex gap-3">
                <a href="{{ route('admin.users.analytics') }}"
                   class="bg-gradient-to-r from-purple-600 to-purple-700 hover:from-purple-700 hover:to-purple-800 text-white px-6 py-3 rounded-lg shadow-md hover:shadow-lg transition-all duration-200 font-medium">
                    <i class="fas fa-chart-line mr-2"></i>
                    الإحصائيات
                </a>
                <a href="{{ route('admin.users.export') }}"
                   class="bg-gradient-to-r from-green-600 to-green-700 hover:from-green-700 hover:to-green-800 text-white px-6 py-3 rounded-lg shadow-md hover:shadow-lg transition-all duration-200 font-medium">
                    <i class="fas fa-file-excel mr-2"></i>
                    تصدير Excel
                </a>
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <!-- Phase Filter -->
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">الطور</label>
                <select id="phase_filter" class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all">
                    <option value="">كل الأطوار</option>
                    @php
                        $phases = \App\Models\AcademicPhase::where('is_active', true)->orderBy('order')->get();
                    @endphp
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
                    @php
                        $years = \App\Models\AcademicYear::where('is_active', true)->orderBy('order')->get();
                    @endphp
                    @foreach($years as $year)
                    <option value="{{ $year->id }}" data-phase="{{ $year->academic_phase_id }}">{{ $year->name_ar }}</option>
                    @endforeach
                </select>
            </div>

            <!-- Status Filter -->
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">الحالة</label>
                <select id="status_filter" class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all">
                    <option value="">الكل</option>
                    <option value="active">نشط</option>
                    <option value="inactive">غير نشط</option>
                    <option value="banned">محظور</option>
                </select>
            </div>
        </div>
    </div>

    <!-- DataTable Card -->
    <div class="bg-white rounded-xl shadow-sm overflow-hidden">
        <div class="p-6">
            <table id="users-table" class="w-full display responsive nowrap" style="width:100%">
                <thead>
                    <tr>
                        <th class="text-right">المستخدم</th>
                        <th class="text-right">المعلومات الأكاديمية</th>
                        <th class="text-right">الحالة</th>
                        <th class="text-right">تاريخ التسجيل</th>
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
    console.log('Initializing DataTable...');

    // Initialize DataTable
    var table = $('#users-table').DataTable({
        processing: true,
        serverSide: true,
        ajax: {
            url: '{{ route('admin.users.index') }}',
            type: 'GET',
            data: function(d) {
                d.phase_id = $('#phase_filter').val();
                d.year_id = $('#year_filter').val();
                d.status_filter = $('#status_filter').val();
                console.log('DataTable request data:', d);
            },
            error: function(xhr, error, code) {
                console.error('DataTable AJAX error:', error, code);
                console.error('Response:', xhr.responseText);
            }
        },
        columns: [
            { data: 'user_info', name: 'name', orderable: true },
            { data: 'academic_info', name: 'academic_info', orderable: false },
            { data: 'status', name: 'is_active', orderable: true },
            { data: 'registered_at', name: 'created_at', orderable: true },
            { data: 'actions', name: 'actions', orderable: false, searchable: false }
        ],
        pageLength: 10,
        lengthMenu: [[10, 25, 50, 100], [10, 25, 50, 100]],
        language: {
            processing: '<div class="text-blue-600"><i class="fas fa-spinner fa-spin text-2xl"></i><br>جاري التحميل...</div>',
            search: 'بحث:',
            lengthMenu: 'عرض _MENU_ صف',
            info: 'عرض _START_ إلى _END_ من أصل _TOTAL_ مستخدم',
            infoEmpty: 'لا يوجد مستخدمون',
            infoFiltered: '(تصفية من _MAX_ مستخدم)',
            zeroRecords: 'لم يتم العثور على مستخدمين مطابقين',
            emptyTable: 'لا يوجد مستخدمون',
            paginate: {
                first: 'الأول',
                previous: 'السابق',
                next: 'التالي',
                last: 'الأخير'
            }
        },
        responsive: true,
        order: [[3, 'desc']],
        drawCallback: function(settings) {
            console.log('DataTable drawn:', settings.json);
        }
    });

    console.log('DataTable initialized:', table);

    // Filter changes - reload table
    $('#phase_filter, #year_filter, #status_filter').on('change', function() {
        console.log('Filter changed, reloading table...');
        table.draw();
    });

    // Phase filter - filter years
    const phaseFilter = $('#phase_filter');
    const yearFilter = $('#year_filter');
    const allYears = yearFilter.find('option').clone();

    phaseFilter.on('change', function() {
        const phaseId = $(this).val();
        yearFilter.html('<option value="">كل السنوات</option>');

        if (!phaseId) {
            yearFilter.append(allYears.clone().not(':first'));
        } else {
            allYears.each(function() {
                const option = $(this);
                if (option.val() === '' || option.data('phase') == phaseId) {
                    yearFilter.append(option.clone());
                }
            });
        }
    });

    // Handle form submissions in action buttons
    $(document).on('submit', 'form[action*="toggle-status"], form[action*="reset-password"]', function(e) {
        e.preventDefault();
        const form = $(this);
        const url = form.attr('action');

        if (confirm('هل أنت متأكد من تنفيذ هذا الإجراء؟')) {
            $.ajax({
                url: url,
                method: 'POST',
                data: form.serialize(),
                success: function(response) {
                    if (response.success) {
                        table.draw(false);
                        alert(response.message || 'تم تنفيذ الإجراء بنجاح');
                    }
                },
                error: function(xhr) {
                    console.error('Action error:', xhr);
                    alert('حدث خطأ أثناء تنفيذ الإجراء');
                }
            });
        }
    });
});
</script>
@endpush
@endsection
