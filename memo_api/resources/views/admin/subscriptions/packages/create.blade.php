@extends('layouts.admin')

@section('title', 'إضافة باقة اشتراك')
@section('page-title', 'إضافة باقة اشتراك جديدة')

@push('styles')
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
<style>
    .select2-container--default .select2-selection--multiple {
        border: 1px solid #d1d5db;
        border-radius: 0.5rem;
        min-height: 42px;
        padding: 4px 8px;
    }
    .select2-container--default.select2-container--focus .select2-selection--multiple {
        border-color: #3b82f6;
        outline: none;
        box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
    }
    .select2-container--default .select2-selection--multiple .select2-selection__choice {
        background-color: #3b82f6;
        border-color: #2563eb;
        color: white;
        padding: 4px 10px;
        border-radius: 0.375rem;
    }
    .select2-container--default .select2-selection--multiple .select2-selection__choice__remove {
        color: white;
        margin-left: 6px;
    }
    .select2-container {
        width: 100% !important;
    }
</style>
@endpush

@section('content')
<div class="space-y-6" style="font-family: 'Cairo', sans-serif; direction: rtl;">
    <!-- Page Header -->
    <div class="bg-gradient-to-r from-purple-600 to-pink-600 rounded-xl shadow-lg p-6">
        <div class="flex items-center justify-between">
            <div class="text-white">
                <h2 class="text-2xl font-bold mb-2">إضافة باقة اشتراك جديدة</h2>
                <p class="text-purple-100">قم بإنشاء باقة شاملة تحتوي على دورات متعددة</p>
            </div>
            <a href="{{ route('admin.subscriptions.packages') }}"
               class="bg-white text-purple-600 hover:bg-purple-50 px-6 py-3 rounded-lg flex items-center gap-2 shadow-md font-semibold">
                <i class="fas fa-arrow-right"></i>
                <span>العودة للقائمة</span>
            </a>
        </div>
    </div>

    <form action="{{ route('admin.subscriptions.packages.store') }}" method="POST">
        @csrf

        <!-- Basic Information Card -->
        <div class="bg-white rounded-xl shadow-md overflow-hidden">
            <div class="bg-gradient-to-r from-blue-500 to-blue-600 px-6 py-4">
                <h3 class="text-xl font-bold text-white flex items-center gap-2">
                    <i class="fas fa-info-circle"></i>
                    المعلومات الأساسية
                </h3>
            </div>
            <div class="p-6 space-y-4">

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                            <i class="fas fa-tag text-blue-500"></i>
                            اسم الباقة (عربي) *
                        </label>
                        <input type="text" name="name_ar" value="{{ old('name_ar') }}" required
                               class="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 @error('name_ar') border-red-500 @enderror"
                               placeholder="مثال: باقة الطالب المتميز">
                        @error('name_ar')
                            <p class="text-red-500 text-sm mt-1 flex items-center gap-1">
                                <i class="fas fa-exclamation-circle"></i>
                                {{ $message }}
                            </p>
                        @enderror
                    </div>

                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                            <i class="fas fa-tag text-blue-500"></i>
                            اسم الباقة (إنجليزي)
                        </label>
                        <input type="text" name="name_en" value="{{ old('name_en') }}"
                               class="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 @error('name_en') border-red-500 @enderror"
                               placeholder="مثال: باقة الطالب المميز" dir="ltr">
                        @error('name_en')
                            <p class="text-red-500 text-sm mt-1 flex items-center gap-1">
                                <i class="fas fa-exclamation-circle"></i>
                                {{ $message }}
                            </p>
                        @enderror
                    </div>
                </div>

                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                        <i class="fas fa-align-right text-blue-500"></i>
                        الوصف (عربي) *
                    </label>
                    <textarea name="description_ar" rows="3" required
                              class="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 @error('description_ar') border-red-500 @enderror"
                              placeholder="اكتب وصفاً شاملاً للباقة...">{{ old('description_ar') }}</textarea>
                    @error('description_ar')
                        <p class="text-red-500 text-sm mt-1 flex items-center gap-1">
                            <i class="fas fa-exclamation-circle"></i>
                            {{ $message }}
                        </p>
                    @enderror
                </div>

                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                        <i class="fas fa-align-right text-blue-500"></i>
                        الوصف (إنجليزي)
                    </label>
                    <textarea name="description_en" rows="3"
                              class="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 @error('description_en') border-red-500 @enderror"
                              placeholder="اكتب وصفاً شاملاً للباقة بالإنجليزية..." dir="ltr">{{ old('description_en') }}</textarea>
                    @error('description_en')
                        <p class="text-red-500 text-sm mt-1 flex items-center gap-1">
                            <i class="fas fa-exclamation-circle"></i>
                            {{ $message }}
                        </p>
                    @enderror
                </div>
            </div>
        </div>

        <!-- Pricing & Duration Card -->
        <div class="bg-white rounded-xl shadow-md overflow-hidden">
            <div class="bg-gradient-to-r from-green-500 to-green-600 px-6 py-4">
                <h3 class="text-xl font-bold text-white flex items-center gap-2">
                    <i class="fas fa-money-bill-wave"></i>
                    السعر والمدة
                </h3>
            </div>
            <div class="p-6">

                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div class="bg-gradient-to-br from-green-50 to-green-100 p-4 rounded-xl border-2 border-green-200">
                        <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                            <i class="fas fa-coins text-green-600"></i>
                            السعر (دينار جزائري) *
                        </label>
                        <input type="number" name="price_dzd" value="{{ old('price_dzd') }}" step="0.01" min="0" required
                               class="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 bg-white @error('price_dzd') border-red-500 @enderror"
                               placeholder="أدخل السعر بالدينار">
                        @error('price_dzd')
                            <p class="text-red-500 text-sm mt-1 flex items-center gap-1">
                                <i class="fas fa-exclamation-circle"></i>
                                {{ $message }}
                            </p>
                        @enderror
                    </div>

                    <div class="bg-gradient-to-br from-blue-50 to-blue-100 p-4 rounded-xl border-2 border-blue-200">
                        <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                            <i class="fas fa-dollar-sign text-blue-600"></i>
                            السعر بالدولار (اختياري)
                        </label>
                        <input type="number" name="price_usd" value="{{ old('price_usd') }}" step="0.01" min="0"
                               class="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 bg-white @error('price_usd') border-red-500 @enderror"
                               placeholder="أدخل السعر بالدولار">
                        @error('price_usd')
                            <p class="text-red-500 text-sm mt-1 flex items-center gap-1">
                                <i class="fas fa-exclamation-circle"></i>
                                {{ $message }}
                            </p>
                        @enderror
                    </div>

                    <div class="bg-gradient-to-br from-purple-50 to-purple-100 p-4 rounded-xl border-2 border-purple-200">
                        <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                            <i class="fas fa-calendar-check text-purple-600"></i>
                            المدة (بالأيام) *
                        </label>
                        <input type="number" name="duration_days" value="{{ old('duration_days', 30) }}" min="1" required
                               class="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500 bg-white @error('duration_days') border-red-500 @enderror"
                               placeholder="أدخل المدة بالأيام">
                        @error('duration_days')
                            <p class="text-red-500 text-sm mt-1 flex items-center gap-1">
                                <i class="fas fa-exclamation-circle"></i>
                                {{ $message }}
                            </p>
                        @enderror
                    </div>
                </div>
            </div>
        </div>

        <!-- Course Selection Card -->
        <div class="bg-white rounded-xl shadow-md overflow-hidden">
            <div class="bg-gradient-to-r from-indigo-500 to-indigo-600 px-6 py-4">
                <h3 class="text-xl font-bold text-white flex items-center gap-2">
                    <i class="fas fa-graduation-cap"></i>
                    الدورات المتضمنة *
                </h3>
            </div>
            <div class="p-6">
                <p class="text-sm text-gray-600 mb-4 bg-indigo-50 p-3 rounded-lg border border-indigo-200 flex items-center gap-2">
                    <i class="fas fa-info-circle text-indigo-600"></i>
                    اختر الدورات التي ستكون متاحة في هذه الباقة
                </p>

                <select name="course_ids[]" id="course_select" multiple class="w-full" required>
                    @foreach(\App\Models\Course::where('is_published', true)->orderBy('title_ar')->get() as $course)
                        <option value="{{ $course->id }}"
                                {{ in_array($course->id, old('course_ids', [])) ? 'selected' : '' }}
                                data-subject="{{ $course->subject ? $course->subject->name_ar : '' }}">
                            {{ $course->title_ar }}
                            @if($course->subject)
                                - {{ $course->subject->name_ar }}
                            @endif
                        </option>
                    @endforeach
                </select>

                @error('course_ids')
                    <p class="text-red-500 text-sm mt-2 flex items-center gap-1">
                        <i class="fas fa-exclamation-circle"></i>
                        {{ $message }}
                    </p>
                @enderror
                @error('course_ids.*')
                    <p class="text-red-500 text-sm mt-2 flex items-center gap-1">
                        <i class="fas fa-exclamation-circle"></i>
                        {{ $message }}
                    </p>
                @enderror
            </div>
        </div>

        <!-- Settings Card -->
        <div class="bg-white rounded-xl shadow-md overflow-hidden">
            <div class="bg-gradient-to-r from-orange-500 to-orange-600 px-6 py-4">
                <h3 class="text-xl font-bold text-white flex items-center gap-2">
                    <i class="fas fa-cog"></i>
                    الإعدادات
                </h3>
            </div>
            <div class="p-6">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div class="bg-gradient-to-br from-green-50 to-green-100 p-4 rounded-xl border-2 border-green-200">
                        <div class="flex items-center gap-3">
                            <input type="checkbox" name="is_active" id="is_active" value="1"
                                   {{ old('is_active', true) ? 'checked' : '' }}
                                   class="ml-2 h-5 w-5 text-green-600 focus:ring-green-500 border-gray-300 rounded">
                            <label for="is_active" class="text-sm font-bold text-gray-700 flex items-center gap-2">
                                <i class="fas fa-check-circle text-green-600"></i>
                                باقة نشطة ومتاحة للاشتراك
                            </label>
                        </div>
                    </div>

                    <div class="bg-gradient-to-br from-yellow-50 to-yellow-100 p-4 rounded-xl border-2 border-yellow-200">
                        <div class="flex items-center gap-3">
                            <input type="checkbox" name="is_featured" id="is_featured" value="1"
                                   {{ old('is_featured') ? 'checked' : '' }}
                                   class="ml-2 h-5 w-5 text-yellow-600 focus:ring-yellow-500 border-gray-300 rounded">
                            <label for="is_featured" class="text-sm font-bold text-gray-700 flex items-center gap-2">
                                <i class="fas fa-star text-yellow-600"></i>
                                باقة مميزة (تظهر بشكل بارز)
                            </label>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Additional Features Card -->
        <div class="bg-white rounded-xl shadow-md overflow-hidden">
            <div class="bg-gradient-to-r from-pink-500 to-pink-600 px-6 py-4">
                <h3 class="text-xl font-bold text-white flex items-center gap-2">
                    <i class="fas fa-sparkles"></i>
                    المميزات الإضافية (اختياري)
                </h3>
            </div>
            <div class="p-6">
                <p class="text-sm text-gray-600 mb-4 bg-pink-50 p-3 rounded-lg border border-pink-200 flex items-center gap-2">
                    <i class="fas fa-info-circle text-pink-600"></i>
                    أضف مميزات أو خصائص إضافية لهذه الباقة (سطر واحد لكل ميزة)
                </p>

                <textarea name="features" rows="6" placeholder="مثال:&#10;- وصول كامل لجميع الدورات&#10;- دعم فني على مدار الساعة&#10;- شهادة إتمام معتمدة&#10;- تحديثات مجانية مدى الحياة"
                          class="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500 font-mono text-sm @error('features') border-red-500 @enderror">{{ old('features') }}</textarea>
                @error('features')
                    <p class="text-red-500 text-sm mt-1 flex items-center gap-1">
                        <i class="fas fa-exclamation-circle"></i>
                        {{ $message }}
                    </p>
                @enderror
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="flex justify-end gap-3 bg-white rounded-xl shadow-md p-6">
            <a href="{{ route('admin.subscriptions.packages') }}"
               class="px-8 py-3 border-2 border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 font-semibold flex items-center gap-2">
                <i class="fas fa-times"></i>
                إلغاء
            </a>
            <button type="submit"
                    class="px-8 py-3 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white rounded-lg font-semibold shadow-lg flex items-center gap-2">
                <i class="fas fa-save"></i>
                حفظ الباقة
            </button>
        </div>
    </form>
</div>
@endsection

@push('scripts')
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
<script>
    $(document).ready(function() {
        $('#course_select').select2({
            placeholder: 'اختر الدورات المتضمنة في الباقة',
            dir: 'rtl',
            language: {
                noResults: function() {
                    return 'لا توجد نتائج';
                },
                searching: function() {
                    return 'جاري البحث...';
                }
            },
            width: '100%',
            closeOnSelect: false,
            allowClear: true
        });
    });
</script>
@endpush
