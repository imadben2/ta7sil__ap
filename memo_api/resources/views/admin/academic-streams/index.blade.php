@extends('layouts.admin')

@section('title', 'الشعب الدراسية')

@section('content')
<div class="p-6 bg-gray-50 min-h-screen">
    <!-- Header -->
    <div class="mb-8">
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-3xl font-bold text-gray-900 flex items-center">
                    <i class="fas fa-stream text-green-600 mr-3"></i>
                    إدارة الشعب الدراسية
                </h1>
                <p class="text-gray-600 mt-2">عرض وإدارة جميع الشعب الدراسية في النظام</p>
            </div>
            <a href="{{ route('admin.academic-streams.create') }}" class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors flex items-center gap-2">
                <i class="fas fa-plus"></i>
                <span>إضافة شعبة جديدة</span>
            </a>
        </div>
    </div>

    <!-- Success Message -->
    @if(session('success'))
    <div class="mb-6 bg-green-50 border-r-4 border-green-500 p-4 rounded-lg">
        <div class="flex">
            <i class="fas fa-check-circle text-green-500 text-xl mr-3"></i>
            <div>
                <p class="text-green-800 font-semibold">{{ session('success') }}</p>
            </div>
        </div>
    </div>
    @endif

    <!-- Error Message -->
    @if(session('error'))
    <div class="mb-6 bg-red-50 border-r-4 border-red-500 p-4 rounded-lg">
        <div class="flex">
            <i class="fas fa-exclamation-circle text-red-500 text-xl mr-3"></i>
            <div>
                <p class="text-red-800 font-semibold">{{ session('error') }}</p>
            </div>
        </div>
    </div>
    @endif

    <!-- Filter Section -->
    <div class="bg-white rounded-xl shadow-md p-6 mb-6">
        <h2 class="text-lg font-bold text-gray-800 mb-4 flex items-center">
            <i class="fas fa-filter text-green-600 mr-2"></i>
            تصفية النتائج
        </h2>
        <form method="GET" action="{{ route('admin.academic-streams.index') }}" class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <!-- Filter by Phase -->
            <div>
                <label for="phase_id" class="block text-sm font-semibold text-gray-700 mb-2">المرحلة الدراسية</label>
                <select name="phase_id" id="phase_id" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500">
                    <option value="">جميع المراحل</option>
                    @foreach($academicPhases as $phase)
                        <option value="{{ $phase->id }}" {{ request('phase_id') == $phase->id ? 'selected' : '' }}>
                            {{ $phase->name_ar }}
                        </option>
                    @endforeach
                </select>
            </div>

            <!-- Filter by Year -->
            <div>
                <label for="year_id" class="block text-sm font-semibold text-gray-700 mb-2">السنة الدراسية</label>
                <select name="year_id" id="year_id" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500">
                    <option value="">جميع السنوات</option>
                    @foreach($academicYears as $year)
                        <option value="{{ $year->id }}" {{ request('year_id') == $year->id ? 'selected' : '' }}>
                            {{ $year->name_ar }}
                        </option>
                    @endforeach
                </select>
            </div>

            <!-- Filter by Status -->
            <div>
                <label for="status" class="block text-sm font-semibold text-gray-700 mb-2">الحالة</label>
                <select name="status" id="status" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500">
                    <option value="">جميع الحالات</option>
                    <option value="1" {{ request('status') === '1' ? 'selected' : '' }}>نشط</option>
                    <option value="0" {{ request('status') === '0' ? 'selected' : '' }}>غير نشط</option>
                </select>
            </div>

            <!-- Submit -->
            <div class="flex items-end gap-2">
                <button type="submit" class="px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors flex items-center gap-2">
                    <i class="fas fa-search"></i>
                    <span>بحث</span>
                </button>
                <a href="{{ route('admin.academic-streams.index') }}" class="px-6 py-2 bg-gray-300 text-gray-700 rounded-lg hover:bg-gray-400 transition-colors">
                    إعادة تعيين
                </a>
            </div>
        </form>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
        <div class="bg-white rounded-xl shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm text-gray-600">إجمالي الشعب</p>
                    <p class="text-3xl font-bold text-green-600 mt-2">{{ $totalStreams }}</p>
                </div>
                <div class="bg-green-100 p-3 rounded-lg">
                    <i class="fas fa-stream text-green-600 text-2xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-xl shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm text-gray-600">شعب نشطة</p>
                    <p class="text-3xl font-bold text-blue-600 mt-2">{{ $activeStreams }}</p>
                </div>
                <div class="bg-blue-100 p-3 rounded-lg">
                    <i class="fas fa-check-circle text-blue-600 text-2xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-xl shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm text-gray-600">شعب غير نشطة</p>
                    <p class="text-3xl font-bold text-gray-600 mt-2">{{ $inactiveStreams }}</p>
                </div>
                <div class="bg-gray-100 p-3 rounded-lg">
                    <i class="fas fa-times-circle text-gray-600 text-2xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-xl shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm text-gray-600">المواد الدراسية</p>
                    <p class="text-3xl font-bold text-indigo-600 mt-2">{{ $totalSubjects }}</p>
                </div>
                <div class="bg-indigo-100 p-3 rounded-lg">
                    <i class="fas fa-book text-indigo-600 text-2xl"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Streams Table -->
    <div class="bg-white rounded-xl shadow-md overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full">
                <thead class="bg-green-600 text-white">
                    <tr>
                        <th class="px-6 py-4 text-right text-sm font-bold uppercase">الترتيب</th>
                        <th class="px-6 py-4 text-right text-sm font-bold uppercase">اسم الشعبة</th>
                        <th class="px-6 py-4 text-right text-sm font-bold uppercase">السنة الدراسية</th>
                        <th class="px-6 py-4 text-right text-sm font-bold uppercase">المرحلة</th>
                        <th class="px-6 py-4 text-right text-sm font-bold uppercase">الوصف</th>
                        <th class="px-6 py-4 text-right text-sm font-bold uppercase">المواد</th>
                        <th class="px-6 py-4 text-right text-sm font-bold uppercase">الحالة</th>
                        <th class="px-6 py-4 text-center text-sm font-bold uppercase">الإجراءات</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                    @forelse($academicStreams as $stream)
                    <tr class="hover:bg-gray-50 transition-colors">
                        <td class="px-6 py-4 text-gray-900 font-semibold">{{ $stream->order }}</td>
                        <td class="px-6 py-4">
                            <div class="font-bold text-gray-900">{{ $stream->name_ar }}</div>
                            <div class="text-sm text-gray-500 font-mono">{{ $stream->slug }}</div>
                        </td>
                        <td class="px-6 py-4">
                            <span class="text-blue-600 font-semibold">{{ $stream->academicYear->name_ar }}</span>
                        </td>
                        <td class="px-6 py-4">
                            <span class="text-purple-600 font-semibold">{{ $stream->academicYear->academicPhase->name_ar }}</span>
                        </td>
                        <td class="px-6 py-4 text-gray-600 text-sm">{{ Str::limit($stream->description_ar, 40) }}</td>
                        <td class="px-6 py-4">
                            <span class="bg-indigo-100 text-indigo-800 px-3 py-1 rounded-full text-sm font-bold">
                                {{ $stream->subjects_count ?? 0 }}
                            </span>
                        </td>
                        <td class="px-6 py-4">
                            @if($stream->is_active)
                                <span class="bg-green-100 text-green-800 px-3 py-1 rounded-full text-xs font-semibold">نشط</span>
                            @else
                                <span class="bg-gray-100 text-gray-800 px-3 py-1 rounded-full text-xs font-semibold">غير نشط</span>
                            @endif
                        </td>
                        <td class="px-6 py-4">
                            <div class="flex items-center justify-center gap-2">
                                <a href="{{ route('admin.academic-streams.show', $stream->id) }}" class="text-blue-600 hover:text-blue-800" title="عرض">
                                    <i class="fas fa-eye"></i>
                                </a>
                                <a href="{{ route('admin.academic-streams.edit', $stream->id) }}" class="text-orange-600 hover:text-orange-800" title="تعديل">
                                    <i class="fas fa-edit"></i>
                                </a>
                                <form action="{{ route('admin.academic-streams.destroy', $stream->id) }}" method="POST" class="inline" onsubmit="return confirm('هل أنت متأكد من حذف هذه الشعبة؟');">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="text-red-600 hover:text-red-800" title="حذف">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="8" class="px-6 py-12 text-center">
                            <div class="flex flex-col items-center justify-center">
                                <i class="fas fa-inbox text-gray-300 text-6xl mb-4"></i>
                                <p class="text-gray-500 text-lg font-semibold">لا توجد شعب دراسية</p>
                                <p class="text-gray-400 text-sm mt-2">قم بإضافة شعبة دراسية جديدة للبدء</p>
                            </div>
                        </td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
</div>
@endsection
