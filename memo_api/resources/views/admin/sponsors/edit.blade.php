@extends('layouts.admin')

@section('title', 'تعديل الراعي')
@section('page-title', 'تعديل الراعي')
@section('page-description', 'تعديل بيانات الراعي "{{ $sponsor->name_ar }}"')

@section('content')
<div class="max-w-3xl mx-auto">
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100">
        <!-- Header -->
        <div class="p-6 border-b border-gray-100">
            <div class="flex items-center gap-4">
                <a href="{{ route('admin.sponsors.index') }}"
                   class="w-10 h-10 rounded-xl bg-gray-100 hover:bg-gray-200 flex items-center justify-center transition-colors">
                    <i class="fas fa-arrow-right text-gray-600"></i>
                </a>
                <div class="flex-1">
                    <h3 class="text-xl font-bold text-gray-900">تعديل الراعي</h3>
                    <p class="text-sm text-gray-500 mt-1">تعديل بيانات {{ $sponsor->name_ar }}</p>
                </div>
                <img src="{{ $sponsor->photo_url }}" alt="{{ $sponsor->name_ar }}" class="w-14 h-14 rounded-full object-cover border-4 border-purple-200">
            </div>
        </div>

        <!-- Form -->
        <form action="{{ route('admin.sponsors.update', $sponsor) }}" method="POST" enctype="multipart/form-data" class="p-6 space-y-6">
            @csrf
            @method('PUT')

            <!-- Name -->
            <div>
                <label for="name_ar" class="block text-sm font-semibold text-gray-700 mb-2">
                    الاسم (بالعربية) <span class="text-red-500">*</span>
                </label>
                <input type="text"
                       name="name_ar"
                       id="name_ar"
                       value="{{ old('name_ar', $sponsor->name_ar) }}"
                       class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all @error('name_ar') border-red-500 @enderror"
                       placeholder="مثال: أ. محمد العربي"
                       required>
                @error('name_ar')
                    <p class="mt-2 text-sm text-red-600">{{ $message }}</p>
                @enderror
            </div>

            <!-- Title -->
            <div>
                <label for="title" class="block text-sm font-semibold text-gray-700 mb-2">
                    اللقب / الصفة
                </label>
                <input type="text"
                       name="title"
                       id="title"
                       value="{{ old('title', $sponsor->title) }}"
                       class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all @error('title') border-red-500 @enderror"
                       placeholder="مثال: أستاذ الرياضيات">
                @error('title')
                    <p class="mt-2 text-sm text-red-600">{{ $message }}</p>
                @enderror
            </div>

            <!-- Specialty -->
            <div>
                <label for="specialty" class="block text-sm font-semibold text-gray-700 mb-2">
                    التخصص / المادة
                </label>
                <input type="text"
                       name="specialty"
                       id="specialty"
                       value="{{ old('specialty', $sponsor->specialty) }}"
                       class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all @error('specialty') border-red-500 @enderror"
                       placeholder="مثال: الرياضيات، الفيزياء">
                @error('specialty')
                    <p class="mt-2 text-sm text-red-600">{{ $message }}</p>
                @enderror
            </div>

            <!-- Photo Section -->
            <div class="bg-gray-50 rounded-xl p-4">
                <h4 class="text-sm font-bold text-gray-700 mb-4 flex items-center gap-2">
                    <i class="fas fa-image text-purple-600"></i>
                    صورة الراعي
                </h4>

                <!-- Current Photo Preview -->
                <div class="flex items-start gap-6 mb-4">
                    <div class="flex-shrink-0">
                        <p class="text-xs text-gray-500 mb-2">الصورة الحالية:</p>
                        <img id="currentPhoto" src="{{ $sponsor->photo_url }}" alt="{{ $sponsor->name_ar }}" class="w-28 h-28 rounded-xl object-cover border-4 border-purple-200 shadow-lg">
                    </div>
                    <div id="newPhotoPreviewContainer" class="flex-shrink-0 hidden">
                        <p class="text-xs text-gray-500 mb-2">الصورة الجديدة:</p>
                        <img id="newPhotoPreview" src="" alt="معاينة" class="w-28 h-28 rounded-xl object-cover border-4 border-green-300 shadow-lg">
                    </div>
                </div>

                <!-- Upload Photo -->
                <div class="mb-4">
                    <label for="photo" class="block text-sm font-medium text-gray-700 mb-2">
                        رفع صورة جديدة
                    </label>
                    <div class="flex items-center gap-3">
                        <label for="photo" class="cursor-pointer flex items-center gap-2 px-4 py-2.5 bg-purple-100 text-purple-700 rounded-xl hover:bg-purple-200 transition-colors">
                            <i class="fas fa-upload"></i>
                            <span>اختر صورة</span>
                        </label>
                        <input type="file"
                               name="photo"
                               id="photo"
                               accept="image/jpeg,image/png,image/jpg,image/webp"
                               class="hidden">
                        <span id="fileName" class="text-sm text-gray-500">لم يتم اختيار ملف</span>
                    </div>
                    <p class="mt-2 text-xs text-gray-500">الصيغ المدعومة: JPG, PNG, WebP (الحد الأقصى: 2MB)</p>
                    @error('photo')
                        <p class="mt-2 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                </div>

                <div class="border-t border-gray-200 pt-4">
                    <p class="text-xs text-gray-500 mb-2">أو أدخل رابط الصورة مباشرة:</p>
                    <!-- Photo URL -->
                    <div>
                        <label for="photo_url" class="block text-sm font-medium text-gray-700 mb-2">
                            رابط الصورة
                        </label>
                        <input type="url"
                               name="photo_url"
                               id="photo_url"
                               value="{{ old('photo_url', $sponsor->photo_url) }}"
                               class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all @error('photo_url') border-red-500 @enderror"
                               placeholder="https://example.com/photo.jpg">
                        @error('photo_url')
                            <p class="mt-2 text-sm text-red-600">{{ $message }}</p>
                        @enderror
                        <p class="mt-1 text-xs text-gray-400">ملاحظة: في حال رفع صورة جديدة، سيتم تجاهل الرابط</p>
                    </div>
                </div>
            </div>

            <!-- Social Media Links Section -->
            <div class="bg-gray-50 rounded-xl p-4">
                <h4 class="text-sm font-bold text-gray-700 mb-4 flex items-center gap-2">
                    <i class="fas fa-share-alt text-purple-600"></i>
                    روابط التواصل الاجتماعي
                </h4>
                <p class="text-xs text-gray-500 mb-4">أضف روابط منصات التواصل الاجتماعي (اختياري - أضف الروابط المتوفرة فقط)</p>

                <div class="space-y-4">
                    <!-- YouTube Link -->
                    <div>
                        <label for="youtube_link" class="flex items-center gap-2 text-sm font-medium text-gray-700 mb-2">
                            <i class="fab fa-youtube text-red-500"></i>
                            رابط YouTube
                            @if($sponsor->youtube_clicks > 0)
                                <span class="text-xs text-gray-400">({{ number_format($sponsor->youtube_clicks) }} نقرة)</span>
                            @endif
                        </label>
                        <input type="url"
                               name="youtube_link"
                               id="youtube_link"
                               value="{{ old('youtube_link', $sponsor->youtube_link) }}"
                               class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-transparent transition-all @error('youtube_link') border-red-500 @enderror"
                               placeholder="https://youtube.com/@channel">
                        @error('youtube_link')
                            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                        @enderror
                    </div>

                    <!-- Facebook Link -->
                    <div>
                        <label for="facebook_link" class="flex items-center gap-2 text-sm font-medium text-gray-700 mb-2">
                            <i class="fab fa-facebook text-blue-600"></i>
                            رابط Facebook
                            @if($sponsor->facebook_clicks > 0)
                                <span class="text-xs text-gray-400">({{ number_format($sponsor->facebook_clicks) }} نقرة)</span>
                            @endif
                        </label>
                        <input type="url"
                               name="facebook_link"
                               id="facebook_link"
                               value="{{ old('facebook_link', $sponsor->facebook_link) }}"
                               class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all @error('facebook_link') border-red-500 @enderror"
                               placeholder="https://facebook.com/page">
                        @error('facebook_link')
                            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                        @enderror
                    </div>

                    <!-- Instagram Link -->
                    <div>
                        <label for="instagram_link" class="flex items-center gap-2 text-sm font-medium text-gray-700 mb-2">
                            <i class="fab fa-instagram text-pink-500"></i>
                            رابط Instagram
                            @if($sponsor->instagram_clicks > 0)
                                <span class="text-xs text-gray-400">({{ number_format($sponsor->instagram_clicks) }} نقرة)</span>
                            @endif
                        </label>
                        <input type="url"
                               name="instagram_link"
                               id="instagram_link"
                               value="{{ old('instagram_link', $sponsor->instagram_link) }}"
                               class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-pink-500 focus:border-transparent transition-all @error('instagram_link') border-red-500 @enderror"
                               placeholder="https://instagram.com/username">
                        @error('instagram_link')
                            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                        @enderror
                    </div>

                    <!-- Telegram Link -->
                    <div>
                        <label for="telegram_link" class="flex items-center gap-2 text-sm font-medium text-gray-700 mb-2">
                            <i class="fab fa-telegram text-blue-400"></i>
                            رابط Telegram
                            @if($sponsor->telegram_clicks > 0)
                                <span class="text-xs text-gray-400">({{ number_format($sponsor->telegram_clicks) }} نقرة)</span>
                            @endif
                        </label>
                        <input type="url"
                               name="telegram_link"
                               id="telegram_link"
                               value="{{ old('telegram_link', $sponsor->telegram_link) }}"
                               class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-400 focus:border-transparent transition-all @error('telegram_link') border-red-500 @enderror"
                               placeholder="https://t.me/channel">
                        @error('telegram_link')
                            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                        @enderror
                    </div>
                </div>
            </div>

            <!-- Display Order -->
            <div>
                <label for="display_order" class="block text-sm font-semibold text-gray-700 mb-2">
                    ترتيب العرض
                </label>
                <input type="number"
                       name="display_order"
                       id="display_order"
                       value="{{ old('display_order', $sponsor->display_order) }}"
                       min="0"
                       class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all @error('display_order') border-red-500 @enderror">
                @error('display_order')
                    <p class="mt-2 text-sm text-red-600">{{ $message }}</p>
                @enderror
            </div>

            <!-- Is Active -->
            <div class="flex items-center gap-3">
                <input type="checkbox"
                       name="is_active"
                       id="is_active"
                       value="1"
                       {{ old('is_active', $sponsor->is_active) ? 'checked' : '' }}
                       class="w-5 h-5 rounded border-gray-300 text-purple-600 focus:ring-purple-500">
                <label for="is_active" class="text-sm font-medium text-gray-700">
                    نشط (يظهر في التطبيق)
                </label>
            </div>

            <!-- Stats Info -->
            <div class="bg-gradient-to-br from-purple-50 to-indigo-50 rounded-xl p-5 border border-purple-100">
                <h4 class="text-sm font-bold text-gray-700 mb-4 flex items-center gap-2">
                    <i class="fas fa-chart-bar text-purple-600"></i>
                    إحصائيات النقرات
                </h4>

                <!-- Total Clicks -->
                <div class="bg-white rounded-xl p-4 mb-4 shadow-sm">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-3xl font-bold text-purple-600">{{ number_format($sponsor->click_count) }}</p>
                            <p class="text-sm text-gray-500">إجمالي النقرات</p>
                        </div>
                        <div class="w-14 h-14 bg-purple-100 rounded-xl flex items-center justify-center">
                            <i class="fas fa-mouse-pointer text-2xl text-purple-600"></i>
                        </div>
                    </div>
                </div>

                <!-- Platform-specific clicks -->
                <div class="grid grid-cols-2 md:grid-cols-4 gap-3 mb-4">
                    <!-- YouTube -->
                    <div class="bg-white rounded-xl p-3 shadow-sm border-r-4 border-red-500">
                        <div class="flex items-center gap-2 mb-1">
                            <i class="fab fa-youtube text-red-500"></i>
                            <span class="text-xs text-gray-500">YouTube</span>
                        </div>
                        <p class="text-xl font-bold text-gray-800">{{ number_format($sponsor->youtube_clicks) }}</p>
                    </div>

                    <!-- Facebook -->
                    <div class="bg-white rounded-xl p-3 shadow-sm border-r-4 border-blue-600">
                        <div class="flex items-center gap-2 mb-1">
                            <i class="fab fa-facebook text-blue-600"></i>
                            <span class="text-xs text-gray-500">Facebook</span>
                        </div>
                        <p class="text-xl font-bold text-gray-800">{{ number_format($sponsor->facebook_clicks) }}</p>
                    </div>

                    <!-- Instagram -->
                    <div class="bg-white rounded-xl p-3 shadow-sm border-r-4 border-pink-500">
                        <div class="flex items-center gap-2 mb-1">
                            <i class="fab fa-instagram text-pink-500"></i>
                            <span class="text-xs text-gray-500">Instagram</span>
                        </div>
                        <p class="text-xl font-bold text-gray-800">{{ number_format($sponsor->instagram_clicks) }}</p>
                    </div>

                    <!-- Telegram -->
                    <div class="bg-white rounded-xl p-3 shadow-sm border-r-4 border-blue-400">
                        <div class="flex items-center gap-2 mb-1">
                            <i class="fab fa-telegram text-blue-400"></i>
                            <span class="text-xs text-gray-500">Telegram</span>
                        </div>
                        <p class="text-xl font-bold text-gray-800">{{ number_format($sponsor->telegram_clicks) }}</p>
                    </div>
                </div>

                <!-- Other Info -->
                <div class="grid grid-cols-3 gap-3 pt-4 border-t border-purple-200">
                    <div class="text-center">
                        <p class="text-lg font-bold text-gray-700">{{ $sponsor->display_order }}</p>
                        <p class="text-xs text-gray-500">الترتيب</p>
                    </div>
                    <div class="text-center">
                        <p class="text-sm font-medium text-gray-700">{{ $sponsor->created_at->format('Y/m/d') }}</p>
                        <p class="text-xs text-gray-500">تاريخ الإضافة</p>
                    </div>
                    <div class="text-center">
                        <p class="text-sm font-medium text-gray-700">{{ $sponsor->updated_at->format('Y/m/d') }}</p>
                        <p class="text-xs text-gray-500">آخر تحديث</p>
                    </div>
                </div>

                <!-- Reset Clicks Button -->
                @if($sponsor->click_count > 0)
                <div class="mt-4 pt-4 border-t border-purple-200">
                    <button type="button" id="resetClicksBtn" class="w-full px-4 py-2 text-sm text-red-600 bg-red-50 hover:bg-red-100 rounded-xl transition-colors flex items-center justify-center gap-2">
                        <i class="fas fa-undo"></i>
                        إعادة تعيين جميع النقرات
                    </button>
                </div>
                @endif
            </div>

            <!-- Submit Buttons -->
            <div class="flex items-center justify-end gap-3 pt-6 border-t border-gray-100">
                <a href="{{ route('admin.sponsors.index') }}"
                   class="px-6 py-2.5 border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors">
                    إلغاء
                </a>
                <button type="submit"
                        class="px-6 py-2.5 bg-gradient-to-l from-purple-600 to-purple-700 text-white rounded-xl hover:from-purple-700 hover:to-purple-800 transition-all shadow-lg shadow-purple-500/25">
                    <i class="fas fa-save ml-2"></i>
                    حفظ التغييرات
                </button>
            </div>
        </form>
    </div>
