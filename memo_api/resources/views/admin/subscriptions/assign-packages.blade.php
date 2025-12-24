@extends('layouts.admin')

@section('title', 'تعيين باقات للطلاب')
@section('page-title', 'تعيين باقات للطلاب')

@push('styles')
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
<style>
    .select2-container--default .select2-selection--multiple {
        border: 2px solid #d1d5db;
        border-radius: 0.5rem;
        padding: 0.5rem;
        min-height: 3rem;
    }
    .select2-container--default.select2-container--focus .select2-selection--multiple {
        border-color: #9333ea;
        box-shadow: 0 0 0 3px rgba(147, 51, 234, 0.1);
    }
    .select2-container--default .select2-selection--multiple .select2-selection__choice {
        background-color: #9333ea;
        border-color: #9333ea;
        color: white;
        padding: 0.25rem 0.75rem;
        border-radius: 0.375rem;
    }
    .select2-container {
        width: 100% !important;
    }
</style>
@endpush

@section('content')
<div class="space-y-6" style="font-family: 'Cairo', sans-serif; direction: rtl;">
    <!-- Header -->
    <div class="bg-gradient-to-r from-purple-600 to-pink-600 rounded-xl shadow-lg p-6">
        <div class="text-white">
            <h2 class="text-2xl font-bold mb-2">
                <i class="fas fa-gift ml-2"></i>
                تعيين باقات للطلاب
            </h2>
            <p class="text-purple-100">قم بتعيين باقة أو عدة باقات لطالب واحد أو عدة طلاب</p>
        </div>
    </div>

    <!-- Success/Error Messages -->
    @if (session('success') || session('error'))
    <div class="{{ session('success') ? 'bg-green-100 border-green-500 text-green-700' : 'bg-red-100 border-red-500 text-red-700' }} border-r-4 p-4 rounded-lg shadow-sm">
        <div class="flex items-center">
            <i class="fas {{ session('success') ? 'fa-check-circle' : 'fa-exclamation-circle' }} mr-3 text-lg"></i>
            <p>{{ session('success') ?? session('error') }}</p>
        </div>
    </div>
    @endif

    <!-- Form Card -->
    <div class="bg-white rounded-xl shadow-lg p-8">
        <form action="{{ route('admin.subscriptions.assign.packages.store') }}" method="POST" class="space-y-6">
            @csrf

            <!-- Students and Packages Selection - Full Width -->
            <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">
                <!-- Students Selection - 6 columns -->
                <div class="lg:col-span-6">
                    <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                        <i class="fas fa-users text-purple-600"></i>
                        اختر الطلاب *
                    </label>
                    <select name="students[]" id="students" multiple class="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent @error('students') border-red-500 @enderror" required>
                        @foreach($students as $student)
                        <option value="{{ $student->id }}">{{ $student->name }} ({{ $student->email }})</option>
                        @endforeach
                    </select>
                    @error('students')
                    <p class="text-red-500 text-sm mt-1 flex items-center gap-1">
                        <i class="fas fa-exclamation-circle"></i>
                        {{ $message }}
                    </p>
                    @enderror
                    <p class="text-sm text-gray-500 mt-2">
                        <i class="fas fa-info-circle ml-1"></i>
                        يمكنك اختيار طالب واحد أو عدة طلاب
                    </p>
                </div>

                <!-- Packages Selection - 6 columns -->
                <div class="lg:col-span-6">
                    <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                        <i class="fas fa-box text-purple-600"></i>
                        اختر الباقات *
                    </label>
                    <select name="packages[]" id="packages" multiple class="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent @error('packages') border-red-500 @enderror" required>
                        @foreach($packages as $package)
                        <option value="{{ $package->id }}">
                            {{ $package->name_ar }} - {{ number_format($package->price_dzd) }} دج ({{ $package->duration_days }} يوم)
                        </option>
                        @endforeach
                    </select>
                    @error('packages')
                    <p class="text-red-500 text-sm mt-1 flex items-center gap-1">
                        <i class="fas fa-exclamation-circle"></i>
                        {{ $message }}
                    </p>
                    @enderror
                    <p class="text-sm text-gray-500 mt-2">
                        <i class="fas fa-info-circle ml-1"></i>
                        يمكنك اختيار باقة واحدة أو عدة باقات
                    </p>
                </div>
            </div>

            <!-- Settings Section -->
            <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">
                <!-- Start Date - 4 columns -->
                <div class="lg:col-span-4">
                    <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                        <i class="fas fa-calendar-alt text-purple-600"></i>
                        تاريخ البداية *
                    </label>
                    <input type="date" name="start_date" value="{{ old('start_date', date('Y-m-d')) }}" class="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent @error('start_date') border-red-500 @enderror" required>
                    @error('start_date')
                    <p class="text-red-500 text-sm mt-1 flex items-center gap-1">
                        <i class="fas fa-exclamation-circle"></i>
                        {{ $message }}
                    </p>
                    @enderror
                    <p class="text-xs text-gray-500 mt-1">سيتم احتساب المدة تلقائياً من الباقة</p>
                </div>

                <!-- Payment Method - 4 columns -->
                <div class="lg:col-span-4">
                    <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                        <i class="fas fa-credit-card text-purple-600"></i>
                        طريقة الدفع *
                    </label>
                    <select name="subscription_method" class="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent @error('subscription_method') border-red-500 @enderror" required>
                        <option value="manual">يدوي (Manual)</option>
                        <option value="ccp">CCP</option>
                        <option value="baridi_mob">بريدي موب</option>
                        <option value="code">رمز اشتراك</option>
                    </select>
                    @error('subscription_method')
                    <p class="text-red-500 text-sm mt-1 flex items-center gap-1">
                        <i class="fas fa-exclamation-circle"></i>
                        {{ $message }}
                    </p>
                    @enderror
                </div>

                <!-- Status - 4 columns -->
                <div class="lg:col-span-4">
                    <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                        <i class="fas fa-toggle-on text-purple-600"></i>
                        الحالة *
                    </label>
                    <select name="status" class="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent @error('status') border-red-500 @enderror" required>
                        <option value="active">نشط</option>
                        <option value="expired">منتهي</option>
                        <option value="cancelled">ملغي</option>
                    </select>
                    @error('status')
                    <p class="text-red-500 text-sm mt-1 flex items-center gap-1">
                        <i class="fas fa-exclamation-circle"></i>
                        {{ $message }}
                    </p>
                    @enderror
                </div>
            </div>

            <!-- Submit Button -->
            <div class="flex justify-end gap-4 pt-6 border-t border-gray-200">
                <a href="{{ route('admin.subscriptions.index') }}" class="px-6 py-3 bg-gray-200 text-gray-700 rounded-lg font-semibold hover:bg-gray-300 transition-colors flex items-center gap-2">
                    <i class="fas fa-times"></i>
                    <span>إلغاء</span>
                </a>
                <button type="submit" class="px-6 py-3 bg-gradient-to-r from-purple-600 to-pink-600 text-white rounded-lg font-semibold hover:from-purple-700 hover:to-pink-700 transition-all shadow-md hover:shadow-lg flex items-center gap-2">
                    <i class="fas fa-check"></i>
                    <span>تعيين الباقات</span>
                </button>
            </div>
        </form>
    </div>

    <!-- Info Card -->
    <div class="bg-purple-50 border-r-4 border-purple-500 p-6 rounded-lg shadow-sm">
        <h3 class="text-lg font-semibold text-purple-900 mb-3 flex items-center gap-2">
            <i class="fas fa-lightbulb"></i>
            ملاحظة هامة
        </h3>
        <ul class="text-purple-800 space-y-2 text-sm">
            <li class="flex items-start gap-2">
                <i class="fas fa-check-circle text-purple-600 mt-0.5"></i>
                <span>سيتم إنشاء اشتراك لكل طالب ولكل باقة تم اختيارها</span>
            </li>
            <li class="flex items-start gap-2">
                <i class="fas fa-check-circle text-purple-600 mt-0.5"></i>
                <span>الباقات تحتوي على عدة دورات، سيحصل الطالب على الوصول لجميعها</span>
            </li>
            <li class="flex items-start gap-2">
                <i class="fas fa-check-circle text-purple-600 mt-0.5"></i>
                <span>المدة ستكون حسب مدة الباقة المحددة مسبقاً</span>
            </li>
            <li class="flex items-start gap-2">
                <i class="fas fa-check-circle text-purple-600 mt-0.5"></i>
                <span>الاشتراكات الموجودة مسبقاً سيتم تخطيها تلقائياً</span>
            </li>
        </ul>
    </div>
</div>
@endsection

@push('scripts')
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

<script>
$(document).ready(function() {
    // Auto-hide success/error messages after 5 seconds (only alert messages, not status badges)
    setTimeout(function() {
        $('.border-r-4').filter('[class*="bg-green-100"], [class*="bg-red-100"]').fadeOut('slow');
    }, 5000);

    // Initialize Select2 for students
    $('#students').select2({
        placeholder: 'اختر الطلاب...',
        allowClear: true,
        dir: 'rtl',
        width: '100%',
        language: {
            noResults: function() {
                return 'لا توجد نتائج';
            },
            searching: function() {
                return 'جاري البحث...';
            }
        }
    });

    // Initialize Select2 for packages
    $('#packages').select2({
        placeholder: 'اختر الباقات...',
        allowClear: true,
        dir: 'rtl',
        width: '100%',
        language: {
            noResults: function() {
                return 'لا توجد نتائج';
            },
            searching: function() {
                return 'جاري البحث...';
            }
        }
    });
});
</script>
@endpush
