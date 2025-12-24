@extends('layouts.admin')

@section('title', 'تفاصيل الجدول الدراسي')
@section('page-title', 'تفاصيل الجدول الدراسي #' . $schedule->id)
@section('page-description', $schedule->user->name)

@section('content')
    <!-- Back Button -->
    <div class="mb-6">
        <a href="{{ route('admin.planner.schedules') }}" class="inline-flex items-center px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors">
            <i class="fas fa-arrow-right mr-2"></i>
            العودة للقائمة
        </a>
    </div>

    <!-- Schedule Info -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="text-gray-500 text-sm mb-1">إجمالي الجلسات</div>
            <div class="text-3xl font-bold text-gray-800">{{ $stats['total_sessions'] }}</div>
        </div>
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="text-gray-500 text-sm mb-1">الجلسات المكتملة</div>
            <div class="text-3xl font-bold text-green-600">{{ $stats['completed'] }}</div>
        </div>
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="text-gray-500 text-sm mb-1">الجلسات الفائتة</div>
            <div class="text-3xl font-bold text-red-600">{{ $stats['missed'] }}</div>
        </div>
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="text-gray-500 text-sm mb-1">الجلسات المجدولة</div>
            <div class="text-3xl font-bold text-blue-600">{{ $stats['scheduled'] }}</div>
        </div>
    </div>

    <!-- Schedule Details -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
        <div class="bg-white rounded-lg shadow-md p-6">
            <h3 class="text-lg font-semibold mb-4 text-gray-800">معلومات الجدول</h3>
            <div class="space-y-3">
                <div class="flex justify-between">
                    <span class="text-gray-600">تاريخ البدء:</span>
                    <span class="font-semibold">{{ $schedule->start_date->format('Y/m/d') }}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-600">تاريخ الانتهاء:</span>
                    <span class="font-semibold">{{ $schedule->end_date->format('Y/m/d') }}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-600">نوع الجدول:</span>
                    <span class="font-semibold">{{ $schedule->schedule_type }}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-600">الحالة:</span>
                    <span class="px-2 py-1 text-xs rounded-full
                        @if($schedule->status === 'active') bg-green-100 text-green-800
                        @elseif($schedule->status === 'draft') bg-gray-100 text-gray-800
                        @elseif($schedule->status === 'completed') bg-blue-100 text-blue-800
                        @else bg-yellow-100 text-yellow-800
                        @endif">
                        {{ $schedule->status }}
                    </span>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow-md p-6">
            <h3 class="text-lg font-semibold mb-4 text-gray-800">إحصائيات الدراسة</h3>
            <div class="space-y-3">
                <div class="flex justify-between">
                    <span class="text-gray-600">إجمالي الساعات:</span>
                    <span class="font-semibold">{{ number_format($schedule->total_study_hours, 1) }} ساعة</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-600">المواد المغطاة:</span>
                    <span class="font-semibold">{{ is_array($schedule->subjects_covered) ? count($schedule->subjects_covered) : 0 }} مادة</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-600">درجة الجدوى:</span>
                    <span class="font-semibold">{{ number_format($schedule->feasibility_score * 100, 0) }}%</span>
                </div>
                <div>
                    <div class="w-full bg-gray-200 rounded-full h-2">
                        <div class="bg-green-500 h-2 rounded-full" style="width: {{ $schedule->feasibility_score * 100 }}%"></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow-md p-6">
            <h3 class="text-lg font-semibold mb-4 text-gray-800">معلومات الإنشاء</h3>
            <div class="space-y-3">
                <div class="flex justify-between">
                    <span class="text-gray-600">تاريخ الإنشاء:</span>
                    <span class="font-semibold text-sm">{{ $schedule->created_at->format('Y/m/d H:i') }}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-600">إصدار الخوارزمية:</span>
                    <span class="font-semibold">{{ $schedule->generation_algorithm_version }}</span>
                </div>
                @if($schedule->activated_at)
                <div class="flex justify-between">
                    <span class="text-gray-600">تاريخ التفعيل:</span>
                    <span class="font-semibold text-sm">{{ $schedule->activated_at->format('Y/m/d H:i') }}</span>
                </div>
                @endif
            </div>
        </div>
    </div>

    <!-- Sessions List -->
    <div class="bg-white rounded-lg shadow-md overflow-hidden">
        <div class="bg-gradient-to-r from-blue-500 to-blue-600 px-6 py-4">
            <h2 class="text-xl font-semibold text-white">الجلسات الدراسية ({{ $schedule->studySessions->count() }})</h2>
        </div>

        @if($schedule->studySessions->count() > 0)
            <div class="overflow-x-auto">
                <table class="w-full">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">المادة</th>
                            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">الموعد</th>
                            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">المدة</th>
                            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">النوع</th>
                            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">مستوى الطاقة</th>
                            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">الحالة</th>
                            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">إجراءات</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200">
                        @foreach($schedule->studySessions->sortBy('scheduled_start') as $session)
                            <tr class="hover:bg-gray-50">
                                <td class="px-6 py-4">
                                    <div class="text-sm font-semibold text-gray-900">{{ $session->subject->name }}</div>
                                </td>
                                <td class="px-6 py-4 text-sm text-gray-600">
                                    <div>{{ $session->scheduled_start->format('Y/m/d') }}</div>
                                    <div class="text-xs text-gray-500">{{ $session->scheduled_start->format('H:i') }} - {{ $session->scheduled_end->format('H:i') }}</div>
                                </td>
                                <td class="px-6 py-4 text-sm text-gray-600">
                                    {{ $session->planned_duration_minutes }} دقيقة
                                </td>
                                <td class="px-6 py-4 text-sm text-gray-600">
                                    @if($session->session_type == 'learning')
                                        <span class="text-blue-600">تعلم</span>
                                    @elseif($session->session_type == 'revision')
                                        <span class="text-purple-600">مراجعة</span>
                                    @elseif($session->session_type == 'practice')
                                        <span class="text-green-600">تمرين</span>
                                    @else
                                        <span class="text-red-600">اختبار</span>
                                    @endif
                                </td>
                                <td class="px-6 py-4 text-sm text-gray-600">
                                    <span class="px-2 py-1 rounded-full text-xs
                                        @if($session->required_energy_level == 'high') bg-green-100 text-green-800
                                        @elseif($session->required_energy_level == 'medium') bg-yellow-100 text-yellow-800
                                        @else bg-red-100 text-red-800
                                        @endif">
                                        {{ $session->required_energy_level }}
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    <span class="px-2 py-1 text-xs rounded-full
                                        @if($session->status === 'completed') bg-green-100 text-green-800
                                        @elseif($session->status === 'in_progress') bg-blue-100 text-blue-800
                                        @elseif($session->status === 'missed') bg-red-100 text-red-800
                                        @else bg-gray-100 text-gray-800
                                        @endif">
                                        {{ $session->status }}
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    <a href="{{ route('admin.planner.sessions.show', $session->id) }}" class="text-blue-500 hover:text-blue-700">
                                        <i class="fas fa-eye"></i>
                                    </a>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        @else
            <div class="p-12 text-center">
                <p class="text-gray-500">لا توجد جلسات في هذا الجدول</p>
            </div>
        @endif
    </div>

@endsection
