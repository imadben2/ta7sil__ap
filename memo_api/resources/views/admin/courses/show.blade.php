@extends('layouts.admin')

@section('title', $course->title_ar)
@section('page-title', $course->title_ar)

@section('content')
<div class="space-y-6" style="font-family: 'Cairo', sans-serif; direction: rtl;">
    <!-- Enhanced Course Header -->
    <div class="bg-gradient-to-r from-blue-600 to-indigo-600 rounded-xl shadow-lg p-6">
        <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
            <div class="flex-1">
                <div class="flex items-center gap-3 mb-3 flex-wrap">
                    @if($course->is_published)
                        <span class="px-4 py-2 text-sm font-bold rounded-lg bg-green-500 text-white shadow-md flex items-center gap-2">
                            <i class="fas fa-check-circle"></i>
                            منشورة
                        </span>
                    @else
                        <span class="px-4 py-2 text-sm font-bold rounded-lg bg-gray-400 text-white shadow-md flex items-center gap-2">
                            <i class="fas fa-file-alt"></i>
                            مسودة
                        </span>
                    @endif
                    @if($course->featured)
                        <span class="px-4 py-2 text-sm font-bold rounded-lg bg-yellow-400 text-gray-900 shadow-md flex items-center gap-2">
                            <i class="fas fa-star"></i>
                            مميزة
                        </span>
                    @endif
                </div>
                <h1 class="text-2xl font-bold text-white mb-2">{{ $course->title_ar }}</h1>
                <p class="text-blue-100 flex items-center gap-2 mb-3">
                    <i class="fas fa-chalkboard-teacher"></i>
                    {{ $course->instructor_name }}
                </p>
                <div class="flex items-center gap-4 flex-wrap text-sm text-blue-100">
                    <span class="flex items-center gap-2 bg-white bg-opacity-20 px-3 py-1 rounded-lg">
                        <i class="fas fa-users"></i>
                        {{ $course->enrollment_count ?? 0 }} طالب
                    </span>
                    <span class="flex items-center gap-2 bg-white bg-opacity-20 px-3 py-1 rounded-lg">
                        <i class="fas fa-star text-yellow-300"></i>
                        {{ number_format($course->average_rating ?? 0, 1) }} ({{ $course->total_reviews ?? 0 }} تقييم)
                    </span>
                    <span class="flex items-center gap-2 bg-white bg-opacity-20 px-3 py-1 rounded-lg">
                        <i class="fas fa-eye"></i>
                        {{ $course->view_count ?? 0 }} مشاهدة
                    </span>
                </div>
            </div>
            <div class="flex gap-3 flex-wrap">
                <a href="{{ route('admin.courses.edit', $course) }}"
                   class="px-6 py-3 bg-white text-blue-600 rounded-lg hover:bg-blue-50 font-bold shadow-md transition-all flex items-center gap-2">
                    <i class="fas fa-edit"></i>
                    تعديل الدورة
                </a>
                @if($course->is_published)
                    <form action="{{ route('admin.courses.unpublish', $course) }}" method="POST">
                        @csrf
                        <button class="px-6 py-3 bg-orange-500 hover:bg-orange-600 text-white rounded-lg font-bold shadow-md transition-all flex items-center gap-2">
                            <i class="fas fa-eye-slash"></i>
                            إلغاء النشر
                        </button>
                    </form>
                @else
                    <form action="{{ route('admin.courses.publish', $course) }}" method="POST">
                        @csrf
                        <button class="px-6 py-3 bg-green-500 hover:bg-green-600 text-white rounded-lg font-bold shadow-md transition-all flex items-center gap-2">
                            <i class="fas fa-check-circle"></i>
                            نشر الدورة
                        </button>
                    </form>
                @endif
                @if($course->enrollment_count > 0)
                    <form action="{{ route('admin.courses.delete-enrollments', $course) }}" method="POST"
                          onsubmit="return confirm('تحذير: سيتم حذف جميع الاشتراكات ({{ $course->enrollment_count }} اشتراك) لهذه الدورة!\n\nهل أنت متأكد من المتابعة؟');">
                        @csrf
                        @method('DELETE')
                        <button type="submit" class="px-6 py-3 bg-red-500 hover:bg-red-600 text-white rounded-lg font-bold shadow-md transition-all flex items-center gap-2">
                            <i class="fas fa-trash-alt"></i>
                            حذف جميع الاشتراكات ({{ $course->enrollment_count }})
                        </button>
                    </form>
                @endif
            </div>
        </div>
    </div>

    <!-- Enhanced Statistics -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div class="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-blue-100 text-xs font-medium mb-1">عدد الوحدات</p>
                    <p class="text-4xl font-bold">{{ $course->total_modules ?? 0 }}</p>
                </div>
                <div class="w-14 h-14 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                    <i class="fas fa-layer-group text-2xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-gradient-to-br from-green-500 to-green-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-green-100 text-xs font-medium mb-1">عدد الدروس</p>
                    <p class="text-4xl font-bold">{{ $course->total_lessons ?? 0 }}</p>
                </div>
                <div class="w-14 h-14 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                    <i class="fas fa-play-circle text-2xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-gradient-to-br from-purple-500 to-purple-600 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-purple-100 text-xs font-medium mb-1">الطلاب المسجلين</p>
                    <p class="text-4xl font-bold">{{ $course->enrollment_count ?? 0 }}</p>
                </div>
                <div class="w-14 h-14 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                    <i class="fas fa-user-graduate text-2xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-gradient-to-br from-yellow-500 to-orange-500 rounded-xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-yellow-100 text-xs font-medium mb-1">التقييم</p>
                    <p class="text-4xl font-bold flex items-center gap-2">
                        {{ number_format($course->average_rating ?? 0, 1) }}
                        <i class="fas fa-star text-2xl"></i>
                    </p>
                </div>
                <div class="w-14 h-14 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                    <i class="fas fa-star text-2xl"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Course Content (Modules & Lessons) with Drag & Drop -->
    <div class="bg-white rounded-xl shadow-lg p-6">
        <div class="flex justify-between items-center mb-6">
            <div class="flex items-center gap-3">
                <div class="w-12 h-12 bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg flex items-center justify-center text-white">
                    <i class="fas fa-book-open text-xl"></i>
                </div>
                <div>
                    <h3 class="text-2xl font-bold text-gray-900">محتوى الدورة</h3>
                    <p class="text-sm text-gray-500">اسحب العناصر لإعادة الترتيب</p>
                </div>
            </div>
            <button onclick="openModal('addModuleModal')"
                    class="px-6 py-3 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white rounded-xl font-bold shadow-lg transition-all flex items-center gap-2">
                <i class="fas fa-plus-circle"></i>
                إضافة وحدة جديدة
            </button>
        </div>

        <div id="modulesList" class="space-y-4">
            @forelse($course->modules()->orderBy('order')->get() as $module)
                <div class="module-item border-2 border-gray-200 rounded-xl overflow-hidden hover:border-blue-300 transition-all" data-id="{{ $module->id }}">
                    <div class="bg-gradient-to-r from-gray-50 to-gray-100 px-6 py-4 flex justify-between items-center cursor-move">
                        <div class="flex items-center gap-4">
                            <div class="drag-handle text-gray-400 hover:text-gray-600 cursor-grab active:cursor-grabbing">
                                <i class="fas fa-grip-vertical text-xl"></i>
                            </div>
                            <div class="w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg flex items-center justify-center text-white font-bold">
                                {{ $module->order }}
                            </div>
                            <div>
                                <h4 class="font-bold text-lg text-gray-900">{{ $module->title_ar }}</h4>
                                <p class="text-sm text-gray-500 flex items-center gap-3">
                                    <span class="flex items-center gap-1">
                                        <i class="fas fa-video text-blue-500"></i>
                                        {{ $module->lessons->count() }} دروس
                                    </span>
                                    @if($module->description_ar)
                                        <span class="text-gray-400">•</span>
                                        <span class="truncate max-w-md">{{ Str::limit($module->description_ar, 50) }}</span>
                                    @endif
                                </p>
                            </div>
                        </div>
                        <div class="flex gap-2">
                            <button onclick="openAddLessonModal({{ $module->id }})"
                                    class="px-4 py-2 bg-blue-50 hover:bg-blue-100 text-blue-600 rounded-lg font-semibold transition-all flex items-center gap-2"
                                    title="إضافة درس">
                                <i class="fas fa-plus-circle"></i>
                                درس جديد
                            </button>
                            <button onclick="openEditModuleModal({{ $module->id }}, '{{ addslashes($module->title_ar) }}', '{{ addslashes($module->description_ar ?? '') }}', {{ $module->order }})"
                                    class="px-4 py-2 bg-green-50 hover:bg-green-100 text-green-600 rounded-lg font-semibold transition-all"
                                    title="تعديل">
                                <i class="fas fa-edit"></i>
                            </button>
                            <button onclick="confirmDeleteModule({{ $module->id }}, '{{ addslashes($module->title_ar) }}')"
                                    class="px-4 py-2 bg-red-50 hover:bg-red-100 text-red-600 rounded-lg font-semibold transition-all"
                                    title="حذف">
                                <i class="fas fa-trash"></i>
                            </button>
                        </div>
                    </div>
                    <div class="p-5 bg-white">
                        <div id="lessonsList-{{ $module->id }}" class="space-y-2">
                            @foreach($module->lessons()->orderBy('order')->get() as $lesson)
                                <div class="lesson-item flex items-center justify-between py-3 px-4 bg-gray-50 hover:bg-blue-50 rounded-lg border border-gray-200 hover:border-blue-300 transition-all" data-id="{{ $lesson->id }}">
                                    <div class="flex items-center gap-3 flex-1">
                                        <div class="lesson-drag-handle text-gray-400 hover:text-gray-600 cursor-grab active:cursor-grabbing">
                                            <i class="fas fa-grip-lines"></i>
                                        </div>
                                        @php
                                            $contentType = $lesson->content_type ?? 'video';
                                            $iconConfig = [
                                                'video' => ['icon' => 'fa-play', 'gradient' => 'from-purple-500 to-pink-500'],
                                                'document' => ['icon' => 'fa-file-pdf', 'gradient' => 'from-blue-500 to-cyan-500'],
                                                'quiz' => ['icon' => 'fa-question-circle', 'gradient' => 'from-green-500 to-emerald-500'],
                                                'text' => ['icon' => 'fa-align-right', 'gradient' => 'from-orange-500 to-amber-500']
                                            ];
                                            $config = $iconConfig[$contentType] ?? $iconConfig['video'];
                                        @endphp
                                        <div class="w-10 h-10 bg-gradient-to-br {{ $config['gradient'] }} rounded-lg flex items-center justify-center text-white">
                                            <i class="fas {{ $config['icon'] }} text-sm"></i>
                                        </div>
                                        <div class="flex-1">
                                            <h5 class="font-semibold text-gray-900">{{ $lesson->title_ar }}</h5>
                                            <div class="flex items-center gap-3 text-xs text-gray-500 mt-1">
                                                @if($contentType === 'video')
                                                    <span class="flex items-center gap-1">
                                                        <i class="fas fa-clock text-blue-500"></i>
                                                        {{ gmdate('H:i:s', $lesson->video_duration_seconds ?? 0) }}
                                                    </span>
                                                    <span class="flex items-center gap-1">
                                                        <i class="fas fa-{{ $lesson->video_type === 'youtube' ? 'youtube text-red-500' : 'upload text-green-500' }}"></i>
                                                        {{ $lesson->video_type === 'youtube' ? 'يوتيوب' : 'مرفوع' }}
                                                    </span>
                                                @elseif($contentType === 'document')
                                                    <span class="flex items-center gap-1">
                                                        <i class="fas fa-file-alt text-blue-500"></i>
                                                        مستند
                                                    </span>
                                                @elseif($contentType === 'quiz')
                                                    <span class="flex items-center gap-1">
                                                        <i class="fas fa-question-circle text-green-500"></i>
                                                        كويز
                                                    </span>
                                                @elseif($contentType === 'text')
                                                    <span class="flex items-center gap-1">
                                                        <i class="fas fa-paragraph text-orange-500"></i>
                                                        محتوى نصي
                                                    </span>
                                                @endif
                                                @if($lesson->is_free_preview ?? $lesson->is_preview ?? false)
                                                    <span class="px-2 py-0.5 bg-green-100 text-green-700 rounded-full font-semibold">
                                                        <i class="fas fa-eye"></i>
                                                        معاينة مجانية
                                                    </span>
                                                @endif
                                            </div>
                                        </div>
                                    </div>
                                    <div class="flex gap-2">
                                        <button onclick="openViewLessonModal({{ $lesson->id }})"
                                                class="px-3 py-2 bg-blue-50 hover:bg-blue-100 text-blue-600 rounded-lg text-sm font-semibold transition-all">
                                            <i class="fas fa-eye"></i>
                                            عرض
                                        </button>
                                        <button onclick="openEditLessonModal({{ $lesson->id }})"
                                                class="px-3 py-2 bg-green-50 hover:bg-green-100 text-green-600 rounded-lg text-sm font-semibold transition-all">
                                            <i class="fas fa-edit"></i>
                                            تعديل
                                        </button>
                                        <button onclick="confirmDeleteLesson({{ $lesson->id }}, '{{ addslashes($lesson->title_ar) }}')"
                                                class="px-3 py-2 bg-red-50 hover:bg-red-100 text-red-600 rounded-lg text-sm font-semibold transition-all">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </div>
                            @endforeach
                        </div>
                    </div>
                </div>
            @empty
                <div class="text-center py-16 bg-gradient-to-br from-gray-50 to-blue-50 rounded-xl border-2 border-dashed border-gray-300">
                    <div class="w-24 h-24 bg-gray-200 rounded-full flex items-center justify-center mx-auto mb-4">
                        <i class="fas fa-folder-open text-gray-400 text-5xl"></i>
                    </div>
                    <h3 class="text-xl font-bold text-gray-700 mb-2">لم يتم إضافة وحدات بعد</h3>
                    <p class="text-gray-500 mb-6">ابدأ ببناء محتوى الدورة بإضافة الوحدات والدروس</p>
                    <button onclick="openModal('addModuleModal')"
                            class="px-8 py-3 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white rounded-xl font-bold shadow-lg transition-all inline-flex items-center gap-2">
                        <i class="fas fa-plus-circle"></i>
                        إضافة وحدة جديدة
                    </button>
                </div>
            @endforelse
        </div>
    </div>
