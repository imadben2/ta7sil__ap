@extends('layouts.admin')

@section('title', 'إضافة عرض ترويجي جديد')
@section('page-title', 'إضافة عرض ترويجي جديد')
@section('page-description', 'إنشاء شريحة ترويجية جديدة للصفحة الرئيسية')

@section('content')
<div class="max-w-4xl mx-auto">
    <form action="{{ route('admin.promos.store') }}" method="POST" enctype="multipart/form-data" class="space-y-6">
        @csrf

        <!-- Basic Info Card -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
            <h3 class="text-lg font-bold text-gray-900 mb-6 flex items-center gap-2">
                <i class="fas fa-info-circle text-blue-500"></i>
                المعلومات الأساسية
            </h3>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <!-- Title -->
                <div class="md:col-span-2">
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        العنوان <span class="text-red-500">*</span>
                    </label>
                    <input type="text" name="title" value="{{ old('title') }}"
                           class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent @error('title') border-red-500 @enderror"
                           placeholder="مثال: دورات جديدة متاحة!" required>
                    @error('title')
                        <p class="mt-1 text-sm text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <!-- Subtitle -->
                <div class="md:col-span-2">
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        العنوان الفرعي
                    </label>
                    <input type="text" name="subtitle" value="{{ old('subtitle') }}"
                           class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent @error('subtitle') border-red-500 @enderror"
                           placeholder="مثال: اكتشف دوراتنا المتخصصة للبكالوريا">
                    @error('subtitle')
                        <p class="mt-1 text-sm text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <!-- Badge -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        الشارة (Badge)
                    </label>
                    <input type="text" name="badge" value="{{ old('badge') }}"
                           class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                           placeholder="مثال: جديد، تحدي، عرض محدود">
                </div>

                <!-- Action Text -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        نص الزر
                    </label>
                    <input type="text" name="action_text" value="{{ old('action_text') }}"
                           class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                           placeholder="مثال: اكتشف الآن">
                </div>
            </div>
        </div>

        <!-- Visual Style Card -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
            <h3 class="text-lg font-bold text-gray-900 mb-6 flex items-center gap-2">
                <i class="fas fa-palette text-purple-500"></i>
                المظهر والتصميم
            </h3>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <!-- Icon Name -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        اسم الأيقونة (Material Icon)
                    </label>
                    <select name="icon_name" class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                        <option value="">اختر أيقونة...</option>
                        <option value="timer" {{ old('icon_name') == 'timer' ? 'selected' : '' }}>timer - مؤقت (للعد التنازلي)</option>
                        <option value="school" {{ old('icon_name') == 'school' ? 'selected' : '' }}>school - مدرسة</option>
                        <option value="emoji_events" {{ old('icon_name') == 'emoji_events' ? 'selected' : '' }}>emoji_events - كأس</option>
                        <option value="assignment" {{ old('icon_name') == 'assignment' ? 'selected' : '' }}>assignment - مهمة</option>
                        <option value="people" {{ old('icon_name') == 'people' ? 'selected' : '' }}>people - أشخاص</option>
                        <option value="calendar_month" {{ old('icon_name') == 'calendar_month' ? 'selected' : '' }}>calendar_month - تقويم</option>
                        <option value="celebration" {{ old('icon_name') == 'celebration' ? 'selected' : '' }}>celebration - احتفال</option>
                        <option value="star" {{ old('icon_name') == 'star' ? 'selected' : '' }}>star - نجمة</option>
                        <option value="bolt" {{ old('icon_name') == 'bolt' ? 'selected' : '' }}>bolt - صاعقة</option>
                        <option value="rocket" {{ old('icon_name') == 'rocket' ? 'selected' : '' }}>rocket - صاروخ</option>
                        <option value="book" {{ old('icon_name') == 'book' ? 'selected' : '' }}>book - كتاب</option>
                        <option value="hourglass_empty" {{ old('icon_name') == 'hourglass_empty' ? 'selected' : '' }}>hourglass_empty - ساعة رملية</option>
                        <option value="alarm" {{ old('icon_name') == 'alarm' ? 'selected' : '' }}>alarm - منبه</option>
                        <option value="schedule" {{ old('icon_name') == 'schedule' ? 'selected' : '' }}>schedule - جدول</option>
                    </select>
                </div>

                <!-- Image Upload -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        رفع صورة
                    </label>
                    <div class="relative">
                        <input type="file" name="image" id="imageInput" accept="image/*"
                               class="hidden">
                        <label for="imageInput"
                               class="flex items-center justify-center gap-2 w-full px-4 py-3 border-2 border-dashed border-gray-300 rounded-xl cursor-pointer hover:border-blue-500 hover:bg-blue-50/50 transition-all">
                            <i class="fas fa-cloud-upload-alt text-gray-400"></i>
                            <span class="text-gray-500">اختر صورة أو اسحبها هنا</span>
                        </label>
                        <p class="mt-1 text-xs text-gray-400">PNG, JPG, GIF, WebP - حد أقصى 2MB</p>
                        @error('image')
                            <p class="mt-1 text-sm text-red-500">{{ $message }}</p>
                        @enderror
                    </div>
                    <!-- Image Preview -->
                    <div id="imagePreviewContainer" class="mt-3 hidden">
                        <div class="relative inline-block">
                            <img id="imagePreview" src="" alt="معاينة" class="w-24 h-24 object-cover rounded-xl border border-gray-200">
                            <button type="button" id="removeImage" class="absolute -top-2 -right-2 w-6 h-6 bg-red-500 text-white rounded-full flex items-center justify-center hover:bg-red-600 transition-colors">
                                <i class="fas fa-times text-xs"></i>
                            </button>
                        </div>
                    </div>
                </div>

                <!-- OR External URL -->
                <div class="md:col-span-2">
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        أو رابط صورة خارجي
                    </label>
                    <input type="url" name="image_url" id="imageUrlInput" value="{{ old('image_url') }}" dir="ltr"
                           class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                           placeholder="https://example.com/image.png">
                    <p class="mt-1 text-xs text-gray-400">سيتم استخدام الصورة المرفوعة إذا تم تحديدها، وإلا سيتم استخدام الرابط</p>
                </div>

                <!-- Gradient Start -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        لون التدرج (البداية)
                    </label>
                    <div class="flex gap-3">
                        <input type="color" name="gradient_start" value="{{ old('gradient_start', '#3B82F6') }}"
                               class="w-14 h-12 rounded-lg border border-gray-200 cursor-pointer">
                        <input type="text" id="gradient_start_text" value="{{ old('gradient_start', '#3B82F6') }}" dir="ltr"
                               class="flex-1 px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent font-mono"
                               placeholder="#3B82F6">
                    </div>
                </div>

                <!-- Gradient End -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        لون التدرج (النهاية)
                    </label>
                    <div class="flex gap-3">
                        <input type="color" name="gradient_end" value="{{ old('gradient_end', '#1D4ED8') }}"
                               class="w-14 h-12 rounded-lg border border-gray-200 cursor-pointer">
                        <input type="text" id="gradient_end_text" value="{{ old('gradient_end', '#1D4ED8') }}" dir="ltr"
                               class="flex-1 px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent font-mono"
                               placeholder="#1D4ED8">
                    </div>
                </div>

                <!-- Preview -->
                <div class="md:col-span-2">
                    <label class="block text-sm font-semibold text-gray-700 mb-2">معاينة التدرج</label>
                    <div id="gradientPreview" class="h-20 rounded-xl shadow-inner" style="background: linear-gradient(135deg, #3B82F6, #1D4ED8);"></div>
                </div>
            </div>
        </div>

        <!-- Action Card -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
            <h3 class="text-lg font-bold text-gray-900 mb-6 flex items-center gap-2">
                <i class="fas fa-link text-green-500"></i>
                الإجراء عند النقر
            </h3>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <!-- Action Type -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        نوع الإجراء <span class="text-red-500">*</span>
                    </label>
                    <select name="action_type" id="actionType" required
                            class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                        <option value="route" {{ old('action_type', 'route') == 'route' ? 'selected' : '' }}>مسار داخلي (Route)</option>
                        <option value="url" {{ old('action_type') == 'url' ? 'selected' : '' }}>رابط خارجي (URL)</option>
                        <option value="none" {{ old('action_type') == 'none' ? 'selected' : '' }}>بدون إجراء</option>
                    </select>
                </div>

                <!-- Route Dropdown (for internal routes) -->
                <div id="routeSelectContainer">
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        اختر المسار
                    </label>
                    <select id="routeSelect" class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                        <option value="">اختر مسار من التطبيق...</option>
                        @foreach($availableRoutes as $route => $label)
                            <option value="{{ $route }}" {{ old('action_value') == $route ? 'selected' : '' }}>{{ $label }} ({{ $route }})</option>
                        @endforeach
                    </select>
                </div>

                <!-- URL Input (for external links) -->
                <div id="urlInputContainer" class="hidden">
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        الرابط الخارجي
                    </label>
                    <input type="url" id="urlInput" value="{{ old('action_value') }}" dir="ltr"
                           class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                           placeholder="https://example.com">
                </div>

                <!-- Hidden action_value field -->
                <input type="hidden" name="action_value" id="actionValue" value="{{ old('action_value') }}">
            </div>
        </div>

        <!-- Countdown Settings Card - Hidden by default, shown only for countdown type -->
        <div id="countdownSettingsCard" class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 {{ old('promo_type') == 'countdown' ? '' : 'hidden' }}">
            <h3 class="text-lg font-bold text-gray-900 mb-6 flex items-center gap-2">
                <i class="fas fa-clock text-orange-500"></i>
                إعدادات العد التنازلي
            </h3>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <!-- Target Date -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        التاريخ المستهدف <span class="text-red-500">*</span>
                    </label>
                    <input type="datetime-local" name="target_date" value="{{ old('target_date') }}"
                           class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent @error('target_date') border-red-500 @enderror">
                    <p class="mt-1 text-xs text-gray-400">مثال: تاريخ امتحان البكالوريا</p>
                    @error('target_date')
                        <p class="mt-1 text-sm text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                <!-- Countdown Label -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        تسمية العد التنازلي
                    </label>
                    <input type="text" name="countdown_label" value="{{ old('countdown_label', 'يوم على البكالوريا') }}"
                           class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                           placeholder="مثال: يوم على البكالوريا">
                </div>
            </div>
        </div>

        <!-- Settings Card -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
            <h3 class="text-lg font-bold text-gray-900 mb-6 flex items-center gap-2">
                <i class="fas fa-cog text-gray-500"></i>
                الإعدادات
            </h3>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                <!-- Promo Type -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        نوع العرض
                    </label>
                    <select name="promo_type" id="promoType"
                            class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                        <option value="default" {{ old('promo_type', 'default') == 'default' ? 'selected' : '' }}>عادي</option>
                        <option value="countdown" {{ old('promo_type') == 'countdown' ? 'selected' : '' }}>عد تنازلي</option>
                    </select>
                    <p class="mt-1 text-xs text-gray-400">عروض العد التنازلي تظهر أولاً</p>
                </div>

                <!-- Display Order -->
                <div id="displayOrderContainer">
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        ترتيب العرض
                    </label>
                    <input type="number" name="display_order" value="{{ old('display_order', 1) }}" min="0"
                           class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                    <p id="countdownOrderNote" class="mt-1 text-xs text-orange-500 hidden">عروض العد التنازلي دائماً في المرتبة 0</p>
                </div>

                <!-- Starts At -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        تاريخ البدء (اختياري)
                    </label>
                    <input type="datetime-local" name="starts_at" value="{{ old('starts_at') }}"
                           class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                </div>

                <!-- Ends At -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        تاريخ الانتهاء (اختياري)
                    </label>
                    <input type="datetime-local" name="ends_at" value="{{ old('ends_at') }}"
                           class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                </div>

                <!-- Is Active -->
                <div class="md:col-span-3">
                    <label class="flex items-center gap-3 cursor-pointer">
                        <input type="checkbox" name="is_active" value="1" {{ old('is_active', true) ? 'checked' : '' }}
                               class="w-5 h-5 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
                        <span class="font-semibold text-gray-700">تفعيل العرض فوراً</span>
                    </label>
                </div>
            </div>
        </div>

        <!-- Submit Buttons -->
        <div class="flex items-center justify-between">
            <a href="{{ route('admin.promos.index') }}"
               class="px-6 py-3 border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors">
                <i class="fas fa-arrow-right ml-2"></i>
                رجوع
            </a>
            <button type="submit"
                    class="px-8 py-3 bg-gradient-to-l from-blue-600 to-purple-600 text-white rounded-xl hover:from-blue-700 hover:to-purple-700 transition-all shadow-lg shadow-blue-500/25">
                <i class="fas fa-save ml-2"></i>
                حفظ العرض
            </button>
        </div>
    </form>
