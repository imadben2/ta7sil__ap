@extends('layouts.admin')

@section('title', 'تفاصيل الكويز')
@section('page-title', $quiz->title_ar)
@section('page-description', 'تفاصيل وإحصائيات الكويز')

@section('content')
<div class="space-y-6">
    <!-- Quiz Header -->
    <div class="bg-white rounded-lg shadow-md p-6">
        <div class="flex items-start justify-between">
            <div class="flex-1">
                <h2 class="text-2xl font-bold text-gray-900 mb-2">{{ $quiz->title_ar }}</h2>
                <p class="text-gray-600 mb-4">{{ $quiz->description_ar }}</p>

                <div class="flex flex-wrap gap-2 mb-4">
                    <!-- Status Badge -->
                    @if($quiz->is_published)
                        <span class="px-3 py-1 text-sm font-semibold rounded-full bg-green-100 text-green-800">
                            <i class="fas fa-check-circle mr-1"></i> منشور
                        </span>
                    @else
                        <span class="px-3 py-1 text-sm font-semibold rounded-full bg-gray-100 text-gray-800">
                            <i class="fas fa-edit mr-1"></i> مسودة
                        </span>
                    @endif

                    <!-- Type Badge -->
                    @if($quiz->quiz_type == 'practice')
                        <span class="px-3 py-1 text-sm font-semibold rounded-full bg-blue-100 text-blue-800">تدريبي</span>
                    @elseif($quiz->quiz_type == 'timed')
                        <span class="px-3 py-1 text-sm font-semibold rounded-full bg-yellow-100 text-yellow-800">موقوت</span>
                    @else
                        <span class="px-3 py-1 text-sm font-semibold rounded-full bg-red-100 text-red-800">اختبار</span>
                    @endif

                    <!-- Difficulty Badge -->
                    @if($quiz->difficulty_level == 'easy')
                        <span class="px-3 py-1 text-sm font-semibold rounded-full bg-green-100 text-green-800">سهل</span>
                    @elseif($quiz->difficulty_level == 'medium')
                        <span class="px-3 py-1 text-sm font-semibold rounded-full bg-yellow-100 text-yellow-800">متوسط</span>
                    @else
                        <span class="px-3 py-1 text-sm font-semibold rounded-full bg-red-100 text-red-800">صعب</span>
                    @endif

                    @if($quiz->is_premium)
                        <span class="px-3 py-1 text-sm font-semibold rounded-full bg-purple-100 text-purple-800">
                            <i class="fas fa-crown mr-1"></i> مدفوع
                        </span>
                    @endif
                </div>

                <div class="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm text-gray-600">
                    <div>
                        <i class="fas fa-book text-blue-600 mr-2"></i>
                        <strong>المادة:</strong> {{ $quiz->subject->name_ar ?? '-' }}
                    </div>
                    <div>
                        <i class="fas fa-bookmark text-blue-600 mr-2"></i>
                        <strong>الفصل:</strong> {{ $quiz->chapter->title_ar ?? '-' }}
                    </div>
                    <div>
                        <i class="fas fa-clock text-blue-600 mr-2"></i>
                        <strong>الوقت المحدد:</strong> {{ $quiz->time_limit_minutes ? $quiz->time_limit_minutes . ' دقيقة' : 'غير محدود' }}
                    </div>
                    <div>
                        <i class="fas fa-check-double text-blue-600 mr-2"></i>
                        <strong>درجة النجاح:</strong> {{ $quiz->passing_score }}%
                    </div>
                </div>
            </div>

            <div class="flex gap-2">
                <a href="{{ route('admin.quizzes.edit', $quiz->id) }}"
                   class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
                    <i class="fas fa-edit mr-2"></i>
                    تعديل
                </a>
                @if($quiz->is_published)
                    <form method="POST" action="{{ route('admin.quizzes.unpublish', $quiz->id) }}" class="inline">
                        @csrf
                        <button type="submit" class="px-4 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700 transition-colors">
                            <i class="fas fa-eye-slash mr-2"></i>
                            إلغاء النشر
                        </button>
                    </form>
                @else
                    <form method="POST" action="{{ route('admin.quizzes.publish', $quiz->id) }}" class="inline">
                        @csrf
                        <button type="submit" class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors">
                            <i class="fas fa-check mr-2"></i>
                            نشر
                        </button>
                    </form>
                @endif
            </div>
        </div>
    </div>

    <!-- Statistics -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-500 text-sm mb-1">إجمالي المحاولات</p>
                    <p class="text-3xl font-bold text-blue-600">{{ number_format($stats['total_attempts']) }}</p>
                </div>
                <div class="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                    <i class="fas fa-users text-blue-600 text-xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-500 text-sm mb-1">متوسط الدرجات</p>
                    <p class="text-3xl font-bold text-green-600">{{ round($stats['average_score'], 1) }}%</p>
                </div>
                <div class="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                    <i class="fas fa-chart-line text-green-600 text-xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-500 text-sm mb-1">معدل النجاح</p>
                    <p class="text-3xl font-bold text-purple-600">{{ round($stats['pass_rate'], 1) }}%</p>
                </div>
                <div class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                    <i class="fas fa-percentage text-purple-600 text-xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-500 text-sm mb-1">معدل الإكمال</p>
                    <p class="text-3xl font-bold text-indigo-600">{{ round($stats['completion_rate'], 1) }}%</p>
                </div>
                <div class="w-12 h-12 bg-indigo-100 rounded-lg flex items-center justify-center">
                    <i class="fas fa-check-circle text-indigo-600 text-xl"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Questions List -->
    <div class="bg-white rounded-lg shadow-md p-6">
        <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold text-gray-900">
                <i class="fas fa-question-circle text-blue-600 mr-2"></i>
                الأسئلة ({{ $quiz->questions->count() }})
            </h3>
            <a href="{{ route('admin.quizzes.questions', $quiz->id) }}"
               class="px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors">
                <i class="fas fa-plus mr-2"></i>
                إدارة الأسئلة
            </a>
        </div>

        @if($quiz->questions->count() > 0)
            <div class="space-y-3">
                @foreach($quiz->questions as $index => $question)
                    <div class="border border-gray-200 rounded-lg p-4 hover:bg-gray-50 transition-colors">
                        <div class="flex items-start justify-between">
                            <div class="flex-1">
                                <div class="flex items-center gap-3 mb-2">
                                    <span class="flex items-center justify-center w-8 h-8 bg-blue-100 text-blue-600 rounded-full text-sm font-bold">
                                        {{ $index + 1 }}
                                    </span>
                                    <h4 class="font-medium text-gray-900">{{ $question->question_text_ar }}</h4>
                                </div>

                                <div class="flex flex-wrap gap-2 mr-11">
                                    <!-- Type Badge -->
                                    @if($question->question_type == 'single_choice')
                                        <span class="px-2 py-1 text-xs font-semibold rounded bg-blue-100 text-blue-800">اختيار من متعدد</span>
                                    @elseif($question->question_type == 'multiple_choice')
                                        <span class="px-2 py-1 text-xs font-semibold rounded bg-purple-100 text-purple-800">اختيار متعدد</span>
                                    @elseif($question->question_type == 'true_false')
                                        <span class="px-2 py-1 text-xs font-semibold rounded bg-green-100 text-green-800">صح/خطأ</span>
                                    @elseif($question->question_type == 'matching')
                                        <span class="px-2 py-1 text-xs font-semibold rounded bg-yellow-100 text-yellow-800">مطابقة</span>
                                    @elseif($question->question_type == 'ordering')
                                        <span class="px-2 py-1 text-xs font-semibold rounded bg-indigo-100 text-indigo-800">ترتيب</span>
                                    @elseif($question->question_type == 'fill_blank')
                                        <span class="px-2 py-1 text-xs font-semibold rounded bg-pink-100 text-pink-800">ملء الفراغات</span>
                                    @elseif($question->question_type == 'short_answer')
                                        <span class="px-2 py-1 text-xs font-semibold rounded bg-teal-100 text-teal-800">إجابة قصيرة</span>
                                    @else
                                        <span class="px-2 py-1 text-xs font-semibold rounded bg-orange-100 text-orange-800">رقمي</span>
                                    @endif

                                    <!-- Points Badge -->
                                    <span class="px-2 py-1 text-xs font-semibold rounded bg-gray-100 text-gray-800">
                                        <i class="fas fa-star text-yellow-500 mr-1"></i>
                                        {{ $question->points }} نقطة
                                    </span>

                                    <!-- Difficulty Badge -->
                                    @if($question->difficulty)
                                        @if($question->difficulty == 'easy')
                                            <span class="px-2 py-1 text-xs font-semibold rounded bg-green-100 text-green-800">سهل</span>
                                        @elseif($question->difficulty == 'medium')
                                            <span class="px-2 py-1 text-xs font-semibold rounded bg-yellow-100 text-yellow-800">متوسط</span>
                                        @else
                                            <span class="px-2 py-1 text-xs font-semibold rounded bg-red-100 text-red-800">صعب</span>
                                        @endif
                                    @endif
                                </div>
                            </div>
                        </div>
                    </div>
                @endforeach
            </div>
        @else
            <div class="text-center py-12">
                <i class="fas fa-question-circle text-6xl text-gray-300 mb-4"></i>
                <p class="text-gray-500 text-lg">لا توجد أسئلة في هذا الكويز</p>
                <a href="{{ route('admin.quizzes.questions', $quiz->id) }}"
                   class="inline-block mt-4 px-6 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors">
                    <i class="fas fa-plus mr-2"></i>
                    إضافة أسئلة
                </a>
            </div>
        @endif
    </div>

    <!-- Options and Tags -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <!-- Display Options -->
        <div class="bg-white rounded-lg shadow-md p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">
                <i class="fas fa-cog text-blue-600 mr-2"></i>
                خيارات العرض
            </h3>
            <div class="space-y-2">
                <div class="flex items-center justify-between">
                    <span class="text-gray-700">خلط الأسئلة</span>
                    @if($quiz->shuffle_questions)
                        <i class="fas fa-check-circle text-green-600"></i>
                    @else
                        <i class="fas fa-times-circle text-gray-400"></i>
                    @endif
                </div>
                <div class="flex items-center justify-between">
                    <span class="text-gray-700">خلط الإجابات</span>
                    @if($quiz->shuffle_answers)
                        <i class="fas fa-check-circle text-green-600"></i>
                    @else
                        <i class="fas fa-times-circle text-gray-400"></i>
                    @endif
                </div>
                <div class="flex items-center justify-between">
                    <span class="text-gray-700">إظهار الإجابات الصحيحة</span>
                    @if($quiz->show_correct_answers)
                        <i class="fas fa-check-circle text-green-600"></i>
                    @else
                        <i class="fas fa-times-circle text-gray-400"></i>
                    @endif
                </div>
                <div class="flex items-center justify-between">
                    <span class="text-gray-700">السماح بالمراجعة</span>
                    @if($quiz->allow_review)
                        <i class="fas fa-check-circle text-green-600"></i>
                    @else
                        <i class="fas fa-times-circle text-gray-400"></i>
                    @endif
                </div>
            </div>
        </div>

        <!-- Tags -->
        <div class="bg-white rounded-lg shadow-md p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">
                <i class="fas fa-tags text-blue-600 mr-2"></i>
                الوسوم
            </h3>
            @if($quiz->tags && count($quiz->tags) > 0)
                <div class="flex flex-wrap gap-2">
                    @foreach($quiz->tags as $tag)
                        <span class="px-3 py-1 bg-gray-100 text-gray-700 rounded-full text-sm">
                            <i class="fas fa-tag text-gray-500 mr-1"></i>
                            {{ $tag }}
                        </span>
                    @endforeach
                </div>
            @else
                <p class="text-gray-500 text-sm">لا توجد وسوم</p>
            @endif
        </div>
    </div>

    <!-- Actions -->
    <div class="flex items-center gap-3">
        <a href="{{ route('admin.quizzes.index') }}"
           class="px-6 py-3 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors">
            <i class="fas fa-arrow-right mr-2"></i>
            العودة للقائمة
        </a>
        <form method="POST" action="{{ route('admin.quizzes.duplicate', $quiz->id) }}" class="inline">
            @csrf
            <button type="submit" class="px-6 py-3 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors">
                <i class="fas fa-copy mr-2"></i>
                نسخ الكويز
            </button>
        </form>
        <a href="{{ route('admin.quizzes.analytics') }}"
           class="px-6 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors">
            <i class="fas fa-chart-bar mr-2"></i>
            عرض التحليلات
        </a>
        <form method="POST" action="{{ route('admin.quizzes.destroy', $quiz->id) }}"
              onsubmit="return confirm('هل أنت متأكد من حذف هذا الكويز؟ سيتم حذف جميع الأسئلة والمحاولات المرتبطة به.')"
              class="inline mr-auto">
            @csrf
            @method('DELETE')
            <button type="submit" class="px-6 py-3 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors">
                <i class="fas fa-trash mr-2"></i>
                حذف الكويز
            </button>
        </form>
    </div>
</div>
@endsection
