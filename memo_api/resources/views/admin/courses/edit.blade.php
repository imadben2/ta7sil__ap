@extends('layouts.admin')

@section('title', 'تعديل الدورة')
@section('page-title', 'تعديل الدورة: ' . $course->title_ar)
@section('page-description', 'تحديث معلومات الدورة المدفوعة')

@section('content')
<div style="font-family: 'Cairo', sans-serif; direction: rtl;">
    <!-- Enhanced Page Header -->
    <div class="bg-gradient-to-r from-blue-600 to-indigo-600 rounded-xl shadow-lg p-6 mb-6">
        <div class="flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
            <div class="flex items-center gap-4">
                <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center text-white">
                    <i class="fas fa-edit text-3xl"></i>
                </div>
                <div class="text-white">
                    <h1 class="text-2xl font-bold mb-1">تعديل الدورة</h1>
                    <p class="text-blue-100 text-sm">{{ $course->title_ar }}</p>
                </div>
            </div>
            <a href="{{ route('admin.courses.index') }}"
               class="bg-white text-blue-600 hover:bg-blue-50 px-6 py-3 rounded-lg flex items-center gap-2 transition-all shadow-md hover:shadow-lg font-semibold">
                <i class="fas fa-arrow-right"></i>
                <span>العودة للقائمة</span>
            </a>
        </div>
    </div>

    <!-- Statistics Cards -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div class="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl shadow-md p-5 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-blue-100 text-xs font-medium mb-1">الطلاب المسجلين</p>
                    <p class="text-3xl font-bold">{{ $course->subscriptions_count ?? 0 }}</p>
                </div>
                <div class="w-12 h-12 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                    <i class="fas fa-users text-xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-gradient-to-br from-green-500 to-green-600 rounded-xl shadow-md p-5 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-green-100 text-xs font-medium mb-1">عدد الوحدات</p>
                    <p class="text-3xl font-bold">{{ $course->modules ? $course->modules->count() : 0 }}</p>
                </div>
                <div class="w-12 h-12 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                    <i class="fas fa-layer-group text-xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-gradient-to-br from-purple-500 to-purple-600 rounded-xl shadow-md p-5 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-purple-100 text-xs font-medium mb-1">عدد الدروس</p>
                    <p class="text-3xl font-bold">{{ $course->lessons ? $course->lessons->count() : 0 }}</p>
                </div>
                <div class="w-12 h-12 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                    <i class="fas fa-play-circle text-xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-gradient-to-br from-yellow-500 to-orange-500 rounded-xl shadow-md p-5 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-yellow-100 text-xs font-medium mb-1">التقييم</p>
                    <p class="text-3xl font-bold">
                        {{ $course->average_rating ? number_format($course->average_rating, 1) : '-' }}
                        @if($course->average_rating)
                            <i class="fas fa-star text-lg"></i>
                        @endif
                    </p>
                </div>
                <div class="w-12 h-12 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                    <i class="fas fa-star text-xl"></i>
                </div>
            </div>
        </div>
    </div>

    <form action="{{ route('admin.courses.update', $course) }}" method="POST" enctype="multipart/form-data" class="space-y-6">
        @csrf
        @method('PUT')

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <!-- Main Content -->
            <div class="lg:col-span-2 space-y-6">
                <!-- Basic Information -->
                <div class="bg-white rounded-xl shadow-lg p-6 border-r-4 border-blue-500 hover:shadow-xl transition-shadow">
                    <div class="flex items-center gap-3 mb-6">
                        <div class="w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg flex items-center justify-center text-white">
                            <i class="fas fa-info-circle"></i>
                        </div>
                        <h3 class="text-xl font-bold text-gray-900">المعلومات الأساسية</h3>
                    </div>

                    <div class="space-y-5">
                        <div>
                            <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                                <i class="fas fa-heading text-blue-500 text-xs"></i>
                                عنوان الدورة *
                            </label>
                            <input type="text" name="title_ar" value="{{ old('title_ar', $course->title_ar) }}" required
                                   class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all @error('title_ar') border-red-500 @enderror">
                            @error('title_ar')
                                <p class="text-red-500 text-sm mt-1 flex items-center gap-1">
                                    <i class="fas fa-exclamation-circle"></i>
                                    {{ $message }}
                                </p>
                            @enderror
                        </div>

                        <div>
                            <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                                <i class="fas fa-align-right text-blue-500 text-xs"></i>
                                الوصف الكامل *
                            </label>
                            <textarea name="description_ar" rows="6" required
                                      class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all @error('description_ar') border-red-500 @enderror">{{ old('description_ar', $course->description_ar) }}</textarea>
                            @error('description_ar')
                                <p class="text-red-500 text-sm mt-1 flex items-center gap-1">
                                    <i class="fas fa-exclamation-circle"></i>
                                    {{ $message }}
                                </p>
                            @enderror
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                                    <i class="fas fa-book text-blue-500 text-xs"></i>
                                    المادة *
                                </label>
                                <select name="subject_id" required
                                        class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all @error('subject_id') border-red-500 @enderror">
                                    <option value="">اختر المادة</option>
                                    @foreach(\App\Models\Subject::all() as $subject)
                                        <option value="{{ $subject->id }}" {{ old('subject_id', $course->subject_id) == $subject->id ? 'selected' : '' }}>
                                            {{ $subject->name_ar }}
                                        </option>
                                    @endforeach
                                </select>
                            </div>

                            <div>
                                <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                                    <i class="fas fa-calendar-days text-blue-500 text-xs"></i>
                                    المدة (بالأيام) *
                                </label>
                                <input type="number" name="duration_days" value="{{ old('duration_days', $course->duration_days ?? 30) }}" min="1" required
                                       class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all">
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Course Content -->
                <div class="bg-white rounded-xl shadow-lg p-6 border-r-4 border-green-500 hover:shadow-xl transition-shadow">
                    <div class="flex items-center gap-3 mb-6">
                        <div class="w-10 h-10 bg-gradient-to-br from-green-500 to-green-600 rounded-lg flex items-center justify-center text-white">
                            <i class="fas fa-list-check"></i>
                        </div>
                        <h3 class="text-xl font-bold text-gray-900">محتوى الدورة</h3>
                    </div>

                    <div class="space-y-5">
                        <div class="bg-green-50 border-2 border-green-200 rounded-xl p-4">
                            <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                                <i class="fas fa-lightbulb text-green-500"></i>
                                ما ستتعلمه في هذه الدورة
                            </label>
                            <textarea name="what_you_will_learn" rows="5" placeholder="أدخل كل نقطة في سطر منفصل"
                                      class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-all">{{ old('what_you_will_learn', $course->what_you_will_learn) }}</textarea>
                            <p class="text-xs text-gray-500 mt-2 flex items-center gap-1">
                                <i class="fas fa-info-circle"></i>
                                مثال: فهم المفاهيم الأساسية، إتقان التطبيقات العملية
                            </p>
                        </div>

                        <div class="bg-blue-50 border-2 border-blue-200 rounded-xl p-4">
                            <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                                <i class="fas fa-clipboard-list text-blue-500"></i>
                                المتطلبات الأساسية
                            </label>
                            <textarea name="requirements" rows="4" placeholder="أدخل كل نقطة في سطر منفصل"
                                      class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all">{{ old('requirements', $course->requirements) }}</textarea>
                        </div>

                        <div class="bg-purple-50 border-2 border-purple-200 rounded-xl p-4">
                            <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                                <i class="fas fa-user-graduate text-purple-500"></i>
                                لمن هذه الدورة
                            </label>
                            <textarea name="target_audience" rows="4" placeholder="أدخل كل نقطة في سطر منفصل"
                                      class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500 transition-all">{{ old('target_audience', $course->target_audience) }}</textarea>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Sidebar -->
            <div class="space-y-6">
                <!-- Current Thumbnail Preview -->
                @if($course->thumbnail_url)
                    <div class="bg-white rounded-xl shadow-lg overflow-hidden">
                        <div class="bg-gradient-to-r from-pink-500 to-purple-500 p-4">
                            <h3 class="text-lg font-bold text-white flex items-center gap-2">
                                <i class="fas fa-image"></i>
                                صورة الغلاف الحالية
                            </h3>
                        </div>
                        <div class="p-4">
                            <img src="{{ Storage::url($course->thumbnail_url) }}" alt="Thumbnail" class="w-full rounded-lg shadow-md">
                        </div>
                    </div>
                @endif

                <!-- Media Upload -->
                <div class="bg-white rounded-xl shadow-lg p-6 border-r-4 border-pink-500">
                    <div class="flex items-center gap-3 mb-6">
                        <div class="w-10 h-10 bg-gradient-to-br from-pink-500 to-pink-600 rounded-lg flex items-center justify-center text-white">
                            <i class="fas fa-photo-film"></i>
                        </div>
                        <h3 class="text-xl font-bold text-gray-900">الصور والفيديو</h3>
                    </div>

                    <div class="space-y-5">
                        <div>
                            <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                                <i class="fas fa-image text-pink-500 text-xs"></i>
                                {{ $course->thumbnail_url ? 'تغيير صورة الغلاف' : 'صورة الغلاف *' }}
                            </label>
                            <input type="file" name="thumbnail" accept="image/*"
                                   class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-pink-500 transition-all file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:bg-pink-50 file:text-pink-700 hover:file:bg-pink-100">
                            <p class="text-xs text-gray-500 mt-2 flex items-center gap-1">
                                <i class="fas fa-info-circle"></i>
                                {{ $course->thumbnail_url ? 'اترك فارغاً للاحتفاظ بالصورة الحالية' : 'الحجم الموصى به: 1280x720' }}
                            </p>
                        </div>

                        <div class="bg-gradient-to-r from-red-50 to-pink-50 border-2 border-pink-200 rounded-xl p-4">
                            <label class="block text-sm font-bold text-gray-700 mb-3 flex items-center gap-2">
                                <i class="fas fa-video text-red-500"></i>
                                فيديو تعريفي (اختياري)
                            </label>
                            <select name="trailer_video_type" class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl mb-3 focus:ring-2 focus:ring-pink-500">
                                <option value="youtube" {{ old('trailer_video_type', $course->trailer_video_type) == 'youtube' ? 'selected' : '' }}>YouTube</option>
                                <option value="vimeo" {{ old('trailer_video_type', $course->trailer_video_type) == 'vimeo' ? 'selected' : '' }}>Vimeo</option>
                                <option value="uploaded" {{ old('trailer_video_type', $course->trailer_video_type) == 'uploaded' ? 'selected' : '' }}>رفع مباشر</option>
                            </select>
                            <input type="text" name="trailer_video_url" value="{{ old('trailer_video_url', $course->trailer_video_url) }}" placeholder="رابط الفيديو"
                                   class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-pink-500">
                        </div>
                    </div>
                </div>

                <!-- Pricing -->
                <div class="bg-white rounded-xl shadow-lg p-6 border-r-4 border-green-500">
                    <div class="flex items-center gap-3 mb-6">
                        <div class="w-10 h-10 bg-gradient-to-br from-green-500 to-green-600 rounded-lg flex items-center justify-center text-white">
                            <i class="fas fa-dollar-sign"></i>
                        </div>
                        <h3 class="text-xl font-bold text-gray-900">السعر</h3>
                    </div>

                    <div class="space-y-4">
                        <div class="flex items-center bg-blue-50 border-2 border-blue-200 rounded-xl p-4">
                            <input type="checkbox" name="is_free" id="is_free" value="1"
                                   {{ old('is_free', $course->is_free) ? 'checked' : '' }}
                                   class="w-5 h-5 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
                                   onchange="document.getElementById('price_field').disabled = this.checked">
                            <label for="is_free" class="mr-3 text-sm font-bold text-gray-700 flex items-center gap-2">
                                <i class="fas fa-gift text-blue-500"></i>
                                دورة مجانية
                            </label>
                        </div>

                        <div>
                            <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                                <i class="fas fa-money-bill text-green-500 text-xs"></i>
                                السعر (دينار جزائري)
                            </label>
                            <div class="relative">
                                <input type="number" name="price_dzd" id="price_field" value="{{ old('price_dzd', $course->price_dzd ?? 0) }}" min="0"
                                       {{ $course->is_free ? 'disabled' : '' }}
                                       class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-green-500 pl-12">
                                <div class="absolute left-3 top-3.5 text-gray-400 font-bold">دج</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Settings -->
                <div class="bg-white rounded-xl shadow-lg p-6 border-r-4 border-purple-500">
                    <div class="flex items-center gap-3 mb-6">
                        <div class="w-10 h-10 bg-gradient-to-br from-purple-500 to-purple-600 rounded-lg flex items-center justify-center text-white">
                            <i class="fas fa-cog"></i>
                        </div>
                        <h3 class="text-xl font-bold text-gray-900">الإعدادات</h3>
                    </div>

                    <div class="space-y-4">
                        <div class="flex items-center bg-green-50 border-2 border-green-200 rounded-xl p-4 hover:bg-green-100 transition-colors cursor-pointer">
                            <input type="checkbox" name="is_published" id="is_published" value="1"
                                   {{ old('is_published', $course->is_published) ? 'checked' : '' }}
                                   class="w-5 h-5 text-green-600 border-gray-300 rounded focus:ring-green-500">
                            <label for="is_published" class="mr-3 text-sm font-bold text-gray-700 flex items-center gap-2 cursor-pointer">
                                <i class="fas fa-globe text-green-500"></i>
                                نشر الدورة (متاحة للطلاب)
                            </label>
                        </div>

                        <div class="flex items-center bg-yellow-50 border-2 border-yellow-200 rounded-xl p-4 hover:bg-yellow-100 transition-colors cursor-pointer">
                            <input type="checkbox" name="featured" id="featured" value="1"
                                   {{ old('featured', $course->featured) ? 'checked' : '' }}
                                   class="w-5 h-5 text-yellow-600 border-gray-300 rounded focus:ring-yellow-500">
                            <label for="featured" class="mr-3 text-sm font-bold text-gray-700 flex items-center gap-2 cursor-pointer">
                                <i class="fas fa-star text-yellow-500"></i>
                                دورة مميزة
                            </label>
                        </div>

                        <div class="flex items-center bg-blue-50 border-2 border-blue-200 rounded-xl p-4 hover:bg-blue-100 transition-colors cursor-pointer">
                            <input type="checkbox" name="certificate_available" id="certificate_available" value="1"
                                   {{ old('certificate_available', $course->certificate_available ?? 1) ? 'checked' : '' }}
                                   class="w-5 h-5 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
                            <label for="certificate_available" class="mr-3 text-sm font-bold text-gray-700 flex items-center gap-2 cursor-pointer">
                                <i class="fas fa-certificate text-blue-500"></i>
                                توفير شهادة إتمام
                            </label>
                        </div>
                    </div>
                </div>

                <!-- Tags -->
                <div class="bg-white rounded-xl shadow-lg p-6 border-r-4 border-indigo-500">
                    <div class="flex items-center gap-3 mb-4">
                        <div class="w-10 h-10 bg-gradient-to-br from-indigo-500 to-indigo-600 rounded-lg flex items-center justify-center text-white">
                            <i class="fas fa-tags"></i>
                        </div>
                        <h3 class="text-xl font-bold text-gray-900">الوسوم</h3>
                    </div>
                    <input type="text" name="tags" value="{{ old('tags', $course->tags) }}" placeholder="برمجة, تصميم, تطوير"
                           class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-indigo-500">
                    <p class="text-xs text-gray-500 mt-2 flex items-center gap-1">
                        <i class="fas fa-info-circle"></i>
                        افصل بين الوسوم بفاصلة
                    </p>
                </div>

                <!-- Quick Actions -->
                <div class="bg-gradient-to-br from-blue-500 to-indigo-500 rounded-xl shadow-lg p-6 text-white">
                    <h3 class="text-lg font-bold mb-4 flex items-center gap-2">
                        <i class="fas fa-bolt"></i>
                        إجراءات سريعة
                    </h3>
                    <div class="space-y-3">
                        <a href="{{ route('admin.courses.show', $course) }}"
                           class="block w-full px-4 py-3 bg-white bg-opacity-20 hover:bg-opacity-30 rounded-lg text-center transition-all font-semibold backdrop-blur-sm">
                            <i class="fas fa-eye ml-2"></i>عرض الدورة
                        </a>
                        <a href="{{ route('admin.courses.show', $course) }}#modules"
                           class="block w-full px-4 py-3 bg-white bg-opacity-20 hover:bg-opacity-30 rounded-lg text-center transition-all font-semibold backdrop-blur-sm">
                            <i class="fas fa-plus ml-2"></i>إضافة وحدة جديدة
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="bg-white rounded-xl shadow-lg p-6">
            <div class="flex flex-col sm:flex-row justify-end gap-4">
                <a href="{{ route('admin.courses.index') }}"
                   class="px-8 py-4 border-2 border-gray-300 rounded-xl text-gray-700 hover:bg-gray-50 font-bold transition-all flex items-center justify-center gap-2">
                    <i class="fas fa-times"></i>
                    <span>إلغاء</span>
                </a>
                <button type="submit"
                        class="px-8 py-4 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white rounded-xl font-bold flex items-center justify-center gap-2 shadow-lg hover:shadow-xl transition-all">
                    <i class="fas fa-save"></i>
                    <span>حفظ التعديلات</span>
                </button>
            </div>
        </div>
    </form>
</div>
@endsection
