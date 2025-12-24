@extends('layouts.admin')

@section('title', 'إعدادات إشعارات المستخدمين')

@section('content')
<div class="min-h-screen bg-gray-50">
    <div class="px-4 sm:px-6 lg:px-8 py-8">
        <!-- Header -->
        <div class="mb-8">
            <div class="flex justify-between items-center mb-4">
                <div>
                    <h1 class="text-3xl font-bold text-gray-900">إعدادات إشعارات المستخدمين</h1>
                    <p class="text-gray-600 mt-1">إدارة تفضيلات الإشعارات لكل مستخدم</p>
                </div>
                <a href="{{ route('admin.notifications.index') }}" class="bg-gray-600 hover:bg-gray-700 text-white px-6 py-3 rounded-lg shadow-md font-semibold">
                    <i class="fas fa-arrow-right ml-2"></i>
                    العودة
                </a>
            </div>
        </div>

        <!-- Success Message -->
        @if(session('success'))
        <div class="mb-6 bg-green-50 border-r-4 border-green-500 p-4 rounded">
            <div class="flex items-center">
                <i class="fas fa-check-circle text-green-500 ml-3"></i>
                <p class="text-green-800">{{ session('success') }}</p>
            </div>
        </div>
        @endif

        <!-- DataTable -->
        <div class="bg-white rounded-xl shadow-md overflow-hidden">
            <div class="p-6">
                <table id="users-table" class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase">المستخدم</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase">البريد الإلكتروني</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase">الحالة</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase">التفضيلات</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase">ساعات الهدوء</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase">الإجراءات</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Edit Settings Modal -->
