@extends('layouts.admin')

@section('title', 'إحصائيات المحتوى')

@section('content')
<div class="p-6 bg-gray-50 min-h-screen">
    <!-- Header -->
    <div class="mb-8">
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-3xl font-bold text-gray-900 flex items-center">
                    <i class="fas fa-chart-pie text-purple-600 mr-3"></i>
                    إحصائيات المحتوى
                </h1>
                <p class="text-gray-600 mt-2">نظرة شاملة على المحتوى التعليمي في المنصة</p>
            </div>
            <div class="flex gap-3">
                <button onclick="window.print()" class="px-4 py-2 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors flex items-center gap-2">
                    <i class="fas fa-print"></i>
                    <span>طباعة</span>
                </button>
                <a href="{{ route('admin.contents.create') }}" class="px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors flex items-center gap-2">
                    <i class="fas fa-plus"></i>
                    <span>إضافة محتوى</span>
                </a>
            </div>
        </div>
    </div>

    <!-- Overview Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-6 mb-8">
        <!-- Total Contents -->
        <div class="bg-gradient-to-l from-purple-500 to-purple-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between mb-4">
                <div class="bg-white/20 p-3 rounded-lg">
                    <i class="fas fa-book text-2xl"></i>
                </div>
                <span class="text-sm opacity-80">إجمالي المحتوى</span>
            </div>
            <div class="text-4xl font-bold">{{ number_format($stats['total_contents']) }}</div>
        </div>

        <!-- Published -->
        <div class="bg-gradient-to-l from-green-500 to-green-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between mb-4">
                <div class="bg-white/20 p-3 rounded-lg">
                    <i class="fas fa-check-circle text-2xl"></i>
                </div>
                <span class="text-sm opacity-80">منشور</span>
            </div>
            <div class="text-4xl font-bold">{{ number_format($stats['published_contents']) }}</div>
            <p class="text-sm mt-2 opacity-80">
                @if($stats['total_contents'] > 0)
                    {{ round(($stats['published_contents'] / $stats['total_contents']) * 100, 1) }}%
                @endif
            </p>
        </div>

        <!-- Draft -->
        <div class="bg-gradient-to-l from-orange-500 to-orange-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between mb-4">
                <div class="bg-white/20 p-3 rounded-lg">
                    <i class="fas fa-file-alt text-2xl"></i>
                </div>
                <span class="text-sm opacity-80">مسودات</span>
            </div>
            <div class="text-4xl font-bold">{{ number_format($stats['draft_contents']) }}</div>
            <p class="text-sm mt-2 opacity-80">
                @if($stats['total_contents'] > 0)
                    {{ round(($stats['draft_contents'] / $stats['total_contents']) * 100, 1) }}%
                @endif
            </p>
        </div>

        <!-- Total Views -->
        <div class="bg-gradient-to-l from-blue-500 to-blue-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between mb-4">
                <div class="bg-white/20 p-3 rounded-lg">
                    <i class="fas fa-eye text-2xl"></i>
                </div>
                <span class="text-sm opacity-80">المشاهدات</span>
            </div>
            <div class="text-4xl font-bold">{{ number_format($stats['total_views']) }}</div>
        </div>

        <!-- Total Downloads -->
        <div class="bg-gradient-to-l from-indigo-500 to-indigo-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between mb-4">
                <div class="bg-white/20 p-3 rounded-lg">
                    <i class="fas fa-download text-2xl"></i>
                </div>
                <span class="text-sm opacity-80">التنزيلات</span>
            </div>
            <div class="text-4xl font-bold">{{ number_format($stats['total_downloads']) }}</div>
        </div>
    </div>

    <!-- Charts Row -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        <!-- Contents by Type -->
        <div class="bg-white rounded-xl shadow-md p-6 hover:shadow-lg transition-shadow">
            <div class="flex items-center justify-between mb-6">
                <h2 class="text-xl font-bold text-gray-800 flex items-center">
                    <i class="fas fa-layer-group text-purple-600 mr-3"></i>
                    توزيع المحتوى حسب النوع
                </h2>
            </div>
            @if($contentsByType->isEmpty())
                <div class="flex flex-col items-center justify-center py-12">
                    <i class="fas fa-chart-pie text-gray-300 text-5xl mb-4"></i>
                    <p class="text-gray-500">لا توجد بيانات لعرضها</p>
                </div>
            @else
                <div class="relative" style="height: 300px;">
                    <canvas id="typeChart"></canvas>
                </div>
            @endif
        </div>

        <!-- Contents by Subject (Top 10) -->
        <div class="bg-white rounded-xl shadow-md p-6 hover:shadow-lg transition-shadow">
            <div class="flex items-center justify-between mb-6">
                <h2 class="text-xl font-bold text-gray-800 flex items-center">
                    <i class="fas fa-book-open text-blue-600 mr-3"></i>
                    المحتوى حسب المادة (أعلى 10)
                </h2>
            </div>
            @if($contentsBySubject->isEmpty())
                <div class="flex flex-col items-center justify-center py-12">
                    <i class="fas fa-chart-bar text-gray-300 text-5xl mb-4"></i>
                    <p class="text-gray-500">لا توجد بيانات لعرضها</p>
                </div>
            @else
                <div class="relative" style="height: 300px;">
                    <canvas id="subjectChart"></canvas>
                </div>
            @endif
        </div>
    </div>

    <!-- Top Viewed Content -->
    <div class="bg-white rounded-xl shadow-md mb-8 overflow-hidden">
        <div class="p-6 border-b border-gray-200 bg-gradient-to-r from-blue-50 to-indigo-50">
            <h2 class="text-xl font-bold text-gray-800 flex items-center">
                <i class="fas fa-fire text-blue-500 mr-3 text-2xl"></i>
                المحتوى الأكثر مشاهدة (أعلى 10)
            </h2>
            <p class="text-sm text-gray-600 mt-1">المحتوى الأكثر شعبية في المنصة</p>
        </div>

        @if($topViewed->isEmpty())
            <div class="p-12 text-center">
                <div class="mx-auto w-24 h-24 bg-gray-100 rounded-full flex items-center justify-center mb-4">
                    <i class="fas fa-book text-4xl text-gray-400"></i>
                </div>
                <h3 class="text-xl font-semibold text-gray-700 mb-2">لا توجد بيانات حالياً</h3>
                <p class="text-gray-500">سيظهر هنا المحتوى الأكثر مشاهدة بمجرد توفر البيانات</p>
            </div>
        @else
            <div class="overflow-x-auto">
                <table class="w-full">
                    <thead class="bg-gray-50 border-b border-gray-200">
                        <tr>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">#</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">العنوان</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">النوع</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">المادة</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">المشاهدات</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">التنزيلات</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">الحالة</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">الإجراءات</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200 bg-white">
                        @foreach($topViewed as $index => $content)
                        <tr class="hover:bg-gray-50 transition-colors">
                            <td class="px-6 py-4">
                                <span class="text-gray-600 font-semibold">#{{ $index + 1 }}</span>
                            </td>
                            <td class="px-6 py-4">
                                <div class="font-semibold text-gray-800">{{ $content->title_ar }}</div>
                                @if($content->description_ar)
                                    <div class="text-sm text-gray-500 mt-1">{{ Str::limit($content->description_ar, 60) }}</div>
                                @endif
                            </td>
                            <td class="px-6 py-4">
                                <span class="bg-purple-100 text-purple-800 px-3 py-1 rounded-full text-sm font-semibold">
                                    {{ $content->contentType->name_ar ?? 'N/A' }}
                                </span>
                            </td>
                            <td class="px-6 py-4">
                                <span class="text-gray-700 font-medium">
                                    {{ $content->subject->name_ar ?? 'N/A' }}
                                </span>
                            </td>
                            <td class="px-6 py-4">
                                <div class="flex items-center">
                                    <i class="fas fa-eye text-blue-500 mr-2"></i>
                                    <span class="font-bold text-blue-600">{{ number_format($content->views_count) }}</span>
                                </div>
                            </td>
                            <td class="px-6 py-4">
                                <div class="flex items-center">
                                    <i class="fas fa-download text-green-500 mr-2"></i>
                                    <span class="font-bold text-green-600">{{ number_format($content->downloads_count) }}</span>
                                </div>
                            </td>
                            <td class="px-6 py-4">
                                @if($content->is_published)
                                    <span class="bg-green-100 text-green-800 px-3 py-1 rounded-full text-sm font-semibold">
                                        <i class="fas fa-check-circle mr-1"></i>
                                        منشور
                                    </span>
                                @else
                                    <span class="bg-orange-100 text-orange-800 px-3 py-1 rounded-full text-sm font-semibold">
                                        <i class="fas fa-clock mr-1"></i>
                                        مسودة
                                    </span>
                                @endif
                            </td>
                            <td class="px-6 py-4">
                                <a href="{{ route('admin.contents.show', $content->id) }}"
                                   class="text-blue-600 hover:text-blue-800 font-semibold transition-colors">
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

    <!-- Top Rated Content -->
    @if($topRated->isNotEmpty())
    <div class="bg-white rounded-xl shadow-md mb-8 overflow-hidden">
        <div class="p-6 border-b border-gray-200 bg-gradient-to-r from-yellow-50 to-orange-50">
            <h2 class="text-xl font-bold text-gray-800 flex items-center">
                <i class="fas fa-star text-yellow-500 mr-3 text-2xl"></i>
                المحتوى الأعلى تقييماً (أعلى 10)
            </h2>
            <p class="text-sm text-gray-600 mt-1">المحتوى الأكثر تقييماً من المستخدمين</p>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full">
                <thead class="bg-gray-50 border-b border-gray-200">
                    <tr>
                        <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">#</th>
                        <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">العنوان</th>
                        <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">النوع</th>
                        <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">المادة</th>
                        <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">التقييم</th>
                        <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">عدد التقييمات</th>
                        <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">الإجراءات</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200 bg-white">
                    @foreach($topRated as $index => $content)
                    <tr class="hover:bg-gray-50 transition-colors">
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
                            <div class="font-semibold text-gray-800">{{ $content->title_ar }}</div>
                        </td>
                        <td class="px-6 py-4">
                            <span class="bg-purple-100 text-purple-800 px-3 py-1 rounded-full text-sm font-semibold">
                                {{ $content->contentType->name_ar ?? 'N/A' }}
                            </span>
                        </td>
                        <td class="px-6 py-4">
                            <span class="text-gray-700 font-medium">
                                {{ $content->subject->name_ar ?? 'N/A' }}
                            </span>
                        </td>
                        <td class="px-6 py-4">
                            <div class="flex items-center">
                                @for($i = 1; $i <= 5; $i++)
                                    @if($i <= round($content->average_rating))
                                        <i class="fas fa-star text-yellow-400"></i>
                                    @else
                                        <i class="far fa-star text-gray-300"></i>
                                    @endif
                                @endfor
                                <span class="mr-2 font-bold text-gray-700">{{ number_format($content->average_rating, 1) }}</span>
                            </div>
                        </td>
                        <td class="px-6 py-4">
                            <span class="text-gray-600">{{ number_format($content->ratings_count) }} تقييم</span>
                        </td>
                        <td class="px-6 py-4">
                            <a href="{{ route('admin.contents.show', $content->id) }}"
                               class="text-blue-600 hover:text-blue-800 font-semibold transition-colors">
                                <i class="fas fa-eye mr-1"></i>
                                عرض
                            </a>
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
    @endif
