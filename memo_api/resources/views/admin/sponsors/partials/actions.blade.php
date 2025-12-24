<div class="flex items-center justify-center gap-2">
    <!-- View -->
    <a href="{{ route('admin.sponsors.show', $sponsor) }}"
       class="w-9 h-9 rounded-lg bg-gray-100 hover:bg-gray-200 flex items-center justify-center transition-colors"
       title="عرض">
        <i class="fas fa-eye text-gray-600"></i>
    </a>

    <!-- Edit -->
    <a href="{{ route('admin.sponsors.edit', $sponsor) }}"
       class="w-9 h-9 rounded-lg bg-blue-100 hover:bg-blue-200 flex items-center justify-center transition-colors"
       title="تعديل">
        <i class="fas fa-edit text-blue-600"></i>
    </a>

    <!-- Toggle Status -->
    <button onclick="toggleStatus({{ $sponsor->id }})"
            class="w-9 h-9 rounded-lg {{ $sponsor->is_active ? 'bg-yellow-100 hover:bg-yellow-200' : 'bg-green-100 hover:bg-green-200' }} flex items-center justify-center transition-colors"
            title="{{ $sponsor->is_active ? 'تعطيل' : 'تفعيل' }}">
        <i class="fas {{ $sponsor->is_active ? 'fa-toggle-off text-yellow-600' : 'fa-toggle-on text-green-600' }}"></i>
    </button>

    <!-- Reset Clicks -->
    <button onclick="resetClicks({{ $sponsor->id }})"
            class="w-9 h-9 rounded-lg bg-purple-100 hover:bg-purple-200 flex items-center justify-center transition-colors"
            title="إعادة تعيين النقرات">
        <i class="fas fa-undo text-purple-600"></i>
    </button>

    <!-- Delete -->
    <button onclick="confirmDelete({{ $sponsor->id }})"
            class="w-9 h-9 rounded-lg bg-red-100 hover:bg-red-200 flex items-center justify-center transition-colors"
            title="حذف">
        <i class="fas fa-trash text-red-600"></i>
    </button>
</div>
