@extends('layouts.admin')

@section('title', 'إضافة محتوى جديد')
@section('page-title', 'إضافة محتوى جديد')
@section('page-description', 'إضافة عنصر جديد لمخطط المادة')

@section('content')
<div class="p-8">
    <!-- Header -->
    <div class="mb-6">
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-3xl font-bold text-gray-800">إضافة محتوى جديد</h1>
                <p class="text-gray-600 mt-2">
                    @if($parent)
                        إضافة فرع جديد تحت: <span class="font-semibold text-blue-600">{{ $parent->title_ar }}</span>
                    @else
                        إضافة عنصر جديد لمخطط المادة
                    @endif
                </p>
            </div>
            <a href="{{ route('admin.subject-planner-content.index') }}" class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded-lg transition">
                <i class="fas fa-arrow-right mr-2"></i>
                العودة إلى القائمة
            </a>
        </div>
    </div>

    <!-- Form -->
    <div class="bg-white rounded-xl shadow-md">
        <form method="POST" action="{{ route('admin.subject-planner-content.store') }}" class="p-6" x-data="contentForm()" x-init="init()" dir="rtl">
            @csrf

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
                                x-model="phaseId"
                                @change="loadYears()"
                                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                {{ $parent ? 'disabled' : '' }}
                                required>
                            <option value="">اختر المرحلة</option>
                            @foreach($phases as $phase)
                            <option value="{{ $phase->id }}"
                                {{ old('academic_phase_id', $parent?->academic_phase_id) == $phase->id ? 'selected' : '' }}>
                                {{ $phase->name_ar }}
                            </option>
                            @endforeach
                        </select>
                        @if($parent)
                            <input type="hidden" name="academic_phase_id" value="{{ $parent->academic_phase_id }}">
                        @endif
                    </div>

                    <!-- Academic Year -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            السنة الدراسية <span class="text-red-500">*</span>
                        </label>
                        <select name="academic_year_id"
                                x-model="yearId"
                                @change="loadStreams(); loadSubjects()"
                                :disabled="!phaseId || loadingYears {{ $parent ? '|| true' : '' }}"
                                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-100"
                                required>
                            <option value="">اختر السنة</option>
                            <template x-for="year in years" :key="year.id">
                                <option :value="year.id" x-text="year.name_ar"></option>
                            </template>
                        </select>
                        @if($parent)
                            <input type="hidden" name="academic_year_id" value="{{ $parent->academic_year_id }}">
                        @endif
                    </div>

                    <!-- Academic Stream -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            الشعبة
                        </label>
                        <select name="academic_stream_id"
                                x-model="streamId"
                                @change="loadSubjects()"
                                :disabled="!yearId || loadingStreams {{ $parent ? '|| true' : '' }}"
                                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-100">
                            <option value="">كل الشعب (مادة مشتركة)</option>
                            <template x-for="stream in streams" :key="stream.id">
                                <option :value="stream.id" x-text="stream.name_ar"></option>
                            </template>
                        </select>
                        @if($parent)
                            <input type="hidden" name="academic_stream_id" value="{{ $parent->academic_stream_id }}">
                        @endif
                    </div>

                    <!-- Subject -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            المادة <span class="text-red-500">*</span>
                        </label>
                        <select name="subject_id"
                                x-model="subjectId"
                                @change="loadParents()"
                                :disabled="!yearId || loadingSubjects {{ $parent ? '|| true' : '' }}"
                                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-100"
                                required>
                            <option value="">اختر المادة</option>
                            <template x-for="subject in subjects" :key="subject.id">
                                <option :value="subject.id" x-text="subject.name_ar"></option>
                            </template>
                        </select>
                        @if($parent)
                            <input type="hidden" name="subject_id" value="{{ $parent->subject_id }}">
                        @endif
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
                        @if($parent)
                            <input type="hidden" name="parent_id" value="{{ $parent->id }}">
                            <div class="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-100 text-gray-700">
                                {{ $parent->code ? $parent->code . ' - ' : '' }}{{ $parent->title_ar }}
                                <span class="text-sm text-gray-500">({{ $levels[$parent->level] ?? $parent->level }})</span>
                            </div>
                        @else
                            <select name="parent_id"
                                    x-model="parentId"
                                    :disabled="!subjectId || loadingParents"
                                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-100">
                                <option value="">بدون أب (عنصر رئيسي)</option>
                                <template x-for="p in parents" :key="p.id">
                                    <option :value="p.id" x-text="p.full_title"></option>
                                </template>
                            </select>
                        @endif
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
                            <option value="{{ $key }}" {{ old('level') == $key ? 'selected' : '' }}>
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
                               value="{{ old('code') }}"
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
                               value="{{ old('title_ar') }}"
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
                              placeholder="وصف تفصيلي للمحتوى...">{{ old('description_ar') }}</textarea>
                </div>

                <!-- Order -->
                <div class="mt-4 w-32">
                    <label class="block text-gray-700 font-semibold mb-2">
                        الترتيب
                    </label>
                    <input type="number"
                           name="order"
                           value="{{ old('order', 0) }}"
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
                            <option value="theory" {{ old('content_type') == 'theory' ? 'selected' : '' }}>نظري</option>
                            <option value="exercise" {{ old('content_type') == 'exercise' ? 'selected' : '' }}>تمارين</option>
                            <option value="review" {{ old('content_type') == 'review' ? 'selected' : '' }}>مراجعة</option>
                            <option value="memorization" {{ old('content_type') == 'memorization' ? 'selected' : '' }}>حفظ</option>
                            <option value="practice" {{ old('content_type') == 'practice' ? 'selected' : '' }}>تطبيق</option>
                            <option value="exam_prep" {{ old('content_type') == 'exam_prep' ? 'selected' : '' }}>تحضير للامتحان</option>
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
                            <option value="easy" {{ old('difficulty_level') == 'easy' ? 'selected' : '' }}>سهل</option>
                            <option value="medium" {{ old('difficulty_level', 'medium') == 'medium' ? 'selected' : '' }}>متوسط</option>
                            <option value="hard" {{ old('difficulty_level') == 'hard' ? 'selected' : '' }}>صعب</option>
                        </select>
                    </div>

                    <!-- Duration -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            المدة المقدرة (دقائق)
                        </label>
                        <input type="number"
                               name="estimated_duration_minutes"
                               value="{{ old('estimated_duration_minutes') }}"
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
                               {{ old('requires_understanding', true) ? 'checked' : '' }}
                               class="w-5 h-5 text-blue-600 rounded">
                        <span class="text-gray-700">يتطلب فهم</span>
                    </label>

                    <label class="flex items-center gap-3 p-3 border rounded-lg hover:bg-gray-50 cursor-pointer">
                        <input type="checkbox" name="requires_review" value="1"
                               {{ old('requires_review', true) ? 'checked' : '' }}
                               class="w-5 h-5 text-blue-600 rounded">
                        <span class="text-gray-700">يتطلب مراجعة</span>
                    </label>

                    <label class="flex items-center gap-3 p-3 border rounded-lg hover:bg-gray-50 cursor-pointer">
                        <input type="checkbox" name="requires_theory_practice" value="1"
                               {{ old('requires_theory_practice') ? 'checked' : '' }}
                               class="w-5 h-5 text-blue-600 rounded">
                        <span class="text-gray-700">تطبيق نظري</span>
                    </label>

                    <label class="flex items-center gap-3 p-3 border rounded-lg hover:bg-gray-50 cursor-pointer">
                        <input type="checkbox" name="requires_exercise_practice" value="1"
                               {{ old('requires_exercise_practice') ? 'checked' : '' }}
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
                                   {{ old('is_bac_priority') ? 'checked' : '' }}
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
                               value="{{ old('bac_frequency', 0) }}"
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
                               value="{{ old('bac_exam_years_input') }}"
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
                               {{ old('is_active', true) ? 'checked' : '' }}
                               class="w-5 h-5 text-blue-600 rounded">
                        <span class="text-gray-700">نشط</span>
                    </label>

                    <label class="flex items-center gap-3 p-3 border rounded-lg hover:bg-gray-50 cursor-pointer">
                        <input type="checkbox" name="is_published" value="1"
                               {{ old('is_published') ? 'checked' : '' }}
                               class="w-5 h-5 text-green-600 rounded">
                        <span class="text-gray-700">منشور</span>
                    </label>
                </div>
            </div>

            <!-- Action Buttons -->
            <div class="flex items-center gap-4 pt-6 border-t">
                <button type="submit"
                        class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg font-semibold transition flex items-center">
                    <i class="fas fa-save mr-2"></i>
                    حفظ المحتوى
                </button>
                <a href="{{ route('admin.subject-planner-content.index') }}"
                   class="bg-gray-500 hover:bg-gray-600 text-white px-6 py-3 rounded-lg font-semibold transition">
                    إلغاء
                </a>
            </div>
        </form>
    </div>
