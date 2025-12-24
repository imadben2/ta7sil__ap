@extends('layouts.admin')

@section('title', 'تعديل العرض الترويجي')
@section('page-title', 'تعديل العرض الترويجي')
@section('page-description', 'تعديل بيانات العرض الترويجي "{{ $promo->title }}"')

@section('content')
<div class="max-w-4xl mx-auto">
    <form action="{{ route('admin.promos.update', $promo) }}" method="POST" enctype="multipart/form-data" class="space-y-6">
        @csrf
        @method('PUT')

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
                    <input type="text" name="title" value="{{ old('title', $promo->title) }}"
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
                    <input type="text" name="subtitle" value="{{ old('subtitle', $promo->subtitle) }}"
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
                    <input type="text" name="badge" value="{{ old('badge', $promo->badge) }}"
                           class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                           placeholder="مثال: جديد، تحدي، عرض محدود">
                </div>

                <!-- Action Text -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        نص الزر
                    </label>
                    <input type="text" name="action_text" value="{{ old('action_text', $promo->action_text) }}"
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
                        <option value="timer" {{ old('icon_name', $promo->icon_name) == 'timer' ? 'selected' : '' }}>timer - مؤقت (للعد التنازلي)</option>
                        <option value="school" {{ old('icon_name', $promo->icon_name) == 'school' ? 'selected' : '' }}>school - مدرسة</option>
                        <option value="emoji_events" {{ old('icon_name', $promo->icon_name) == 'emoji_events' ? 'selected' : '' }}>emoji_events - كأس</option>
                        <option value="assignment" {{ old('icon_name', $promo->icon_name) == 'assignment' ? 'selected' : '' }}>assignment - مهمة</option>
                        <option value="people" {{ old('icon_name', $promo->icon_name) == 'people' ? 'selected' : '' }}>people - أشخاص</option>
                        <option value="calendar_month" {{ old('icon_name', $promo->icon_name) == 'calendar_month' ? 'selected' : '' }}>calendar_month - تقويم</option>
                        <option value="celebration" {{ old('icon_name', $promo->icon_name) == 'celebration' ? 'selected' : '' }}>celebration - احتفال</option>
                        <option value="star" {{ old('icon_name', $promo->icon_name) == 'star' ? 'selected' : '' }}>star - نجمة</option>
                        <option value="bolt" {{ old('icon_name', $promo->icon_name) == 'bolt' ? 'selected' : '' }}>bolt - صاعقة</option>
                        <option value="rocket" {{ old('icon_name', $promo->icon_name) == 'rocket' ? 'selected' : '' }}>rocket - صاروخ</option>
                        <option value="book" {{ old('icon_name', $promo->icon_name) == 'book' ? 'selected' : '' }}>book - كتاب</option>
                        <option value="hourglass_empty" {{ old('icon_name', $promo->icon_name) == 'hourglass_empty' ? 'selected' : '' }}>hourglass_empty - ساعة رملية</option>
                        <option value="alarm" {{ old('icon_name', $promo->icon_name) == 'alarm' ? 'selected' : '' }}>alarm - منبه</option>
                        <option value="schedule" {{ old('icon_name', $promo->icon_name) == 'schedule' ? 'selected' : '' }}>schedule - جدول</option>
                    </select>
                </div>

                <!-- Current Image & Upload -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        الصورة
                    </label>
                    @if($promo->image_url)
                        <div id="currentImageContainer" class="mb-3">
                            <p class="text-xs text-gray-500 mb-2">الصورة الحالية:</p>
                            <div class="relative inline-block">
                                <img src="{{ $promo->image_url }}" alt="الصورة الحالية" class="w-24 h-24 object-cover rounded-xl border border-gray-200">
                                <button type="button" id="removeCurrentImage" class="absolute -top-2 -right-2 w-6 h-6 bg-red-500 text-white rounded-full flex items-center justify-center hover:bg-red-600 transition-colors">
                                    <i class="fas fa-times text-xs"></i>
                                </button>
                            </div>
                            <input type="hidden" name="remove_image" id="removeImageFlag" value="0">
                        </div>
                    @endif
                    <div class="relative">
                        <input type="file" name="image" id="imageInput" accept="image/*"
                               class="hidden">
                        <label for="imageInput"
                               class="flex items-center justify-center gap-2 w-full px-4 py-3 border-2 border-dashed border-gray-300 rounded-xl cursor-pointer hover:border-blue-500 hover:bg-blue-50/50 transition-all">
                            <i class="fas fa-cloud-upload-alt text-gray-400"></i>
                            <span class="text-gray-500">{{ $promo->image_url ? 'استبدال الصورة' : 'رفع صورة' }}</span>
                        </label>
                        <p class="mt-1 text-xs text-gray-400">PNG, JPG, GIF, WebP - حد أقصى 2MB</p>
                        @error('image')
                            <p class="mt-1 text-sm text-red-500">{{ $message }}</p>
                        @enderror
                    </div>
                    <!-- New Image Preview -->
                    <div id="imagePreviewContainer" class="mt-3 hidden">
                        <p class="text-xs text-green-600 mb-2">الصورة الجديدة:</p>
                        <div class="relative inline-block">
                            <img id="imagePreview" src="" alt="معاينة" class="w-24 h-24 object-cover rounded-xl border border-green-200">
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
                    <input type="url" name="image_url" id="imageUrlInput" value="{{ old('image_url', $promo->image_url) }}" dir="ltr"
                           class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                           placeholder="https://example.com/image.png">
                    <p class="mt-1 text-xs text-gray-400">سيتم استخدام الصورة المرفوعة إذا تم تحديدها</p>
                </div>

                @php
                    $gradientColors = $promo->gradient_colors ?? ['#3B82F6', '#1D4ED8'];
                    $gradientStart = $gradientColors[0] ?? '#3B82F6';
                    $gradientEnd = $gradientColors[1] ?? '#1D4ED8';
                @endphp

                <!-- Gradient Start -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        لون التدرج (البداية)
                    </label>
                    <div class="flex gap-3">
                        <input type="color" name="gradient_start" value="{{ old('gradient_start', $gradientStart) }}"
                               class="w-14 h-12 rounded-lg border border-gray-200 cursor-pointer">
                        <input type="text" id="gradient_start_text" value="{{ old('gradient_start', $gradientStart) }}" dir="ltr"
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
                        <input type="color" name="gradient_end" value="{{ old('gradient_end', $gradientEnd) }}"
                               class="w-14 h-12 rounded-lg border border-gray-200 cursor-pointer">
                        <input type="text" id="gradient_end_text" value="{{ old('gradient_end', $gradientEnd) }}" dir="ltr"
                               class="flex-1 px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent font-mono"
                               placeholder="#1D4ED8">
                    </div>
                </div>

                <!-- Preview -->
                <div class="md:col-span-2">
                    <label class="block text-sm font-semibold text-gray-700 mb-2">معاينة التدرج</label>
                    <div id="gradientPreview" class="h-20 rounded-xl shadow-inner" style="background: linear-gradient(135deg, {{ $gradientStart }}, {{ $gradientEnd }});"></div>
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
                        <option value="route" {{ old('action_type', $promo->action_type) == 'route' ? 'selected' : '' }}>مسار داخلي (Route)</option>
                        <option value="url" {{ old('action_type', $promo->action_type) == 'url' ? 'selected' : '' }}>رابط خارجي (URL)</option>
                        <option value="none" {{ old('action_type', $promo->action_type) == 'none' ? 'selected' : '' }}>بدون إجراء</option>
                    </select>
                </div>

                <!-- Route Dropdown (for internal routes) -->
                <div id="routeSelectContainer" class="{{ old('action_type', $promo->action_type) != 'route' ? 'hidden' : '' }}">
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        اختر المسار
                    </label>
                    <select id="routeSelect" class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                        <option value="">اختر مسار من التطبيق...</option>
                        @foreach($availableRoutes as $route => $label)
                            <option value="{{ $route }}" {{ old('action_value', $promo->action_value) == $route ? 'selected' : '' }}>{{ $label }} ({{ $route }})</option>
                        @endforeach
                    </select>
                </div>

                <!-- URL Input (for external links) -->
                <div id="urlInputContainer" class="{{ old('action_type', $promo->action_type) != 'url' ? 'hidden' : '' }}">
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        الرابط الخارجي
                    </label>
                    <input type="url" id="urlInput" value="{{ old('action_type', $promo->action_type) == 'url' ? old('action_value', $promo->action_value) : '' }}" dir="ltr"
                           class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                           placeholder="https://example.com">
                </div>

                <!-- Hidden action_value field -->
                <input type="hidden" name="action_value" id="actionValue" value="{{ old('action_value', $promo->action_value) }}">
            </div>
        </div>

        <!-- Countdown Settings Card - Hidden by default, shown only for countdown type -->
        <div id="countdownSettingsCard" class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 {{ old('promo_type', $promo->promo_type) == 'countdown' ? '' : 'hidden' }}">
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
                    <input type="datetime-local" name="target_date" value="{{ old('target_date', $promo->target_date?->format('Y-m-d\TH:i')) }}"
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
                    <input type="text" name="countdown_label" value="{{ old('countdown_label', $promo->countdown_label ?? 'يوم على البكالوريا') }}"
                           class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                           placeholder="مثال: يوم على البكالوريا">
                </div>
            </div>

            <!-- Days Remaining Preview (for countdown type) -->
            @if($promo->promo_type == 'countdown' && $promo->target_date)
            <div id="countdownPreview" class="mt-6 p-4 bg-gradient-to-l from-blue-600 to-purple-600 rounded-xl text-white">
                <p class="text-sm opacity-80 mb-2">معاينة العد التنازلي:</p>
                <div class="flex items-center justify-center gap-4">
                    @php
                        $now = now();
                        $diff = $now->diff($promo->target_date);
                        $days = $diff->days;
                        $hours = $diff->h;
                        $minutes = $diff->i;
                        $seconds = $diff->s;
                    @endphp
                    <div class="text-center bg-white/20 rounded-lg px-4 py-2">
                        <span class="text-2xl font-bold">{{ $days }}</span>
                        <p class="text-xs opacity-80">يوم</p>
                    </div>
                    <div class="text-center bg-white/20 rounded-lg px-4 py-2">
                        <span class="text-2xl font-bold">{{ str_pad($hours, 2, '0', STR_PAD_LEFT) }}</span>
                        <p class="text-xs opacity-80">ساعة</p>
                    </div>
                    <div class="text-center bg-white/20 rounded-lg px-4 py-2">
                        <span class="text-2xl font-bold">{{ str_pad($minutes, 2, '0', STR_PAD_LEFT) }}</span>
                        <p class="text-xs opacity-80">دقيقة</p>
                    </div>
                    <div class="text-center bg-white/20 rounded-lg px-4 py-2">
                        <span class="text-2xl font-bold">{{ str_pad($seconds, 2, '0', STR_PAD_LEFT) }}</span>
                        <p class="text-xs opacity-80">ثانية</p>
                    </div>
                </div>
                <p class="text-center text-sm mt-2 opacity-80">{{ $promo->countdown_label ?? 'يوم على البكالوريا' }}</p>
            </div>
            @endif
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
                        <option value="default" {{ old('promo_type', $promo->promo_type) == 'default' ? 'selected' : '' }}>عادي</option>
                        <option value="countdown" {{ old('promo_type', $promo->promo_type) == 'countdown' ? 'selected' : '' }}>عد تنازلي</option>
                    </select>
                    <p class="mt-1 text-xs text-gray-400">عروض العد التنازلي تظهر أولاً</p>
                </div>

                <!-- Display Order -->
                <div id="displayOrderContainer">
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        ترتيب العرض
                    </label>
                    <input type="number" name="display_order" value="{{ old('display_order', $promo->display_order) }}" min="0"
                           class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                           {{ old('promo_type', $promo->promo_type) == 'countdown' ? 'disabled' : '' }}>
                    <p id="countdownOrderNote" class="mt-1 text-xs text-orange-500 {{ old('promo_type', $promo->promo_type) == 'countdown' ? '' : 'hidden' }}">عروض العد التنازلي دائماً في المرتبة 0</p>
                </div>

                <!-- Starts At -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        تاريخ البدء (اختياري)
                    </label>
                    <input type="datetime-local" name="starts_at" value="{{ old('starts_at', $promo->starts_at?->format('Y-m-d\TH:i')) }}"
                           class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                </div>

                <!-- Ends At -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        تاريخ الانتهاء (اختياري)
                    </label>
                    <input type="datetime-local" name="ends_at" value="{{ old('ends_at', $promo->ends_at?->format('Y-m-d\TH:i')) }}"
                           class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                </div>

                <!-- Is Active -->
                <div class="md:col-span-3">
                    <label class="flex items-center gap-3 cursor-pointer">
                        <input type="checkbox" name="is_active" value="1" {{ old('is_active', $promo->is_active) ? 'checked' : '' }}
                               class="w-5 h-5 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
                        <span class="font-semibold text-gray-700">تفعيل العرض</span>
                    </label>
                </div>
            </div>
        </div>

        <!-- Statistics Card -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
            <h3 class="text-lg font-bold text-gray-900 mb-6 flex items-center gap-2">
                <i class="fas fa-chart-bar text-blue-500"></i>
                إحصائيات العرض
            </h3>

            <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                <div class="bg-gray-50 rounded-xl p-4 text-center">
                    <p class="text-2xl font-bold text-blue-600">{{ number_format($promo->click_count) }}</p>
                    <p class="text-sm text-gray-500">النقرات</p>
                </div>
                <div class="bg-gray-50 rounded-xl p-4 text-center">
                    <p class="text-2xl font-bold text-gray-900">{{ $promo->display_order }}</p>
                    <p class="text-sm text-gray-500">الترتيب</p>
                </div>
                <div class="bg-gray-50 rounded-xl p-4 text-center">
                    <p class="text-2xl font-bold text-gray-900">{{ $promo->created_at->format('Y-m-d') }}</p>
                    <p class="text-sm text-gray-500">تاريخ الإنشاء</p>
                </div>
                <div class="bg-gray-50 rounded-xl p-4 text-center">
                    <p class="text-2xl font-bold {{ $promo->isCurrentlyActive() ? 'text-green-600' : 'text-red-600' }}">
                        {{ $promo->isCurrentlyActive() ? 'نشط' : 'غير نشط' }}
                    </p>
                    <p class="text-sm text-gray-500">الحالة الحالية</p>
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
            <div class="flex gap-3">
                <button type="button" onclick="confirmDelete({{ $promo->id }})"
                        class="px-6 py-3 bg-red-100 text-red-700 rounded-xl hover:bg-red-200 transition-colors">
                    <i class="fas fa-trash ml-2"></i>
                    حذف
                </button>
                <button type="submit"
                        class="px-8 py-3 bg-gradient-to-l from-blue-600 to-purple-600 text-white rounded-xl hover:from-blue-700 hover:to-purple-700 transition-all shadow-lg shadow-blue-500/25">
                    <i class="fas fa-save ml-2"></i>
                    حفظ التغييرات
                </button>
            </div>
        </div>
    </form>
