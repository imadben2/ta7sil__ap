@extends('layouts.admin')

@section('title', $content->title_ar)
@section('page-title', 'تفاصيل المحتوى')
@section('page-description', $content->title_ar)

@push('styles')
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.7/css/jquery.dataTables.min.css">
<style>
    .dataTables_wrapper .dataTables_length select,
    .dataTables_wrapper .dataTables_filter input {
        padding: 0.5rem;
        border: 1px solid #d1d5db;
        border-radius: 0.5rem;
        font-size: 0.875rem;
    }
    table.dataTable thead th {
        background: #f9fafb;
        font-weight: 600;
        color: #374151;
        padding: 0.75rem;
        border-bottom: 2px solid #e5e7eb;
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

    <!-- Breadcrumb -->
    <div class="mb-6">
        <nav class="flex items-center text-sm text-gray-600 flex-wrap">
            <a href="{{ route('admin.subject-planner-content.index') }}" class="hover:text-blue-600">
                <i class="fas fa-home mr-1"></i>
                محتوى مخطط المادة
            </a>
            @foreach($breadcrumb as $item)
                <span class="mx-2">/</span>
                @if($loop->last)
                    <span class="text-gray-900 font-medium">{{ $item->title_ar }}</span>
                @else
                    <a href="{{ route('admin.subject-planner-content.show', $item) }}" class="hover:text-blue-600">
                        {{ $item->title_ar }}
                    </a>
                @endif
            @endforeach
        </nav>
    </div>

    <!-- Header -->
    <div class="flex items-start justify-between mb-6">
        <div>
            <div class="flex items-center gap-3 mb-2">
                @php
                    $colorClasses = [
                        'blue' => 'bg-blue-100 text-blue-800',
                        'green' => 'bg-green-100 text-green-800',
                        'yellow' => 'bg-yellow-100 text-yellow-800',
                        'orange' => 'bg-orange-100 text-orange-800',
                        'purple' => 'bg-purple-100 text-purple-800',
                    ];
                    $levelColor = $levelColors[$content->level] ?? 'gray';
                @endphp
                <span class="px-3 py-1 text-sm rounded-full {{ $colorClasses[$levelColor] ?? 'bg-gray-100 text-gray-800' }}">
                    {{ $levels[$content->level] ?? $content->level }}
                </span>
                @if($content->is_bac_priority)
                <span class="px-3 py-1 text-sm rounded-full bg-red-100 text-red-800">
                    <i class="fas fa-star mr-1"></i>
                    أولوية BAC
                </span>
                @endif
                @if($content->is_published)
                <span class="px-3 py-1 text-sm rounded-full bg-green-100 text-green-800">منشور</span>
                @else
                <span class="px-3 py-1 text-sm rounded-full bg-gray-100 text-gray-800">مسودة</span>
                @endif
                @if(!$content->is_active)
                <span class="px-3 py-1 text-sm rounded-full bg-red-100 text-red-800">غير نشط</span>
                @endif
            </div>
            <h1 class="text-3xl font-bold text-gray-800">
                @if($content->code)
                <span class="text-gray-500">{{ $content->code }} -</span>
                @endif
                {{ $content->title_ar }}
            </h1>
            @if($content->description_ar)
            <p class="text-gray-600 mt-2">{{ $content->description_ar }}</p>
            @endif
        </div>
        <div class="flex gap-3">
            <a href="{{ route('admin.subject-planner-content.create', ['parent_id' => $content->id]) }}"
               class="bg-purple-600 hover:bg-purple-700 text-white px-4 py-2 rounded-lg transition">
                <i class="fas fa-plus mr-2"></i>
                إضافة فرع
            </a>
            <a href="{{ route('admin.subject-planner-content.edit', $content) }}"
               class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg transition">
                <i class="fas fa-edit mr-2"></i>
                تعديل
            </a>
            <a href="{{ route('admin.subject-planner-content.index') }}"
               class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded-lg transition">
                <i class="fas fa-arrow-right mr-2"></i>
                العودة
            </a>
        </div>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
        <div class="bg-white rounded-xl shadow-sm p-6">
            <div class="flex items-center">
                <div class="p-3 bg-blue-100 rounded-lg">
                    <i class="fas fa-folder-tree text-blue-600 text-xl"></i>
                </div>
                <div class="mr-4">
                    <p class="text-sm text-gray-600">الفروع المباشرة</p>
                    <p class="text-2xl font-bold text-gray-800">{{ $stats['children_count'] }}</p>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm p-6">
            <div class="flex items-center">
                <div class="p-3 bg-green-100 rounded-lg">
                    <i class="fas fa-sitemap text-green-600 text-xl"></i>
                </div>
                <div class="mr-4">
                    <p class="text-sm text-gray-600">إجمالي العناصر الفرعية</p>
                    <p class="text-2xl font-bold text-gray-800">{{ $stats['descendants_count'] }}</p>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm p-6">
            <div class="flex items-center">
                <div class="p-3 bg-purple-100 rounded-lg">
                    <i class="fas fa-users text-purple-600 text-xl"></i>
                </div>
                <div class="mr-4">
                    <p class="text-sm text-gray-600">تقدم المستخدمين</p>
                    <p class="text-2xl font-bold text-gray-800">{{ $stats['user_progress_count'] }}</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Content Details -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <!-- Academic Context -->
        <div class="bg-white rounded-xl shadow-sm p-6">
            <h3 class="text-lg font-bold text-gray-800 mb-4 border-b pb-2">
                <i class="fas fa-graduation-cap text-blue-600 mr-2"></i>
                السياق الأكاديمي
            </h3>
            <div class="space-y-3">
                <div class="flex justify-between">
                    <span class="text-gray-600">المرحلة:</span>
                    <span class="font-medium">{{ $content->academicPhase?->name_ar ?? '-' }}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-600">السنة:</span>
                    <span class="font-medium">{{ $content->academicYear?->name_ar ?? '-' }}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-600">الشعبة:</span>
                    <span class="font-medium">{{ $content->academicStream?->name_ar ?? 'مادة مشتركة' }}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-600">المادة:</span>
                    <span class="font-medium">{{ $content->subject?->name_ar ?? '-' }}</span>
                </div>
            </div>
        </div>

        <!-- Study Metadata -->
        <div class="bg-white rounded-xl shadow-sm p-6">
            <h3 class="text-lg font-bold text-gray-800 mb-4 border-b pb-2">
                <i class="fas fa-book-reader text-blue-600 mr-2"></i>
                معلومات الدراسة
            </h3>
            <div class="space-y-3">
                <div class="flex justify-between">
                    <span class="text-gray-600">نوع المحتوى:</span>
                    <span class="font-medium">
                        @switch($content->content_type)
                            @case('theory') نظري @break
                            @case('exercise') تمارين @break
                            @case('review') مراجعة @break
                            @case('memorization') حفظ @break
                            @case('practice') تطبيق @break
                            @case('exam_prep') تحضير للامتحان @break
                            @default -
                        @endswitch
                    </span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-600">الصعوبة:</span>
                    <span class="font-medium">
                        @switch($content->difficulty_level)
                            @case('easy') <span class="text-green-600">سهل</span> @break
                            @case('medium') <span class="text-yellow-600">متوسط</span> @break
                            @case('hard') <span class="text-red-600">صعب</span> @break
                            @default -
                        @endswitch
                    </span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-600">المدة المقدرة:</span>
                    <span class="font-medium">{{ $content->estimated_duration_minutes ? $content->estimated_duration_minutes . ' دقيقة' : '-' }}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-600">الترتيب:</span>
                    <span class="font-medium">{{ $content->order }}</span>
                </div>
            </div>
        </div>
    </div>

    <!-- Repetition Requirements & BAC Info -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <!-- Repetition Requirements -->
        <div class="bg-white rounded-xl shadow-sm p-6">
            <h3 class="text-lg font-bold text-gray-800 mb-4 border-b pb-2">
                <i class="fas fa-sync-alt text-blue-600 mr-2"></i>
                متطلبات التكرار
            </h3>
            <div class="grid grid-cols-2 gap-3">
                <div class="flex items-center gap-2">
                    <i class="fas {{ $content->requires_understanding ? 'fa-check-circle text-green-600' : 'fa-times-circle text-gray-400' }}"></i>
                    <span>يتطلب فهم</span>
                </div>
                <div class="flex items-center gap-2">
                    <i class="fas {{ $content->requires_review ? 'fa-check-circle text-green-600' : 'fa-times-circle text-gray-400' }}"></i>
                    <span>يتطلب مراجعة</span>
                </div>
                <div class="flex items-center gap-2">
                    <i class="fas {{ $content->requires_theory_practice ? 'fa-check-circle text-green-600' : 'fa-times-circle text-gray-400' }}"></i>
                    <span>تطبيق نظري</span>
                </div>
                <div class="flex items-center gap-2">
                    <i class="fas {{ $content->requires_exercise_practice ? 'fa-check-circle text-green-600' : 'fa-times-circle text-gray-400' }}"></i>
                    <span>تطبيق تمارين</span>
                </div>
            </div>
        </div>

        <!-- BAC Info -->
        <div class="bg-white rounded-xl shadow-sm p-6">
            <h3 class="text-lg font-bold text-gray-800 mb-4 border-b pb-2">
                <i class="fas fa-award text-blue-600 mr-2"></i>
                معلومات البكالوريا
            </h3>
            <div class="space-y-3">
                <div class="flex justify-between">
                    <span class="text-gray-600">أولوية:</span>
                    <span class="font-medium">
                        @if($content->is_bac_priority)
                        <span class="text-red-600"><i class="fas fa-star mr-1"></i>نعم</span>
                        @else
                        <span class="text-gray-500">لا</span>
                        @endif
                    </span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-600">تكرار الظهور:</span>
                    <span class="font-medium">{{ $content->bac_frequency }} مرة</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-600">سنوات الظهور:</span>
                    <span class="font-medium">
                        @if($content->bac_exam_years && count($content->bac_exam_years) > 0)
                            {{ implode(', ', $content->bac_exam_years) }}
                        @else
                            -
                        @endif
                    </span>
                </div>
            </div>
        </div>
    </div>

    <!-- Children List -->
    @if($stats['children_count'] > 0)
    <div class="bg-white rounded-xl shadow-sm overflow-hidden">
        <div class="p-6 border-b">
            <h3 class="text-lg font-bold text-gray-800">
                <i class="fas fa-folder-tree text-blue-600 mr-2"></i>
                الفروع ({{ $stats['children_count'] }})
            </h3>
        </div>
        <div class="p-6">
            <table id="children-table" class="w-full display" style="width:100%">
                <thead>
                    <tr>
                        <th class="text-right">العنوان</th>
                        <th class="text-right">المستوى</th>
                        <th class="text-right">الحالة</th>
                        <th class="text-right">الفروع</th>
                        <th class="text-right">الإجراءات</th>
                    </tr>
                </thead>
            </table>
        </div>
    </div>
    @else
    <div class="bg-white rounded-xl shadow-sm p-8 text-center">
        <i class="fas fa-folder-open text-gray-300 text-5xl mb-4"></i>
        <p class="text-gray-500 mb-4">لا توجد فروع لهذا العنصر</p>
        <a href="{{ route('admin.subject-planner-content.create', ['parent_id' => $content->id]) }}"
           class="inline-flex items-center bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition">
            <i class="fas fa-plus mr-2"></i>
            إضافة فرع جديد
        </a>
    </div>
    @endif

</div>

@if($stats['children_count'] > 0)
@push('scripts')
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>

<script>
$(document).ready(function() {
    $('#children-table').DataTable({
        processing: true,
        serverSide: true,
        ajax: '{{ route('admin.subject-planner-content.show', $content) }}',
        columns: [
            { data: 'title_info', name: 'title_ar' },
            { data: 'level_badge', name: 'level' },
            { data: 'status_badge', name: 'is_published' },
            { data: 'children_count', name: 'children_count' },
            { data: 'actions', name: 'actions', orderable: false, searchable: false }
        ],
        pageLength: 10,
        language: {
            url: '//cdn.datatables.net/plug-ins/1.13.7/i18n/ar.json',
            processing: '<i class="fas fa-spinner fa-spin"></i> جاري التحميل...'
        },
        order: [[0, 'asc']]
    });

    $(document).on('submit', '.delete-form', function(e) {
        if (!confirm('هل أنت متأكد من حذف هذا العنصر؟')) {
            e.preventDefault();
            return false;
        }
    });
});
</script>
@endpush
@endif
@endsection