</div>

<!-- Enhanced Add Module Modal -->
<div id="addModuleModal" class="hidden fixed inset-0 bg-black bg-opacity-60 backdrop-blur-sm overflow-y-auto h-full w-full z-50" style="font-family: 'Cairo', sans-serif; direction: rtl;">
    <div class="relative top-20 mx-auto p-0 border-0 w-full max-w-2xl">
        <div class="bg-white rounded-2xl shadow-2xl overflow-hidden">
            <!-- Modal Header -->
            <div class="bg-gradient-to-r from-blue-600 to-indigo-600 px-6 py-5">
                <div class="flex justify-between items-center">
                    <div class="flex items-center gap-3 text-white">
                        <div class="w-10 h-10 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                            <i class="fas fa-plus-circle text-xl"></i>
                        </div>
                        <h3 class="text-xl font-bold">إضافة وحدة جديدة</h3>
                    </div>
                    <button onclick="closeModal('addModuleModal')" class="text-white hover:bg-white hover:bg-opacity-20 w-8 h-8 rounded-lg transition-all">
                        <i class="fas fa-times text-xl"></i>
                    </button>
                </div>
            </div>

            <!-- Modal Body -->
            <form action="{{ route('admin.courses.modules.store', $course) }}" method="POST" class="p-6">
                @csrf
                <div class="space-y-5">
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                            <i class="fas fa-heading text-blue-500 text-xs"></i>
                            عنوان الوحدة *
                        </label>
                        <input type="text" name="title_ar" required
                               class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all"
                               placeholder="مثال: مقدمة في البرمجة">
                    </div>

                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                            <i class="fas fa-align-right text-blue-500 text-xs"></i>
                            الوصف
                        </label>
                        <textarea name="description_ar" rows="4"
                                  class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all"
                                  placeholder="وصف مختصر عن محتوى الوحدة"></textarea>
                    </div>

                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                            <i class="fas fa-sort-numeric-up text-blue-500 text-xs"></i>
                            الترتيب
                        </label>
                        <input type="number" name="order" value="{{ $course->modules->count() + 1 }}" min="0"
                               class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 transition-all">
                    </div>

                    <div class="flex items-center bg-blue-50 border-2 border-blue-200 rounded-xl p-4">
                        <input type="checkbox" name="is_published" value="1" id="module_published" class="w-5 h-5 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
                        <label for="module_published" class="mr-3 text-sm font-bold text-gray-700 flex items-center gap-2 cursor-pointer">
                            <i class="fas fa-globe text-blue-500"></i>
                            نشر الوحدة (متاحة للطلاب)
                        </label>
                    </div>
                </div>

                <div class="flex justify-end gap-3 mt-6 pt-6 border-t border-gray-200">
                    <button type="button" onclick="closeModal('addModuleModal')"
                            class="px-6 py-3 border-2 border-gray-300 rounded-xl text-gray-700 hover:bg-gray-50 font-bold transition-all">
                        <i class="fas fa-times ml-2"></i>
                        إلغاء
                    </button>
                    <button type="submit"
                            class="px-6 py-3 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white rounded-xl font-bold shadow-lg transition-all">
                        <i class="fas fa-save ml-2"></i>
                        حفظ الوحدة
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Enhanced Edit Module Modal -->
<div id="editModuleModal" class="hidden fixed inset-0 bg-black bg-opacity-60 backdrop-blur-sm overflow-y-auto h-full w-full z-50" style="font-family: 'Cairo', sans-serif; direction: rtl;">
    <div class="relative top-20 mx-auto p-0 border-0 w-full max-w-2xl">
        <div class="bg-white rounded-2xl shadow-2xl overflow-hidden">
            <div class="bg-gradient-to-r from-green-600 to-teal-600 px-6 py-5">
                <div class="flex justify-between items-center">
                    <div class="flex items-center gap-3 text-white">
                        <div class="w-10 h-10 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                            <i class="fas fa-edit text-xl"></i>
                        </div>
                        <h3 class="text-xl font-bold">تعديل الوحدة</h3>
                    </div>
                    <button onclick="closeModal('editModuleModal')" class="text-white hover:bg-white hover:bg-opacity-20 w-8 h-8 rounded-lg transition-all">
                        <i class="fas fa-times text-xl"></i>
                    </button>
                </div>
            </div>

            <form id="editModuleForm" method="POST" class="p-6">
                @csrf
                @method('PUT')
                <div class="space-y-5">
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                            <i class="fas fa-heading text-green-500 text-xs"></i>
                            عنوان الوحدة *
                        </label>
                        <input type="text" name="title_ar" id="edit_module_title" required
                               class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-all">
                    </div>

                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                            <i class="fas fa-align-right text-green-500 text-xs"></i>
                            الوصف
                        </label>
                        <textarea name="description_ar" id="edit_module_description" rows="4"
                                  class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-all"></textarea>
                    </div>

                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                            <i class="fas fa-sort-numeric-up text-green-500 text-xs"></i>
                            الترتيب
                        </label>
                        <input type="number" name="order" id="edit_module_order" min="0"
                               class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-green-500 transition-all">
                    </div>

                    <div class="flex items-center bg-green-50 border-2 border-green-200 rounded-xl p-4">
                        <input type="checkbox" name="is_published" value="1" id="edit_module_published" class="w-5 h-5 text-green-600 border-gray-300 rounded focus:ring-green-500">
                        <label for="edit_module_published" class="mr-3 text-sm font-bold text-gray-700 flex items-center gap-2 cursor-pointer">
                            <i class="fas fa-globe text-green-500"></i>
                            نشر الوحدة (متاحة للطلاب)
                        </label>
                    </div>
                </div>

                <div class="flex justify-end gap-3 mt-6 pt-6 border-t border-gray-200">
                    <button type="button" onclick="closeModal('editModuleModal')"
                            class="px-6 py-3 border-2 border-gray-300 rounded-xl text-gray-700 hover:bg-gray-50 font-bold transition-all">
                        <i class="fas fa-times ml-2"></i>
                        إلغاء
                    </button>
                    <button type="submit"
                            class="px-6 py-3 bg-gradient-to-r from-green-600 to-teal-600 hover:from-green-700 hover:to-teal-700 text-white rounded-xl font-bold shadow-lg transition-all">
                        <i class="fas fa-save ml-2"></i>
                        حفظ التعديلات
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Add Lesson Modal (will be loaded via AJAX for better UX) -->
<div id="addLessonModal" class="hidden fixed inset-0 bg-black bg-opacity-60 backdrop-blur-sm overflow-y-auto h-full w-full z-50" style="font-family: 'Cairo', sans-serif; direction: rtl;">
    <div class="relative top-10 mx-auto p-0 border-0 w-full max-w-4xl">
        <div class="bg-white rounded-2xl shadow-2xl overflow-hidden">
            <div class="bg-gradient-to-r from-purple-600 to-pink-600 px-6 py-5">
                <div class="flex justify-between items-center">
                    <div class="flex items-center gap-3 text-white">
                        <div class="w-10 h-10 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                            <i class="fas fa-plus-circle text-xl"></i>
                        </div>
                        <h3 class="text-xl font-bold">إضافة درس جديد</h3>
                    </div>
                    <button onclick="closeModal('addLessonModal')" class="text-white hover:bg-white hover:bg-opacity-20 w-8 h-8 rounded-lg transition-all">
                        <i class="fas fa-times text-xl"></i>
                    </button>
                </div>
            </div>

            <form id="addLessonForm" method="POST" enctype="multipart/form-data" class="p-6">
                @csrf
                <div class="space-y-5 max-h-[70vh] overflow-y-auto px-1">
                    <!-- Title -->
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                            <i class="fas fa-heading text-purple-500 text-xs"></i>
                            عنوان المحتوى *
                        </label>
                        <input type="text" name="title_ar" required
                               class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500 transition-all"
                               placeholder="مثال: مقدمة في المتغيرات">
                    </div>

                    <!-- Description -->
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                            <i class="fas fa-align-right text-purple-500 text-xs"></i>
                            الوصف
                        </label>
                        <textarea name="description_ar" rows="3"
                                  class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500 transition-all"
                                  placeholder="وصف مختصر عن المحتوى"></textarea>
                    </div>

                    <!-- Content Type Selector -->
                    <div class="bg-gradient-to-r from-indigo-50 to-purple-50 border-2 border-indigo-200 rounded-xl p-4">
                        <label class="block text-sm font-bold text-gray-700 mb-3 flex items-center gap-2">
                            <i class="fas fa-layer-group text-indigo-500"></i>
                            نوع المحتوى *
                        </label>
                        <div class="grid grid-cols-2 md:grid-cols-4 gap-3">
                            <label class="content-type-option">
                                <input type="radio" name="content_type" value="video" checked onclick="toggleContentFields('video')" class="hidden">
                                <div class="flex flex-col items-center gap-2 p-4 border-2 border-gray-300 rounded-xl cursor-pointer hover:border-purple-500 hover:bg-purple-50 transition-all">
                                    <i class="fas fa-video text-2xl text-purple-600"></i>
                                    <span class="text-sm font-bold">فيديو</span>
                                </div>
                            </label>
                            <label class="content-type-option">
                                <input type="radio" name="content_type" value="document" onclick="toggleContentFields('document')" class="hidden">
                                <div class="flex flex-col items-center gap-2 p-4 border-2 border-gray-300 rounded-xl cursor-pointer hover:border-blue-500 hover:bg-blue-50 transition-all">
                                    <i class="fas fa-file-pdf text-2xl text-blue-600"></i>
                                    <span class="text-sm font-bold">مستند</span>
                                </div>
                            </label>
                            <label class="content-type-option">
                                <input type="radio" name="content_type" value="quiz" onclick="toggleContentFields('quiz')" class="hidden">
                                <div class="flex flex-col items-center gap-2 p-4 border-2 border-gray-300 rounded-xl cursor-pointer hover:border-green-500 hover:bg-green-50 transition-all">
                                    <i class="fas fa-question-circle text-2xl text-green-600"></i>
                                    <span class="text-sm font-bold">كويز</span>
                                </div>
                            </label>
                            <label class="content-type-option">
                                <input type="radio" name="content_type" value="text" onclick="toggleContentFields('text')" class="hidden">
                                <div class="flex flex-col items-center gap-2 p-4 border-2 border-gray-300 rounded-xl cursor-pointer hover:border-orange-500 hover:bg-orange-50 transition-all">
                                    <i class="fas fa-align-left text-2xl text-orange-600"></i>
                                    <span class="text-sm font-bold">نص</span>
                                </div>
                            </label>
                        </div>
                    </div>

                    <!-- Video Content Fields -->
                    <div id="video_fields" class="content-fields">
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                                    <i class="fas fa-video text-purple-500 text-xs"></i>
                                    نوع الفيديو *
                                </label>
                                <select name="video_type" id="add_video_type"
                                        class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 transition-all"
                                        onchange="toggleVideoInput('add')">
                                    <option value="youtube">YouTube</option>
                                    <option value="upload">رفع ملف</option>
                                </select>
                            </div>
                            <div>
                                <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                                    <i class="fas fa-clock text-purple-500 text-xs"></i>
                                    مدة الفيديو (بالثواني) *
                                </label>
                                <input type="number" name="video_duration_seconds" min="0"
                                       class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 transition-all"
                                       placeholder="3600">
                            </div>
                        </div>
                        <div id="add_youtube_input" class="bg-red-50 border-2 border-red-200 rounded-xl p-4 mt-4">
                            <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                                <i class="fab fa-youtube text-red-500"></i>
                                رابط YouTube *
                            </label>
                            <input type="text" name="video_url"
                                   class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-red-500 transition-all"
                                   placeholder="https://www.youtube.com/watch?v=...">
                        </div>
                        <div id="add_upload_input" class="hidden bg-green-50 border-2 border-green-200 rounded-xl p-4 mt-4">
                            <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                                <i class="fas fa-upload text-green-500"></i>
                                رفع فيديو *
                            </label>
                            <input type="file" name="video" accept="video/mp4,video/mov,video/avi"
                                   class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-green-500 transition-all file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:bg-green-100 file:text-green-700 hover:file:bg-green-200">
                        </div>
                    </div>

                    <!-- Document Content Fields -->
                    <div id="document_fields" class="content-fields hidden">
                        <div class="bg-blue-50 border-2 border-blue-200 rounded-xl p-4">
                            <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                                <i class="fas fa-file-upload text-blue-500"></i>
                                رفع مستند (PDF, DOC, PPT, XLS) *
                            </label>
                            <input type="file" name="document" accept=".pdf,.doc,.docx,.ppt,.pptx,.xls,.xlsx"
                                   class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 transition-all file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:bg-blue-100 file:text-blue-700 hover:file:bg-blue-200">
                            <p class="text-xs text-gray-500 mt-2">الحد الأقصى: 20 ميجابايت</p>
                        </div>
                    </div>

                    <!-- Quiz Content Fields -->
                    <div id="quiz_fields" class="content-fields hidden">
                        <div class="bg-green-50 border-2 border-green-200 rounded-xl p-4">
                            <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                                <i class="fas fa-list text-green-500"></i>
                                اختر الكويز *
                            </label>
                            <select name="quiz_id" class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-green-500 transition-all">
                                <option value="">-- اختر كويز --</option>
                                @forelse($filteredQuizzes as $quiz)
                                    <option value="{{ $quiz->id }}">{{ $quiz->title_ar }}</option>
                                @empty
                                    <option value="" disabled>لا توجد كويزات متاحة لهذه المادة</option>
                                @endforelse
                            </select>
                            @if($course->subject)
                                <p class="text-xs text-gray-600 mt-2">
                                    <i class="fas fa-info-circle text-blue-500"></i>
                                    يتم عرض الكويزات الخاصة بـ: <strong>{{ $course->subject->name_ar }}</strong>
                                    @if($course->subject->academicYear)
                                        - {{ $course->subject->academicYear->name_ar }}
                                    @endif
                                    @if($course->subject->academicStream)
                                        - {{ $course->subject->academicStream->name_ar }}
                                    @endif
                                </p>
                            @endif
                            <a href="{{ route('admin.quizzes.index') }}" target="_blank" class="inline-block mt-2 text-sm text-green-600 hover:text-green-700">
                                <i class="fas fa-external-link-alt"></i>
                                إدارة الكويزات
                            </a>
                        </div>
                    </div>

                    <!-- Text Content Fields -->
                    <div id="text_fields" class="content-fields hidden">
                        <div class="bg-orange-50 border-2 border-orange-200 rounded-xl p-4">
                            <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                                <i class="fas fa-paragraph text-orange-500"></i>
                                محتوى النص *
                            </label>
                            <textarea name="content_text_ar" rows="8"
                                      class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-orange-500 transition-all"
                                      placeholder="اكتب محتوى الدرس النصي هنا..."></textarea>
                        </div>
                    </div>

                    <!-- Common Options -->
                    <div class="flex items-center gap-4 bg-gradient-to-r from-blue-50 to-purple-50 border-2 border-blue-200 rounded-xl p-4">
                        <div class="flex items-center">
                            <input type="checkbox" name="is_free_preview" value="1" id="add_is_free" class="w-5 h-5 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
                            <label for="add_is_free" class="mr-3 text-sm font-bold text-gray-700 flex items-center gap-2 cursor-pointer">
                                <i class="fas fa-eye text-blue-500"></i>
                                معاينة مجانية
                            </label>
                        </div>
                        <div class="flex items-center">
                            <input type="checkbox" name="is_published" value="1" id="add_lesson_published" checked class="w-5 h-5 text-green-600 border-gray-300 rounded focus:ring-green-500">
                            <label for="add_lesson_published" class="mr-3 text-sm font-bold text-gray-700 flex items-center gap-2 cursor-pointer">
                                <i class="fas fa-globe text-green-500"></i>
                                منشور
                            </label>
                        </div>
                    </div>
                </div>

                <div class="flex justify-end gap-3 mt-6 pt-6 border-t border-gray-200">
                    <button type="button" onclick="closeModal('addLessonModal')"
                            class="px-6 py-3 border-2 border-gray-300 rounded-xl text-gray-700 hover:bg-gray-50 font-bold transition-all">
                        <i class="fas fa-times ml-2"></i>
                        إلغاء
                    </button>
                    <button type="submit"
                            class="px-6 py-3 bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700 text-white rounded-xl font-bold shadow-lg transition-all">
                        <i class="fas fa-save ml-2"></i>
                        حفظ الدرس
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Enhanced Delete Confirmation Modal -->
<div id="deleteConfirmModal" class="hidden fixed inset-0 bg-black bg-opacity-60 backdrop-blur-sm overflow-y-auto h-full w-full z-50" style="font-family: 'Cairo', sans-serif; direction: rtl;">
    <div class="relative top-32 mx-auto p-0 border-0 w-full max-w-md">
        <div class="bg-white rounded-2xl shadow-2xl overflow-hidden">
            <div class="p-8 text-center">
                <div class="mx-auto flex items-center justify-center h-20 w-20 rounded-full bg-red-100 mb-6">
                    <i class="fas fa-exclamation-triangle text-red-600 text-4xl"></i>
                </div>
                <h3 class="text-2xl font-bold text-gray-900 mb-3">تأكيد الحذف</h3>
                <p class="text-gray-600 mb-6" id="deleteConfirmText"></p>

                <form id="deleteForm" method="POST">
                    @csrf
                    @method('DELETE')
                    <div class="flex gap-3">
                        <button type="button" onclick="closeModal('deleteConfirmModal')"
                                class="flex-1 px-6 py-3 border-2 border-gray-300 rounded-xl text-gray-700 hover:bg-gray-50 font-bold transition-all">
                            <i class="fas fa-times ml-2"></i>
                            إلغاء
                        </button>
                        <button type="submit"
                                class="flex-1 px-6 py-3 bg-gradient-to-r from-red-600 to-red-700 hover:from-red-700 hover:to-red-800 text-white rounded-xl font-bold shadow-lg transition-all">
                            <i class="fas fa-trash ml-2"></i>
                            حذف نهائياً
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- View & Edit Lesson Modals (loaded dynamically) -->
<div id="viewLessonModal" class="hidden fixed inset-0 bg-black bg-opacity-60 backdrop-blur-sm overflow-y-auto h-full w-full z-50" style="font-family: 'Cairo', sans-serif; direction: rtl;"></div>
<div id="editLessonModal" class="hidden fixed inset-0 bg-black bg-opacity-60 backdrop-blur-sm overflow-y-auto h-full w-full z-50" style="font-family: 'Cairo', sans-serif; direction: rtl;"></div>

