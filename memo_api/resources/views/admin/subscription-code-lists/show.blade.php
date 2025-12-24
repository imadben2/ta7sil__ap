@extends('layouts.admin')

@section('title', 'تفاصيل قائمة الأكواد')
@section('page-title', $list->name)

@push('styles')
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.7/css/jquery.dataTables.min.css">
<style>
    .dataTables_wrapper { direction: rtl; }
    table.dataTable thead th { text-align: right !important; }
    table.dataTable tbody td { text-align: right !important; }
</style>
@endpush

@section('content')
<div class="space-y-6" style="font-family: 'Cairo', sans-serif; direction: rtl;">
    <!-- Header -->
    <div class="bg-gradient-to-r from-indigo-600 to-purple-600 rounded-xl shadow-lg p-6">
        <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
            <div class="text-white">
                <h2 class="text-2xl font-bold mb-2">{{ $list->name }}</h2>
                <p class="text-indigo-100">عرض تفاصيل القائمة والأكواد المرتبطة بها</p>
            </div>
            <a href="{{ route('admin.subscription-code-lists.index') }}"
               class="bg-white text-indigo-600 hover:bg-indigo-50 px-6 py-3 rounded-lg flex items-center gap-2 transition-all shadow-md">
                <span>العودة للقوائم</span>
                <i class="fas fa-arrow-left"></i>
            </a>
        </div>
    </div>

    <!-- List Metadata -->
    <div class="bg-white rounded-xl shadow-md p-6">
        <h3 class="text-xl font-bold text-gray-900 mb-4">
            <i class="fas fa-info-circle text-indigo-600 mr-2"></i>
            معلومات القائمة
        </h3>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <div>
                <p class="text-sm text-gray-600 mb-1">نوع الكود</p>
                <p class="text-lg font-semibold text-gray-900">
                    @if($list->code_type === 'single_course')
                        <span class="text-blue-600">دورة واحدة</span>
                    @elseif($list->code_type === 'package')
                        <span class="text-purple-600">باقة</span>
                    @else
                        <span class="text-green-600">عام</span>
                    @endif
                </p>
            </div>

            @if($list->course)
            <div>
                <p class="text-sm text-gray-600 mb-1">الدورة</p>
                <p class="text-lg font-semibold text-gray-900">{{ $list->course->title_ar }}</p>
            </div>
            @endif

            @if($list->package)
            <div>
                <p class="text-sm text-gray-600 mb-1">الباقة</p>
                <p class="text-lg font-semibold text-gray-900">{{ $list->package->name_ar }}</p>
            </div>
            @endif

            <div>
                <p class="text-sm text-gray-600 mb-1">عدد الاستخدامات لكل كود</p>
                <p class="text-lg font-semibold text-gray-900">{{ $list->max_uses_per_code }}</p>
            </div>

            <div>
                <p class="text-sm text-gray-600 mb-1">تاريخ الانتهاء</p>
                <p class="text-lg font-semibold text-gray-900">
                    {{ $list->expires_at ? $list->expires_at->format('Y-m-d') : 'غير محدد' }}
                </p>
            </div>

            <div>
                <p class="text-sm text-gray-600 mb-1">تم الإنشاء بواسطة</p>
                <p class="text-lg font-semibold text-gray-900">{{ $list->creator->name }}</p>
            </div>

            <div>
                <p class="text-sm text-gray-600 mb-1">تاريخ الإنشاء</p>
                <p class="text-lg font-semibold text-gray-900">{{ $list->created_at->format('Y-m-d H:i') }}</p>
            </div>
        </div>
    </div>

    <!-- Statistics Cards -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-600 text-sm mb-1">إجمالي الأكواد</p>
                    <p class="text-2xl font-bold text-indigo-600">{{ $stats['total_codes'] }}</p>
                </div>
                <div class="w-12 h-12 bg-indigo-100 rounded-lg flex items-center justify-center">
                    <i class="fas fa-ticket-alt text-indigo-600 text-xl"></i>
                </div>
            </div>
        </div>
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-600 text-sm mb-1">الأكواد الصالحة</p>
                    <p class="text-2xl font-bold text-green-600">{{ $stats['valid_codes'] }}</p>
                </div>
                <div class="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                    <i class="fas fa-check-circle text-green-600 text-xl"></i>
                </div>
            </div>
        </div>
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-600 text-sm mb-1">الأكواد المستخدمة</p>
                    <p class="text-2xl font-bold text-orange-600">{{ $stats['used_codes'] }}</p>
                </div>
                <div class="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
                    <i class="fas fa-users text-orange-600 text-xl"></i>
                </div>
            </div>
        </div>
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-600 text-sm mb-1">المستخدمة بالكامل</p>
                    <p class="text-2xl font-bold text-red-600">{{ $stats['fully_used_codes'] }}</p>
                </div>
                <div class="w-12 h-12 bg-red-100 rounded-lg flex items-center justify-center">
                    <i class="fas fa-ban text-red-600 text-xl"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Codes Table -->
    <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">
            <i class="fas fa-list text-indigo-600 mr-2"></i>
            الأكواد في هذه القائمة
        </h3>

        <div class="overflow-x-auto">
            <table id="codes-table" class="min-w-full divide-y divide-gray-200 display responsive nowrap" style="width:100%">
                <thead class="bg-gray-50">
                    <tr>
                        <th>الكود</th>
                        <th>الاستخدامات</th>
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

<script>
$(document).ready(function() {
    $('#codes-table').DataTable({
        processing: true,
        serverSide: true,
        ajax: "{{ route('admin.subscription-code-lists.show', $list) }}",
        columns: [
            { data: 'code_display', name: 'code' },
            { data: 'usage', name: 'current_uses' },
            { data: 'status_badge', name: 'is_active' },
            { data: 'actions', name: 'actions', orderable: false, searchable: false }
        ],
        language: {
            "url": "//cdn.datatables.net/plug-ins/1.13.7/i18n/ar.json"
        },
        order: [[0, 'asc']],
        pageLength: 25
    });
});
</script>
@endpush
