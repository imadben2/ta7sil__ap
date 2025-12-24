@extends('layouts.admin')

@section('title', 'محتوى مخطط المادة')
@section('page-title', 'محتوى مخطط المادة')
@section('page-description', 'إدارة المحتوى الدراسي المنظم للمواد')

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
    .bulk-actions-bar {
        display: none;
    }
    .bulk-actions-bar.show {
        display: flex;
    }
</style>
@endpush

@section('content')
<div class="p-8">

    <!-- Success/Error Messages -->
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

    <!-- Header Actions -->
    <div class="flex justify-between items-center mb-6">
        <div>
            <h1 class="text-2xl font-bold text-gray-800">محتوى مخطط المادة</h1>
            <p class="text-gray-600 mt-1">إدارة المحتوى الدراسي المنظم (المحاور، الوحدات، المواضيع)</p>
        </div>
        <div class="flex gap-3">
            <a href="{{ route('admin.subject-planner-content.tree') }}"
               class="bg-purple-600 hover:bg-purple-700 text-white px-4 py-2 rounded-lg shadow-md hover:shadow-lg transition-all duration-200 font-medium">
                <i class="fas fa-sitemap mr-2"></i>
                العرض الشجري
            </a>
            <a href="{{ route('admin.subject-planner-content.create') }}"
               class="bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white px-6 py-2 rounded-lg shadow-md hover:shadow-lg transition-all duration-200 font-medium">
                <i class="fas fa-plus mr-2"></i>
                إضافة محتوى جديد
            </a>
        </div>
    </div>

    <!-- Filters Card -->
    <div class="bg-white rounded-xl shadow-sm p-6 mb-6">
        <h3 class="text-lg font-bold text-gray-800 mb-4">
            <i class="fas fa-filter mr-2 text-blue-600"></i>
            تصفية المحتوى
        </h3>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-4">
            <!-- Phase Filter -->
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">المرحلة</label>
                <select id="phase_filter" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all">
                    <option value="">كل المراحل</option>
                    @foreach($phases as $phase)
                    <option value="{{ $phase->id }}">{{ $phase->name_ar }}</option>
                    @endforeach
                </select>
            </div>

            <!-- Year Filter -->
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">السنة</label>
                <select id="year_filter" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all" disabled>
                    <option value="">اختر المرحلة أولاً</option>
                </select>
            </div>

            <!-- Stream Filter -->
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">الشعبة</label>
                <select id="stream_filter" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all" disabled>
                    <option value="">اختر السنة أولاً</option>
                </select>
            </div>

            <!-- Subject Filter -->
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">المادة</label>
                <select id="subject_filter" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all" disabled>
                    <option value="">اختر الشعبة أولاً</option>
                </select>
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <!-- Level Filter -->
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">المستوى</label>
                <select id="level_filter" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all">
                    <option value="">كل المستويات</option>
                    @foreach($levels as $key => $label)
                    <option value="{{ $key }}">{{ $label }}</option>
                    @endforeach
                </select>
            </div>

            <!-- BAC Priority Filter -->
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">أولوية البكالوريا</label>
                <select id="bac_priority_filter" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all">
                    <option value="">الكل</option>
                    <option value="1">أولوية فقط</option>
                    <option value="0">غير أولوية</option>
                </select>
            </div>

            <!-- Status Filter -->
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">الحالة</label>
                <select id="status_filter" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all">
                    <option value="">كل الحالات</option>
                    <option value="published">منشور</option>
                    <option value="draft">مسودة</option>
                    <option value="active">نشط</option>
                    <option value="inactive">غير نشط</option>
                </select>
            </div>
        </div>

        <div class="mt-4 flex justify-end">
            <button type="button" id="reset_filters" class="bg-gray-500 hover:bg-gray-600 text-white px-4 py-2 rounded-lg transition">
                <i class="fas fa-undo mr-2"></i>
                إعادة تعيين
            </button>
        </div>
    </div>

    <!-- Bulk Actions Bar -->
    <div id="bulk_actions_bar" class="bulk-actions-bar bg-blue-50 border border-blue-200 rounded-lg p-4 mb-4 items-center justify-between">
        <div class="flex items-center gap-2">
            <span class="text-blue-800 font-medium">
                <span id="selected_count">0</span> عنصر محدد
            </span>
        </div>
        <div class="flex items-center gap-2">
            <form id="bulk_action_form" method="POST" action="{{ route('admin.subject-planner-content.bulk-action') }}" class="flex items-center gap-2">
                @csrf
                <input type="hidden" name="ids" id="bulk_ids">
                <select name="action" class="px-3 py-2 border border-gray-300 rounded-lg">
                    <option value="">اختر إجراء</option>
                    <option value="publish">نشر</option>
                    <option value="unpublish">إلغاء النشر</option>
                    <option value="activate">تفعيل</option>
                    <option value="deactivate">إلغاء التفعيل</option>
                    <option value="delete">حذف</option>
                </select>
                <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition">
                    <i class="fas fa-check mr-2"></i>
                    تنفيذ
                </button>
            </form>
            <button type="button" id="clear_selection" class="bg-gray-500 hover:bg-gray-600 text-white px-4 py-2 rounded-lg transition">
                <i class="fas fa-times mr-2"></i>
                إلغاء التحديد
            </button>
        </div>
    </div>

    <!-- DataTable Card -->
    <div class="bg-white rounded-xl shadow-sm overflow-hidden">
        <div class="p-6">
            <table id="content-table" class="w-full display responsive nowrap" style="width:100%">
                <thead>
                    <tr>
                        <th class="text-right" style="width: 30px;">
                            <input type="checkbox" id="select_all" class="rounded">
                        </th>
                        <th class="text-right">العنوان</th>
                        <th class="text-right">المستوى</th>
                        <th class="text-right">المادة</th>
                        <th class="text-right">أولوية BAC</th>
                        <th class="text-right">الحالة</th>
                        <th class="text-right">الفروع</th>
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
    var table = $('#content-table').DataTable({
        processing: true,
        serverSide: true,
        ajax: {
            url: '{{ route('admin.subject-planner-content.index') }}',
            data: function(d) {
                d.phase_id = $('#phase_filter').val();
                d.year_id = $('#year_filter').val();
                d.stream_id = $('#stream_filter').val();
                d.subject_id = $('#subject_filter').val();
                d.level = $('#level_filter').val();
                d.bac_priority = $('#bac_priority_filter').val();
                d.status = $('#status_filter').val();
            }
        },
        columns: [
            { data: 'checkbox', name: 'checkbox', orderable: false, searchable: false },
            { data: 'title_info', name: 'title_ar', orderable: true },
            { data: 'level_badge', name: 'level', orderable: true },
            { data: 'subject_info', name: 'subject_id', orderable: false },
            { data: 'bac_priority_badge', name: 'is_bac_priority', orderable: true },
            { data: 'status_badges', name: 'is_published', orderable: true },
            { data: 'children_count', name: 'children_count', orderable: false },
            { data: 'actions', name: 'actions', orderable: false, searchable: false }
        ],
        pageLength: 25,
        lengthMenu: [[10, 25, 50, 100], [10, 25, 50, 100]],
        language: {
            url: '//cdn.datatables.net/plug-ins/1.13.7/i18n/ar.json',
            processing: '<div class="text-blue-600"><i class="fas fa-spinner fa-spin text-2xl"></i><br>جاري التحميل...</div>',
            search: 'بحث:',
            lengthMenu: 'عرض _MENU_ صف',
            info: 'عرض _START_ إلى _END_ من أصل _TOTAL_ عنصر',
            infoEmpty: 'لا توجد عناصر',
            infoFiltered: '(تصفية من _MAX_ عنصر)',
            zeroRecords: 'لم يتم العثور على عناصر مطابقة',
            emptyTable: 'لا يوجد محتوى',
            paginate: {
                first: 'الأول',
                previous: 'السابق',
                next: 'التالي',
                last: 'الأخير'
            }
        },
        responsive: true,
        order: [[1, 'asc']],
        drawCallback: function() {
            updateBulkActionsBar();
        }
    });

    // Cascading dropdowns
    $('#phase_filter').on('change', function() {
        var phaseId = $(this).val();
        var yearFilter = $('#year_filter');
        var streamFilter = $('#stream_filter');
        var subjectFilter = $('#subject_filter');

        yearFilter.html('<option value="">جاري التحميل...</option>').prop('disabled', true);
        streamFilter.html('<option value="">اختر السنة أولاً</option>').prop('disabled', true);
        subjectFilter.html('<option value="">اختر الشعبة أولاً</option>').prop('disabled', true);

        if (!phaseId) {
            yearFilter.html('<option value="">اختر المرحلة أولاً</option>');
            table.draw();
            return;
        }

        $.get(`{{ url('/admin/subject-planner-content/ajax/years') }}/${phaseId}`, function(years) {
            yearFilter.html('<option value="">كل السنوات</option>');
            years.forEach(function(year) {
                yearFilter.append(`<option value="${year.id}">${year.name_ar}</option>`);
            });
            yearFilter.prop('disabled', false);
            table.draw();
        });
    });

    $('#year_filter').on('change', function() {
        var yearId = $(this).val();
        var streamFilter = $('#stream_filter');
        var subjectFilter = $('#subject_filter');

        streamFilter.html('<option value="">جاري التحميل...</option>').prop('disabled', true);
        subjectFilter.html('<option value="">اختر الشعبة أولاً</option>').prop('disabled', true);

        if (!yearId) {
            streamFilter.html('<option value="">اختر السنة أولاً</option>');
            table.draw();
            return;
        }

        $.get(`{{ url('/admin/subject-planner-content/ajax/streams') }}/${yearId}`, function(streams) {
            streamFilter.html('<option value="">كل الشعب</option>');
            streams.forEach(function(stream) {
                streamFilter.append(`<option value="${stream.id}">${stream.name_ar}</option>`);
            });
            streamFilter.prop('disabled', false);
            table.draw();
        });
    });

    $('#stream_filter').on('change', function() {
        var streamId = $(this).val();
        var subjectFilter = $('#subject_filter');

        subjectFilter.html('<option value="">جاري التحميل...</option>').prop('disabled', true);

        if (!streamId) {
            subjectFilter.html('<option value="">اختر الشعبة أولاً</option>');
            table.draw();
            return;
        }

        $.get(`{{ url('/admin/subject-planner-content/ajax/subjects') }}/${streamId}`, function(subjects) {
            subjectFilter.html('<option value="">كل المواد</option>');
            subjects.forEach(function(subject) {
                subjectFilter.append(`<option value="${subject.id}">${subject.name_ar}</option>`);
            });
            subjectFilter.prop('disabled', false);
            table.draw();
        });
    });

    $('#subject_filter, #level_filter, #bac_priority_filter, #status_filter').on('change', function() {
        table.draw();
    });

    // Reset filters
    $('#reset_filters').on('click', function() {
        $('#phase_filter').val('');
        $('#year_filter').html('<option value="">اختر المرحلة أولاً</option>').prop('disabled', true);
        $('#stream_filter').html('<option value="">اختر السنة أولاً</option>').prop('disabled', true);
        $('#subject_filter').html('<option value="">اختر الشعبة أولاً</option>').prop('disabled', true);
        $('#level_filter').val('');
        $('#bac_priority_filter').val('');
        $('#status_filter').val('');
        table.draw();
    });

    // Bulk selection
    var selectedIds = [];

    function updateBulkActionsBar() {
        if (selectedIds.length > 0) {
            $('#bulk_actions_bar').addClass('show');
            $('#selected_count').text(selectedIds.length);
            $('#bulk_ids').val(JSON.stringify(selectedIds));
        } else {
            $('#bulk_actions_bar').removeClass('show');
        }
    }

    $('#select_all').on('change', function() {
        var isChecked = $(this).is(':checked');
        $('.row-checkbox').each(function() {
            $(this).prop('checked', isChecked);
            var id = parseInt($(this).val());
            if (isChecked && !selectedIds.includes(id)) {
                selectedIds.push(id);
            } else if (!isChecked) {
                selectedIds = selectedIds.filter(function(item) { return item !== id; });
            }
        });
        updateBulkActionsBar();
    });

    $(document).on('change', '.row-checkbox', function() {
        var id = parseInt($(this).val());
        if ($(this).is(':checked')) {
            if (!selectedIds.includes(id)) {
                selectedIds.push(id);
            }
        } else {
            selectedIds = selectedIds.filter(function(item) { return item !== id; });
        }
        updateBulkActionsBar();
    });

    $('#clear_selection').on('click', function() {
        selectedIds = [];
        $('#select_all').prop('checked', false);
        $('.row-checkbox').prop('checked', false);
        updateBulkActionsBar();
    });

    // Bulk action form submission
    $('#bulk_action_form').on('submit', function(e) {
        var action = $(this).find('select[name="action"]').val();
        if (!action) {
            e.preventDefault();
            alert('يرجى اختيار إجراء');
            return false;
        }
        if (selectedIds.length === 0) {
            e.preventDefault();
            alert('يرجى تحديد عناصر');
            return false;
        }
        if (action === 'delete' && !confirm('هل أنت متأكد من حذف العناصر المحددة؟')) {
            e.preventDefault();
            return false;
        }

        // Convert array to comma-separated for form submission
        $('#bulk_ids').val(selectedIds.join(','));
    });

    // Delete confirmation
    $(document).on('submit', '.delete-form', function(e) {
        if (!confirm('هل أنت متأكد من حذف هذا العنصر؟')) {
            e.preventDefault();
            return false;
        }
    });
});
</script>
@endpush
@endsection
