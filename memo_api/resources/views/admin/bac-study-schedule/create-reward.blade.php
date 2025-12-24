@extends('layouts.admin')

@section('title', 'إضافة مكافأة جديدة')
@section('page-title', 'إضافة مكافأة جديدة')
@section('page-description', 'إنشاء مكافأة أسبوعية جديدة')

@section('content')

    <!-- Breadcrumb -->
    <div class="mb-6">
        <a href="{{ route('admin.bac-study-schedule.rewards') }}" class="text-blue-500 hover:text-blue-700">
            <i class="fas fa-arrow-right ml-2"></i>العودة للمكافآت
        </a>
    </div>

    <div class="bg-white rounded-lg shadow-md overflow-hidden max-w-2xl">
        <div class="px-6 py-4 bg-gradient-to-r from-green-500 to-green-600">
            <h1 class="text-xl font-bold text-white">إضافة مكافأة جديدة</h1>
        </div>

        <form action="{{ route('admin.bac-study-schedule.rewards.store') }}" method="POST" class="p-6">
            @csrf

            <div class="space-y-6">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">الشعبة <span class="text-red-500">*</span></label>
                    <select name="academic_stream_id" class="w-full border rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500" required>
                        <option value="">اختر الشعبة</option>
                        @foreach($streams as $stream)
                            <option value="{{ $stream->id }}" {{ old('academic_stream_id') == $stream->id ? 'selected' : '' }}>
                                {{ $stream->name_ar }}
                            </option>
                        @endforeach
                    </select>
                    @error('academic_stream_id')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">رقم الأسبوع <span class="text-red-500">*</span></label>
                    <select name="week_number" class="w-full border rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500" required>
                        <option value="">اختر الأسبوع</option>
                        @for($i = 1; $i <= 14; $i++)
                            <option value="{{ $i }}" {{ old('week_number') == $i ? 'selected' : '' }}>
                                الأسبوع {{ $i }} (أيام {{ (($i-1)*7)+1 }}-{{ $i*7 }})
                            </option>
                        @endfor
                    </select>
                    @error('week_number')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">العنوان <span class="text-red-500">*</span></label>
                    <input type="text" name="title_ar" value="{{ old('title_ar') }}"
                           placeholder="مثال: مكافأة الأسبوع الأول"
                           class="w-full border rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500" required>
                    @error('title_ar')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">اسم الفيلم</label>
                    <input type="text" name="movie_title" value="{{ old('movie_title') }}"
                           placeholder="مثال: Spirited Away"
                           class="w-full border rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500">
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">رابط صورة الفيلم</label>
                    <input type="text" name="movie_image" value="{{ old('movie_image') }}" dir="ltr"
                           placeholder="https://example.com/image.jpg"
                           class="w-full border rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500">
                    <p class="text-xs text-gray-500 mt-1">يفضل استخدام صور من TMDB أو IMDB</p>
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">الوصف</label>
                    <textarea name="description_ar" rows="3"
                              placeholder="وصف المكافأة أو نبذة عن الفيلم"
                              class="w-full border rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500">{{ old('description_ar') }}</textarea>
                </div>
            </div>

            <div class="flex justify-end gap-3 mt-6 pt-6 border-t">
                <a href="{{ route('admin.bac-study-schedule.rewards') }}"
                   class="px-6 py-2 text-gray-600 hover:text-gray-800">إلغاء</a>
                <button type="submit" class="bg-green-500 text-white px-6 py-2 rounded-lg hover:bg-green-600 transition-colors">
                    <i class="fas fa-plus mr-2"></i>إضافة المكافأة
                </button>
            </div>
        </form>
    </div>

@endsection
