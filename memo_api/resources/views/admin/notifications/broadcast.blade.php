@extends('layouts.admin')

@section('title', 'إرسال إشعار جماعي')

@section('content')
<div class="min-h-screen bg-gray-50">
    <div class="px-4 sm:px-6 lg:px-8 py-8">
        <!-- Header -->
        <div class="mb-8">
            <div class="flex justify-between items-center mb-4">
                <div>
                    <h1 class="text-3xl font-bold text-gray-900">إرسال إشعار جماعي</h1>
                    <p class="text-gray-600 mt-1">إرسال إشعارات للمستخدمين عبر التطبيق</p>
                </div>
                <a href="{{ route('admin.notifications.index') }}" class="bg-gray-600 hover:bg-gray-700 text-white px-6 py-3 rounded-lg shadow-md font-semibold">
                    <i class="fas fa-arrow-right ml-2"></i>
                    العودة
                </a>
            </div>
        </div>

        <!-- Messages -->
        @if(session('success'))
        <div class="mb-6 bg-green-50 border-r-4 border-green-500 p-4 rounded">
            <div class="flex items-center">
                <i class="fas fa-check-circle text-green-500 ml-3"></i>
                <p class="text-green-800">{{ session('success') }}</p>
            </div>
        </div>
        @endif

        @if(session('error'))
        <div class="mb-6 bg-red-50 border-r-4 border-red-500 p-4 rounded">
            <div class="flex items-center">
                <i class="fas fa-exclamation-circle text-red-500 ml-3"></i>
                <p class="text-red-800">{{ session('error') }}</p>
            </div>
        </div>
        @endif

        @if($errors->any())
        <div class="mb-6 bg-red-50 border-r-4 border-red-500 p-4 rounded">
            <div class="flex items-start">
                <i class="fas fa-exclamation-circle text-red-500 ml-3 mt-1"></i>
                <ul class="text-red-800">
                    @foreach($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        </div>
        @endif

        <form id="broadcastForm" action="{{ route('admin.notifications.broadcast.send') }}" method="POST">
            @csrf

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                <!-- Left Column - Notification Content -->
                <div class="lg:col-span-2 space-y-6">
                    <!-- Notification Content Card -->
                    <div class="bg-white rounded-xl shadow-md p-6">
                        <h2 class="text-xl font-bold text-gray-900 mb-6">
                            <i class="fas fa-edit ml-2 text-blue-600"></i>
                            محتوى الإشعار
                        </h2>

                        <div class="space-y-6">
                            <!-- Title -->
                            <div>
                                <label class="block text-sm font-bold text-gray-700 mb-2">عنوان الإشعار <span class="text-red-500">*</span></label>
                                <input type="text" name="title_ar" value="{{ old('title_ar') }}" required maxlength="255"
                                    class="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-right"
                                    placeholder="أدخل عنوان الإشعار...">
                                <p class="text-xs text-gray-500 mt-1">الحد الأقصى: 255 حرف</p>
                            </div>

                            <!-- Body -->
                            <div>
                                <label class="block text-sm font-bold text-gray-700 mb-2">نص الإشعار <span class="text-red-500">*</span></label>
                                <textarea name="body_ar" rows="4" required maxlength="1000"
                                    class="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-right resize-none"
                                    placeholder="أدخل نص الإشعار...">{{ old('body_ar') }}</textarea>
                                <p class="text-xs text-gray-500 mt-1">الحد الأقصى: 1000 حرف</p>
                            </div>

                            <!-- Type and Priority Row -->
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                <!-- Type -->
                                <div>
                                    <label class="block text-sm font-bold text-gray-700 mb-2">نوع الإشعار <span class="text-red-500">*</span></label>
                                    <select name="type" required
                                        class="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                                        <option value="system" {{ old('type') == 'system' ? 'selected' : '' }}>نظام</option>
                                        <option value="announcement" {{ old('type') == 'announcement' ? 'selected' : '' }}>إعلان</option>
                                        <option value="course_update" {{ old('type') == 'course_update' ? 'selected' : '' }}>تحديث دورة</option>
                                        <option value="achievement" {{ old('type') == 'achievement' ? 'selected' : '' }}>إنجاز</option>
                                    </select>
                                </div>

                                <!-- Priority -->
                                <div>
                                    <label class="block text-sm font-bold text-gray-700 mb-2">الأولوية <span class="text-red-500">*</span></label>
                                    <select name="priority" required
                                        class="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                                        <option value="normal" {{ old('priority', 'normal') == 'normal' ? 'selected' : '' }}>عادية</option>
                                        <option value="low" {{ old('priority') == 'low' ? 'selected' : '' }}>منخفضة</option>
                                        <option value="high" {{ old('priority') == 'high' ? 'selected' : '' }}>عالية</option>
                                    </select>
                                </div>
                            </div>

                            <!-- Schedule -->
                            <div>
                                <label class="block text-sm font-bold text-gray-700 mb-2">
                                    <i class="fas fa-clock ml-1 text-indigo-600"></i>
                                    جدولة الإرسال (اختياري)
                                </label>
                                <input type="datetime-local" name="scheduled_for" value="{{ old('scheduled_for') }}"
                                    class="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                                <p class="text-xs text-gray-500 mt-1">اتركه فارغًا للإرسال الفوري</p>
                            </div>
                        </div>
                    </div>

                    <!-- Target Audience Card -->
                    <div class="bg-white rounded-xl shadow-md p-6">
                        <h2 class="text-xl font-bold text-gray-900 mb-6">
                            <i class="fas fa-users ml-2 text-green-600"></i>
                            الجمهور المستهدف
                        </h2>

                        <!-- Target Type Selection -->
                        <div class="space-y-4 mb-6">
                            <label class="flex items-center cursor-pointer p-4 rounded-lg border-2 border-gray-200 hover:border-blue-500 transition-colors target-option" data-target="all">
                                <input type="radio" name="target_type" value="all" {{ old('target_type', 'all') == 'all' ? 'checked' : '' }}
                                    class="w-5 h-5 text-blue-600 border-gray-300 focus:ring-blue-500">
                                <div class="mr-4">
                                    <span class="text-sm font-bold text-gray-900">جميع المستخدمين</span>
                                    <p class="text-xs text-gray-500">إرسال لجميع المستخدمين النشطين ({{ $totalUsers }} مستخدم)</p>
                                </div>
                            </label>

                            <label class="flex items-center cursor-pointer p-4 rounded-lg border-2 border-gray-200 hover:border-blue-500 transition-colors target-option" data-target="stream">
                                <input type="radio" name="target_type" value="stream" {{ old('target_type') == 'stream' ? 'checked' : '' }}
                                    class="w-5 h-5 text-blue-600 border-gray-300 focus:ring-blue-500">
                                <div class="mr-4">
                                    <span class="text-sm font-bold text-gray-900">حسب الشعبة</span>
                                    <p class="text-xs text-gray-500">إرسال لمستخدمي شعبة محددة</p>
                                </div>
                            </label>

                            <label class="flex items-center cursor-pointer p-4 rounded-lg border-2 border-gray-200 hover:border-blue-500 transition-colors target-option" data-target="year">
                                <input type="radio" name="target_type" value="year" {{ old('target_type') == 'year' ? 'checked' : '' }}
                                    class="w-5 h-5 text-blue-600 border-gray-300 focus:ring-blue-500">
                                <div class="mr-4">
                                    <span class="text-sm font-bold text-gray-900">حسب السنة الدراسية</span>
                                    <p class="text-xs text-gray-500">إرسال لمستخدمي سنة دراسية محددة</p>
                                </div>
                            </label>

                            <label class="flex items-center cursor-pointer p-4 rounded-lg border-2 border-gray-200 hover:border-blue-500 transition-colors target-option" data-target="selected">
                                <input type="radio" name="target_type" value="selected" {{ old('target_type') == 'selected' ? 'checked' : '' }}
                                    class="w-5 h-5 text-blue-600 border-gray-300 focus:ring-blue-500">
                                <div class="mr-4">
                                    <span class="text-sm font-bold text-gray-900">اختيار مستخدمين</span>
                                    <p class="text-xs text-gray-500">اختيار مستخدمين محددين من القائمة</p>
                                </div>
                            </label>
                        </div>

                        <!-- Stream Filter -->
                        <div id="streamFilter" class="hidden mb-6">
                            <label class="block text-sm font-bold text-gray-700 mb-2">اختر الشعبة</label>
                            <select name="stream_id" id="stream_id"
                                class="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                                <option value="">-- اختر الشعبة --</option>
                                @foreach($streams as $stream)
                                    <option value="{{ $stream->id }}" {{ old('stream_id') == $stream->id ? 'selected' : '' }}>{{ $stream->name_ar }}</option>
                                @endforeach
                            </select>
                        </div>

                        <!-- Year Filter -->
                        <div id="yearFilter" class="hidden mb-6">
                            <label class="block text-sm font-bold text-gray-700 mb-2">اختر السنة الدراسية</label>
                            <select name="year_id" id="year_id"
                                class="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                                <option value="">-- اختر السنة --</option>
                                @foreach($years as $year)
                                    <option value="{{ $year->id }}" {{ old('year_id') == $year->id ? 'selected' : '' }}>{{ $year->name_ar }}</option>
                                @endforeach
                            </select>
                        </div>

                        <!-- Users Table (for selected target type) -->
                        <div id="usersTableContainer" class="hidden">
                            <div class="flex justify-between items-center mb-4">
                                <h3 class="text-lg font-bold text-gray-900">اختر المستخدمين</h3>
                                <div class="flex gap-2">
                                    <button type="button" onclick="selectAllUsers()" class="text-sm bg-blue-100 hover:bg-blue-200 text-blue-700 px-4 py-2 rounded-lg font-semibold">
                                        <i class="fas fa-check-double ml-1"></i>
                                        تحديد الكل
                                    </button>
                                    <button type="button" onclick="deselectAllUsers()" class="text-sm bg-gray-100 hover:bg-gray-200 text-gray-700 px-4 py-2 rounded-lg font-semibold">
                                        <i class="fas fa-times ml-1"></i>
                                        إلغاء التحديد
                                    </button>
                                </div>
                            </div>

                            <!-- Filter Option -->
                            <div class="mb-4 p-3 bg-blue-50 border border-blue-200 rounded-lg">
                                <label class="flex items-center cursor-pointer">
                                    <input type="checkbox" id="filterWithDevices" class="rounded border-blue-300 text-blue-600 focus:ring-blue-500">
                                    <span class="mr-2 text-sm text-blue-700">عرض المستخدمين الذين لديهم أجهزة مسجلة فقط</span>
                                </label>
                            </div>

                            <div class="overflow-x-auto border rounded-lg">
                                <table id="usersTable" class="min-w-full divide-y divide-gray-200">
                                    <thead class="bg-gray-50">
                                        <tr>
                                            <th class="px-4 py-3 text-right text-xs font-bold text-gray-700">
                                                <input type="checkbox" id="selectAllCheckbox" class="rounded border-gray-300">
                                            </th>
                                            <th class="px-4 py-3 text-right text-xs font-bold text-gray-700">الاسم</th>
                                            <th class="px-4 py-3 text-right text-xs font-bold text-gray-700">البريد</th>
                                            <th class="px-4 py-3 text-right text-xs font-bold text-gray-700">الشعبة</th>
                                            <th class="px-4 py-3 text-right text-xs font-bold text-gray-700">السنة</th>
                                            <th class="px-4 py-3 text-right text-xs font-bold text-gray-700">الأجهزة</th>
                                        </tr>
                                    </thead>
                                    <tbody class="bg-white divide-y divide-gray-200"></tbody>
                                </table>
                            </div>

                            <div class="mt-3 p-3 bg-yellow-50 border border-yellow-200 rounded-lg">
                                <p class="text-sm text-yellow-700">
                                    <i class="fas fa-info-circle ml-1"></i>
                                    <strong>ملاحظة:</strong> الإشعارات ستُحفظ لجميع المستخدمين المحددين. إشعارات Push ستُرسل فقط للمستخدمين الذين لديهم أجهزة مسجلة.
                                </p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right Column - Preview & Actions -->
                <div class="space-y-6">
                    <!-- Preview Card -->
                    <div class="bg-white rounded-xl shadow-md p-6 sticky top-6">
                        <h2 class="text-xl font-bold text-gray-900 mb-6">
                            <i class="fas fa-eye ml-2 text-purple-600"></i>
                            معاينة
                        </h2>

                        <!-- Notification Preview -->
                        <div class="bg-gray-100 rounded-lg p-4 mb-6">
                            <div class="flex items-start gap-3">
                                <div class="bg-blue-600 p-2 rounded-lg shrink-0">
                                    <i class="fas fa-bell text-white"></i>
                                </div>
                                <div class="flex-1 min-w-0">
                                    <p id="previewTitle" class="font-bold text-gray-900 text-sm mb-1">عنوان الإشعار</p>
                                    <p id="previewBody" class="text-gray-600 text-xs line-clamp-3">نص الإشعار سيظهر هنا...</p>
                                </div>
                            </div>
                        </div>

                        <!-- Recipients Summary -->
                        <div class="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-lg p-4 mb-6">
                            <div class="flex items-center justify-between mb-2">
                                <span class="text-sm font-semibold text-gray-700">المستلمين</span>
                                <span id="recipientsCount" class="text-2xl font-bold text-blue-600">0</span>
                            </div>
                            <div class="flex items-center justify-between">
                                <span class="text-sm font-semibold text-gray-700">الأجهزة</span>
                                <span id="devicesCount" class="text-2xl font-bold text-green-600">0</span>
                            </div>
                        </div>

                        <!-- Submit Button -->
                        <button type="submit" id="submitBtn"
                            class="w-full bg-gradient-to-r from-green-600 to-green-700 hover:from-green-700 hover:to-green-800 text-white px-6 py-4 rounded-lg font-bold text-lg shadow-lg transition-all">
                            <i class="fas fa-paper-plane ml-2"></i>
                            إرسال الإشعار
                        </button>

                        <p class="text-xs text-gray-500 text-center mt-4">
                            <i class="fas fa-info-circle ml-1"></i>
                            سيتم إرسال الإشعار فوريًا ما لم يتم جدولته
                        </p>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>
@endsection

@push('styles')
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.7/css/jquery.dataTables.min.css">
<style>
    .target-option.active {
        border-color: #3b82f6;
        background-color: #eff6ff;
    }
</style>
@endpush

@push('scripts')
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>

<script>
let usersTable = null;
let selectedUserIds = [];
let previewDebounceTimer = null;

$(document).ready(function() {
    // Initialize DataTable
    usersTable = $('#usersTable').DataTable({
        processing: true,
        serverSide: true,
        ajax: {
            url: '{{ route('admin.notifications.broadcast.users') }}',
            data: function(d) {
                d.stream_id = $('#stream_id').val();
                d.year_id = $('#year_id').val();
                d.with_devices = $('#filterWithDevices').is(':checked') ? 'true' : 'false';
            },
            error: function(xhr, error, thrown) {
                console.error('DataTables AJAX error:', error, thrown);
                console.error('Response:', xhr.responseText);
            }
        },
        columns: [
            { data: 'checkbox', name: 'checkbox', orderable: false, searchable: false },
            { data: 'name', name: 'name' },
            { data: 'email', name: 'email' },
            { data: 'stream', name: 'stream', orderable: false },
            { data: 'year', name: 'year', orderable: false },
            { data: 'fcm_tokens', name: 'fcm_tokens', orderable: false, searchable: false }
        ],
        language: {
            "processing": "جاري التحميل...",
            "lengthMenu": "أظهر _MENU_ مدخلات",
            "zeroRecords": "لا يوجد مستخدمين مطابقين",
            "info": "إظهار _START_ إلى _END_ من أصل _TOTAL_ مدخل",
            "infoEmpty": "لا توجد بيانات",
            "infoFiltered": "(تمت التصفية من _MAX_ مدخل)",
            "search": "بحث:",
            "paginate": {
                "first": "الأول",
                "previous": "السابق",
                "next": "التالي",
                "last": "الأخير"
            },
            "loadingRecords": "جاري التحميل...",
            "emptyTable": "لا توجد بيانات متاحة في الجدول"
        },
        pageLength: 10,
        order: [[1, 'asc']],
        drawCallback: function() {
            // Restore checkbox states after redraw
            restoreCheckboxStates();
        }
    });

    // Handle target type change
    $('input[name="target_type"]').on('change', function() {
        const target = $(this).val();
        updateTargetUI(target);
        // Auto-calculate recipients when target changes
        previewRecipients();
    });

    // Initialize UI based on current selection
    const currentTarget = $('input[name="target_type"]:checked').val();
    updateTargetUI(currentTarget);

    // Auto-calculate on page load
    previewRecipients();

    // Handle filter changes (including device filter)
    $('#stream_id, #year_id, #filterWithDevices').on('change', function() {
        if (usersTable) {
            usersTable.ajax.reload();
        }
        // Auto-calculate recipients when filters change
        previewRecipients();
    });

    // Live preview
    $('input[name="title_ar"], textarea[name="body_ar"]').on('input', function() {
        updatePreview();
    });

    // Handle checkbox changes in table
    $('#usersTable').on('change', '.user-checkbox', function() {
        const userId = $(this).val();
        if ($(this).is(':checked')) {
            if (!selectedUserIds.includes(userId)) {
                selectedUserIds.push(userId);
            }
        } else {
            selectedUserIds = selectedUserIds.filter(id => id !== userId);
        }
        updateSelectedCount();
    });

    // Select all checkbox
    $('#selectAllCheckbox').on('change', function() {
        const isChecked = $(this).is(':checked');
        $('.user-checkbox').prop('checked', isChecked).trigger('change');
    });

    // Update form with selected user IDs before submit
    $('#broadcastForm').on('submit', function(e) {
        // Remove existing hidden inputs for user_ids
        $('input[name="user_ids[]"]').remove();

        // Add hidden inputs for selected users
        if ($('input[name="target_type"]:checked').val() === 'selected') {
            selectedUserIds.forEach(id => {
                $('<input>').attr({
                    type: 'hidden',
                    name: 'user_ids[]',
                    value: id
                }).appendTo('#broadcastForm');
            });
        }
    });
});

function updateTargetUI(target) {
    // Update active state
    $('.target-option').removeClass('active');
    $(`.target-option[data-target="${target}"]`).addClass('active');

    // Hide all filters
    $('#streamFilter, #yearFilter, #usersTableContainer').addClass('hidden');

    // Show relevant filter
    switch(target) {
        case 'stream':
            $('#streamFilter').removeClass('hidden');
            break;
        case 'year':
            $('#yearFilter').removeClass('hidden');
            break;
        case 'selected':
            $('#usersTableContainer').removeClass('hidden');
            if (usersTable) {
                // Reload data and adjust columns (needed when table was hidden)
                usersTable.ajax.reload();
                usersTable.columns.adjust().draw();
            }
            break;
    }
}

function updatePreview() {
    const title = $('input[name="title_ar"]').val() || 'عنوان الإشعار';
    const body = $('textarea[name="body_ar"]').val() || 'نص الإشعار سيظهر هنا...';
    $('#previewTitle').text(title);
    $('#previewBody').text(body);
}

function previewRecipients() {
    const targetType = $('input[name="target_type"]:checked').val();
    const data = {
        target_type: targetType,
        stream_id: $('#stream_id').val(),
        year_id: $('#year_id').val(),
        user_ids: selectedUserIds,
        _token: '{{ csrf_token() }}'
    };

    // Show loading state on count displays
    $('#recipientsCount').html('<i class="fas fa-spinner fa-spin text-sm"></i>');
    $('#devicesCount').html('<i class="fas fa-spinner fa-spin text-sm"></i>');

    $.post('{{ route('admin.notifications.broadcast.preview') }}', data)
        .done(function(response) {
            if (response.success) {
                $('#recipientsCount').text(response.recipients_count);
                $('#devicesCount').text(response.devices_count);
            }
        })
        .fail(function(xhr) {
            console.error('Preview failed:', xhr.status, xhr.responseText);
            $('#recipientsCount').text('--');
            $('#devicesCount').text('--');
        });
}

function selectAllUsers() {
    $('.user-checkbox').prop('checked', true).trigger('change');
}

function deselectAllUsers() {
    $('.user-checkbox').prop('checked', false).trigger('change');
    selectedUserIds = [];
    updateSelectedCount();
}

function restoreCheckboxStates() {
    $('.user-checkbox').each(function() {
        const userId = $(this).val();
        if (selectedUserIds.includes(userId)) {
            $(this).prop('checked', true);
        }
    });
}

function updateSelectedCount() {
    // Use debounce for auto-preview when selecting users
    clearTimeout(previewDebounceTimer);
    previewDebounceTimer = setTimeout(function() {
        previewRecipients();
    }, 500);
}
</script>
@endpush
