@extends('layouts.admin')

@section('title', 'تعديل باقة اشتراك')
@section('page-title', 'تعديل باقة: ' . $package->name_ar)

@section('content')
<form action="{{ route('admin.subscriptions.packages.update', $package) }}" method="POST" class="max-w-4xl mx-auto space-y-6">
    @csrf
    @method('PUT')

    <div class="bg-white rounded-lg shadow-sm p-6 space-y-6">
        <!-- Basic Information -->
        <div>
            <h3 class="text-lg font-semibold text-gray-900 mb-4 border-b pb-2">المعلومات الأساسية</h3>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">اسم الباقة (عربي) *</label>
                    <input type="text" name="name_ar" value="{{ old('name_ar', $package->name_ar) }}" required
                           class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 @error('name_ar') border-red-500 @enderror">
                    @error('name_ar')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">اسم الباقة (إنجليزي)</label>
                    <input type="text" name="name_en" value="{{ old('name_en', $package->name_en) }}"
                           class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 @error('name_en') border-red-500 @enderror">
                    @error('name_en')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                    @enderror
                </div>
            </div>

            <div class="mt-4">
                <label class="block text-sm font-medium text-gray-700 mb-2">الوصف (عربي) *</label>
                <textarea name="description_ar" rows="3" required
                          class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 @error('description_ar') border-red-500 @enderror">{{ old('description_ar', $package->description_ar) }}</textarea>
                @error('description_ar')
                    <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                @enderror
            </div>

            <div class="mt-4">
                <label class="block text-sm font-medium text-gray-700 mb-2">الوصف (إنجليزي)</label>
                <textarea name="description_en" rows="3"
                          class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 @error('description_en') border-red-500 @enderror">{{ old('description_en', $package->description_en) }}</textarea>
                @error('description_en')
                    <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                @enderror
            </div>
        </div>

        <!-- Pricing & Duration -->
        <div>
            <h3 class="text-lg font-semibold text-gray-900 mb-4 border-b pb-2">السعر والمدة</h3>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">السعر (دينار جزائري) *</label>
                    <input type="number" name="price_dzd" value="{{ old('price_dzd', $package->price_dzd) }}" step="0.01" min="0" required
                           class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 @error('price_dzd') border-red-500 @enderror">
                    @error('price_dzd')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">السعر بالدولار (اختياري)</label>
                    <input type="number" name="price_usd" value="{{ old('price_usd', $package->price_usd) }}" step="0.01" min="0"
                           class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 @error('price_usd') border-red-500 @enderror">
                    @error('price_usd')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">المدة (بالأيام) *</label>
                    <input type="number" name="duration_days" value="{{ old('duration_days', $package->duration_days) }}" min="1" required
                           class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 @error('duration_days') border-red-500 @enderror">
                    @error('duration_days')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                    @enderror
                </div>
            </div>
        </div>

        <!-- Course Selection -->
        <div>
            <h3 class="text-lg font-semibold text-gray-900 mb-4 border-b pb-2">الدورات المتضمنة *</h3>
            <p class="text-sm text-gray-600 mb-3">اختر الدورات التي ستكون متاحة في هذه الباقة</p>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-3 max-h-96 overflow-y-auto border border-gray-200 rounded-lg p-4">
                @php
                    $packageCourseIds = $package->courses->pluck('id')->toArray();
                @endphp
                @foreach(\App\Models\Course::where('is_published', true)->orderBy('title_ar')->get() as $course)
                    <div class="flex items-start">
                        <input type="checkbox" name="course_ids[]" value="{{ $course->id }}"
                               id="course_{{ $course->id }}"
                               {{ in_array($course->id, old('course_ids', $packageCourseIds)) ? 'checked' : '' }}
                               class="mt-1 ml-2 h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded">
                        <label for="course_{{ $course->id }}" class="text-sm text-gray-700 cursor-pointer">
                            <span class="font-medium">{{ $course->title_ar }}</span>
                            @if($course->subject)
                                <span class="text-gray-500 text-xs block">{{ $course->subject->name_ar }}</span>
                            @endif
                        </label>
                    </div>
                @endforeach
            </div>
            @error('course_ids')
                <p class="text-red-500 text-sm mt-2">{{ $message }}</p>
            @enderror
            @error('course_ids.*')
                <p class="text-red-500 text-sm mt-2">{{ $message }}</p>
            @enderror
        </div>

        <!-- Settings -->
        <div>
            <h3 class="text-lg font-semibold text-gray-900 mb-4 border-b pb-2">الإعدادات</h3>

            <div class="space-y-3">
                <div class="flex items-center">
                    <input type="checkbox" name="is_active" id="is_active" value="1"
                           {{ old('is_active', $package->is_active) ? 'checked' : '' }}
                           class="ml-2 h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded">
                    <label for="is_active" class="text-sm font-medium text-gray-700">
                        باقة نشطة ومتاحة للاشتراك
                    </label>
                </div>

                <div class="flex items-center">
                    <input type="checkbox" name="is_featured" id="is_featured" value="1"
                           {{ old('is_featured', $package->is_featured) ? 'checked' : '' }}
                           class="ml-2 h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded">
                    <label for="is_featured" class="text-sm font-medium text-gray-700">
                        باقة مميزة (تظهر بشكل بارز)
                    </label>
                </div>
            </div>
        </div>

        <!-- Additional Features -->
        <div>
            <h3 class="text-lg font-semibold text-gray-900 mb-4 border-b pb-2">المميزات الإضافية (اختياري)</h3>
            <p class="text-sm text-gray-600 mb-3">أضف مميزات أو خصائص إضافية لهذه الباقة (سطر واحد لكل ميزة)</p>

            <textarea name="features" rows="5" placeholder="مثال:&#10;- وصول كامل لجميع الدورات&#10;- دعم فني على مدار الساعة&#10;- شهادة إتمام معتمدة"
                      class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 font-mono text-sm @error('features') border-red-500 @enderror">{{ old('features', $package->features) }}</textarea>
            @error('features')
                <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
            @enderror
        </div>

        <!-- Statistics -->
        <div class="bg-gray-50 rounded-lg p-4">
            <h3 class="text-lg font-semibold text-gray-900 mb-3">إحصائيات الباقة</h3>
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                <div class="text-center">
                    <p class="text-sm text-gray-600">إجمالي الاشتراكات</p>
                    <p class="text-2xl font-bold text-gray-900">{{ $package->subscriptions->count() }}</p>
                </div>
                <div class="text-center">
                    <p class="text-sm text-gray-600">الاشتراكات النشطة</p>
                    <p class="text-2xl font-bold text-green-600">{{ $package->subscriptions()->where('is_active', true)->where('expires_at', '>', now())->count() }}</p>
                </div>
                <div class="text-center">
                    <p class="text-sm text-gray-600">الدورات المتضمنة</p>
                    <p class="text-2xl font-bold text-blue-600">{{ $package->courses->count() }}</p>
                </div>
                <div class="text-center">
                    <p class="text-sm text-gray-600">الإيرادات المتوقعة</p>
                    <p class="text-2xl font-bold text-purple-600">{{ number_format($package->price_dzd * $package->subscriptions()->where('is_active', true)->where('expires_at', '>', now())->count()) }} دج</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Action Buttons -->
    <div class="flex justify-end gap-3">
        <a href="{{ route('admin.subscriptions.packages') }}"
           class="px-6 py-3 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors">
            <i class="fas fa-times ml-2"></i>إلغاء
        </a>
        <button type="submit"
                class="px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors">
            <i class="fas fa-save ml-2"></i>حفظ التعديلات
        </button>
    </div>
</form>
@endsection