@push('scripts')
<script src="https://cdn.jsdelivr.net/npm/sortablejs@1.15.0/Sortable.min.js"></script>
<script>
// Enhanced Modal Functions
function openModal(modalId) {
    const modal = document.getElementById(modalId);
    if (!modal) {
        console.error(`Modal with ID "${modalId}" not found`);
        alert(`خطأ: لم يتم العثور على النافذة المنبثقة (${modalId})`);
        return;
    }
    modal.classList.remove('hidden');
    document.body.style.overflow = 'hidden';
}

function closeModal(modalId) {
    document.getElementById(modalId).classList.add('hidden');
    document.body.style.overflow = 'auto';
}

function openAddLessonModal(moduleId) {
    if (!moduleId) {
        alert('خطأ: معرف الوحدة غير صحيح');
        console.error('Module ID is missing');
        return;
    }
    const form = document.getElementById('addLessonForm');
    if (!form) {
        alert('خطأ: لم يتم العثور على نموذج إضافة الدرس');
        console.error('Add lesson form not found');
        return;
    }
    form.action = `/admin/courses/modules/${moduleId}/lessons`;
    openModal('addLessonModal');
}

function openEditModuleModal(moduleId, title, description, order) {
    const form = document.getElementById('editModuleForm');
    form.action = `/admin/courses/modules/${moduleId}`;
    document.getElementById('edit_module_title').value = title;
    document.getElementById('edit_module_description').value = description;
    document.getElementById('edit_module_order').value = order;
    openModal('editModuleModal');
}

