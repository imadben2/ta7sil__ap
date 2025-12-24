@extends('layouts.admin')

@section('title', 'تعديل شعبة دراسية')

@section('content')
<div class="p-6 bg-gray-50 min-h-screen">
    <!-- Header -->
    <div class="mb-8">
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-3xl font-bold text-gray-900 flex items-center">
                    <i class="fas fa-edit text-orange-600 mr-3"></i>
                    تعديل الشعبة: {{ $academicStream->name_ar }}
                </h1>
                <p class="text-gray-600 mt-2">تحديث معلومات الشعبة الدراسية</p>
            </div>
            <a href="{{ route('admin.academic-streams.index') }}" class="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors flex items-center gap-2">
                <i class="fas fa-arrow-right"></i>
                <span>رجوع</span>
            </a>
        </div>
    </div>

    <!-- Form -->
    <div class="bg-white rounded-xl shadow-md p-8">
        <form action="{{ route('admin.academic-streams.update', $academicStream->id) }}" method="POST">
            @csrf
            @method('PUT')

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <!-- Academic Year -->
                <div class="md:col-span-2">
                    <label for="academic_year_id" class="block text-sm font-semibold text-gray-700 mb-2">
                        السنة الدراسية <span class="text-red-500">*</span>
                    </label>
                    <select name="academic_year_id"
                            id="academic_year_id"
                            class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent @error('academic_year_id') border-red-500 @enderror"
                            required>
                        <option value="">اختر السنة الدراسية</option>
                        @foreach($academicPhases as $phase)
                            <optgroup label="{{ $phase->name_ar }}">
                                @foreach($phase->academicYears as $year)
                                    <option value="{{ $year->id }}" {{ old('academic_year_id', $academicStream->academic_year_id) == $year->id ? 'selected' : '' }}>
                                        {{ $year->name_ar }}
                                    </option>
                                @endforeach
                            </optgroup>
                        @endforeach
                    </select>
                    @error('academic_year_id')
                        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                </div>

                <!-- Name -->
                <div class="md:col-span-2">
                    <label for="name_ar" class="block text-sm font-semibold text-gray-700 mb-2">
                        اسم الشعبة بالعربية <span class="text-red-500">*</span>
                    </label>
                    <input type="text"
                           name="name_ar"
                           id="name_ar"
                           value="{{ old('name_ar', $academicStream->name_ar) }}"
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent @error('name_ar') border-red-500 @enderror"
                           placeholder="مثال: شعبة العلوم التجريبية"
                           required>
                    @error('name_ar')
                        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                </div>

                <!-- Description -->
                <div class="md:col-span-2">
                    <label for="description_ar" class="block text-sm font-semibold text-gray-700 mb-2">
                        الوصف بالعربية
                    </label>
                    <textarea name="description_ar"
                              id="description_ar"
                              rows="4"
                              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent @error('description_ar') border-red-500 @enderror"
                              placeholder="وصف مختصر للشعبة الدراسية...">{{ old('description_ar', $academicStream->description_ar) }}</textarea>
                    @error('description_ar')
                        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                    <p class="mt-1 text-xs text-gray-500">وصف اختياري للشعبة، مثل: شعبة تركز على العلوم الطبيعية والرياضيات</p>
                </div>

                <!-- Order -->
                <div>
                    <label for="order" class="block text-sm font-semibold text-gray-700 mb-2">
                        الترتيب <span class="text-red-500">*</span>
                    </label>
                    <input type="number"
                           name="order"
                           id="order"
                           value="{{ old('order', $academicStream->order) }}"
                           min="0"
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent @error('order') border-red-500 @enderror"
                           placeholder="0"
                           required>
                    @error('order')
                        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                    <p class="mt-1 text-xs text-gray-500">الترتيب يحدد كيفية ظهور الشعبة في القوائم (0 = أول)</p>
                </div>

                <!-- Current Slug (Read-only) -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        المعرف (Slug)
                    </label>
                    <input type="text"
                           value="{{ $academicStream->slug }}"
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
                               {{ old('is_active', $academicStream->is_active) ? 'checked' : '' }}
                               class="w-5 h-5 text-orange-600 border-gray-300 rounded focus:ring-2 focus:ring-orange-500">
                        <span class="mr-3 text-sm font-semibold text-gray-700">الشعبة نشطة</span>
                    </label>
                    <p class="mt-1 text-xs text-gray-500 mr-8">الشعب النشطة فقط تظهر في التطبيقات والنماذج</p>
                </div>
            </div>

            <!-- Submit Buttons -->
            <div class="mt-8 flex items-center gap-4">
                <button type="submit" class="px-6 py-3 bg-orange-600 text-white rounded-lg hover:bg-orange-700 transition-colors flex items-center gap-2 font-semibold">
                    <i class="fas fa-save"></i>
                    <span>حفظ التعديلات</span>
                </button>
                <a href="{{ route('admin.academic-streams.index') }}" class="px-6 py-3 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors font-semibold">
                    إلغاء
                </a>
            </div>
        </form>
    </div>
</div>
@endsection
