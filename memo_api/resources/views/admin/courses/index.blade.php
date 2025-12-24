@extends('layouts.admin')

@section('title', 'إدارة الدورات')
@section('page-title', 'إدارة الدورات')
@section('page-description', 'عرض وإدارة جميع الدورات المدفوعة')

@section('content')
<div class="space-y-6" style="font-family: 'Cairo', sans-serif; direction: rtl;">
    <!-- Enhanced Header with Gradient -->
    <div class="bg-gradient-to-r from-blue-600 to-blue-800 rounded-xl shadow-lg p-6">
        <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
            <div class="text-white">
                <h2 class="text-2xl font-bold mb-2">مكتبة الدورات التعليمية</h2>
                <p class="text-blue-100">إدارة شاملة لجميع الدورات والمحتوى التعليمي</p>
            </div>
            <div class="flex gap-3">
                <a href="{{ route('admin.courses.create') }}"
                   class="bg-white text-blue-600 hover:bg-blue-50 px-6 py-3 rounded-lg flex items-center gap-2 shadow-md font-semibold">
                    <i class="fas fa-plus-circle"></i>
                    <span>إضافة دورة جديدة</span>
                </a>
                <a href="{{ route('admin.exports.courses') }}"
                   class="bg-green-500 hover:bg-green-600 text-white px-6 py-3 rounded-lg flex items-center gap-2 shadow-md">
                    <i class="fas fa-file-download"></i>
                    <span>تصدير</span>
                </a>
            </div>
        </div>
    </div>

    <!-- Enhanced Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div class="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-blue-100 text-sm font-medium mb-1">إجمالي الدورات</p>
                    <p class="text-4xl font-bold">{{ $totalCourses ?? 0 }}</p>
                    <p class="text-blue-100 text-xs mt-2">جميع الدورات المسجلة</p>
                </div>
                <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center">
                    <i class="fas fa-video text-3xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-gradient-to-br from-green-500 to-green-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-green-100 text-sm font-medium mb-1">الدورات المنشورة</p>
                    <p class="text-4xl font-bold">{{ $publishedCourses ?? 0 }}</p>
                    <p class="text-green-100 text-xs mt-2">متاحة للطلاب حالياً</p>
                </div>
                <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center">
                    <i class="fas fa-check-circle text-3xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-gradient-to-br from-yellow-500 to-orange-500 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-yellow-100 text-sm font-medium mb-1">المسودات</p>
                    <p class="text-4xl font-bold">{{ $draftCourses ?? 0 }}</p>
                    <p class="text-yellow-100 text-xs mt-2">بانتظار النشر</p>
                </div>
                <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center">
                    <i class="fas fa-pencil-alt text-3xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-gradient-to-br from-purple-500 to-pink-500 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-purple-100 text-sm font-medium mb-1">إجمالي الطلاب</p>
                    <p class="text-4xl font-bold">{{ $totalEnrollments ?? 0 }}</p>
                    <p class="text-purple-100 text-xs mt-2">طالب مسجل</p>
                </div>
                <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center">
                    <i class="fas fa-user-graduate text-3xl"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Enhanced Filters Section -->
    <div class="bg-white rounded-xl shadow-md overflow-hidden">
        <div class="bg-gray-50 border-b border-gray-200 px-6 py-4">
            <h3 class="text-lg font-semibold text-gray-800 flex items-center gap-2">
                <i class="fas fa-filter text-blue-600"></i>
                البحث والتصفية
            </h3>
        </div>
        <form method="GET" action="{{ route('admin.courses.index') }}" class="p-6">
            <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        <i class="fas fa-search text-gray-400 ml-1"></i>
                        البحث
                    </label>
                    <input type="text" name="search" value="{{ request('search') }}"
                           placeholder="ابحث بالعنوان أو المدرب..."
                           class="w-full px-4 py-2.5 border-2 border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                </div>
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        <i class="fas fa-book text-gray-400 ml-1"></i>
                        المادة
                    </label>
                    <select name="subject_id" class="w-full px-4 py-2.5 border-2 border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                        <option value="">جميع المواد</option>
                        @foreach(\App\Models\Subject::all() as $subject)
                            <option value="{{ $subject->id }}" {{ request('subject_id') == $subject->id ? 'selected' : '' }}>
                                {{ $subject->name_ar }}
                            </option>
                        @endforeach
                    </select>
                </div>
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        <i class="fas fa-toggle-on text-gray-400 ml-1"></i>
                        الحالة
                    </label>
                    <select name="is_published" class="w-full px-4 py-2.5 border-2 border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                        <option value="">الكل</option>
                        <option value="1" {{ request('is_published') === '1' ? 'selected' : '' }}>منشورة</option>
                        <option value="0" {{ request('is_published') === '0' ? 'selected' : '' }}>مسودة</option>
                    </select>
                </div>
                <div class="flex items-end gap-2">
                    <button type="submit" class="flex-1 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white px-4 py-2.5 rounded-lg font-semibold shadow-md">
                        <i class="fas fa-search ml-2"></i>بحث
                    </button>
                    <a href="{{ route('admin.courses.index') }}" class="bg-gray-100 hover:bg-gray-200 text-gray-700 px-4 py-2.5 rounded-lg">
                        <i class="fas fa-redo"></i>
                    </a>
                </div>
            </div>
        </form>
    </div>

    <!-- Enhanced Courses Grid -->
    <div class="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-6">
        @forelse($courses as $course)
            <div class="bg-white rounded-xl shadow-md overflow-hidden border border-gray-100">
                <!-- Course Thumbnail -->
                <div class="relative h-48 overflow-hidden">
                    @if($course->thumbnail_url)
                        <img src="{{ Storage::url($course->thumbnail_url) }}"
                             alt="{{ $course->title_ar }}"
                             class="w-full h-full object-cover">
                    @else
                        <div class="w-full h-full bg-gradient-to-br from-blue-400 to-blue-600 flex items-center justify-center">
                            <i class="fas fa-video text-white text-6xl opacity-50"></i>
                        </div>
                    @endif

                    <!-- Status Badge -->
                    <div class="absolute top-3 left-3">
                        @if($course->is_published)
                            <span class="px-3 py-1.5 text-xs font-bold rounded-full bg-green-500 text-white shadow-lg flex items-center gap-1">
                                <i class="fas fa-check-circle"></i>
                                منشورة
                            </span>
                        @else
                            <span class="px-3 py-1.5 text-xs font-bold rounded-full bg-gray-500 text-white shadow-lg flex items-center gap-1">
                                <i class="fas fa-edit"></i>
                                مسودة
                            </span>
                        @endif
                    </div>

                    <!-- Featured Badge -->
                    @if($course->featured)
                        <div class="absolute top-3 right-3">
                            <span class="px-3 py-1.5 text-xs font-bold rounded-full bg-yellow-500 text-white shadow-lg flex items-center gap-1">
                                <i class="fas fa-star"></i>
                                مميزة
                            </span>
                        </div>
                    @endif

                    <!-- Price Tag -->
                    <div class="absolute bottom-3 right-3">
                        @if($course->is_free)
                            <span class="px-4 py-2 text-sm font-bold rounded-lg bg-green-500 text-white shadow-lg">
                                مجانية
                            </span>
                        @else
                            <span class="px-4 py-2 text-sm font-bold rounded-lg bg-blue-600 text-white shadow-lg">
                                {{ number_format($course->price_dzd) }} دج
                            </span>
                        @endif
                    </div>
                </div>

                <!-- Course Info -->
                <div class="p-5">
                    <!-- Title & Instructor -->
                    <div class="mb-4">
                        <h3 class="text-lg font-bold text-gray-900 mb-2 line-clamp-2 hover:text-blue-600">
                            {{ $course->title_ar }}
                        </h3>
                        <p class="text-sm text-gray-600 flex items-center gap-2">
                            <i class="fas fa-chalkboard-teacher text-blue-500"></i>
                            {{ $course->instructor_name }}
                        </p>
                    </div>

                    <!-- Stats Row -->
                    <div class="grid grid-cols-3 gap-3 mb-4 pb-4 border-b border-gray-100">
                        <div class="text-center">
                            <p class="text-xs text-gray-500 mb-1">الطلاب</p>
                            <p class="text-lg font-bold text-blue-600">{{ $course->enrollment_count }}</p>
                        </div>
                        <div class="text-center">
                            <p class="text-xs text-gray-500 mb-1">التقييم</p>
                            <p class="text-lg font-bold text-yellow-500 flex items-center justify-center gap-1">
                                <i class="fas fa-star text-sm"></i>
                                {{ number_format($course->average_rating, 1) }}
                            </p>
                        </div>
                        <div class="text-center">
                            <p class="text-xs text-gray-500 mb-1">المراجعات</p>
                            <p class="text-lg font-bold text-gray-700">{{ $course->total_reviews }}</p>
                        </div>
                    </div>

                    <!-- Subject Badge -->
                    @if($course->subject)
                        <div class="mb-4">
                            <span class="px-3 py-1 text-xs font-semibold rounded-full bg-purple-100 text-purple-700">
                                <i class="fas fa-tag ml-1"></i>
                                {{ $course->subject->name_ar }}
                            </span>
                        </div>
                    @endif

                    <!-- Action Buttons -->
                    <div class="flex gap-2">
                        <a href="{{ route('admin.courses.show', $course) }}"
                           class="flex-1 bg-blue-50 hover:bg-blue-100 text-blue-600 py-2.5 rounded-lg text-center font-semibold text-sm">
                            <i class="fas fa-eye ml-1"></i>
                            عرض
                        </a>
                        <a href="{{ route('admin.courses.edit', $course) }}"
                           class="flex-1 bg-green-50 hover:bg-green-100 text-green-600 py-2.5 rounded-lg text-center font-semibold text-sm">
                            <i class="fas fa-edit ml-1"></i>
                            تعديل
                        </a>
                        <button onclick="deleteCourse({{ $course->id }})"
                                class="px-4 bg-red-50 hover:bg-red-100 text-red-600 py-2.5 rounded-lg font-semibold text-sm">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>

                    <!-- Quick Actions -->
                    <div class="mt-3 pt-3 border-t border-gray-100 flex gap-2">
                        @if($course->is_published)
                            <form action="{{ route('admin.courses.unpublish', $course) }}" method="POST" class="flex-1">
                                @csrf
                                <button type="submit" class="w-full text-xs bg-orange-50 hover:bg-orange-100 text-orange-600 py-2 rounded-lg font-semibold">
                                    <i class="fas fa-eye-slash ml-1"></i>
                                    إلغاء النشر
                                </button>
                            </form>
                        @else
                            <form action="{{ route('admin.courses.publish', $course) }}" method="POST" class="flex-1">
                                @csrf
                                <button type="submit" class="w-full text-xs bg-green-50 hover:bg-green-100 text-green-600 py-2 rounded-lg font-semibold">
                                    <i class="fas fa-check-circle ml-1"></i>
                                    نشر الدورة
                                </button>
                            </form>
                        @endif
                    </div>
                </div>
            </div>
        @empty
            <div class="col-span-full">
                <div class="bg-white rounded-xl shadow-md p-12 text-center">
                    <div class="w-24 h-24 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
                        <i class="fas fa-video text-gray-400 text-5xl"></i>
                    </div>
                    <h3 class="text-2xl font-bold text-gray-700 mb-2">لا توجد دورات</h3>
                    <p class="text-gray-500 mb-6">ابدأ بإضافة دورات تعليمية جديدة للمنصة</p>
                    <a href="{{ route('admin.courses.create') }}"
                       class="inline-flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-8 py-3 rounded-lg font-semibold shadow-md">
                        <i class="fas fa-plus-circle"></i>
                        إضافة دورة جديدة
                    </a>
                </div>
            </div>
        @endforelse
    </div>

    <!-- Pagination -->
    @if($courses->hasPages())
        <div class="bg-white rounded-xl shadow-md p-6">
            {{ $courses->links() }}
        </div>
    @endif
</div>

<!-- Delete Confirmation Script -->
<script>
function deleteCourse(id) {
    if (confirm('هل أنت متأكد من حذف هذه الدورة؟\nسيتم حذف جميع الوحدات والدروس المرتبطة بها.')) {
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = `/admin/courses/${id}`;

        const csrfToken = document.createElement('input');
        csrfToken.type = 'hidden';
        csrfToken.name = '_token';
        csrfToken.value = '{{ csrf_token() }}';

        const methodField = document.createElement('input');
        methodField.type = 'hidden';
        methodField.name = '_method';
        methodField.value = 'DELETE';

        form.appendChild(csrfToken);
        form.appendChild(methodField);
        document.body.appendChild(form);
        form.submit();
    }
}
</script>
@endsection