function confirmDeleteModule(moduleId, title) {
    const form = document.getElementById('deleteForm');
    form.action = `/admin/courses/modules/${moduleId}`;
    document.getElementById('deleteConfirmText').innerText = `هل أنت متأكد من حذف الوحدة "${title}"؟ سيتم حذف جميع الدروس المرتبطة بها.`;
    openModal('deleteConfirmModal');
}

function confirmDeleteLesson(lessonId, title) {
    const form = document.getElementById('deleteForm');
    form.action = `/admin/courses/lessons/${lessonId}`;
    document.getElementById('deleteConfirmText').innerText = `هل أنت متأكد من حذف الدرس "${title}"؟`;
    openModal('deleteConfirmModal');
}

function toggleVideoInput(prefix) {
    const videoType = document.getElementById(prefix + '_video_type').value;
    const youtubeInput = document.getElementById(prefix + '_youtube_input');
    const uploadInput = document.getElementById(prefix + '_upload_input');

    if (videoType === 'youtube') {
        youtubeInput.classList.remove('hidden');
        uploadInput.classList.add('hidden');
        youtubeInput.querySelector('input').required = true;
        const uploadFileInput = uploadInput.querySelector('input');
        if (uploadFileInput) uploadFileInput.required = false;
    } else {
        youtubeInput.classList.add('hidden');
        uploadInput.classList.remove('hidden');
        youtubeInput.querySelector('input').required = false;
        uploadInput.querySelector('input').required = true;
    }
}

