@extends('layouts.admin')

@section('title', 'إحصائيات المستخدمين')

@section('content')
<div class="p-6 bg-gray-50 min-h-screen">
    <!-- Header -->
    <div class="mb-8">
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-3xl font-bold text-gray-900 flex items-center">
                    <i class="fas fa-chart-bar text-blue-600 mr-3"></i>
                    إحصائيات المستخدمين
                </h1>
                <p class="text-gray-600 mt-2">نظرة شاملة على نشاط وإحصائيات جميع المستخدمين</p>
            </div>
            <div class="flex gap-3">
                <button onclick="window.print()" class="px-4 py-2 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors flex items-center gap-2">
                    <i class="fas fa-print"></i>
                    <span>طباعة</span>
                </button>
                <a href="{{ route('admin.users.export') }}" class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors flex items-center gap-2">
                    <i class="fas fa-file-excel"></i>
                    <span>تصدير Excel</span>
                </a>
            </div>
        </div>
    </div>

    <!-- Overview Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <!-- Total Users -->
        <div class="bg-gradient-to-l from-blue-500 to-blue-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between mb-4">
                <div class="bg-white/20 p-3 rounded-lg">
                    <i class="fas fa-users text-2xl"></i>
                </div>
                <span class="text-sm opacity-80">إجمالي المستخدمين</span>
            </div>
            <div class="text-4xl font-bold">{{ number_format($totalUsers) }}</div>
        </div>

        <!-- New This Month -->
        <div class="bg-gradient-to-l from-green-500 to-green-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between mb-4">
                <div class="bg-white/20 p-3 rounded-lg">
                    <i class="fas fa-user-plus text-2xl"></i>
                </div>
                <span class="text-sm opacity-80">جدد هذا الشهر</span>
            </div>
            <div class="text-4xl font-bold">{{ number_format($newThisMonth) }}</div>
            <p class="text-sm mt-2 opacity-80">
                @if($totalUsers > 0)
                    {{ round(($newThisMonth / $totalUsers) * 100, 1) }}% من الإجمالي
                @endif
            </p>
        </div>

        <!-- Active Users (Last 7 Days) -->
        <div class="bg-gradient-to-l from-orange-500 to-orange-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between mb-4">
                <div class="bg-white/20 p-3 rounded-lg">
                    <i class="fas fa-fire text-2xl"></i>
                </div>
                <span class="text-sm opacity-80">نشطين (آخر 7 أيام)</span>
            </div>
            <div class="text-4xl font-bold">{{ number_format($activeUsers) }}</div>
            <p class="text-sm mt-2 opacity-80">
                @if($totalUsers > 0)
                    {{ round(($activeUsers / $totalUsers) * 100, 1) }}% معدل النشاط
                @endif
            </p>
        </div>

        <!-- Inactive Users (>30 Days) -->
        <div class="bg-gradient-to-l from-red-500 to-red-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between mb-4">
                <div class="bg-white/20 p-3 rounded-lg">
                    <i class="fas fa-user-slash text-2xl"></i>
                </div>
                <span class="text-sm opacity-80">غير نشطين (+30 يوم)</span>
            </div>
            <div class="text-4xl font-bold">{{ number_format($inactiveUsers) }}</div>
            <p class="text-sm mt-2 opacity-80">
                @if($totalUsers > 0)
                    {{ round(($inactiveUsers / $totalUsers) * 100, 1) }}% من الإجمالي
                @endif
            </p>
        </div>
    </div>

    <!-- Charts Row -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        <!-- Users by Phase -->
        <div class="bg-white rounded-xl shadow-md p-6 hover:shadow-lg transition-shadow">
            <div class="flex items-center justify-between mb-6">
                <h2 class="text-xl font-bold text-gray-800 flex items-center">
                    <i class="fas fa-graduation-cap text-blue-600 mr-3"></i>
                    توزيع المستخدمين حسب المرحلة الدراسية
                </h2>
            </div>
            @if($usersByPhase->isEmpty())
                <div class="flex flex-col items-center justify-center py-12">
                    <i class="fas fa-chart-pie text-gray-300 text-5xl mb-4"></i>
                    <p class="text-gray-500">لا توجد بيانات لعرضها</p>
                </div>
            @else
                <div class="relative" style="height: 300px;">
                    <canvas id="phaseChart"></canvas>
                </div>
            @endif
        </div>

        <!-- Registration Trend (Last 30 Days) -->
        <div class="bg-white rounded-xl shadow-md p-6 hover:shadow-lg transition-shadow">
            <div class="flex items-center justify-between mb-6">
                <h2 class="text-xl font-bold text-gray-800 flex items-center">
                    <i class="fas fa-chart-line text-green-600 mr-3"></i>
                    اتجاه التسجيلات (آخر 30 يوماً)
                </h2>
            </div>
            @if($registrationTrend->isEmpty())
                <div class="flex flex-col items-center justify-center py-12">
                    <i class="fas fa-chart-line text-gray-300 text-5xl mb-4"></i>
                    <p class="text-gray-500">لا توجد بيانات لعرضها</p>
                </div>
            @else
                <div class="relative" style="height: 300px;">
                    <canvas id="registrationChart"></canvas>
                </div>
            @endif
        </div>
    </div>

    <!-- Top Users Table -->
    <div class="bg-white rounded-xl shadow-md mb-8 overflow-hidden">
        <div class="p-6 border-b border-gray-200 bg-gradient-to-r from-yellow-50 to-orange-50">
            <h2 class="text-xl font-bold text-gray-800 flex items-center">
                <i class="fas fa-trophy text-yellow-500 mr-3 text-2xl"></i>
                أفضل 10 مستخدمين (حسب ساعات الدراسة)
            </h2>
            <p class="text-sm text-gray-600 mt-1">المستخدمون الأكثر نشاطاً في المنصة</p>
        </div>

        @if($topUsers->isEmpty())
            <div class="p-12 text-center">
                <div class="mx-auto w-24 h-24 bg-gray-100 rounded-full flex items-center justify-center mb-4">
                    <i class="fas fa-users text-4xl text-gray-400"></i>
                </div>
                <h3 class="text-xl font-semibold text-gray-700 mb-2">لا توجد بيانات حالياً</h3>
                <p class="text-gray-500">سيظهر هنا أفضل المستخدمين بمجرد توفر البيانات</p>
            </div>
        @else
            <div class="overflow-x-auto">
                <table class="w-full">
                    <thead class="bg-gray-50 border-b border-gray-200">
                        <tr>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">الترتيب</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">المستخدم</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">البريد الإلكتروني</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">ساعات الدراسة</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">السلسلة</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">المستوى</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">النقاط</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">الإجراءات</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200 bg-white">
                        @foreach($topUsers as $index => $user)
                    <tr class="hover:bg-gray-50">
                        <td class="px-6 py-4">
                            @if($index == 0)
                                <span class="text-2xl">🥇</span>
                            @elseif($index == 1)
                                <span class="text-2xl">🥈</span>
                            @elseif($index == 2)
                                <span class="text-2xl">🥉</span>
                            @else
                                <span class="text-gray-600 font-semibold">#{{ $index + 1 }}</span>
                            @endif
                        </td>
                        <td class="px-6 py-4">
                            <div class="flex items-center">
                                @if($user->profile_image)
                                    <img src="{{ $user->profile_image }}" class="w-10 h-10 rounded-full mr-3" alt="{{ $user->name }}">
                                @else
                                    <div class="w-10 h-10 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center text-white font-bold mr-3">
                                        {{ mb_substr($user->name, 0, 1) }}
                                    </div>
                                @endif
                                <span class="font-semibold text-gray-800">{{ $user->name }}</span>
                            </div>
                        </td>
                        <td class="px-6 py-4 text-gray-600" dir="ltr">{{ $user->email }}</td>
                        <td class="px-6 py-4">
                            <span class="font-bold text-blue-600">
                                {{ round($user->total_study_minutes / 60, 1) }} ساعة
                            </span>
                        </td>
                        <td class="px-6 py-4">
                            <span class="bg-orange-100 text-orange-800 px-3 py-1 rounded-full text-sm font-semibold">
                                {{ $user->current_streak_days ?? 0 }} يوم
                            </span>
                        </td>
                        <td class="px-6 py-4">
                            <span class="bg-purple-100 text-purple-800 px-3 py-1 rounded-full text-sm font-semibold">
                                المستوى {{ $user->level ?? 1 }}
                            </span>
                        </td>
                        <td class="px-6 py-4">
                            <span class="font-semibold text-green-600">
                                {{ number_format($user->gamification_points ?? 0) }}
                            </span>
                        </td>
                        <td class="px-6 py-4">
                            <a href="{{ route('admin.users.show', $user->id) }}"
                               class="text-blue-600 hover:text-blue-800 font-semibold">
                                <i class="fas fa-eye mr-1"></i>
                                عرض
                            </a>
                        </td>
                    </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        @endif
    </div>

    <!-- Additional Statistics Grid -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
        <!-- Average Study Time -->
        <div class="bg-white rounded-xl shadow-md p-6 hover:shadow-lg transition-shadow">
            <div class="flex items-center justify-between mb-4">
                <h3 class="text-lg font-semibold text-gray-800">
                    متوسط ساعات الدراسة
                </h3>
                <div class="p-3 bg-blue-100 rounded-lg">
                    <i class="fas fa-clock text-2xl text-blue-600"></i>
                </div>
            </div>
            <div class="text-center">
                @php
                    $totalMinutes = $topUsers->sum('total_study_minutes');
                    $avgHours = $topUsers->count() > 0 ? round($totalMinutes / $topUsers->count() / 60, 1) : 0;
                @endphp
                <div class="text-5xl font-bold text-blue-600 mb-2">{{ $avgHours }}</div>
                <p class="text-gray-600 text-sm">ساعة لكل مستخدم نشط</p>
                <div class="mt-4 pt-4 border-t border-gray-100">
                    <p class="text-xs text-gray-500">إجمالي الساعات: {{ round($totalMinutes / 60) }} ساعة</p>
                </div>
            </div>
        </div>

        <!-- Average Streak -->
        <div class="bg-white rounded-xl shadow-md p-6 hover:shadow-lg transition-shadow">
            <div class="flex items-center justify-between mb-4">
                <h3 class="text-lg font-semibold text-gray-800">
                    متوسط السلسلة
                </h3>
                <div class="p-3 bg-orange-100 rounded-lg">
                    <i class="fas fa-fire text-2xl text-orange-600"></i>
                </div>
            </div>
            <div class="text-center">
                @php
                    $avgStreak = $topUsers->count() > 0 ? round($topUsers->avg('current_streak_days'), 1) : 0;
                    $maxStreak = $topUsers->max('current_streak_days') ?? 0;
                @endphp
                <div class="text-5xl font-bold text-orange-600 mb-2">{{ $avgStreak }}</div>
                <p class="text-gray-600 text-sm">يوم متتالي</p>
                <div class="mt-4 pt-4 border-t border-gray-100">
                    <p class="text-xs text-gray-500">أعلى سلسلة: {{ $maxStreak }} يوم</p>
                </div>
            </div>
        </div>

        <!-- Average Level -->
        <div class="bg-white rounded-xl shadow-md p-6 hover:shadow-lg transition-shadow">
            <div class="flex items-center justify-between mb-4">
                <h3 class="text-lg font-semibold text-gray-800">
                    متوسط المستوى
                </h3>
                <div class="p-3 bg-purple-100 rounded-lg">
                    <i class="fas fa-star text-2xl text-purple-600"></i>
                </div>
            </div>
            <div class="text-center">
                @php
                    $avgLevel = $topUsers->count() > 0 ? round($topUsers->avg('level'), 1) : 1;
                    $maxLevel = $topUsers->max('level') ?? 1;
                @endphp
                <div class="text-5xl font-bold text-purple-600 mb-2">{{ $avgLevel }}</div>
                <p class="text-gray-600 text-sm">من 10 مستويات</p>
                <div class="mt-4 pt-4 border-t border-gray-100">
                    <p class="text-xs text-gray-500">أعلى مستوى: المستوى {{ $maxLevel }}</p>
                </div>
            </div>
        </div>
    </div>
