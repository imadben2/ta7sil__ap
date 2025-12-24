@extends('layouts.admin')

@section('title', 'تعديل اليوم ' . $day->day_number)
@section('page-title', 'تعديل اليوم ' . $day->day_number)
@section('page-description', 'تعديل إعدادات اليوم')

@section('content')

    <!-- Breadcrumb -->
    <div class="mb-6">
        <a href="{{ route('admin.bac-study-schedule.days.show', $day->id) }}" class="text-blue-500 hover:text-blue-700">
            <i class="fas fa-arrow-right ml-2"></i>العودة لتفاصيل اليوم
        </a>
    </div>

    <div class="bg-white rounded-lg shadow-md overflow-hidden">
        <div class="px-6 py-4 bg-gradient-to-r from-yellow-500 to-orange-500">
            <h1 class="text-xl font-bold text-white">تعديل اليوم {{ $day->day_number }}</h1>
        </div>

        <form action="{{ route('admin.bac-study-schedule.days.update', $day->id) }}" method="POST" class="p-6">
            @csrf
            @method('PUT')

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">رقم اليوم</label>
                    <input type="text" value="{{ $day->day_number }}" disabled
                           class="w-full border rounded-lg px-4 py-2 bg-gray-100 text-gray-500">
                    <p class="text-xs text-gray-500 mt-1">لا يمكن تعديل رقم اليوم</p>
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">الشعبة</label>
                    <input type="text" value="{{ $day->academicStream->name_ar ?? 'N/A' }}" disabled
                           class="w-full border rounded-lg px-4 py-2 bg-gray-100 text-gray-500">
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">نوع اليوم</label>
                    <select name="day_type" class="w-full border rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500">
                        <option value="study" {{ $day->day_type === 'study' ? 'selected' : '' }}>دراسة</option>
                        <option value="review" {{ $day->day_type === 'review' ? 'selected' : '' }}>مراجعة</option>
                        <option value="reward" {{ $day->day_type === 'reward' ? 'selected' : '' }}>مكافأة</option>
                    </select>
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">الحالة</label>
                    <label class="flex items-center gap-3 cursor-pointer">
                        <input type="checkbox" name="is_active" value="1" {{ $day->is_active ? 'checked' : '' }}
                               class="w-5 h-5 text-blue-600 rounded focus:ring-blue-500">
                        <span class="text-gray-700">نشط</span>
                    </label>
                </div>

                <div class="md:col-span-2">
                    <label class="block text-sm font-medium text-gray-700 mb-2">العنوان (اختياري)</label>
                    <input type="text" name="title_ar" value="{{ $day->title_ar }}"
                           placeholder="مثال: مراجعة شاملة، يوم راحة..."
                           class="w-full border rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500">
                </div>
            </div>

            <div class="flex justify-end gap-3 mt-6 pt-6 border-t">
                <a href="{{ route('admin.bac-study-schedule.days.show', $day->id) }}"
                   class="px-6 py-2 text-gray-600 hover:text-gray-800">إلغاء</a>
                <button type="submit" class="bg-blue-500 text-white px-6 py-2 rounded-lg hover:bg-blue-600 transition-colors">
                    <i class="fas fa-save mr-2"></i>حفظ التعديلات
                </button>
            </div>
        </form>
    </div>

@endsection
