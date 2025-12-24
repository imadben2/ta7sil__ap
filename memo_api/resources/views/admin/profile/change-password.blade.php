@extends('layouts.admin')

@section('title', 'تغيير كلمة المرور')
@section('page-title', 'تغيير كلمة المرور')

@section('content')
<div class="max-w-2xl mx-auto" style="font-family: 'Cairo', sans-serif; direction: rtl;">
    <div class="bg-white rounded-xl shadow-lg overflow-hidden">
        <!-- Header -->
        <div class="bg-gradient-to-r from-red-600 to-pink-600 px-8 py-6">
            <h2 class="text-2xl font-bold text-white flex items-center gap-3">
                <i class="fas fa-lock"></i>
                تغيير كلمة المرور
            </h2>
            <p class="text-red-100 mt-2">حافظ على أمان حسابك بتحديث كلمة المرور بانتظام</p>
        </div>

        <!-- Form -->
        <form action="{{ route('admin.profile.update-password') }}" method="POST" class="p-8">
            @csrf
            @method('PUT')

            <div class="space-y-6">
                <!-- Current Password -->
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                        <i class="fas fa-key text-blue-600"></i>
                        كلمة المرور الحالية *
                    </label>
                    <div class="relative">
                        <input type="password" name="current_password" id="current_password" required
                               class="w-full px-4 py-3 pr-12 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all @error('current_password') border-red-500 @enderror"
                               placeholder="أدخل كلمة المرور الحالية">
                        <button type="button" onclick="togglePassword('current_password')" class="absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600">
                            <i class="fas fa-eye" id="current_password-icon"></i>
                        </button>
                    </div>
                    @error('current_password')
                        <p class="text-red-600 text-sm mt-1">{{ $message }}</p>
                    @enderror
                </div>

                <div class="border-t border-gray-200"></div>

                <!-- New Password -->
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                        <i class="fas fa-lock text-blue-600"></i>
                        كلمة المرور الجديدة *
                    </label>
                    <div class="relative">
                        <input type="password" name="new_password" id="new_password" required
                               class="w-full px-4 py-3 pr-12 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all @error('new_password') border-red-500 @enderror"
                               placeholder="أدخل كلمة المرور الجديدة">
                        <button type="button" onclick="togglePassword('new_password')" class="absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600">
                            <i class="fas fa-eye" id="new_password-icon"></i>
                        </button>
                    </div>
                    @error('new_password')
                        <p class="text-red-600 text-sm mt-1">{{ $message }}</p>
                    @enderror
                    <p class="text-sm text-gray-500 mt-2">كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل</p>
                </div>

                <!-- Confirm New Password -->
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                        <i class="fas fa-check-circle text-blue-600"></i>
                        تأكيد كلمة المرور الجديدة *
                    </label>
                    <div class="relative">
                        <input type="password" name="new_password_confirmation" id="new_password_confirmation" required
                               class="w-full px-4 py-3 pr-12 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all"
                               placeholder="أعد إدخال كلمة المرور الجديدة">
                        <button type="button" onclick="togglePassword('new_password_confirmation')" class="absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600">
                            <i class="fas fa-eye" id="new_password_confirmation-icon"></i>
                        </button>
                    </div>
                </div>

                <!-- Password Strength Indicator -->
                <div class="bg-blue-50 border-2 border-blue-200 rounded-xl p-4">
                    <p class="font-bold text-blue-900 mb-2 flex items-center gap-2">
                        <i class="fas fa-info-circle"></i>
                        متطلبات كلمة المرور:
                    </p>
                    <ul class="text-sm text-blue-800 space-y-1">
                        <li class="flex items-center gap-2"><i class="fas fa-check-circle text-green-600"></i> على الأقل 8 أحرف</li>
                        <li class="flex items-center gap-2"><i class="fas fa-check-circle text-green-600"></i> حرف كبير واحد على الأقل</li>
                        <li class="flex items-center gap-2"><i class="fas fa-check-circle text-green-600"></i> حرف صغير واحد على الأقل</li>
                        <li class="flex items-center gap-2"><i class="fas fa-check-circle text-green-600"></i> رقم واحد على الأقل</li>
                        <li class="flex items-center gap-2"><i class="fas fa-check-circle text-green-600"></i> رمز خاص واحد على الأقل (@$!%*?&)</li>
                    </ul>
                </div>
            </div>

            <div class="border-t border-gray-200 my-8"></div>

            <!-- Action Buttons -->
            <div class="flex flex-col md:flex-row gap-4 justify-end">
                <a href="{{ route('admin.profile.index') }}" class="px-6 py-3 border-2 border-gray-300 rounded-xl text-gray-700 hover:bg-gray-50 font-bold transition-all text-center">
                    <i class="fas fa-times ml-2"></i>
                    إلغاء
                </a>
                <button type="submit" class="px-8 py-3 bg-gradient-to-r from-red-600 to-pink-600 hover:from-red-700 hover:to-pink-700 text-white rounded-xl font-bold shadow-lg transition-all">
                    <i class="fas fa-save ml-2"></i>
                    تحديث كلمة المرور
                </button>
            </div>
        </form>
    </div>
</div>

@push('scripts')
<script>
function togglePassword(fieldId) {
    const field = document.getElementById(fieldId);
    const icon = document.getElementById(fieldId + '-icon');

    if (field.type === 'password') {
        field.type = 'text';
        icon.classList.remove('fa-eye');
        icon.classList.add('fa-eye-slash');
    } else {
        field.type = 'password';
        icon.classList.remove('fa-eye-slash');
        icon.classList.add('fa-eye');
    }
}
</script>
@endpush
@endsection
