@extends('layouts.admin')

@section('title', 'التحليلات والإحصائيات')
@section('page-title', 'لوحة التحليلات')

@section('content')
<div class="space-y-6" style="font-family: 'Cairo', sans-serif; direction: rtl;">
    <!-- Enhanced Header with Gradient -->
    <div class="bg-gradient-to-r from-indigo-600 to-purple-600 rounded-xl shadow-lg p-6">
        <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
            <div class="text-white">
                <h2 class="text-2xl font-bold mb-2">لوحة التحليلات والإحصائيات</h2>
                <p class="text-indigo-100">تحليل شامل لأداء المنصة والمستخدمين</p>
            </div>
            <div class="flex gap-3">
                <select id="periodFilter" onchange="changePeriod(this.value)"
                        class="px-6 py-3 bg-white text-indigo-600 border-2 border-white rounded-lg focus:ring-2 focus:ring-indigo-300 font-semibold shadow-md">
                    <option value="7" {{ $period == 7 ? 'selected' : '' }}>آخر 7 أيام</option>
                    <option value="30" {{ $period == 30 ? 'selected' : '' }}>آخر 30 يوم</option>
                    <option value="90" {{ $period == 90 ? 'selected' : '' }}>آخر 90 يوم</option>
                </select>
                <button onclick="window.location.reload()"
                        class="bg-white text-indigo-600 hover:bg-indigo-50 px-6 py-3 rounded-lg flex items-center gap-2 shadow-md font-semibold transition-all">
                    <i class="fas fa-sync-alt"></i>
                    <span>تحديث</span>
                </button>
            </div>
        </div>
    </div>

    <!-- User Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div class="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-blue-100 text-sm font-medium mb-1">إجمالي المستخدمين</p>
                    <p class="text-4xl font-bold">{{ number_format($stats['users']['total']) }}</p>
                    <p class="text-blue-100 text-xs mt-2 flex items-center gap-1">
                        <i class="fas fa-arrow-up"></i>
                        {{ number_format($stats['users']['new_users']) }} مستخدم جديد
                    </p>
                </div>
                <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center">
                    <i class="fas fa-users text-3xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-gradient-to-br from-green-500 to-green-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-green-100 text-sm font-medium mb-1">مستخدمون نشطون يومياً</p>
                    <p class="text-4xl font-bold">{{ number_format($stats['users']['dau']) }}</p>
                    <p class="text-green-100 text-xs mt-2">
                        DAU/MAU: {{ $stats['users']['dau_mau_ratio'] }}%
                    </p>
                </div>
                <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center">
                    <i class="fas fa-chart-line text-3xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-gradient-to-br from-purple-500 to-pink-500 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-purple-100 text-sm font-medium mb-1">مستخدمون نشطون شهرياً</p>
                    <p class="text-4xl font-bold">{{ number_format($stats['users']['mau']) }}</p>
                    <p class="text-purple-100 text-xs mt-2">
                        {{ round(($stats['users']['mau'] / max($stats['users']['total'], 1)) * 100, 1) }}% من الإجمالي
                    </p>
                </div>
                <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center">
                    <i class="fas fa-user-check text-3xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-gradient-to-br from-orange-500 to-red-500 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-orange-100 text-sm font-medium mb-1">إجمالي ساعات الدراسة</p>
                    <p class="text-4xl font-bold">{{ number_format($stats['engagement']['total_hours'], 1) }}</p>
                    <p class="text-orange-100 text-xs mt-2">
                        {{ number_format($stats['engagement']['completed_sessions']) }} جلسة مكتملة
                    </p>
                </div>
                <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center">
                    <i class="fas fa-clock text-3xl"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Engagement & Performance Stats -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Engagement Card -->
        <div class="bg-white rounded-xl shadow-md p-6">
            <h3 class="text-xl font-bold text-gray-900 mb-6 flex items-center gap-2">
                <div class="w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg flex items-center justify-center text-white">
                    <i class="fas fa-chart-bar"></i>
                </div>
                <span>مقاييس التفاعل</span>
            </h3>
            <div class="space-y-4">
                <div class="flex justify-between items-center p-4 bg-blue-50 rounded-lg">
                    <span class="text-gray-700 font-semibold">إجمالي الجلسات</span>
                    <span class="text-2xl font-bold text-blue-600">{{ number_format($stats['engagement']['total_sessions']) }}</span>
                </div>
                <div class="flex justify-between items-center p-4 bg-green-50 rounded-lg">
                    <span class="text-gray-700 font-semibold">نسبة الإكمال</span>
                    <span class="text-2xl font-bold text-green-600">{{ $stats['engagement']['completion_rate'] }}%</span>
                </div>
                <div class="flex justify-between items-center p-4 bg-purple-50 rounded-lg">
                    <span class="text-gray-700 font-semibold">متوسط مدة الجلسة</span>
                    <span class="text-2xl font-bold text-purple-600">{{ $stats['engagement']['average_duration'] }} دقيقة</span>
                </div>
                <div class="flex justify-between items-center p-4 bg-indigo-50 rounded-lg">
                    <span class="text-gray-700 font-semibold">جلسات لكل مستخدم</span>
                    <span class="text-2xl font-bold text-indigo-600">{{ $stats['engagement']['sessions_per_user'] }}</span>
                </div>
            </div>
        </div>

        <!-- Performance Card -->
        <div class="bg-white rounded-xl shadow-md p-6">
            <h3 class="text-xl font-bold text-gray-900 mb-6 flex items-center gap-2">
                <div class="w-10 h-10 bg-gradient-to-br from-yellow-500 to-orange-500 rounded-lg flex items-center justify-center text-white">
                    <i class="fas fa-trophy"></i>
                </div>
                <span>الأداء العام</span>
            </h3>
            <div class="space-y-4">
                <div class="flex justify-between items-center p-4 bg-blue-50 rounded-lg">
                    <span class="text-gray-700 font-semibold">إجمالي الاختبارات</span>
                    <span class="text-2xl font-bold text-blue-600">{{ number_format($stats['performance']['total_quizzes']) }}</span>
                </div>
                <div class="flex justify-between items-center p-4 bg-green-50 rounded-lg">
                    <span class="text-gray-700 font-semibold">متوسط الدرجات</span>
                    <span class="text-2xl font-bold text-green-600">{{ $stats['performance']['average_score'] }}%</span>
                </div>
                <div class="mt-4">
                    <p class="text-gray-700 font-semibold mb-3 flex items-center gap-2">
                        <i class="fas fa-chart-pie text-purple-500"></i>
                        توزيع الدرجات
                    </p>
                    <div class="space-y-2">
                        @foreach($stats['performance']['score_distribution'] as $range => $count)
                        <div class="flex items-center gap-3">
                            <span class="text-sm font-semibold text-gray-600 w-20">{{ $range }}%</span>
                            <div class="flex-1 bg-gray-200 rounded-full h-4 overflow-hidden">
                                @php
                                    $percentage = $stats['performance']['total_quizzes'] > 0
                                        ? ($count / $stats['performance']['total_quizzes']) * 100
                                        : 0;
                                    $color = match($range) {
                                        '0-40' => 'bg-gradient-to-r from-red-500 to-red-600',
                                        '40-60' => 'bg-gradient-to-r from-yellow-500 to-yellow-600',
                                        '60-80' => 'bg-gradient-to-r from-blue-500 to-blue-600',
                                        '80-100' => 'bg-gradient-to-r from-green-500 to-green-600',
                                        default => 'bg-gray-500'
                                    };
                                @endphp
                                <div class="{{ $color }} h-4 rounded-full flex items-center justify-end pr-2" style="width: {{ $percentage }}%">
                                    @if($percentage > 10)
                                        <span class="text-xs text-white font-bold">{{ $count }}</span>
                                    @endif
                                </div>
                            </div>
                            @if($percentage <= 10)
                                <span class="text-sm font-bold text-gray-600 w-12">{{ $count }}</span>
                            @endif
                        </div>
                        @endforeach
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Retention & Subjects -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Retention Card -->
        <div class="bg-white rounded-xl shadow-md p-6">
            <h3 class="text-xl font-bold text-gray-900 mb-6 flex items-center gap-2">
                <div class="w-10 h-10 bg-gradient-to-br from-indigo-500 to-purple-500 rounded-lg flex items-center justify-center text-white">
                    <i class="fas fa-user-shield"></i>
                </div>
                <span>معدلات الاحتفاظ</span>
            </h3>
            <div class="space-y-6">
                <div>
                    <div class="flex justify-between items-center mb-3">
                        <span class="text-gray-700 font-semibold flex items-center gap-2">
                            <i class="fas fa-calendar-week text-blue-500"></i>
                            الاحتفاظ لمدة 7 أيام
                        </span>
                        <span class="text-2xl font-bold text-blue-600">{{ $stats['retention']['day_7'] }}%</span>
                    </div>
                    <div class="w-full bg-gray-200 rounded-full h-5 overflow-hidden">
                        <div class="bg-gradient-to-r from-blue-500 to-blue-600 h-5 rounded-full flex items-center justify-end pr-3"
                             style="width: {{ $stats['retention']['day_7'] }}%">
                            <span class="text-xs text-white font-bold">{{ $stats['retention']['day_7'] }}%</span>
                        </div>
                    </div>
                </div>
                <div>
                    <div class="flex justify-between items-center mb-3">
                        <span class="text-gray-700 font-semibold flex items-center gap-2">
                            <i class="fas fa-calendar-alt text-green-500"></i>
                            الاحتفاظ لمدة 30 يوم
                        </span>
                        <span class="text-2xl font-bold text-green-600">{{ $stats['retention']['day_30'] }}%</span>
                    </div>
                    <div class="w-full bg-gray-200 rounded-full h-5 overflow-hidden">
                        <div class="bg-gradient-to-r from-green-500 to-green-600 h-5 rounded-full flex items-center justify-end pr-3"
                             style="width: {{ $stats['retention']['day_30'] }}%">
                            <span class="text-xs text-white font-bold">{{ $stats['retention']['day_30'] }}%</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Top Subjects Card -->
        <div class="bg-white rounded-xl shadow-md p-6">
            <h3 class="text-xl font-bold text-gray-900 mb-6 flex items-center gap-2">
                <div class="w-10 h-10 bg-gradient-to-br from-green-500 to-teal-500 rounded-lg flex items-center justify-center text-white">
                    <i class="fas fa-book"></i>
                </div>
                <span>المواد الأكثر دراسة</span>
            </h3>
            <div class="space-y-3">
                @foreach(array_slice($stats['subjects'], 0, 5) as $index => $subject)
                <div class="flex items-center justify-between p-3 rounded-lg">
                    <div class="flex items-center gap-3">
                        @php
                            $colors = [
                                'bg-gradient-to-br from-yellow-500 to-orange-500',
                                'bg-gradient-to-br from-blue-500 to-indigo-500',
                                'bg-gradient-to-br from-green-500 to-teal-500',
                                'bg-gradient-to-br from-purple-500 to-pink-500',
                                'bg-gradient-to-br from-red-500 to-pink-500',
                            ];
                        @endphp
                        <span class="flex items-center justify-center w-10 h-10 rounded-lg {{ $colors[$index] }} text-white font-bold shadow-md">
                            {{ $index + 1 }}
                        </span>
                        <span class="text-gray-700 font-semibold">{{ $subject['name'] }}</span>
                    </div>
                    <div class="text-left">
                        <p class="text-lg font-bold text-gray-900">{{ $subject['hours'] }} ساعة</p>
                        <p class="text-sm text-gray-500">{{ $subject['sessions'] }} جلسة</p>
                    </div>
                </div>
                @endforeach
            </div>
        </div>
    </div>

    <!-- Charts -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Engagement Trends Chart -->
        <div class="bg-white rounded-xl shadow-md p-6">
            <h3 class="text-xl font-bold text-gray-900 mb-6 flex items-center gap-2">
                <div class="w-10 h-10 bg-gradient-to-br from-cyan-500 to-blue-500 rounded-lg flex items-center justify-center text-white">
                    <i class="fas fa-chart-area"></i>
                </div>
                <span>تطور التفاعل</span>
            </h3>
            <div style="height: 300px;">
                <canvas id="engagementChart"></canvas>
            </div>
        </div>

        <!-- Performance Trends Chart -->
        <div class="bg-white rounded-xl shadow-md p-6">
            <h3 class="text-xl font-bold text-gray-900 mb-6 flex items-center gap-2">
                <div class="w-10 h-10 bg-gradient-to-br from-green-500 to-emerald-500 rounded-lg flex items-center justify-center text-white">
                    <i class="fas fa-chart-line"></i>
                </div>
                <span>تطور الأداء</span>
            </h3>
            <div style="height: 300px;">
                <canvas id="performanceChart"></canvas>
            </div>
        </div>
    </div>

    <!-- Additional Charts Row -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- User Growth Chart -->
        <div class="bg-white rounded-xl shadow-md p-6">
            <h3 class="text-xl font-bold text-gray-900 mb-6 flex items-center gap-2">
                <div class="w-10 h-10 bg-gradient-to-br from-purple-500 to-pink-500 rounded-lg flex items-center justify-center text-white">
                    <i class="fas fa-users"></i>
                </div>
                <span>نمو المستخدمين</span>
            </h3>
            <div style="height: 300px;">
                <canvas id="userGrowthChart"></canvas>
            </div>
        </div>

        <!-- Subject Distribution Chart -->
        <div class="bg-white rounded-xl shadow-md p-6">
            <h3 class="text-xl font-bold text-gray-900 mb-6 flex items-center gap-2">
                <div class="w-10 h-10 bg-gradient-to-br from-orange-500 to-red-500 rounded-lg flex items-center justify-center text-white">
                    <i class="fas fa-chart-pie"></i>
                </div>
                <span>توزيع المواد الدراسية</span>
            </h3>
            <div style="height: 300px;" class="flex items-center justify-center">
                <canvas id="subjectDistributionChart"></canvas>
            </div>
        </div>
    </div>
