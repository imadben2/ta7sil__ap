@extends('layouts.admin')

@section('title', 'تفاصيل المستخدم')
@section('page-title', 'تفاصيل المستخدم')
@section('page-description', $user->name)

@section('content')
<div x-data="{ activeTab: 'general' }">
    <!-- User Header Card -->
    <div class="bg-gradient-to-l from-blue-600 to-blue-700 rounded-lg shadow-lg p-8 mb-6 text-white">
        <div class="flex items-center justify-between">
            <div class="flex items-center">
                @if($user->profile_image)
                    <img src="{{ $user->profile_image }}" class="w-24 h-24 rounded-full border-4 border-white shadow-lg mr-6">
                @else
                    <div class="w-24 h-24 rounded-full bg-white/20 flex items-center justify-center mr-6 border-4 border-white">
                        <i class="fas fa-user text-4xl"></i>
                    </div>
                @endif

                <div>
                    <h2 class="text-3xl font-bold mb-2">{{ $user->name }}</h2>
                    <p class="text-blue-100 mb-1">
                        <i class="fas fa-envelope mr-2"></i>
                        {{ $user->email }}
                    </p>
                    <p class="text-blue-100">
                        <i class="fas fa-phone mr-2"></i>
                        {{ $user->phone ?? 'لا يوجد رقم' }}
                    </p>
                </div>
            </div>

            <!-- Quick Stats -->
            <div class="grid grid-cols-3 gap-6">
                <div class="text-center">
                    <div class="text-3xl font-bold">{{ round(($user->stats->total_study_minutes ?? 0) / 60, 1) }}</div>
                    <div class="text-blue-200 text-sm">ساعات الدراسة</div>
                </div>
                <div class="text-center">
                    <div class="text-3xl font-bold">{{ $user->stats->current_streak_days ?? 0 }}</div>
                    <div class="text-blue-200 text-sm">أيام متتالية</div>
                </div>
                <div class="text-center">
                    <div class="text-3xl font-bold">{{ $user->stats->level ?? 1 }}</div>
                    <div class="text-blue-200 text-sm">المستوى</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Tabs Navigation -->
    <div class="bg-white rounded-lg shadow-sm mb-6">
        <div class="border-b border-gray-200">
            <nav class="flex -mb-px">
                <button @click="activeTab = 'general'"
                        :class="activeTab === 'general' ? 'border-blue-500 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'"
                        class="px-6 py-4 border-b-2 font-medium text-sm transition-colors">
                    <i class="fas fa-info-circle mr-2"></i>
                    معلومات عامة
                </button>
                <button @click="activeTab = 'academic'"
                        :class="activeTab === 'academic' ? 'border-blue-500 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'"
                        class="px-6 py-4 border-b-2 font-medium text-sm transition-colors">
                    <i class="fas fa-graduation-cap mr-2"></i>
                    الملف الأكاديمي
                </button>
                <button @click="activeTab = 'stats'"
                        :class="activeTab === 'stats' ? 'border-blue-500 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'"
                        class="px-6 py-4 border-b-2 font-medium text-sm transition-colors">
                    <i class="fas fa-chart-line mr-2"></i>
                    الإحصائيات
                </button>
                <button @click="activeTab = 'activity'"
                        :class="activeTab === 'activity' ? 'border-blue-500 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'"
                        class="px-6 py-4 border-b-2 font-medium text-sm transition-colors">
                    <i class="fas fa-history mr-2"></i>
                    سجل النشاطات
                </button>
                <button @click="activeTab = 'actions'"
                        :class="activeTab === 'actions' ? 'border-blue-500 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'"
                        class="px-6 py-4 border-b-2 font-medium text-sm transition-colors">
                    <i class="fas fa-cog mr-2"></i>
                    إجراءات
                </button>
            </nav>
        </div>
    </div>

    <!-- Tab Contents -->

    <!-- General Information Tab -->
    <div x-show="activeTab === 'general'" class="bg-white rounded-lg shadow-sm p-6">
        <h3 class="text-xl font-semibold mb-6">المعلومات الأساسية</h3>

        <form method="POST" action="{{ route('admin.users.update', $user->id) }}" class="grid grid-cols-2 gap-6">
            @csrf
            @method('PUT')

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">الاسم الكامل</label>
                <input type="text" name="name" value="{{ $user->name }}"
                       class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">البريد الإلكتروني</label>
                <input type="email" name="email" value="{{ $user->email }}"
                       class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">رقم الهاتف</label>
                <input type="text" name="phone" value="{{ $user->phone }}"
                       class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">الحالة</label>
                <select name="is_active" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                    <option value="1" {{ $user->is_active ? 'selected' : '' }}>نشط</option>
                    <option value="0" {{ !$user->is_active ? 'selected' : '' }}>غير نشط</option>
                </select>
            </div>

            <div class="col-span-2">
                <h4 class="font-semibold mb-3 text-gray-700 flex items-center gap-2">
                    <i class="fas fa-mobile-alt text-blue-600"></i>
                    معلومات الجهاز
                </h4>
                <div class="bg-gradient-to-br from-blue-50 to-indigo-50 p-5 rounded-lg border border-blue-200">
                    @if($user->device_name || $user->device_model || $user->device_os)
                        <div class="space-y-3">
                            <div class="flex items-start gap-3">
                                <i class="fas fa-mobile-alt text-blue-600 mt-1"></i>
                                <div>
                                    <p class="text-xs text-gray-500 mb-1">اسم الجهاز</p>
                                    <p class="text-sm font-semibold text-gray-800">{{ $user->device_name ?? '-' }}</p>
                                </div>
                            </div>
                            <div class="flex items-start gap-3">
                                <i class="fas fa-tablet-alt text-blue-600 mt-1"></i>
                                <div>
                                    <p class="text-xs text-gray-500 mb-1">الموديل</p>
                                    <p class="text-sm font-semibold text-gray-800">{{ $user->device_model ?? '-' }}</p>
                                </div>
                            </div>
                            <div class="flex items-start gap-3">
                                <i class="fab fa-android text-blue-600 mt-1"></i>
                                <div>
                                    <p class="text-xs text-gray-500 mb-1">نظام التشغيل</p>
                                    <p class="text-sm font-semibold text-gray-800">{{ $user->device_os ?? '-' }}</p>
                                </div>
                            </div>
                            @if($user->device_uuid)
                            <div class="flex items-start gap-3">
                                <i class="fas fa-fingerprint text-blue-600 mt-1"></i>
                                <div>
                                    <p class="text-xs text-gray-500 mb-1">معرف الجهاز الفريد</p>
                                    <p class="text-xs font-mono text-gray-700 bg-white px-2 py-1 rounded">{{ $user->device_uuid }}</p>
                                </div>
                            </div>
                            @endif
                            @if($user->last_login_at)
                            <div class="flex items-start gap-3">
                                <i class="fas fa-clock text-green-600 mt-1"></i>
                                <div>
                                    <p class="text-xs text-gray-500 mb-1">آخر تسجيل دخول</p>
                                    <p class="text-sm font-semibold text-gray-800">{{ $user->last_login_at->format('Y-m-d H:i') }}</p>
                                    <p class="text-xs text-gray-500">{{ $user->last_login_at->diffForHumans() }}</p>
                                </div>
                            </div>
                            @endif
                        </div>
                    @else
                        <div class="text-center py-4">
                            <i class="fas fa-mobile-alt text-gray-400 text-3xl mb-2"></i>
                            <p class="text-gray-500 font-semibold">لم يتم ربط أي جهاز بعد</p>
                            <p class="text-xs text-gray-400 mt-1">سيتم تسجيل معلومات الجهاز عند تسجيل الدخول الأول</p>
                        </div>
                    @endif
                </div>
            </div>

            <div class="col-span-2 flex gap-2">
                <button type="submit" class="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
                    <i class="fas fa-save mr-2"></i>
                    حفظ التغييرات
                </button>
                <a href="{{ route('admin.users.index') }}" class="px-6 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300">
                    إلغاء
                </a>
            </div>
        </form>
    </div>

    <!-- Academic Profile Tab -->
    <div x-show="activeTab === 'academic'" class="bg-white rounded-lg shadow-sm p-6">
        <h3 class="text-xl font-semibold mb-6">الملف الأكاديمي</h3>

        <div class="grid grid-cols-2 gap-6 mb-6">
            <div class="bg-blue-50 p-4 rounded-lg">
                <p class="text-sm text-gray-600 mb-1">المرحلة الدراسية</p>
                <p class="text-lg font-semibold text-gray-900">
                    {{ $user->academicProfile?->academicYear?->academicPhase?->name_ar ?? 'غير محدد' }}
                </p>
            </div>

            <div class="bg-green-50 p-4 rounded-lg">
                <p class="text-sm text-gray-600 mb-1">السنة الدراسية</p>
                <p class="text-lg font-semibold text-gray-900">
                    {{ $user->academicProfile?->academicYear?->name_ar ?? 'غير محدد' }}
                </p>
            </div>

            <div class="bg-purple-50 p-4 rounded-lg">
                <p class="text-sm text-gray-600 mb-1">الشعبة</p>
                <p class="text-lg font-semibold text-gray-900">
                    {{ $user->academicProfile?->academicStream?->name_ar ?? 'غير محدد' }}
                </p>
            </div>

            <div class="bg-yellow-50 p-4 rounded-lg">
                <p class="text-sm text-gray-600 mb-1">عدد المواد</p>
                <p class="text-lg font-semibold text-gray-900">
                    {{ $user->subjects->count() }} مادة
                </p>
            </div>
        </div>

        <!-- Subjects List -->
        <h4 class="font-semibold mb-3">المواد الدراسية</h4>
        <div class="grid grid-cols-3 gap-4">
            @foreach($user->userSubjects as $userSubject)
            <div class="border border-gray-200 rounded-lg p-4">
                <p class="font-medium text-gray-900">{{ $userSubject->subject->name_ar }}</p>
                <div class="mt-2 flex items-center justify-between text-sm">
                    <span class="text-gray-600">المعامل: {{ $userSubject->coefficient }}</span>
                    @if($userSubject->is_favorite)
                        <i class="fas fa-star text-yellow-500"></i>
                    @endif
                </div>
                <div class="mt-2 text-xs text-gray-500">
                    الهدف الأسبوعي: {{ round($userSubject->weekly_goal_minutes / 60, 1) }} ساعة
                </div>
            </div>
            @endforeach
        </div>
    </div>

    <!-- Statistics Tab -->
    <div x-show="activeTab === 'stats'" class="bg-white rounded-lg shadow-sm p-6">
        <h3 class="text-xl font-semibold mb-6">إحصائيات التقدم</h3>

        <div class="grid grid-cols-4 gap-6 mb-8">
            <div class="bg-blue-50 p-6 rounded-lg text-center">
                <div class="text-3xl font-bold text-blue-600 mb-2">
                    {{ round(($stats['overview']['total_study_hours'] ?? 0), 1) }}
                </div>
                <div class="text-sm text-gray-600">إجمالي ساعات الدراسة</div>
            </div>

            <div class="bg-green-50 p-6 rounded-lg text-center">
                <div class="text-3xl font-bold text-green-600 mb-2">
                    {{ $stats['overview']['current_streak'] ?? 0 }}
                </div>
                <div class="text-sm text-gray-600">الأيام المتتالية الحالية</div>
            </div>

            <div class="bg-purple-50 p-6 rounded-lg text-center">
                <div class="text-3xl font-bold text-purple-600 mb-2">
                    {{ $stats['overview']['level'] ?? 1 }}
                </div>
                <div class="text-sm text-gray-600">المستوى</div>
            </div>

            <div class="bg-yellow-50 p-6 rounded-lg text-center">
                <div class="text-3xl font-bold text-yellow-600 mb-2">
                    {{ $stats['overview']['points'] ?? 0 }}
                </div>
                <div class="text-sm text-gray-600">النقاط</div>
            </div>
        </div>

        <!-- Subjects Breakdown Chart -->
        <h4 class="font-semibold mb-4">توزيع الوقت حسب المواد</h4>
        <canvas id="subjectsChart" height="100"></canvas>
    </div>

    <!-- Activity Log Tab -->
    <div x-show="activeTab === 'activity'" class="bg-white rounded-lg shadow-sm p-6">
        <h3 class="text-xl font-semibold mb-6">سجل النشاطات</h3>

        <div class="space-y-4">
            @foreach($recentActivity as $activity)
            <div class="flex items-start border-r-4 {{ $activity->activity_type === 'login' ? 'border-green-500' : 'border-blue-500' }} pr-4 py-2">
                <div class="flex-shrink-0 mr-4">
                    <div class="w-10 h-10 rounded-full {{ $activity->activity_type === 'login' ? 'bg-green-100' : 'bg-blue-100' }} flex items-center justify-center">
                        <i class="fas fa-{{ $activity->activity_type === 'login' ? 'sign-in-alt' : 'circle' }} text-{{ $activity->activity_type === 'login' ? 'green' : 'blue' }}-600"></i>
                    </div>
                </div>
                <div class="flex-grow">
                    <p class="font-medium text-gray-900">{{ $activity->activity_type }}</p>
                    <p class="text-sm text-gray-600">{{ $activity->activity_description }}</p>
                    <p class="text-xs text-gray-400 mt-1">{{ $activity->created_at->diffForHumans() }}</p>
                </div>
            </div>
            @endforeach
        </div>
    </div>

    <!-- Actions Tab -->
    <div x-show="activeTab === 'actions'" class="bg-white rounded-lg shadow-sm p-6">
        <h3 class="text-xl font-semibold mb-6">إجراءات إدارية</h3>

        <div class="grid grid-cols-2 gap-6">
            <div class="border border-gray-200 rounded-lg p-6">
                <h4 class="font-semibold mb-2 text-gray-900">إعادة تعيين كلمة المرور</h4>
                <p class="text-sm text-gray-600 mb-4">سيتم إرسال كلمة مرور جديدة للمستخدم عبر البريد الإلكتروني</p>
                <button onclick="resetPassword({{ $user->id }})"
                        class="w-full px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
                    <i class="fas fa-key mr-2"></i>
                    إعادة تعيين كلمة المرور
                </button>
            </div>

            <div class="border border-gray-200 rounded-lg p-6">
                <h4 class="font-semibold mb-2 text-gray-900">إلغاء ربط الجهاز</h4>
                <p class="text-sm text-gray-600 mb-4">سيتمكن المستخدم من تسجيل الدخول من جهاز جديد</p>
                <button onclick="revokeDevice({{ $user->id }})"
                        class="w-full px-4 py-2 bg-yellow-600 text-white rounded-lg hover:bg-yellow-700">
                    <i class="fas fa-mobile-alt mr-2"></i>
                    إلغاء ربط الجهاز
                </button>
            </div>

            <div class="border border-gray-200 rounded-lg p-6">
                <h4 class="font-semibold mb-2 text-gray-900">تصدير بيانات المستخدم</h4>
                <p class="text-sm text-gray-600 mb-4">تنزيل جميع بيانات المستخدم (GDPR)</p>
                <button onclick="exportUserData({{ $user->id }})"
                        class="w-full px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700">
                    <i class="fas fa-download mr-2"></i>
                    تصدير البيانات
                </button>
            </div>

            <div class="border border-red-200 rounded-lg p-6 bg-red-50">
                <h4 class="font-semibold mb-2 text-red-900">حذف الحساب</h4>
                <p class="text-sm text-red-600 mb-4">سيتم حذف الحساب بشكل نهائي (لا يمكن التراجع)</p>
                <button onclick="deleteAccount({{ $user->id }})"
                        class="w-full px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700">
                    <i class="fas fa-trash mr-2"></i>
                    حذف الحساب
                </button>
            </div>
        </div>
    </div>
