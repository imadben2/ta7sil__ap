@extends('layouts.admin')

@section('title', 'إضافة شعبة دراسية')

@section('content')
<div class="p-6 bg-gray-50 min-h-screen">
    <!-- Header -->
    <div class="mb-8">
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-3xl font-bold text-gray-900 flex items-center">
                    <i class="fas fa-plus-circle text-green-600 mr-3"></i>
                    إضافة شعبة دراسية جديدة
                </h1>
                <p class="text-gray-600 mt-2">أضف شعبة دراسية جديدة لسنة معينة</p>
            </div>
            <a href="{{ route('admin.academic-streams.index') }}" class="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors flex items-center gap-2">
                <i class="fas fa-arrow-right"></i>
                <span>رجوع</span>
            </a>
        </div>
    </div>

    <!-- Form -->
    <div class="bg-white rounded-xl shadow-md p-8">
        <form action="{{ route('admin.academic-streams.store') }}" method="POST">
            @csrf

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <!-- Academic Year -->
                <div class="md:col-span-2">
                    <label for="academic_year_id" class="block text-sm font-semibold text-gray-700 mb-2">
                        السنة الدراسية <span class="text-red-500">*</span>
                    </label>
                    <select name="academic_year_id"
                            id="academic_year_id"
                            class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent @error('academic_year_id') border-red-500 @enderror"
                            required>
                        <option value="">اختر السنة الدراسية</option>
                        @foreach($academicPhases as $phase)
                            <optgroup label="{{ $phase->name_ar }}">
                                @foreach($phase->academicYears as $year)
                                    <option value="{{ $year->id }}" {{ old('academic_year_id') == $year->id ? 'selected' : '' }}>
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
                           value="{{ old('name_ar') }}"
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent @error('name_ar') border-red-500 @enderror"
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
                              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent @error('description_ar') border-red-500 @enderror"
                              placeholder="وصف مختصر للشعبة الدراسية...">{{ old('description_ar') }}</textarea>
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
                           value="{{ old('order', 0) }}"
                           min="0"
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent @error('order') border-red-500 @enderror"
                           placeholder="0"
                           required>
                    @error('order')
                        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                    <p class="mt-1 text-xs text-gray-500">الترتيب يحدد كيفية ظهور الشعبة في القوائم (0 = أول)</p>
                </div>

                <!-- Is Active -->
                <div>
                    <label class="flex items-center cursor-pointer mt-8">
                        <input type="checkbox"
                               name="is_active"
                               id="is_active"
                               value="1"
                               {{ old('is_active', true) ? 'checked' : '' }}
                               class="w-5 h-5 text-green-600 border-gray-300 rounded focus:ring-2 focus:ring-green-500">
                        <span class="mr-3 text-sm font-semibold text-gray-700">الشعبة نشطة</span>
                    </label>
                    <p class="mt-1 text-xs text-gray-500 mr-8">الشعب النشطة فقط تظهر في التطبيقات والنماذج</p>
                </div>
            </div>

            <!-- Submit Buttons -->
            <div class="mt-8 flex items-center gap-4">
                <button type="submit" class="px-6 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors flex items-center gap-2 font-semibold">
                    <i class="fas fa-save"></i>
                    <span>حفظ الشعبة</span>
                </button>
                <a href="{{ route('admin.academic-streams.index') }}" class="px-6 py-3 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors font-semibold">
                    إلغاء
                </a>
            </div>
        </form>
    </div>

    <!-- Help Section -->
    <div class="mt-6 bg-blue-50 border-r-4 border-blue-500 p-4 rounded-lg">
        <div class="flex">
            <i class="fas fa-info-circle text-blue-500 text-xl mr-3 mt-1"></i>
            <div>
                <h3 class="text-blue-900 font-semibold mb-1">نصائح</h3>
                <ul class="text-sm text-blue-800 space-y-1">
                    <li>• الشعب الشائعة في الثانوي: علوم تجريبية، رياضيات، تقني رياضي، تسيير واقتصاد، آداب وفلسفة، لغات أجنبية</li>
                    <li>• في المتوسط والابتدائي عادة لا توجد شعب، أو قد تكون شعبة واحدة "عام"</li>
                    <li>• الترتيب يساعد في تنظيم عرض الشعب حسب الأهمية</li>
                    <li>• الوصف مفيد لتوضيح تخصص كل شعبة والمواد المركزة عليها</li>
                </ul>
            </div>
        </div>
    </div>
</div>
@endsection