</div>

@push('styles')
<link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700&display=swap" rel="stylesheet">
@endpush

@push('scripts')
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script>
function changePeriod(period) {
    window.location.href = '{{ route('admin.analytics.index') }}?period=' + period;
}

// Fake data for testing charts
const fakeDates = [
    @for($i = 29; $i >= 0; $i--)
        '{{ now()->subDays($i)->format('Y-m-d') }}'{{ $i > 0 ? ',' : '' }}
    @endfor
];

// Engagement Trends Chart
const ctxEngagement = document.getElementById('engagementChart').getContext('2d');
new Chart(ctxEngagement, {
    type: 'line',
    data: {
        labels: fakeDates,
        datasets: [
            {
                label: 'إجمالي الجلسات',
                data: [45, 52, 48, 65, 71, 68, 75, 82, 78, 85, 92, 88, 95, 102, 98, 105, 112, 108, 115, 122, 118, 125, 132, 128, 135, 142, 138, 145, 152, 148],
                borderColor: 'rgb(59, 130, 246)',
                backgroundColor: 'rgba(59, 130, 246, 0.1)',
                tension: 0.4,
                fill: true,
                borderWidth: 3
            },
            {
                label: 'جلسات مكتملة',
                data: [38, 44, 41, 55, 60, 57, 63, 69, 66, 72, 78, 74, 80, 86, 83, 89, 95, 91, 97, 103, 99, 105, 111, 107, 113, 119, 115, 121, 127, 123],
                borderColor: 'rgb(34, 197, 94)',
                backgroundColor: 'rgba(34, 197, 94, 0.1)',
                tension: 0.4,
                fill: true,
                borderWidth: 3
            }
        ]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
            legend: {
                position: 'top',
                labels: {
                    font: {
                        family: 'Cairo',
                        size: 12,
                        weight: 'bold'
                    },
                    padding: 15,
                    usePointStyle: true
                }
            },
            tooltip: {
                backgroundColor: 'rgba(0, 0, 0, 0.8)',
                titleFont: {
                    family: 'Cairo',
                    size: 14
                },
                bodyFont: {
                    family: 'Cairo',
                    size: 13
                },
                padding: 12,
                cornerRadius: 8
            }
        },
        scales: {
            y: {
                beginAtZero: true,
                grid: {
                    color: 'rgba(0, 0, 0, 0.05)'
                },
                ticks: {
                    font: {
                        family: 'Cairo'
                    }
                }
            },
            x: {
                grid: {
                    display: false
                },
                ticks: {
                    font: {
                        family: 'Cairo'
                    },
                    maxRotation: 45,
                    minRotation: 45
                }
            }
        }
    }
});