function toggleContentFields(contentType) {
    // Hide all content field divs
    document.querySelectorAll('.content-fields').forEach(el => el.classList.add('hidden'));

    // Show the selected content type fields
    const selectedFields = document.getElementById(contentType + '_fields');
    if (selectedFields) {
        selectedFields.classList.remove('hidden');
    }

    // Update radio button styling to highlight selection
    document.querySelectorAll('.content-type-option').forEach(label => {
        const input = label.querySelector('input[type="radio"]');
        const div = label.querySelector('div');

        if (input && div) {
            if (input.value === contentType && input.checked) {
                // Selected state
                div.classList.add('border-4', 'bg-purple-100', 'shadow-lg', 'scale-105');
                div.classList.remove('border-2', 'bg-white');
            } else {
                // Unselected state
                div.classList.remove('border-4', 'bg-purple-100', 'shadow-lg', 'scale-105');
                div.classList.add('border-2');
            }
        }
    });
}

async function openViewLessonModal(lessonId) {
    const modal = document.getElementById('viewLessonModal');
    modal.innerHTML = `
        <div class="relative top-10 mx-auto p-0 border-0 w-full max-w-4xl">
            <div class="bg-white rounded-2xl shadow-2xl overflow-hidden">
                <div class="p-8 text-center">
                    <i class="fas fa-spinner fa-spin text-blue-600 text-5xl"></i>
                    <p class="mt-4 text-gray-600">جاري التحميل...</p>
                </div>
            </div>
        </div>
    `;
    openModal('viewLessonModal');

    try {
        const response = await fetch(`/admin/courses/lessons/${lessonId}/view`);
        const html = await response.text();
        modal.innerHTML = html;
    } catch (error) {
        modal.innerHTML = `
            <div class="relative top-10 mx-auto p-0 border-0 w-full max-w-md">
                <div class="bg-white rounded-2xl shadow-2xl p-8 text-center">
                    <i class="fas fa-exclamation-circle text-red-600 text-5xl mb-4"></i>
                    <p class="text-red-600 font-bold">حدث خطأ في تحميل البيانات</p>
                    <button onclick="closeModal('viewLessonModal')" class="mt-4 px-6 py-2 bg-gray-200 rounded-lg">إغلاق</button>
                </div>
            </div>
        `;
    }
}

