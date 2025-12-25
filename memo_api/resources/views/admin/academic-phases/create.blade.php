@extends('layouts.admin')

@section('title', 'إضافة مرحلة دراسية')

@section('content')
<div class="p-6 bg-gray-50 min-h-screen">
    <!-- Header -->
    <div class="mb-8">
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-3xl font-bold text-gray-900 flex items-center">
                    <i class="fas fa-plus-circle text-purple-600 mr-3"></i>
                    إضافة مرحلة دراسية جديدة
                </h1>
                <p class="text-gray-600 mt-2">أضف مرحلة تعليمية جديدة (ابتدائي، متوسط، ثانوي)</p>
            </div>
            <a href="{{ route('admin.academic-phases.index') }}" class="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors flex items-center gap-2">
                <i class="fas fa-arrow-right"></i>
                <span>رجوع</span>
            </a>
        </div>
    </div>

    <!-- Form -->
    <div class="bg-white rounded-xl shadow-md p-8">
        <form action="{{ route('admin.academic-phases.store') }}" method="POST">
            @csrf

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <!-- Name -->
                <div class="md:col-span-2">
                    <label for="name_ar" class="block text-sm font-semibold text-gray-700 mb-2">
                        اسم المرحلة بالعربية <span class="text-red-500">*</span>
                    </label>
                    <input type="text"
                           name="name_ar"
                           id="name_ar"
                           value="{{ old('name_ar') }}"
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent @error('name_ar') border-red-500 @enderror"
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
                           value="{{ old('order', 0) }}"
                           min="0"
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent @error('order') border-red-500 @enderror"
                           placeholder="0"
                           required>
                    @error('order')
                        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                    <p class="mt-1 text-xs text-gray-500">الترتيب يحدد كيفية ظهور المرحلة في القوائم (0 = أول)</p>
                </div>

                <!-- Is Active -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        الحالة
                    </label>
                    <label class="relative inline-flex items-center cursor-pointer">
                        <input type="checkbox"
                               name="is_active"
                               value="1"
                               class="sr-only peer"
                               {{ old('is_active', true) ? 'checked' : '' }}>
                        <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-purple-300 rounded-full peer peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-purple-600"></div>
                        <span class="ms-3 text-sm font-medium text-gray-700">مفعّلة</span>
                    </label>
                    <p class="mt-1 text-xs text-gray-500">المراحل المعطلة لن تظهر في التطبيق</p>
                </div>
            </div>

            <!-- Submit Buttons -->
            <div class="mt-8 flex items-center gap-4">
                <button type="submit" class="px-6 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors flex items-center gap-2 font-semibold">
                    <i class="fas fa-save"></i>
                    <span>حفظ المرحلة</span>
                </button>
                <a href="{{ route('admin.academic-phases.index') }}" class="px-6 py-3 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors font-semibold">
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
                    <li>• المراحل الأساسية في الجزائر: الطور الابتدائي، الطور المتوسط، الطور الثانوي</li>
                    <li>• الترتيب يساعد في تنظيم عرض المراحل (ابتدائي = 0، متوسط = 1، ثانوي = 2)</li>
                    <li>• لا يمكن حذف مرحلة تحتوي على سنوات دراسية</li>
                </ul>
            </div>
        </div>
    </div>
</div>
@endsection
