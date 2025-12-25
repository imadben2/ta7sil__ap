@extends('layouts.admin')

@section('title', 'باقات الاشتراك')
@section('page-title', 'إدارة باقات الاشتراك')

@section('content')
<div class="space-y-6" style="font-family: 'Cairo', sans-serif; direction: rtl;">
    <!-- Enhanced Header with Gradient -->
    <div class="bg-gradient-to-r from-purple-600 to-pink-600 rounded-xl shadow-lg p-6">
        <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
            <div class="text-white">
                <h2 class="text-2xl font-bold mb-2">باقات الاشتراك الشاملة</h2>
                <p class="text-purple-100">إنشاء وإدارة باقات مخصصة للطلاب</p>
            </div>
            <div class="flex gap-3">
                <a href="{{ route('admin.subscriptions.packages.create') }}"
                   class="bg-white text-purple-600 hover:bg-purple-50 px-6 py-3 rounded-lg flex items-center gap-2 shadow-md font-semibold">
                    <i class="fas fa-plus-circle"></i>
                    <span>إضافة باقة جديدة</span>
                </a>
                <a href="{{ route('admin.exports.packages.statistics') }}"
                   class="bg-green-500 hover:bg-green-600 text-white px-6 py-3 rounded-lg flex items-center gap-2 shadow-md">
                    <i class="fas fa-file-download"></i>
                    <span>تصدير إحصائيات</span>
                </a>
            </div>
        </div>
    </div>

    <!-- Enhanced Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div class="bg-gradient-to-br from-indigo-500 to-indigo-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-indigo-100 text-sm font-medium mb-1">إجمالي الباقات</p>
                    <p class="text-4xl font-bold">{{ $packages->total() }}</p>
                    <p class="text-indigo-100 text-xs mt-2">باقة متاحة</p>
                </div>
                <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center">
                    <i class="fas fa-box text-3xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-gradient-to-br from-green-500 to-green-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-green-100 text-sm font-medium mb-1">الباقات النشطة</p>
                    <p class="text-4xl font-bold">{{ $packages->where('is_active', true)->count() }}</p>
                    <p class="text-green-100 text-xs mt-2">متاحة للاشتراك</p>
                </div>
                <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center">
                    <i class="fas fa-check-circle text-3xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-gradient-to-br from-gray-500 to-gray-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-100 text-sm font-medium mb-1">الباقات المعطلة</p>
                    <p class="text-4xl font-bold">{{ $packages->where('is_active', false)->count() }}</p>
                    <p class="text-gray-100 text-xs mt-2">غير متاحة</p>
                </div>
                <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center">
                    <i class="fas fa-times-circle text-3xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-gradient-to-br from-blue-500 to-cyan-500 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-blue-100 text-sm font-medium mb-1">إجمالي المشتركين</p>
                    <p class="text-4xl font-bold">
                        {{ \App\Models\UserSubscription::whereNotNull('course_id')->where('is_active', true)->count() }}
                    </p>
                    <p class="text-blue-100 text-xs mt-2">مشترك نشط</p>
                </div>
                <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center">
                    <i class="fas fa-users text-3xl"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Packages Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
        @forelse($packages as $package)
            <div class="bg-white rounded-xl shadow-md overflow-hidden border-2 border-gray-100 hover:shadow-lg transition-shadow duration-300 {{ $package->is_featured ? 'ring-2 ring-yellow-400' : '' }}">
                <!-- Package Header with Image Support -->
                <div class="relative">
                    @if($package->image_url)
                        <!-- Image Header -->
                        <div class="h-48 overflow-hidden relative">
                            <img src="{{ asset('storage/' . $package->image_url) }}" alt="{{ $package->name_ar }}" class="w-full h-full object-cover">
                            <div class="absolute inset-0 bg-gradient-to-t from-black/70 via-black/30 to-transparent"></div>
                            <!-- Content overlay for image -->
                            <div class="absolute bottom-0 left-0 right-0 p-6 text-white">
                                <div class="flex justify-between items-start mb-3">
                                    <div class="flex-1">
                                        <h3 class="text-2xl font-bold mb-2">{{ $package->name_ar }}</h3>
                                        <p class="text-gray-200 text-sm flex items-center gap-2">
                                            <i class="fas fa-layer-group"></i>
                                            {{ $package->courses->count() }} دورة تعليمية
                                        </p>
                                    </div>
                                    <div class="flex flex-col gap-2 items-end">
                                        @if($package->is_active)
                                            <span class="px-3 py-1.5 text-xs font-bold rounded-full bg-green-500 text-white shadow-lg flex items-center gap-1">
                                                <i class="fas fa-check-circle"></i>
                                                نشطة
                                            </span>
                                        @else
                                            <span class="px-3 py-1.5 text-xs font-bold rounded-full bg-gray-500 text-white shadow-lg flex items-center gap-1">
                                                <i class="fas fa-times-circle"></i>
                                                معطلة
                                            </span>
                                        @endif
                                        @if($package->sort_order > 0)
                                            <span class="px-2 py-1 text-xs font-medium rounded bg-white/20 text-white">
                                                <i class="fas fa-sort-numeric-up"></i> {{ $package->sort_order }}
                                            </span>
                                        @endif
                                    </div>
                                </div>
                                <!-- Badges Row -->
                                <div class="flex flex-wrap gap-2">
                                    @if($package->is_featured)
                                        <div class="inline-flex items-center gap-1 px-3 py-1 bg-yellow-400 text-yellow-900 rounded-full text-xs font-bold">
                                            <i class="fas fa-star"></i>
                                            باقة مميزة
                                        </div>
                                    @endif
                                    @if($package->badge_text)
                                        <div class="inline-flex items-center gap-1 px-3 py-1 bg-red-500 text-white rounded-full text-xs font-bold">
                                            <i class="fas fa-tag"></i>
                                            {{ $package->badge_text }}
                                        </div>
                                    @endif
                                </div>
                            </div>
                        </div>
                    @else
                        <!-- Gradient Header (default) -->
                        <div class="p-6 text-white" style="background: {{ $package->background_color ?? 'linear-gradient(to right, #8b5cf6, #ec4899)' }};">
                            <div class="flex justify-between items-start mb-3">
                                <div class="flex-1">
                                    <h3 class="text-2xl font-bold mb-2">{{ $package->name_ar }}</h3>
                                    <p class="text-purple-100 text-sm flex items-center gap-2">
                                        <i class="fas fa-layer-group"></i>
                                        {{ $package->courses->count() }} دورة تعليمية
                                    </p>
                                </div>
                                <div class="flex flex-col gap-2 items-end">
                                    @if($package->is_active)
                                        <span class="px-3 py-1.5 text-xs font-bold rounded-full bg-green-500 text-white shadow-lg flex items-center gap-1">
                                            <i class="fas fa-check-circle"></i>
                                            نشطة
                                        </span>
                                    @else
                                        <span class="px-3 py-1.5 text-xs font-bold rounded-full bg-gray-500 text-white shadow-lg flex items-center gap-1">
                                            <i class="fas fa-times-circle"></i>
                                            معطلة
                                        </span>
                                    @endif
                                    @if($package->sort_order > 0)
                                        <span class="px-2 py-1 text-xs font-medium rounded bg-white/20 text-white">
                                            <i class="fas fa-sort-numeric-up"></i> {{ $package->sort_order }}
                                        </span>
                                    @endif
                                </div>
                            </div>
                            <!-- Badges Row -->
                            <div class="flex flex-wrap gap-2">
                                @if($package->is_featured)
                                    <div class="inline-flex items-center gap-1 px-3 py-1 bg-yellow-400 text-yellow-900 rounded-full text-xs font-bold">
                                        <i class="fas fa-star"></i>
                                        باقة مميزة
                                    </div>
                                @endif
                                @if($package->badge_text)
                                    <div class="inline-flex items-center gap-1 px-3 py-1 bg-red-500 text-white rounded-full text-xs font-bold">
                                        <i class="fas fa-tag"></i>
                                        {{ $package->badge_text }}
                                    </div>
                                @endif
                            </div>
                        </div>
                    @endif
                </div>

                <!-- Package Body -->
                <div class="p-6">
                    <!-- Description -->
                    <p class="text-gray-600 text-sm mb-6 line-clamp-3 leading-relaxed">{{ $package->description_ar }}</p>

                    <!-- Price & Duration Box -->
                    <div class="bg-gradient-to-br from-blue-50 to-purple-50 rounded-xl p-5 mb-6 border border-purple-100">
                        <div class="flex justify-between items-center mb-3">
                            <span class="text-sm font-medium text-gray-600 flex items-center gap-2">
                                <i class="fas fa-tag text-purple-500"></i>
                                السعر
                            </span>
                            <span class="text-3xl font-bold bg-gradient-to-r from-purple-600 to-pink-600 bg-clip-text text-transparent">
                                {{ number_format($package->price_dzd) }} دج
                            </span>
                        </div>
                        <div class="flex justify-between items-center pt-3 border-t border-purple-100">
                            <span class="text-sm font-medium text-gray-600 flex items-center gap-2">
                                <i class="fas fa-calendar-alt text-purple-500"></i>
                                المدة
                            </span>
                            <span class="text-lg font-bold text-gray-800">{{ $package->duration_days }} يوم</span>
                        </div>
                    </div>

                    <!-- Courses List -->
                    <div class="mb-6">
                        <h4 class="text-sm font-bold text-gray-800 mb-3 flex items-center gap-2">
                            <i class="fas fa-graduation-cap text-purple-500"></i>
                            الدورات المتضمنة:
                        </h4>
                        <div class="space-y-2 max-h-40 overflow-y-auto">
                            @foreach($package->courses->take(3) as $course)
                                <div class="flex items-center gap-2 text-sm text-gray-700 bg-gray-50 rounded-lg p-2">
                                    <i class="fas fa-check-circle text-green-500 text-xs"></i>
                                    <span class="truncate">{{ $course->title_ar }}</span>
                                </div>
                            @endforeach
                            @if($package->courses->count() > 3)
                                <p class="text-xs text-purple-600 font-semibold text-center py-2 bg-purple-50 rounded-lg">
                                    <i class="fas fa-plus-circle ml-1"></i>
                                    {{ $package->courses->count() - 3 }} دورات إضافية
                                </p>
                            @endif
                        </div>
                    </div>

                    <!-- Stats Grid -->
                    <div class="grid grid-cols-2 gap-3 mb-6 pt-6 border-t border-gray-100">
                        <div class="text-center bg-green-50 rounded-lg p-3">
                            <p class="text-xs text-green-600 font-medium mb-1">الاشتراكات النشطة</p>
                            <p class="text-2xl font-bold text-green-700">
                                {{ $package->subscriptions()->where('is_active', true)->where('expires_at', '>', now())->count() }}
                            </p>
                        </div>
                        <div class="text-center bg-blue-50 rounded-lg p-3">
                            <p class="text-xs text-blue-600 font-medium mb-1">إجمالي الاشتراكات</p>
                            <p class="text-2xl font-bold text-blue-700">{{ $package->subscriptions->count() }}</p>
                        </div>
                    </div>

                    <!-- Action Buttons -->
                    <div class="flex gap-2">
                        <a href="{{ route('admin.subscriptions.packages.edit', $package) }}"
                           class="flex-1 bg-blue-50 hover:bg-blue-100 text-blue-600 py-3 rounded-lg text-center font-semibold flex items-center justify-center gap-2">
                            <i class="fas fa-edit"></i>
                            <span>تعديل</span>
                        </a>
                        <button onclick="deletePackage({{ $package->id }})"
                                class="flex-1 bg-red-50 hover:bg-red-100 text-red-600 py-3 rounded-lg text-center font-semibold flex items-center justify-center gap-2">
                            <i class="fas fa-trash"></i>
                            <span>حذف</span>
                        </button>
                    </div>
                </div>
            </div>
        @empty
            <div class="col-span-full">
                <div class="bg-white rounded-xl shadow-md p-12 text-center">
                    <div class="w-24 h-24 bg-gradient-to-br from-purple-100 to-pink-100 rounded-full flex items-center justify-center mx-auto mb-4">
                        <i class="fas fa-box-open text-purple-400 text-5xl"></i>
                    </div>
                    <h3 class="text-2xl font-bold text-gray-700 mb-2">لا توجد باقات اشتراك</h3>
                    <p class="text-gray-500 mb-6">ابدأ بإنشاء أول باقة اشتراك للطلاب</p>
                    <a href="{{ route('admin.subscriptions.packages.create') }}"
                       class="inline-flex items-center gap-2 bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700 text-white px-8 py-3 rounded-lg font-semibold shadow-md">
                        <i class="fas fa-plus-circle"></i>
                        إضافة باقة جديدة
                    </a>
                </div>
            </div>
        @endforelse
    </div>

    <!-- Pagination -->
    @if($packages->hasPages())
        <div class="bg-white rounded-xl shadow-md p-6">
            {{ $packages->links() }}
        </div>
    @endif
</div>

<!-- Delete Confirmation Script -->
<script>
function deletePackage(id) {
    if (confirm('هل أنت متأكد من حذف هذه الباقة؟\nلن تتمكن من التراجع عن هذا الإجراء.')) {
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = `/admin/subscriptions/packages/${id}`;

        const csrfToken = document.createElement('input');
        csrfToken.type = 'hidden';
        csrfToken.name = '_token';
        csrfToken.value = '{{ csrf_token() }}';

        const methodField = document.createElement('input');
        methodField.type = 'hidden';
        methodField.name = '_method';
        methodField.value = 'DELETE';

        form.appendChild(csrfToken);
        form.appendChild(methodField);
        document.body.appendChild(form);
        form.submit();
    }
}
</script>
@endsection