</div>

@if(!$contentsByType->isEmpty() || !$contentsBySubject->isEmpty())
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    @if(!$contentsByType->isEmpty())
    // Contents by Type Chart
    const typeData = @json($contentsByType);
    const typeLabels = typeData.map(t => t.content_type?.name_ar || 'غير محدد');
    const typeCounts = typeData.map(t => t.count);

    new Chart(document.getElementById('typeChart'), {
        type: 'doughnut',
        data: {
            labels: typeLabels,
            datasets: [{
                data: typeCounts,
                backgroundColor: [
                    'rgba(139, 92, 246, 0.85)',  // Purple
                    'rgba(59, 130, 246, 0.85)',  // Blue
                    'rgba(16, 185, 129, 0.85)',  // Green
                    'rgba(245, 158, 11, 0.85)',  // Orange
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

    @if(!$contentsBySubject->isEmpty())
    // Contents by Subject Chart
    const subjectData = @json($contentsBySubject);
    const subjectLabels = subjectData.map(s => s.subject?.name_ar || 'غير محدد');
    const subjectCounts = subjectData.map(s => s.count);

    new Chart(document.getElementById('subjectChart'), {
        type: 'bar',
        data: {
            labels: subjectLabels,
            datasets: [{
                label: 'عدد المحتويات',
                data: subjectCounts,
                backgroundColor: 'rgba(59, 130, 246, 0.7)',
                borderColor: 'rgb(59, 130, 246)',
                borderWidth: 2,
                borderRadius: 8,
                hoverBackgroundColor: 'rgba(59, 130, 246, 0.9)'
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
                            return 'المحتويات: ' + context.parsed.y;
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
