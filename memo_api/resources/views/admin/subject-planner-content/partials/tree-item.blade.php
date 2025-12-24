@php
    $colorClasses = [
        'learning_axis' => 'bg-blue-100 text-blue-800',
        'unit' => 'bg-green-100 text-green-800',
        'topic' => 'bg-yellow-100 text-yellow-800',
        'subtopic' => 'bg-orange-100 text-orange-800',
        'learning_objective' => 'bg-purple-100 text-purple-800',
    ];
    $levelColor = $colorClasses[$item->level] ?? 'bg-gray-100 text-gray-800';
    $hasChildren = $item->children->count() > 0;
@endphp

<div class="tree-item level-{{ $item->level }} p-3 rounded-lg bg-white border" data-id="{{ $item->id }}" data-order="{{ $item->order }}">
    <div class="flex items-center justify-between">
        <div class="flex items-center gap-3">
            <!-- Drag Handle -->
            <span class="drag-handle" title="اسحب لنقل العنصر">
                <i class="fas fa-grip-vertical"></i>
            </span>

            <!-- Expand/Collapse Button -->
            @if($hasChildren)
            <button type="button" class="expand-btn" data-has-children="true">
                <i class="fas fa-chevron-down"></i>
            </button>
            @else
            <span class="w-6"></span>
            @endif

            <!-- Level Badge -->
            <span class="px-2 py-1 text-xs rounded-full {{ $levelColor }}">
                {{ $levels[$item->level] ?? $item->level }}
            </span>

            <!-- Subject Badge -->
            @if($item->subject)
            <span class="px-2 py-1 text-xs rounded-full bg-indigo-100 text-indigo-800 border border-indigo-200">
                <i class="fas fa-book mr-1"></i>{{ $item->subject->name_ar }}
            </span>
            @endif

            <!-- Title -->
            <div>
                <span class="font-medium">
                    @if($item->code)
                    <span class="text-gray-500">{{ $item->code }} -</span>
                    @endif
                    {{ $item->title_ar }}
                </span>

                @if($item->is_bac_priority)
                <span class="mr-2 text-red-600"><i class="fas fa-star"></i></span>
                @endif

                @if(!$item->is_published)
                <span class="mr-2 px-2 py-0.5 text-xs bg-gray-100 text-gray-600 rounded">مسودة</span>
                @endif

                @if(!$item->is_active)
                <span class="mr-2 px-2 py-0.5 text-xs bg-red-100 text-red-600 rounded">غير نشط</span>
                @endif
            </div>
        </div>

        <!-- Actions -->
        <div class="flex items-center gap-2">
            <a href="{{ route('admin.subject-planner-content.show', $item) }}"
               class="text-blue-600 hover:text-blue-800 transition-colors"
               title="عرض">
                <i class="fas fa-eye"></i>
            </a>
            <a href="{{ route('admin.subject-planner-content.edit', $item) }}"
               class="text-green-600 hover:text-green-800 transition-colors"
               title="تعديل">
                <i class="fas fa-edit"></i>
            </a>
            <a href="{{ route('admin.subject-planner-content.create', ['parent_id' => $item->id]) }}"
               class="text-purple-600 hover:text-purple-800 transition-colors"
               title="إضافة فرع">
                <i class="fas fa-plus-circle"></i>
            </a>
        </div>
    </div>

    <!-- Children container (always present for drop target) -->
    <div class="tree-children space-y-2 mt-2 {{ !$hasChildren ? 'hidden' : '' }}">
        @foreach($item->children as $child)
            @include('admin.subject-planner-content.partials.tree-item', ['item' => $child, 'depth' => $depth + 1])
        @endforeach
    </div>
</div>
