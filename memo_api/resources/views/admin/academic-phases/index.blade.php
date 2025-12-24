@extends('layouts.admin')

@section('title', 'إدارة المراحل الدراسية')

@section('content')
<div class="p-6 bg-gray-50 min-h-screen">
    <!-- Header -->
    <div class="mb-8">
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-3xl font-bold text-gray-900 flex items-center">
                    <i class="fas fa-layer-group text-purple-600 mr-3"></i>
                    المراحل الدراسية
                </h1>
                <p class="text-gray-600 mt-2">إدارة المراحل التعليمية (ابتدائي، متوسط، ثانوي)</p>
            </div>
            <a href="{{ route('admin.academic-phases.create') }}" class="px-6 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors flex items-center gap-2 shadow-md">
                <i class="fas fa-plus"></i>
                <span>إضافة مرحلة جديدة</span>
            </a>
        </div>
    </div>

    <!-- Success/Error Messages -->
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

    <!-- Phases Table -->
    <div class="bg-white rounded-xl shadow-md overflow-hidden">
        <div class="p-6 border-b border-gray-200">
            <h2 class="text-xl font-bold text-gray-800">قائمة المراحل الدراسية</h2>
            <p class="text-sm text-gray-600 mt-1">عدد المراحل: {{ $phases->count() }}</p>
        </div>

        @if($phases->isEmpty())
            <div class="p-12 text-center">
                <div class="mx-auto w-24 h-24 bg-gray-100 rounded-full flex items-center justify-center mb-4">
                    <i class="fas fa-layer-group text-4xl text-gray-400"></i>
                </div>
                <h3 class="text-xl font-semibold text-gray-700 mb-2">لا توجد مراحل دراسية</h3>
                <p class="text-gray-500 mb-4">ابدأ بإضافة المراحل الدراسية الأساسية (ابتدائي، متوسط، ثانوي)</p>
                <a href="{{ route('admin.academic-phases.create') }}" class="inline-flex items-center px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors">
                    <i class="fas fa-plus mr-2"></i>
                    إضافة مرحلة
                </a>
            </div>
        @else
            <div class="overflow-x-auto">
                <table class="w-full">
                    <thead class="bg-gray-50 border-b border-gray-200">
                        <tr>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">الترتيب</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">اسم المرحلة</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">عدد السنوات</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">عدد الشعب</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase tracking-wider">الإجراءات</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200 bg-white">
                        @foreach($phases as $phase)
                        <tr class="hover:bg-gray-50 transition-colors">
                            <td class="px-6 py-4">
                                <span class="inline-flex items-center justify-center w-8 h-8 bg-purple-100 text-purple-700 rounded-full font-bold">
                                    {{ $phase->order }}
                                </span>
                            </td>
                            <td class="px-6 py-4">
                                <div class="font-semibold text-gray-900 text-lg">{{ $phase->name_ar }}</div>
                                <div class="text-sm text-gray-500">{{ $phase->slug }}</div>
                            </td>
                            <td class="px-6 py-4">
                                <span class="inline-flex items-center px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-sm font-semibold">
                                    <i class="fas fa-calendar-alt mr-2"></i>
                                    {{ $phase->academic_years_count }} سنة
                                </span>
                            </td>
                            <td class="px-6 py-4">
                                <span class="inline-flex items-center px-3 py-1 bg-green-100 text-green-800 rounded-full text-sm font-semibold">
                                    <i class="fas fa-stream mr-2"></i>
                                    {{ $phase->academic_streams_count }} شعبة
                                </span>
                            </td>
                            <td class="px-6 py-4">
                                <div class="flex items-center gap-2">
                                    <a href="{{ route('admin.academic-phases.show', $phase->id) }}"
                                       class="px-3 py-1.5 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors text-sm font-semibold">
                                        <i class="fas fa-eye mr-1"></i>
                                        عرض
                                    </a>
                                    <a href="{{ route('admin.academic-phases.edit', $phase->id) }}"
                                       class="px-3 py-1.5 bg-orange-600 text-white rounded-lg hover:bg-orange-700 transition-colors text-sm font-semibold">
                                        <i class="fas fa-edit mr-1"></i>
                                        تعديل
                                    </a>
                                    <form action="{{ route('admin.academic-phases.destroy', $phase->id) }}" method="POST" class="inline-block" onsubmit="return confirm('هل أنت متأكد من حذف هذه المرحلة؟')">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="px-3 py-1.5 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors text-sm font-semibold">
                                            <i class="fas fa-trash mr-1"></i>
                                            حذف
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        @endif
    </div>
</div>
@endsection
