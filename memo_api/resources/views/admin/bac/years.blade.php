@extends('layouts.admin')

@section('title', 'إدارة سنوات البكالوريا')
@section('page-title', 'إدارة سنوات البكالوريا')
@section('page-description', 'إضافة وإدارة سنوات البكالوريا المتاحة')

@section('content')
<div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
        <a href="{{ route('admin.bac.index') }}" class="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors">
            <i class="fas fa-arrow-right mr-2"></i>
            العودة
        </a>
    </div>

    <!-- Add New Year -->
    <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-6">
            <i class="fas fa-plus-circle text-purple-600 mr-2"></i>
            إضافة سنة جديدة
        </h3>

        <form method="POST" action="{{ route('admin.bac.years.store') }}" class="flex items-end gap-4">
            @csrf

            <div class="flex-1">
                <label class="block text-sm font-medium text-gray-700 mb-2">
                    السنة <span class="text-red-500">*</span>
                </label>
                <input type="number" name="year" required min="2000" max="2050" value="{{ old('year', date('Y')) }}"
                       class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                       placeholder="مثال: 2024">
                @error('year')
                    <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                @enderror
            </div>

            <div class="flex items-center">
                <label class="flex items-center cursor-pointer">
                    <input type="checkbox" name="is_active" value="1" checked class="form-checkbox h-5 w-5 text-purple-600 rounded">
                    <span class="mr-2 text-sm font-medium text-gray-700">نشطة</span>
                </label>
            </div>

            <button type="submit" class="px-6 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors">
                <i class="fas fa-plus mr-2"></i>
                إضافة
            </button>
        </form>
    </div>

    <!-- Years List -->
    <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-6">
            <i class="fas fa-list text-blue-600 mr-2"></i>
            قائمة السنوات ({{ $years->count() }})
        </h3>

        @if($years->count() > 0)
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                @foreach($years as $year)
                    <div class="border border-gray-200 rounded-lg p-4 hover:bg-gray-50 transition-colors">
                        <div class="flex items-center justify-between mb-3">
                            <div class="flex items-center gap-2">
                                <span class="text-2xl font-bold text-gray-900">{{ $year->year }}</span>
                                @if($year->is_active)
                                    <span class="px-2 py-1 text-xs font-semibold rounded bg-green-100 text-green-800">
                                        <i class="fas fa-check-circle"></i> نشطة
                                    </span>
                                @else
                                    <span class="px-2 py-1 text-xs font-semibold rounded bg-gray-100 text-gray-800">
                                        <i class="fas fa-times-circle"></i> غير نشطة
                                    </span>
                                @endif
                            </div>
                        </div>

                        <div class="text-sm text-gray-600 mb-4">
                            <i class="fas fa-file-alt mr-1"></i>
                            {{ $year->bacSubjects->count() }} موضوع
                        </div>

                        <div class="flex gap-2">
                            <form method="POST" action="{{ route('admin.bac.years.toggle-status', $year->id) }}" class="flex-1">
                                @csrf
                                <button type="submit" class="w-full px-3 py-1.5 {{ $year->is_active ? 'bg-gray-100 text-gray-700 hover:bg-gray-200' : 'bg-green-100 text-green-700 hover:bg-green-200' }} rounded transition-colors text-sm">
                                    <i class="fas fa-{{ $year->is_active ? 'pause' : 'play' }} mr-1"></i>
                                    {{ $year->is_active ? 'تعطيل' : 'تفعيل' }}
                                </button>
                            </form>

                            @if($year->bacSubjects->count() === 0)
                                <form method="POST" action="{{ route('admin.bac.years.destroy', $year->id) }}"
                                      onsubmit="return confirm('هل أنت متأكد من حذف هذه السنة؟')">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="px-3 py-1.5 bg-red-100 text-red-700 rounded hover:bg-red-200 transition-colors text-sm">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </form>
                            @endif
                        </div>
                    </div>
                @endforeach
            </div>
        @else
            <div class="text-center py-12">
                <i class="fas fa-calendar-times text-6xl text-gray-300 mb-4"></i>
                <p class="text-gray-500 text-lg">لا توجد سنوات مضافة</p>
            </div>
        @endif
    </div>
</div>
@endsection