async function openEditLessonModal(lessonId) {
    const modal = document.getElementById('editLessonModal');
    modal.innerHTML = `
        <div class="relative top-10 mx-auto p-0 border-0 w-full max-w-4xl">
            <div class="bg-white rounded-2xl shadow-2xl overflow-hidden">
                <div class="p-8 text-center">
                    <i class="fas fa-spinner fa-spin text-green-600 text-5xl"></i>
                    <p class="mt-4 text-gray-600">جاري التحميل...</p>
                </div>
            </div>
        </div>
    `;
    openModal('editLessonModal');

    try {
        const response = await fetch(`/admin/courses/lessons/${lessonId}/edit`);
        const html = await response.text();
        modal.innerHTML = html;
    } catch (error) {
        modal.innerHTML = `
            <div class="relative top-10 mx-auto p-0 border-0 w-full max-w-md">
                <div class="bg-white rounded-2xl shadow-2xl p-8 text-center">
                    <i class="fas fa-exclamation-circle text-red-600 text-5xl mb-4"></i>
                    <p class="text-red-600 font-bold">حدث خطأ في تحميل البيانات</p>
                    <button onclick="closeModal('editLessonModal')" class="mt-4 px-6 py-2 bg-gray-200 rounded-lg">إغلاق</button>
                </div>
            </div>
        `;
    }
}

