@extends('layouts.admin')

@section('title', $academicPhase->name_ar)

@section('content')
<div class="p-6 bg-gray-50 min-h-screen">
    <!-- Header -->
    <div class="mb-8">
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-3xl font-bold text-gray-900 flex items-center">
                    <i class="fas fa-layer-group text-purple-600 mr-3"></i>
                    {{ $academicPhase->name_ar }}
                </h1>
                <p class="text-gray-600 mt-2">عرض تفاصيل المرحلة الدراسية</p>
            </div>
            <div class="flex gap-3">
                <a href="{{ route('admin.academic-phases.index') }}" class="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors flex items-center gap-2">
                    <i class="fas fa-arrow-right"></i>
                    <span>رجوع</span>
                </a>
                <a href="{{ route('admin.academic-phases.edit', $academicPhase->id) }}" class="px-4 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700 transition-colors flex items-center gap-2">
                    <i class="fas fa-edit"></i>
                    <span>تعديل</span>
                </a>
            </div>
        </div>
    </div>

    <!-- Phase Info Card -->
    <div class="bg-white rounded-xl shadow-md p-6 mb-6">
        <h2 class="text-xl font-bold text-gray-800 mb-4 flex items-center">
            <i class="fas fa-info-circle text-blue-600 mr-2"></i>
            معلومات المرحلة
        </h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
                <label class="text-sm font-semibold text-gray-600">الاسم</label>
                <p class="text-lg font-bold text-gray-900 mt-1">{{ $academicPhase->name_ar }}</p>
            </div>
            <div>
                <label class="text-sm font-semibold text-gray-600">المعرف (Slug)</label>
                <p class="text-lg text-gray-700 mt-1 font-mono">{{ $academicPhase->slug }}</p>
            </div>
            <div>
                <label class="text-sm font-semibold text-gray-600">الترتيب</label>
                <p class="text-lg font-bold text-purple-600 mt-1">{{ $academicPhase->order }}</p>
            </div>
        </div>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
        <div class="bg-gradient-to-l from-blue-500 to-blue-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between mb-4">
                <div class="bg-white/20 p-3 rounded-lg">
                    <i class="fas fa-calendar-alt text-2xl"></i>
                </div>
                <span class="text-sm opacity-80">السنوات الدراسية</span>
            </div>
            <div class="text-4xl font-bold">{{ $academicPhase->academicYears->count() }}</div>
            <p class="text-sm mt-2 opacity-80">سنة دراسية في هذه المرحلة</p>
        </div>

        <div class="bg-gradient-to-l from-green-500 to-green-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between mb-4">
                <div class="bg-white/20 p-3 rounded-lg">
                    <i class="fas fa-stream text-2xl"></i>
                </div>
                <span class="text-sm opacity-80">الشعب الدراسية</span>
            </div>
            <div class="text-4xl font-bold">{{ $academicPhase->academicStreams->count() }}</div>
            <p class="text-sm mt-2 opacity-80">شعبة دراسية في هذه المرحلة</p>
        </div>
    </div>

    <!-- Academic Years Table -->
    @if($academicPhase->academicYears->isNotEmpty())
    <div class="bg-white rounded-xl shadow-md mb-6 overflow-hidden">
        <div class="p-6 border-b border-gray-200">
            <h2 class="text-xl font-bold text-gray-800 flex items-center">
                <i class="fas fa-calendar-alt text-blue-600 mr-2"></i>
                السنوات الدراسية
            </h2>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-6 py-3 text-right text-xs font-bold text-gray-700 uppercase">الترتيب</th>
                        <th class="px-6 py-3 text-right text-xs font-bold text-gray-700 uppercase">اسم السنة</th>
                        <th class="px-6 py-3 text-right text-xs font-bold text-gray-700 uppercase">المستوى</th>
                        <th class="px-6 py-3 text-right text-xs font-bold text-gray-700 uppercase">الشعب</th>
                        <th class="px-6 py-3 text-right text-xs font-bold text-gray-700 uppercase">المواد</th>
                        <th class="px-6 py-3 text-right text-xs font-bold text-gray-700 uppercase">الحالة</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                    @foreach($academicPhase->academicYears as $year)
                    <tr class="hover:bg-gray-50">
                        <td class="px-6 py-4">{{ $year->order }}</td>
                        <td class="px-6 py-4 font-semibold">{{ $year->name_ar }}</td>
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
                                <span class="bg-green-100 text-green-800 px-2 py-1 rounded-full text-xs font-semibold">نشط</span>
                            @else
                                <span class="bg-gray-100 text-gray-800 px-2 py-1 rounded-full text-xs font-semibold">غير نشط</span>
                            @endif
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
    @endif

    <!-- Academic Streams Table -->
    @if($academicPhase->academicStreams->isNotEmpty())
    <div class="bg-white rounded-xl shadow-md overflow-hidden">
        <div class="p-6 border-b border-gray-200">
            <h2 class="text-xl font-bold text-gray-800 flex items-center">
                <i class="fas fa-stream text-green-600 mr-2"></i>
                الشعب الدراسية
            </h2>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-6 py-3 text-right text-xs font-bold text-gray-700 uppercase">الترتيب</th>
                        <th class="px-6 py-3 text-right text-xs font-bold text-gray-700 uppercase">اسم الشعبة</th>
                        <th class="px-6 py-3 text-right text-xs font-bold text-gray-700 uppercase">السنة</th>
                        <th class="px-6 py-3 text-right text-xs font-bold text-gray-700 uppercase">المواد</th>
                        <th class="px-6 py-3 text-right text-xs font-bold text-gray-700 uppercase">الحالة</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                    @foreach($academicPhase->academicStreams as $stream)
                    <tr class="hover:bg-gray-50">
                        <td class="px-6 py-4">{{ $stream->order }}</td>
                        <td class="px-6 py-4 font-semibold">{{ $stream->name_ar }}</td>
                        <td class="px-6 py-4">{{ $stream->academicYear->name_ar ?? 'N/A' }}</td>
                        <td class="px-6 py-4">
                            <span class="bg-blue-100 text-blue-800 px-2 py-1 rounded-full text-sm">
                                {{ $stream->subjects_count }}
                            </span>
                        </td>
                        <td class="px-6 py-4">
                            @if($stream->is_active)
                                <span class="bg-green-100 text-green-800 px-2 py-1 rounded-full text-xs font-semibold">نشط</span>
                            @else
                                <span class="bg-gray-100 text-gray-800 px-2 py-1 rounded-full text-xs font-semibold">غير نشط</span>
                            @endif
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
    @endif
</div>
@endsection
