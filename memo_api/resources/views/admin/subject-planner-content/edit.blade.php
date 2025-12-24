@extends('layouts.admin')

@section('title', 'تعديل المحتوى')
@section('page-title', 'تعديل المحتوى')
@section('page-description', 'تعديل عنصر في مخطط المادة')

@section('content')
<div class="p-8">
    <!-- Header -->
    <div class="mb-6">
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-3xl font-bold text-gray-800">تعديل: {{ $content->title_ar }}</h1>
                <p class="text-gray-600 mt-2">تحديث معلومات عنصر المحتوى</p>
            </div>
            <div class="flex gap-3">
                <a href="{{ route('admin.subject-planner-content.show', $content) }}" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition">
                    <i class="fas fa-eye mr-2"></i>
                    عرض
                </a>
                <a href="{{ route('admin.subject-planner-content.index') }}" class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded-lg transition">
                    <i class="fas fa-arrow-right mr-2"></i>
                    العودة
                </a>
            </div>
        </div>
    </div>

    <!-- Form -->
    <div class="bg-white rounded-xl shadow-md">
        <form method="POST" action="{{ route('admin.subject-planner-content.update', $content) }}" class="p-6" dir="rtl">
            @csrf
            @method('PUT')

            <!-- Error Messages -->
            @if($errors->any())
            <div class="bg-red-50 border-r-4 border-red-500 p-4 mb-6 rounded">
                <div class="flex items-start">
                    <i class="fas fa-exclamation-circle text-red-500 mr-3 mt-1"></i>
                    <div>
                        <h3 class="text-red-800 font-semibold mb-2">يوجد أخطاء في النموذج:</h3>
                        <ul class="list-disc list-inside text-red-700">
                            @foreach($errors->all() as $error)
                            <li>{{ $error }}</li>
                            @endforeach
                        </ul>
                    </div>
                </div>
            </div>
            @endif

            <!-- Academic Context Section -->
            <div class="mb-8">
                <h2 class="text-xl font-semibold text-gray-800 mb-4 border-b pb-2">
                    <i class="fas fa-graduation-cap text-blue-600 mr-2"></i>
                    السياق الأكاديمي
                </h2>

                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                    <!-- Academic Phase -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            المرحلة الدراسية <span class="text-red-500">*</span>
                        </label>
                        <select name="academic_phase_id"
                                id="phase_select"
                                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                required>
                            <option value="">اختر المرحلة</option>
                            @foreach($phases as $phase)
                            <option value="{{ $phase->id }}"
                                {{ old('academic_phase_id', $content->academic_phase_id) == $phase->id ? 'selected' : '' }}>
                                {{ $phase->name_ar }}
                            </option>
                            @endforeach
                        </select>
                    </div>

                    <!-- Academic Year -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            السنة الدراسية <span class="text-red-500">*</span>
                        </label>
                        <select name="academic_year_id"
                                id="year_select"
                                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                required>
                            <option value="">اختر السنة</option>
                            @foreach($years as $year)
                            <option value="{{ $year->id }}"
                                {{ old('academic_year_id', $content->academic_year_id) == $year->id ? 'selected' : '' }}>
                                {{ $year->name_ar }}
                            </option>
                            @endforeach
                        </select>
                    </div>

                    <!-- Academic Stream -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            الشعبة
                        </label>
                        <select name="academic_stream_id"
                                id="stream_select"
                                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                            <option value="">مادة مشتركة</option>
                            @foreach($streams as $stream)
                            <option value="{{ $stream->id }}"
                                {{ old('academic_stream_id', $content->academic_stream_id) == $stream->id ? 'selected' : '' }}>
                                {{ $stream->name_ar }}
                            </option>
                            @endforeach
                        </select>
                    </div>

                    <!-- Subject -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            المادة <span class="text-red-500">*</span>
                        </label>
                        <select name="subject_id"
                                id="subject_select"
                                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                required>
                            <option value="">اختر المادة</option>
                            @foreach($subjects as $subject)
                            <option value="{{ $subject->id }}"
                                {{ old('subject_id', $content->subject_id) == $subject->id ? 'selected' : '' }}>
                                {{ $subject->name_ar }}
                            </option>
                            @endforeach
                        </select>
                    </div>
                </div>
            </div>

            <!-- Hierarchy Section -->
            <div class="mb-8">
                <h2 class="text-xl font-semibold text-gray-800 mb-4 border-b pb-2">
                    <i class="fas fa-sitemap text-blue-600 mr-2"></i>
                    التسلسل الهرمي
                </h2>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <!-- Parent -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            العنصر الأب
                        </label>
                        <select name="parent_id"
                                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                            <option value="">بدون أب (عنصر رئيسي)</option>
                            @foreach($potentialParents as $parent)
                            <option value="{{ $parent->id }}"
                                {{ old('parent_id', $content->parent_id) == $parent->id ? 'selected' : '' }}>
                                {{ $parent->code ? $parent->code . ' - ' : '' }}{{ $parent->title_ar }} ({{ $levels[$parent->level] ?? $parent->level }})
                            </option>
                            @endforeach
                        </select>
                    </div>

                    <!-- Level -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            المستوى <span class="text-red-500">*</span>
                        </label>
                        <select name="level"
                                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                required>
                            <option value="">اختر المستوى</option>
                            @foreach($levels as $key => $label)
                            <option value="{{ $key }}" {{ old('level', $content->level) == $key ? 'selected' : '' }}>
                                {{ $label }}
                            </option>
                            @endforeach
                        </select>
                    </div>
                </div>
            </div>

            <!-- Basic Information Section -->
            <div class="mb-8">
                <h2 class="text-xl font-semibold text-gray-800 mb-4 border-b pb-2">
                    <i class="fas fa-info-circle text-blue-600 mr-2"></i>
                    المعلومات الأساسية
                </h2>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <!-- Code -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            الرمز
                        </label>
                        <input type="text"
                               name="code"
                               value="{{ old('code', $content->code) }}"
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                               placeholder="مثال: U1.T2"
                               dir="ltr">
                    </div>

                    <!-- Title -->
                    <div class="md:col-span-2">
                        <label class="block text-gray-700 font-semibold mb-2">
                            العنوان <span class="text-red-500">*</span>
                        </label>
                        <input type="text"
                               name="title_ar"
                               value="{{ old('title_ar', $content->title_ar) }}"
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                               placeholder="عنوان المحتوى"
                               required>
                    </div>
                </div>

                <!-- Description -->
                <div class="mt-4">
                    <label class="block text-gray-700 font-semibold mb-2">
                        الوصف
                    </label>
                    <textarea name="description_ar"
                              rows="3"
                              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                              placeholder="وصف تفصيلي للمحتوى...">{{ old('description_ar', $content->description_ar) }}</textarea>
                </div>

                <!-- Order -->
                <div class="mt-4 w-32">
                    <label class="block text-gray-700 font-semibold mb-2">
                        الترتيب
                    </label>
                    <input type="number"
                           name="order"
                           value="{{ old('order', $content->order) }}"
                           min="0"
                           class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                </div>
            </div>

            <!-- Study Metadata Section -->
            <div class="mb-8">
                <h2 class="text-xl font-semibold text-gray-800 mb-4 border-b pb-2">
                    <i class="fas fa-book-reader text-blue-600 mr-2"></i>
                    معلومات الدراسة
                </h2>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <!-- Content Type -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            نوع المحتوى
                        </label>
                        <select name="content_type"
                                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                            <option value="">غير محدد</option>
                            <option value="theory" {{ old('content_type', $content->content_type) == 'theory' ? 'selected' : '' }}>نظري</option>
                            <option value="exercise" {{ old('content_type', $content->content_type) == 'exercise' ? 'selected' : '' }}>تمارين</option>
                            <option value="review" {{ old('content_type', $content->content_type) == 'review' ? 'selected' : '' }}>مراجعة</option>
                            <option value="memorization" {{ old('content_type', $content->content_type) == 'memorization' ? 'selected' : '' }}>حفظ</option>
                            <option value="practice" {{ old('content_type', $content->content_type) == 'practice' ? 'selected' : '' }}>تطبيق</option>
                            <option value="exam_prep" {{ old('content_type', $content->content_type) == 'exam_prep' ? 'selected' : '' }}>تحضير للامتحان</option>
                        </select>
                    </div>

                    <!-- Difficulty -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            مستوى الصعوبة
                        </label>
                        <select name="difficulty_level"
                                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                            <option value="">غير محدد</option>
                            <option value="easy" {{ old('difficulty_level', $content->difficulty_level) == 'easy' ? 'selected' : '' }}>سهل</option>
                            <option value="medium" {{ old('difficulty_level', $content->difficulty_level) == 'medium' ? 'selected' : '' }}>متوسط</option>
                            <option value="hard" {{ old('difficulty_level', $content->difficulty_level) == 'hard' ? 'selected' : '' }}>صعب</option>
                        </select>
                    </div>

                    <!-- Duration -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            المدة المقدرة (دقائق)
                        </label>
                        <input type="number"
                               name="estimated_duration_minutes"
                               value="{{ old('estimated_duration_minutes', $content->estimated_duration_minutes) }}"
                               min="1"
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                               placeholder="30">
                    </div>
                </div>
            </div>

            <!-- Repetition Requirements Section -->
            <div class="mb-8">
                <h2 class="text-xl font-semibold text-gray-800 mb-4 border-b pb-2">
                    <i class="fas fa-sync-alt text-blue-600 mr-2"></i>
                    متطلبات التكرار
                </h2>

                <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <label class="flex items-center gap-3 p-3 border rounded-lg hover:bg-gray-50 cursor-pointer">
                        <input type="checkbox" name="requires_understanding" value="1"
                               {{ old('requires_understanding', $content->requires_understanding) ? 'checked' : '' }}
                               class="w-5 h-5 text-blue-600 rounded">
                        <span class="text-gray-700">يتطلب فهم</span>
                    </label>

                    <label class="flex items-center gap-3 p-3 border rounded-lg hover:bg-gray-50 cursor-pointer">
                        <input type="checkbox" name="requires_review" value="1"
                               {{ old('requires_review', $content->requires_review) ? 'checked' : '' }}
                               class="w-5 h-5 text-blue-600 rounded">
                        <span class="text-gray-700">يتطلب مراجعة</span>
                    </label>

                    <label class="flex items-center gap-3 p-3 border rounded-lg hover:bg-gray-50 cursor-pointer">
                        <input type="checkbox" name="requires_theory_practice" value="1"
                               {{ old('requires_theory_practice', $content->requires_theory_practice) ? 'checked' : '' }}
                               class="w-5 h-5 text-blue-600 rounded">
                        <span class="text-gray-700">تطبيق نظري</span>
                    </label>

                    <label class="flex items-center gap-3 p-3 border rounded-lg hover:bg-gray-50 cursor-pointer">
                        <input type="checkbox" name="requires_exercise_practice" value="1"
                               {{ old('requires_exercise_practice', $content->requires_exercise_practice) ? 'checked' : '' }}
                               class="w-5 h-5 text-blue-600 rounded">
                        <span class="text-gray-700">تطبيق تمارين</span>
                    </label>
                </div>
            </div>

            <!-- BAC Exam Info Section -->
            <div class="mb-8">
                <h2 class="text-xl font-semibold text-gray-800 mb-4 border-b pb-2">
                    <i class="fas fa-award text-blue-600 mr-2"></i>
                    معلومات البكالوريا
                </h2>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <!-- BAC Priority -->
                    <div>
                        <label class="flex items-center gap-3 p-3 border rounded-lg hover:bg-gray-50 cursor-pointer">
                            <input type="checkbox" name="is_bac_priority" value="1"
                                   {{ old('is_bac_priority', $content->is_bac_priority) ? 'checked' : '' }}
                                   class="w-5 h-5 text-red-600 rounded">
                            <span class="text-gray-700 font-semibold">أولوية البكالوريا</span>
                        </label>
                    </div>

                    <!-- BAC Frequency -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            تكرار في BAC
                        </label>
                        <input type="number"
                               name="bac_frequency"
                               value="{{ old('bac_frequency', $content->bac_frequency) }}"
                               min="0"
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                    </div>

                    <!-- BAC Years -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            سنوات الظهور في BAC
                        </label>
                        <input type="text"
                               name="bac_exam_years_input"
                               value="{{ old('bac_exam_years_input', is_array($content->bac_exam_years) ? implode(', ', $content->bac_exam_years) : '') }}"
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                               placeholder="2024, 2023, 2022"
                               dir="ltr">
                        <p class="text-sm text-gray-500 mt-1">أدخل السنوات مفصولة بفاصلة</p>
                    </div>
                </div>
            </div>

            <!-- Status Section -->
            <div class="mb-8">
                <h2 class="text-xl font-semibold text-gray-800 mb-4 border-b pb-2">
                    <i class="fas fa-cog text-blue-600 mr-2"></i>
                    الحالة
                </h2>

                <div class="flex gap-6">
                    <label class="flex items-center gap-3 p-3 border rounded-lg hover:bg-gray-50 cursor-pointer">
                        <input type="checkbox" name="is_active" value="1"
                               {{ old('is_active', $content->is_active) ? 'checked' : '' }}
                               class="w-5 h-5 text-blue-600 rounded">
                        <span class="text-gray-700">نشط</span>
                    </label>

                    <label class="flex items-center gap-3 p-3 border rounded-lg hover:bg-gray-50 cursor-pointer">
                        <input type="checkbox" name="is_published" value="1"
                               {{ old('is_published', $content->is_published) ? 'checked' : '' }}
                               class="w-5 h-5 text-green-600 rounded">
                        <span class="text-gray-700">منشور</span>
                    </label>
                </div>

                @if($content->published_at)
                <p class="text-sm text-gray-500 mt-2">
                    <i class="fas fa-clock mr-1"></i>
                    تم النشر: {{ $content->published_at->format('Y-m-d H:i') }}
                </p>
                @endif
            </div>

            <!-- Meta Info -->
            <div class="mb-8 bg-gray-50 rounded-lg p-4">
                <div class="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm text-gray-600">
                    <div>
                        <span class="font-semibold">تاريخ الإنشاء:</span>
                        {{ $content->created_at->format('Y-m-d H:i') }}
                    </div>
                    <div>
                        <span class="font-semibold">آخر تحديث:</span>
                        {{ $content->updated_at->format('Y-m-d H:i') }}
                    </div>
                    @if($content->creator)
                    <div>
                        <span class="font-semibold">أنشأه:</span>
                        {{ $content->creator->name }}
                    </div>
                    @endif
                    @if($content->updater)
                    <div>
                        <span class="font-semibold">آخر تعديل:</span>
                        {{ $content->updater->name }}
                    </div>
                    @endif
                </div>
            </div>

            <!-- Action Buttons -->
            <div class="flex items-center gap-4 pt-6 border-t">
                <button type="submit"
                        class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg font-semibold transition flex items-center">
                    <i class="fas fa-save mr-2"></i>
                    حفظ التغييرات
                </button>
                <a href="{{ route('admin.subject-planner-content.show', $content) }}"
                   class="bg-gray-500 hover:bg-gray-600 text-white px-6 py-3 rounded-lg font-semibold transition">
                    إلغاء
                </a>
            </div>
        </form>
    </div>
</div>
@endsection
