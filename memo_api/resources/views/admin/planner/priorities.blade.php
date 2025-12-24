@extends('layouts.admin')

@section('title', 'أولويات المواد')
@section('page-title', 'أولويات المواد')
@section('page-description', 'عرض الأولويات المحسوبة للمواد الدراسية')

@section('content')
    <!-- Back Button -->
    <div class="mb-6">
        <a href="{{ route('admin.planner.index') }}" class="inline-flex items-center px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors">
            <i class="fas fa-arrow-right mr-2"></i>
            العودة
        </a>
    </div>

    <div class="bg-white rounded-lg shadow-md p-6 mb-6">
        <form method="GET" class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">بحث</label>
                <input type="text" name="search" value="{{ request('search') }}" placeholder="اسم المستخدم أو المادة" class="w-full px-4 py-2 border border-gray-300 rounded-lg">
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">المستخدم</label>
                <select name="user_id" class="w-full px-4 py-2 border border-gray-300 rounded-lg">
                    <option value="">الكل</option>
                    @foreach($users as $user)
                        <option value="{{ $user->id }}" {{ request('user_id') == $user->id ? 'selected' : '' }}>{{ $user->name }}</option>
                    @endforeach
                </select>
            </div>
            <div class="flex items-end">
                <button type="submit" class="w-full px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600">
                    <i class="fas fa-search mr-2"></i>
                    تصفية
                </button>
            </div>
        </form>
    </div>

    <div class="bg-white rounded-lg shadow-md overflow-hidden">
        @if($priorities->count() > 0)
            <table class="w-full">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">المستخدم</th>
                        <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">المادة</th>
                        <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">الأولوية الكلية</th>
                        <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">المعامل</th>
                        <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">قرب الامتحان</th>
                        <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">الصعوبة</th>
                        <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">الخمول</th>
                        <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">فجوة الأداء</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                    @foreach($priorities as $priority)
                        <tr class="hover:bg-gray-50">
                            <td class="px-6 py-4 text-sm">{{ $priority->user->name }}</td>
                            <td class="px-6 py-4 text-sm font-semibold">{{ $priority->subject->name }}</td>
                            <td class="px-6 py-4">
                                <div class="flex items-center">
                                    <span class="px-3 py-1 rounded-full text-sm font-semibold bg-green-100 text-green-800 mr-2">
                                        {{ number_format($priority->total_priority_score, 2) }}
                                    </span>
                                    <div class="w-20 bg-gray-200 rounded-full h-2">
                                        <div class="bg-green-500 h-2 rounded-full" style="width: {{ min(100, ($priority->total_priority_score / 10) * 100) }}%"></div>
                                    </div>
                                </div>
                            </td>
                            <td class="px-6 py-4 text-sm text-center">{{ number_format($priority->coefficient_score, 1) }}</td>
                            <td class="px-6 py-4 text-sm text-center">{{ number_format($priority->exam_proximity_score, 1) }}</td>
                            <td class="px-6 py-4 text-sm text-center">{{ number_format($priority->difficulty_score, 1) }}</td>
                            <td class="px-6 py-4 text-sm text-center">{{ number_format($priority->inactivity_score, 1) }}</td>
                            <td class="px-6 py-4 text-sm text-center">{{ number_format($priority->performance_gap_score, 1) }}</td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
            <div class="px-6 py-4 border-t">
                {{ $priorities->links() }}
            </div>
        @else
            <div class="p-12 text-center">
                <i class="fas fa-sort-amount-up text-gray-300 text-6xl mb-4"></i>
                <p class="text-gray-500 text-lg">لا توجد بيانات أولويات</p>
            </div>
        @endif
    </div>

@endsection
