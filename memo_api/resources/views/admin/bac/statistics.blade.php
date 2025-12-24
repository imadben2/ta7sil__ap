@extends('layouts.admin')

@section('title', 'إحصائيات أرشيف البكالوريا')
@section('page-title', 'إحصائيات أرشيف البكالوريا')
@section('page-description', 'عرض الإحصائيات والتحليلات التفصيلية')

@section('content')
<div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
        <a href="{{ route('admin.bac.index') }}" class="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors">
            <i class="fas fa-arrow-right mr-2"></i>
            العودة
        </a>
    </div>

    <!-- Overall Statistics -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
        <!-- Total Subjects -->
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm font-medium text-gray-500">إجمالي المواضيع</p>
                    <p class="text-3xl font-bold text-purple-600 mt-2">{{ $statistics['total_subjects'] }}</p>
                </div>
                <div class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                    <i class="fas fa-file-alt text-purple-600 text-xl"></i>
                </div>
            </div>
        </div>

        <!-- Total Views -->
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm font-medium text-gray-500">إجمالي المشاهدات</p>
                    <p class="text-3xl font-bold text-blue-600 mt-2">{{ number_format($statistics['total_views']) }}</p>
                </div>
                <div class="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                    <i class="fas fa-eye text-blue-600 text-xl"></i>
                </div>
            </div>
        </div>

        <!-- Total Downloads -->
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm font-medium text-gray-500">إجمالي التنزيلات</p>
                    <p class="text-3xl font-bold text-green-600 mt-2">{{ number_format($statistics['total_downloads']) }}</p>
                </div>
                <div class="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                    <i class="fas fa-download text-green-600 text-xl"></i>
                </div>
            </div>
        </div>

        <!-- Total Simulations -->
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm font-medium text-gray-500">إجمالي المحاكاة</p>
                    <p class="text-3xl font-bold text-orange-600 mt-2">{{ number_format($simulationStats['total_simulations']) }}</p>
                </div>
                <div class="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
                    <i class="fas fa-play-circle text-orange-600 text-xl"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Simulation Statistics -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <!-- Completed Simulations -->
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between mb-4">
                <h4 class="text-sm font-medium text-gray-500">المحاكاة المكتملة</h4>
                <i class="fas fa-check-circle text-green-600 text-xl"></i>
            </div>
            <p class="text-2xl font-bold text-green-600">{{ number_format($simulationStats['completed_simulations']) }}</p>
            @if($simulationStats['total_simulations'] > 0)
                <p class="text-sm text-gray-500 mt-2">
                    {{ number_format(($simulationStats['completed_simulations'] / $simulationStats['total_simulations']) * 100, 1) }}% من الإجمالي
                </p>
            @endif
        </div>

        <!-- Active Simulations -->
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between mb-4">
                <h4 class="text-sm font-medium text-gray-500">المحاكاة النشطة</h4>
                <i class="fas fa-spinner text-blue-600 text-xl"></i>
            </div>
            <p class="text-2xl font-bold text-blue-600">{{ number_format($simulationStats['active_simulations']) }}</p>
        </div>

        <!-- Abandoned Simulations -->
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between mb-4">
                <h4 class="text-sm font-medium text-gray-500">المحاكاة الملغاة</h4>
                <i class="fas fa-times-circle text-red-600 text-xl"></i>
            </div>
            <p class="text-2xl font-bold text-red-600">{{ number_format($simulationStats['abandoned_simulations']) }}</p>
            @if($simulationStats['total_simulations'] > 0)
                <p class="text-sm text-gray-500 mt-2">
                    {{ number_format(($simulationStats['abandoned_simulations'] / $simulationStats['total_simulations']) * 100, 1) }}% من الإجمالي
                </p>
            @endif
        </div>
    </div>

    <!-- Subjects by Year -->
    <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-6">
            <i class="fas fa-chart-bar text-blue-600 mr-2"></i>
            توزيع المواضيع حسب السنة
        </h3>

        @if(count($statistics['subjects_by_year']) > 0)
            <div class="space-y-4">
                @foreach($statistics['subjects_by_year'] as $yearData)
                    <div>
                        <div class="flex items-center justify-between mb-2">
                            <span class="text-sm font-medium text-gray-700">{{ $yearData->bacYear->year }}</span>
                            <span class="text-sm font-bold text-purple-600">{{ $yearData->count }} موضوع</span>
                        </div>
                        <div class="w-full bg-gray-200 rounded-full h-2">
                            <div class="bg-purple-600 h-2 rounded-full" style="width: {{ ($yearData->count / $statistics['total_subjects']) * 100 }}%"></div>
                        </div>
                    </div>
                @endforeach
            </div>
        @else
            <div class="text-center py-8 text-gray-500">
                <p>لا توجد بيانات</p>
            </div>
        @endif
    </div>

    <!-- Most Downloaded Subjects -->
    <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-6">
            <i class="fas fa-fire text-orange-600 mr-2"></i>
            المواضيع الأكثر تحميلاً
        </h3>

        @if(count($statistics['most_downloaded']) > 0)
            <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">#</th>
                            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">العنوان</th>
                            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">السنة</th>
                            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">الدورة</th>
                            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">المادة</th>
                            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">التنزيلات</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                        @foreach($statistics['most_downloaded'] as $index => $subject)
                            <tr class="hover:bg-gray-50">
                                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                                    @if($index < 3)
                                        <span class="inline-flex items-center justify-center w-6 h-6 rounded-full {{ $index === 0 ? 'bg-yellow-100 text-yellow-800' : ($index === 1 ? 'bg-gray-100 text-gray-800' : 'bg-orange-100 text-orange-800') }}">
                                            {{ $index + 1 }}
                                        </span>
                                    @else
                                        {{ $index + 1 }}
                                    @endif
                                </td>
                                <td class="px-6 py-4 text-sm text-gray-900">{{ Str::limit($subject->title_ar, 50) }}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{{ $subject->bacYear->year }}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{{ $subject->bacSession->name_ar }}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{{ $subject->subject->name_ar }}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm font-bold text-green-600">
                                    <i class="fas fa-download mr-1"></i>
                                    {{ number_format($subject->downloads_count) }}
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        @else
            <div class="text-center py-8 text-gray-500">
                <p>لا توجد بيانات</p>
            </div>
        @endif
    </div>

    <!-- Average Simulation Duration -->
    @if($simulationStats['average_duration'])
        <div class="bg-white rounded-lg shadow-md p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">
                <i class="fas fa-clock text-blue-600 mr-2"></i>
                متوسط مدة المحاكاة
            </h3>
            <p class="text-3xl font-bold text-blue-600">
                {{ gmdate('H:i:s', $simulationStats['average_duration']) }}
            </p>
            <p class="text-sm text-gray-500 mt-2">ساعة:دقيقة:ثانية</p>
        </div>
    @endif
</div>
@endsection
