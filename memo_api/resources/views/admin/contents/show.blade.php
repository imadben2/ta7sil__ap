@extends('layouts.admin')

@section('title', $content->title_ar)
@section('page-title', $content->title_ar)
@section('page-description', 'عرض تفاصيل المحتوى التعليمي')

@section('content')
<div class="p-8">

    @if(session('success'))
    <div class="mb-6 bg-green-100 border-r-4 border-green-500 text-green-700 p-4 rounded">
        <div class="flex items-center">
            <i class="fas fa-check-circle mr-3"></i>
            <p>{{ session('success') }}</p>
        </div>
    </div>
    @endif

    <div class="flex gap-6">
        <!-- Main Content Area -->
        <div class="flex-1">
            <!-- Header Card -->
            <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
                <div class="flex justify-between items-start mb-4">
                    <div class="flex-1">
                        <div class="flex items-center gap-3 mb-3">
                            <span class="px-3 py-1 text-xs rounded-full bg-purple-100 text-purple-800">
                                <i class="fas fa-{{ $content->contentType->icon }} mr-1"></i>
                                {{ $content->contentType->name_ar }}
                            </span>
                            @if($content->difficulty_level == 'easy')
                                <span class="px-3 py-1 text-xs rounded-full bg-green-100 text-green-800">سهل</span>
                            @elseif($content->difficulty_level == 'medium')
                                <span class="px-3 py-1 text-xs rounded-full bg-yellow-100 text-yellow-800">متوسط</span>
                            @else
                                <span class="px-3 py-1 text-xs rounded-full bg-red-100 text-red-800">صعب</span>
                            @endif
                            @if($content->is_premium)
                                <span class="px-3 py-1 text-xs rounded-full bg-yellow-100 text-yellow-800">
                                    <i class="fas fa-crown mr-1"></i>
                                    مميز
                                </span>
                            @endif
                        </div>

                        <h1 class="text-2xl font-bold text-gray-900 mb-2">{{ $content->title_ar }}</h1>

                        <div class="flex items-center gap-4 text-sm text-gray-600">
                            <div>
                                <i class="fas fa-book mr-1 text-blue-600"></i>
                                <span>{{ $content->subject->name_ar }}</span>
                            </div>
                            @if($content->chapter)
                            <div>
                                <i class="fas fa-bookmark mr-1 text-green-600"></i>
                                <span>{{ $content->chapter->title_ar }}</span>
                            </div>
                            @endif
                            @if($content->estimated_duration_minutes)
                            <div>
                                <i class="fas fa-clock mr-1 text-orange-600"></i>
                                <span>{{ $content->estimated_duration_minutes }} دقيقة</span>
                            </div>
                            @endif
                        </div>
                    </div>

                    <div class="flex gap-2">
                        <a href="{{ route('admin.contents.edit', $content) }}"
                           class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors">
                            <i class="fas fa-edit mr-2"></i>
                            تعديل
                        </a>
                        @if($content->is_published)
                        <form action="{{ route('admin.contents.unpublish', $content) }}" method="POST" class="inline">
                            @csrf
                            <button type="submit" class="bg-yellow-600 hover:bg-yellow-700 text-white px-4 py-2 rounded-lg transition-colors">
                                <i class="fas fa-eye-slash mr-2"></i>
                                إلغاء النشر
                            </button>
                        </form>
                        @else
                        <form action="{{ route('admin.contents.publish', $content) }}" method="POST" class="inline">
                            @csrf
                            <button type="submit" class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg transition-colors">
                                <i class="fas fa-check mr-2"></i>
                                نشر
                            </button>
                        </form>
                        @endif
                    </div>
                </div>

                @if($content->description_ar)
                <div class="border-t border-gray-200 pt-4">
                    <p class="text-gray-700">{{ $content->description_ar }}</p>
                </div>
                @endif
            </div>

            <!-- Content Body -->
            @if($content->content_body_ar)
            <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
                <h2 class="text-xl font-semibold text-gray-800 mb-4">
                    <i class="fas fa-align-right mr-2 text-blue-600"></i>
                    المحتوى التعليمي
                </h2>
                <div class="prose prose-lg max-w-none">
                    {!! nl2br(e($content->content_body_ar)) !!}
                </div>
            </div>
            @endif

            <!-- Files & Media -->
            @if($content->pdf_path || $content->video_url || $content->video_path)
            <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
                <h2 class="text-xl font-semibold text-gray-800 mb-4">
                    <i class="fas fa-file-upload mr-2 text-blue-600"></i>
                    الملفات والوسائط
                </h2>

                <div class="space-y-3">
                    @if($content->pdf_path)
                    <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg border border-gray-200">
                        <div class="flex items-center">
                            <i class="fas fa-file-pdf text-red-600 text-2xl mr-3"></i>
                            <div>
                                <p class="font-medium text-gray-900">{{ basename($content->pdf_path) }}</p>
                                <p class="text-xs text-gray-500">ملف PDF</p>
                            </div>
                        </div>
                        <a href="{{ Storage::url($content->pdf_path) }}" target="_blank"
                           class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors text-sm">
                            <i class="fas fa-download mr-1"></i>
                            تحميل
                        </a>
                    </div>
                    @endif

                    @if($content->video_url)
                    <div class="p-4 bg-gray-50 rounded-lg border border-gray-200">
                        <div class="flex items-center mb-3">
                            <i class="fab fa-youtube text-red-600 text-2xl mr-3"></i>
                            <p class="font-medium text-gray-900">فيديو YouTube</p>
                        </div>
                        <a href="{{ $content->video_url }}" target="_blank" class="text-blue-600 hover:text-blue-800 text-sm break-all">
                            {{ $content->video_url }}
                        </a>
                    </div>
                    @endif

                    @if($content->video_path)
                    <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg border border-gray-200">
                        <div class="flex items-center">
                            <i class="fas fa-video text-blue-600 text-2xl mr-3"></i>
                            <div>
                                <p class="font-medium text-gray-900">{{ basename($content->video_path) }}</p>
                                <p class="text-xs text-gray-500">ملف فيديو</p>
                            </div>
                        </div>
                        <a href="{{ Storage::url($content->video_path) }}" target="_blank"
                           class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors text-sm">
                            <i class="fas fa-play mr-1"></i>
                            تشغيل
                        </a>
                    </div>
                    @endif
                </div>
            </div>
            @endif

            <!-- Tags & Keywords -->
            @if($content->tags || $content->search_keywords)
            <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
                <h2 class="text-xl font-semibold text-gray-800 mb-4">
                    <i class="fas fa-tags mr-2 text-blue-600"></i>
                    الكلمات المفتاحية
                </h2>

                @if($content->tags && is_array($content->tags))
                <div class="mb-4">
                    <p class="text-sm font-medium text-gray-700 mb-2">Tags:</p>
                    <div class="flex flex-wrap gap-2">
                        @foreach($content->tags as $tag)
                        <span class="px-3 py-1 text-sm bg-blue-100 text-blue-800 rounded-full">
                            #{{ $tag }}
                        </span>
                        @endforeach
                    </div>
                </div>
                @endif

                @if($content->search_keywords)
                <div>
                    <p class="text-sm font-medium text-gray-700 mb-2">كلمات البحث:</p>
                    <p class="text-sm text-gray-600">{{ $content->search_keywords }}</p>
                </div>
                @endif
            </div>
            @endif
        </div>

        <!-- Sidebar -->
        <div class="w-80">
            <!-- Status Card -->
            <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
                <h3 class="text-lg font-semibold text-gray-800 mb-4">
                    <i class="fas fa-info-circle mr-2 text-blue-600"></i>
                    الحالة
                </h3>

                <div class="space-y-3 text-sm">
                    <div class="flex justify-between">
                        <span class="text-gray-600">الحالة:</span>
                        @if($content->is_published)
                            <span class="px-2 py-1 text-xs rounded-full bg-green-100 text-green-800">منشور</span>
                        @else
                            <span class="px-2 py-1 text-xs rounded-full bg-gray-100 text-gray-800">مسودة</span>
                        @endif
                    </div>

                    @if($content->is_published && $content->published_at)
                    <div class="flex justify-between">
                        <span class="text-gray-600">تاريخ النشر:</span>
                        <span class="text-gray-900">{{ $content->published_at->format('Y-m-d') }}</span>
                    </div>
                    @endif

                    <div class="flex justify-between">
                        <span class="text-gray-600">تاريخ الإنشاء:</span>
                        <span class="text-gray-900">{{ $content->created_at->format('Y-m-d') }}</span>
                    </div>

                    <div class="flex justify-between">
                        <span class="text-gray-600">آخر تحديث:</span>
                        <span class="text-gray-900">{{ $content->updated_at->diffForHumans() }}</span>
                    </div>

                    @if($content->creator)
                    <div class="flex justify-between">
                        <span class="text-gray-600">المنشئ:</span>
                        <span class="text-gray-900">{{ $content->creator->full_name }}</span>
                    </div>
                    @endif

                    @if($content->updater)
                    <div class="flex justify-between">
                        <span class="text-gray-600">آخر محدث:</span>
                        <span class="text-gray-900">{{ $content->updater->full_name }}</span>
                    </div>
                    @endif
                </div>
            </div>

            <!-- Statistics Card -->
            <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
                <h3 class="text-lg font-semibold text-gray-800 mb-4">
                    <i class="fas fa-chart-bar mr-2 text-green-600"></i>
                    الإحصائيات
                </h3>

                <div class="space-y-4">
                    <div class="text-center p-4 bg-blue-50 rounded-lg">
                        <div class="text-3xl font-bold text-blue-600">{{ $content->views_count }}</div>
                        <div class="text-sm text-gray-600 mt-1">
                            <i class="fas fa-eye"></i> مشاهدة
                        </div>
                    </div>

                    <div class="text-center p-4 bg-green-50 rounded-lg">
                        <div class="text-3xl font-bold text-green-600">{{ $content->downloads_count }}</div>
                        <div class="text-sm text-gray-600 mt-1">
                            <i class="fas fa-download"></i> تحميل
                        </div>
                    </div>

                    <div class="text-center p-4 bg-yellow-50 rounded-lg">
                        <div class="text-3xl font-bold text-yellow-600">
                            @if($content->average_rating)
                                {{ number_format($content->average_rating, 1) }}
                            @else
                                -
                            @endif
                        </div>
                        <div class="text-sm text-gray-600 mt-1">
                            <i class="fas fa-star"></i>
                            التقييم ({{ $content->total_ratings }} تقييم)
                        </div>
                    </div>

                    <div class="text-center p-4 bg-purple-50 rounded-lg">
                        <div class="text-3xl font-bold text-purple-600">{{ $content->completed_count ?? 0 }}</div>
                        <div class="text-sm text-gray-600 mt-1">
                            <i class="fas fa-check-circle"></i> إكمال
                        </div>
                    </div>
                </div>
            </div>

            <!-- Quick Actions -->
            <div class="bg-white rounded-lg shadow-sm p-6">
                <h3 class="text-lg font-semibold text-gray-800 mb-4">
                    <i class="fas fa-bolt mr-2 text-orange-600"></i>
                    إجراءات سريعة
                </h3>

                <div class="space-y-2">
                    <a href="{{ route('admin.contents.index') }}"
                       class="block text-center bg-gray-100 hover:bg-gray-200 text-gray-700 px-4 py-2 rounded-lg transition-colors">
                        <i class="fas fa-list mr-2"></i>
                        كل المحتويات
                    </a>

                    <a href="{{ route('admin.contents.create') }}"
                       class="block text-center bg-blue-100 hover:bg-blue-200 text-blue-700 px-4 py-2 rounded-lg transition-colors">
                        <i class="fas fa-plus mr-2"></i>
                        إضافة محتوى جديد
                    </a>

                    <form action="{{ route('admin.contents.destroy', $content) }}" method="POST"
                          onsubmit="return confirm('هل أنت متأكد من حذف هذا المحتوى؟')">
                        @csrf
                        @method('DELETE')
                        <button type="submit"
                                class="w-full bg-red-100 hover:bg-red-200 text-red-700 px-4 py-2 rounded-lg transition-colors">
                            <i class="fas fa-trash mr-2"></i>
                            حذف المحتوى
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

</div>
@endsection
