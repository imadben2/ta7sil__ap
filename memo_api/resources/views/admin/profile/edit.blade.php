@extends('layouts.admin')

@section('title', 'تعديل الملف الشخصي')
@section('page-title', 'تعديل الملف الشخصي')

@section('content')
<div class="max-w-4xl mx-auto" style="font-family: 'Cairo', sans-serif; direction: rtl;">
    <div class="bg-white rounded-xl shadow-lg overflow-hidden">
        <!-- Header -->
        <div class="bg-gradient-to-r from-blue-600 to-indigo-600 px-8 py-6">
            <h2 class="text-2xl font-bold text-white flex items-center gap-3">
                <i class="fas fa-user-edit"></i>
                تعديل المعلومات الشخصية
            </h2>
            <p class="text-blue-100 mt-2">قم بتحديث معلوماتك الشخصية هنا</p>
        </div>

        <!-- Form -->
        <form action="{{ route('admin.profile.update') }}" method="POST" enctype="multipart/form-data" class="p-8">
            @csrf
            @method('PUT')

            <!-- Profile Picture Section -->
            <div class="mb-8">
                <label class="block text-sm font-bold text-gray-700 mb-4">صورة الملف الشخصي</label>
                <div class="flex items-center gap-6">
                    <div class="relative">
                        <div class="w-24 h-24 rounded-full border-4 border-blue-200 shadow-lg overflow-hidden bg-white">
                            @if(auth()->user()->profile_picture)
                                <img id="preview" src="{{ Storage::url(auth()->user()->profile_picture) }}" alt="{{ auth()->user()->name }}" class="w-full h-full object-cover">
                            @else
                                <div id="preview" class="w-full h-full flex items-center justify-center bg-blue-100">
                                    <span class="text-4xl font-bold text-blue-600">{{ substr(auth()->user()->name, 0, 1) }}</span>
                                </div>
                            @endif
                        </div>
                    </div>

                    <div class="flex-1">
                        <input type="file" name="profile_picture" id="profile_picture" accept="image/*" class="hidden" onchange="previewImage(event)">
                        <label for="profile_picture" class="inline-block px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-bold cursor-pointer transition-all">
                            <i class="fas fa-upload ml-2"></i>
                            اختر صورة جديدة
                        </label>
                        <p class="text-sm text-gray-500 mt-2">JPG, PNG أو GIF (الحد الأقصى 2MB)</p>
                    </div>
                </div>
                @error('profile_picture')
                    <p class="text-red-600 text-sm mt-2">{{ $message }}</p>
                @enderror
            </div>

            <div class="border-t border-gray-200 mb-8"></div>

            <!-- Personal Information -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <!-- Full Name -->
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                        <i class="fas fa-user text-blue-600"></i>
                        الاسم الكامل *
                    </label>
                    <input type="text" name="name" value="{{ old('name', auth()->user()->name) }}" required
                           class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all @error('name') border-red-500 @enderror"
                           placeholder="أدخل اسمك الكامل">
                    @error('name')
                        <p class="text-red-600 text-sm mt-1">{{ $message }}</p>
                    @enderror
                </div>

                <!-- Email -->
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                        <i class="fas fa-envelope text-blue-600"></i>
                        البريد الإلكتروني *
                    </label>
                    <input type="email" name="email" value="{{ old('email', auth()->user()->email) }}" required
                           class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all @error('email') border-red-500 @enderror"
                           placeholder="example@domain.com">
                    @error('email')
                        <p class="text-red-600 text-sm mt-1">{{ $message }}</p>
                    @enderror
                </div>

                <!-- Phone -->
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                        <i class="fas fa-phone text-blue-600"></i>
                        رقم الهاتف
                    </label>
                    <input type="tel" name="phone" value="{{ old('phone', auth()->user()->phone) }}"
                           class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all @error('phone') border-red-500 @enderror"
                           placeholder="+213 xxx xxx xxx">
                    @error('phone')
                        <p class="text-red-600 text-sm mt-1">{{ $message }}</p>
                    @enderror
                </div>

                <!-- Date of Birth -->
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                        <i class="fas fa-calendar text-blue-600"></i>
                        تاريخ الميلاد
                    </label>
                    <input type="date" name="date_of_birth" value="{{ old('date_of_birth', auth()->user()->date_of_birth) }}"
                           class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all @error('date_of_birth') border-red-500 @enderror">
                    @error('date_of_birth')
                        <p class="text-red-600 text-sm mt-1">{{ $message }}</p>
                    @enderror
                </div>
            </div>

            <!-- Bio -->
            <div class="mt-6">
                <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                    <i class="fas fa-align-right text-blue-600"></i>
                    نبذة عنك
                </label>
                <textarea name="bio" rows="4"
                          class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all @error('bio') border-red-500 @enderror"
                          placeholder="اكتب نبذة قصيرة عنك...">{{ old('bio', auth()->user()->bio) }}</textarea>
                @error('bio')
                    <p class="text-red-600 text-sm mt-1">{{ $message }}</p>
                @enderror
            </div>

            <div class="border-t border-gray-200 my-8"></div>

            <!-- Action Buttons -->
            <div class="flex flex-col md:flex-row gap-4 justify-end">
                <a href="{{ route('admin.profile.index') }}" class="px-6 py-3 border-2 border-gray-300 rounded-xl text-gray-700 hover:bg-gray-50 font-bold transition-all text-center">
                    <i class="fas fa-times ml-2"></i>
                    إلغاء
                </a>
                <button type="submit" class="px-8 py-3 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white rounded-xl font-bold shadow-lg transition-all">
                    <i class="fas fa-save ml-2"></i>
                    حفظ التعديلات
                </button>
            </div>
        </form>
    </div>
</div>

@push('scripts')
<script>
function previewImage(event) {
    const reader = new FileReader();
    reader.onload = function() {
        const preview = document.getElementById('preview');
        preview.innerHTML = `<img src="${reader.result}" class="w-full h-full object-cover">`;
    }
    reader.readAsDataURL(event.target.files[0]);
}
</script>
@endpush
@endsection
