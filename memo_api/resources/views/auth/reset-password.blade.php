@extends('layouts.auth')

@section('title', 'إعادة تعيين كلمة المرور')

@section('content')
<div>
    <!-- Header -->
    <div class="text-center mb-8">
        <div class="inline-flex items-center justify-center w-16 h-16 bg-green-100 rounded-full mb-4">
            <i class="fas fa-lock-open text-3xl text-green-600"></i>
        </div>
        <h2 class="text-3xl font-bold text-gray-800 mb-2">إعادة تعيين كلمة المرور</h2>
        <p class="text-gray-600">أدخل كلمة المرور الجديدة لحسابك</p>
    </div>

    <!-- Error Messages -->
    @if($errors->any())
    <div class="mb-6 bg-red-50 border-r-4 border-red-500 p-4 rounded">
        <div class="flex items-start">
            <i class="fas fa-exclamation-circle text-red-500 mr-3 mt-1"></i>
            <div>
                <p class="text-red-800 font-semibold mb-1">يوجد أخطاء:</p>
                <ul class="list-disc list-inside text-red-700 text-sm">
                    @foreach($errors->all() as $error)
                    <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        </div>
    </div>
    @endif

    <!-- Reset Password Form -->
    <form method="POST" action="{{ route('admin.password.update') }}" class="space-y-6" x-data="{ showPassword: false, showPasswordConfirmation: false }">
        @csrf

        <!-- Hidden Token -->
        <input type="hidden" name="token" value="{{ $token }}">

        <!-- Email Field (Read-only) -->
        <div>
            <label for="email" class="block text-sm font-semibold text-gray-700 mb-2">
                <i class="fas fa-envelope mr-2 text-gray-500"></i>
                البريد الإلكتروني
            </label>
            <input type="email"
                   id="email"
                   name="email"
                   value="{{ $email ?? old('email') }}"
                   required
                   readonly
                   class="w-full px-4 py-3 border border-gray-300 rounded-lg bg-gray-50 cursor-not-allowed"
                   dir="ltr">
            @error('email')
            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
            @enderror
        </div>

        <!-- Password Field -->
        <div>
            <label for="password" class="block text-sm font-semibold text-gray-700 mb-2">
                <i class="fas fa-lock mr-2 text-gray-500"></i>
                كلمة المرور الجديدة
            </label>
            <div class="relative">
                <input :type="showPassword ? 'text' : 'password'"
                       id="password"
                       name="password"
                       required
                       autofocus
                       class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 transition @error('password') border-red-500 @enderror"
                       placeholder="أدخل كلمة مرور قوية"
                       dir="ltr">
                <button type="button"
                        @click="showPassword = !showPassword"
                        class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-700 focus:outline-none">
                    <i :class="showPassword ? 'fas fa-eye-slash' : 'fas fa-eye'"></i>
                </button>
            </div>
            <p class="mt-1 text-xs text-gray-500">
                <i class="fas fa-info-circle mr-1"></i>
                الحد الأدنى 8 أحرف، يفضل استخدام أحرف كبيرة وصغيرة وأرقام ورموز
            </p>
            @error('password')
            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
            @enderror
        </div>

        <!-- Password Confirmation Field -->
        <div>
            <label for="password_confirmation" class="block text-sm font-semibold text-gray-700 mb-2">
                <i class="fas fa-check-circle mr-2 text-gray-500"></i>
                تأكيد كلمة المرور
            </label>
            <div class="relative">
                <input :type="showPasswordConfirmation ? 'text' : 'password'"
                       id="password_confirmation"
                       name="password_confirmation"
                       required
                       class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 transition"
                       placeholder="أعد إدخال كلمة المرور"
                       dir="ltr">
                <button type="button"
                        @click="showPasswordConfirmation = !showPasswordConfirmation"
                        class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-700 focus:outline-none">
                    <i :class="showPasswordConfirmation ? 'fas fa-eye-slash' : 'fas fa-eye'"></i>
                </button>
            </div>
        </div>

        <!-- Password Strength Indicator -->
        <div class="bg-gray-50 border border-gray-200 rounded-lg p-4">
            <p class="text-sm font-semibold text-gray-700 mb-2">
                <i class="fas fa-shield-alt mr-2 text-blue-600"></i>
                متطلبات كلمة المرور القوية:
            </p>
            <ul class="space-y-1 text-xs text-gray-600">
                <li class="flex items-center">
                    <i class="fas fa-check text-green-500 mr-2 text-xs"></i>
                    الحد الأدنى 8 أحرف
                </li>
                <li class="flex items-center">
                    <i class="fas fa-check text-green-500 mr-2 text-xs"></i>
                    حرف كبير واحد على الأقل (A-Z)
                </li>
                <li class="flex items-center">
                    <i class="fas fa-check text-green-500 mr-2 text-xs"></i>
                    حرف صغير واحد على الأقل (a-z)
                </li>
                <li class="flex items-center">
                    <i class="fas fa-check text-green-500 mr-2 text-xs"></i>
                    رقم واحد على الأقل (0-9)
                </li>
            </ul>
        </div>

        <!-- Submit Button -->
        <button type="submit"
                class="w-full bg-gradient-to-l from-green-600 to-green-700 hover:from-green-700 hover:to-green-800 text-white font-bold py-3 px-4 rounded-lg transition duration-200 transform hover:scale-[1.02] active:scale-[0.98] shadow-lg">
            <i class="fas fa-save mr-2"></i>
            إعادة تعيين كلمة المرور
        </button>
    </form>

    <!-- Divider -->
    <div class="relative my-8">
        <div class="absolute inset-0 flex items-center">
            <div class="w-full border-t border-gray-300"></div>
        </div>
    </div>

    <!-- Back to Login -->
    <div class="text-center">
        <a href="{{ route('admin.login') }}" class="inline-flex items-center text-sm text-blue-600 hover:text-blue-800 font-semibold">
            <i class="fas fa-arrow-right mr-2"></i>
            العودة إلى تسجيل الدخول
        </a>
    </div>
</div>
@endsection

@section('footer-links')
<div class="space-y-2">
    <p class="text-white/90 text-sm">
        <i class="fas fa-clock mr-1"></i>
        رابط إعادة التعيين صالح لمدة 60 دقيقة
    </p>
</div>
@endsection

@push('scripts')
<script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
@endpush
