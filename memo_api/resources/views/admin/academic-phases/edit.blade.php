@extends('layouts.admin')

@section('title', 'تعديل مرحلة دراسية')

@section('content')
<div class="p-6 bg-gray-50 min-h-screen">
    <!-- Header -->
    <div class="mb-8">
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-3xl font-bold text-gray-900 flex items-center">
                    <i class="fas fa-edit text-orange-600 mr-3"></i>
                    تعديل المرحلة: {{ $academicPhase->name_ar }}
                </h1>
                <p class="text-gray-600 mt-2">تحديث معلومات المرحلة الدراسية</p>
            </div>
            <a href="{{ route('admin.academic-phases.index') }}" class="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors flex items-center gap-2">
                <i class="fas fa-arrow-right"></i>
                <span>رجوع</span>
            </a>
        </div>
    </div>

    <!-- Form -->
    <div class="bg-white rounded-xl shadow-md p-8">
        <form action="{{ route('admin.academic-phases.update', $academicPhase->id) }}" method="POST">
            @csrf
            @method('PUT')

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <!-- Name -->
                <div class="md:col-span-2">
                    <label for="name_ar" class="block text-sm font-semibold text-gray-700 mb-2">
                        اسم المرحلة بالعربية <span class="text-red-500">*</span>
                    </label>
                    <input type="text"
                           name="name_ar"
                           id="name_ar"
                           value="{{ old('name_ar', $academicPhase->name_ar) }}"
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent @error('name_ar') border-red-500 @enderror"
                           placeholder="مثال: الطور الثانوي"
                           required>
                    @error('name_ar')
                        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                </div>

                <!-- Order -->
                <div>
                    <label for="order" class="block text-sm font-semibold text-gray-700 mb-2">
                        الترتيب <span class="text-red-500">*</span>
                    </label>
                    <input type="number"
                           name="order"
                           id="order"
                           value="{{ old('order', $academicPhase->order) }}"
                           min="0"
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent @error('order') border-red-500 @enderror"
                           placeholder="0"
                           required>
                    @error('order')
                        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                    <p class="mt-1 text-xs text-gray-500">الترتيب يحدد كيفية ظهور المرحلة في القوائم (0 = أول)</p>
                </div>

                <!-- Current Slug (Read-only) -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        المعرف (Slug)
                    </label>
                    <input type="text"
                           value="{{ $academicPhase->slug }}"
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg bg-gray-100"
                           readonly>
                    <p class="mt-1 text-xs text-gray-500">سيتم تحديثه تلقائياً عند حفظ التغييرات</p>
                </div>
            </div>

            <!-- Submit Buttons -->
            <div class="mt-8 flex items-center gap-4">
                <button type="submit" class="px-6 py-3 bg-orange-600 text-white rounded-lg hover:bg-orange-700 transition-colors flex items-center gap-2 font-semibold">
                    <i class="fas fa-save"></i>
                    <span>حفظ التعديلات</span>
                </button>
                <a href="{{ route('admin.academic-phases.index') }}" class="px-6 py-3 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors font-semibold">
                    إلغاء
                </a>
            </div>
        </form>
    </div>
</div>
@endsection
