@extends('layouts.admin')

@section('title', 'الملف الشخصي')
@section('page-title', 'الملف الشخصي')

@section('content')
<div class="space-y-6" style="font-family: 'Cairo', sans-serif; direction: rtl;">
    <!-- Profile Header -->
    <div class="bg-gradient-to-r from-blue-600 to-indigo-600 rounded-xl shadow-lg p-8">
        <div class="flex flex-col md:flex-row items-center gap-6">
            <!-- Profile Picture -->
            <div class="relative">
                <div class="w-32 h-32 rounded-full border-4 border-white shadow-lg overflow-hidden bg-white">
                    @if(auth()->user()->profile_picture)
                        <img src="{{ Storage::url(auth()->user()->profile_picture) }}" alt="{{ auth()->user()->name }}" class="w-full h-full object-cover">
                    @else
                        <div class="w-full h-full flex items-center justify-center bg-blue-100">
                            <span class="text-5xl font-bold text-blue-600">{{ substr(auth()->user()->name, 0, 1) }}</span>
                        </div>
                    @endif
                </div>
                <button onclick="openModal('changePhotoModal')" class="absolute bottom-0 right-0 bg-white text-blue-600 p-2 rounded-full shadow-lg hover:bg-blue-50">
                    <i class="fas fa-camera"></i>
                </button>
            </div>

            <!-- User Info -->
            <div class="flex-1 text-center md:text-right text-white">
                <h1 class="text-3xl font-bold mb-2">{{ auth()->user()->name }}</h1>
                <p class="text-blue-100 mb-3 flex items-center justify-center md:justify-start gap-2">
                    <i class="fas fa-envelope"></i>
                    {{ auth()->user()->email }}
                </p>
                <p class="text-blue-100 flex items-center justify-center md:justify-start gap-2">
                    <i class="fas fa-user-tag"></i>
                    {{ auth()->user()->role_display }}
                </p>
                @if(auth()->user()->phone)
                <p class="text-blue-100 mt-2 flex items-center justify-center md:justify-start gap-2">
                    <i class="fas fa-phone"></i>
                    {{ auth()->user()->phone }}
                </p>
                @endif
            </div>

            <!-- Quick Actions -->
            <div class="flex flex-col gap-3">
                <a href="{{ route('admin.profile.edit') }}" class="px-6 py-3 bg-white text-blue-600 rounded-lg hover:bg-blue-50 font-bold shadow-md transition-all flex items-center gap-2">
                    <i class="fas fa-edit"></i>
                    تعديل الملف
                </a>
                <a href="{{ route('admin.profile.change-password') }}" class="px-6 py-3 bg-blue-700 hover:bg-blue-800 text-white rounded-lg font-bold shadow-md transition-all flex items-center gap-2">
                    <i class="fas fa-lock"></i>
                    تغيير كلمة المرور
                </a>
            </div>
        </div>
    </div>

    <!-- Statistics Cards -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div class="bg-gradient-to-br from-purple-500 to-purple-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-purple-100 text-sm mb-1">عضو منذ</p>
                    <p class="text-2xl font-bold">{{ auth()->user()->created_at->format('Y') }}</p>
                </div>
                <div class="w-14 h-14 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                    <i class="fas fa-calendar text-2xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-gradient-to-br from-green-500 to-green-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-green-100 text-sm mb-1">آخر تسجيل دخول</p>
                    <p class="text-xl font-bold">{{ auth()->user()->last_login_at ? auth()->user()->last_login_at->diffForHumans() : 'الآن' }}</p>
                </div>
                <div class="w-14 h-14 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                    <i class="fas fa-sign-in-alt text-2xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-gradient-to-br from-orange-500 to-orange-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-orange-100 text-sm mb-1">الجهاز</p>
                    <p class="text-xl font-bold">{{ auth()->user()->device_name ?? 'غير محدد' }}</p>
                </div>
                <div class="w-14 h-14 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                    <i class="fas fa-mobile-alt text-2xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-blue-100 text-sm mb-1">الحالة</p>
                    <p class="text-xl font-bold">نشط</p>
                </div>
                <div class="w-14 h-14 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                    <i class="fas fa-check-circle text-2xl"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Profile Sections -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Personal Information -->
        <div class="bg-white rounded-xl shadow-lg p-6">
            <div class="flex items-center justify-between mb-6">
                <h3 class="text-xl font-bold text-gray-900 flex items-center gap-2">
                    <i class="fas fa-user text-blue-600"></i>
                    المعلومات الشخصية
                </h3>
                <a href="{{ route('admin.profile.edit') }}" class="text-blue-600 hover:text-blue-700">
                    <i class="fas fa-edit"></i>
                </a>
            </div>
            <div class="space-y-4">
                <div class="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                    <i class="fas fa-user text-gray-400"></i>
                    <div>
                        <p class="text-xs text-gray-500">الاسم الكامل</p>
                        <p class="font-semibold">{{ auth()->user()->name }}</p>
                    </div>
                </div>
                <div class="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                    <i class="fas fa-envelope text-gray-400"></i>
                    <div>
                        <p class="text-xs text-gray-500">البريد الإلكتروني</p>
                        <p class="font-semibold">{{ auth()->user()->email }}</p>
                    </div>
                </div>
                @if(auth()->user()->phone)
                <div class="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                    <i class="fas fa-phone text-gray-400"></i>
                    <div>
                        <p class="text-xs text-gray-500">رقم الهاتف</p>
                        <p class="font-semibold">{{ auth()->user()->phone }}</p>
                    </div>
                </div>
                @endif
                <div class="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                    <i class="fas fa-calendar text-gray-400"></i>
                    <div>
                        <p class="text-xs text-gray-500">تاريخ التسجيل</p>
                        <p class="font-semibold">{{ auth()->user()->created_at->format('Y-m-d') }}</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Security Settings -->
        <div class="bg-white rounded-xl shadow-lg p-6">
            <div class="flex items-center justify-between mb-6">
                <h3 class="text-xl font-bold text-gray-900 flex items-center gap-2">
                    <i class="fas fa-shield-alt text-blue-600"></i>
                    الأمان والخصوصية
                </h3>
            </div>
            <div class="space-y-3">
                <a href="{{ route('admin.profile.change-password') }}" class="flex items-center justify-between p-4 bg-gray-50 hover:bg-gray-100 rounded-lg transition-all">
                    <div class="flex items-center gap-3">
                        <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                            <i class="fas fa-lock text-blue-600"></i>
                        </div>
                        <div>
                            <p class="font-semibold">تغيير كلمة المرور</p>
                            <p class="text-xs text-gray-500">تحديث كلمة المرور الخاصة بك</p>
                        </div>
                    </div>
                    <i class="fas fa-chevron-left text-gray-400"></i>
                </a>

                <a href="{{ route('admin.profile.devices') }}" class="flex items-center justify-between p-4 bg-gray-50 hover:bg-gray-100 rounded-lg transition-all">
                    <div class="flex items-center gap-3">
                        <div class="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
                            <i class="fas fa-mobile-alt text-green-600"></i>
                        </div>
                        <div>
                            <p class="font-semibold">إدارة الأجهزة</p>
                            <p class="text-xs text-gray-500">الأجهزة المرتبطة بحسابك</p>
                        </div>
                    </div>
                    <i class="fas fa-chevron-left text-gray-400"></i>
                </a>

                <a href="{{ route('admin.profile.activity') }}" class="flex items-center justify-between p-4 bg-gray-50 hover:bg-gray-100 rounded-lg transition-all">
                    <div class="flex items-center gap-3">
                        <div class="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
                            <i class="fas fa-history text-purple-600"></i>
                        </div>
                        <div>
                            <p class="font-semibold">سجل النشاط</p>
                            <p class="text-xs text-gray-500">عرض نشاطك الأخير</p>
                        </div>
                    </div>
                    <i class="fas fa-chevron-left text-gray-400"></i>
                </a>

                <a href="{{ route('admin.settings.index') }}" class="flex items-center justify-between p-4 bg-gray-50 hover:bg-gray-100 rounded-lg transition-all">
                    <div class="flex items-center gap-3">
                        <div class="w-10 h-10 bg-orange-100 rounded-lg flex items-center justify-center">
                            <i class="fas fa-cog text-orange-600"></i>
                        </div>
                        <div>
                            <p class="font-semibold">الإعدادات</p>
                            <p class="text-xs text-gray-500">تخصيص تفضيلاتك</p>
                        </div>
                    </div>
                    <i class="fas fa-chevron-left text-gray-400"></i>
                </a>
            </div>
        </div>
    </div>

    <!-- Recent Activity -->
    <div class="bg-white rounded-xl shadow-lg p-6">
        <h3 class="text-xl font-bold text-gray-900 mb-6 flex items-center gap-2">
            <i class="fas fa-clock text-blue-600"></i>
            النشاط الأخير
        </h3>
        <div class="space-y-3">
            <div class="flex items-center gap-4 p-4 bg-gray-50 rounded-lg">
                <div class="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                    <i class="fas fa-sign-in-alt text-blue-600"></i>
                </div>
                <div class="flex-1">
                    <p class="font-semibold">تسجيل دخول</p>
                    <p class="text-sm text-gray-500">{{ auth()->user()->last_login_at ? auth()->user()->last_login_at->format('Y-m-d H:i') : 'الآن' }}</p>
                </div>
            </div>

            <div class="flex items-center gap-4 p-4 bg-gray-50 rounded-lg">
                <div class="w-10 h-10 bg-green-100 rounded-full flex items-center justify-center">
                    <i class="fas fa-user-edit text-green-600"></i>
                </div>
                <div class="flex-1">
                    <p class="font-semibold">تحديث الملف الشخصي</p>
                    <p class="text-sm text-gray-500">{{ auth()->user()->updated_at->format('Y-m-d H:i') }}</p>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Change Photo Modal -->
