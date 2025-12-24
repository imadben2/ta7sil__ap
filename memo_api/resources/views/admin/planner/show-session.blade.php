@extends('layouts.admin')

@section('title', 'تفاصيل الجلسة')
@section('page-title', 'تفاصيل الجلسة #' . $session->id)
@section('page-description', $session->user->name . ' - ' . $session->subject->name)

@section('content')
    <!-- Back Button -->
    <div class="mb-6">
        <a href="{{ route('admin.planner.sessions') }}" class="inline-flex items-center px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors">
            <i class="fas fa-arrow-right mr-2"></i>
            العودة
        </a>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <div class="bg-white rounded-lg shadow-md p-6">
            <h3 class="text-lg font-semibold mb-4">معلومات الجلسة</h3>
            <div class="space-y-3">
                <div class="flex justify-between">
                    <span class="text-gray-600">الموعد المجدول:</span>
                    <span class="font-semibold">{{ $session->scheduled_start->format('Y/m/d H:i') }}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-600">المدة المخططة:</span>
                    <span class="font-semibold">{{ $session->planned_duration_minutes }} دقيقة</span>
                </div>
                @if($session->actual_start)
                <div class="flex justify-between">
                    <span class="text-gray-600">البداية الفعلية:</span>
                    <span class="font-semibold">{{ $session->actual_start->format('Y/m/d H:i') }}</span>
                </div>
                @endif
                @if($session->actual_end)
                <div class="flex justify-between">
                    <span class="text-gray-600">النهاية الفعلية:</span>
                    <span class="font-semibold">{{ $session->actual_end->format('Y/m/d H:i') }}</span>
                </div>
                @endif
                @if($session->actual_duration_minutes)
                <div class="flex justify-between">
                    <span class="text-gray-600">المدة الفعلية:</span>
                    <span class="font-semibold">{{ $session->actual_duration_minutes }} دقيقة</span>
                </div>
                @endif
            </div>
        </div>

        <div class="bg-white rounded-lg shadow-md p-6">
            <h3 class="text-lg font-semibold mb-4">التقييم والأداء</h3>
            <div class="space-y-3">
                <div class="flex justify-between">
                    <span class="text-gray-600">الحالة:</span>
                    <span class="px-2 py-1 text-xs rounded-full
                        @if($session->status === 'completed') bg-green-100 text-green-800
                        @elseif($session->status === 'in_progress') bg-blue-100 text-blue-800
                        @elseif($session->status === 'missed') bg-red-100 text-red-800
                        @else bg-gray-100 text-gray-800
                        @endif">
                        {{ $session->status }}
                    </span>
                </div>
                @if($session->completion_percentage)
                <div>
                    <div class="flex justify-between mb-1">
                        <span class="text-gray-600">نسبة الإنجاز:</span>
                        <span class="font-semibold">{{ $session->completion_percentage }}%</span>
                    </div>
                    <div class="w-full bg-gray-200 rounded-full h-2">
                        <div class="bg-green-500 h-2 rounded-full" style="width: {{ $session->completion_percentage }}%"></div>
                    </div>
                </div>
                @endif
                @if($session->focus_score)
                <div class="flex justify-between">
                    <span class="text-gray-600">درجة التركيز:</span>
                    <span class="font-semibold">{{ $session->focus_score }}/10</span>
                </div>
                @endif
                @if($session->difficulty_rating)
                <div class="flex justify-between">
                    <span class="text-gray-600">مستوى الصعوبة:</span>
                    <span class="font-semibold">{{ $session->difficulty_rating }}/10</span>
                </div>
                @endif
            </div>
        </div>
    </div>

    @if($session->notes)
    <div class="bg-white rounded-lg shadow-md p-6 mb-6">
        <h3 class="text-lg font-semibold mb-2">ملاحظات</h3>
        <p class="text-gray-700">{{ $session->notes }}</p>
    </div>
    @endif

    @if($session->activities->count() > 0)
    <div class="bg-white rounded-lg shadow-md overflow-hidden">
        <div class="bg-gradient-to-r from-purple-500 to-purple-600 px-6 py-4">
            <h2 class="text-xl font-semibold text-white">سجل النشاط</h2>
        </div>
        <div class="p-6">
            <div class="space-y-4">
                @foreach($session->activities->sortBy('activity_time') as $activity)
                    <div class="flex items-start">
                        <div class="flex-shrink-0 mr-4">
                            <div class="w-10 h-10 rounded-full flex items-center justify-center
                                @if($activity->activity_type === 'start') bg-green-100
                                @elseif($activity->activity_type === 'pause') bg-yellow-100
                                @elseif($activity->activity_type === 'resume') bg-blue-100
                                @else bg-purple-100
                                @endif">
                                <i class="fas
                                    @if($activity->activity_type === 'start') fa-play text-green-600
                                    @elseif($activity->activity_type === 'pause') fa-pause text-yellow-600
                                    @elseif($activity->activity_type === 'resume') fa-play-circle text-blue-600
                                    @else fa-check text-purple-600
                                    @endif"></i>
                            </div>
                        </div>
                        <div class="flex-1">
                            <p class="font-semibold text-gray-900">{{ ucfirst($activity->activity_type) }}</p>
                            <p class="text-sm text-gray-600">{{ $activity->activity_time->format('Y/m/d H:i:s') }}</p>
                            @if($activity->metadata && isset($activity->metadata['reason']))
                                <p class="text-sm text-gray-500 mt-1">{{ $activity->metadata['reason'] }}</p>
                            @endif
                        </div>
                    </div>
                @endforeach
            </div>
        </div>
    </div>
    @endif

@endsection
