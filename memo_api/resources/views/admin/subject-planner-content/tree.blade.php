@extends('layouts.admin')

@section('title', 'العرض الشجري - محتوى مخطط المادة')
@section('page-title', 'العرض الشجري')
@section('page-description', 'عرض هرمي لمحتوى مخطط المادة')

@push('styles')
<style>
    .tree-item {
        border-right: 3px solid #e5e7eb;
        transition: all 0.2s ease;
        cursor: grab;
    }
    .tree-item:hover {
        background-color: #f9fafb;
    }
    .tree-item:active {
        cursor: grabbing;
    }
    .tree-item.level-learning_axis { border-right-color: #3b82f6; }
    .tree-item.level-unit { border-right-color: #22c55e; }
    .tree-item.level-topic { border-right-color: #eab308; }
    .tree-item.level-subtopic { border-right-color: #f97316; }
    .tree-item.level-learning_objective { border-right-color: #a855f7; }

    .tree-children {
        margin-right: 1.5rem;
        border-right: 1px dashed #d1d5db;
        min-height: 10px;
    }

    .expand-btn {
        width: 24px;
        height: 24px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 4px;
        transition: all 0.2s ease;
    }
    .expand-btn:hover {
        background-color: #e5e7eb;
    }

    .sortable-ghost {
        opacity: 0.4;
        background-color: #dbeafe;
    }
    .sortable-chosen {
        background-color: #eff6ff;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    }
    .sortable-drag {
        opacity: 1;
        background-color: #fff;
        box-shadow: 0 8px 25px rgba(0,0,0,0.2);
    }

    /* Drop zone indicator */
    .tree-item.drop-target {
        border: 2px dashed #3b82f6;
        background-color: #eff6ff;
    }

    /* Drag handle indicator */
    .drag-handle {
        cursor: grab;
        padding: 4px;
        color: #9ca3af;
        transition: color 0.2s;
    }
    .drag-handle:hover {
        color: #4b5563;
    }
    .drag-handle:active {
        cursor: grabbing;
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

    <!-- Header Actions -->
    <div class="flex justify-between items-center mb-6">
        <div>
            <h1 class="text-2xl font-bold text-gray-800">العرض الشجري</h1>
            <p class="text-gray-600 mt-1">عرض هرمي للمحتوى مع إمكانية التوسيع والطي</p>
        </div>
        <div class="flex gap-3">
            <a href="{{ route('admin.subject-planner-content.index') }}"
               class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded-lg shadow-md hover:shadow-lg transition-all duration-200 font-medium">
                <i class="fas fa-list mr-2"></i>
                القائمة المسطحة
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

        <form method="GET" action="{{ route('admin.subject-planner-content.tree') }}" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-6 gap-4">
            <!-- Phase Filter -->
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">المرحلة</label>
                <select name="phase_id" id="phase_filter" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                    <option value="">كل المراحل</option>
                    @foreach($phases as $phase)
                    <option value="{{ $phase->id }}" {{ request('phase_id') == $phase->id ? 'selected' : '' }}>
                        {{ $phase->name_ar }}
                    </option>
                    @endforeach
                </select>
            </div>

            <!-- Year Filter -->
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">السنة</label>
                <select name="year_id" id="year_filter" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500" {{ !request('phase_id') ? 'disabled' : '' }}>
                    <option value="">كل السنوات</option>
                </select>
            </div>

            <!-- Stream Filter -->
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">الشعبة</label>
                <select name="stream_id" id="stream_filter" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500" {{ !request('year_id') ? 'disabled' : '' }}>
                    <option value="">كل الشعب</option>
                </select>
            </div>

            <!-- Subject Filter (depends on Stream) -->
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">
                    <i class="fas fa-book text-indigo-600 mr-1"></i>
                    المادة
                </label>
                <select name="subject_id" id="subject_filter" class="w-full px-4 py-2 border-2 border-indigo-300 rounded-lg focus:ring-2 focus:ring-indigo-500 bg-indigo-50" {{ !request('stream_id') ? 'disabled' : '' }}>
                    <option value="">كل المواد</option>
                </select>
            </div>

            <!-- Filter Button -->
            <div class="flex items-end">
                <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition">
                    <i class="fas fa-search mr-2"></i>
                    تصفية
                </button>
            </div>
        </form>
    </div>

    <!-- Level Legend -->
    <div class="bg-white rounded-xl shadow-sm p-4 mb-6">
        <div class="flex flex-wrap gap-4 items-center">
            <span class="text-sm font-semibold text-gray-700">دليل المستويات:</span>
            @foreach($levels as $key => $label)
            @php
                $colorClasses = [
                    'learning_axis' => 'bg-blue-100 text-blue-800 border-blue-300',
                    'unit' => 'bg-green-100 text-green-800 border-green-300',
                    'topic' => 'bg-yellow-100 text-yellow-800 border-yellow-300',
                    'subtopic' => 'bg-orange-100 text-orange-800 border-orange-300',
                    'learning_objective' => 'bg-purple-100 text-purple-800 border-purple-300',
                ];
            @endphp
            <span class="px-3 py-1 text-xs rounded-full border {{ $colorClasses[$key] ?? 'bg-gray-100 text-gray-800' }}">
                {{ $label }}
            </span>
            @endforeach
        </div>
    </div>

    <!-- Tree View -->
    <div class="bg-white rounded-xl shadow-sm">
        <div class="p-6 border-b flex justify-between items-center">
            <h3 class="text-lg font-bold text-gray-800">
                <i class="fas fa-sitemap text-blue-600 mr-2"></i>
                هيكل المحتوى
            </h3>
            <div class="flex gap-2">
                <button type="button" id="expand_all" class="text-sm bg-gray-100 hover:bg-gray-200 px-3 py-1 rounded transition">
                    <i class="fas fa-expand-arrows-alt mr-1"></i>
                    توسيع الكل
                </button>
                <button type="button" id="collapse_all" class="text-sm bg-gray-100 hover:bg-gray-200 px-3 py-1 rounded transition">
                    <i class="fas fa-compress-arrows-alt mr-1"></i>
                    طي الكل
                </button>
            </div>
        </div>

        <div class="p-6">
            @if($rootItems->count() > 0)
            <div id="tree-container" class="space-y-2">
                @foreach($rootItems as $item)
                    @include('admin.subject-planner-content.partials.tree-item', ['item' => $item, 'depth' => 0])
                @endforeach
            </div>
            @else
            <div class="text-center py-12">
                <i class="fas fa-folder-open text-gray-300 text-5xl mb-4"></i>
                <p class="text-gray-500 mb-4">لا يوجد محتوى مطابق للمعايير المحددة</p>
                <a href="{{ route('admin.subject-planner-content.create') }}"
                   class="inline-flex items-center bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition">
                    <i class="fas fa-plus mr-2"></i>
                    إضافة محتوى جديد
                </a>
            </div>
            @endif
        </div>
    </div>

</div>

@push('scripts')
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sortablejs@1.15.0/Sortable.min.js"></script>

<script>
$(document).ready(function() {
    // Cascading dropdowns: Phase -> Year -> Stream -> Subject
    const phaseFilter = $('#phase_filter');
    const yearFilter = $('#year_filter');
    const streamFilter = $('#stream_filter');
    const subjectFilter = $('#subject_filter');

    phaseFilter.on('change', function() {
        const phaseId = $(this).val();
        yearFilter.html('<option value="">جاري التحميل...</option>').prop('disabled', true);
        streamFilter.html('<option value="">اختر السنة أولاً</option>').prop('disabled', true);
        subjectFilter.html('<option value="">اختر الشعبة أولاً</option>').prop('disabled', true);

        if (!phaseId) {
            yearFilter.html('<option value="">اختر المرحلة أولاً</option>');
            return;
        }

        $.get(`/admin/subject-planner-content/ajax/years/${phaseId}`, function(years) {
            yearFilter.html('<option value="">كل السنوات</option>');
            years.forEach(function(year) {
                yearFilter.append(`<option value="${year.id}">${year.name_ar}</option>`);
            });
            yearFilter.prop('disabled', false);
        });
    });

    yearFilter.on('change', function() {
        const yearId = $(this).val();
        streamFilter.html('<option value="">جاري التحميل...</option>').prop('disabled', true);
        subjectFilter.html('<option value="">اختر الشعبة أولاً</option>').prop('disabled', true);

        if (!yearId) {
            streamFilter.html('<option value="">اختر السنة أولاً</option>');
            return;
        }

        $.get(`/admin/subject-planner-content/ajax/streams/${yearId}`, function(streams) {
            streamFilter.html('<option value="">كل الشعب</option>');
            streams.forEach(function(stream) {
                streamFilter.append(`<option value="${stream.id}">${stream.name_ar}</option>`);
            });
            streamFilter.prop('disabled', false);
        });
    });

    streamFilter.on('change', function() {
        const streamId = $(this).val();
        subjectFilter.html('<option value="">جاري التحميل...</option>').prop('disabled', true);

        if (!streamId) {
            subjectFilter.html('<option value="">اختر الشعبة أولاً</option>');
            return;
        }

        $.get(`/admin/subject-planner-content/ajax/subjects/${streamId}`, function(subjects) {
            subjectFilter.html('<option value="">كل المواد</option>');
            subjects.forEach(function(subject) {
                subjectFilter.append(`<option value="${subject.id}">${subject.name_ar}</option>`);
            });
            subjectFilter.prop('disabled', false);
        });
    });

    // Load initial values for cascading filters if set
    @if(request('phase_id'))
        $.get(`/admin/subject-planner-content/ajax/years/{{ request('phase_id') }}`, function(years) {
            yearFilter.html('<option value="">كل السنوات</option>');
            years.forEach(function(year) {
                yearFilter.append(`<option value="${year.id}" ${year.id == {{ request('year_id', 0) }} ? 'selected' : ''}>${year.name_ar}</option>`);
            });
            yearFilter.prop('disabled', false);

            @if(request('year_id'))
                $.get(`/admin/subject-planner-content/ajax/streams/{{ request('year_id') }}`, function(streams) {
                    streamFilter.html('<option value="">كل الشعب</option>');
                    streams.forEach(function(stream) {
                        streamFilter.append(`<option value="${stream.id}" ${stream.id == {{ request('stream_id', 0) }} ? 'selected' : ''}>${stream.name_ar}</option>`);
                    });
                    streamFilter.prop('disabled', false);

                    @if(request('stream_id'))
                        $.get(`/admin/subject-planner-content/ajax/subjects/{{ request('stream_id') }}`, function(subjects) {
                            subjectFilter.html('<option value="">كل المواد</option>');
                            subjects.forEach(function(subject) {
                                subjectFilter.append(`<option value="${subject.id}" ${subject.id == {{ request('subject_id', 0) }} ? 'selected' : ''}>${subject.name_ar}</option>`);
                            });
                            subjectFilter.prop('disabled', false);
                        });
                    @endif
                });
            @endif
        });
    @endif

    // Toggle expand/collapse
    $(document).on('click', '.expand-btn', function(e) {
        e.preventDefault();
        const $btn = $(this);
        const $item = $btn.closest('.tree-item');
        const $children = $item.find('> .tree-children');
        const itemId = $item.data('id');

        if ($children.length && $children.children().length > 0) {
            // Toggle existing children
            $children.slideToggle(200);
            $btn.find('i').toggleClass('fa-chevron-down fa-chevron-left');
        } else if ($btn.data('has-children')) {
            // Load children via AJAX
            $btn.html('<i class="fas fa-spinner fa-spin"></i>');

            $.get(`/admin/subject-planner-content/ajax/children/${itemId}`, function(children) {
                if (children.length > 0) {
                    let html = '<div class="tree-children space-y-2 mt-2">';
                    children.forEach(function(child) {
                        html += buildTreeItemHtml(child);
                    });
                    html += '</div>';

                    $item.append(html);
                    $btn.html('<i class="fas fa-chevron-down"></i>');

                    // Initialize sortable for new container
                    initSortable($item.find('> .tree-children')[0]);
                } else {
                    $btn.html('<i class="fas fa-minus text-gray-400"></i>');
                    $btn.removeClass('expand-btn');
                }
            });
        }
    });

    function buildTreeItemHtml(item) {
        const levelColors = {
            'learning_axis': 'blue',
            'unit': 'green',
            'topic': 'yellow',
            'subtopic': 'orange',
            'learning_objective': 'purple'
        };
        const colorClasses = {
            'blue': 'bg-blue-100 text-blue-800',
            'green': 'bg-green-100 text-green-800',
            'yellow': 'bg-yellow-100 text-yellow-800',
            'orange': 'bg-orange-100 text-orange-800',
            'purple': 'bg-purple-100 text-purple-800'
        };
        const color = levelColors[item.level] || 'gray';
        const colorClass = colorClasses[color] || 'bg-gray-100 text-gray-800';

        let html = `<div class="tree-item level-${item.level} p-3 rounded-lg bg-white border" data-id="${item.id}" data-order="${item.order}">`;
        html += '<div class="flex items-center justify-between">';
        html += '<div class="flex items-center gap-3">';

        // Drag Handle
        html += '<span class="drag-handle" title="اسحب لنقل العنصر"><i class="fas fa-grip-vertical"></i></span>';

        if (item.has_children) {
            html += `<button type="button" class="expand-btn" data-has-children="true"><i class="fas fa-chevron-left"></i></button>`;
        } else {
            html += '<span class="w-6"></span>';
        }

        html += `<span class="px-2 py-1 text-xs rounded-full ${colorClass}">${item.level_label}</span>`;

        // Subject Badge
        if (item.subject_name) {
            html += `<span class="px-2 py-1 text-xs rounded-full bg-indigo-100 text-indigo-800 border border-indigo-200"><i class="fas fa-book mr-1"></i>${item.subject_name}</span>`;
        }

        html += '<div>';
        html += `<span class="font-medium">${item.code ? item.code + ' - ' : ''}${item.title_ar}</span>`;

        if (item.is_bac_priority) {
            html += '<span class="mr-2 text-red-600"><i class="fas fa-star"></i></span>';
        }
        if (!item.is_published) {
            html += '<span class="mr-2 px-2 py-0.5 text-xs bg-gray-100 text-gray-600 rounded">مسودة</span>';
        }
        if (!item.is_active) {
            html += '<span class="mr-2 px-2 py-0.5 text-xs bg-red-100 text-red-600 rounded">غير نشط</span>';
        }

        html += '</div>';
        html += '</div>';

        // Actions
        html += '<div class="flex items-center gap-2">';
        html += `<a href="/admin/subject-planner-content/${item.id}" class="text-blue-600 hover:text-blue-800" title="عرض"><i class="fas fa-eye"></i></a>`;
        html += `<a href="/admin/subject-planner-content/${item.id}/edit" class="text-green-600 hover:text-green-800" title="تعديل"><i class="fas fa-edit"></i></a>`;
        html += `<a href="/admin/subject-planner-content/create?parent_id=${item.id}" class="text-purple-600 hover:text-purple-800" title="إضافة فرع"><i class="fas fa-plus-circle"></i></a>`;
        html += '</div>';

        html += '</div>';

        // Hidden children container for drop target
        html += '<div class="tree-children space-y-2 mt-2 hidden"></div>';

        html += '</div>';

        return html;
    }

    // Expand/Collapse All
    $('#expand_all').on('click', function() {
        $('.expand-btn').each(function() {
            const $btn = $(this);
            const $children = $btn.closest('.tree-item').find('> .tree-children');
            if ($children.length && $children.is(':hidden')) {
                $btn.click();
            } else if ($btn.data('has-children') && !$children.length) {
                $btn.click();
            }
        });
    });

    $('#collapse_all').on('click', function() {
        $('.tree-children').slideUp(200);
        $('.expand-btn i').removeClass('fa-chevron-down').addClass('fa-chevron-left');
    });

    // Initialize Sortable for reordering with full drag & drop support
    function initSortable(container) {
        if (!container) return;
        if (container.sortableInstance) return; // Prevent double initialization

        container.sortableInstance = new Sortable(container, {
            group: {
                name: 'nested-tree',
                pull: true,
                put: true
            },
            animation: 150,
            fallbackOnBody: true,
            swapThreshold: 0.65,
            ghostClass: 'sortable-ghost',
            chosenClass: 'sortable-chosen',
            dragClass: 'sortable-drag',
            handle: '.drag-handle', // Only drag from handle
            filter: '.expand-btn, .actions-btn, a', // Don't drag when clicking these
            preventOnFilter: false,
            onStart: function(evt) {
                // Show all hidden children containers as drop targets
                document.querySelectorAll('.tree-children.hidden').forEach(function(el) {
                    el.classList.remove('hidden');
                    el.style.minHeight = '40px';
                    el.style.border = '2px dashed #93c5fd';
                    el.style.borderRadius = '8px';
                    el.style.backgroundColor = '#eff6ff';
                });
                // Also expand visible children containers
                document.querySelectorAll('.tree-children:not(.hidden)').forEach(function(el) {
                    el.style.minHeight = '40px';
                });
            },
            onEnd: function(evt) {
                // Reset styles and hide empty containers
                document.querySelectorAll('.tree-children').forEach(function(el) {
                    el.style.minHeight = '10px';
                    el.style.border = '';
                    el.style.backgroundColor = '';
                    // Hide if empty
                    if (el.children.length === 0) {
                        el.classList.add('hidden');
                    }
                });

                const itemId = $(evt.item).data('id');
                const $newParent = $(evt.to).closest('.tree-item');
                const newParentId = $newParent.length ? $newParent.data('id') : null;
                const oldParentId = $(evt.from).closest('.tree-item').data('id') || null;

                // Collect new order for all items in the target container
                const items = [];
                $(evt.to).children('.tree-item').each(function(index) {
                    items.push({
                        id: $(this).data('id'),
                        order: index
                    });
                });

                // If moved to a different parent, update parent relationship
                if (evt.from !== evt.to || oldParentId !== newParentId) {
                    $.ajax({
                        url: '{{ route('admin.subject-planner-content.ajax.move') }}',
                        method: 'POST',
                        data: {
                            _token: '{{ csrf_token() }}',
                            item_id: itemId,
                            new_parent_id: newParentId,
                            items: items
                        },
                        success: function(response) {
                            if (response.success) {
                                showToast('تم نقل العنصر بنجاح', 'success');
                                // Update the expand button on old parent if it has no more children
                                if (oldParentId && $(evt.from).children('.tree-item').length === 0) {
                                    const $oldParentBtn = $(evt.from).siblings('.flex').find('.expand-btn');
                                    $oldParentBtn.html('<i class="fas fa-minus text-gray-400"></i>');
                                    $oldParentBtn.removeClass('expand-btn');
                                }
                                // Add expand button to new parent if it didn't have children before
                                if (newParentId) {
                                    const $newParentBtn = $newParent.find('> .flex .expand-btn, > .flex > .flex > span.w-6').first();
                                    if ($newParentBtn.hasClass('w-6')) {
                                        $newParentBtn.replaceWith('<button type="button" class="expand-btn" data-has-children="true"><i class="fas fa-chevron-down"></i></button>');
                                    }
                                }
                            } else {
                                showToast(response.message || 'حدث خطأ أثناء نقل العنصر', 'error');
                                location.reload();
                            }
                        },
                        error: function(xhr) {
                            showToast('حدث خطأ أثناء نقل العنصر', 'error');
                            location.reload();
                        }
                    });
                } else {
                    // Just reordering within the same parent
                    $.ajax({
                        url: '{{ route('admin.subject-planner-content.ajax.reorder') }}',
                        method: 'POST',
                        data: {
                            _token: '{{ csrf_token() }}',
                            items: items
                        },
                        success: function(response) {
                            showToast('تم تحديث الترتيب بنجاح', 'success');
                        },
                        error: function() {
                            showToast('حدث خطأ أثناء حفظ الترتيب', 'error');
                        }
                    });
                }
            }
        });
    }

    // Toast notification function
    function showToast(message, type = 'success') {
        const bgColor = type === 'success' ? 'bg-green-500' : 'bg-red-500';
        const icon = type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle';
        const $toast = $(`
            <div class="fixed bottom-4 left-4 ${bgColor} text-white px-6 py-3 rounded-lg shadow-lg z-50 flex items-center gap-2 animate-fade-in">
                <i class="fas ${icon}"></i>
                <span>${message}</span>
            </div>
        `);
        $('body').append($toast);
        setTimeout(() => {
            $toast.fadeOut(300, function() { $(this).remove(); });
        }, 3000);
    }

    // Initialize sortable for existing containers
    document.querySelectorAll('#tree-container, .tree-children').forEach(initSortable);

    // Re-initialize sortable when new children are loaded via AJAX
    $(document).on('DOMNodeInserted', '.tree-children', function() {
        initSortable(this);
    });
});
</script>
@endpush
@endsection