<div id="changePhotoModal" class="hidden fixed inset-0 bg-black bg-opacity-60 backdrop-blur-sm overflow-y-auto h-full w-full z-50" style="font-family: 'Cairo', sans-serif; direction: rtl;">
    <div class="relative top-20 mx-auto p-0 border-0 w-full max-w-md">
        <div class="bg-white rounded-2xl shadow-2xl overflow-hidden">
            <div class="bg-gradient-to-r from-blue-600 to-indigo-600 px-6 py-5">
                <div class="flex justify-between items-center">
                    <h3 class="text-xl font-bold text-white">تغيير صورة الملف الشخصي</h3>
                    <button onclick="closeModal('changePhotoModal')" class="text-white hover:bg-white hover:bg-opacity-20 w-8 h-8 rounded-lg transition-all">
                        <i class="fas fa-times text-xl"></i>
                    </button>
                </div>
            </div>

            <form action="{{ route('admin.profile.update-picture') }}" method="POST" enctype="multipart/form-data" class="p-6">
                @csrf
                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-2">اختر صورة جديدة</label>
                        <input type="file" name="profile_picture" accept="image/*" required class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 transition-all">
                    </div>

                    <div class="flex gap-3">
                        <button type="button" onclick="closeModal('changePhotoModal')" class="flex-1 px-6 py-3 border-2 border-gray-300 rounded-xl text-gray-700 hover:bg-gray-50 font-bold transition-all">
                            إلغاء
                        </button>
                        <button type="submit" class="flex-1 px-6 py-3 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white rounded-xl font-bold shadow-lg transition-all">
                            حفظ
                        </button>
                    </div>
                </div>
            </form>

            @if(auth()->user()->profile_picture)
            <div class="px-6 pb-6">
                <form action="{{ route('admin.profile.delete-picture') }}" method="POST">
                    @csrf
                    @method('DELETE')
                    <button type="submit" onclick="return confirm('هل أنت متأكد من حذف الصورة؟')" class="w-full px-6 py-3 bg-red-50 hover:bg-red-100 text-red-600 rounded-xl font-bold transition-all">
                        <i class="fas fa-trash ml-2"></i>
                        حذف الصورة الحالية
                    </button>
                </form>
            </div>
            @endif
        </div>
    </div>
</div>

@push('scripts')
<script>
function openModal(modalId) {
    document.getElementById(modalId).classList.remove('hidden');
    document.body.style.overflow = 'hidden';
}

function closeModal(modalId) {
    document.getElementById(modalId).classList.add('hidden');
    document.body.style.overflow = 'auto';
}

// Close modal on background click
document.querySelectorAll('[id$="Modal"]').forEach(modal => {
    modal.addEventListener('click', function(e) {
        if (e.target === this) {
            closeModal(this.id);
        }
    });
});
</script>
@endpush
@endsection
