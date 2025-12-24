@extends('layouts.admin')

@section('title', 'المكافآت الأسبوعية')
@section('page-title', 'المكافآت الأسبوعية')
@section('page-description', 'إدارة مكافآت الأفلام الأسبوعية')

@section('content')

    <!-- Header Actions -->
    <div class="flex flex-wrap items-center justify-between gap-4 mb-6">
        <form method="GET" class="flex items-center gap-4">
            <label class="font-semibold text-gray-700">الشعبة:</label>
            <select name="stream_id" onchange="this.form.submit()" class="border rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500">
                <option value="">جميع الشعب</option>
                @foreach($streams as $stream)
                    <option value="{{ $stream->id }}" {{ $streamId == $stream->id ? 'selected' : '' }}>
                        {{ $stream->name_ar }}
                    </option>
                @endforeach
            </select>
        </form>
        <a href="{{ route('admin.bac-study-schedule.rewards.create') }}"
           class="bg-green-500 text-white px-4 py-2 rounded-lg hover:bg-green-600 transition-colors">
            <i class="fas fa-plus mr-2"></i>إضافة مكافأة
        </a>
    </div>

    <!-- Rewards Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
        @forelse($rewards as $reward)
            <div class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow">
                @if($reward->movie_image)
                    <div class="h-48 bg-gray-200 overflow-hidden">
                        <img src="{{ $reward->movie_image }}" alt="{{ $reward->movie_title }}"
                             class="w-full h-full object-cover">
                    </div>
                @else
                    <div class="h-48 bg-gradient-to-br from-yellow-400 to-orange-500 flex items-center justify-center">
                        <i class="fas fa-film text-white text-6xl opacity-50"></i>
                    </div>
                @endif
                <div class="p-4">
                    <div class="flex items-center justify-between mb-2">
                        <span class="px-3 py-1 bg-yellow-100 text-yellow-800 rounded-full text-sm font-semibold">
                            الأسبوع {{ $reward->week_number }}
                        </span>
                        <span class="text-xs text-gray-500">
                            {{ $reward->academicStream->name_ar ?? 'N/A' }}
                        </span>
                    </div>
                    <h3 class="text-lg font-semibold text-gray-800 mb-1">{{ $reward->title_ar }}</h3>
                    @if($reward->movie_title)
                        <p class="text-gray-600 text-sm mb-2">
                            <i class="fas fa-film mr-1 text-yellow-500"></i>
                            {{ $reward->movie_title }}
                        </p>
                    @endif
                    @if($reward->description_ar)
                        <p class="text-gray-500 text-sm line-clamp-2">{{ $reward->description_ar }}</p>
                    @endif
                    <div class="flex gap-2 mt-4">
                        <a href="{{ route('admin.bac-study-schedule.rewards.edit', $reward->id) }}"
                           class="flex-1 text-center bg-yellow-500 text-white px-3 py-2 rounded-lg hover:bg-yellow-600 transition-colors text-sm">
                            <i class="fas fa-edit"></i> تعديل
                        </a>
                        <form action="{{ route('admin.bac-study-schedule.rewards.destroy', $reward->id) }}" method="POST" class="flex-1">
                            @csrf
                            @method('DELETE')
                            <button type="submit" onclick="return confirm('هل أنت متأكد من حذف هذه المكافأة؟')"
                                    class="w-full bg-red-500 text-white px-3 py-2 rounded-lg hover:bg-red-600 transition-colors text-sm">
                                <i class="fas fa-trash"></i> حذف
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        @empty
            <div class="col-span-full bg-white rounded-lg shadow-md p-8 text-center">
                <i class="fas fa-gift text-gray-300 text-6xl mb-4"></i>
                <p class="text-gray-500 text-lg">لا توجد مكافآت</p>
                <a href="{{ route('admin.bac-study-schedule.rewards.create') }}"
                   class="inline-block mt-4 bg-green-500 text-white px-6 py-2 rounded-lg hover:bg-green-600 transition-colors">
                    <i class="fas fa-plus mr-2"></i>إضافة مكافأة جديدة
                </a>
            </div>
        @endforelse
    </div>

    <!-- Pagination -->
    <div class="mt-6">
        {{ $rewards->appends(request()->query())->links() }}
    </div>

@endsection
