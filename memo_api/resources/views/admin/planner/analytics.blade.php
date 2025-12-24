@extends('layouts.admin')

@section('title', 'تحليلات المخطط')
@section('page-title', 'تحليلات المخطط الذكي')
@section('page-description', 'تحليلات شاملة لأداء المستخدمين والجلسات الدراسية')

@section('content')

    <div class="bg-white rounded-lg shadow-md p-6 mb-6">
        <form method="GET" class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">تاريخ البداية</label>
                <input type="date" name="start_date" value="{{ request('start_date', $startDate instanceof \Carbon\Carbon ? $startDate->format('Y-m-d') : $startDate) }}" class="w-full px-4 py-2 border border-gray-300 rounded-lg">
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">تاريخ النهاية</label>
                <input type="date" name="end_date" value="{{ request('end_date', $endDate instanceof \Carbon\Carbon ? $endDate->format('Y-m-d') : $endDate) }}" class="w-full px-4 py-2 border border-gray-300 rounded-lg">
            </div>
            <div class="flex items-end">
                <button type="submit" class="w-full px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600">
                    <i class="fas fa-filter mr-2"></i>
                    تطبيق
                </button>
            </div>
        </form>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <div class="bg-white rounded-lg shadow-md p-6">
            <h3 class="text-lg font-semibold mb-4">معدلات الإنجاز حسب المستخدم</h3>
            @if($userCompletionRates->count() > 0)
                <div class="space-y-3">
                    @foreach($userCompletionRates as $user)
                        <div>
                            <div class="flex justify-between mb-1">
                                <span class="text-sm font-medium">{{ $user->name }}</span>
                                <span class="text-sm text-gray-600">{{ number_format(($user->completed / $user->total) * 100, 1) }}%</span>
                            </div>
                            <div class="w-full bg-gray-200 rounded-full h-2">
                                <div class="bg-blue-500 h-2 rounded-full" style="width: {{ ($user->completed / $user->total) * 100 }}%"></div>
                            </div>
                            <div class="text-xs text-gray-500 mt-1">
                                {{ $user->completed }} / {{ $user->total }} جلسة
                            </div>
                        </div>
                    @endforeach
                </div>
            @else
                <p class="text-gray-500 text-center py-8">لا توجد بيانات</p>
            @endif
        </div>

        <div class="bg-white rounded-lg shadow-md p-6">
            <h3 class="text-lg font-semibold mb-4">التركيز حسب الوقت</h3>
            @if($focusScoresByTime->count() > 0)
                <div class="space-y-3">
                    @foreach($focusScoresByTime as $time)
                        <div>
                            <div class="flex justify-between mb-1">
                                <span class="text-sm font-medium">الساعة {{ $time->hour }}:00</span>
                                <span class="text-sm text-gray-600">{{ number_format($time->avg_focus_score, 1) }}/10</span>
                            </div>
                            <div class="w-full bg-gray-200 rounded-full h-2">
                                <div class="bg-green-500 h-2 rounded-full" style="width: {{ ($time->avg_focus_score / 10) * 100 }}%"></div>
                            </div>
                        </div>
                    @endforeach
                </div>
            @else
                <p class="text-gray-500 text-center py-8">لا توجد بيانات</p>
            @endif
        </div>
    </div>

    <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-lg font-semibold mb-4">الجلسات مع الوقت</h3>
        <div class="text-gray-500 text-center py-8">
            <i class="fas fa-chart-line text-6xl mb-2"></i>
            <p>الرسوم البيانية قيد التطوير</p>
            <p class="text-sm">سيتم إضافة Chart.js لعرض البيانات</p>
        </div>
    </div>

@endsection