<div id="editModal" class="hidden fixed inset-0 bg-gray-900 bg-opacity-50 z-50 overflow-y-auto">
    <div class="flex items-center justify-center min-h-screen p-4">
        <div class="bg-white rounded-2xl shadow-2xl max-w-4xl w-full max-h-[90vh] overflow-y-auto">
            <!-- Modal Header -->
            <div class="bg-gradient-to-r from-blue-600 to-blue-700 px-8 py-6 rounded-t-2xl">
                <div class="flex items-center justify-between">
                    <div class="flex items-center gap-4">
                        <div class="bg-white/20 p-3 rounded-full">
                            <i class="fas fa-user text-white text-2xl"></i>
                        </div>
                        <div>
                            <h3 class="text-2xl font-bold text-white" id="modalUserName"></h3>
                            <p class="text-blue-100" id="modalUserEmail"></p>
                        </div>
                    </div>
                    <button onclick="closeModal()" class="text-white hover:text-gray-200 transition-colors">
                        <i class="fas fa-times text-2xl"></i>
                    </button>
                </div>
            </div>

            <!-- Modal Body -->
            <form id="settingsForm" class="p-8">
                @csrf
                @method('PUT')
                <input type="hidden" id="userId" name="user_id">

                <div class="space-y-8">
                    <!-- Main Toggle -->
                    <div class="bg-gradient-to-r from-blue-50 to-indigo-50 border-2 border-blue-200 rounded-xl p-6">
                        <label class="flex items-center cursor-pointer">
                            <input type="checkbox" name="notifications_enabled" id="notifications_enabled" value="1" class="w-6 h-6 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
                            <span class="mr-4 text-lg font-bold text-gray-900">
                                <i class="fas fa-bell ml-2 text-blue-600"></i>
                                تفعيل جميع الإشعارات
                            </span>
                        </label>
                    </div>

                    <!-- Notification Types -->
                    <div>
                        <h4 class="text-xl font-bold text-gray-900 mb-4">
                            <i class="fas fa-list-check ml-2 text-indigo-600"></i>
                            أنواع الإشعارات
                        </h4>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <label class="flex items-center cursor-pointer bg-gray-50 hover:bg-gray-100 p-4 rounded-lg transition-colors border-2 border-transparent hover:border-blue-200">
                                <input type="checkbox" name="study_reminders" value="1" class="w-5 h-5 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
                                <span class="mr-3 text-sm font-semibold text-gray-900">
                                    <i class="fas fa-book-reader ml-2 text-blue-600"></i>
                                    تذكير الدراسة
                                </span>
                            </label>

                            <label class="flex items-center cursor-pointer bg-gray-50 hover:bg-gray-100 p-4 rounded-lg transition-colors border-2 border-transparent hover:border-red-200">
                                <input type="checkbox" name="exam_reminders" value="1" class="w-5 h-5 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
                                <span class="mr-3 text-sm font-semibold text-gray-900">
                                    <i class="fas fa-graduation-cap ml-2 text-red-600"></i>
                                    تنبيهات الامتحانات
                                </span>
                            </label>

                            <label class="flex items-center cursor-pointer bg-gray-50 hover:bg-gray-100 p-4 rounded-lg transition-colors border-2 border-transparent hover:border-green-200">
                                <input type="checkbox" name="daily_summary" value="1" class="w-5 h-5 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
                                <span class="mr-3 text-sm font-semibold text-gray-900">
                                    <i class="fas fa-calendar-day ml-2 text-green-600"></i>
                                    الملخص اليومي
                                </span>
                            </label>

                            <label class="flex items-center cursor-pointer bg-gray-50 hover:bg-gray-100 p-4 rounded-lg transition-colors border-2 border-transparent hover:border-purple-200">
                                <input type="checkbox" name="weekly_summary" value="1" class="w-5 h-5 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
                                <span class="mr-3 text-sm font-semibold text-gray-900">
                                    <i class="fas fa-calendar-week ml-2 text-purple-600"></i>
                                    الملخص الأسبوعي
                                </span>
                            </label>

                            <label class="flex items-center cursor-pointer bg-gray-50 hover:bg-gray-100 p-4 rounded-lg transition-colors border-2 border-transparent hover:border-yellow-200">
                                <input type="checkbox" name="motivational_quotes" value="1" class="w-5 h-5 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
                                <span class="mr-3 text-sm font-semibold text-gray-900">
                                    <i class="fas fa-trophy ml-2 text-yellow-600"></i>
                                    الإنجازات والتحفيز
                                </span>
                            </label>

                            <label class="flex items-center cursor-pointer bg-gray-50 hover:bg-gray-100 p-4 rounded-lg transition-colors border-2 border-transparent hover:border-indigo-200">
                                <input type="checkbox" name="course_updates" value="1" class="w-5 h-5 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
                                <span class="mr-3 text-sm font-semibold text-gray-900">
                                    <i class="fas fa-chalkboard-teacher ml-2 text-indigo-600"></i>
                                    تحديثات الدورات
                                </span>
                            </label>
                        </div>
                    </div>

                    <!-- Quiet Hours -->
                    <div>
                        <h4 class="text-xl font-bold text-gray-900 mb-4">
                            <i class="fas fa-moon ml-2 text-indigo-600"></i>
                            ساعات الهدوء
                        </h4>
                        <div class="bg-indigo-50 border-2 border-indigo-200 rounded-xl p-6">
                            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                                <label class="flex items-center cursor-pointer col-span-full">
                                    <input type="checkbox" name="quiet_hours_enabled" id="quiet_hours_enabled" value="1" class="w-5 h-5 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
                                    <span class="mr-3 text-sm font-bold text-gray-900">
                                        تفعيل ساعات الهدوء
                                    </span>
                                </label>

                                <div>
                                    <label class="block text-sm font-bold text-gray-700 mb-2">بداية الهدوء</label>
                                    <input type="time" name="quiet_start_time" id="quiet_start_time" class="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
                                </div>

                                <div>
                                    <label class="block text-sm font-bold text-gray-700 mb-2">نهاية الهدوء</label>
                                    <input type="time" name="quiet_end_time" id="quiet_end_time" class="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Modal Footer -->
                <div class="flex justify-end gap-4 mt-8 pt-6 border-t border-gray-200">
                    <button type="button" onclick="closeModal()" class="px-6 py-3 bg-gray-200 hover:bg-gray-300 text-gray-700 font-semibold rounded-lg transition-colors">
                        <i class="fas fa-times ml-2"></i>
                        إلغاء
                    </button>
                    <button type="submit" class="px-8 py-3 bg-blue-600 hover:bg-blue-700 text-white font-semibold rounded-lg shadow-md transition-colors">
                        <i class="fas fa-save ml-2"></i>
                        حفظ الإعدادات
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

