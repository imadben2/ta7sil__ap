@extends('layouts.admin')

@section('title', 'جدول مراجعة البكالوريا')
@section('page-title', 'جدول مراجعة البكالوريا')
@section('page-description', 'إدارة جدول المراجعة 98 يوم للبكالوريا')

@section('content')

    <!-- Stream Filter -->
    <div class="bg-white rounded-lg shadow-md p-4 mb-6">
        <form method="GET" class="flex items-center gap-4">
            <label class="font-semibold text-gray-700">الشعبة:</label>
            <select name="stream_id" onchange="this.form.submit()" class="border rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500">
                <option value="">جميع الشعب</option>
                @foreach($streams as $stream)
                    <option value="{{ $stream->id }}" {{ $streamId == $stream->id ? 'selected' : '' }}>
                        {{ $stream->name_ar }}
                    </option>
                @endforeach
            </select>
        </form>
    </div>

    <!-- Statistics Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-6 mb-8">
        <!-- Total Days -->
        <div class="bg-white rounded-lg shadow-md p-6 border-r-4 border-blue-500">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-500 text-sm mb-1">إجمالي الأيام</p>
                    <p class="text-3xl font-bold text-gray-800">{{ $stats['total_days'] }}</p>
                </div>
                <div class="bg-blue-100 p-3 rounded-full">
                    <i class="fas fa-calendar-day text-blue-500 text-2xl"></i>
                </div>
            </div>
        </div>

        <!-- Total Topics -->
        <div class="bg-white rounded-lg shadow-md p-6 border-r-4 border-green-500">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-500 text-sm mb-1">إجمالي الدروس</p>
                    <p class="text-3xl font-bold text-gray-800">{{ $stats['total_topics'] }}</p>
                </div>
                <div class="bg-green-100 p-3 rounded-full">
                    <i class="fas fa-book text-green-500 text-2xl"></i>
                </div>
            </div>
        </div>

        <!-- Weekly Rewards -->
        <div class="bg-white rounded-lg shadow-md p-6 border-r-4 border-yellow-500">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-500 text-sm mb-1">المكافآت الأسبوعية</p>
                    <p class="text-3xl font-bold text-gray-800">{{ $stats['total_rewards'] }}</p>
                </div>
                <div class="bg-yellow-100 p-3 rounded-full">
                    <i class="fas fa-gift text-yellow-500 text-2xl"></i>
                </div>
            </div>
        </div>

        <!-- Users with Progress -->
        <div class="bg-white rounded-lg shadow-md p-6 border-r-4 border-purple-500">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-500 text-sm mb-1">المستخدمون النشطون</p>
                    <p class="text-3xl font-bold text-gray-800">{{ $stats['users_with_progress'] }}</p>
                </div>
                <div class="bg-purple-100 p-3 rounded-full">
                    <i class="fas fa-users text-purple-500 text-2xl"></i>
                </div>
            </div>
        </div>

        <!-- Completed Topics -->
        <div class="bg-white rounded-lg shadow-md p-6 border-r-4 border-teal-500">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-500 text-sm mb-1">الدروس المكتملة</p>
                    <p class="text-3xl font-bold text-gray-800">{{ $stats['completed_topics'] }}</p>
                </div>
                <div class="bg-teal-100 p-3 rounded-full">
                    <i class="fas fa-check-circle text-teal-500 text-2xl"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Quick Links -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <a href="{{ route('admin.bac-study-schedule.days') }}{{ $streamId ? '?stream_id='.$streamId : '' }}" class="bg-gradient-to-br from-blue-500 to-blue-600 text-white rounded-lg shadow-lg p-6 hover:shadow-xl transition-shadow">
            <div class="flex items-center">
                <div class="bg-white bg-opacity-20 p-3 rounded-full mr-4">
                    <i class="fas fa-calendar-alt text-2xl"></i>
                </div>
                <div>
                    <h3 class="text-lg font-semibold mb-1">إدارة الأيام</h3>
                    <p class="text-blue-100 text-sm">عرض وتعديل أيام المراجعة</p>
                </div>
            </div>
        </a>

        <a href="{{ route('admin.bac-study-schedule.rewards') }}{{ $streamId ? '?stream_id='.$streamId : '' }}" class="bg-gradient-to-br from-yellow-500 to-orange-500 text-white rounded-lg shadow-lg p-6 hover:shadow-xl transition-shadow">
            <div class="flex items-center">
                <div class="bg-white bg-opacity-20 p-3 rounded-full mr-4">
                    <i class="fas fa-gift text-2xl"></i>
                </div>
                <div>
                    <h3 class="text-lg font-semibold mb-1">المكافآت الأسبوعية</h3>
                    <p class="text-yellow-100 text-sm">إدارة مكافآت الأفلام</p>
                </div>
            </div>
        </a>

        <a href="{{ route('admin.bac-study-schedule.progress') }}{{ $streamId ? '?stream_id='.$streamId : '' }}" class="bg-gradient-to-br from-purple-500 to-purple-600 text-white rounded-lg shadow-lg p-6 hover:shadow-xl transition-shadow">
            <div class="flex items-center">
                <div class="bg-white bg-opacity-20 p-3 rounded-full mr-4">
                    <i class="fas fa-chart-line text-2xl"></i>
                </div>
                <div>
                    <h3 class="text-lg font-semibold mb-1">تقدم المستخدمين</h3>
                    <p class="text-purple-100 text-sm">متابعة تقدم الطلاب</p>
                </div>
            </div>
        </a>

        <a href="{{ route('admin.bac-study-schedule.rewards.create') }}" class="bg-gradient-to-br from-green-500 to-green-600 text-white rounded-lg shadow-lg p-6 hover:shadow-xl transition-shadow">
            <div class="flex items-center">
                <div class="bg-white bg-opacity-20 p-3 rounded-full mr-4">
                    <i class="fas fa-plus text-2xl"></i>
                </div>
                <div>
                    <h3 class="text-lg font-semibold mb-1">إضافة مكافأة</h3>
                    <p class="text-green-100 text-sm">إنشاء مكافأة جديدة</p>
                </div>
            </div>
        </a>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Empty Days Warning -->
        @if(count($emptyDays) > 0)
        <div class="bg-white rounded-lg shadow-md overflow-hidden">
            <div class="bg-gradient-to-r from-red-500 to-red-600 px-6 py-4">
                <h2 class="text-xl font-semibold text-white">
                    <i class="fas fa-exclamation-triangle mr-2"></i>
                    أيام بدون محتوى
                </h2>
            </div>
            <div class="p-6">
                <p class="text-gray-600 mb-4">الأيام التالية لا تحتوي على أي دروس:</p>
                <div class="flex flex-wrap gap-2">
                    @foreach($emptyDays as $dayNum)
                        <a href="{{ route('admin.bac-study-schedule.days') }}?stream_id={{ $streamId }}&week={{ ceil($dayNum/7) }}"
                           class="px-3 py-1 bg-red-100 text-red-800 rounded-full text-sm hover:bg-red-200 transition-colors">
                            اليوم {{ $dayNum }}
                        </a>
                    @endforeach
                </div>
            </div>
        </div>
        @endif

        <!-- Recent Progress -->
        <div class="bg-white rounded-lg shadow-md overflow-hidden {{ count($emptyDays) == 0 ? 'lg:col-span-2' : '' }}">
            <div class="bg-gradient-to-r from-green-500 to-green-600 px-6 py-4">
                <h2 class="text-xl font-semibold text-white">آخر النشاطات</h2>
            </div>
            <div class="p-6">
                @if($recentProgress->count() > 0)
                    <div class="space-y-4">
                        @foreach($recentProgress as $progress)
                            <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                                <div class="flex-1">
                                    <h3 class="font-semibold text-gray-800">{{ $progress->user->name }}</h3>
                                    <p class="text-sm text-gray-600">
                                        أكمل: {{ $progress->topic->topic_ar }}
                                    </p>
                                    <p class="text-xs text-gray-500 mt-1">
                                        <span class="inline-flex items-center px-2 py-0.5 rounded bg-blue-100 text-blue-800">
                                            اليوم {{ $progress->topic->daySubject->studyDay->day_number }}
                                        </span>
                                        <span class="mr-2">{{ $progress->topic->daySubject->subject->name_ar ?? 'N/A' }}</span>
                                    </p>
                                </div>
                                <div class="text-left">
                                    <span class="text-xs text-gray-500">
                                        {{ $progress->completed_at ? $progress->completed_at->diffForHumans() : '-' }}
                                    </span>
                                </div>
                            </div>
                        @endforeach
                    </div>
                @else
                    <p class="text-gray-500 text-center py-8">لا توجد نشاطات حتى الآن</p>
                @endif
            </div>
        </div>
    </div>

@endsection
