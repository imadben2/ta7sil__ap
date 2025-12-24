@extends('layouts.admin')

@section('title', 'التقييمات والمراجعات')
@section('page-title', 'إدارة التقييمات')

@section('content')
<div class="space-y-6" style="font-family: 'Cairo', sans-serif; direction: rtl;">
    <!-- Enhanced Header with Gradient -->
    <div class="bg-gradient-to-r from-yellow-500 to-orange-500 rounded-xl shadow-lg p-6">
        <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
            <div class="text-white">
                <h2 class="text-2xl font-bold mb-2">إدارة تقييمات الدورات</h2>
                <p class="text-yellow-100">مراجعة وإدارة تقييمات الطلاب على الدورات التعليمية</p>
            </div>
            <div class="flex gap-3">
                <button onclick="window.location.reload()"
                        class="bg-white text-yellow-600 hover:bg-yellow-50 px-6 py-3 rounded-lg flex items-center gap-2 shadow-md font-semibold transition-all">
                    <i class="fas fa-sync-alt"></i>
                    <span>تحديث</span>
                </button>
            </div>
        </div>
    </div>

    <!-- Enhanced Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div class="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-blue-100 text-sm font-medium mb-1">إجمالي التقييمات</p>
                    <p class="text-4xl font-bold">{{ $stats['total'] }}</p>
                    <p class="text-blue-100 text-xs mt-2">جميع التقييمات</p>
                </div>
                <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center">
                    <i class="fas fa-star text-3xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-gradient-to-br from-yellow-500 to-orange-500 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-yellow-100 text-sm font-medium mb-1">التقييمات المعلقة</p>
                    <p class="text-4xl font-bold">{{ $stats['pending'] }}</p>
                    <p class="text-yellow-100 text-xs mt-2">بانتظار المراجعة</p>
                </div>
                <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center">
                    <i class="fas fa-clock text-3xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-gradient-to-br from-green-500 to-green-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-green-100 text-sm font-medium mb-1">التقييمات المقبولة</p>
                    <p class="text-4xl font-bold">{{ $stats['approved'] }}</p>
                    <p class="text-green-100 text-xs mt-2">تم الموافقة عليها</p>
                </div>
                <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center">
                    <i class="fas fa-check-circle text-3xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-gradient-to-br from-purple-500 to-pink-500 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-purple-100 text-sm font-medium mb-1">متوسط التقييم</p>
                    <p class="text-4xl font-bold">{{ $stats['average_rating'] }}</p>
                    <p class="text-purple-100 text-xs mt-2">من 5.0</p>
                </div>
                <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center">
                    <i class="fas fa-chart-line text-3xl"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Enhanced Filters -->
    <div class="bg-white rounded-xl shadow-md p-6">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">
                    <i class="fas fa-video text-gray-400 ml-1"></i>
                    الدورة
                </label>
                <select id="filterCourse" class="w-full px-4 py-2.5 border-2 border-gray-200 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500">
                    <option value="">جميع الدورات</option>
                    @foreach($courses as $course)
                        <option value="{{ $course->id }}">{{ $course->title_ar }}</option>
                    @endforeach
                </select>
            </div>

            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">
                    <i class="fas fa-star text-gray-400 ml-1"></i>
                    التقييم
                </label>
                <select id="filterRating" class="w-full px-4 py-2.5 border-2 border-gray-200 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500">
                    <option value="">جميع التقييمات</option>
                    <option value="5">5 نجوم</option>
                    <option value="4">4 نجوم</option>
                    <option value="3">3 نجوم</option>
                    <option value="2">2 نجوم</option>
                    <option value="1">1 نجمة</option>
                </select>
            </div>

            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">
                    <i class="fas fa-filter text-gray-400 ml-1"></i>
                    الحالة
                </label>
                <select id="filterStatus" class="w-full px-4 py-2.5 border-2 border-gray-200 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500">
                    <option value="">جميع الحالات</option>
                    <option value="pending">معلقة</option>
                    <option value="approved">مقبولة</option>
                </select>
            </div>

            <div class="flex items-end">
                <button onclick="resetFilters()" class="w-full bg-gray-100 hover:bg-gray-200 text-gray-700 px-4 py-2.5 rounded-lg font-semibold transition-all">
                    <i class="fas fa-redo ml-2"></i>إعادة تعيين
                </button>
            </div>
        </div>
    </div>

    <!-- DataTable -->
    <div class="bg-white rounded-xl shadow-md overflow-hidden">
        <div class="overflow-x-auto">
            <table id="reviewsTable" class="min-w-full divide-y divide-gray-200" style="width: 100%;">
                <thead class="bg-gradient-to-r from-gray-50 to-gray-100">
                    <tr>
                        <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">
                            <i class="fas fa-user text-blue-500 ml-1"></i>الطالب
                        </th>
                        <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">
                            <i class="fas fa-video text-blue-500 ml-1"></i>الدورة
                        </th>
                        <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">
                            <i class="fas fa-star text-yellow-500 ml-1"></i>التقييم
                        </th>
                        <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">
                            <i class="fas fa-comment text-purple-500 ml-1"></i>المراجعة
                        </th>
                        <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">
                            <i class="fas fa-toggle-on text-green-500 ml-1"></i>الحالة
                        </th>
                        <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">
                            <i class="fas fa-calendar text-orange-500 ml-1"></i>التاريخ
                        </th>
                        <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">
                            <i class="fas fa-cog text-gray-500 ml-1"></i>الإجراءات
                        </th>
                    </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                    <!-- DataTables will populate this -->
                </tbody>
            </table>
        </div>
    </div>
