@extends('layouts.auth')

@section('title', 'نسيت كلمة المرور')

@section('content')
<div>
    <!-- Header -->
    <div class="text-center mb-8">
        <div class="inline-flex items-center justify-center w-16 h-16 bg-blue-100 rounded-full mb-4">
            <i class="fas fa-key text-3xl text-blue-600"></i>
        </div>
        <h2 class="text-3xl font-bold text-gray-800 mb-2">نسيت كلمة المرور؟</h2>
        <p class="text-gray-600">أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة تعيين كلمة المرور</p>
    </div>

    <!-- Success Message -->
    @if(session('status'))
    <div class="mb-6 bg-green-50 border-r-4 border-green-500 p-4 rounded">
        <div class="flex items-start">
            <i class="fas fa-check-circle text-green-500 mr-3 mt-1"></i>
            <div>
                <p class="text-green-800 font-semibold mb-1">تم الإرسال بنجاح!</p>
                <p class="text-green-700 text-sm">{{ session('status') }}</p>
            </div>
        </div>
    </div>
    @endif

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

    <!-- Forgot Password Form -->
    <form method="POST" action="{{ route('admin.password.email') }}" class="space-y-6">
        @csrf

        <!-- Email Field -->
        <div>
            <label for="email" class="block text-sm font-semibold text-gray-700 mb-2">
                <i class="fas fa-envelope mr-2 text-gray-500"></i>
                البريد الإلكتروني
            </label>
            <input type="email"
                   id="email"
                   name="email"
                   value="{{ old('email') }}"
                   required
                   autofocus
                   class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition @error('email') border-red-500 @enderror"
                   placeholder="admin@example.com"
                   dir="ltr">
            @error('email')
            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
            @enderror
        </div>

        <!-- Info Box -->
        <div class="bg-blue-50 border-r-4 border-blue-500 p-4 rounded">
            <div class="flex items-start">
                <i class="fas fa-info-circle text-blue-500 mr-3 mt-1"></i>
                <div class="text-sm text-blue-800">
                    <p class="font-semibold mb-1">ملاحظة مهمة:</p>
                    <p>سيتم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني. الرابط صالح لمدة 60 دقيقة فقط.</p>
                </div>
            </div>
        </div>

        <!-- Submit Button -->
        <button type="submit"
                class="w-full bg-gradient-to-l from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white font-bold py-3 px-4 rounded-lg transition duration-200 transform hover:scale-[1.02] active:scale-[0.98] shadow-lg">
            <i class="fas fa-paper-plane mr-2"></i>
            إرسال رابط إعادة التعيين
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
        <i class="fas fa-shield-alt mr-1"></i>
        جميع البيانات محمية ومشفرة
    </p>
</div>
@endsection
