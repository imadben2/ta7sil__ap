@extends('layouts.admin')

@section('title', 'لوحة التحكم')
@section('page-title', 'الرئيسية')

@section('content')
<div class="space-y-6" style="font-family: 'Cairo', sans-serif; direction: rtl;">
    <!-- Welcome Header with Search -->
    <div class="bg-gradient-to-r from-blue-600 to-indigo-600 rounded-xl shadow-lg p-6">
        <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
            <div class="text-white">
                <h1 class="text-3xl font-bold mb-2">
                    <i class="fas fa-home ml-2"></i>
                    مرحباً، {{ auth()->user()->name }}
                </h1>
                <p class="text-blue-100">نظرة عامة على النظام والإحصائيات الرئيسية</p>
            </div>
            <div class="flex gap-3 items-center">
                <button onclick="refreshDashboard()" class="bg-white text-blue-600 hover:bg-blue-50 px-4 py-2 rounded-lg flex items-center gap-2 shadow-md font-semibold">
                    <i class="fas fa-sync-alt"></i>
                    <span>تحديث</span>
                </button>
                <div class="text-white text-sm">
                    <i class="fas fa-calendar ml-1"></i>
                    <span>{{ now()->isoFormat('dddd، D MMMM YYYY') }}</span>
                </div>
            </div>
        </div>
    </div>

    <!-- Overview Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <!-- Total Users -->
        <div class="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between mb-4">
                <div>
                    <p class="text-blue-100 text-sm font-medium mb-1">إجمالي المستخدمين</p>
                    <p class="text-4xl font-bold">{{ number_format($stats['overview']['total_users']) }}</p>
                    <p class="text-blue-100 text-xs mt-2 flex items-center gap-1">
                        <i class="fas fa-arrow-up"></i>
                        {{ $stats['overview']['user_growth'] }}% من الشهر الماضي
                    </p>
                </div>
                <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center">
                    <i class="fas fa-users text-3xl"></i>
                </div>
            </div>
        </div>

        <!-- Active Users -->
        <div class="bg-gradient-to-br from-green-500 to-green-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between mb-4">
                <div>
                    <p class="text-green-100 text-sm font-medium mb-1">مستخدمون نشطون</p>
                    <p class="text-4xl font-bold">{{ number_format($stats['overview']['active_users']) }}</p>
                    <p class="text-green-100 text-xs mt-2">
                        {{ round(($stats['overview']['active_users'] / max($stats['overview']['total_users'], 1)) * 100, 1) }}% من الإجمالي
                    </p>
                </div>
                <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center">
                    <i class="fas fa-user-check text-3xl"></i>
                </div>
            </div>
        </div>

        <!-- Total Content -->
        <div class="bg-gradient-to-br from-orange-500 to-orange-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between mb-4">
                <div>
                    <p class="text-orange-100 text-sm font-medium mb-1">إجمالي المحتوى</p>
                    <p class="text-4xl font-bold">{{ number_format($stats['overview']['total_content']) }}</p>
                    <p class="text-orange-100 text-xs mt-2 flex items-center gap-1">
                        <i class="fas fa-arrow-up"></i>
                        {{ $stats['overview']['content_growth'] }}% من الشهر الماضي
                    </p>
                </div>
                <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center">
                    <i class="fas fa-book text-3xl"></i>
                </div>
            </div>
        </div>

        <!-- Total Study Hours -->
        <div class="bg-gradient-to-br from-purple-500 to-purple-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between mb-4">
                <div>
                    <p class="text-purple-100 text-sm font-medium mb-1">ساعات الدراسة</p>
                    <p class="text-4xl font-bold">{{ number_format($stats['engagement']['total_study_hours'], 1) }}</p>
                    <p class="text-purple-100 text-xs mt-2">
                        {{ number_format($stats['engagement']['completed_sessions']) }} جلسة مكتملة
                    </p>
                </div>
                <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center">
                    <i class="fas fa-clock text-3xl"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Pending Actions Alert -->
    @if($stats['pending']['device_transfer_requests'] > 0 || $stats['pending']['pending_subscriptions'] > 0)
    <div class="bg-yellow-50 border-r-4 border-yellow-500 p-4 rounded-lg shadow">
        <div class="flex items-start">
            <i class="fas fa-exclamation-triangle text-yellow-600 text-xl ml-3 mt-1"></i>
            <div>
                <h3 class="text-yellow-800 font-bold mb-1">إجراءات تحتاج إلى اهتمام</h3>
                <div class="text-yellow-700 text-sm space-y-1">
                    @if($stats['pending']['device_transfer_requests'] > 0)
                    <p><i class="fas fa-mobile-alt ml-1"></i> {{ $stats['pending']['device_transfer_requests'] }} طلب نقل جهاز معلق</p>
                    @endif
                    @if($stats['pending']['pending_subscriptions'] > 0)
                    <p><i class="fas fa-credit-card ml-1"></i> {{ $stats['pending']['pending_subscriptions'] }} اشتراك معلق</p>
                    @endif
                </div>
            </div>
        </div>
    </div>
    @endif

    <!-- Charts Row -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- User Growth Chart -->
        <div class="bg-white rounded-xl shadow-md p-6">
            <h3 class="text-xl font-bold text-gray-900 mb-6 flex items-center gap-2">
                <div class="w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg flex items-center justify-center text-white">
                    <i class="fas fa-users"></i>
                </div>
                <span>نمو المستخدمين (آخر 30 يوم)</span>
            </h3>
            <div style="height: 300px;">
                <canvas id="userGrowthChart"></canvas>
            </div>
        </div>

        <!-- Study Sessions Chart -->
        <div class="bg-white rounded-xl shadow-md p-6">
            <h3 class="text-xl font-bold text-gray-900 mb-6 flex items-center gap-2">
                <div class="w-10 h-10 bg-gradient-to-br from-green-500 to-green-600 rounded-lg flex items-center justify-center text-white">
                    <i class="fas fa-chart-line"></i>
                </div>
                <span>جلسات الدراسة (آخر 30 يوم)</span>
            </h3>
            <div style="height: 300px;">
                <canvas id="studySessionsChart"></canvas>
            </div>
        </div>
    </div>

    <!-- Content Distribution and Top Subjects -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Content Distribution Doughnut -->
        <div class="bg-white rounded-xl shadow-md p-6">
            <h3 class="text-xl font-bold text-gray-900 mb-6 flex items-center gap-2">
                <div class="w-10 h-10 bg-gradient-to-br from-orange-500 to-red-500 rounded-lg flex items-center justify-center text-white">
                    <i class="fas fa-chart-pie"></i>
                </div>
                <span>توزيع المحتوى</span>
            </h3>
            <div style="height: 300px;" class="flex items-center justify-center">
                <canvas id="contentDistributionChart"></canvas>
            </div>
        </div>

        <!-- Top Subjects Bar Chart -->
        <div class="bg-white rounded-xl shadow-md p-6">
            <h3 class="text-xl font-bold text-gray-900 mb-6 flex items-center gap-2">
                <div class="w-10 h-10 bg-gradient-to-br from-purple-500 to-pink-500 rounded-lg flex items-center justify-center text-white">
                    <i class="fas fa-book"></i>
                </div>
                <span>أكثر المواد دراسة</span>
            </h3>
            <div style="height: 300px;">
                <canvas id="topSubjectsChart"></canvas>
            </div>
        </div>
    </div>

    <!-- User Stats Details -->
    <div class="bg-white rounded-xl shadow-md p-6">
        <h3 class="text-xl font-bold text-gray-900 mb-6 flex items-center gap-2">
            <div class="w-10 h-10 bg-gradient-to-br from-indigo-500 to-purple-500 rounded-lg flex items-center justify-center text-white">
                <i class="fas fa-users"></i>
            </div>
            <span>تفاصيل المستخدمين</span>
        </h3>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div class="bg-blue-50 rounded-lg p-4 text-center">
                <p class="text-3xl font-bold text-blue-600">{{ number_format($stats['users']['new_today']) }}</p>
                <p class="text-sm text-gray-700 mt-1">مستخدمون جدد اليوم</p>
            </div>
            <div class="bg-green-50 rounded-lg p-4 text-center">
                <p class="text-3xl font-bold text-green-600">{{ number_format($stats['users']['new_this_week']) }}</p>
                <p class="text-sm text-gray-700 mt-1">مستخدمون جدد هذا الأسبوع</p>
            </div>
            <div class="bg-purple-50 rounded-lg p-4 text-center">
                <p class="text-3xl font-bold text-purple-600">{{ number_format($stats['users']['active_today']) }}</p>
                <p class="text-sm text-gray-700 mt-1">نشطون اليوم</p>
            </div>
            <div class="bg-orange-50 rounded-lg p-4 text-center">
                <p class="text-3xl font-bold text-orange-600">{{ number_format($stats['users']['inactive']) }}</p>
                <p class="text-sm text-gray-700 mt-1">غير نشطين</p>
            </div>
        </div>
    </div>

    <!-- Academic Hierarchy Structure -->
    <div class="bg-white rounded-xl shadow-md p-6">
        <div class="flex items-center justify-between mb-6">
            <h2 class="text-2xl font-bold text-gray-800">
                <i class="fas fa-sitemap text-blue-600 ml-2"></i>
                الهيكل الأكاديمي
            </h2>
            <div class="text-sm text-gray-600">
                <i class="fas fa-info-circle ml-1"></i>
                النظام الهرمي للمحتوى التعليمي
            </div>
        </div>

        <!-- Hierarchy Visualization -->
        <div class="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-lg p-6 mb-6">
            <div class="flex items-start gap-3 text-lg font-semibold text-gray-700 flex-wrap">
                <div class="flex items-center gap-2">
                    <i class="fas fa-layer-group text-blue-600"></i>
                    <span>الطور</span>
                </div>
                <i class="fas fa-arrow-left text-gray-400"></i>
                <div class="flex items-center gap-2">
                    <i class="fas fa-calendar-alt text-green-600"></i>
                    <span>السنة</span>
                </div>
                <i class="fas fa-arrow-left text-gray-400"></i>
                <div class="flex items-center gap-2">
                    <i class="fas fa-stream text-purple-600"></i>
                    <span>الشعبة</span>
                </div>
                <i class="fas fa-arrow-left text-gray-400"></i>
                <div class="flex items-center gap-2">
                    <i class="fas fa-book text-orange-600"></i>
                    <span>المادة</span>
                </div>
                <i class="fas fa-arrow-left text-gray-400"></i>
                <div class="flex items-center gap-2">
                    <i class="fas fa-file-alt text-red-600"></i>
                    <span>المحتوى</span>
                </div>
            </div>
        </div>

        <!-- Hierarchy Stats -->
        <div class="grid grid-cols-2 md:grid-cols-5 gap-4">
            <div class="bg-blue-50 rounded-lg p-4 text-center border-2 border-blue-200">
                <div class="text-2xl font-bold text-blue-600">{{ $stats['content']['phases'] }}</div>
                <div class="text-sm text-gray-700 mt-1">أطوار</div>
            </div>
            <div class="bg-green-50 rounded-lg p-4 text-center border-2 border-green-200">
                <div class="text-2xl font-bold text-green-600">{{ $stats['content']['years'] }}</div>
                <div class="text-sm text-gray-700 mt-1">سنوات</div>
            </div>
            <div class="bg-purple-50 rounded-lg p-4 text-center border-2 border-purple-200">
                <div class="text-2xl font-bold text-purple-600">{{ $stats['content']['streams'] }}</div>
                <div class="text-sm text-gray-700 mt-1">شعب</div>
            </div>
            <div class="bg-orange-50 rounded-lg p-4 text-center border-2 border-orange-200">
                <div class="text-2xl font-bold text-orange-600">{{ $stats['content']['subjects'] }}</div>
                <div class="text-sm text-gray-700 mt-1">مواد</div>
            </div>
            <div class="bg-red-50 rounded-lg p-4 text-center border-2 border-red-200">
                <div class="text-2xl font-bold text-red-600">{{ $stats['content']['total'] }}</div>
                <div class="text-sm text-gray-700 mt-1">محتويات</div>
            </div>
        </div>
    </div>

    <!-- Content Types Breakdown -->
    <div class="bg-white rounded-xl shadow-md p-6">
        <h3 class="text-xl font-bold text-gray-800 mb-4">
            <i class="fas fa-th-large text-gray-600 ml-2"></i>
            أنواع المحتوى
        </h3>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div class="bg-gradient-to-br from-cyan-50 to-cyan-100 rounded-lg p-4 border border-cyan-200">
                <div class="flex items-center gap-3">
                    <div class="bg-cyan-500 p-3 rounded-lg">
                        <i class="fas fa-book-reader text-white text-xl"></i>
                    </div>
                    <div>
                        <div class="text-xl font-bold text-cyan-700">{{ number_format($stats['content']['lessons']) }}</div>
                        <div class="text-sm text-gray-700">الدروس</div>
                    </div>
                </div>
            </div>
            <div class="bg-gradient-to-br from-amber-50 to-amber-100 rounded-lg p-4 border border-amber-200">
                <div class="flex items-center gap-3">
                    <div class="bg-amber-500 p-3 rounded-lg">
                        <i class="fas fa-file-alt text-white text-xl"></i>
                    </div>
                    <div>
                        <div class="text-xl font-bold text-amber-700">{{ number_format($stats['content']['summaries']) }}</div>
                        <div class="text-sm text-gray-700">الملخصات</div>
                    </div>
                </div>
            </div>
            <div class="bg-gradient-to-br from-emerald-50 to-emerald-100 rounded-lg p-4 border border-emerald-200">
                <div class="flex items-center gap-3">
                    <div class="bg-emerald-500 p-3 rounded-lg">
                        <i class="fas fa-tasks text-white text-xl"></i>
                    </div>
                    <div>
                        <div class="text-xl font-bold text-emerald-700">{{ number_format($stats['content']['exercises']) }}</div>
                        <div class="text-sm text-gray-700">التمارين</div>
                    </div>
                </div>
            </div>
            <div class="bg-gradient-to-br from-rose-50 to-rose-100 rounded-lg p-4 border border-rose-200">
                <div class="flex items-center gap-3">
                    <div class="bg-rose-500 p-3 rounded-lg">
                        <i class="fas fa-clipboard-check text-white text-xl"></i>
                    </div>
                    <div>
                        <div class="text-xl font-bold text-rose-700">{{ number_format($stats['content']['tests']) }}</div>
                        <div class="text-sm text-gray-700">الاختبارات</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Quick Actions -->
    <div class="bg-white rounded-xl shadow-md p-6">
        <h2 class="text-xl font-bold text-gray-800 mb-4">
            <i class="fas fa-bolt text-yellow-500 ml-2"></i>
            إجراءات سريعة
        </h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <a href="{{ route('admin.users.create') }}" class="bg-blue-50 hover:bg-blue-100 border-2 border-blue-200 rounded-lg p-4 flex items-center gap-3">
                <div class="bg-blue-600 p-3 rounded-lg">
                    <i class="fas fa-user-plus text-white text-xl"></i>
                </div>
                <div>
                    <h3 class="font-semibold text-gray-800">إضافة مستخدم</h3>
                    <p class="text-sm text-gray-600">إنشاء حساب جديد</p>
                </div>
            </a>

            <a href="{{ route('admin.subjects.create') }}" class="bg-orange-50 hover:bg-orange-100 border-2 border-orange-200 rounded-lg p-4 flex items-center gap-3">
                <div class="bg-orange-600 p-3 rounded-lg">
                    <i class="fas fa-book text-white text-xl"></i>
                </div>
                <div>
                    <h3 class="font-semibold text-gray-800">إضافة مادة</h3>
                    <p class="text-sm text-gray-600">إنشاء مادة دراسية</p>
                </div>
            </a>

            <a href="{{ route('admin.contents.create') }}" class="bg-red-50 hover:bg-red-100 border-2 border-red-200 rounded-lg p-4 flex items-center gap-3">
                <div class="bg-red-600 p-3 rounded-lg">
                    <i class="fas fa-file-alt text-white text-xl"></i>
                </div>
                <div>
                    <h3 class="font-semibold text-gray-800">إضافة محتوى</h3>
                    <p class="text-sm text-gray-600">درس، ملخص، تمرين</p>
                </div>
            </a>

            <a href="{{ route('admin.quizzes.create') }}" class="bg-green-50 hover:bg-green-100 border-2 border-green-200 rounded-lg p-4 flex items-center gap-3">
                <div class="bg-green-600 p-3 rounded-lg">
                    <i class="fas fa-question-circle text-white text-xl"></i>
                </div>
                <div>
                    <h3 class="font-semibold text-gray-800">إضافة اختبار</h3>
                    <p class="text-sm text-gray-600">إنشاء اختبار جديد</p>
                </div>
            </a>

            <a href="{{ route('admin.courses.create') }}" class="bg-purple-50 hover:bg-purple-100 border-2 border-purple-200 rounded-lg p-4 flex items-center gap-3">
                <div class="bg-purple-600 p-3 rounded-lg">
                    <i class="fas fa-graduation-cap text-white text-xl"></i>
                </div>
                <div>
                    <h3 class="font-semibold text-gray-800">إضافة دورة</h3>
                    <p class="text-sm text-gray-600">إنشاء دورة تدريبية</p>
                </div>
            </a>

            <a href="{{ route('admin.analytics.index') }}" class="bg-indigo-50 hover:bg-indigo-100 border-2 border-indigo-200 rounded-lg p-4 flex items-center gap-3">
                <div class="bg-indigo-600 p-3 rounded-lg">
                    <i class="fas fa-chart-line text-white text-xl"></i>
                </div>
                <div>
                    <h3 class="font-semibold text-gray-800">التحليلات</h3>
                    <p class="text-sm text-gray-600">عرض الإحصائيات</p>
                </div>
            </a>

            <a href="{{ route('admin.subjects.index') }}" class="bg-orange-50 hover:bg-orange-100 border-2 border-orange-200 rounded-lg p-4">
                <div class="flex items-center gap-3 mb-2">
                    <div class="bg-orange-600 p-2 rounded-lg">
                        <i class="fas fa-book text-white text-lg"></i>
                    </div>
                    <h3 class="font-semibold text-gray-800">إدارة المواد</h3>
                </div>
                <p class="text-sm text-gray-600 mb-3">رياضيات، فيزياء، عربية...</p>
                <span class="text-orange-600 text-sm font-semibold">
                    <i class="fas fa-arrow-left mr-1"></i>
                    انتقال
                </span>
            </a>

            <a href="{{ route('admin.contents.index') }}" class="bg-red-50 hover:bg-red-100 border-2 border-red-200 rounded-lg p-4">
                <div class="flex items-center gap-3 mb-2">
                    <div class="bg-red-600 p-2 rounded-lg">
                        <i class="fas fa-file-alt text-white text-lg"></i>
                    </div>
                    <h3 class="font-semibold text-gray-800">إدارة المحتوى</h3>
                </div>
                <p class="text-sm text-gray-600 mb-3">دروس، ملخصات، تمارين، اختبارات</p>
                <span class="text-red-600 text-sm font-semibold">
                    <i class="fas fa-arrow-left mr-1"></i>
                    انتقال
                </span>
            </a>
        </div>
    </div>