</div>

@push('styles')
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.7/css/jquery.dataTables.min.css">
<link rel="stylesheet" href="https://cdn.datatables.net/responsive/2.5.0/css/responsive.dataTables.min.css">
<style>
    /* Custom DataTables RTL Styling */
    .dataTables_wrapper {
        direction: rtl;
        font-family: 'Cairo', sans-serif;
    }

    .dataTables_filter input,
    .dataTables_length select {
        border: 2px solid #e5e7eb;
        border-radius: 0.5rem;
        padding: 0.5rem 1rem;
        font-family: 'Cairo', sans-serif;
    }

    .dataTables_filter input:focus,
    .dataTables_length select:focus {
        outline: none;
        border-color: #f59e0b;
        ring: 2px;
        ring-color: #fef3c7;
    }

    .dataTables_info,
    .dataTables_length label,
    .dataTables_filter label {
        font-weight: 600;
        color: #374151;
        font-family: 'Cairo', sans-serif;
    }

    .paginate_button {
        border-radius: 0.5rem !important;
        margin: 0 0.25rem !important;
        font-family: 'Cairo', sans-serif;
    }

    .paginate_button.current {
        background: linear-gradient(to bottom right, #f59e0b, #ea580c) !important;
        color: white !important;
        border: none !important;
    }

    table.dataTable tbody tr:hover {
        background-color: #fef3c7 !important;
    }

    .dataTables_wrapper .dataTables_paginate {
        padding-top: 1rem;
    }
</style>
@endpush

@push('scripts')
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/responsive/2.5.0/js/dataTables.responsive.min.js"></script>

<script>
$(document).ready(function() {
    var table = $('#reviewsTable').DataTable({
        processing: true,
        serverSide: true,
        ajax: {
            url: "{{ route('admin.course-reviews.index') }}",
            data: function (d) {
                d.course_id = $('#filterCourse').val();
                d.rating = $('#filterRating').val();
                d.status = $('#filterStatus').val();
            }
        },
        columns: [
            { data: 'user_name', name: 'user.name', orderable: true },
            { data: 'course_name', name: 'course.title_ar', orderable: true },
            { data: 'rating_stars', name: 'rating', orderable: true },
            { data: 'review_text', name: 'review_text_ar', orderable: false },
            { data: 'status', name: 'is_approved', orderable: true },
            { data: 'created_date', name: 'created_at', orderable: true },
            { data: 'actions', name: 'actions', orderable: false, searchable: false }
        ],
        order: [[5, 'desc']], // Sort by date descending
        pageLength: 25,
        responsive: true,
        language: {
            url: '//cdn.datatables.net/plug-ins/1.13.7/i18n/ar.json',
            search: "_INPUT_",
            searchPlaceholder: "ابحث عن تقييم...",
            lengthMenu: "عرض _MENU_ تقييم",
            info: "عرض _START_ إلى _END_ من _TOTAL_ تقييم",
            infoEmpty: "لا توجد تقييمات",
            infoFiltered: "(تم التصفية من _MAX_ إجمالي)",
            paginate: {
                first: "الأول",
                last: "الأخير",
                next: "التالي",
                previous: "السابق"
            },
            processing: '<div class="flex items-center justify-center"><i class="fas fa-spinner fa-spin text-yellow-500 text-3xl"></i></div>'
        }
    });

    // Filter functionality
    $('#filterCourse, #filterRating, #filterStatus').on('change', function() {
        table.ajax.reload();
    });

    // Reset filters
    window.resetFilters = function() {
        $('#filterCourse').val('');
        $('#filterRating').val('');
        $('#filterStatus').val('');
        table.ajax.reload();
    };

    // Reload on form submission
    $(document).on('submit', 'form', function(e) {
        setTimeout(function() {
            table.ajax.reload();
        }, 1000);
    });
});
</script>
@endpush
@endsection
