<div class="flex items-center justify-center gap-2">
    <!-- View -->
    <a href="{{ route('admin.promos.show', $promo) }}"
       class="p-2 text-gray-500 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
       title="عرض">
        <i class="fas fa-eye"></i>
    </a>

    <!-- Edit -->
    <a href="{{ route('admin.promos.edit', $promo) }}"
       class="p-2 text-gray-500 hover:text-yellow-600 hover:bg-yellow-50 rounded-lg transition-colors"
       title="تعديل">
        <i class="fas fa-edit"></i>
    </a>

    <!-- Toggle Status -->
    <button onclick="toggleStatus({{ $promo->id }})"
            class="p-2 {{ $promo->is_active ? 'text-green-600 hover:bg-green-50' : 'text-gray-400 hover:bg-gray-50' }} rounded-lg transition-colors"
            title="{{ $promo->is_active ? 'تعطيل' : 'تفعيل' }}">
        <i class="fas {{ $promo->is_active ? 'fa-toggle-on' : 'fa-toggle-off' }}"></i>
    </button>

    <!-- Reset Clicks -->
    <button onclick="resetClicks({{ $promo->id }})"
            class="p-2 text-gray-500 hover:text-purple-600 hover:bg-purple-50 rounded-lg transition-colors"
            title="إعادة تعيين النقرات">
        <i class="fas fa-redo"></i>
    </button>

    <!-- Delete -->
    <button onclick="confirmDelete({{ $promo->id }})"
            class="p-2 text-gray-500 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors"
            title="حذف">
        <i class="fas fa-trash"></i>
    </button>
</div>
