@extends('layouts.admin')

@section('title', 'استيراد أسئلة من Excel')
@section('page-title', 'استيراد أسئلة من Excel')
@section('page-description', 'رفع ملف Excel لإنشاء كويز مع أسئلة متعددة')

@section('content')
<div class="p-8">

    @if (session('error') || $errors->any())
    <div class="mb-6 bg-red-100 border-r-4 border-red-500 text-red-700 p-4 rounded-lg shadow-sm">
        <div class="flex items-start">
            <i class="fas fa-exclamation-circle mr-3 text-lg mt-1"></i>
            <div class="flex-1">
                <p class="font-bold mb-2">خطأ</p>

                @if (session('error'))
                    <div class="text-sm mb-2">{!! session('error') !!}</div>
                @endif

                @if ($errors->any())
                    <ul class="list-disc list-inside text-sm">
                        @foreach ($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                @endif
            </div>
        </div>
    </div>
    @endif

    <!-- Info Box -->
    <div class="bg-blue-50 border-r-4 border-blue-500 p-4 rounded-lg mb-6">
        <div class="flex items-start">
            <i class="fas fa-info-circle text-blue-600 text-2xl mr-3 mt-1"></i>
            <div>
                <p class="font-bold text-blue-800 mb-2">كيفية استخدام هذه الصفحة:</p>
                <ol class="list-decimal list-inside text-blue-700 text-sm space-y-1">
                    <li><strong>أولاً:</strong> قم بإنشاء قالب Excel يدوياً باتباع الدليل في: <code>storage/app/templates/TEMPLATE_CREATION_GUIDE.md</code></li>
                    <li>قم بتنزيل قالب Excel من الزر أدناه (بعد إنشائه)</li>
                    <li>املأ القالب بالأسئلة (أنواع مدعومة: اختيار واحد، اختيار متعدد، صح/خطأ، إجابة قصيرة)</li>
                    <li>اختر المرحلة، السنة، الشعبة، والمادة</li>
                    <li>أدخل عنوان الاختبار والإعدادات</li>
                    <li>ارفع ملف Excel</li>
                </ol>
                <div class="mt-3 p-2 bg-yellow-100 border border-yellow-300 rounded text-yellow-800 text-xs">
                    <i class="fas fa-exclamation-triangle mr-1"></i>
                    <strong>ملاحظة:</strong> يجب إنشاء ملف القالب يدوياً أولاً. راجع الوثائق في <code>docs/bank_questions/</code>
                </div>
            </div>
        </div>
    </div>

    <!-- Download Template Button -->
    <div class="mb-6">
        <a href="{{ route('admin.quizzes.downloadTemplate') }}"
           class="inline-flex items-center px-6 py-3 bg-gradient-to-r from-green-600 to-green-700 hover:from-green-700 hover:to-green-800 text-white font-medium rounded-lg shadow-md hover:shadow-lg transition-all duration-200">
            <i class="fas fa-download mr-2"></i>
            تنزيل قالب Excel
        </a>
        <span class="mr-3 text-sm text-gray-600">(يتطلب إنشاء القالب يدوياً أولاً)</span>
    </div>

    <form action="{{ route('admin.quizzes.importQuestions') }}" method="POST" enctype="multipart/form-data" id="importForm">
        @csrf

        <div class="flex gap-6">
            <!-- Main Content Area (70%) -->
            <div class="flex-1">

                <!-- Academic Selection -->
                <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
                    <h3 class="text-lg font-semibold text-gray-800 mb-4">
                        <i class="fas fa-graduation-cap text-purple-600 mr-2"></i>
                        المعلومات الأكاديمية
                    </h3>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <!-- Academic Phase -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                المرحلة الدراسية <span class="text-red-500">*</span>
                            </label>
                            <select name="phase_id" id="phase_id" required
                                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500">
                                <option value="">اختر المرحلة</option>
                                @foreach($phases as $phase)
                                    <option value="{{ $phase->id }}" {{ old('phase_id') == $phase->id ? 'selected' : '' }}>
                                        {{ $phase->name_ar }}
                                    </option>
                                @endforeach
                            </select>
                        </div>

                        <!-- Academic Year -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                السنة الدراسية <span class="text-red-500">*</span>
                            </label>
                            <select name="academic_year_id" id="year_id" required
                                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500">
                                <option value="">اختر السنة</option>
                                @foreach($years as $year)
                                    <option value="{{ $year->id }}" data-phase="{{ $year->academic_phase_id }}" {{ old('academic_year_id') == $year->id ? 'selected' : '' }}>
                                        {{ $year->name_ar }}
                                    </option>
                                @endforeach
                            </select>
                        </div>

                        <!-- Academic Stream -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                الشعبة الدراسية
                            </label>
                            <select name="academic_stream_id" id="stream_id"
                                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500">
                                <option value="">اختر الشعبة (اختياري)</option>
                                @foreach($streams as $stream)
                                    <option value="{{ $stream->id }}" data-year="{{ $stream->academic_year_id }}" {{ old('academic_stream_id') == $stream->id ? 'selected' : '' }}>
                                        {{ $stream->name_ar }}
                                    </option>
                                @endforeach
                            </select>
                        </div>

                        <!-- Subject -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                المادة الدراسية <span class="text-red-500">*</span>
                            </label>
                            <select name="subject_id" id="subject_id" required
                                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500">
                                <option value="">اختر المادة</option>
                                @foreach($subjects as $subject)
                                    <option value="{{ $subject->id }}"
                                            data-stream="{{ $subject->academic_stream_id }}"
                                            data-year="{{ $subject->academic_year_id }}"
                                            {{ old('subject_id') == $subject->id ? 'selected' : '' }}>
                                        {{ $subject->name_ar }}
                                    </option>
                                @endforeach
                            </select>
                        </div>

                        <!-- Chapter (Optional) -->
                        <div class="md:col-span-2">
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                الفصل (اختياري)
                            </label>
                            <select name="chapter_id" id="chapter_id"
                                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500">
                                <option value="">لا يوجد فصل محدد</option>
                            </select>
                        </div>
                    </div>
                </div>

                <!-- Quiz Basic Info -->
                <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
                    <h3 class="text-lg font-semibold text-gray-800 mb-4">
                        <i class="fas fa-clipboard-list text-blue-600 mr-2"></i>
                        معلومات الاختبار
                    </h3>

                    <div class="space-y-4">
                        <!-- Quiz Title -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                عنوان الكويز <span class="text-red-500">*</span>
                            </label>
                            <input type="text" name="title_ar" id="title_ar" required
                                   value="{{ old('title_ar') }}"
                                   class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                   placeholder="مثال: اختبار الوحدة الأولى - الرياضيات">
                        </div>

                        <!-- Description -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                الوصف
                            </label>
                            <textarea name="description_ar" rows="3"
                                      class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                      placeholder="وصف مختصر للاختبار...">{{ old('description_ar') }}</textarea>
                        </div>
                    </div>
                </div>

                <!-- Excel File Upload -->
                <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
                    <h3 class="text-lg font-semibold text-gray-800 mb-4">
                        <i class="fas fa-file-excel text-green-600 mr-2"></i>
                        ملف Excel
                    </h3>

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">
                            رفع ملف الأسئلة <span class="text-red-500">*</span>
                        </label>
                        <input type="file" name="excel_file" id="excel_file" required
                               accept=".xlsx,.xls,.csv"
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500">
                        <p class="mt-2 text-sm text-gray-500">
                            <i class="fas fa-info-circle mr-1"></i>
                            الأنواع المدعومة: .xlsx, .xls, .csv (حجم أقصى: 10 ميجابايت)
                        </p>
                    </div>
                </div>
            </div>

            <!-- Sidebar (30%) -->
            <div class="w-96">

                <!-- Quiz Settings -->
                <div class="bg-white rounded-lg shadow-sm p-6 mb-6 sticky top-6">
                    <h3 class="text-lg font-semibold text-gray-800 mb-4">
                        <i class="fas fa-cog text-gray-600 mr-2"></i>
                        إعدادات الاختبار
                    </h3>

                    <div class="space-y-4">
                        <!-- Quiz Type -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                نوع الكويز <span class="text-red-500">*</span>
                            </label>
                            <select name="quiz_type" required
                                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                                <option value="practice" {{ old('quiz_type') == 'practice' ? 'selected' : '' }}>تدريبي</option>
                                <option value="timed" {{ old('quiz_type') == 'timed' ? 'selected' : '' }}>موقوت</option>
                                <option value="exam" {{ old('quiz_type') == 'exam' ? 'selected' : '' }}>امتحان</option>
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
                                <option value="medium" {{ old('difficulty_level', 'medium') == 'medium' ? 'selected' : '' }}>متوسط</option>
                                <option value="hard" {{ old('difficulty_level') == 'hard' ? 'selected' : '' }}>صعب</option>
                            </select>
                        </div>

                        <!-- Passing Score -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                درجة النجاح (%) <span class="text-red-500">*</span>
                            </label>
                            <input type="number" name="passing_score" min="0" max="100"
                                   value="{{ old('passing_score', 60) }}" required
                                   class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                        </div>

                        <!-- Time Limit -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                الحد الزمني (دقيقة)
                            </label>
                            <input type="number" name="time_limit_minutes" min="1"
                                   value="{{ old('time_limit_minutes') }}"
                                   class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                   placeholder="اختياري">
                        </div>

                        <!-- Estimated Duration -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                المدة المقدرة (دقيقة)
                            </label>
                            <input type="number" name="estimated_duration_minutes" min="1"
                                   value="{{ old('estimated_duration_minutes') }}"
                                   class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                   placeholder="اختياري">
                        </div>

                        <!-- Display Options -->
                        <div class="space-y-2 pt-2 border-t">
                            <label class="flex items-center">
                                <input type="checkbox" name="shuffle_questions" value="1"
                                       {{ old('shuffle_questions', true) ? 'checked' : '' }}
                                       class="rounded border-gray-300 text-blue-600 focus:ring-blue-500 mr-2">
                                <span class="text-sm text-gray-700">خلط ترتيب الأسئلة</span>
                            </label>

                            <label class="flex items-center">
                                <input type="checkbox" name="shuffle_answers" value="1"
                                       {{ old('shuffle_answers', true) ? 'checked' : '' }}
                                       class="rounded border-gray-300 text-blue-600 focus:ring-blue-500 mr-2">
                                <span class="text-sm text-gray-700">خلط ترتيب الإجابات</span>
                            </label>

                            <label class="flex items-center">
                                <input type="checkbox" name="show_correct_answers" value="1"
                                       {{ old('show_correct_answers', true) ? 'checked' : '' }}
                                       class="rounded border-gray-300 text-blue-600 focus:ring-blue-500 mr-2">
                                <span class="text-sm text-gray-700">عرض الإجابات الصحيحة</span>
                            </label>

                            <label class="flex items-center">
                                <input type="checkbox" name="allow_review" value="1"
                                       {{ old('allow_review', true) ? 'checked' : '' }}
                                       class="rounded border-gray-300 text-blue-600 focus:ring-blue-500 mr-2">
                                <span class="text-sm text-gray-700">السماح بالمراجعة</span>
                            </label>
                        </div>
                    </div>
                </div>

                <!-- Action Buttons -->
                <div class="bg-white rounded-lg shadow-sm p-6">
                    <button type="submit"
                            class="w-full bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white font-medium py-3 rounded-lg shadow-md hover:shadow-lg transition-all duration-200 mb-3">
                        <i class="fas fa-upload mr-2"></i>
                        استيراد وإنشاء الكويز
                    </button>

                    <a href="{{ route('admin.quizzes.index') }}"
                       class="block w-full text-center bg-gray-200 hover:bg-gray-300 text-gray-700 font-medium py-3 rounded-lg transition-colors duration-200">
                        <i class="fas fa-times mr-2"></i>
                        إلغاء
                    </a>
                </div>
            </div>
        </div>
    </form>
</div>

@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', function() {
    // Cascading dropdowns logic
    const phaseSelect = document.getElementById('phase_id');
    const yearSelect = document.getElementById('year_id');
    const streamSelect = document.getElementById('stream_id');
    const subjectSelect = document.getElementById('subject_id');
    const chapterSelect = document.getElementById('chapter_id');

    // Store original options
    const allYears = Array.from(yearSelect.querySelectorAll('option:not(:first-child)'));
    const allStreams = Array.from(streamSelect.querySelectorAll('option:not(:first-child)'));
    const allSubjects = Array.from(subjectSelect.querySelectorAll('option:not(:first-child)'));

    // Phase change -> filter years
    phaseSelect.addEventListener('change', function() {
        const phaseId = this.value;

        // Clear and reset year dropdown
        yearSelect.innerHTML = '<option value="">اختر السنة</option>';

        if (phaseId) {
            const filteredYears = allYears.filter(option =>
                option.dataset.phase == phaseId
            );
            filteredYears.forEach(option => yearSelect.appendChild(option.cloneNode(true)));
        } else {
            allYears.forEach(option => yearSelect.appendChild(option.cloneNode(true)));
        }

        // Trigger year change to update streams
        yearSelect.dispatchEvent(new Event('change'));
    });

    // Year change -> filter streams
    yearSelect.addEventListener('change', function() {
        const yearId = this.value;

        // Clear and reset stream dropdown
        streamSelect.innerHTML = '<option value="">اختر الشعبة (اختياري)</option>';

        if (yearId) {
            const filteredStreams = allStreams.filter(option =>
                option.dataset.year == yearId
            );
            filteredStreams.forEach(option => streamSelect.appendChild(option.cloneNode(true)));
        } else {
            allStreams.forEach(option => streamSelect.appendChild(option.cloneNode(true)));
        }

        // Trigger stream change to update subjects
        streamSelect.dispatchEvent(new Event('change'));
    });

    // Stream change -> filter subjects
    streamSelect.addEventListener('change', function() {
        const streamId = this.value;
        const yearId = yearSelect.value;

        // Clear and reset subject dropdown
        subjectSelect.innerHTML = '<option value="">اختر المادة</option>';

        if (streamId) {
            // Filter by stream
            const filteredSubjects = allSubjects.filter(option =>
                option.dataset.stream == streamId
            );
            filteredSubjects.forEach(option => subjectSelect.appendChild(option.cloneNode(true)));
        } else if (yearId) {
            // Filter by year (common subjects)
            const filteredSubjects = allSubjects.filter(option =>
                option.dataset.year == yearId && !option.dataset.stream
            );
            filteredSubjects.forEach(option => subjectSelect.appendChild(option.cloneNode(true)));
        } else {
            allSubjects.forEach(option => subjectSelect.appendChild(option.cloneNode(true)));
        }

        // Trigger subject change to update chapters
        subjectSelect.dispatchEvent(new Event('change'));
    });

    // Subject change -> load chapters via AJAX
    subjectSelect.addEventListener('change', function() {
        const subjectId = this.value;

        // Clear chapters
        chapterSelect.innerHTML = '<option value="">لا يوجد فصل محدد</option>';

        if (subjectId) {
            fetch(`/admin/quizzes/ajax/chapters/${subjectId}`)
                .then(response => response.json())
                .then(chapters => {
                    chapters.forEach(chapter => {
                        const option = document.createElement('option');
                        option.value = chapter.id;
                        option.textContent = chapter.title_ar;
                        chapterSelect.appendChild(option);
                    });
                })
                .catch(error => console.error('Error loading chapters:', error));
        }
    });

    // File upload validation
    const fileInput = document.getElementById('excel_file');
    fileInput.addEventListener('change', function() {
        const file = this.files[0];
        if (file) {
            const maxSize = 10 * 1024 * 1024; // 10MB
            if (file.size > maxSize) {
                alert('حجم الملف أكبر من 10 ميجابايت!');
                this.value = '';
                return;
            }

            const allowedTypes = [
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                'application/vnd.ms-excel',
                'text/csv'
            ];

            if (!allowedTypes.includes(file.type)) {
                alert('نوع الملف غير مدعوم! يرجى رفع ملف Excel أو CSV.');
                this.value = '';
                return;
            }
        }
    });

    // Form submission loading state
    const form = document.getElementById('importForm');
    form.addEventListener('submit', function(e) {
        const submitButton = form.querySelector('button[type="submit"]');
        submitButton.disabled = true;
        submitButton.innerHTML = '<i class="fas fa-spinner fa-spin mr-2"></i>جاري الاستيراد...';
    });
});
</script>
@endpush

@endsection
