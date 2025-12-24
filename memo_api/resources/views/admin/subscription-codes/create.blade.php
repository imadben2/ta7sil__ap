@extends('layouts.admin')

@section('title', 'توليد أكواد اشتراك')
@section('page-title', 'توليد أكواد اشتراك جديدة')

@section('content')
<div class="space-y-6" style="font-family: 'Cairo', sans-serif; direction: rtl;">
    <!-- Enhanced Header with Gradient -->
    <div class="bg-gradient-to-r from-purple-600 to-pink-600 rounded-2xl shadow-xl p-8">
        <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
            <div class="text-white">
                <h2 class="text-3xl font-bold mb-3 flex items-center gap-3">
                    <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center">
                        <i class="fas fa-ticket-alt text-3xl"></i>
                    </div>
                    <span>توليد أكواد اشتراك جديدة</span>
                </h2>
                <p class="text-purple-100 text-lg">قم بإنشاء أكواد اشتراك للدورات والباقات التعليمية بسهولة</p>
            </div>
            <a href="{{ route('admin.subscription-codes.index') }}"
               class="bg-white text-purple-600 hover:bg-purple-50 px-6 py-3 rounded-xl flex items-center gap-2 transition-all shadow-md hover:shadow-lg font-semibold">
                <span>العودة للقائمة</span>
                <i class="fas fa-arrow-left"></i>
            </a>
        </div>
    </div>

    <!-- Main Form -->
    <form action="{{ route('admin.subscription-codes.store') }}" method="POST" class="space-y-6">
        @csrf

        <!-- Step 1: Code Type Selection -->
        <div class="bg-white rounded-2xl shadow-xl overflow-hidden">
            <div class="bg-gradient-to-r from-indigo-600 to-purple-600 px-8 py-5">
                <h3 class="text-2xl font-bold text-white flex items-center gap-3">
                    <div class="w-10 h-10 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                        <span class="text-xl font-bold">1</span>
                    </div>
                    اختر نوع الكود
                </h3>
            </div>
            <div class="p-8">
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <!-- Single Course -->
                    <label class="cursor-pointer group">
                        <input type="radio" name="code_type" value="single_course" class="hidden peer" onchange="toggleCodeTypeFields(this.value)">
                        <div class="relative border-3 border-gray-200 rounded-2xl p-6 transition-all hover:border-blue-400 hover:shadow-xl peer-checked:border-blue-500 peer-checked:bg-blue-50 peer-checked:shadow-2xl">
                            <div class="absolute top-4 left-4 w-6 h-6 rounded-full border-2 border-gray-300 peer-checked:border-blue-500 peer-checked:bg-blue-500 flex items-center justify-center">
                                <i class="fas fa-check text-white text-xs hidden peer-checked:block"></i>
                            </div>
                            <div class="text-center">
                                <div class="w-20 h-20 bg-gradient-to-br from-blue-500 to-cyan-500 rounded-2xl flex items-center justify-center mx-auto mb-4">
                                    <i class="fas fa-video text-white text-3xl"></i>
                                </div>
                                <h4 class="text-xl font-bold text-gray-900 mb-2">دورة واحدة</h4>
                                <p class="text-gray-600 text-sm">إنشاء كود لدورة تعليمية واحدة</p>
                            </div>
                        </div>
                    </label>

                    <!-- Package -->
                    <label class="cursor-pointer group">
                        <input type="radio" name="code_type" value="package" class="hidden peer" onchange="toggleCodeTypeFields(this.value)">
                        <div class="relative border-3 border-gray-200 rounded-2xl p-6 transition-all hover:border-purple-400 hover:shadow-xl peer-checked:border-purple-500 peer-checked:bg-purple-50 peer-checked:shadow-2xl">
                            <div class="absolute top-4 left-4 w-6 h-6 rounded-full border-2 border-gray-300 peer-checked:border-purple-500 peer-checked:bg-purple-500 flex items-center justify-center">
                                <i class="fas fa-check text-white text-xs hidden peer-checked:block"></i>
                            </div>
                            <div class="text-center">
                                <div class="w-20 h-20 bg-gradient-to-br from-purple-500 to-pink-500 rounded-2xl flex items-center justify-center mx-auto mb-4">
                                    <i class="fas fa-box text-white text-3xl"></i>
                                </div>
                                <h4 class="text-xl font-bold text-gray-900 mb-2">باقة</h4>
                                <p class="text-gray-600 text-sm">إنشاء كود لباقة تحتوي على عدة دورات</p>
                            </div>
                        </div>
                    </label>

                    <!-- General -->
                    <label class="cursor-pointer group">
                        <input type="radio" name="code_type" value="general" class="hidden peer" onchange="toggleCodeTypeFields(this.value)">
                        <div class="relative border-3 border-gray-200 rounded-2xl p-6 transition-all hover:border-green-400 hover:shadow-xl peer-checked:border-green-500 peer-checked:bg-green-50 peer-checked:shadow-2xl">
                            <div class="absolute top-4 left-4 w-6 h-6 rounded-full border-2 border-gray-300 peer-checked:border-green-500 peer-checked:bg-green-500 flex items-center justify-center">
                                <i class="fas fa-check text-white text-xs hidden peer-checked:block"></i>
                            </div>
                            <div class="text-center">
                                <div class="w-20 h-20 bg-gradient-to-br from-green-500 to-emerald-500 rounded-2xl flex items-center justify-center mx-auto mb-4">
                                    <i class="fas fa-star text-white text-3xl"></i>
                                </div>
                                <h4 class="text-xl font-bold text-gray-900 mb-2">عام</h4>
                                <p class="text-gray-600 text-sm">كود عام لجميع المحتويات</p>
                            </div>
                        </div>
                    </label>
                </div>
            </div>
        </div>

        <!-- Step 2: List Name (Required) -->
        <div class="bg-white rounded-2xl shadow-xl overflow-hidden">
            <div class="bg-gradient-to-r from-teal-600 to-cyan-600 px-8 py-5">
                <h3 class="text-2xl font-bold text-white flex items-center gap-3">
                    <div class="w-10 h-10 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                        <span class="text-xl font-bold">2</span>
                    </div>
                    اسم القائمة
                </h3>
            </div>
            <div class="p-8">
                <div class="space-y-4">
                    <div class="bg-blue-50 border-r-4 border-blue-500 p-4 rounded-lg">
                        <div class="flex items-start gap-3">
                            <i class="fas fa-info-circle text-blue-500 text-xl mt-1"></i>
                            <div>
                                <h4 class="font-bold text-blue-900 mb-1">ما فائدة اسم القائمة؟</h4>
                                <p class="text-blue-800 text-sm">
                                    يساعدك اسم القائمة على تنظيم وتتبع الأكواد بسهولة.
                                    مثال: "أكواد عيد الأضحى 2025" أو "مجموعة طلاب الثانوية العامة"
                                </p>
                            </div>
                        </div>
                    </div>

                    <div class="relative">
                        <label class="block text-lg font-bold text-gray-800 mb-3">
                            اسم القائمة
                            <span class="text-red-500">*</span>
                        </label>
                        <div class="relative">
                            <div class="absolute right-4 top-1/2 -translate-y-1/2 text-teal-500">
                                <i class="fas fa-tag text-xl"></i>
                            </div>
                            <input type="text" name="list_name" required
                                   class="w-full pr-14 pl-6 py-4 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-teal-500 focus:border-teal-500 transition-all text-lg"
                                   placeholder="مثال: أكواد العرض الترويجي - يناير 2025"
                                   maxlength="255">
                        </div>
                        <p class="text-sm text-gray-600 mt-2 flex items-center gap-2">
                            <i class="fas fa-info-circle text-teal-500"></i>
                            <span>مطلوب لتنظيم وتتبع الأكواد المُنشأة</span>
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Step 3: Course Selection (Hidden) -->
        <div id="course_field" style="display:none;" class="bg-white rounded-2xl shadow-xl overflow-hidden">
            <div class="bg-gradient-to-r from-blue-600 to-cyan-600 px-8 py-5">
                <h3 class="text-2xl font-bold text-white flex items-center gap-3">
                    <div class="w-10 h-10 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                        <span class="text-xl font-bold">3</span>
                    </div>
                    اختر الدورة التعليمية
                </h3>
            </div>
            <div class="p-8">
                <select name="course_id" class="w-full px-6 py-4 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all text-lg">
                    <option value="">اختر الدورة</option>
                    @foreach(\App\Models\Course::where('is_published', true)->get() as $course)
                        <option value="{{ $course->id }}">{{ $course->title_ar }}</option>
                    @endforeach
                </select>
            </div>
        </div>

        <!-- Step 3: Package Selection (Hidden) -->
        <div id="package_field" style="display:none;" class="bg-white rounded-2xl shadow-xl overflow-hidden">
            <div class="bg-gradient-to-r from-purple-600 to-pink-600 px-8 py-5">
                <h3 class="text-2xl font-bold text-white flex items-center gap-3">
                    <div class="w-10 h-10 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                        <span class="text-xl font-bold">3</span>
                    </div>
                    اختر الباقة التعليمية
                </h3>
            </div>
            <div class="p-8">
                <select name="package_id" class="w-full px-6 py-4 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500 transition-all text-lg">
                    <option value="">اختر الباقة</option>
                    @foreach(\App\Models\SubscriptionPackage::where('is_active', true)->get() as $package)
                        <option value="{{ $package->id }}">{{ $package->name_ar }}</option>
                    @endforeach
                </select>
            </div>
        </div>

        <!-- Step 4: Code Settings -->
        <div class="bg-white rounded-2xl shadow-xl overflow-hidden">
            <div class="bg-gradient-to-r from-orange-600 to-red-600 px-8 py-5">
                <h3 class="text-2xl font-bold text-white flex items-center gap-3">
                    <div class="w-10 h-10 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                        <span class="text-xl font-bold" id="step-number">4</span>
                    </div>
                    إعدادات الأكواد
                </h3>
            </div>
            <div class="p-8 space-y-8">
                <!-- Quantity and Max Uses -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <!-- Quantity -->
                    <div class="relative">
                        <label class="block text-lg font-bold text-gray-800 mb-3">
                            عدد الأكواد المطلوبة
                            <span class="text-red-500">*</span>
                        </label>
                        <div class="relative">
                            <div class="absolute right-4 top-1/2 -translate-y-1/2 text-blue-500">
                                <i class="fas fa-hashtag text-xl"></i>
                            </div>
                            <input type="number" name="quantity" value="1" min="1" max="1000" required
                                   class="w-full pr-14 pl-6 py-4 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all text-lg font-semibold"
                                   placeholder="أدخل العدد">
                        </div>
                        <p class="text-sm text-gray-600 mt-2 flex items-center gap-2">
                            <i class="fas fa-info-circle text-blue-500"></i>
                            <span>الحد الأقصى: 1000 كود في المرة الواحدة</span>
                        </p>
                    </div>

                    <!-- Max Uses -->
                    <div class="relative">
                        <label class="block text-lg font-bold text-gray-800 mb-3">
                            عدد الاستخدامات لكل كود
                            <span class="text-red-500">*</span>
                        </label>
                        <div class="relative">
                            <div class="absolute right-4 top-1/2 -translate-y-1/2 text-green-500">
                                <i class="fas fa-sync-alt text-xl"></i>
                            </div>
                            <input type="number" name="max_uses_per_code" value="1" min="1" required
                                   class="w-full pr-14 pl-6 py-4 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-all text-lg font-semibold"
                                   placeholder="أدخل العدد">
                        </div>
                        <p class="text-sm text-gray-600 mt-2 flex items-center gap-2">
                            <i class="fas fa-info-circle text-green-500"></i>
                            <span>عدد المرات التي يمكن استخدام الكود الواحد فيها</span>
                        </p>
                    </div>
                </div>

                <!-- Expiration Date -->
                <div class="relative">
                    <label class="block text-lg font-bold text-gray-800 mb-3">
                        تاريخ انتهاء الصلاحية
                        <span class="text-gray-500 text-sm font-normal">(اختياري)</span>
                    </label>
                    <div class="relative">
                        <div class="absolute right-4 top-1/2 -translate-y-1/2 text-orange-500">
                            <i class="fas fa-calendar-alt text-xl"></i>
                        </div>
                        <input type="datetime-local" name="expires_at"
                               class="w-full pr-14 pl-6 py-4 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-orange-500 focus:border-orange-500 transition-all text-lg">
                    </div>
                    <p class="text-sm text-gray-600 mt-2 flex items-center gap-2">
                        <i class="fas fa-info-circle text-orange-500"></i>
                        <span>اتركه فارغاً إذا كنت تريد أن تكون الأكواد صالحة بشكل دائم</span>
                    </p>
                </div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="flex flex-col sm:flex-row gap-4 justify-end">
            <a href="{{ route('admin.subscription-codes.index') }}"
               class="px-8 py-4 bg-white border-2 border-gray-300 rounded-xl text-gray-700 hover:bg-gray-50 font-bold transition-all text-center flex items-center justify-center gap-2 shadow-md">
                <i class="fas fa-times"></i>
                <span>إلغاء</span>
            </a>
            <button type="submit"
                    class="px-8 py-4 bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700 text-white rounded-xl font-bold shadow-xl hover:shadow-2xl transition-all flex items-center justify-center gap-2">
                <i class="fas fa-magic"></i>
                <span>توليد الأكواد</span>
            </button>
        </div>
    </form>
