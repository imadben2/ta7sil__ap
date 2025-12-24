@extends('layouts.auth')

@section('title', 'تسجيل الدخول - لوحة التحكم')

@section('content')
<div>
    <!-- Header -->
    <div class="text-center mb-8">
        <h2 class="text-3xl font-bold text-gray-800 mb-2">تسجيل الدخول</h2>
        <p class="text-gray-600">لوحة تحكم الإدارة</p>
    </div>

    <!-- Success/Error Messages -->
    @if(session('success'))
    <div class="mb-6 bg-green-50 border-r-4 border-green-500 p-4 rounded">
        <div class="flex items-center">
            <i class="fas fa-check-circle text-green-500 mr-3"></i>
            <p class="text-green-800">{{ session('success') }}</p>
        </div>
    </div>
    @endif

    @if(session('error'))
    <div class="mb-6 bg-red-50 border-r-4 border-red-500 p-4 rounded">
        <div class="flex items-center">
            <i class="fas fa-exclamation-circle text-red-500 mr-3"></i>
            <p class="text-red-800">{{ session('error') }}</p>
        </div>
    </div>
    @endif

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

    <!-- Quick Login Helper (Development Only) -->
    @if(config('app.env') !== 'production')
    <div class="mb-6 bg-yellow-50 border-r-4 border-yellow-500 p-4 rounded">
        <div class="flex items-start">
            <i class="fas fa-exclamation-triangle text-yellow-600 mr-3 mt-1"></i>
            <div class="flex-1">
                <p class="text-yellow-800 font-semibold mb-2">وضع التطوير - دخول سريع</p>
                <div class="flex gap-2">
                    <button type="button"
                            onclick="quickLogin('admin@example.com', 'admin123')"
                            class="bg-yellow-600 hover:bg-yellow-700 text-white text-sm px-3 py-1 rounded transition">
                        <i class="fas fa-bolt mr-1"></i>
                        دخول كمدير
                    </button>
                    <button type="button"
                            onclick="document.getElementById('loginForm').submit()"
                            class="bg-green-600 hover:bg-green-700 text-white text-sm px-3 py-1 rounded transition">
                        <i class="fas fa-play mr-1"></i>
                        دخول مباشر
                    </button>
                </div>
            </div>
        </div>
    </div>
    @endif

    <!-- Login Form -->
    <form method="POST" action="{{ route('admin.login.submit') }}" class="space-y-6" id="loginForm" x-data="loginForm()">
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
                   x-model="email"
                   value="{{ old('email', config('app.env') !== 'production' ? 'admin@example.com' : '') }}"
                   required
                   autofocus
                   class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition @error('email') border-red-500 @enderror"
                   placeholder="admin@example.com"
                   dir="ltr">
            @error('email')
            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
            @enderror
        </div>

        <!-- Password Field -->
        <div>
            <label for="password" class="block text-sm font-semibold text-gray-700 mb-2">
                <i class="fas fa-lock mr-2 text-gray-500"></i>
                كلمة المرور
            </label>
            <div class="relative">
                <input :type="showPassword ? 'text' : 'password'"
                       id="password"
                       name="password"
                       x-model="password"
                       value="{{ config('app.env') !== 'production' ? 'admin123' : '' }}"
                       required
                       class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition @error('password') border-red-500 @enderror"
                       placeholder="••••••••"
                       dir="ltr">
                <button type="button"
                        @click="showPassword = !showPassword"
                        class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-700 focus:outline-none">
                    <i :class="showPassword ? 'fas fa-eye-slash' : 'fas fa-eye'"></i>
                </button>
            </div>
            @error('password')
            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
            @enderror
        </div>

        <!-- Remember Me & Forgot Password -->
        <div class="flex items-center justify-between">
            <div class="flex items-center">
                <input type="checkbox"
                       id="remember"
                       name="remember"
                       {{ old('remember') ? 'checked' : '' }}
                       class="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
                <label for="remember" class="mr-2 text-sm text-gray-700">
                    تذكرني
                </label>
            </div>

            <a href="{{ route('admin.password.request') }}" class="text-sm text-blue-600 hover:text-blue-800 font-semibold">
                نسيت كلمة المرور؟
            </a>
        </div>

        <!-- Submit Button -->
        <button type="submit"
                class="w-full bg-gradient-to-l from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white font-bold py-3 px-4 rounded-lg transition duration-200 transform hover:scale-[1.02] active:scale-[0.98] shadow-lg">
            <i class="fas fa-sign-in-alt mr-2"></i>
            تسجيل الدخول
        </button>
    </form>

    <!-- Divider -->
    <div class="relative my-8">
        <div class="absolute inset-0 flex items-center">
            <div class="w-full border-t border-gray-300"></div>
        </div>
        <div class="relative flex justify-center text-sm">
            <span class="px-4 bg-white text-gray-500">أو</span>
        </div>
    </div>

    <!-- Back to Home -->
    <div class="text-center">
        <a href="/" class="text-sm text-gray-600 hover:text-gray-800">
            <i class="fas fa-home mr-2"></i>
            العودة إلى الصفحة الرئيسية
        </a>
    </div>
</div>
@endsection

@section('footer-links')
<div class="space-y-2">
    <p class="text-white/90 text-sm">
        <i class="fas fa-info-circle mr-1"></i>
        هذه الصفحة مخصصة لفريق الإدارة فقط
    </p>
</div>
@endsection

@push('scripts')
<script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
<script>
// Refresh page if it has been inactive for too long (to get new CSRF token)
let pageLoadTime = Date.now();
document.addEventListener('visibilitychange', function() {
    if (!document.hidden) {
        // Check if page has been hidden for more than 30 minutes
        let timeSinceLoad = Date.now() - pageLoadTime;
        if (timeSinceLoad > 30 * 60 * 1000) {
            console.log('Page has been inactive, refreshing for new CSRF token...');
            window.location.reload();
        }
    }
});

function loginForm() {
    return {
        email: '{{ old('email', config('app.env') !== 'production' ? 'admin@example.com' : '') }}',
        password: '{{ config('app.env') !== 'production' ? 'admin123' : '' }}',
        showPassword: false
    }
}

function quickLogin(email, password) {
    document.getElementById('email').value = email;
    document.getElementById('password').value = password;

    // Update Alpine.js model
    const form = document.getElementById('loginForm');
    if (form.__x) {
        form.__x.$data.email = email;
        form.__x.$data.password = password;
    }

    // Optional: Auto-submit after filling
    setTimeout(() => {
        form.submit();
    }, 500);
}

// Auto-fill on page load in development
@if(config('app.env') !== 'production')
document.addEventListener('DOMContentLoaded', function() {
    // Fields are already pre-filled via value attributes
    console.log('Development mode: Login fields pre-filled');

    // Optional: Press Enter to auto-submit
    document.addEventListener('keypress', function(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            const form = document.getElementById('loginForm');
            if (form && document.activeElement.tagName !== 'BUTTON') {
                form.submit();
            }
        }
    });
});
@endif
</script>
@endpush