// Initialize Drag & Drop for Modules
const modulesList = document.getElementById('modulesList');
if (modulesList) {
    new Sortable(modulesList, {
        animation: 150,
        handle: '.drag-handle',
        ghostClass: 'opacity-50',
        dragClass: 'shadow-2xl',
        onEnd: async function (evt) {
            const moduleIds = Array.from(modulesList.children).map((el, index) => ({
                id: el.dataset.id,
                order: index + 1
            }));

            try {
                await fetch('/admin/courses/{{ $course->id }}/reorder-modules', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
                    },
                    body: JSON.stringify({ modules: moduleIds })
                });
            } catch (error) {
                console.error('Error reordering modules:', error);
                alert('حدث خطأ أثناء إعادة الترتيب');
            }
        }
    });
}

// Initialize Drag & Drop for Lessons within each module
document.querySelectorAll('[id^="lessonsList-"]').forEach(lessonsList => {
    new Sortable(lessonsList, {
        animation: 150,
        handle: '.lesson-drag-handle',
        ghostClass: 'opacity-50',
        dragClass: 'shadow-2xl',
        onEnd: async function (evt) {
            const moduleId = lessonsList.id.replace('lessonsList-', '');
            const lessonIds = Array.from(lessonsList.children).map((el, index) => ({
                id: el.dataset.id,
                order: index + 1
            }));

            try {
                await fetch(`/admin/courses/modules/${moduleId}/reorder-lessons`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
                    },
                    body: JSON.stringify({ lessons: lessonIds })
                });
            } catch (error) {
                console.error('Error reordering lessons:', error);
                alert('حدث خطأ أثناء إعادة الترتيب');
            }
        }
    });
});

// Close modals on background click
document.querySelectorAll('[id$="Modal"]').forEach(modal => {
    modal.addEventListener('click', function(e) {
        if (e.target === this) {
            closeModal(this.id);
        }
    });
});

// Close modals on ESC key
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        document.querySelectorAll('[id$="Modal"]').forEach(modal => {
            if (!modal.classList.contains('hidden')) {
                closeModal(modal.id);
            }
        });
    }
});
</script>
@endpush

@push('styles')
<style>
/* Content Type Radio Button Styles */
.content-type-option input[type="radio"]:checked + div {
    border-width: 4px !important;
    background-color: rgb(243 232 255) !important;
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
    transform: scale(1.05);
}

.content-type-option div {
    transition: all 0.3s ease-in-out;
}

.content-type-option:hover div {
    transform: translateY(-2px);
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

/* Content Fields Transition */
.content-fields {
    transition: opacity 0.3s ease-in-out, max-height 0.3s ease-in-out;
}

.content-fields.hidden {
    opacity: 0;
    max-height: 0;
    overflow: hidden;
}

.content-fields:not(.hidden) {
    opacity: 1;
    max-height: 1000px;
}
</style>
@endpush
@endsection
