@extends('layouts.admin')

@section('title', 'تعديل باقة اشتراك')
@section('page-title', 'تعديل باقة: ' . $package->name_ar)

@section('content')
<form action="{{ route('admin.subscriptions.packages.update', $package) }}" method="POST" class="max-w-4xl mx-auto space-y-6" enctype="multipart/form-data">
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

        <!-- Customization -->
        <div>
            <h3 class="text-lg font-semibold text-gray-900 mb-4 border-b pb-2">التخصيص والمظهر</h3>
            <p class="text-sm text-gray-600 mb-3">خصص مظهر الباقة في التطبيق (صورة، شارة، لون الخلفية)</p>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <!-- Image Upload -->
                <div class="md:col-span-2">
                    <label class="block text-sm font-medium text-gray-700 mb-2">صورة الباقة (اختياري)</label>
                    <div class="flex items-center gap-4">
                        <div id="image-preview" class="w-32 h-32 bg-gray-100 rounded-xl border-2 border-dashed border-gray-300 flex items-center justify-center overflow-hidden">
                            @if($package->image_url)
                                <img src="{{ asset('storage/' . $package->image_url) }}" class="w-full h-full object-cover">
                            @else
                                <i class="fas fa-image text-gray-400 text-3xl"></i>
                            @endif
                        </div>
                        <div class="flex-1">
                            <input type="file" name="image" id="image" accept="image/*"
                                   class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 @error('image') border-red-500 @enderror"
                                   onchange="previewImage(this)">
                            <p class="text-xs text-gray-500 mt-1">الحجم الأقصى: 2MB | الصيغ: JPG, PNG, GIF, WEBP</p>
                            @if($package->image_url)
                                <div class="mt-2">
                                    <label class="flex items-center text-sm text-red-600 cursor-pointer">
                                        <input type="checkbox" name="remove_image" value="1" class="ml-2 h-4 w-4 text-red-600 focus:ring-red-500 border-gray-300 rounded">
                                        حذف الصورة الحالية
                                    </label>
                                </div>
                            @endif
                            @error('image')
                                <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                            @enderror
                        </div>
                    </div>
                </div>

                <!-- Badge Text -->
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">نص الشارة (اختياري)</label>
                    <input type="text" name="badge_text" value="{{ old('badge_text', $package->badge_text) }}"
                           class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 @error('badge_text') border-red-500 @enderror"
                           placeholder="مثال: الأكثر شعبية، خصم 20%">
                    @error('badge_text')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                    @enderror
                </div>

                <!-- Background Color -->
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">لون الخلفية (اختياري)</label>
                    <div class="flex items-center gap-3">
                        <input type="color" name="background_color" id="background_color" value="{{ old('background_color', $package->background_color ?? '#3B82F6') }}"
                               class="w-16 h-10 rounded-lg border border-gray-300 cursor-pointer">
                        <input type="text" id="background_color_text" value="{{ old('background_color', $package->background_color ?? '') }}"
                               class="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                               placeholder="#3B82F6" pattern="^#[A-Fa-f0-9]{6}$">
                        <button type="button" onclick="clearBackgroundColor()" class="px-3 py-2 bg-gray-100 hover:bg-gray-200 rounded-lg text-gray-600">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                    @error('background_color')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                    @enderror
                </div>

                <!-- Sort Order -->
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">ترتيب العرض</label>
                    <input type="number" name="sort_order" value="{{ old('sort_order', $package->sort_order ?? 0) }}" min="0"
                           class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 @error('sort_order') border-red-500 @enderror"
                           placeholder="0">
                    <p class="text-xs text-gray-500 mt-1">الرقم الأصغر يظهر أولاً</p>
                    @error('sort_order')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                    @enderror
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

@push('scripts')
<script>
    // Sync color picker with text input
    document.addEventListener('DOMContentLoaded', function() {
        const colorPicker = document.getElementById('background_color');
        const colorText = document.getElementById('background_color_text');

        if (colorPicker && colorText) {
            colorPicker.addEventListener('input', function() {
                colorText.value = this.value;
            });

            colorText.addEventListener('input', function() {
                if (/^#[A-Fa-f0-9]{6}$/.test(this.value)) {
                    colorPicker.value = this.value;
                }
            });
        }
    });

    // Image preview function
    function previewImage(input) {
        const preview = document.getElementById('image-preview');
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = function(e) {
                preview.innerHTML = '<img src="' + e.target.result + '" class="w-full h-full object-cover">';
            }
            reader.readAsDataURL(input.files[0]);
        }
    }

    // Clear background color
    function clearBackgroundColor() {
        document.getElementById('background_color').value = '#3B82F6';
        document.getElementById('background_color_text').value = '';
        document.querySelector('input[name="background_color"]').value = '';
    }
</script>
@endpush