</div>

@if(!$usersByPhase->isEmpty() || !$registrationTrend->isEmpty())
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    @if(!$usersByPhase->isEmpty())
    // Users by Phase Chart
    const phaseData = @json($usersByPhase);
    const phaseLabels = phaseData.map(p => p.phase_name);
    const phaseCounts = phaseData.map(p => p.count);

    new Chart(document.getElementById('phaseChart'), {
        type: 'doughnut',
        data: {
            labels: phaseLabels,
            datasets: [{
                data: phaseCounts,
                backgroundColor: [
                    'rgba(59, 130, 246, 0.85)',  // Blue
                    'rgba(16, 185, 129, 0.85)',  // Green
                    'rgba(245, 158, 11, 0.85)',  // Orange
                    'rgba(139, 92, 246, 0.85)',  // Purple
                    'rgba(239, 68, 68, 0.85)',   // Red
                    'rgba(236, 72, 153, 0.85)',  // Pink
                ],
                borderWidth: 3,
                borderColor: '#fff',
                hoverBorderWidth: 4,
                hoverOffset: 10
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'bottom',
                    rtl: true,
                    labels: {
                        font: {
                            family: 'Cairo',
                            size: 13,
                            weight: '500'
                        },
                        padding: 15,
                        usePointStyle: true,
                        pointStyle: 'circle'
                    }
                },
                tooltip: {
                    rtl: true,
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    titleFont: {
                        family: 'Cairo',
                        size: 14,
                        weight: 'bold'
                    },
                    bodyFont: {
                        family: 'Cairo',
                        size: 13
                    },
                    padding: 12,
                    cornerRadius: 8,
                    displayColors: true
                }
            }
        }
    });
    @endif

    @if(!$registrationTrend->isEmpty())
    // Registration Trend Chart
    const registrationData = @json($registrationTrend);
    const registrationLabels = registrationData.map(r => {
        const date = new Date(r.date);
        return date.toLocaleDateString('ar-DZ', { month: 'short', day: 'numeric' });
    });
    const registrationCounts = registrationData.map(r => r.count);

    new Chart(document.getElementById('registrationChart'), {
        type: 'line',
        data: {
            labels: registrationLabels,
            datasets: [{
                label: 'تسجيلات جديدة',
                data: registrationCounts,
                borderColor: 'rgb(16, 185, 129)',
                backgroundColor: 'rgba(16, 185, 129, 0.15)',
                tension: 0.4,
                fill: true,
                pointRadius: 5,
                pointHoverRadius: 8,
                pointBackgroundColor: 'rgb(16, 185, 129)',
                pointBorderColor: '#fff',
                pointBorderWidth: 3,
                pointHoverBorderWidth: 4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    rtl: true,
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    titleFont: {
                        family: 'Cairo',
                        size: 14,
                        weight: 'bold'
                    },
                    bodyFont: {
                        family: 'Cairo',
                        size: 13
                    },
                    padding: 12,
                    cornerRadius: 8,
                    callbacks: {
                        label: function(context) {
                            return 'التسجيلات: ' + context.parsed.y;
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        precision: 0,
                        font: {
                            family: 'Cairo',
                            size: 12
                        },
                        color: '#6B7280'
                    },
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)',
                        borderDash: [5, 5]
                    }
                },
                x: {
                    ticks: {
                        font: {
                            family: 'Cairo',
                            size: 11
                        },
                        color: '#6B7280',
                        maxRotation: 45,
                        minRotation: 0
                    },
                    grid: {
                        display: false
                    }
                }
            }
        }
    });
    @endif
});
</script>
@endif
@endsection
