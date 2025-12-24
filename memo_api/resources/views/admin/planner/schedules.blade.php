@extends('layouts.admin')

@section('title', 'الجداول الدراسية')
@section('page-title', 'الجداول الدراسية')
@section('page-description', 'إدارة ومتابعة جداول الدراسة للمستخدمين')

@section('content')
    <!-- Back Button -->
    <div class="mb-6">
        <a href="{{ route('admin.planner.index') }}" class="inline-flex items-center px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors">
            <i class="fas fa-arrow-right mr-2"></i>
            العودة للرئيسية
        </a>
    </div>

    <!-- Filters -->
    <div class="bg-white rounded-lg shadow-md p-6 mb-6">
        <form method="GET" action="{{ route('admin.planner.schedules') }}" class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <!-- Search -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">بحث</label>
                <input type="text" name="search" value="{{ request('search') }}" placeholder="اسم المستخدم أو البريد" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
            </div>

            <!-- Status Filter -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">الحالة</label>
                <select name="status" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                    <option value="">جميع الحالات</option>
                    <option value="draft" {{ request('status') == 'draft' ? 'selected' : '' }}>مسودة</option>
                    <option value="active" {{ request('status') == 'active' ? 'selected' : '' }}>نشط</option>
                    <option value="completed" {{ request('status') == 'completed' ? 'selected' : '' }}>مكتمل</option>
                    <option value="archived" {{ request('status') == 'archived' ? 'selected' : '' }}>مؤرشف</option>
                </select>
            </div>

            <!-- User Filter -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">المستخدم</label>
                <select name="user_id" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                    <option value="">جميع المستخدمين</option>
                    @foreach($users as $user)
                        <option value="{{ $user->id }}" {{ request('user_id') == $user->id ? 'selected' : '' }}>
                            {{ $user->name }}
                        </option>
                    @endforeach
                </select>
            </div>

            <!-- Submit -->
            <div class="flex items-end">
                <button type="submit" class="w-full px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors">
                    <i class="fas fa-search mr-2"></i>
                    تصفية
                </button>
            </div>
        </form>
    </div>

    <!-- Schedules Table -->
    <div class="bg-white rounded-lg shadow-md overflow-hidden">
        @if($schedules->count() > 0)
            <div class="overflow-x-auto">
                <table class="w-full">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">#</th>
                            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">المستخدم</th>
                            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">الفترة</th>
                            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">النوع</th>
                            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">الجلسات</th>
                            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">الساعات</th>
                            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">الجدوى</th>
                            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">الحالة</th>
                            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">إجراءات</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200">
                        @foreach($schedules as $schedule)
                            <tr class="hover:bg-gray-50">
                                <td class="px-6 py-4 text-sm text-gray-900">{{ $schedule->id }}</td>
                                <td class="px-6 py-4">
                                    <div class="text-sm font-semibold text-gray-900">{{ $schedule->user->name }}</div>
                                    <div class="text-xs text-gray-500">{{ $schedule->user->email }}</div>
                                </td>
                                <td class="px-6 py-4 text-sm text-gray-600">
                                    <div>{{ $schedule->start_date->format('Y/m/d') }}</div>
                                    <div class="text-xs text-gray-500">إلى {{ $schedule->end_date->format('Y/m/d') }}</div>
                                </td>
                                <td class="px-6 py-4 text-sm text-gray-600">
                                    @if($schedule->schedule_type == 'auto')
                                        <span class="text-blue-600">تلقائي</span>
                                    @elseif($schedule->schedule_type == 'manual')
                                        <span class="text-purple-600">يدوي</span>
                                    @else
                                        <span class="text-green-600">تحضير امتحان</span>
                                    @endif
                                </td>
                                <td class="px-6 py-4 text-sm text-gray-600">
                                    {{ $schedule->studySessions->count() }} جلسة
                                </td>
                                <td class="px-6 py-4 text-sm text-gray-600">
                                    {{ number_format($schedule->total_study_hours, 1) }} ساعة
                                </td>
                                <td class="px-6 py-4">
                                    <div class="flex items-center">
                                        <div class="w-16 bg-gray-200 rounded-full h-2 mr-2">
                                            <div class="bg-green-500 h-2 rounded-full" style="width: {{ $schedule->feasibility_score * 100 }}%"></div>
                                        </div>
                                        <span class="text-xs text-gray-600">{{ number_format($schedule->feasibility_score * 100, 0) }}%</span>
                                    </div>
                                </td>
                                <td class="px-6 py-4">
                                    <span class="px-2 py-1 text-xs rounded-full
                                        @if($schedule->status === 'active') bg-green-100 text-green-800
                                        @elseif($schedule->status === 'draft') bg-gray-100 text-gray-800
                                        @elseif($schedule->status === 'completed') bg-blue-100 text-blue-800
                                        @else bg-yellow-100 text-yellow-800
                                        @endif">
                                        {{ $schedule->status }}
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    <a href="{{ route('admin.planner.schedules.show', $schedule->id) }}" class="text-blue-500 hover:text-blue-700">
                                        <i class="fas fa-eye"></i>
                                    </a>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>

            <!-- Pagination -->
            <div class="px-6 py-4 border-t border-gray-200">
                {{ $schedules->links() }}
            </div>
        @else
            <div class="p-12 text-center">
                <i class="fas fa-calendar-times text-gray-300 text-6xl mb-4"></i>
                <p class="text-gray-500 text-lg">لا توجد جداول دراسية</p>
            </div>
        @endif
    </div>

@endsection
