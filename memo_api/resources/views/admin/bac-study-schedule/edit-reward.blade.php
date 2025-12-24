@extends('layouts.admin')

@section('title', 'تعديل المكافأة')
@section('page-title', 'تعديل المكافأة')
@section('page-description', 'تعديل بيانات المكافأة الأسبوعية')

@section('content')

    <!-- Breadcrumb -->
    <div class="mb-6">
        <a href="{{ route('admin.bac-study-schedule.rewards') }}" class="text-blue-500 hover:text-blue-700">
            <i class="fas fa-arrow-right ml-2"></i>العودة للمكافآت
        </a>
    </div>

    <div class="bg-white rounded-lg shadow-md overflow-hidden max-w-2xl">
        <div class="px-6 py-4 bg-gradient-to-r from-yellow-500 to-orange-500">
            <h1 class="text-xl font-bold text-white">تعديل المكافأة - الأسبوع {{ $reward->week_number }}</h1>
        </div>

        <form action="{{ route('admin.bac-study-schedule.rewards.update', $reward->id) }}" method="POST" class="p-6">
            @csrf
            @method('PUT')

            <div class="space-y-6">
                <div class="bg-gray-50 rounded-lg p-4">
                    <p class="text-sm text-gray-600">
                        <span class="font-semibold">الشعبة:</span> {{ $reward->academicStream->name_ar ?? 'غير محدد' }}
                    </p>
                    <p class="text-sm text-gray-600 mt-1">
                        <span class="font-semibold">الأسبوع:</span> {{ $reward->week_number }} (أيام {{ (($reward->week_number-1)*7)+1 }}-{{ $reward->week_number*7 }})
                    </p>
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">العنوان <span class="text-red-500">*</span></label>
                    <input type="text" name="title_ar" value="{{ old('title_ar', $reward->title_ar) }}"
                           placeholder="مثال: مكافأة الأسبوع الأول"
                           class="w-full border rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500" required>
                    @error('title_ar')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">اسم الفيلم</label>
                    <input type="text" name="movie_title" value="{{ old('movie_title', $reward->movie_title) }}"
                           placeholder="مثال: Spirited Away"
                           class="w-full border rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500">
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">رابط صورة الفيلم</label>
                    <input type="text" name="movie_image" value="{{ old('movie_image', $reward->movie_image) }}" dir="ltr"
                           placeholder="https://example.com/image.jpg"
                           class="w-full border rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500">
                    <p class="text-xs text-gray-500 mt-1">يفضل استخدام صور من TMDB أو IMDB</p>

                    @if($reward->movie_image)
                        <div class="mt-3">
                            <p class="text-sm text-gray-600 mb-2">الصورة الحالية:</p>
                            <img src="{{ $reward->movie_image }}" alt="{{ $reward->movie_title }}"
                                 class="w-32 h-48 object-cover rounded-lg shadow">
                        </div>
                    @endif
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">الوصف</label>
                    <textarea name="description_ar" rows="3"
                              placeholder="وصف المكافأة أو نبذة عن الفيلم"
                              class="w-full border rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500">{{ old('description_ar', $reward->description_ar) }}</textarea>
                </div>
            </div>

            <div class="flex justify-end gap-3 mt-6 pt-6 border-t">
                <a href="{{ route('admin.bac-study-schedule.rewards') }}"
                   class="px-6 py-2 text-gray-600 hover:text-gray-800">إلغاء</a>
                <button type="submit" class="bg-yellow-500 text-white px-6 py-2 rounded-lg hover:bg-yellow-600 transition-colors">
                    <i class="fas fa-save mr-2"></i>حفظ التعديلات
                </button>
            </div>
        </form>
    </div>

@endsection