</div>

<!-- Delete Confirmation Modal -->
<div id="deleteModal" class="fixed inset-0 bg-black/50 z-50 hidden items-center justify-center">
    <div class="bg-white rounded-2xl p-6 max-w-md w-full mx-4">
        <div class="text-center">
            <div class="w-16 h-16 rounded-full bg-red-100 flex items-center justify-center mx-auto mb-4">
                <i class="fas fa-trash-alt text-2xl text-red-600"></i>
            </div>
            <h3 class="text-xl font-bold text-gray-900 mb-2">تأكيد الحذف</h3>
            <p class="text-gray-500 mb-6">هل أنت متأكد من حذف هذا العرض؟ لا يمكن التراجع عن هذا الإجراء.</p>
            <div class="flex gap-3 justify-center">
                <button onclick="closeDeleteModal()" class="px-6 py-2.5 border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors">
                    إلغاء
                </button>
                <form action="{{ route('admin.promos.destroy', $promo) }}" method="POST" class="inline">
                    @csrf
                    @method('DELETE')
                    <button type="submit" class="px-6 py-2.5 bg-red-600 text-white rounded-xl hover:bg-red-700 transition-colors">
                        حذف
                    </button>
                </form>
            </div>
        </div>
    </div>
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
            }
            reader.readAsDataURL(file);
        }
    });

    removeImage.addEventListener('click', function() {
        imageInput.value = '';
        imagePreviewContainer.classList.add('hidden');
        imagePreview.src = '';
    });

    // Remove current image
    const removeCurrentImage = document.getElementById('removeCurrentImage');
    const currentImageContainer = document.getElementById('currentImageContainer');
    const removeImageFlag = document.getElementById('removeImageFlag');

    if (removeCurrentImage) {
        removeCurrentImage.addEventListener('click', function() {
            currentImageContainer.classList.add('hidden');
            removeImageFlag.value = '1';
            imageUrlInput.value = '';
        });
    }

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

function confirmDelete(id) {
    document.getElementById('deleteModal').classList.remove('hidden');
    document.getElementById('deleteModal').classList.add('flex');
}

function closeDeleteModal() {
    document.getElementById('deleteModal').classList.remove('flex');
    document.getElementById('deleteModal').classList.add('hidden');
}

document.getElementById('deleteModal').addEventListener('click', function(e) {
    if (e.target === this) {
        closeDeleteModal();
    }
});
</script>
@endpush
