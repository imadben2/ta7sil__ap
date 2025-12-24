@extends('layouts.admin')

@section('title', 'نظام التخطيط الذكي')
@section('page-title', 'نظام التخطيط الذكي')
@section('page-description', 'متابعة وإدارة جداول الدراسة والأولويات')

@section('content')

    <!-- Statistics Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <!-- Active Schedules -->
        <div class="bg-white rounded-lg shadow-md p-6 border-r-4 border-blue-500">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-500 text-sm mb-1">الجداول النشطة</p>
                    <p class="text-3xl font-bold text-gray-800">{{ $stats['active_schedules'] }}</p>
                </div>
                <div class="bg-blue-100 p-3 rounded-full">
                    <i class="fas fa-calendar-alt text-blue-500 text-2xl"></i>
                </div>
            </div>
        </div>

        <!-- Users with Schedules -->
        <div class="bg-white rounded-lg shadow-md p-6 border-r-4 border-green-500">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-500 text-sm mb-1">المستخدمون النشطون</p>
                    <p class="text-3xl font-bold text-gray-800">{{ $stats['total_users_with_schedules'] }}</p>
                </div>
                <div class="bg-green-100 p-3 rounded-full">
                    <i class="fas fa-users text-green-500 text-2xl"></i>
                </div>
            </div>
        </div>

        <!-- Today's Sessions -->
        <div class="bg-white rounded-lg shadow-md p-6 border-r-4 border-purple-500">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-500 text-sm mb-1">جلسات اليوم</p>
                    <p class="text-3xl font-bold text-gray-800">{{ $stats['completed_sessions_today'] }}/{{ $stats['total_sessions_today'] }}</p>
                </div>
                <div class="bg-purple-100 p-3 rounded-full">
                    <i class="fas fa-book-open text-purple-500 text-2xl"></i>
                </div>
            </div>
        </div>

        <!-- In Progress Sessions -->
        <div class="bg-white rounded-lg shadow-md p-6 border-r-4 border-yellow-500">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-500 text-sm mb-1">جلسات جارية</p>
                    <p class="text-3xl font-bold text-gray-800">{{ $stats['in_progress_sessions'] }}</p>
                </div>
                <div class="bg-yellow-100 p-3 rounded-full">
                    <i class="fas fa-spinner text-yellow-500 text-2xl"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Quick Links -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <a href="{{ route('admin.planner.schedules') }}" class="bg-gradient-to-br from-blue-500 to-blue-600 text-white rounded-lg shadow-lg p-6 hover:shadow-xl transition-shadow">
            <div class="flex items-center">
                <div class="bg-white bg-opacity-20 p-3 rounded-full mr-4">
                    <i class="fas fa-calendar-check text-2xl"></i>
                </div>
                <div>
                    <h3 class="text-lg font-semibold mb-1">إدارة الجداول</h3>
                    <p class="text-blue-100 text-sm">عرض وتعديل جداول الدراسة</p>
                </div>
            </div>
        </a>

        <a href="{{ route('admin.planner.sessions') }}" class="bg-gradient-to-br from-purple-500 to-purple-600 text-white rounded-lg shadow-lg p-6 hover:shadow-xl transition-shadow">
            <div class="flex items-center">
                <div class="bg-white bg-opacity-20 p-3 rounded-full mr-4">
                    <i class="fas fa-book-reader text-2xl"></i>
                </div>
                <div>
                    <h3 class="text-lg font-semibold mb-1">جلسات الدراسة</h3>
                    <p class="text-purple-100 text-sm">متابعة وإدارة الجلسات</p>
                </div>
            </div>
        </a>

        <a href="{{ route('admin.planner.priorities') }}" class="bg-gradient-to-br from-green-500 to-green-600 text-white rounded-lg shadow-lg p-6 hover:shadow-xl transition-shadow">
            <div class="flex items-center">
                <div class="bg-white bg-opacity-20 p-3 rounded-full mr-4">
                    <i class="fas fa-sort-amount-up text-2xl"></i>
                </div>
                <div>
                    <h3 class="text-lg font-semibold mb-1">أولويات المواد</h3>
                    <p class="text-green-100 text-sm">عرض الأولويات المحسوبة</p>
                </div>
            </div>
        </a>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Recent Schedules -->
        <div class="bg-white rounded-lg shadow-md overflow-hidden">
            <div class="bg-gradient-to-r from-blue-500 to-blue-600 px-6 py-4">
                <h2 class="text-xl font-semibold text-white">آخر الجداول المُنشأة</h2>
            </div>
            <div class="p-6">
                @if($recentSchedules->count() > 0)
                    <div class="space-y-4">
                        @foreach($recentSchedules as $schedule)
                            <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                                <div class="flex-1">
                                    <h3 class="font-semibold text-gray-800">{{ $schedule->user->name }}</h3>
                                    <p class="text-sm text-gray-600">
                                        {{ $schedule->start_date->format('Y/m/d') }} - {{ $schedule->end_date->format('Y/m/d') }}
                                    </p>
                                    <div class="flex items-center mt-2 space-x-2 space-x-reverse">
                                        <span class="px-2 py-1 text-xs rounded-full
                                            @if($schedule->status === 'active') bg-green-100 text-green-800
                                            @elseif($schedule->status === 'draft') bg-gray-100 text-gray-800
                                            @else bg-blue-100 text-blue-800
                                            @endif">
                                            {{ $schedule->status }}
                                        </span>
                                        <span class="text-xs text-gray-500">
                                            {{ $schedule->total_study_hours }} ساعة دراسة
                                        </span>
                                    </div>
                                </div>
                                <a href="{{ route('admin.planner.schedules.show', $schedule->id) }}" class="text-blue-500 hover:text-blue-700">
                                    <i class="fas fa-arrow-left"></i>
                                </a>
                            </div>
                        @endforeach
                    </div>
                @else
                    <p class="text-gray-500 text-center py-8">لا توجد جداول حتى الآن</p>
                @endif
            </div>
        </div>

        <!-- Active Sessions -->
        <div class="bg-white rounded-lg shadow-md overflow-hidden">
            <div class="bg-gradient-to-r from-purple-500 to-purple-600 px-6 py-4">
                <h2 class="text-xl font-semibold text-white">الجلسات الجارية</h2>
            </div>
            <div class="p-6">
                @if($activeSessions->count() > 0)
                    <div class="space-y-4">
                        @foreach($activeSessions as $session)
                            <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                                <div class="flex-1">
                                    <h3 class="font-semibold text-gray-800">{{ $session->user->name }}</h3>
                                    <p class="text-sm text-gray-600">{{ $session->subject->name }}</p>
                                    <p class="text-xs text-gray-500 mt-1">
                                        <i class="far fa-clock mr-1"></i>
                                        بدأت منذ {{ $session->actual_start ? $session->actual_start->diffForHumans() : '-' }}
                                    </p>
                                </div>
                                <div class="flex items-center space-x-2 space-x-reverse">
                                    <span class="w-3 h-3 bg-green-500 rounded-full animate-pulse"></span>
                                    <a href="{{ route('admin.planner.sessions.show', $session->id) }}" class="text-purple-500 hover:text-purple-700">
                                        <i class="fas fa-arrow-left"></i>
                                    </a>
                                </div>
                            </div>
                        @endforeach
                    </div>
                @else
                    <p class="text-gray-500 text-center py-8">لا توجد جلسات جارية حالياً</p>
                @endif
            </div>
        </div>
    </div>

    <!-- Top Priorities -->
    <div class="mt-6 bg-white rounded-lg shadow-md overflow-hidden">
        <div class="bg-gradient-to-r from-green-500 to-green-600 px-6 py-4">
            <h2 class="text-xl font-semibold text-white">أعلى الأولويات</h2>
        </div>
        <div class="p-6">
            @if($topPriorities->count() > 0)
                <div class="overflow-x-auto">
                    <table class="w-full">
                        <thead>
                            <tr class="bg-gray-50">
                                <th class="px-4 py-3 text-right text-xs font-semibold text-gray-600 uppercase">المستخدم</th>
                                <th class="px-4 py-3 text-right text-xs font-semibold text-gray-600 uppercase">المادة</th>
                                <th class="px-4 py-3 text-right text-xs font-semibold text-gray-600 uppercase">نقاط الأولوية</th>
                                <th class="px-4 py-3 text-right text-xs font-semibold text-gray-600 uppercase">المعامل</th>
                                <th class="px-4 py-3 text-right text-xs font-semibold text-gray-600 uppercase">قرب الامتحان</th>
                                <th class="px-4 py-3 text-right text-xs font-semibold text-gray-600 uppercase">الصعوبة</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-200">
                            @foreach($topPriorities as $priority)
                                <tr class="hover:bg-gray-50">
                                    <td class="px-4 py-3 text-sm">{{ $priority->user->name }}</td>
                                    <td class="px-4 py-3 text-sm font-semibold">{{ $priority->subject->name }}</td>
                                    <td class="px-4 py-3 text-sm">
                                        <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-800">
                                            {{ number_format($priority->total_priority_score, 2) }}
                                        </span>
                                    </td>
                                    <td class="px-4 py-3 text-sm text-gray-600">{{ number_format($priority->coefficient_score, 1) }}</td>
                                    <td class="px-4 py-3 text-sm text-gray-600">{{ number_format($priority->exam_proximity_score, 1) }}</td>
                                    <td class="px-4 py-3 text-sm text-gray-600">{{ number_format($priority->difficulty_score, 1) }}</td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            @else
                <p class="text-gray-500 text-center py-8">لا توجد بيانات أولويات</p>
            @endif
        </div>
    </div>

@endsection