</div>

@push('styles')
<link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700&display=swap" rel="stylesheet">
@endpush

@push('scripts')
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script>
function refreshDashboard() {
    window.location.reload();
}

// User Growth Chart
fetch('{{ route('admin.dashboard.user-growth') }}')
    .then(response => response.json())
    .then(result => {
        const ctx = document.getElementById('userGrowthChart').getContext('2d');
        new Chart(ctx, {
            type: 'line',
            data: {
                labels: result.data.map(d => d.date),
                datasets: [{
                    label: 'مستخدمون جدد',
                    data: result.data.map(d => d.count),
                    borderColor: 'rgb(59, 130, 246)',
                    backgroundColor: 'rgba(59, 130, 246, 0.1)',
                    tension: 0.4,
                    fill: true,
                    borderWidth: 3
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        labels: {
                            font: { family: 'Cairo', size: 12, weight: 'bold' },
                            padding: 15
                        }
                    }
                },
                scales: {
                    y: { beginAtZero: true, ticks: { font: { family: 'Cairo' } } },
                    x: { ticks: { font: { family: 'Cairo' }, maxRotation: 45, minRotation: 45 } }
                }
            }
        });
    });

// Study Sessions Chart
fetch('{{ route('admin.dashboard.study-sessions') }}')
    .then(response => response.json())
    .then(result => {
        const ctx = document.getElementById('studySessionsChart').getContext('2d');
        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: result.data.map(d => d.date),
                datasets: [
                    {
                        label: 'جلسات مكتملة',
                        data: result.data.map(d => d.completed),
                        backgroundColor: 'rgba(34, 197, 94, 0.8)',
                        borderColor: 'rgb(34, 197, 94)',
                        borderWidth: 2,
                        borderRadius: 6
                    },
                    {
                        label: 'إجمالي الجلسات',
                        data: result.data.map(d => d.sessions),
                        backgroundColor: 'rgba(59, 130, 246, 0.8)',
                        borderColor: 'rgb(59, 130, 246)',
                        borderWidth: 2,
                        borderRadius: 6
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        labels: {
                            font: { family: 'Cairo', size: 12, weight: 'bold' },
                            padding: 15
                        }
                    }
                },
                scales: {
                    y: { beginAtZero: true, ticks: { font: { family: 'Cairo' } } },
                    x: { ticks: { font: { family: 'Cairo' }, maxRotation: 45, minRotation: 45 } }
                }
            }
        });
    });

