@extends('layouts.admin')

@section('title', 'تقدم المستخدمين')
@section('page-title', 'تقدم المستخدمين')
@section('page-description', 'متابعة تقدم الطلاب في جدول المراجعة')

@section('content')

    <!-- Breadcrumb -->
    <div class="mb-6">
        <a href="{{ route('admin.bac-study-schedule.index') }}" class="text-blue-500 hover:text-blue-700">
            <i class="fas fa-arrow-right ml-2"></i>العودة للوحة التحكم
        </a>
    </div>

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

    <!-- Statistics -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div class="bg-white rounded-lg shadow-md p-6 border-r-4 border-blue-500">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-500 text-sm mb-1">إجمالي الدروس</p>
                    <p class="text-3xl font-bold text-gray-800">{{ $totalTopics }}</p>
                </div>
                <div class="bg-blue-100 p-3 rounded-full">
                    <i class="fas fa-book text-blue-500 text-2xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow-md p-6 border-r-4 border-green-500">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-500 text-sm mb-1">المستخدمون النشطون</p>
                    <p class="text-3xl font-bold text-gray-800">{{ $usersProgress->total() }}</p>
                </div>
                <div class="bg-green-100 p-3 rounded-full">
                    <i class="fas fa-users text-green-500 text-2xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow-md p-6 border-r-4 border-purple-500">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-500 text-sm mb-1">متوسط الإنجاز</p>
                    <p class="text-3xl font-bold text-gray-800">
                        @php
                            $avgCompletion = $usersProgress->count() > 0 && $totalTopics > 0
                                ? round($usersProgress->avg('completed_count') / $totalTopics * 100, 1)
                                : 0;
                        @endphp
                        {{ $avgCompletion }}%
                    </p>
                </div>
                <div class="bg-purple-100 p-3 rounded-full">
                    <i class="fas fa-chart-pie text-purple-500 text-2xl"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Users Progress Table -->
    <div class="bg-white rounded-lg shadow-md overflow-hidden">
        <div class="px-6 py-4 bg-gradient-to-r from-purple-500 to-purple-600">
            <h2 class="text-xl font-semibold text-white">
                <i class="fas fa-chart-line mr-2"></i>
                تقدم المستخدمين
            </h2>
        </div>

        @if($usersProgress->count() > 0)
            <div class="overflow-x-auto">
                <table class="w-full">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-3 text-right text-sm font-semibold text-gray-700">#</th>
                            <th class="px-6 py-3 text-right text-sm font-semibold text-gray-700">المستخدم</th>
                            <th class="px-6 py-3 text-right text-sm font-semibold text-gray-700">البريد الإلكتروني</th>
                            <th class="px-6 py-3 text-right text-sm font-semibold text-gray-700">الدروس المكتملة</th>
                            <th class="px-6 py-3 text-right text-sm font-semibold text-gray-700">نسبة الإنجاز</th>
                            <th class="px-6 py-3 text-right text-sm font-semibold text-gray-700">آخر نشاط</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200">
                        @foreach($usersProgress as $index => $user)
                            @php
                                $percentage = $totalTopics > 0 ? round(($user->completed_count / $totalTopics) * 100, 1) : 0;
                            @endphp
                            <tr class="hover:bg-gray-50">
                                <td class="px-6 py-4 text-sm text-gray-600">
                                    {{ $usersProgress->firstItem() + $index }}
                                </td>
                                <td class="px-6 py-4">
                                    <div class="flex items-center">
                                        <div class="w-10 h-10 bg-gradient-to-br from-blue-500 to-purple-500 rounded-full flex items-center justify-center text-white font-bold">
                                            {{ mb_substr($user->name, 0, 1) }}
                                        </div>
                                        <span class="mr-3 font-medium text-gray-800">{{ $user->name }}</span>
                                    </div>
                                </td>
                                <td class="px-6 py-4 text-sm text-gray-600" dir="ltr">
                                    {{ $user->email }}
                                </td>
                                <td class="px-6 py-4">
                                    <span class="font-semibold text-green-600">{{ $user->completed_count }}</span>
                                    <span class="text-gray-400">/ {{ $totalTopics }}</span>
                                </td>
                                <td class="px-6 py-4">
                                    <div class="flex items-center gap-3">
                                        <div class="flex-1 bg-gray-200 rounded-full h-2.5 max-w-[150px]">
                                            <div class="h-2.5 rounded-full {{ $percentage >= 80 ? 'bg-green-500' : ($percentage >= 50 ? 'bg-yellow-500' : 'bg-blue-500') }}"
                                                 style="width: {{ $percentage }}%"></div>
                                        </div>
                                        <span class="text-sm font-medium {{ $percentage >= 80 ? 'text-green-600' : ($percentage >= 50 ? 'text-yellow-600' : 'text-blue-600') }}">
                                            {{ $percentage }}%
                                        </span>
                                    </div>
                                </td>
                                <td class="px-6 py-4 text-sm text-gray-600">
                                    @if($user->last_activity)
                                        {{ \Carbon\Carbon::parse($user->last_activity)->diffForHumans() }}
                                    @else
                                        -
                                    @endif
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>

            <!-- Pagination -->
            <div class="px-6 py-4 border-t">
                {{ $usersProgress->appends(request()->query())->links() }}
            </div>
        @else
            <div class="p-12 text-center">
                <div class="bg-gray-100 w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-4">
                    <i class="fas fa-users text-gray-400 text-3xl"></i>
                </div>
                <h3 class="text-lg font-medium text-gray-800 mb-2">لا يوجد تقدم بعد</h3>
                <p class="text-gray-500">لم يبدأ أي مستخدم في المراجعة حتى الآن</p>
            </div>
        @endif
    </div>

@endsection
