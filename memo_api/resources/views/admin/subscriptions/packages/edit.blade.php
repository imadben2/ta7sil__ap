@extends('layouts.admin')

@section('title', 'تعديل باقة اشتراك')
@section('page-title', 'تعديل باقة: ' . $package->name_ar)

@section('content')
<div class="space-y-6" style="font-family: 'Cairo', sans-serif; direction: rtl;">
    <!-- Enhanced Header with Gradient -->
    <div class="bg-gradient-to-r from-indigo-600 to-purple-600 rounded-2xl shadow-xl p-8">
        <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
            <div class="text-white">
                <h2 class="text-3xl font-bold mb-3 flex items-center gap-3">
                    <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center">
                        <i class="fas fa-box-open text-3xl"></i>
                    </div>
                    <span>تعديل باقة الاشتراك</span>
                </h2>
                <p class="text-purple-100 text-lg">{{ $package->name_ar }}</p>
            </div>
            <a href="{{ route('admin.subscriptions.packages') }}"
               class="bg-white text-indigo-600 hover:bg-indigo-50 px-6 py-3 rounded-xl flex items-center gap-2 transition-all shadow-md hover:shadow-lg font-semibold">
                <span>العودة للقائمة</span>
                <i class="fas fa-arrow-left"></i>
            </a>
        </div>
    </div>

    <form action="{{ route('admin.subscriptions.packages.update', $package) }}" method="POST" class="space-y-6">
        @csrf
        @method('PUT')

        <!-- Basic Information -->
        <div class="bg-white rounded-2xl shadow-xl overflow-hidden">
            <div class="bg-gradient-to-r from-blue-600 to-cyan-600 px-8 py-5">
                <h3 class="text-2xl font-bold text-white flex items-center gap-3">
                    <div class="w-10 h-10 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                        <i class="fas fa-info-circle"></i>
                    </div>
                    المعلومات الأساسية
                </h3>
            </div>
            <div class="p-8 space-y-6">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                        <label class="block text-lg font-bold text-gray-800 mb-3">
                            اسم الباقة (عربي)
                            <span class="text-red-500">*</span>
                        </label>
                        <div class="relative">
                            <div class="absolute right-4 top-1/2 -translate-y-1/2 text-blue-500">
                                <i class="fas fa-tag text-xl"></i>
                            </div>
                            <input type="text" name="name_ar" value="{{ old('name_ar', $package->name_ar) }}" required
                                   class="w-full pr-14 pl-6 py-4 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all text-lg @error('name_ar') border-red-500 @enderror">
                        </div>
                        @error('name_ar')
                            <p class="text-red-500 text-sm mt-2 flex items-center gap-1">
                                <i class="fas fa-exclamation-circle"></i>
                                <span>{{ $message }}</span>
                            </p>
                        @enderror
                    </div>

                    <div>
                        <label class="block text-lg font-bold text-gray-800 mb-3">
                            اسم الباقة (إنجليزي)
                        </label>
                        <div class="relative">
                            <div class="absolute right-4 top-1/2 -translate-y-1/2 text-blue-500">
                                <i class="fas fa-tag text-xl"></i>
                            </div>
                            <input type="text" name="name_en" value="{{ old('name_en', $package->name_en) }}"
                                   class="w-full pr-14 pl-6 py-4 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all text-lg @error('name_en') border-red-500 @enderror"
                                   dir="ltr">
                        </div>
                        @error('name_en')
                            <p class="text-red-500 text-sm mt-2 flex items-center gap-1">
                                <i class="fas fa-exclamation-circle"></i>
                                <span>{{ $message }}</span>
                            </p>
                        @enderror
                    </div>
                </div>

                <div>
                    <label class="block text-lg font-bold text-gray-800 mb-3">
                        الوصف (عربي)
                        <span class="text-red-500">*</span>
                    </label>
                    <textarea name="description_ar" rows="4" required
                              class="w-full px-6 py-4 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all text-lg @error('description_ar') border-red-500 @enderror">{{ old('description_ar', $package->description_ar) }}</textarea>
                    @error('description_ar')
                        <p class="text-red-500 text-sm mt-2 flex items-center gap-1">
                            <i class="fas fa-exclamation-circle"></i>
                            <span>{{ $message }}</span>
                        </p>
                    @enderror
                </div>

                <div>
                    <label class="block text-lg font-bold text-gray-800 mb-3">
                        الوصف (إنجليزي)
                    </label>
                    <textarea name="description_en" rows="4"
                              class="w-full px-6 py-4 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all text-lg @error('description_en') border-red-500 @enderror"
                              dir="ltr">{{ old('description_en', $package->description_en) }}</textarea>
                    @error('description_en')
                        <p class="text-red-500 text-sm mt-2 flex items-center gap-1">
                            <i class="fas fa-exclamation-circle"></i>
                            <span>{{ $message }}</span>
                        </p>
                    @enderror
                </div>
            </div>
        </div>

        <!-- Pricing & Duration -->
        <div class="bg-white rounded-2xl shadow-xl overflow-hidden">
            <div class="bg-gradient-to-r from-green-600 to-emerald-600 px-8 py-5">
                <h3 class="text-2xl font-bold text-white flex items-center gap-3">
                    <div class="w-10 h-10 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                        <i class="fas fa-money-bill-wave"></i>
                    </div>
                    السعر والمدة
                </h3>
            </div>
            <div class="p-8">
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <div>
                        <label class="block text-lg font-bold text-gray-800 mb-3">
                            السعر (دينار جزائري)
                            <span class="text-red-500">*</span>
                        </label>
                        <div class="relative">
                            <div class="absolute right-4 top-1/2 -translate-y-1/2 text-green-500">
                                <i class="fas fa-coins text-xl"></i>
                            </div>
                            <input type="number" name="price_dzd" value="{{ old('price_dzd', $package->price_dzd) }}" step="0.01" min="0" required
                                   class="w-full pr-14 pl-6 py-4 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-all text-lg font-semibold @error('price_dzd') border-red-500 @enderror">
                        </div>
                        @error('price_dzd')
                            <p class="text-red-500 text-sm mt-2 flex items-center gap-1">
                                <i class="fas fa-exclamation-circle"></i>
                                <span>{{ $message }}</span>
                            </p>
                        @enderror
                    </div>

                    <div>
                        <label class="block text-lg font-bold text-gray-800 mb-3">
                            السعر بالدولار
                            <span class="text-gray-500 text-sm font-normal">(اختياري)</span>
                        </label>
                        <div class="relative">
                            <div class="absolute right-4 top-1/2 -translate-y-1/2 text-green-500">
                                <i class="fas fa-dollar-sign text-xl"></i>
                            </div>
                            <input type="number" name="price_usd" value="{{ old('price_usd', $package->price_usd) }}" step="0.01" min="0"
                                   class="w-full pr-14 pl-6 py-4 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-all text-lg font-semibold @error('price_usd') border-red-500 @enderror">
                        </div>
                        @error('price_usd')
                            <p class="text-red-500 text-sm mt-2 flex items-center gap-1">
                                <i class="fas fa-exclamation-circle"></i>
                                <span>{{ $message }}</span>
                            </p>
                        @enderror
                    </div>

                    <div>
                        <label class="block text-lg font-bold text-gray-800 mb-3">
                            المدة (بالأيام)
                            <span class="text-red-500">*</span>
                        </label>
                        <div class="relative">
                            <div class="absolute right-4 top-1/2 -translate-y-1/2 text-green-500">
                                <i class="fas fa-calendar-alt text-xl"></i>
                            </div>
                            <input type="number" name="duration_days" value="{{ old('duration_days', $package->duration_days) }}" min="1" required
                                   class="w-full pr-14 pl-6 py-4 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-all text-lg font-semibold @error('duration_days') border-red-500 @enderror">
                        </div>
                        @error('duration_days')
                            <p class="text-red-500 text-sm mt-2 flex items-center gap-1">
                                <i class="fas fa-exclamation-circle"></i>
                                <span>{{ $message }}</span>
                            </p>
                        @enderror
                    </div>
                </div>
            </div>
        </div>

        <!-- Course Selection -->
        <div class="bg-white rounded-2xl shadow-xl overflow-hidden">
            <div class="bg-gradient-to-r from-purple-600 to-pink-600 px-8 py-5">
                <h3 class="text-2xl font-bold text-white flex items-center gap-3">
                    <div class="w-10 h-10 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                        <i class="fas fa-graduation-cap"></i>
                    </div>
                    الدورات المتضمنة
                </h3>
            </div>
            <div class="p-8">
                <p class="text-gray-600 mb-6 text-lg flex items-center gap-2">
                    <i class="fas fa-info-circle text-purple-500"></i>
                    <span>اختر الدورات التي ستكون متاحة في هذه الباقة</span>
                </p>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 max-h-96 overflow-y-auto border-2 border-gray-200 rounded-xl p-6 bg-gray-50">
                    @php
                        $packageCourseIds = $package->courses->pluck('id')->toArray();
                    @endphp
                    @foreach(\App\Models\Course::where('is_published', true)->orderBy('title_ar')->get() as $course)
                        <label class="flex items-start gap-3 p-4 bg-white rounded-lg border-2 border-gray-200 hover:border-purple-400 hover:shadow-md transition-all cursor-pointer">
                            <input type="checkbox" name="course_ids[]" value="{{ $course->id }}"
                                   {{ in_array($course->id, old('course_ids', $packageCourseIds)) ? 'checked' : '' }}
                                   class="mt-1 w-5 h-5 text-purple-600 focus:ring-purple-500 border-gray-300 rounded">
                            <div class="flex-1">
                                <span class="font-bold text-gray-900 block">{{ $course->title_ar }}</span>
                                @if($course->subject)
                                    <span class="text-gray-500 text-sm flex items-center gap-1 mt-1">
                                        <i class="fas fa-book text-purple-500"></i>
                                        {{ $course->subject->name_ar }}
                                    </span>
                                @endif
                            </div>
                        </label>
                    @endforeach
                </div>
                @error('course_ids')
                    <p class="text-red-500 text-sm mt-3 flex items-center gap-1">
                        <i class="fas fa-exclamation-circle"></i>
                        <span>{{ $message }}</span>
                    </p>
                @enderror
            </div>
        </div>

        <!-- Settings -->
        <div class="bg-white rounded-2xl shadow-xl overflow-hidden">
            <div class="bg-gradient-to-r from-orange-600 to-red-600 px-8 py-5">
                <h3 class="text-2xl font-bold text-white flex items-center gap-3">
                    <div class="w-10 h-10 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                        <i class="fas fa-cog"></i>
                    </div>
                    الإعدادات
                </h3>
            </div>
            <div class="p-8 space-y-4">
                <label class="flex items-center gap-4 p-5 bg-gradient-to-r from-green-50 to-emerald-50 border-2 border-green-200 rounded-xl cursor-pointer hover:shadow-md transition-all">
                    <input type="checkbox" name="is_active" value="1"
                           {{ old('is_active', $package->is_active) ? 'checked' : '' }}
                           class="w-6 h-6 text-green-600 focus:ring-green-500 border-gray-300 rounded">
                    <div class="flex-1">
                        <span class="text-lg font-bold text-gray-900 flex items-center gap-2">
                            <i class="fas fa-check-circle text-green-500"></i>
                            باقة نشطة ومتاحة للاشتراك
                        </span>
                        <p class="text-sm text-gray-600 mt-1">يمكن للمستخدمين الاشتراك في هذه الباقة</p>
                    </div>
                </label>

                <label class="flex items-center gap-4 p-5 bg-gradient-to-r from-yellow-50 to-orange-50 border-2 border-yellow-200 rounded-xl cursor-pointer hover:shadow-md transition-all">
                    <input type="checkbox" name="is_featured" value="1"
                           {{ old('is_featured', $package->is_featured) ? 'checked' : '' }}
                           class="w-6 h-6 text-yellow-600 focus:ring-yellow-500 border-gray-300 rounded">
                    <div class="flex-1">
                        <span class="text-lg font-bold text-gray-900 flex items-center gap-2">
                            <i class="fas fa-star text-yellow-500"></i>
                            باقة مميزة
                        </span>
                        <p class="text-sm text-gray-600 mt-1">تظهر بشكل بارز في صفحة الباقات</p>
                    </div>
                </label>
            </div>
        </div>

        <!-- Additional Features -->
        <div class="bg-white rounded-2xl shadow-xl overflow-hidden">
            <div class="bg-gradient-to-r from-indigo-600 to-blue-600 px-8 py-5">
                <h3 class="text-2xl font-bold text-white flex items-center gap-3">
                    <div class="w-10 h-10 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                        <i class="fas fa-list-check"></i>
                    </div>
                    المميزات الإضافية
                </h3>
            </div>
            <div class="p-8">
                <p class="text-gray-600 mb-4 text-lg flex items-center gap-2">
                    <i class="fas fa-lightbulb text-indigo-500"></i>
                    <span>أضف مميزات أو خصائص إضافية لهذه الباقة (سطر واحد لكل ميزة)</span>
                </p>
                <textarea name="features" rows="6"
                          placeholder="مثال:&#10;- وصول كامل لجميع الدورات&#10;- دعم فني على مدار الساعة&#10;- شهادة إتمام معتمدة&#10;- محتوى حصري للمشتركين"
                          class="w-full px-6 py-4 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all text-lg font-mono @error('features') border-red-500 @enderror">{{ old('features', $package->features) }}</textarea>
                @error('features')
                    <p class="text-red-500 text-sm mt-2 flex items-center gap-1">
                        <i class="fas fa-exclamation-circle"></i>
                        <span>{{ $message }}</span>
                    </p>
                @enderror
            </div>
        </div>

        <!-- Statistics -->
        <div class="bg-gradient-to-br from-gray-50 to-blue-50 rounded-2xl shadow-xl p-8 border-2 border-gray-200">
            <h3 class="text-2xl font-bold text-gray-900 mb-6 flex items-center gap-3">
                <div class="w-12 h-12 bg-gradient-to-br from-blue-500 to-indigo-500 rounded-xl flex items-center justify-center text-white">
                    <i class="fas fa-chart-bar text-xl"></i>
                </div>
                إحصائيات الباقة
            </h3>
            <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
                <div class="bg-white rounded-xl p-6 shadow-md text-center">
                    <div class="w-16 h-16 bg-gradient-to-br from-blue-500 to-cyan-500 rounded-xl flex items-center justify-center mx-auto mb-3">
                        <i class="fas fa-users text-white text-2xl"></i>
                    </div>
                    <p class="text-sm text-gray-600 mb-1">إجمالي الاشتراكات</p>
                    <p class="text-3xl font-bold text-gray-900">{{ $package->subscriptions->count() }}</p>
                </div>
                <div class="bg-white rounded-xl p-6 shadow-md text-center">
                    <div class="w-16 h-16 bg-gradient-to-br from-green-500 to-emerald-500 rounded-xl flex items-center justify-center mx-auto mb-3">
                        <i class="fas fa-check-circle text-white text-2xl"></i>
                    </div>
                    <p class="text-sm text-gray-600 mb-1">الاشتراكات النشطة</p>
                    <p class="text-3xl font-bold text-green-600">{{ $package->subscriptions()->where('status', 'active')->count() }}</p>
                </div>
                <div class="bg-white rounded-xl p-6 shadow-md text-center">
                    <div class="w-16 h-16 bg-gradient-to-br from-purple-500 to-pink-500 rounded-xl flex items-center justify-center mx-auto mb-3">
                        <i class="fas fa-graduation-cap text-white text-2xl"></i>
                    </div>
                    <p class="text-sm text-gray-600 mb-1">الدورات المتضمنة</p>
                    <p class="text-3xl font-bold text-purple-600">{{ $package->courses->count() }}</p>
                </div>
                <div class="bg-white rounded-xl p-6 shadow-md text-center">
                    <div class="w-16 h-16 bg-gradient-to-br from-orange-500 to-red-500 rounded-xl flex items-center justify-center mx-auto mb-3">
                        <i class="fas fa-coins text-white text-2xl"></i>
                    </div>
                    <p class="text-sm text-gray-600 mb-1">الإيرادات المتوقعة</p>
                    <p class="text-2xl font-bold text-orange-600">{{ number_format($package->price_dzd * $package->subscriptions()->where('status', 'active')->count()) }} دج</p>
                </div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="flex flex-col sm:flex-row gap-4 justify-end">
            <a href="{{ route('admin.subscriptions.packages') }}"
               class="px-8 py-4 bg-white border-2 border-gray-300 rounded-xl text-gray-700 hover:bg-gray-50 font-bold transition-all text-center flex items-center justify-center gap-2 shadow-md">
                <i class="fas fa-times"></i>
                <span>إلغاء</span>
            </a>
            <button type="submit"
                    class="px-8 py-4 bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-700 hover:to-purple-700 text-white rounded-xl font-bold shadow-xl hover:shadow-2xl transition-all flex items-center justify-center gap-2">
                <i class="fas fa-save"></i>
                <span>حفظ التعديلات</span>
            </button>
        </div>
    </form>
</div>
@endsection