</div>
@endsection

@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', function() {
    // Gradient color sync
    const gradientStart = document.querySelector('input[name="gradient_start"]');
    const gradientEnd = document.querySelector('input[name="gradient_end"]');
    const gradientStartText = document.getElementById('gradient_start_text');
    const gradientEndText = document.getElementById('gradient_end_text');
    const gradientPreview = document.getElementById('gradientPreview');

    function updatePreview() {
        gradientPreview.style.background = `linear-gradient(135deg, ${gradientStart.value}, ${gradientEnd.value})`;
    }

    gradientStart.addEventListener('input', function() {
        gradientStartText.value = this.value;
        updatePreview();
    });

    gradientEnd.addEventListener('input', function() {
        gradientEndText.value = this.value;
        updatePreview();
    });

    gradientStartText.addEventListener('input', function() {
        if (/^#[0-9A-Fa-f]{6}$/.test(this.value)) {
            gradientStart.value = this.value;
            updatePreview();
        }
    });

    gradientEndText.addEventListener('input', function() {
        if (/^#[0-9A-Fa-f]{6}$/.test(this.value)) {
            gradientEnd.value = this.value;
            updatePreview();
        }
    });

    // Action type change
    const actionType = document.getElementById('actionType');
    const routeSelectContainer = document.getElementById('routeSelectContainer');
    const urlInputContainer = document.getElementById('urlInputContainer');
    const routeSelect = document.getElementById('routeSelect');
    const urlInput = document.getElementById('urlInput');
    const actionValue = document.getElementById('actionValue');

    function updateActionFields() {
        const type = actionType.value;

        if (type === 'route') {
            routeSelectContainer.classList.remove('hidden');
            urlInputContainer.classList.add('hidden');
            actionValue.value = routeSelect.value;
        } else if (type === 'url') {
            routeSelectContainer.classList.add('hidden');
            urlInputContainer.classList.remove('hidden');
            actionValue.value = urlInput.value;
        } else {
            routeSelectContainer.classList.add('hidden');
            urlInputContainer.classList.add('hidden');
            actionValue.value = '';
        }
    }

    actionType.addEventListener('change', updateActionFields);
    routeSelect.addEventListener('change', function() {
        actionValue.value = this.value;
    });
    urlInput.addEventListener('input', function() {
        actionValue.value = this.value;
    });

    // Initialize
    updateActionFields();

    // Image upload preview
    const imageInput = document.getElementById('imageInput');
    const imagePreviewContainer = document.getElementById('imagePreviewContainer');
    const imagePreview = document.getElementById('imagePreview');
    const removeImage = document.getElementById('removeImage');
    const imageUrlInput = document.getElementById('imageUrlInput');

    imageInput.addEventListener('change', function(e) {
        const file = e.target.files[0];
        if (file) {
            // Validate file size (2MB max)
            if (file.size > 2 * 1024 * 1024) {
                alert('حجم الملف يجب أن لا يتجاوز 2MB');
                this.value = '';
                return;
            }

            const reader = new FileReader();
            reader.onload = function(e) {
                imagePreview.src = e.target.result;
                imagePreviewContainer.classList.remove('hidden');
                // Clear URL input when file is selected
                imageUrlInput.value = '';
            }
            reader.readAsDataURL(file);
        }
    });

    removeImage.addEventListener('click', function() {
        imageInput.value = '';
        imagePreviewContainer.classList.add('hidden');
        imagePreview.src = '';
    });

    // Drag and drop support
    const dropZone = document.querySelector('label[for="imageInput"]');

    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
        dropZone.addEventListener(eventName, preventDefaults, false);
    });

    function preventDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }

    ['dragenter', 'dragover'].forEach(eventName => {
        dropZone.addEventListener(eventName, () => {
            dropZone.classList.add('border-blue-500', 'bg-blue-50');
        });
    });

    ['dragleave', 'drop'].forEach(eventName => {
        dropZone.addEventListener(eventName, () => {
            dropZone.classList.remove('border-blue-500', 'bg-blue-50');
        });
    });

    dropZone.addEventListener('drop', function(e) {
        const dt = e.dataTransfer;
        const files = dt.files;
        if (files.length) {
            imageInput.files = files;
            imageInput.dispatchEvent(new Event('change'));
        }
    });

    // Promo type change (countdown fields)
    const promoType = document.getElementById('promoType');
    const countdownSettingsCard = document.getElementById('countdownSettingsCard');
    const displayOrderContainer = document.getElementById('displayOrderContainer');
    const countdownOrderNote = document.getElementById('countdownOrderNote');

    function updateCountdownFields() {
        const isCountdown = promoType.value === 'countdown';

        if (isCountdown) {
            countdownSettingsCard.classList.remove('hidden');
            countdownOrderNote.classList.remove('hidden');
            displayOrderContainer.querySelector('input').disabled = true;
            displayOrderContainer.querySelector('input').value = 0;
        } else {
            countdownSettingsCard.classList.add('hidden');
            countdownOrderNote.classList.add('hidden');
            displayOrderContainer.querySelector('input').disabled = false;
        }
    }

    promoType.addEventListener('change', updateCountdownFields);

    // Initialize countdown fields
    updateCountdownFields();
});
</script>
@endpush
