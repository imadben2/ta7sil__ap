@extends('layouts.admin')

@section('title', 'تعديل الكويز')
@section('page-title', 'تعديل الكويز')
@section('page-description', 'تعديل معلومات وإعدادات الكويز')

@section('content')
<div class="p-8">

    @if ($errors->any())
    <div class="mb-6 bg-red-100 border-r-4 border-red-500 text-red-700 p-4 rounded">
        <div class="flex items-center mb-2">
            <i class="fas fa-exclamation-circle mr-3"></i>
            <p class="font-bold">يرجى تصحيح الأخطاء التالية:</p>
        </div>
        <ul class="list-disc list-inside">
            @foreach ($errors->all() as $error)
                <li>{{ $error }}</li>
            @endforeach
        </ul>
    </div>
    @endif

    <form action="{{ route('admin.quizzes.update', ->id) }}" method="POST" id="quizForm">
        @method('PUT')
        @csrf

        <div class="flex gap-6">
            <!-- Main Content Area (70%) -->
            <div class="flex-1">
                <!-- Basic Information -->
                <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
                    <h3 class="text-lg font-semibold text-gray-800 mb-4">
                        <i class="fas fa-info-circle text-blue-600 mr-2"></i>
                        المعلومات الأساسية
                    </h3>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <!-- Subject -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                المادة الدراسية
                            </label>
                            <select name="subject_id" id="subject_id"
                                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                                <option value="">اختر المادة</option>
                                @foreach($subjects as $subject)
                                    <option value="{{ $subject->id }}" {{ old('subject_id') == $subject->id ? 'selected' : '' }}>
                                        {{ $subject->name_ar }}
                                    </option>
                                @endforeach
                            </select>
                            @error('subject_id')
                                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                            @enderror
                        </div>

                        <!-- Chapter -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                الفصل (اختياري)
                            </label>
                            <select name="chapter_id" id="chapter_id"
                                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                                <option value="">اختر الفصل</option>
                                @foreach($chapters as $chapter)
                                    <option value="{{ $chapter->id }}" data-subject="{{ $chapter->subject_id }}"
                                            {{ old('chapter_id') == $chapter->id ? 'selected' : '' }}>
                                        {{ $chapter->title_ar }}
                                    </option>
                                @endforeach
                            </select>
                            @error('chapter_id')
                                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                            @enderror
                        </div>

                        <!-- Title -->
                        <div class="md:col-span-2">
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                عنوان الكويز <span class="text-red-500">*</span>
                            </label>
                            <input type="text" name="title_ar" value="{{ old('title_ar') }}" required
                                   class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 @error('title_ar') border-red-500 @enderror"
                                   placeholder="مثال: اختبار الوحدة الأولى - الدوال">
                            @error('title_ar')
                                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                            @enderror
                        </div>

                        <!-- Description -->
                        <div class="md:col-span-2">
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                الوصف
                            </label>
                            <textarea name="description_ar" rows="3"
                                      class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 @error('description_ar') border-red-500 @enderror"
                                      placeholder="وصف مختصر للكويز وما يغطيه">{{ old('description_ar') }}</textarea>
                            @error('description_ar')
                                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                            @enderror
                        </div>
                    </div>
                </div>

                <!-- Quiz Settings -->
                <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
                    <h3 class="text-lg font-semibold text-gray-800 mb-4">
                        <i class="fas fa-cog text-blue-600 mr-2"></i>
                        إعدادات الكويز
                    </h3>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <!-- Quiz Type -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                نوع الكويز <span class="text-red-500">*</span>
                            </label>
                            <select name="quiz_type" required
                                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                                <option value="practice" {{ old('quiz_type') == 'practice' ? 'selected' : '' }}>تدريبي (Practice)</option>
                                <option value="timed" {{ old('quiz_type') == 'timed' ? 'selected' : '' }}>موقوت (Timed)</option>
                                <option value="exam" {{ old('quiz_type') == 'exam' ? 'selected' : '' }}>اختبار (Exam)</option>
                            </select>
                        </div>

                        <!-- Difficulty Level -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                مستوى الصعوبة <span class="text-red-500">*</span>
                            </label>
                            <select name="difficulty_level" required
                                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                                <option value="easy" {{ old('difficulty_level') == 'easy' ? 'selected' : '' }}>سهل</option>
                                <option value="medium" {{ old('difficulty_level') == 'medium' ? 'selected' : '' }}>متوسط</option>
                                <option value="hard" {{ old('difficulty_level') == 'hard' ? 'selected' : '' }}>صعب</option>
                            </select>
                        </div>

                        <!-- Time Limit -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                الوقت المحدد (بالدقائق)
                            </label>
                            <input type="number" name="time_limit_minutes" value="{{ old('time_limit_minutes') }}" min="1"
                                   class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                   placeholder="اتركه فارغاً لكويز بدون حد زمني">
                        </div>

                        <!-- Estimated Duration -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                المدة المتوقعة (بالدقائق)
                            </label>
                            <input type="number" name="estimated_duration_minutes" value="{{ old('estimated_duration_minutes') }}" min="1"
                                   class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                        </div>

                        <!-- Passing Score -->
                        <div class="md:col-span-2">
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                درجة النجاح (%) <span class="text-red-500">*</span>
                            </label>
                            <input type="number" name="passing_score" value="{{ old('passing_score', 60) }}" min="0" max="100" required
                                   class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                        </div>
                    </div>
                </div>

                <!-- Display Options -->
                <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
                    <h3 class="text-lg font-semibold text-gray-800 mb-4">
                        <i class="fas fa-eye text-blue-600 mr-2"></i>
                        خيارات العرض
                    </h3>

                    <div class="space-y-3">
                        <label class="flex items-center">
                            <input type="checkbox" name="shuffle_questions" value="1" {{ old('shuffle_questions') ? 'checked' : '' }}
                                   class="w-5 h-5 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
                            <span class="mr-3 text-sm text-gray-700">خلط ترتيب الأسئلة</span>
                        </label>

                        <label class="flex items-center">
                            <input type="checkbox" name="shuffle_answers" value="1" {{ old('shuffle_answers') ? 'checked' : '' }}
                                   class="w-5 h-5 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
                            <span class="mr-3 text-sm text-gray-700">خلط ترتيب الإجابات</span>
                        </label>

                        <label class="flex items-center">
                            <input type="checkbox" name="show_correct_answers" value="1" {{ old('show_correct_answers') ? 'checked' : '' }}
                                   class="w-5 h-5 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
                            <span class="mr-3 text-sm text-gray-700">إظهار الإجابات الصحيحة بعد الإرسال</span>
                        </label>

                        <label class="flex items-center">
                            <input type="checkbox" name="allow_review" value="1" {{ old('allow_review', true) ? 'checked' : '' }}
                                   class="w-5 h-5 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
                            <span class="mr-3 text-sm text-gray-700">السماح بمراجعة الإجابات</span>
                        </label>
                    </div>
                </div>

                <!-- Tags -->
                <div class="bg-white rounded-lg shadow-sm p-6">
                    <h3 class="text-lg font-semibold text-gray-800 mb-4">
                        <i class="fas fa-tags text-blue-600 mr-2"></i>
                        الوسوم (Tags)
                    </h3>

                    <div id="tags-container" class="space-y-2">
                        <div class="flex gap-2">
                            <input type="text" name="tags[]" value="{{ old('tags.0') }}"
                                   class="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                   placeholder="مثال: الجبر، المعادلات">
                        </div>
                    </div>

                    <button type="button" onclick="addTagField()" class="mt-2 px-4 py-2 text-sm text-blue-600 hover:text-blue-800">
                        <i class="fas fa-plus mr-1"></i>
                        إضافة وسم
                    </button>
                </div>
            </div>

            <!-- Sidebar (30%) -->
            <div class="w-80">
                <!-- Publication Status -->
                <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
                    <h3 class="text-lg font-semibold text-gray-800 mb-4">
                        <i class="fas fa-paper-plane text-blue-600 mr-2"></i>
                        النشر
                    </h3>

                    <div class="mb-4">
                        <label class="flex items-center">
                            <input type="checkbox" name="is_published" value="1" {{ old('is_published') ? 'checked' : '' }}
                                   class="w-5 h-5 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
                            <span class="mr-3 text-sm font-medium text-gray-700">نشر الكويز الآن</span>
                        </label>
                        <p class="text-xs text-gray-500 mr-8 mt-1">إذا لم يتم تحديده، سيبقى الكويز كمسودة</p>
                    </div>
                </div>

                <!-- Premium Status -->
                <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
                    <h3 class="text-lg font-semibold text-gray-800 mb-4">
                        <i class="fas fa-crown text-yellow-500 mr-2"></i>
                        الاشتراك المدفوع
                    </h3>

                    <div>
                        <label class="flex items-center">
                            <input type="checkbox" name="is_premium" value="1" {{ old('is_premium') ? 'checked' : '' }}
                                   class="w-5 h-5 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
                            <span class="mr-3 text-sm font-medium text-gray-700">كويز مدفوع (Premium)</span>
                        </label>
                        <p class="text-xs text-gray-500 mr-8 mt-1">يتطلب اشتراكاً مدفوعاً للوصول</p>
                    </div>
                </div>

                <!-- Actions -->
                <div class="bg-white rounded-lg shadow-sm p-6">
                    <div class="space-y-3">
                        <button type="submit" class="w-full px-4 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium">
                            <i class="fas fa-save mr-2"></i>
                            حفظ الكويز
                        </button>
                        <a href="{{ route('admin.quizzes.index') }}" class="block w-full px-4 py-3 bg-gray-200 text-gray-700 text-center rounded-lg hover:bg-gray-300 transition-colors font-medium">
                            <i class="fas fa-times mr-2"></i>
                            إلغاء
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </form>
</div>

@push('scripts')
<script>
// Add tag field
function addTagField() {
    const container = document.getElementById('tags-container');
    const div = document.createElement('div');
    div.className = 'flex gap-2';
    div.innerHTML = `
        <input type="text" name="tags[]"
               class="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
               placeholder="مثال: الجبر، المعادلات">
        <button type="button" onclick="this.parentElement.remove()"
                class="px-3 py-2 text-red-600 hover:text-red-800">
            <i class="fas fa-times"></i>
        </button>
    `;
    container.appendChild(div);
}

// Filter chapters by selected subject
document.getElementById('subject_id').addEventListener('change', function() {
    const subjectId = this.value;
    const chapterSelect = document.getElementById('chapter_id');
    const chapterOptions = chapterSelect.querySelectorAll('option[data-subject]');

    chapterSelect.value = '';

    chapterOptions.forEach(option => {
        if (option.dataset.subject == subjectId) {
            option.style.display = 'block';
        } else {
            option.style.display = 'none';
        }
    });
});

// Trigger on page load if subject is already selected
if (document.getElementById('subject_id').value) {
    document.getElementById('subject_id').dispatchEvent(new Event('change'));
}
</script>
@endpush
@endsection
