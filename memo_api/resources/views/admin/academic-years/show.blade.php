@extends('layouts.admin')

@section('title', $academicYear->name_ar)

@section('content')
<div class="p-6 bg-gray-50 min-h-screen">
    <!-- Header -->
    <div class="mb-8">
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-3xl font-bold text-gray-900 flex items-center">
                    <i class="fas fa-calendar-alt text-blue-600 mr-3"></i>
                    {{ $academicYear->name_ar }}
                </h1>
                <p class="text-gray-600 mt-2">عرض تفاصيل السنة الدراسية</p>
            </div>
            <div class="flex gap-3">
                <a href="{{ route('admin.academic-years.index') }}" class="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors flex items-center gap-2">
                    <i class="fas fa-arrow-right"></i>
                    <span>رجوع</span>
                </a>
                <a href="{{ route('admin.academic-years.edit', $academicYear->id) }}" class="px-4 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700 transition-colors flex items-center gap-2">
                    <i class="fas fa-edit"></i>
                    <span>تعديل</span>
                </a>
            </div>
        </div>
    </div>

    <!-- Year Info Card -->
    <div class="bg-white rounded-xl shadow-md p-6 mb-6">
        <h2 class="text-xl font-bold text-gray-800 mb-4 flex items-center">
            <i class="fas fa-info-circle text-blue-600 mr-2"></i>
            معلومات السنة
        </h2>
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
            <div>
                <label class="text-sm font-semibold text-gray-600">الاسم</label>
                <p class="text-lg font-bold text-gray-900 mt-1">{{ $academicYear->name_ar }}</p>
            </div>
            <div>
                <label class="text-sm font-semibold text-gray-600">المرحلة الدراسية</label>
                <p class="text-lg text-purple-600 font-semibold mt-1">{{ $academicYear->academicPhase->name_ar }}</p>
            </div>
            <div>
                <label class="text-sm font-semibold text-gray-600">رقم المستوى</label>
                <p class="text-lg font-bold text-blue-600 mt-1">{{ $academicYear->level_number }}</p>
            </div>
            <div>
                <label class="text-sm font-semibold text-gray-600">الترتيب</label>
                <p class="text-lg font-bold text-gray-700 mt-1">{{ $academicYear->order }}</p>
            </div>
            <div>
                <label class="text-sm font-semibold text-gray-600">الحالة</label>
                <div class="mt-1">
                    @if($academicYear->is_active)
                        <span class="bg-green-100 text-green-800 px-3 py-1 rounded-full text-sm font-semibold">نشط</span>
                    @else
                        <span class="bg-gray-100 text-gray-800 px-3 py-1 rounded-full text-sm font-semibold">غير نشط</span>
                    @endif
                </div>
            </div>
        </div>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
        <div class="bg-gradient-to-l from-green-500 to-green-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between mb-4">
                <div class="bg-white/20 p-3 rounded-lg">
                    <i class="fas fa-stream text-2xl"></i>
                </div>
                <span class="text-sm opacity-80">الشعب الدراسية</span>
            </div>
            <div class="text-4xl font-bold">{{ $academicYear->academicStreams->count() }}</div>
            <p class="text-sm mt-2 opacity-80">شعبة دراسية في هذه السنة</p>
        </div>

        <div class="bg-gradient-to-l from-indigo-500 to-indigo-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between mb-4">
                <div class="bg-white/20 p-3 rounded-lg">
                    <i class="fas fa-book text-2xl"></i>
                </div>
                <span class="text-sm opacity-80">المواد الدراسية</span>
            </div>
            <div class="text-4xl font-bold">{{ $academicYear->subjects->count() }}</div>
            <p class="text-sm mt-2 opacity-80">مادة دراسية في هذه السنة</p>
        </div>
    </div>

    <!-- Academic Streams Table -->
    @if($academicYear->academicStreams->isNotEmpty())
    <div class="bg-white rounded-xl shadow-md mb-6 overflow-hidden">
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
                        <th class="px-6 py-3 text-right text-xs font-bold text-gray-700 uppercase">الوصف</th>
                        <th class="px-6 py-3 text-right text-xs font-bold text-gray-700 uppercase">المواد</th>
                        <th class="px-6 py-3 text-right text-xs font-bold text-gray-700 uppercase">الحالة</th>
                        <th class="px-6 py-3 text-right text-xs font-bold text-gray-700 uppercase">الإجراءات</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                    @foreach($academicYear->academicStreams as $stream)
                    <tr class="hover:bg-gray-50">
                        <td class="px-6 py-4">{{ $stream->order }}</td>
                        <td class="px-6 py-4 font-semibold">{{ $stream->name_ar }}</td>
                        <td class="px-6 py-4 text-gray-600 text-sm">{{ Str::limit($stream->description_ar, 50) }}</td>
                        <td class="px-6 py-4">
                            <span class="bg-indigo-100 text-indigo-800 px-2 py-1 rounded-full text-sm">
                                {{ $stream->subjects_count ?? 0 }}
                            </span>
                        </td>
                        <td class="px-6 py-4">
                            @if($stream->is_active)
                                <span class="bg-green-100 text-green-800 px-2 py-1 rounded-full text-xs font-semibold">نشط</span>
                            @else
                                <span class="bg-gray-100 text-gray-800 px-2 py-1 rounded-full text-xs font-semibold">غير نشط</span>
                            @endif
                        </td>
                        <td class="px-6 py-4">
                            <a href="{{ route('admin.academic-streams.show', $stream->id) }}" class="text-blue-600 hover:text-blue-800">
                                <i class="fas fa-eye"></i>
                            </a>
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
    @else
    <div class="bg-yellow-50 border-r-4 border-yellow-400 p-4 rounded-lg mb-6">
        <div class="flex">
            <i class="fas fa-exclamation-triangle text-yellow-400 text-xl mr-3"></i>
            <div>
                <h3 class="text-yellow-800 font-semibold">لا توجد شعب دراسية</h3>
                <p class="text-sm text-yellow-700 mt-1">لم يتم إضافة أي شعب دراسية لهذه السنة بعد</p>
            </div>
        </div>
    </div>
    @endif

    <!-- Subjects Table -->
    @if($academicYear->subjects->isNotEmpty())
    <div class="bg-white rounded-xl shadow-md overflow-hidden">
        <div class="p-6 border-b border-gray-200">
            <h2 class="text-xl font-bold text-gray-800 flex items-center">
                <i class="fas fa-book text-indigo-600 mr-2"></i>
                المواد الدراسية
            </h2>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-6 py-3 text-right text-xs font-bold text-gray-700 uppercase">اسم المادة</th>
                        <th class="px-6 py-3 text-right text-xs font-bold text-gray-700 uppercase">الشعبة</th>
                        <th class="px-6 py-3 text-right text-xs font-bold text-gray-700 uppercase">المعامل</th>
                        <th class="px-6 py-3 text-right text-xs font-bold text-gray-700 uppercase">الحالة</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                    @foreach($academicYear->subjects as $subject)
                    <tr class="hover:bg-gray-50">
                        <td class="px-6 py-4 font-semibold">{{ $subject->name_ar }}</td>
                        <td class="px-6 py-4">{{ $subject->academicStream->name_ar ?? 'عام' }}</td>
                        <td class="px-6 py-4">
                            <span class="bg-blue-100 text-blue-800 px-2 py-1 rounded-full text-sm font-bold">
                                {{ $subject->coefficient }}
                            </span>
                        </td>
                        <td class="px-6 py-4">
                            @if($subject->is_active)
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
    @else
    <div class="bg-yellow-50 border-r-4 border-yellow-400 p-4 rounded-lg">
        <div class="flex">
            <i class="fas fa-exclamation-triangle text-yellow-400 text-xl mr-3"></i>
            <div>
                <h3 class="text-yellow-800 font-semibold">لا توجد مواد دراسية</h3>
                <p class="text-sm text-yellow-700 mt-1">لم يتم إضافة أي مواد دراسية لهذه السنة بعد</p>
            </div>
        </div>
    </div>
    @endif
</div>
@endsection
