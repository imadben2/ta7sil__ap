@extends('layouts.admin')

@section('title', $subject->name_ar)
@section('page-title', $subject->name_ar)
@section('page-description', 'عرض تفاصيل المادة الدراسية')

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
        background: #9333ea !important;
        color: white !important;
        border: 1px solid #9333ea !important;
    }

    /* Filter Pills */
    .filter-pill {
        transition: all 0.2s ease;
    }
    .filter-pill:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
    }
    .filter-pill.active {
        background: linear-gradient(to right, #9333ea, #7c3aed) !important;
        color: white !important;
    }
</style>
@endpush

@section('content')
<div class="p-8">

    @if(session('success'))
    <div class="mb-6 bg-green-100 border-r-4 border-green-500 text-green-700 p-4 rounded">
        <div class="flex items-center">
            <i class="fas fa-check-circle mr-3"></i>
            <p>{{ session('success') }}</p>
        </div>
    </div>
    @endif

    <div class="flex gap-6">
        <!-- Main Content Area -->
        <div class="flex-1">
            <!-- Header Card -->
            <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
                <div class="flex justify-between items-start">
                    <div class="flex items-start flex-1">
                        @if($subject->color)
                        <div class="w-4 h-4 rounded-full mr-4 mt-1" style="background-color: {{ $subject->color }}"></div>
                        @endif

                        <div class="flex-1">
                            <h1 class="text-2xl font-bold text-gray-900 mb-2">
                                @if($subject->icon)
                                <i class="fas fa-{{ $subject->icon }} mr-2"></i>
                                @endif
                                {{ $subject->name_ar }}
                            </h1>

                            <div class="flex items-center gap-4 text-sm text-gray-600 mb-4">
                                @if($subject->academicStream)
                                    <div>
                                        <i class="fas fa-graduation-cap mr-1 text-blue-600"></i>
                                        <span>{{ $subject->academicStream->academicYear->academicPhase->name_ar }}</span>
                                    </div>
                                    <div>
                                        <i class="fas fa-calendar mr-1 text-green-600"></i>
                                        <span>{{ $subject->academicStream->academicYear->name_ar }}</span>
                                    </div>
                                    <div>
                                        <i class="fas fa-stream mr-1 text-purple-600"></i>
                                        <span>{{ $subject->academicStream->name_ar }}</span>
                                    </div>
                                @elseif($subject->academicYear)
                                    <div>
                                        <i class="fas fa-graduation-cap mr-1 text-blue-600"></i>
                                        <span>{{ $subject->academicYear->academicPhase->name_ar }}</span>
                                    </div>
                                    <div>
                                        <i class="fas fa-calendar mr-1 text-green-600"></i>
                                        <span>{{ $subject->academicYear->name_ar }}</span>
                                    </div>
                                    <div class="text-xs text-gray-500">(مادة مشتركة)</div>
                                @endif

                                <div>
                                    <i class="fas fa-calculator mr-1 text-orange-600"></i>
                                    <span>المعامل: {{ $subject->coefficient }}</span>
                                </div>
                            </div>

                            @if($subject->description_ar)
                            <p class="text-gray-700 border-t border-gray-200 pt-4">{{ $subject->description_ar }}</p>
                            @endif
                        </div>
                    </div>

                    <div class="flex gap-2">
                        <a href="{{ route('admin.subjects.edit', $subject) }}"
                           class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors">
                            <i class="fas fa-edit mr-2"></i>
                            تعديل
                        </a>
                        <form action="{{ route('admin.subjects.toggle-status', $subject) }}" method="POST" class="inline">
                            @csrf
                            <button type="submit"
                                    class="bg-{{ $subject->is_active ? 'yellow' : 'green' }}-600 hover:bg-{{ $subject->is_active ? 'yellow' : 'green' }}-700 text-white px-4 py-2 rounded-lg transition-colors">
                                <i class="fas fa-toggle-{{ $subject->is_active ? 'on' : 'off' }} mr-2"></i>
                                {{ $subject->is_active ? 'تعطيل' : 'تفعيل' }}
                            </button>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Statistics Cards -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
                <div class="bg-white rounded-lg shadow-sm p-6">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm text-gray-600">إجمالي المحتويات</p>
                            <p class="text-3xl font-bold text-blue-600 mt-2">{{ $stats['total_contents'] }}</p>
                        </div>
                        <div class="bg-blue-100 p-4 rounded-lg">
                            <i class="fas fa-file-alt text-3xl text-blue-600"></i>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-lg shadow-sm p-6">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm text-gray-600">المحتوى المنشور</p>
                            <p class="text-3xl font-bold text-green-600 mt-2">{{ $stats['published_contents'] }}</p>
                        </div>
                        <div class="bg-green-100 p-4 rounded-lg">
                            <i class="fas fa-check-circle text-3xl text-green-600"></i>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-lg shadow-sm p-6">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm text-gray-600">عدد الفصول</p>
                            <p class="text-3xl font-bold text-purple-600 mt-2">{{ $stats['total_chapters'] }}</p>
                        </div>
                        <div class="bg-purple-100 p-4 rounded-lg">
                            <i class="fas fa-bookmark text-3xl text-purple-600"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Chapters Section -->
            @if($subject->contentChapters->count() > 0)
            <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
                <div class="flex justify-between items-center mb-4">
                    <h2 class="text-xl font-semibold text-gray-800">
                        <i class="fas fa-bookmark mr-2 text-purple-600"></i>
                        الفصول
                    </h2>
                    <button onclick="toggleChapterForm()" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors text-sm">
                        <i class="fas fa-plus mr-2"></i>
                        إضافة فصل
                    </button>
                </div>

                <!-- Add Chapter Form (hidden by default) -->
                <div id="chapterForm" class="hidden mb-6 p-4 bg-gray-50 rounded-lg border border-gray-200">
                    <form action="{{ route('admin.chapters.store', $subject) }}" method="POST">
                        @csrf
                        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                            <div class="md:col-span-2">
                                <input type="text" name="title_ar" placeholder="عنوان الفصل" required
                                       class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                            </div>
                            <div>
                                <input type="number" name="order" placeholder="الترتيب" min="0"
                                       class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                            </div>
                        </div>
                        <div class="mt-3 flex gap-2">
                            <button type="submit" class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg transition-colors text-sm">
                                <i class="fas fa-save mr-2"></i>
                                حفظ
                            </button>
                            <button type="button" onclick="toggleChapterForm()" class="bg-gray-300 hover:bg-gray-400 text-gray-700 px-4 py-2 rounded-lg transition-colors text-sm">
                                إلغاء
                            </button>
                        </div>
                    </form>
                </div>

                <div class="space-y-2">
                    @foreach($subject->contentChapters as $chapter)
                    <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                        <div class="flex items-center flex-1">
                            <div class="bg-purple-100 text-purple-600 w-8 h-8 rounded-full flex items-center justify-center mr-3 text-sm font-semibold">
                                {{ $chapter->order }}
                            </div>
                            <span class="text-gray-900 font-medium">{{ $chapter->title_ar }}</span>
                        </div>
                        <div class="flex gap-2">
                            <button onclick="editChapter({{ $chapter->id }}, '{{ $chapter->title_ar }}', {{ $chapter->order }})"
                                    class="text-blue-600 hover:text-blue-800">
                                <i class="fas fa-edit"></i>
                            </button>
                            <form action="{{ route('admin.chapters.destroy', [$subject, $chapter]) }}" method="POST" class="inline"
                                  onsubmit="return confirm('هل أنت متأكد من حذف هذا الفصل؟')">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="text-red-600 hover:text-red-800">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </form>
                        </div>
                    </div>
                    @endforeach
                </div>
            </div>
            @else
            <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
                <div class="text-center py-8">
                    <i class="fas fa-bookmark text-5xl text-gray-300 mb-3"></i>
                    <p class="text-gray-500 mb-4">لا توجد فصول لهذه المادة</p>
                    <button onclick="toggleChapterForm()" class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg transition-colors">
                        <i class="fas fa-plus mr-2"></i>
                        إضافة أول فصل
                    </button>
                </div>

                <!-- Add Chapter Form (hidden by default) -->
                <div id="chapterForm" class="hidden mt-6 p-4 bg-gray-50 rounded-lg border border-gray-200">
                    <form action="{{ route('admin.chapters.store', $subject) }}" method="POST">
                        @csrf
                        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                            <div class="md:col-span-2">
                                <input type="text" name="title_ar" placeholder="عنوان الفصل" required
                                       class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                            </div>
                            <div>
                                <input type="number" name="order" placeholder="الترتيب" min="0"
                                       class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                            </div>
                        </div>
                        <div class="mt-3 flex gap-2">
                            <button type="submit" class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg transition-colors text-sm">
                                <i class="fas fa-save mr-2"></i>
                                حفظ
                            </button>
                            <button type="button" onclick="toggleChapterForm()" class="bg-gray-300 hover:bg-gray-400 text-gray-700 px-4 py-2 rounded-lg transition-colors text-sm">
                                إلغاء
                            </button>
                        </div>
                    </form>
                </div>
            </div>
            @endif

            <!-- Contents Section -->
            <div class="bg-white rounded-lg shadow-sm p-6">
                <div class="flex justify-between items-center mb-6">
                    <h2 class="text-xl font-semibold text-gray-800">
                        <i class="fas fa-file-alt mr-2 text-blue-600"></i>
                        المحتويات التعليمية
                    </h2>
                    <a href="{{ route('admin.contents.create') }}?subject_id={{ $subject->id }}"
                       class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors text-sm">
                        <i class="fas fa-plus mr-2"></i>
                        إضافة محتوى
                    </a>
                </div>

                <!-- Content Type Filters -->
                <div class="mb-6">
                    <h3 class="text-sm font-semibold text-gray-700 mb-3">
                        <i class="fas fa-filter mr-2"></i>
                        تصفية حسب النوع
                    </h3>

                    <div class="flex flex-wrap gap-2" id="content-type-filters">
                        <!-- All button -->
                        <button type="button"
                                class="filter-pill active px-4 py-2 rounded-full bg-gray-200 text-gray-800 font-semibold text-sm"
                                data-type="all">
                            <i class="fas fa-globe mr-1"></i>
                            الكل
                        </button>

                        @foreach($contentTypes as $type)
                        <button type="button"
                                class="filter-pill px-4 py-2 rounded-full bg-gray-100 hover:bg-gray-200 text-gray-700 font-semibold text-sm"
                                data-type="{{ $type->id }}">
                            <i class="fas fa-{{ $type->icon }} mr-1"></i>
                            {{ $type->name_ar }}
                        </button>
                        @endforeach
                    </div>
                </div>

                <!-- Future Enhancement: Additional Filters (Hidden for now) -->
                <div class="mb-6 hidden" id="advanced-filters">
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                        <!-- Difficulty Filter -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">مستوى الصعوبة</label>
                            <select id="filter-difficulty" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500">
                                <option value="">الكل</option>
                                <option value="easy">سهل</option>
                                <option value="medium">متوسط</option>
                                <option value="hard">صعب</option>
                            </select>
                        </div>

                        <!-- Status Filter -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">الحالة</label>
                            <select id="filter-status" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500">
                                <option value="">الكل</option>
                                <option value="published">منشور</option>
                                <option value="draft">مسودة</option>
                            </select>
                        </div>

                        <!-- Chapter Filter -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">الفصل</label>
                            <select id="filter-chapter" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500">
                                <option value="">الكل</option>
                                @foreach($subject->contentChapters as $chapter)
                                    <option value="{{ $chapter->id }}">{{ $chapter->title_ar }}</option>
                                @endforeach
                            </select>
                        </div>
                    </div>
                </div>

                <!-- DataTable -->
                <div class="overflow-x-auto">
                    <table id="contents-table" class="min-w-full divide-y divide-gray-200 display responsive nowrap" style="width:100%">
                        <thead class="bg-gray-50">
                            <tr>
                                <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">العنوان والفصل</th>
                                <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">النوع</th>
                                <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">الصعوبة</th>
                                <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">المشاهدات</th>
                                <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">الحالة</th>
                                <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">الإجراءات</th>
                            </tr>
                        </thead>
                        <tbody class="bg-white divide-y divide-gray-200">
                            <!-- DataTables will populate this -->
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Sidebar -->
        <div class="w-80">
            <!-- Quick Actions -->
            <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
                <h3 class="text-lg font-semibold text-gray-800 mb-4">
                    <i class="fas fa-bolt mr-2 text-orange-600"></i>
                    إجراءات سريعة
                </h3>

                <div class="space-y-2">
                    <a href="{{ route('admin.subjects.index') }}"
                       class="block text-center bg-gray-100 hover:bg-gray-200 text-gray-700 px-4 py-2 rounded-lg transition-colors">
                        <i class="fas fa-list mr-2"></i>
                        كل المواد
                    </a>

                    <a href="{{ route('admin.subjects.create') }}"
                       class="block text-center bg-blue-100 hover:bg-blue-200 text-blue-700 px-4 py-2 rounded-lg transition-colors">
                        <i class="fas fa-plus mr-2"></i>
                        إضافة مادة جديدة
                    </a>

                    <form action="{{ route('admin.subjects.destroy', $subject) }}" method="POST"
                          onsubmit="return confirm('هل أنت متأكد من حذف هذه المادة؟ سيتم حذف جميع المحتويات المرتبطة بها.')">
                        @csrf
                        @method('DELETE')
                        <button type="submit"
                                class="w-full bg-red-100 hover:bg-red-200 text-red-700 px-4 py-2 rounded-lg transition-colors">
                            <i class="fas fa-trash mr-2"></i>
                            حذف المادة
                        </button>
                    </form>
                </div>
            </div>

            <!-- Info Card -->
            <div class="bg-blue-50 rounded-lg p-4 border border-blue-200">
                <h4 class="font-semibold text-blue-900 mb-2">
                    <i class="fas fa-info-circle mr-1"></i>
                    معلومات
                </h4>
                <div class="text-xs text-blue-800 space-y-2">
                    @if($subject->created_at)
                    <div class="flex justify-between">
                        <span>تاريخ الإنشاء:</span>
                        <span>{{ $subject->created_at->format('Y-m-d') }}</span>
                    </div>
                    @endif
                    @if($subject->updated_at)
                    <div class="flex justify-between">
                        <span>آخر تحديث:</span>
                        <span>{{ $subject->updated_at->diffForHumans() }}</span>
                    </div>
                    @endif
                    <div class="flex justify-between">
                        <span>الترتيب:</span>
                        <span>{{ $subject->order }}</span>
                    </div>
                    <div class="flex justify-between">
                        <span>Slug:</span>
                        <span class="text-left" dir="ltr">{{ $subject->slug }}</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

</div>

<script>
function toggleChapterForm() {
    const form = document.getElementById('chapterForm');
    form.classList.toggle('hidden');
}

function editChapter(id, title, order) {
    // This would open an edit modal or inline edit form
    // For now, we can use a simple prompt
    const newTitle = prompt('عنوان الفصل الجديد:', title);
    if (newTitle && newTitle !== title) {
        // Submit update form via AJAX or create a form dynamically
        alert('سيتم إضافة وظيفة التعديل قريبًا');
    }
}
</script>

@push('scripts')
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/responsive/2.5.0/js/dataTables.responsive.min.js"></script>

<script>
$(document).ready(function() {
    // Store current content type filter
    let currentContentType = 'all';

    // Initialize DataTable
    var table = $('#contents-table').DataTable({
        processing: true,
        serverSide: true,
        ajax: {
            url: "{{ route('admin.subjects.show', $subject) }}",
            data: function(d) {
                // Add filter parameters
                if (currentContentType !== 'all') {
                    d.content_type_id = currentContentType;
                }

                // Future enhancement: add more filters
                d.difficulty = $('#filter-difficulty').val();
                d.status = $('#filter-status').val();
                d.chapter_id = $('#filter-chapter').val();
            }
        },
        columns: [
            { data: 'title_info', name: 'title_ar', orderable: true },
            { data: 'type_badge', name: 'contentType.name_ar', orderable: true },
            { data: 'difficulty_badge', name: 'difficulty_level', orderable: true },
            { data: 'views_count', name: 'views_count', orderable: true },
            { data: 'status_badge', name: 'is_published', orderable: true },
            { data: 'actions', name: 'actions', orderable: false, searchable: false }
        ],
        language: {
            "url": "//cdn.datatables.net/plug-ins/1.13.7/i18n/ar.json",
            "search": "بحث:",
            "lengthMenu": "عرض _MENU_ سجلات لكل صفحة",
            "info": "عرض _START_ إلى _END_ من أصل _TOTAL_ محتوى",
            "infoEmpty": "لا توجد محتويات",
            "infoFiltered": "(تمت التصفية من _MAX_ محتوى إجمالي)",
            "paginate": {
                "first": "الأول",
                "last": "الأخير",
                "next": "التالي",
                "previous": "السابق"
            },
            "processing": "جاري التحميل...",
            "zeroRecords": "لا توجد محتويات تطابق البحث"
        },
        order: [[0, 'asc']], // Sort by title ascending
        pageLength: 10,
        lengthMenu: [[5, 10, 25, 50, 100], [5, 10, 25, 50, 100]],
        responsive: true,
        autoWidth: false,
        drawCallback: function() {
            // Update info text after each draw
            console.log('Table redrawn');
        }
    });

    // Content Type Filter Pills Click Handler
    $('.filter-pill').on('click', function() {
        // Remove active class from all pills
        $('.filter-pill').removeClass('active')
            .removeClass('bg-gradient-to-r')
            .addClass('bg-gray-100');

        // Add active class to clicked pill
        $(this).addClass('active')
            .removeClass('bg-gray-100');

        // Update current filter
        currentContentType = $(this).data('type');

        // Reload table
        table.ajax.reload();
    });

    // Advanced Filters Change Handler (Future Enhancement)
    $('#filter-difficulty, #filter-status, #filter-chapter').on('change', function() {
        table.ajax.reload();
    });

    // Optional: Toggle Advanced Filters
    // Uncomment this section when you want to enable advanced filters
    /*
    let advancedFiltersVisible = false;

    $('<button type="button" class="text-sm text-blue-600 hover:text-blue-800 mb-3">' +
      '<i class="fas fa-sliders-h mr-1"></i>فلاتر متقدمة</button>')
        .insertBefore('#content-type-filters')
        .on('click', function() {
            advancedFiltersVisible = !advancedFiltersVisible;
            $('#advanced-filters').toggleClass('hidden');
            $(this).find('i').toggleClass('fa-sliders-h fa-times');
        });
    */
});
</script>
@endpush
@endsection
