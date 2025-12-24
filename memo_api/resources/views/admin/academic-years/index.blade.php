@extends('layouts.admin')

@section('title', 'إدارة السنوات الدراسية')

@section('content')
<div class="p-6 bg-gray-50 min-h-screen">
    <div class="mb-8">
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-3xl font-bold text-gray-900 flex items-center">
                    <i class="fas fa-calendar-alt text-blue-600 mr-3"></i>
                    السنوات الدراسية
                </h1>
                <p class="text-gray-600 mt-2">إدارة السنوات الدراسية لكل مرحلة</p>
            </div>
            <a href="{{ route('admin.academic-years.create') }}" class="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors flex items-center gap-2 shadow-md">
                <i class="fas fa-plus"></i>
                <span>إضافة سنة جديدة</span>
            </a>
        </div>
    </div>

    @if(session('success'))
        <div class="mb-6 bg-green-50 border-r-4 border-green-500 p-4 rounded-lg">
            <div class="flex items-center">
                <i class="fas fa-check-circle text-green-500 text-xl mr-3"></i>
                <p class="text-green-700 font-semibold">{{ session('success') }}</p>
            </div>
        </div>
    @endif

    @if(session('error'))
        <div class="mb-6 bg-red-50 border-r-4 border-red-500 p-4 rounded-lg">
            <div class="flex items-center">
                <i class="fas fa-exclamation-circle text-red-500 text-xl mr-3"></i>
                <p class="text-red-700 font-semibold">{{ session('error') }}</p>
            </div>
        </div>
    @endif

    <!-- Filter -->
    <div class="bg-white rounded-lg shadow p-4 mb-6">
        <form method="GET" action="{{ route('admin.academic-years.index') }}" class="flex gap-4">
            <select name="phase_id" class="px-4 py-2 border border-gray-300 rounded-lg">
                <option value="">كل المراحل</option>
                @foreach($phases as $phase)
                    <option value="{{ $phase->id }}" {{ request('phase_id') == $phase->id ? 'selected' : '' }}>
                        {{ $phase->name_ar }}
                    </option>
                @endforeach
            </select>
            <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
                <i class="fas fa-filter mr-2"></i>تصفية
            </button>
        </form>
    </div>

    <div class="bg-white rounded-xl shadow-md overflow-hidden">
        <div class="p-6 border-b">
            <h2 class="text-xl font-bold">قائمة السنوات الدراسية ({{ $years->count() }})</h2>
        </div>
        
        @if($years->isEmpty())
            <div class="p-12 text-center">
                <i class="fas fa-calendar-alt text-6xl text-gray-300 mb-4"></i>
                <h3 class="text-xl font-semibold text-gray-700 mb-2">لا توجد سنوات دراسية</h3>
                <a href="{{ route('admin.academic-years.create') }}" class="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 mt-4">
                    <i class="fas fa-plus mr-2"></i>إضافة سنة
                </a>
            </div>
        @else
            <table class="w-full">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-6 py-3 text-right text-xs font-bold uppercase">الترتيب</th>
                        <th class="px-6 py-3 text-right text-xs font-bold uppercase">السنة</th>
                        <th class="px-6 py-3 text-right text-xs font-bold uppercase">المرحلة</th>
                        <th class="px-6 py-3 text-right text-xs font-bold uppercase">المستوى</th>
                        <th class="px-6 py-3 text-right text-xs font-bold uppercase">الشعب</th>
                        <th class="px-6 py-3 text-right text-xs font-bold uppercase">المواد</th>
                        <th class="px-6 py-3 text-right text-xs font-bold uppercase">الحالة</th>
                        <th class="px-6 py-3 text-right text-xs font-bold uppercase">الإجراءات</th>
                    </tr>
                </thead>
                <tbody class="divide-y">
                    @foreach($years as $year)
                    <tr class="hover:bg-gray-50">
                        <td class="px-6 py-4">{{ $year->order }}</td>
                        <td class="px-6 py-4 font-semibold">{{ $year->name_ar }}</td>
                        <td class="px-6 py-4">{{ $year->academicPhase->name_ar }}</td>
                        <td class="px-6 py-4">{{ $year->level_number }}</td>
                        <td class="px-6 py-4">
                            <span class="bg-green-100 text-green-800 px-2 py-1 rounded-full text-sm">
                                {{ $year->academic_streams_count }}
                            </span>
                        </td>
                        <td class="px-6 py-4">
                            <span class="bg-blue-100 text-blue-800 px-2 py-1 rounded-full text-sm">
                                {{ $year->subjects_count }}
                            </span>
                        </td>
                        <td class="px-6 py-4">
                            @if($year->is_active)
                                <span class="bg-green-100 text-green-800 px-2 py-1 rounded-full text-xs">نشط</span>
                            @else
                                <span class="bg-gray-100 text-gray-800 px-2 py-1 rounded-full text-xs">غير نشط</span>
                            @endif
                        </td>
                        <td class="px-6 py-4">
                            <div class="flex gap-2">
                                <a href="{{ route('admin.academic-years.show', $year->id) }}" class="px-3 py-1.5 bg-blue-600 text-white rounded-lg hover:bg-blue-700 text-sm">
                                    <i class="fas fa-eye mr-1"></i>عرض
                                </a>
                                <a href="{{ route('admin.academic-years.edit', $year->id) }}" class="px-3 py-1.5 bg-orange-600 text-white rounded-lg hover:bg-orange-700 text-sm">
                                    <i class="fas fa-edit mr-1"></i>تعديل
                                </a>
                                <form action="{{ route('admin.academic-years.destroy', $year->id) }}" method="POST" onsubmit="return confirm('هل أنت متأكد؟')">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="px-3 py-1.5 bg-red-600 text-white rounded-lg hover:bg-red-700 text-sm">
                                        <i class="fas fa-trash mr-1"></i>حذف
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        @endif
    </div>
</div>
@endsection