// Performance Trends Chart
const ctxPerformance = document.getElementById('performanceChart').getContext('2d');
new Chart(ctxPerformance, {
    type: 'line',
    data: {
        labels: fakeDates,
        datasets: [{
            label: 'متوسط الدرجات',
            data: [72, 74, 73, 75, 76, 75, 77, 78, 77, 79, 80, 79, 81, 82, 81, 83, 84, 83, 85, 86, 85, 87, 88, 87, 89, 90, 89, 91, 92, 91],
            borderColor: 'rgb(34, 197, 94)',
            backgroundColor: 'rgba(34, 197, 94, 0.1)',
            tension: 0.4,
            fill: true,
            borderWidth: 3,
            pointRadius: 4,
            pointBackgroundColor: 'rgb(34, 197, 94)',
            pointBorderColor: '#fff',
            pointBorderWidth: 2
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
            legend: {
                position: 'top',
                labels: {
                    font: {
                        family: 'Cairo',
                        size: 12,
                        weight: 'bold'
                    },
                    padding: 15,
                    usePointStyle: true
                }
            },
            tooltip: {
                backgroundColor: 'rgba(0, 0, 0, 0.8)',
                titleFont: {
                    family: 'Cairo',
                    size: 14
                },
                bodyFont: {
                    family: 'Cairo',
                    size: 13
                },
                padding: 12,
                cornerRadius: 8,
                callbacks: {
                    label: function(context) {
                        return ' الدرجة: ' + context.parsed.y + '%';
                    }
                }
            }
        },
        scales: {
            y: {
                beginAtZero: true,
                max: 100,
                grid: {
                    color: 'rgba(0, 0, 0, 0.05)'
                },
                ticks: {
                    font: {
                        family: 'Cairo'
                    },
                    callback: function(value) {
                        return value + '%';
                    }
                }
            },
            x: {
                grid: {
                    display: false
                },
                ticks: {
                    font: {
                        family: 'Cairo'
                    },
                    maxRotation: 45,
                    minRotation: 45
                }
            }
        }
    }
});

// User Growth Chart
const ctxUserGrowth = document.getElementById('userGrowthChart').getContext('2d');
new Chart(ctxUserGrowth, {
    type: 'bar',
    data: {
        labels: fakeDates,
        datasets: [
            {
                label: 'مستخدمون جدد',
                data: [12, 15, 11, 18, 22, 19, 25, 28, 24, 31, 35, 32, 38, 42, 39, 45, 49, 46, 52, 56, 53, 59, 63, 60, 66, 70, 67, 73, 77, 74],
                backgroundColor: 'rgba(139, 92, 246, 0.8)',
                borderColor: 'rgb(139, 92, 246)',
                borderWidth: 2,
                borderRadius: 6
            },
            {
                label: 'مستخدمون نشطون',
                data: [245, 252, 248, 265, 271, 268, 275, 282, 278, 285, 292, 288, 295, 302, 298, 305, 312, 308, 315, 322, 318, 325, 332, 328, 335, 342, 338, 345, 352, 348],
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
                position: 'top',
                labels: {
                    font: {
                        family: 'Cairo',
                        size: 12,
                        weight: 'bold'
                    },
                    padding: 15,
                    usePointStyle: true
                }
            },
            tooltip: {
                backgroundColor: 'rgba(0, 0, 0, 0.8)',
                titleFont: {
                    family: 'Cairo',
                    size: 14
                },
                bodyFont: {
                    family: 'Cairo',
                    size: 13
                },
                padding: 12,
                cornerRadius: 8
            }
        },
        scales: {
            y: {
                beginAtZero: true,
                grid: {
                    color: 'rgba(0, 0, 0, 0.05)'
                },
                ticks: {
                    font: {
                        family: 'Cairo'
                    }
                }
            },
            x: {
                grid: {
                    display: false
                },
                ticks: {
                    font: {
                        family: 'Cairo'
                    },
                    maxRotation: 45,
                    minRotation: 45
                }
            }
        }
    }
});

// Subject Distribution Chart (Doughnut)
const ctxSubjectDistribution = document.getElementById('subjectDistributionChart').getContext('2d');
new Chart(ctxSubjectDistribution, {
    type: 'doughnut',
    data: {
        labels: [
            @foreach(array_slice($stats['subjects'], 0, 6) as $subject)
                '{{ $subject['name'] }}'{{ !$loop->last ? ',' : '' }}
            @endforeach
        ],
        datasets: [{
            data: [
                @foreach(array_slice($stats['subjects'], 0, 6) as $subject)
                    {{ $subject['hours'] }}{{ !$loop->last ? ',' : '' }}
                @endforeach
            ],
            backgroundColor: [
                'rgba(234, 179, 8, 0.8)',
                'rgba(59, 130, 246, 0.8)',
                'rgba(34, 197, 94, 0.8)',
                'rgba(168, 85, 247, 0.8)',
                'rgba(239, 68, 68, 0.8)',
                'rgba(236, 72, 153, 0.8)'
            ],
            borderColor: [
                'rgb(234, 179, 8)',
                'rgb(59, 130, 246)',
                'rgb(34, 197, 94)',
                'rgb(168, 85, 247)',
                'rgb(239, 68, 68)',
                'rgb(236, 72, 153)'
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
                    font: {
                        family: 'Cairo',
                        size: 12,
                        weight: 'bold'
                    },
                    padding: 15,
                    usePointStyle: true,
                    generateLabels: function(chart) {
                        const data = chart.data;
                        if (data.labels.length && data.datasets.length) {
                            return data.labels.map((label, i) => {
                                const value = data.datasets[0].data[i];
                                return {
                                    text: label + ' (' + value + ' ساعة)',
                                    fillStyle: data.datasets[0].backgroundColor[i],
                                    strokeStyle: data.datasets[0].borderColor[i],
                                    lineWidth: 2,
                                    hidden: false,
                                    index: i
                                };
                            });
                        }
                        return [];
                    }
                }
            },
            tooltip: {
                backgroundColor: 'rgba(0, 0, 0, 0.8)',
                titleFont: {
                    family: 'Cairo',
                    size: 14
                },
                bodyFont: {
                    family: 'Cairo',
                    size: 13
                },
                padding: 12,
                cornerRadius: 8,
                callbacks: {
                    label: function(context) {
                        const total = context.dataset.data.reduce((a, b) => a + b, 0);
                        const percentage = ((context.parsed / total) * 100).toFixed(1);
                        return ' ' + context.label + ': ' + context.parsed + ' ساعة (' + percentage + '%)';
                    }
                }
            }
        }
    }
});
</script>
@endpush
@endsection