@endsection

@push('styles')
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.7/css/jquery.dataTables.min.css">
@endpush

@push('scripts')
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>

<script>
$(document).ready(function() {
    // Initialize DataTable
    const table = $('#users-table').DataTable({
        processing: true,
        serverSide: true,
        ajax: '{{ route('admin.notifications.settings') }}',
        columns: [
            { data: 'name', name: 'name' },
            { data: 'email', name: 'email' },
            { data: 'status', name: 'status', orderable: false, searchable: false },
            { data: 'preferences', name: 'preferences', orderable: false, searchable: false },
            { data: 'quiet_hours', name: 'quiet_hours', orderable: false, searchable: false },
            { data: 'actions', name: 'actions', orderable: false, searchable: false }
        ],
        language: {
            url: '//cdn.datatables.net/plug-ins/1.13.7/i18n/ar.json'
        },
        pageLength: 25,
        order: [[0, 'asc']]
    });
});

// Open modal and load user settings
function editSettings(userId) {
    $.get(`{{ route('admin.notifications.users.settings.get', ':userId') }}`.replace(':userId', userId))
        .done(function(response) {
            if (response.success) {
                const user = response.user;
                const settings = response.settings;

                // Set user info
                $('#modalUserName').text(user.name);
                $('#modalUserEmail').text(user.email);
                $('#userId').val(user.id);

                // Set checkbox values
                $('#notifications_enabled').prop('checked', settings.notifications_enabled);
                $('input[name="study_reminders"]').prop('checked', settings.study_reminders);
                $('input[name="exam_reminders"]').prop('checked', settings.exam_reminders);
                $('input[name="daily_summary"]').prop('checked', settings.daily_summary);
                $('input[name="weekly_summary"]').prop('checked', settings.weekly_summary);
                $('input[name="motivational_quotes"]').prop('checked', settings.motivational_quotes);
                $('input[name="course_updates"]').prop('checked', settings.course_updates);
                $('#quiet_hours_enabled').prop('checked', settings.quiet_hours_enabled);
                $('#quiet_start_time').val(settings.quiet_start_time || '');
                $('#quiet_end_time').val(settings.quiet_end_time || '');

                // Show modal
                $('#editModal').removeClass('hidden');
            }
        })
        .fail(function() {
            alert('حدث خطأ أثناء تحميل البيانات');
        });
}

// Close modal
function closeModal() {
    $('#editModal').addClass('hidden');
    $('#settingsForm')[0].reset();
}

// Handle form submission
$('#settingsForm').on('submit', function(e) {
    e.preventDefault();

    const userId = $('#userId').val();
    const formData = new FormData(this);

    // Convert unchecked checkboxes to false
    const checkboxes = ['notifications_enabled', 'study_reminders', 'exam_reminders', 'daily_summary',
                        'weekly_summary', 'motivational_quotes', 'course_updates', 'quiet_hours_enabled'];

    checkboxes.forEach(name => {
        if (!formData.has(name)) {
            formData.append(name, '0');
        }
    });

    $.ajax({
        url: `{{ route('admin.notifications.users.settings.update', ':userId') }}`.replace(':userId', userId),
        method: 'POST',
        data: formData,
        processData: false,
        contentType: false,
        headers: {
            'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
        },
        success: function(response) {
            closeModal();
            $('#users-table').DataTable().ajax.reload();

            // Show success message
            const successMsg = `
                <div class="mb-6 bg-green-50 border-r-4 border-green-500 p-4 rounded">
                    <div class="flex items-center">
                        <i class="fas fa-check-circle text-green-500 ml-3"></i>
                        <p class="text-green-800">تم تحديث إعدادات الإشعارات بنجاح</p>
                    </div>
                </div>
            `;
            $('.px-4.sm\\:px-6.lg\\:px-8.py-8 > .mb-8').after(successMsg);
            setTimeout(() => $('.bg-green-50').fadeOut(), 3000);
        },
        error: function(xhr) {
            alert('حدث خطأ أثناء حفظ البيانات');
        }
    });
});

// Close modal when clicking outside
$('#editModal').on('click', function(e) {
    if (e.target.id === 'editModal') {
        closeModal();
    }
});
</script>
@endpush
