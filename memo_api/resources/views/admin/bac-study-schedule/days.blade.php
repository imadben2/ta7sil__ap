@extends('layouts.admin')

@section('title', 'أيام المراجعة')
@section('page-title', 'أيام المراجعة')
@section('page-description', 'عرض وإدارة أيام جدول المراجعة')

@section('content')

    <!-- Filters -->
    <div class="bg-white rounded-lg shadow-md p-4 mb-6">
        <form method="GET" class="flex flex-wrap items-center gap-4">
            <div class="flex items-center gap-2">
                <label class="font-semibold text-gray-700">الشعبة:</label>
                <select name="stream_id" onchange="this.form.submit()" class="border rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500">
                    <option value="">جميع الشعب</option>
                    @foreach($streams as $stream)
                        <option value="{{ $stream->id }}" {{ $streamId == $stream->id ? 'selected' : '' }}>
                            {{ $stream->name_ar }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="flex items-center gap-2">
                <label class="font-semibold text-gray-700">الأسبوع:</label>
                <select name="week" onchange="this.form.submit()" class="border rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500">
                    <option value="">جميع الأسابيع</option>
                    @foreach($weeks as $week)
                        <option value="{{ $week }}" {{ $weekNumber == $week ? 'selected' : '' }}>
                            الأسبوع {{ $week }} (أيام {{ (($week-1)*7)+1 }}-{{ $week*7 }})
                        </option>
                    @endforeach
                </select>
            </div>
            @if($streamId || $weekNumber)
                <a href="{{ route('admin.bac-study-schedule.days') }}" class="text-red-500 hover:text-red-700">
                    <i class="fas fa-times"></i> إزالة الفلاتر
                </a>
            @endif
        </form>
    </div>

    <!-- Days Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 mb-6">
        @foreach($days as $day)
            <div class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow">
                <div class="px-4 py-3 {{ $day->day_type === 'review' ? 'bg-gradient-to-r from-purple-500 to-purple-600' : ($day->day_type === 'reward' ? 'bg-gradient-to-r from-yellow-500 to-orange-500' : 'bg-gradient-to-r from-blue-500 to-blue-600') }}">
                    <div class="flex items-center justify-between">
                        <h3 class="text-lg font-bold text-white">اليوم {{ $day->day_number }}</h3>
                        <span class="px-2 py-1 text-xs rounded-full bg-white bg-opacity-20 text-white">
                            الأسبوع {{ $day->week_number }}
                        </span>
                    </div>
                    @if($day->title_ar)
                        <p class="text-white text-opacity-80 text-sm mt-1">{{ $day->title_ar }}</p>
                    @endif
                </div>
                <div class="p-4">
                    <div class="flex items-center justify-between mb-3">
                        <span class="text-sm text-gray-500">
                            @if($day->day_type === 'study')
                                <i class="fas fa-book-open text-blue-500"></i> دراسة
                            @elseif($day->day_type === 'review')
                                <i class="fas fa-redo text-purple-500"></i> مراجعة
                            @else
                                <i class="fas fa-gift text-yellow-500"></i> مكافأة
                            @endif
                        </span>
                        <span class="text-sm {{ $day->is_active ? 'text-green-500' : 'text-red-500' }}">
                            <i class="fas {{ $day->is_active ? 'fa-check-circle' : 'fa-times-circle' }}"></i>
                            {{ $day->is_active ? 'نشط' : 'معطل' }}
                        </span>
                    </div>

                    @if($day->daySubjects->count() > 0)
                        <div class="space-y-2 mb-4">
                            @foreach($day->daySubjects as $daySubject)
                                <div class="flex items-center justify-between text-sm">
                                    <span class="text-gray-700">{{ $daySubject->subject->name_ar ?? 'N/A' }}</span>
                                    <span class="bg-gray-100 text-gray-600 px-2 py-0.5 rounded text-xs">
                                        {{ $daySubject->topics->count() }} درس
                                    </span>
                                </div>
                            @endforeach
                        </div>
                    @else
                        <div class="bg-red-50 text-red-600 text-sm p-2 rounded mb-4 text-center">
                            <i class="fas fa-exclamation-triangle mr-1"></i>
                            لا يوجد محتوى
                        </div>
                    @endif

                    <div class="flex gap-2">
                        <a href="{{ route('admin.bac-study-schedule.days.show', $day->id) }}"
                           class="flex-1 text-center bg-blue-500 text-white px-3 py-2 rounded-lg hover:bg-blue-600 transition-colors text-sm">
                            <i class="fas fa-eye"></i> عرض
                        </a>
                        <a href="{{ route('admin.bac-study-schedule.days.edit', $day->id) }}"
                           class="flex-1 text-center bg-yellow-500 text-white px-3 py-2 rounded-lg hover:bg-yellow-600 transition-colors text-sm">
                            <i class="fas fa-edit"></i> تعديل
                        </a>
                    </div>
                </div>
            </div>
        @endforeach
    </div>

    @if($days->isEmpty())
        <div class="bg-white rounded-lg shadow-md p-8 text-center">
            <i class="fas fa-calendar-times text-gray-300 text-6xl mb-4"></i>
            <p class="text-gray-500 text-lg">لا توجد أيام للعرض</p>
            <p class="text-gray-400 text-sm mt-2">قم بتشغيل Seeder لإنشاء الجدول</p>
        </div>
    @endif

    <!-- Pagination -->
    <div class="mt-6">
        {{ $days->appends(request()->query())->links() }}
    </div>

@endsection