// Content Distribution Chart
const contentDistribution = {
    'lesson': {{ $stats['content']['lessons'] }},
    'summary': {{ $stats['content']['summaries'] }},
    'exercise': {{ $stats['content']['exercises'] }},
    'test': {{ $stats['content']['tests'] }}
};

const contentLabels = {
    'lesson': 'الدروس',
    'summary': 'الملخصات',
    'exercise': 'التمارين',
    'test': 'الاختبارات'
};

const ctxContent = document.getElementById('contentDistributionChart').getContext('2d');
new Chart(ctxContent, {
    type: 'doughnut',
    data: {
        labels: Object.keys(contentDistribution).map(k => contentLabels[k]),
        datasets: [{
            data: Object.values(contentDistribution),
            backgroundColor: [
                'rgba(59, 130, 246, 0.8)',
                'rgba(234, 179, 8, 0.8)',
                'rgba(34, 197, 94, 0.8)',
                'rgba(239, 68, 68, 0.8)'
            ],
            borderColor: [
                'rgb(59, 130, 246)',
                'rgb(234, 179, 8)',
                'rgb(34, 197, 94)',
                'rgb(239, 68, 68)'
            ],
            borderWidth: 3
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
            legend: {
                position: 'right',
                labels: {
                    font: { family: 'Cairo', size: 12, weight: 'bold' },
                    padding: 15
                }
            }
        }
    }
});

// Top Subjects Chart
fetch('{{ route('admin.dashboard.top-subjects') }}')
    .then(response => response.json())
    .then(result => {
        const ctx = document.getElementById('topSubjectsChart').getContext('2d');
        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: result.data.map(d => d.name),
                datasets: [{
                    label: 'ساعات الدراسة',
                    data: result.data.map(d => d.hours),
                    backgroundColor: 'rgba(168, 85, 247, 0.8)',
                    borderColor: 'rgb(168, 85, 247)',
                    borderWidth: 2,
                    borderRadius: 6
                }]
            },
            options: {
                indexAxis: 'y',
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        labels: {
                            font: { family: 'Cairo', size: 12, weight: 'bold' },
                            padding: 15
                        }
                    }
                },
                scales: {
                    x: { beginAtZero: true, ticks: { font: { family: 'Cairo' } } },
                    y: { ticks: { font: { family: 'Cairo' } } }
                }
            }
        });
    });
</script>
@endpush
@endsection
