@extends('layouts.admin')

@section('title', 'تعديل سنة دراسية')

@section('content')
<div class="p-6 bg-gray-50 min-h-screen">
    <!-- Header -->
    <div class="mb-8">
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-3xl font-bold text-gray-900 flex items-center">
                    <i class="fas fa-edit text-orange-600 mr-3"></i>
                    تعديل السنة: {{ $academicYear->name_ar }}
                </h1>
                <p class="text-gray-600 mt-2">تحديث معلومات السنة الدراسية</p>
            </div>
            <a href="{{ route('admin.academic-years.index') }}" class="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors flex items-center gap-2">
                <i class="fas fa-arrow-right"></i>
                <span>رجوع</span>
            </a>
        </div>
    </div>

    <!-- Form -->
    <div class="bg-white rounded-xl shadow-md p-8">
        <form action="{{ route('admin.academic-years.update', $academicYear->id) }}" method="POST">
            @csrf
            @method('PUT')

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <!-- Academic Phase -->
                <div class="md:col-span-2">
                    <label for="academic_phase_id" class="block text-sm font-semibold text-gray-700 mb-2">
                        المرحلة الدراسية <span class="text-red-500">*</span>
                    </label>
                    <select name="academic_phase_id"
                            id="academic_phase_id"
                            class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent @error('academic_phase_id') border-red-500 @enderror"
                            required>
                        <option value="">اختر المرحلة الدراسية</option>
                        @foreach($phases as $phase)
                            <option value="{{ $phase->id }}" {{ old('academic_phase_id', $academicYear->academic_phase_id) == $phase->id ? 'selected' : '' }}>
                                {{ $phase->name_ar }}
                            </option>
                        @endforeach
                    </select>
                    @error('academic_phase_id')
                        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                </div>

                <!-- Name -->
                <div class="md:col-span-2">
                    <label for="name_ar" class="block text-sm font-semibold text-gray-700 mb-2">
                        اسم السنة بالعربية <span class="text-red-500">*</span>
                    </label>
                    <input type="text"
                           name="name_ar"
                           id="name_ar"
                           value="{{ old('name_ar', $academicYear->name_ar) }}"
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent @error('name_ar') border-red-500 @enderror"
                           placeholder="مثال: السنة الأولى ثانوي"
                           required>
                    @error('name_ar')
                        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                </div>

                <!-- Level Number -->
                <div>
                    <label for="level_number" class="block text-sm font-semibold text-gray-700 mb-2">
                        رقم المستوى <span class="text-red-500">*</span>
                    </label>
                    <input type="number"
                           name="level_number"
                           id="level_number"
                           value="{{ old('level_number', $academicYear->level_number) }}"
                           min="1"
                           max="7"
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent @error('level_number') border-red-500 @enderror"
                           placeholder="1"
                           required>
                    @error('level_number')
                        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                    <p class="mt-1 text-xs text-gray-500">رقم المستوى التعليمي (ابتدائي: 1-5، متوسط: 1-4، ثانوي: 1-3)</p>
                </div>

                <!-- Order -->
                <div>
                    <label for="order" class="block text-sm font-semibold text-gray-700 mb-2">
                        الترتيب <span class="text-red-500">*</span>
                    </label>
                    <input type="number"
                           name="order"
                           id="order"
                           value="{{ old('order', $academicYear->order) }}"
                           min="0"
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent @error('order') border-red-500 @enderror"
                           placeholder="0"
                           required>
                    @error('order')
                        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                    <p class="mt-1 text-xs text-gray-500">الترتيب يحدد كيفية ظهور السنة في القوائم (0 = أول)</p>
                </div>

                <!-- Current Slug (Read-only) -->
                <div class="md:col-span-2">
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        المعرف (Slug)
                    </label>
                    <input type="text"
                           value="{{ $academicYear->slug }}"
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg bg-gray-100"
                           readonly>
                    <p class="mt-1 text-xs text-gray-500">سيتم تحديثه تلقائياً عند حفظ التغييرات</p>
                </div>

                <!-- Is Active -->
                <div class="md:col-span-2">
                    <label class="flex items-center cursor-pointer">
                        <input type="checkbox"
                               name="is_active"
                               id="is_active"
                               value="1"
                               {{ old('is_active', $academicYear->is_active) ? 'checked' : '' }}
                               class="w-5 h-5 text-orange-600 border-gray-300 rounded focus:ring-2 focus:ring-orange-500">
                        <span class="mr-3 text-sm font-semibold text-gray-700">السنة نشطة</span>
                    </label>
                    <p class="mt-1 text-xs text-gray-500 mr-8">السنوات النشطة فقط تظهر في التطبيقات والنماذج</p>
                </div>
            </div>

            <!-- Submit Buttons -->
            <div class="mt-8 flex items-center gap-4">
                <button type="submit" class="px-6 py-3 bg-orange-600 text-white rounded-lg hover:bg-orange-700 transition-colors flex items-center gap-2 font-semibold">
                    <i class="fas fa-save"></i>
                    <span>حفظ التعديلات</span>
                </button>
                <a href="{{ route('admin.academic-years.index') }}" class="px-6 py-3 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors font-semibold">
                    إلغاء
                </a>
            </div>
        </form>
    </div>
</div>
@endsection
