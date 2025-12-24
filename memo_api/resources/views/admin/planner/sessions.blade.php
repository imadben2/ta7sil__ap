@extends('layouts.admin')

@section('title', 'جلسات الدراسة')
@section('page-title', 'جلسات الدراسة')
@section('page-description', 'متابعة وإدارة جلسات الدراسة للمستخدمين')

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
        <form method="GET" action="{{ route('admin.planner.sessions') }}" class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <!-- Search -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">بحث</label>
                <input type="text" name="search" value="{{ request('search') }}" placeholder="اسم المستخدم" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
            </div>

            <!-- Status Filter -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">الحالة</label>
                <select name="status" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                    <option value="">جميع الحالات</option>
                    <option value="scheduled" {{ request('status') == 'scheduled' ? 'selected' : '' }}>مجدولة</option>
                    <option value="in_progress" {{ request('status') == 'in_progress' ? 'selected' : '' }}>جارية</option>
                    <option value="completed" {{ request('status') == 'completed' ? 'selected' : '' }}>مكتملة</option>
                    <option value="missed" {{ request('status') == 'missed' ? 'selected' : '' }}>فائتة</option>
                </select>
            </div>

            <!-- Date Filter -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">التاريخ</label>
                <input type="date" name="date" value="{{ request('date') }}" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
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

    <!-- Sessions Table -->
    <div class="bg-white rounded-lg shadow-md overflow-hidden">
        @if($sessions->count() > 0)
            <div class="overflow-x-auto">
                <table class="w-full">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">#</th>
                            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">المستخدم</th>
                            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">المادة</th>
                            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">الموعد</th>
                            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">المدة</th>
                            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">النوع</th>
                            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">الحالة</th>
                            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">الإنجاز</th>
                            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">إجراءات</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200">
                        @foreach($sessions as $session)
                            <tr class="hover:bg-gray-50 {{ $session->status == 'in_progress' ? 'bg-blue-50' : '' }}">
                                <td class="px-6 py-4 text-sm text-gray-900">{{ $session->id }}</td>
                                <td class="px-6 py-4">
                                    <div class="text-sm font-semibold text-gray-900">{{ $session->user->name }}</div>
                                    <div class="text-xs text-gray-500">{{ $session->user->email }}</div>
                                </td>
                                <td class="px-6 py-4 text-sm font-semibold text-gray-900">
                                    {{ $session->subject->name }}
                                </td>
                                <td class="px-6 py-4 text-sm text-gray-600">
                                    <div>{{ $session->scheduled_start->format('Y/m/d') }}</div>
                                    <div class="text-xs text-gray-500">
                                        {{ $session->scheduled_start->format('H:i') }} - {{ $session->scheduled_end->format('H:i') }}
                                    </div>
                                </td>
                                <td class="px-6 py-4 text-sm text-gray-600">
                                    <div>{{ $session->planned_duration_minutes }} د</div>
                                    @if($session->actual_duration_minutes)
                                        <div class="text-xs text-gray-500">فعلي: {{ $session->actual_duration_minutes }} د</div>
                                    @endif
                                </td>
                                <td class="px-6 py-4 text-sm">
                                    @if($session->session_type == 'learning')
                                        <span class="text-blue-600">📚 تعلم</span>
                                    @elseif($session->session_type == 'revision')
                                        <span class="text-purple-600">📖 مراجعة</span>
                                    @elseif($session->session_type == 'practice')
                                        <span class="text-green-600">✍️ تمرين</span>
                                    @else
                                        <span class="text-red-600">📝 اختبار</span>
                                    @endif
                                </td>
                                <td class="px-6 py-4">
                                    <span class="px-2 py-1 text-xs rounded-full inline-flex items-center
                                        @if($session->status === 'completed') bg-green-100 text-green-800
                                        @elseif($session->status === 'in_progress') bg-blue-100 text-blue-800
                                        @elseif($session->status === 'missed') bg-red-100 text-red-800
                                        @else bg-gray-100 text-gray-800
                                        @endif">
                                        @if($session->status === 'in_progress')
                                            <span class="w-2 h-2 bg-blue-500 rounded-full animate-pulse mr-1"></span>
                                        @endif
                                        {{ $session->status }}
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    @if($session->completion_percentage)
                                        <div class="flex items-center">
                                            <div class="w-12 bg-gray-200 rounded-full h-2 mr-2">
                                                <div class="bg-green-500 h-2 rounded-full" style="width: {{ $session->completion_percentage }}%"></div>
                                            </div>
                                            <span class="text-xs text-gray-600">{{ $session->completion_percentage }}%</span>
                                        </div>
                                    @else
                                        <span class="text-xs text-gray-400">-</span>
                                    @endif
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

            <!-- Pagination -->
            <div class="px-6 py-4 border-t border-gray-200">
                {{ $sessions->links() }}
            </div>
        @else
            <div class="p-12 text-center">
                <i class="fas fa-book-open text-gray-300 text-6xl mb-4"></i>
                <p class="text-gray-500 text-lg">لا توجد جلسات دراسية</p>
            </div>
        @endif
    </div>

@endsection
