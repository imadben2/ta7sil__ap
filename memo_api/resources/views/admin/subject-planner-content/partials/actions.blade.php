<div class="flex items-center gap-2">
    <!-- View -->
    <a href="{{ route('admin.subject-planner-content.show', $content) }}"
       class="text-blue-600 hover:text-blue-800 transition-colors"
       title="عرض">
        <i class="fas fa-eye"></i>
    </a>

    <!-- Edit -->
    <a href="{{ route('admin.subject-planner-content.edit', $content) }}"
       class="text-green-600 hover:text-green-800 transition-colors"
       title="تعديل">
        <i class="fas fa-edit"></i>
    </a>

    <!-- Add Child -->
    <a href="{{ route('admin.subject-planner-content.create', ['parent_id' => $content->id]) }}"
       class="text-purple-600 hover:text-purple-800 transition-colors"
       title="إضافة فرع">
        <i class="fas fa-plus-circle"></i>
    </a>

    <!-- Toggle Publish -->
    <form action="{{ route('admin.subject-planner-content.toggle-publish', $content) }}" method="POST" class="inline">
        @csrf
        <button type="submit"
                class="{{ $content->is_published ? 'text-yellow-600 hover:text-yellow-800' : 'text-green-600 hover:text-green-800' }} transition-colors"
                title="{{ $content->is_published ? 'إلغاء النشر' : 'نشر' }}">
            <i class="fas {{ $content->is_published ? 'fa-eye-slash' : 'fa-check-circle' }}"></i>
        </button>
    </form>

    <!-- Toggle Active Status -->
    <form action="{{ route('admin.subject-planner-content.toggle-status', $content) }}" method="POST" class="inline">
        @csrf
        <button type="submit"
                class="{{ $content->is_active ? 'text-orange-600 hover:text-orange-800' : 'text-green-600 hover:text-green-800' }} transition-colors"
                title="{{ $content->is_active ? 'إلغاء التفعيل' : 'تفعيل' }}">
            <i class="fas {{ $content->is_active ? 'fa-toggle-on' : 'fa-toggle-off' }}"></i>
        </button>
    </form>

    <!-- Delete -->
    <form action="{{ route('admin.subject-planner-content.destroy', $content) }}" method="POST" class="inline delete-form">
        @csrf
        @method('DELETE')
        <button type="submit"
                class="text-red-600 hover:text-red-800 transition-colors"
                title="حذف">
            <i class="fas fa-trash"></i>
        </button>
    </form>
</div>