</div>
@endsection

@push('scripts')
<script>
$(document).ready(function() {
    // File upload preview
    $('#photo').on('change', function(e) {
        const file = e.target.files[0];
        if (file) {
            // Validate file size (max 2MB)
            if (file.size > 2 * 1024 * 1024) {
                Swal.fire({
                    icon: 'error',
                    title: 'خطأ',
                    text: 'حجم الملف يجب أن يكون أقل من 2MB',
                    confirmButtonText: 'حسناً'
                });
                $(this).val('');
                return;
            }

            // Validate file type
            const allowedTypes = ['image/jpeg', 'image/png', 'image/jpg', 'image/webp'];
            if (!allowedTypes.includes(file.type)) {
                Swal.fire({
                    icon: 'error',
                    title: 'خطأ',
                    text: 'صيغة الملف غير مدعومة. استخدم JPG, PNG, أو WebP',
                    confirmButtonText: 'حسناً'
                });
                $(this).val('');
                return;
            }

            // Show file name
            $('#fileName').text(file.name);

            // Show preview
            const reader = new FileReader();
            reader.onload = function(e) {
                $('#newPhotoPreview').attr('src', e.target.result);
                $('#newPhotoPreviewContainer').removeClass('hidden');
            };
            reader.readAsDataURL(file);
        }
    });

    // Photo URL preview
    $('#photo_url').on('input', function() {
        const url = $(this).val();
        if (url && isValidUrl(url)) {
            $('#currentPhoto').attr('src', url);

            // Handle image load error
            $('#currentPhoto').on('error', function() {
                $(this).attr('src', '{{ $sponsor->photo_url }}');
            });
        }
    });

    function isValidUrl(string) {
        try {
            new URL(string);
            return true;
        } catch (_) {
            return false;
        }
    }

    // Reset clicks button
    $('#resetClicksBtn').on('click', function() {
        Swal.fire({
            title: 'هل أنت متأكد؟',
            text: 'سيتم إعادة تعيين جميع عدادات النقرات لهذا الراعي إلى صفر',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#dc2626',
            cancelButtonColor: '#6b7280',
            confirmButtonText: 'نعم، إعادة تعيين',
            cancelButtonText: 'إلغاء'
        }).then((result) => {
            if (result.isConfirmed) {
                $.ajax({
                    url: '{{ route("admin.sponsors.reset-clicks", $sponsor) }}',
                    type: 'POST',
                    data: {
                        _token: '{{ csrf_token() }}'
                    },
                    success: function(response) {
                        Swal.fire({
                            icon: 'success',
                            title: 'تم!',
                            text: response.message,
                            confirmButtonText: 'حسناً'
                        }).then(() => {
                            location.reload();
                        });
                    },
                    error: function() {
                        Swal.fire({
                            icon: 'error',
                            title: 'خطأ',
                            text: 'حدث خطأ أثناء إعادة تعيين النقرات',
                            confirmButtonText: 'حسناً'
                        });
                    }
                });
            }
        });
    });
});
</script>
@endpush
