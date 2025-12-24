<div class="flex gap-2">
    <a href="{{ route('admin.subjects.show', $subject) }}"
       class="text-blue-600 hover:text-blue-900"
       title="عرض">
        <i class="fas fa-eye"></i>
    </a>
    <a href="{{ route('admin.subjects.edit', $subject) }}"
       class="text-green-600 hover:text-green-900"
       title="تعديل">
        <i class="fas fa-edit"></i>
    </a>
    <form action="{{ route('admin.subjects.toggle-status', $subject) }}"
          method="POST"
          class="inline">
        @csrf
        <button type="submit"
                class="text-yellow-600 hover:text-yellow-900"
                title="{{ $subject->is_active ? 'تعطيل' : 'تفعيل' }}">
            <i class="fas fa-{{ $subject->is_active ? 'toggle-on' : 'toggle-off' }}"></i>
        </button>
    </form>
    <form action="{{ route('admin.subjects.destroy', $subject) }}"
          method="POST"
          class="inline delete-form">
        @csrf
        @method('DELETE')
        <button type="submit"
                class="text-red-600 hover:text-red-900"
                title="حذف">
            <i class="fas fa-trash"></i>
        </button>
    </form>
</div>
