@extends('layouts.admin')

@section('title', $deck->title_ar)

@section('content')
<div class="p-6">
    <!-- Header -->
    <div class="flex flex-col md:flex-row md:items-start md:justify-between gap-4 mb-6">
        <div class="flex items-start gap-4">
            <a href="{{ route('admin.flashcard-decks.index') }}"
               class="w-10 h-10 bg-gray-100 hover:bg-gray-200 rounded-xl flex items-center justify-center transition flex-shrink-0 mt-1">
                <i class="fas fa-arrow-right text-gray-600"></i>
            </a>
            <div>
                <h1 class="text-2xl font-bold text-gray-900">{{ $deck->title_ar }}</h1>
                @if($deck->subject)
                    <p class="text-gray-600 mt-1">
                        <span class="px-2 py-1 bg-blue-100 text-blue-700 rounded-full text-xs font-semibold">{{ $deck->subject->name_ar }}</span>
                        @if($deck->chapter)
                            <span class="text-gray-400 mx-1">›</span>
                            <span class="text-gray-600">{{ $deck->chapter->title_ar }}</span>
                        @endif
                    </p>
                @endif
            </div>
        </div>
        <div class="flex flex-wrap gap-2">
            @if(!$deck->is_published)
                <form action="{{ route('admin.flashcard-decks.publish', $deck->id) }}" method="POST" class="inline">
                    @csrf
                    <button type="submit" class="px-4 py-2 bg-green-500 hover:bg-green-600 text-white rounded-lg font-semibold transition">
                        <i class="fas fa-check-circle ml-1"></i> نشر
                    </button>
                </form>
            @else
                <form action="{{ route('admin.flashcard-decks.unpublish', $deck->id) }}" method="POST" class="inline">
                    @csrf
                    <button type="submit" class="px-4 py-2 bg-gray-500 hover:bg-gray-600 text-white rounded-lg font-semibold transition">
                        <i class="fas fa-eye-slash ml-1"></i> إلغاء النشر
                    </button>
                </form>
            @endif
            <a href="{{ route('admin.flashcards.index', $deck->id) }}"
               class="px-4 py-2 bg-pink-500 hover:bg-pink-600 text-white rounded-lg font-semibold transition">
                <i class="fas fa-clone ml-1"></i> إدارة البطاقات ({{ $deck->total_cards }})
            </a>
            <a href="{{ route('admin.flashcard-decks.edit', $deck->id) }}"
               class="px-4 py-2 bg-yellow-500 hover:bg-yellow-600 text-white rounded-lg font-semibold transition">
                <i class="fas fa-edit ml-1"></i> تعديل
            </a>
            <form action="{{ route('admin.flashcard-decks.duplicate', $deck->id) }}" method="POST" class="inline">
                @csrf
                <button type="submit" class="px-4 py-2 bg-blue-500 hover:bg-blue-600 text-white rounded-lg font-semibold transition">
                    <i class="fas fa-copy ml-1"></i> نسخ
                </button>
            </form>
        </div>
    </div>

    <!-- Status Banner -->
    @if(!$deck->is_published)
        <div class="bg-yellow-50 border border-yellow-200 rounded-xl p-4 mb-6 flex items-center gap-3">
            <i class="fas fa-exclamation-triangle text-yellow-500 text-xl"></i>
            <div>
                <p class="font-bold text-yellow-800">هذه المجموعة غير منشورة</p>
                <p class="text-yellow-700 text-sm">لن تظهر للطلاب حتى يتم نشرها</p>
            </div>
        </div>
    @endif

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Main Info -->
        <div class="lg:col-span-2 space-y-6">
            <!-- Description -->
            <div class="bg-white rounded-xl shadow-sm p-6">
                <h2 class="text-lg font-bold text-gray-900 mb-4">الوصف</h2>
                <p class="text-gray-600">{{ $deck->description_ar ?: 'لا يوجد وصف' }}</p>
            </div>

            <!-- Cards Overview -->
            <div class="bg-white rounded-xl shadow-sm p-6">
                <div class="flex items-center justify-between mb-4">
                    <h2 class="text-lg font-bold text-gray-900">البطاقات</h2>
                    <a href="{{ route('admin.flashcards.index', $deck->id) }}"
                       class="text-pink-600 hover:text-pink-700 font-semibold text-sm">
                        عرض الكل <i class="fas fa-arrow-left mr-1"></i>
                    </a>
                </div>

                @if($deck->total_cards > 0)
                    <!-- Card Type Distribution -->
                    <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
                        <div class="bg-blue-50 rounded-lg p-4 text-center">
                            <i class="fas fa-file-alt text-blue-500 text-2xl mb-2"></i>
                            <p class="text-2xl font-bold text-blue-700">{{ $cardTypes['basic'] ?? 0 }}</p>
                            <p class="text-xs text-blue-600">أساسي</p>
                        </div>
                        <div class="bg-purple-50 rounded-lg p-4 text-center">
                            <i class="fas fa-fill-drip text-purple-500 text-2xl mb-2"></i>
                            <p class="text-2xl font-bold text-purple-700">{{ $cardTypes['cloze'] ?? 0 }}</p>
                            <p class="text-xs text-purple-600">إملاء</p>
                        </div>
                        <div class="bg-green-50 rounded-lg p-4 text-center">
                            <i class="fas fa-image text-green-500 text-2xl mb-2"></i>
                            <p class="text-2xl font-bold text-green-700">{{ $cardTypes['image'] ?? 0 }}</p>
                            <p class="text-xs text-green-600">صورة</p>
                        </div>
                        <div class="bg-orange-50 rounded-lg p-4 text-center">
                            <i class="fas fa-volume-up text-orange-500 text-2xl mb-2"></i>
                            <p class="text-2xl font-bold text-orange-700">{{ $cardTypes['audio'] ?? 0 }}</p>
                            <p class="text-xs text-orange-600">صوت</p>
                        </div>
                    </div>

                    <!-- Difficulty Distribution -->
                    <h3 class="font-semibold text-gray-700 mb-3">توزيع الصعوبة</h3>
                    <div class="flex gap-4">
                        <div class="flex-1 bg-green-100 rounded-lg p-3 text-center">
                            <p class="text-xl font-bold text-green-700">{{ $difficulties['easy'] ?? 0 }}</p>
                            <p class="text-xs text-green-600">سهل</p>
                        </div>
                        <div class="flex-1 bg-yellow-100 rounded-lg p-3 text-center">
                            <p class="text-xl font-bold text-yellow-700">{{ $difficulties['medium'] ?? 0 }}</p>
                            <p class="text-xs text-yellow-600">متوسط</p>
                        </div>
                        <div class="flex-1 bg-red-100 rounded-lg p-3 text-center">
                            <p class="text-xl font-bold text-red-700">{{ $difficulties['hard'] ?? 0 }}</p>
                            <p class="text-xs text-red-600">صعب</p>
                        </div>
                    </div>
                @else
                    <div class="text-center py-8">
                        <i class="fas fa-clone text-gray-300 text-5xl mb-4"></i>
                        <p class="text-gray-500 mb-4">لا توجد بطاقات في هذه المجموعة</p>
                        <a href="{{ route('admin.flashcards.index', $deck->id) }}"
                           class="inline-flex items-center gap-2 px-4 py-2 bg-pink-500 hover:bg-pink-600 text-white rounded-lg font-semibold transition">
                            <i class="fas fa-plus"></i>
                            إضافة بطاقات
                        </a>
                    </div>
                @endif
            </div>
        </div>

        <!-- Sidebar -->
        <div class="space-y-6">
            <!-- Quick Stats -->
            <div class="bg-white rounded-xl shadow-sm p-6">
                <h2 class="text-lg font-bold text-gray-900 mb-4">معلومات سريعة</h2>
                <div class="space-y-4">
                    <div class="flex items-center justify-between">
                        <span class="text-gray-600">الحالة</span>
                        @if($deck->is_published)
                            <span class="px-3 py-1 bg-green-100 text-green-700 rounded-full text-sm font-bold">منشور</span>
                        @else
                            <span class="px-3 py-1 bg-gray-100 text-gray-600 rounded-full text-sm font-bold">مسودة</span>
                        @endif
                    </div>
                    <div class="flex items-center justify-between">
                        <span class="text-gray-600">الصعوبة</span>
                        @php
                            $difficultyLabels = ['easy' => 'سهل', 'medium' => 'متوسط', 'hard' => 'صعب'];
                            $difficultyColors = ['easy' => 'green', 'medium' => 'yellow', 'hard' => 'red'];
                        @endphp
                        <span class="px-3 py-1 bg-{{ $difficultyColors[$deck->difficulty_level] ?? 'gray' }}-100 text-{{ $difficultyColors[$deck->difficulty_level] ?? 'gray' }}-700 rounded-full text-sm font-bold">
                            {{ $difficultyLabels[$deck->difficulty_level] ?? '-' }}
                        </span>
                    </div>
                    <div class="flex items-center justify-between">
                        <span class="text-gray-600">عدد البطاقات</span>
                        <span class="font-bold text-pink-600">{{ $deck->total_cards }}</span>
                    </div>
                    <div class="flex items-center justify-between">
                        <span class="text-gray-600">الوقت المقدر</span>
                        <span class="font-bold text-gray-900">{{ $deck->estimated_study_minutes ?? '-' }} دقيقة</span>
                    </div>
                    @if($deck->is_premium)
                        <div class="flex items-center justify-between">
                            <span class="text-gray-600">النوع</span>
                            <span class="px-3 py-1 bg-yellow-100 text-yellow-700 rounded-full text-sm font-bold">مدفوع</span>
                        </div>
                    @endif
                </div>
            </div>

            <!-- Academic Info -->
            <div class="bg-white rounded-xl shadow-sm p-6">
                <h2 class="text-lg font-bold text-gray-900 mb-4">التصنيف الأكاديمي</h2>
                <div class="space-y-3">
                    @if($deck->subject)
                        <div>
                            <p class="text-gray-500 text-xs mb-1">المادة</p>
                            <p class="font-semibold text-gray-900">{{ $deck->subject->name_ar }}</p>
                        </div>
                    @endif
                    @if($deck->chapter)
                        <div>
                            <p class="text-gray-500 text-xs mb-1">الفصل</p>
                            <p class="font-semibold text-gray-900">{{ $deck->chapter->title_ar }}</p>
                        </div>
                    @endif
                    <div>
                        <p class="text-gray-500 text-xs mb-1">الشعب</p>
                        @if($deck->academicStreams->isNotEmpty())
                            <div class="flex flex-wrap gap-1 mt-1">
                                @foreach($deck->academicStreams as $stream)
                                    <span class="px-2 py-1 bg-purple-100 text-purple-700 rounded-full text-xs font-semibold">
                                        {{ $stream->name_ar }}
                                    </span>
                                @endforeach
                            </div>
                        @else
                            <p class="text-gray-500 italic">كل الشعب</p>
                        @endif
                    </div>
                </div>
            </div>

            <!-- Metadata -->
            <div class="bg-white rounded-xl shadow-sm p-6">
                <h2 class="text-lg font-bold text-gray-900 mb-4">معلومات إضافية</h2>
                <div class="space-y-3 text-sm">
                    <div class="flex items-center justify-between">
                        <span class="text-gray-500">تاريخ الإنشاء</span>
                        <span class="text-gray-900">{{ $deck->created_at->format('Y/m/d') }}</span>
                    </div>
                    <div class="flex items-center justify-between">
                        <span class="text-gray-500">آخر تحديث</span>
                        <span class="text-gray-900">{{ $deck->updated_at->format('Y/m/d') }}</span>
                    </div>
                    @if($deck->creator)
                        <div class="flex items-center justify-between">
                            <span class="text-gray-500">أنشأ بواسطة</span>
                            <span class="text-gray-900">{{ $deck->creator->name }}</span>
                        </div>
                    @endif
                </div>
            </div>

            <!-- Danger Zone -->
            <div class="bg-red-50 border border-red-200 rounded-xl p-6">
                <h2 class="text-lg font-bold text-red-800 mb-4">منطقة الخطر</h2>
                <p class="text-red-700 text-sm mb-4">حذف المجموعة سيؤدي إلى حذف جميع البطاقات المرتبطة بها</p>
                <form action="{{ route('admin.flashcard-decks.destroy', $deck->id) }}" method="POST"
                      onsubmit="return confirm('هل أنت متأكد من حذف هذه المجموعة؟ لا يمكن التراجع عن هذا الإجراء.')">
                    @csrf
                    @method('DELETE')
                    <button type="submit" class="w-full px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded-lg font-semibold transition">
                        <i class="fas fa-trash ml-1"></i> حذف المجموعة
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection
