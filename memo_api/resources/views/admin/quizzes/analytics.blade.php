@extends('layouts.admin')

@section('title', 'تحليلات الكويزات')
@section('page-title', 'تحليلات الكويزات')
@section('page-description', 'تحليلات وإحصائيات شاملة لأداء الكويزات')

@section('content')
<div class="space-y-6">
    <!-- Date Range Filter -->
    <div class="bg-white rounded-lg shadow-md p-6">
        <form method="GET" action="{{ route('admin.quizzes.analytics') }}" class="flex items-end gap-4">
            <div class="flex-1">
                <label class="block text-sm font-medium text-gray-700 mb-2">من تاريخ</label>
                <input type="date" name="start_date" value="{{ $startDate }}"
                       class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
            </div>
            <div class="flex-1">
                <label class="block text-sm font-medium text-gray-700 mb-2">إلى تاريخ</label>
                <input type="date" name="end_date" value="{{ $endDate }}"
                       class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
            </div>
            <button type="submit" class="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
                <i class="fas fa-filter mr-2"></i>
                تطبيق
            </button>
        </form>
    </div>

    <!-- Overall Statistics -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-500 text-sm mb-1">إجمالي الكويزات المنشورة</p>
                    <p class="text-3xl font-bold text-blue-600">{{ $stats['total_quizzes'] }}</p>
                </div>
                <div class="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                    <i class="fas fa-clipboard-list text-blue-600 text-xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-500 text-sm mb-1">المحاولات هذا الشهر</p>
                    <p class="text-3xl font-bold text-purple-600">{{ number_format($stats['total_attempts_month']) }}</p>
                </div>
                <div class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                    <i class="fas fa-users text-purple-600 text-xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-500 text-sm mb-1">متوسط الدرجات</p>
                    <p class="text-3xl font-bold text-green-600">{{ round($stats['average_score'], 1) }}%</p>
                </div>
                <div class="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                    <i class="fas fa-chart-line text-green-600 text-xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-500 text-sm mb-1">معدل النجاح</p>
                    <p class="text-3xl font-bold text-indigo-600">{{ round($stats['pass_rate'], 1) }}%</p>
                </div>
                <div class="w-12 h-12 bg-indigo-100 rounded-lg flex items-center justify-center">
                    <i class="fas fa-check-circle text-indigo-600 text-xl"></i>
                </div>
            </div>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Most Popular Quizzes -->
        <div class="bg-white rounded-lg shadow-md p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">
                <i class="fas fa-fire text-orange-500 mr-2"></i>
                الكويزات الأكثر شعبية
            </h3>
            <div class="space-y-3">
                @forelse($popularQuizzes as $quiz)
                    <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                        <div class="flex-1">
                            <p class="font-medium text-gray-900">{{ $quiz->title_ar }}</p>
                            <p class="text-sm text-gray-500">
                                <i class="fas fa-book text-blue-500 mr-1"></i>
                                {{ $quiz->subject->name_ar ?? '-' }}
                            </p>
                        </div>
                        <div class="text-left">
                            <p class="text-2xl font-bold text-blue-600">{{ number_format($quiz->total_attempts) }}</p>
                            <p class="text-xs text-gray-500">محاولة</p>
                        </div>
                    </div>
                @empty
                    <p class="text-gray-500 text-center py-4">لا توجد بيانات</p>
                @endforelse
            </div>
        </div>

        <!-- Most Difficult Quizzes -->
        <div class="bg-white rounded-lg shadow-md p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">
                <i class="fas fa-exclamation-triangle text-red-500 mr-2"></i>
                الكويزات الأكثر صعوبة
            </h3>
            <div class="space-y-3">
                @forelse($difficultQuizzes as $quiz)
                    <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                        <div class="flex-1">
                            <p class="font-medium text-gray-900">{{ $quiz->title_ar }}</p>
                            <p class="text-sm text-gray-500">
                                <i class="fas fa-book text-blue-500 mr-1"></i>
                                {{ $quiz->subject->name_ar ?? '-' }}
                            </p>
                        </div>
                        <div class="text-left">
                            <p class="text-2xl font-bold text-red-600">{{ round($quiz->average_score, 1) }}%</p>
                            <p class="text-xs text-gray-500">متوسط الدرجات</p>
                        </div>
                    </div>
                @empty
                    <p class="text-gray-500 text-center py-4">لا توجد بيانات</p>
                @endforelse
            </div>
        </div>
    </div>

    <!-- Performance by Subject -->
    <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">
            <i class="fas fa-chart-bar text-blue-600 mr-2"></i>
            الأداء حسب المادة الدراسية
        </h3>
        <div class="overflow-x-auto">
            <table class="w-full">
                <thead class="bg-gray-50 border-b border-gray-200">
                    <tr>
                        <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">المادة</th>
                        <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">عدد الكويزات</th>
                        <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">إجمالي المحاولات</th>
                        <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">متوسط الدرجات</th>
                        <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">التقييم</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                    @forelse($performanceBySubject as $performance)
                        <tr class="hover:bg-gray-50 transition-colors">
                            <td class="px-6 py-4 text-sm font-medium text-gray-900">{{ $performance->name }}</td>
                            <td class="px-6 py-4 text-sm text-gray-900">{{ $performance->quiz_count }}</td>
                            <td class="px-6 py-4 text-sm text-gray-900">{{ number_format($performance->total_attempts) }}</td>
                            <td class="px-6 py-4 text-sm">
                                <div class="flex items-center gap-2">
                                    <div class="flex-1 bg-gray-200 rounded-full h-2">
                                        <div class="bg-blue-600 h-2 rounded-full" style="width: {{ min(100, $performance->avg_score) }}%"></div>
                                    </div>
                                    <span class="font-semibold text-gray-900 w-12 text-left">{{ round($performance->avg_score, 1) }}%</span>
                                </div>
                            </td>
                            <td class="px-6 py-4 text-sm">
                                @if($performance->avg_score >= 80)
                                    <span class="px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">ممتاز</span>
                                @elseif($performance->avg_score >= 70)
                                    <span class="px-2 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-800">جيد</span>
                                @elseif($performance->avg_score >= 60)
                                    <span class="px-2 py-1 text-xs font-semibold rounded-full bg-yellow-100 text-yellow-800">مقبول</span>
                                @else
                                    <span class="px-2 py-1 text-xs font-semibold rounded-full bg-red-100 text-red-800">ضعيف</span>
                                @endif
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="5" class="px-6 py-8 text-center text-gray-500">لا توجد بيانات</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <!-- Never Attempted Quizzes -->
    @if($neverAttempted->count() > 0)
        <div class="bg-white rounded-lg shadow-md p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">
                <i class="fas fa-question-circle text-gray-500 mr-2"></i>
                كويزات لم يتم حلها بعد ({{ $neverAttempted->count() }})
            </h3>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                @foreach($neverAttempted as $quiz)
                    <div class="p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                        <div class="flex items-start justify-between">
                            <div class="flex-1">
                                <p class="font-medium text-gray-900 mb-1">{{ $quiz->title_ar }}</p>
                                <p class="text-sm text-gray-500">
                                    <i class="fas fa-book text-blue-500 mr-1"></i>
                                    {{ $quiz->subject->name_ar ?? '-' }}
                                </p>
                                <div class="flex gap-2 mt-2">
                                    @if($quiz->difficulty_level == 'easy')
                                        <span class="px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">سهل</span>
                                    @elseif($quiz->difficulty_level == 'medium')
                                        <span class="px-2 py-1 text-xs font-semibold rounded-full bg-yellow-100 text-yellow-800">متوسط</span>
                                    @else
                                        <span class="px-2 py-1 text-xs font-semibold rounded-full bg-red-100 text-red-800">صعب</span>
                                    @endif
                                </div>
                            </div>
                            <a href="{{ route('admin.quizzes.show', $quiz->id) }}"
                               class="text-blue-600 hover:text-blue-800">
                                <i class="fas fa-eye"></i>
                            </a>
                        </div>
                    </div>
                @endforeach
            </div>
        </div>
    @endif

    <!-- Back Button -->
    <div>
        <a href="{{ route('admin.quizzes.index') }}"
           class="inline-block px-6 py-3 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors">
            <i class="fas fa-arrow-right mr-2"></i>
            العودة للقائمة
        </a>
    </div>
</div>
@endsection
