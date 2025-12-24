@extends('layouts.admin')

@section('title', $academicStream->name_ar)

@section('content')
<div class="p-6 bg-gray-50 min-h-screen">
    <!-- Header -->
    <div class="mb-8">
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-3xl font-bold text-gray-900 flex items-center">
                    <i class="fas fa-layer-group text-green-600 mr-3"></i>
                    {{ $academicStream->name_ar }}
                </h1>
                <p class="text-gray-600 mt-2">عرض تفاصيل الشعبة الدراسية</p>
            </div>
            <div class="flex gap-3">
                <a href="{{ route('admin.academic-streams.index') }}" class="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors flex items-center gap-2">
                    <i class="fas fa-arrow-right"></i>
                    <span>رجوع</span>
                </a>
                <a href="{{ route('admin.academic-streams.edit', $academicStream->id) }}" class="px-4 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700 transition-colors flex items-center gap-2">
                    <i class="fas fa-edit"></i>
                    <span>تعديل</span>
                </a>
            </div>
        </div>
    </div>

    <!-- Stream Info Card -->
    <div class="bg-white rounded-xl shadow-md p-6 mb-6">
        <h2 class="text-xl font-bold text-gray-800 mb-4 flex items-center">
            <i class="fas fa-info-circle text-blue-600 mr-2"></i>
            معلومات الشعبة
        </h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
                <label class="text-sm font-semibold text-gray-600">اسم الشعبة</label>
                <p class="text-lg font-bold text-gray-900 mt-1">{{ $academicStream->name_ar }}</p>
            </div>
            <div>
                <label class="text-sm font-semibold text-gray-600">السنة الدراسية</label>
                <p class="text-lg text-blue-600 font-semibold mt-1">{{ $academicStream->academicYear->name_ar }}</p>
            </div>
            <div>
                <label class="text-sm font-semibold text-gray-600">المرحلة الدراسية</label>
                <p class="text-lg text-purple-600 font-semibold mt-1">{{ $academicStream->academicYear->academicPhase->name_ar }}</p>
            </div>
            <div class="md:col-span-2">
                <label class="text-sm font-semibold text-gray-600">الوصف</label>
                <p class="text-base text-gray-700 mt-1">{{ $academicStream->description_ar ?: 'لا يوجد وصف' }}</p>
            </div>
            <div>
                <label class="text-sm font-semibold text-gray-600">الترتيب</label>
                <p class="text-lg font-bold text-gray-700 mt-1">{{ $academicStream->order }}</p>
            </div>
            <div>
                <label class="text-sm font-semibold text-gray-600">المعرف (Slug)</label>
                <p class="text-lg text-gray-700 mt-1 font-mono">{{ $academicStream->slug }}</p>
            </div>
            <div>
                <label class="text-sm font-semibold text-gray-600">الحالة</label>
                <div class="mt-1">
                    @if($academicStream->is_active)
                        <span class="bg-green-100 text-green-800 px-3 py-1 rounded-full text-sm font-semibold">نشط</span>
                    @else
                        <span class="bg-gray-100 text-gray-800 px-3 py-1 rounded-full text-sm font-semibold">غير نشط</span>
                    @endif
                </div>
            </div>
        </div>
    </div>

    <!-- Stats Card -->
    <div class="grid grid-cols-1 md:grid-cols-1 gap-6 mb-6">
        <div class="bg-gradient-to-l from-indigo-500 to-indigo-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between mb-4">
                <div class="bg-white/20 p-3 rounded-lg">
                    <i class="fas fa-book text-2xl"></i>
                </div>
                <span class="text-sm opacity-80">المواد الدراسية</span>
            </div>
            <div class="text-4xl font-bold">{{ $academicStream->subjects->count() }}</div>
            <p class="text-sm mt-2 opacity-80">مادة دراسية في هذه الشعبة</p>
        </div>
    </div>

    <!-- Subjects Table -->
    @if($academicStream->subjects->isNotEmpty())
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
                        <th class="px-6 py-3 text-right text-xs font-bold text-gray-700 uppercase">اسم المادة بالفرنسية</th>
                        <th class="px-6 py-3 text-right text-xs font-bold text-gray-700 uppercase">المعامل</th>
                        <th class="px-6 py-3 text-right text-xs font-bold text-gray-700 uppercase">النوع</th>
                        <th class="px-6 py-3 text-right text-xs font-bold text-gray-700 uppercase">الحالة</th>
                        <th class="px-6 py-3 text-right text-xs font-bold text-gray-700 uppercase">الإجراءات</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                    @foreach($academicStream->subjects as $subject)
                    <tr class="hover:bg-gray-50">
                        <td class="px-6 py-4 font-bold text-gray-900">{{ $subject->name_ar }}</td>
                        <td class="px-6 py-4 text-gray-600">{{ $subject->name_fr }}</td>
                        <td class="px-6 py-4">
                            <span class="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-sm font-bold">
                                {{ $subject->coefficient }}
                            </span>
                        </td>
                        <td class="px-6 py-4">
                            @if($subject->type === 'core')
                                <span class="bg-purple-100 text-purple-800 px-2 py-1 rounded-full text-xs">أساسية</span>
                            @elseif($subject->type === 'elective')
                                <span class="bg-yellow-100 text-yellow-800 px-2 py-1 rounded-full text-xs">اختيارية</span>
                            @else
                                <span class="bg-gray-100 text-gray-800 px-2 py-1 rounded-full text-xs">{{ $subject->type }}</span>
                            @endif
                        </td>
                        <td class="px-6 py-4">
                            @if($subject->is_active)
                                <span class="bg-green-100 text-green-800 px-2 py-1 rounded-full text-xs font-semibold">نشط</span>
                            @else
                                <span class="bg-gray-100 text-gray-800 px-2 py-1 rounded-full text-xs font-semibold">غير نشط</span>
                            @endif
                        </td>
                        <td class="px-6 py-4">
                            <a href="{{ route('admin.subjects.show', $subject->id) }}" class="text-blue-600 hover:text-blue-800">
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
    <div class="bg-yellow-50 border-r-4 border-yellow-400 p-4 rounded-lg">
        <div class="flex">
            <i class="fas fa-exclamation-triangle text-yellow-400 text-xl mr-3"></i>
            <div>
                <h3 class="text-yellow-800 font-semibold">لا توجد مواد دراسية</h3>
                <p class="text-sm text-yellow-700 mt-1">لم يتم إضافة أي مواد دراسية لهذه الشعبة بعد</p>
            </div>
        </div>
    </div>
    @endif
</div>
@endsection