</div>

@push('scripts')
<script>
function toggleCodeTypeFields(type) {
    const courseField = document.getElementById('course_field');
    const packageField = document.getElementById('package_field');
    const stepNumber = document.getElementById('step-number');

    // Hide all fields first
    courseField.style.display = 'none';
    packageField.style.display = 'none';

    // Show the relevant field with animation
    if (type === 'single_course') {
        courseField.style.display = 'block';
        stepNumber.textContent = '3';
        setTimeout(() => {
            courseField.style.opacity = '0';
            courseField.style.transform = 'translateY(20px)';
            courseField.style.transition = 'opacity 0.3s ease-out, transform 0.3s ease-out';
            setTimeout(() => {
                courseField.style.opacity = '1';
                courseField.style.transform = 'translateY(0)';
            }, 10);
        }, 10);
    } else if (type === 'package') {
        packageField.style.display = 'block';
        stepNumber.textContent = '3';
        setTimeout(() => {
            packageField.style.opacity = '0';
            packageField.style.transform = 'translateY(20px)';
            packageField.style.transition = 'opacity 0.3s ease-out, transform 0.3s ease-out';
            setTimeout(() => {
                packageField.style.opacity = '1';
                packageField.style.transform = 'translateY(0)';
            }, 10);
        }, 10);
    } else {
        stepNumber.textContent = '2';
    }
}
</script>
@endpush

@push('styles')
<style>
/* Custom radio button styling */
.peer:checked ~ div {
    animation: checkPulse 0.3s ease-in-out;
}

@keyframes checkPulse {
    0% {
        transform: scale(1);
    }
    50% {
        transform: scale(1.05);
    }
    100% {
        transform: scale(1);
    }
}

/* Border width adjustment */
.border-3 {
    border-width: 3px;
}

/* Number input - hide arrows for cleaner look */
input[type="number"]::-webkit-inner-spin-button,
input[type="number"]::-webkit-outer-spin-button {
    opacity: 1;
}
</style>
@endpush
@endsection