</div>

@push('scripts')
<script>
// Chart for subjects breakdown
const subjectsData = @json($stats['subjects_breakdown'] ?? []);
if (subjectsData.length > 0) {
    const ctx = document.getElementById('subjectsChart').getContext('2d');
    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: subjectsData.map(s => s.subject),
            datasets: [{
                label: 'دقائق الدراسة',
                data: subjectsData.map(s => s.minutes),
                backgroundColor: 'rgba(59, 130, 246, 0.5)',
                borderColor: 'rgba(59, 130, 246, 1)',
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });
}

async function resetPassword(userId) {
    if (!confirm('هل أنت متأكد من إعادة تعيين كلمة المرور؟')) return;

    const response = await fetch(`/admin/users/${userId}/reset-password`, {
        method: 'POST',
        headers: {
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
        }
    });

    const data = await response.json();
    if (data.success) {
        alert('تم إعادة تعيين كلمة المرور بنجاح');
    }
}

async function revokeDevice(userId) {
    if (!confirm('هل أنت متأكد من إلغاء ربط الجهاز؟')) return;

    const response = await fetch(`/admin/users/${userId}/revoke-device`, {
        method: 'POST',
        headers: {
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
        }
    });

    const data = await response.json();
    if (data.success) {
        alert('تم إلغاء ربط الجهاز بنجاح');
        location.reload();
    }
}

function exportUserData(userId) {
    window.location.href = `/api/v1/user/export`;
}

async function deleteAccount(userId) {
    if (!confirm('تحذير: سيتم حذف الحساب نهائياً! هل أنت متأكد؟')) return;

    const response = await fetch(`/admin/users/${userId}`, {
        method: 'DELETE',
        headers: {
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
        }
    });

    const data = await response.json();
    if (data.success) {
        alert('تم حذف الحساب بنجاح');
        window.location.href = '{{ route("admin.users.index") }}';
    }
}
</script>
@endpush
@endsection