</div>

<script>
function contentForm() {
    return {
        phaseId: '{{ old('academic_phase_id', $parent?->academic_phase_id) }}',
        yearId: '{{ old('academic_year_id', $parent?->academic_year_id) }}',
        streamId: '{{ old('academic_stream_id', $parent?->academic_stream_id) }}',
        subjectId: '{{ old('subject_id', $parent?->subject_id) }}',
        parentId: '{{ old('parent_id', $parent?->id) }}',

        years: [],
        streams: [],
        subjects: [],
        parents: [],

        loadingYears: false,
        loadingStreams: false,
        loadingSubjects: false,
        loadingParents: false,

        async init() {
            @if($parent)
                // Pre-load data for parent context
                await this.loadYears();
                await this.loadStreams();
                await this.loadSubjects();
            @else
                if (this.phaseId) await this.loadYears();
                if (this.yearId) {
                    await this.loadStreams();
                    await this.loadSubjects(); // Load subjects by year or stream
                }
                if (this.subjectId) await this.loadParents();
            @endif
        },

        async loadYears() {
            if (!this.phaseId) {
                this.years = [];
                this.yearId = '';
                return;
            }

            this.loadingYears = true;
            try {
                const response = await fetch(`/admin/subject-planner-content/ajax/years/${this.phaseId}`);
                this.years = await response.json();
            } catch (error) {
                console.error('Error loading years:', error);
            } finally {
                this.loadingYears = false;
            }
        },

        async loadStreams() {
            if (!this.yearId) {
                this.streams = [];
                this.streamId = '';
                return;
            }

            this.loadingStreams = true;
            try {
                const response = await fetch(`/admin/subject-planner-content/ajax/streams/${this.yearId}`);
                this.streams = await response.json();
            } catch (error) {
                console.error('Error loading streams:', error);
            } finally {
                this.loadingStreams = false;
            }
        },

        async loadSubjects() {
            // Need at least yearId to load subjects
            if (!this.yearId) {
                this.subjects = [];
                this.subjectId = '';
                return;
            }

            this.loadingSubjects = true;
            try {
                let url;
                if (this.streamId) {
                    // Load subjects for specific stream
                    url = `/admin/subject-planner-content/ajax/subjects/${this.streamId}`;
                } else {
                    // Load all subjects for the year (shared subjects)
                    url = `/admin/subject-planner-content/ajax/subjects-by-year/${this.yearId}`;
                }
                const response = await fetch(url);
                this.subjects = await response.json();
            } catch (error) {
                console.error('Error loading subjects:', error);
            } finally {
                this.loadingSubjects = false;
            }
        },

        async loadParents() {
            if (!this.subjectId) {
                this.parents = [];
                this.parentId = '';
                return;
            }

            this.loadingParents = true;
            try {
                const response = await fetch(`/admin/subject-planner-content/ajax/parents/${this.subjectId}`);
                this.parents = await response.json();
            } catch (error) {
                console.error('Error loading parents:', error);
            } finally {
                this.loadingParents = false;
            }
        }
    }
}
</script>
@endsection
