<div class="flex gap-2">
    <a href="{{ route('admin.users.show', $user) }}"
       class="text-blue-600 hover:text-blue-900"
       title="عرض التفاصيل">
        <i class="fas fa-eye"></i>
    </a>

    @php
        $isBanned = isset($user->banned_at) && $user->banned_at !== null;
    @endphp

    @if($user->is_active && !$isBanned)
        <form action="{{ route('admin.users.toggle-status', $user) }}"
              method="POST"
              class="inline">
            @csrf
            <button type="submit"
                    class="text-yellow-600 hover:text-yellow-900"
                    title="تعطيل">
                <i class="fas fa-ban"></i>
            </button>
        </form>
    @else
        <form action="{{ route('admin.users.toggle-status', $user) }}"
              method="POST"
              class="inline">
            @csrf
            <button type="submit"
                    class="text-green-600 hover:text-green-900"
                    title="تفعيل">
                <i class="fas fa-check-circle"></i>
            </button>
        </form>
    @endif

    <form action="{{ route('admin.users.reset-password', $user) }}"
          method="POST"
          class="inline">
        @csrf
        <button type="submit"
                class="text-indigo-600 hover:text-indigo-900"
                title="إعادة تعيين كلمة المرور">
            <i class="fas fa-key"></i>
        </button>
    </form>
</div>
