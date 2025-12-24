@extends('layouts.admin')

@section('title', 'إضافة محتوى تعليمي جديد')
@section('page-title', 'إضافة محتوى تعليمي جديد')
@section('page-description', 'إنشاء محتوى تعليمي جديد (درس، ملخص، تمارين، اختبار)')

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

    <form action="{{ route('admin.contents.store') }}" method="POST" id="contentForm" enctype="multipart/form-data">
        @csrf

        <div class="flex gap-6">
            <!-- Main Content Area (70%) -->
            <div class="flex-1">
                <!-- Tabs Navigation -->
                <div class="bg-white rounded-lg shadow-sm mb-6">
                    <div class="border-b border-gray-200">
                        <nav class="flex -mb-px">
                            <button type="button" onclick="switchTab('basic')" id="tab-basic"
                                    class="tab-button active px-6 py-3 border-b-2 border-blue-600 text-blue-600 font-medium">
                                <i class="fas fa-info-circle mr-2"></i>
                                المعلومات الأساسية
                            </button>
                            <button type="button" onclick="switchTab('content')" id="tab-content"
                                    class="tab-button px-6 py-3 border-b-2 border-transparent text-gray-500 hover:text-gray-700 font-medium">
                                <i class="fas fa-align-right mr-2"></i>
                                المحتوى
                            </button>
                            <button type="button" onclick="switchTab('files')" id="tab-files"
                                    class="tab-button px-6 py-3 border-b-2 border-transparent text-gray-500 hover:text-gray-700 font-medium">
                                <i class="fas fa-file-upload mr-2"></i>
                                الملفات والوسائط
                            </button>
                            <button type="button" onclick="switchTab('metadata')" id="tab-metadata"
                                    class="tab-button px-6 py-3 border-b-2 border-transparent text-gray-500 hover:text-gray-700 font-medium">
                                <i class="fas fa-tags mr-2"></i>
                                البيانات الوصفية
                            </button>
                        </nav>
                    </div>
                </div>

                <!-- Tab Content -->
                <div class="bg-white rounded-lg shadow-sm p-6">
                    <!-- Tab 1: Basic Info -->
                    <div id="content-basic" class="tab-content">
                        <h3 class="text-lg font-semibold text-gray-800 mb-4">المعلومات الأساسية</h3>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <!-- Content Type -->
                            <div class="md:col-span-2">
                                <label class="block text-sm font-medium text-gray-700 mb-2">
                                    نوع المحتوى <span class="text-red-500">*</span>
                                </label>
                                <div class="grid grid-cols-2 md:grid-cols-5 gap-3">
                                    @foreach($contentTypes as $type)
                                    <label class="flex items-center p-3 border-2 border-gray-200 rounded-lg cursor-pointer hover:border-blue-500 transition-colors">
                                        <input type="radio" name="content_type_id" value="{{ $type->id }}"
                                               class="ml-2" {{ old('content_type_id') == $type->id ? 'checked' : '' }} required>
                                        <div>
                                            <i class="fas fa-{{ $type->icon }} text-blue-600"></i>
                                            <span class="text-sm font-medium mr-1">{{ $type->name_ar }}</span>
                                        </div>
                                    </label>
                                    @endforeach
                                </div>
                            </div>

                            <!-- Academic Phase -->
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">
                                    المرحلة الدراسية <span class="text-red-500">*</span>
                                </label>
                                <select name="phase_id" id="phase_id"
                                        class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500" required>
                                    <option value="">اختر المرحلة الدراسية</option>
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
                                <select name="academic_year_id" id="academic_year_id"
                                        class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500" required disabled>
                                    <option value="">اختر السنة الدراسية</option>
                                </select>
                                <p class="text-xs text-gray-500 mt-1">يرجى اختيار المرحلة أولاً</p>
                            </div>

                            <!-- Academic Stream -->
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">
                                    الشعبة الدراسية <span class="text-red-500">*</span>
                                </label>
                                <select name="stream_id" id="stream_id"
                                        class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500" required disabled>
                                    <option value="">اختر الشعبة الدراسية</option>
                                </select>
                                <p class="text-xs text-gray-500 mt-1">يرجى اختيار السنة أولاً</p>
                            </div>

                            <!-- Subject -->
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">
                                    المادة <span class="text-red-500">*</span>
                                </label>
                                <select name="subject_id" id="subject_id"
                                        class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500" required disabled>
                                    <option value="">اختر المادة</option>
                                </select>
                                <p class="text-xs text-gray-500 mt-1">يرجى اختيار الشعبة أولاً</p>
                            </div>

                            <!-- Chapter -->
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">
                                    الفصل (اختياري)
                                </label>
                                <select name="chapter_id" id="chapter_id"
                                        class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                                    <option value="">اختر الفصل</option>
                                    @foreach($chapters as $chapter)
                                    <option value="{{ $chapter->id }}" data-subject="{{ $chapter->subject_id }}"
                                            {{ old('chapter_id') == $chapter->id ? 'selected' : '' }}>
                                        {{ $chapter->title_ar }}
                                    </option>
                                    @endforeach
                                </select>
                            </div>

                            <!-- Quiz Selection (Only for Exam/Test content type) -->
                            <div id="quiz-selection-section" class="md:col-span-2 hidden">
                                <div class="bg-purple-50 border-2 border-purple-200 rounded-lg p-4">
                                    <label class="block text-sm font-medium text-purple-900 mb-3">
                                        <i class="fas fa-clipboard-question mr-2"></i>
                                        ربط اختبارات موجودة (يمكن اختيار أكثر من واحد)
                                    </label>

                                    <div class="flex gap-3 mb-3">
                                        <a href="#" id="view-quizzes-link" target="_blank"
                                           class="bg-purple-600 hover:bg-purple-700 text-white px-4 py-2 rounded-lg transition-colors inline-flex items-center">
                                            <i class="fas fa-external-link-alt mr-2"></i>
                                            تصفح الاختبارات
                                        </a>
                                    </div>

                                    <!-- Quizzes will be loaded here as checkboxes -->
                                    <div id="quiz-checkboxes-container" class="space-y-2 max-h-60 overflow-y-auto">
                                        <p class="text-gray-500 text-sm">جاري تحميل الاختبارات...</p>
                                    </div>

                                    <p class="text-xs text-purple-700 mt-3">
                                        <i class="fas fa-info-circle"></i>
                                        يمكنك ربط اختبار أو أكثر بهذا المحتوى، أو تركها فارغة لإنشاء محتوى عادي
                                    </p>
                                </div>
                            </div>

                            <!-- Title -->
                            <div class="md:col-span-2">
                                <label class="block text-sm font-medium text-gray-700 mb-2">
                                    العنوان <span class="text-red-500">*</span>
                                </label>
                                <input type="text" name="title_ar" value="{{ old('title_ar') }}"
                                       placeholder="مثال: الدالة الأسية وخصائصها"
                                       class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500" required>
                            </div>

                            <!-- Description -->
                            <div class="md:col-span-2">
                                <label class="block text-sm font-medium text-gray-700 mb-2">
                                    الوصف المختصر
                                </label>
                                <textarea name="description_ar" rows="3"
                                          placeholder="وصف مختصر عن المحتوى..."
                                          class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">{{ old('description_ar') }}</textarea>
                            </div>

                            <!-- Difficulty -->
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">
                                    مستوى الصعوبة <span class="text-red-500">*</span>
                                </label>
                                <div class="flex gap-3">
                                    <label class="flex items-center">
                                        <input type="radio" name="difficulty_level" value="easy"
                                               class="ml-2" {{ old('difficulty_level') == 'easy' ? 'checked' : '' }} required>
                                        <span class="px-3 py-1 text-xs rounded-full bg-green-100 text-green-800">سهل</span>
                                    </label>
                                    <label class="flex items-center">
                                        <input type="radio" name="difficulty_level" value="medium"
                                               class="ml-2" {{ old('difficulty_level') == 'medium' ? 'checked' : '' }}>
                                        <span class="px-3 py-1 text-xs rounded-full bg-yellow-100 text-yellow-800">متوسط</span>
                                    </label>
                                    <label class="flex items-center">
                                        <input type="radio" name="difficulty_level" value="hard"
                                               class="ml-2" {{ old('difficulty_level') == 'hard' ? 'checked' : '' }}>
                                        <span class="px-3 py-1 text-xs rounded-full bg-red-100 text-red-800">صعب</span>
                                    </label>
                                </div>
                            </div>

                            <!-- Duration -->
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">
                                    المدة المقدرة (بالدقائق)
                                </label>
                                <input type="number" name="estimated_duration_minutes" value="{{ old('estimated_duration_minutes') }}"
                                       placeholder="60"
                                       class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                            </div>

                            <!-- Order -->
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">
                                    الترتيب
                                </label>
                                <input type="number" name="order" value="{{ old('order', 0) }}"
                                       class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                            </div>
                        </div>
                    </div>

                    <!-- Tab 2: Content Body -->
                    <div id="content-content" class="tab-content hidden">
                        <h3 class="text-lg font-semibold text-gray-800 mb-4">محتوى الدرس</h3>

                        <div class="mb-4">
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                المحتوى التفصيلي
                            </label>
                            <textarea name="content_body_ar" id="content_body_ar" rows="20"
                                      placeholder="اكتب المحتوى التعليمي هنا... يدعم HTML و Markdown"
                                      class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 font-mono text-sm">{{ old('content_body_ar') }}</textarea>
                            <p class="text-xs text-gray-500 mt-2">
                                <i class="fas fa-info-circle"></i>
                                يمكنك استخدام HTML أو Markdown. للمعادلات الرياضية استخدم MathJax: \( formula \) أو $$ formula $$
                            </p>
                        </div>

                        <!-- Formatting Toolbar -->
                        <div class="bg-gray-50 p-4 rounded-lg border border-gray-200">
                            <p class="text-sm font-medium text-gray-700 mb-2">أمثلة التنسيق:</p>
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-2 text-xs text-gray-600">
                                <div><code class="bg-white px-2 py-1 rounded">**نص عريض**</code> → <strong>نص عريض</strong></div>
                                <div><code class="bg-white px-2 py-1 rounded">*نص مائل*</code> → <em>نص مائل</em></div>
                                <div><code class="bg-white px-2 py-1 rounded"># عنوان</code> → عنوان كبير</div>
                                <div><code class="bg-white px-2 py-1 rounded">- قائمة</code> → قائمة نقطية</div>
                            </div>
                        </div>
                    </div>

                    <!-- Tab 3: Files & Media -->
                    <div id="content-files" class="tab-content hidden">
                        <h3 class="text-lg font-semibold text-gray-800 mb-4">الملفات والوسائط</h3>

                        <!-- PDF/DOC Upload -->
                        <div class="mb-6">
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                <i class="fas fa-file-pdf text-red-600 mr-1"></i>
                                ملف PDF أو Word
                            </label>
                            <input type="file" name="pdf_file" accept=".pdf,.doc,.docx"
                                   class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                            <p class="text-xs text-gray-500 mt-1">الحجم الأقصى: 10 ميجابايت</p>
                        </div>

                        <!-- Video URL (YouTube) -->
                        <div class="mb-6">
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                <i class="fab fa-youtube text-red-600 mr-1"></i>
                                رابط فيديو YouTube
                            </label>
                            <input type="url" name="video_url" value="{{ old('video_url') }}"
                                   placeholder="https://www.youtube.com/watch?v=..."
                                   class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                        </div>

                        <!-- Video Upload -->
                        <div class="mb-6">
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                <i class="fas fa-video text-blue-600 mr-1"></i>
                                أو ارفع فيديو من جهازك
                            </label>
                            <input type="file" name="video_file" accept="video/*"
                                   class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                            <p class="text-xs text-gray-500 mt-1">الحجم الأقصى: 50 ميجابايت</p>
                        </div>

                        <!-- Additional Files -->
                        <div class="mb-6">
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                <i class="fas fa-paperclip mr-1"></i>
                                ملفات إضافية
                            </label>
                            <input type="file" name="additional_files[]" multiple
                                   class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                            <p class="text-xs text-gray-500 mt-1">يمكنك رفع عدة ملفات (صور، مستندات، إلخ)</p>
                        </div>
                    </div>

                    <!-- Tab 4: Metadata -->
                    <div id="content-metadata" class="tab-content hidden">
                        <h3 class="text-lg font-semibold text-gray-800 mb-4">البيانات الوصفية</h3>

                        <!-- Tags -->
                        <div class="mb-6">
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                الكلمات المفتاحية (Tags)
                            </label>
                            <input type="text" name="tags" value="{{ old('tags') }}"
                                   placeholder="مثال: رياضيات، دوال، باكالوريا (افصل بفواصل)"
                                   class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                            <p class="text-xs text-gray-500 mt-1">افصل الكلمات المفتاحية بفواصل</p>
                        </div>

                        <!-- Search Keywords -->
                        <div class="mb-6">
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                كلمات البحث
                            </label>
                            <textarea name="search_keywords" rows="3"
                                      placeholder="كلمات إضافية لتسهيل البحث..."
                                      class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">{{ old('search_keywords') }}</textarea>
                        </div>

                        <!-- Premium Content -->
                        <div class="mb-6">
                            <label class="flex items-center">
                                <input type="checkbox" name="is_premium" value="1"
                                       class="ml-2 w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
                                       {{ old('is_premium') ? 'checked' : '' }}>
                                <span class="text-sm font-medium text-gray-700">
                                    <i class="fas fa-crown text-yellow-500 mr-1"></i>
                                    محتوى مميز (Premium)
                                </span>
                            </label>
                            <p class="text-xs text-gray-500 mr-6 mt-1">سيتطلب اشتراكًا مدفوعًا للوصول إليه</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Sidebar Actions (30%) -->
            <div class="w-80">
                <!-- Publication Status -->
                <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
                    <h3 class="text-lg font-semibold text-gray-800 mb-4">
                        <i class="fas fa-paper-plane mr-2 text-blue-600"></i>
                        النشر
                    </h3>

                    <div class="mb-4">
                        <label class="flex items-center">
                            <input type="checkbox" name="is_published" value="1"
                                   class="ml-2 w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
                                   {{ old('is_published') ? 'checked' : '' }}>
                            <span class="text-sm font-medium text-gray-700">نشر مباشرة</span>
                        </label>
                        <p class="text-xs text-gray-500 mr-6 mt-1">إذا لم يتم التحديد، سيتم حفظه كمسودة</p>
                    </div>

                    <div class="border-t border-gray-200 pt-4">
                        <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors mb-2">
                            <i class="fas fa-save mr-2"></i>
                            حفظ المحتوى
                        </button>
                        <a href="{{ route('admin.contents.index') }}" class="block w-full text-center bg-gray-200 hover:bg-gray-300 text-gray-700 px-4 py-2 rounded-lg transition-colors">
                            <i class="fas fa-times mr-2"></i>
                            إلغاء
                        </a>
                    </div>
                </div>

                <!-- Help Card -->
                <div class="bg-blue-50 rounded-lg p-4 border border-blue-200">
                    <h4 class="font-semibold text-blue-900 mb-2">
                        <i class="fas fa-info-circle mr-1"></i>
                        نصائح
                    </h4>
                    <ul class="text-xs text-blue-800 space-y-1">
                        <li>• املأ جميع الحقول المطلوبة بعناية</li>
                        <li>• استخدم عناوين واضحة ومفيدة</li>
                        <li>• أضف كلمات مفتاحية لتسهيل البحث</li>
                        <li>• راجع المحتوى قبل النشر</li>
                        <li>• يمكنك حفظه كمسودة والعودة لاحقًا</li>
                    </ul>
                </div>
            </div>
        </div>

    </form>

</div>

<script>
// Tab Switching
function switchTab(tabName) {
    // Hide all tab contents
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.add('hidden');
    });

    // Remove active class from all tab buttons
    document.querySelectorAll('.tab-button').forEach(button => {
        button.classList.remove('active', 'border-blue-600', 'text-blue-600');
        button.classList.add('border-transparent', 'text-gray-500');
    });

    // Show selected tab content
    document.getElementById('content-' + tabName).classList.remove('hidden');

    // Add active class to selected tab button
    const activeButton = document.getElementById('tab-' + tabName);
    activeButton.classList.add('active', 'border-blue-600', 'text-blue-600');
    activeButton.classList.remove('border-transparent', 'text-gray-500');
}

// Cascading Dropdowns - Phase -> Year -> Stream -> Subject

// 1. When Phase changes, load Years
document.getElementById('phase_id').addEventListener('change', function() {
    const phaseId = this.value;
    const yearSelect = document.getElementById('academic_year_id');
    const streamSelect = document.getElementById('stream_id');
    const subjectSelect = document.getElementById('subject_id');

    // Reset dependent dropdowns
    yearSelect.innerHTML = '<option value="">اختر السنة الدراسية</option>';
    yearSelect.disabled = true;
    streamSelect.innerHTML = '<option value="">اختر الشعبة الدراسية</option>';
    streamSelect.disabled = true;
    subjectSelect.innerHTML = '<option value="">اختر المادة</option>';
    subjectSelect.disabled = true;

    if (phaseId) {
        // Load years for this phase
        fetch(`/admin/subjects/ajax/years/${phaseId}`)
            .then(response => response.json())
            .then(years => {
                years.forEach(year => {
                    const option = document.createElement('option');
                    option.value = year.id;
                    option.textContent = year.name_ar;
                    yearSelect.appendChild(option);
                });
                yearSelect.disabled = false;
            })
            .catch(error => console.error('Error loading years:', error));
    }
});

// 2. When Year changes, load Streams
document.getElementById('academic_year_id').addEventListener('change', function() {
    const yearId = this.value;
    const streamSelect = document.getElementById('stream_id');
    const subjectSelect = document.getElementById('subject_id');

    // Reset dependent dropdowns
    streamSelect.innerHTML = '<option value="">اختر الشعبة الدراسية</option>';
    streamSelect.disabled = true;
    subjectSelect.innerHTML = '<option value="">اختر المادة</option>';
    subjectSelect.disabled = true;

    if (yearId) {
        // Load streams for this year
        fetch(`/admin/subjects/ajax/streams/${yearId}`)
            .then(response => response.json())
            .then(streams => {
                streams.forEach(stream => {
                    const option = document.createElement('option');
                    option.value = stream.id;
                    option.textContent = stream.name_ar;
                    streamSelect.appendChild(option);
                });
                streamSelect.disabled = false;
            })
            .catch(error => console.error('Error loading streams:', error));
    }
});

// 3. When Stream changes, load Subjects
document.getElementById('stream_id').addEventListener('change', function() {
    const streamId = this.value;
    const subjectSelect = document.getElementById('subject_id');

    // Reset subject dropdown
    subjectSelect.innerHTML = '<option value="">اختر المادة</option>';
    subjectSelect.disabled = true;

    if (streamId) {
        // Load subjects for this stream
        fetch(`/admin/subjects/ajax/subjects/${streamId}`)
            .then(response => response.json())
            .then(subjects => {
                subjects.forEach(subject => {
                    const option = document.createElement('option');
                    option.value = subject.id;
                    option.textContent = subject.name_ar;
                    subjectSelect.appendChild(option);
                });
                subjectSelect.disabled = false;
            })
            .catch(error => console.error('Error loading subjects:', error));
    }
});

// 4. Filter chapters by selected subject
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

    // Load quizzes for selected subject if content type is exam/test
    loadQuizzesForSubject(subjectId);
});

// 5. Show/Hide Quiz Selection based on Content Type
const contentTypeRadios = document.querySelectorAll('input[name="content_type_id"]');
contentTypeRadios.forEach(radio => {
    radio.addEventListener('change', function() {
        checkContentTypeForQuiz();
    });
});

function checkContentTypeForQuiz() {
    const selectedContentType = document.querySelector('input[name="content_type_id"]:checked');
    const quizSection = document.getElementById('quiz-selection-section');

    if (selectedContentType) {
        const contentTypeId = selectedContentType.value;
        // Get the text of the selected content type
        const contentTypeLabel = selectedContentType.parentElement.textContent.trim();

        // Check if it's exam or test content type (إختبار or فرض)
        if (contentTypeLabel.includes('اختبار') || contentTypeLabel.includes('فرض')) {
            quizSection.classList.remove('hidden');

            // Load quizzes if subject is already selected
            const subjectId = document.getElementById('subject_id').value;
            if (subjectId) {
                loadQuizzesForSubject(subjectId);
            }
        } else {
            quizSection.classList.add('hidden');
        }
    }
}

// 6. Load Quizzes for Selected Subject
function loadQuizzesForSubject(subjectId) {
    const container = document.getElementById('quiz-checkboxes-container');
    const quizLink = document.getElementById('view-quizzes-link');
    const quizSection = document.getElementById('quiz-selection-section');

    // Only proceed if quiz section is visible (content type is exam/test)
    if (quizSection.classList.contains('hidden')) {
        return;
    }

    // Update link to quizzes page with subject filter
    quizLink.href = `/admin/quizzes?subject_id=${subjectId}`;

    if (subjectId) {
        container.innerHTML = '<p class="text-gray-500 text-sm animate-pulse">جاري تحميل الاختبارات...</p>';

        // Fetch quizzes for this subject
        fetch(`/admin/quizzes/ajax/by-subject/${subjectId}`)
            .then(response => response.json())
            .then(quizzes => {
                if (quizzes.length === 0) {
                    container.innerHTML = '<p class="text-gray-400 text-sm">لا توجد اختبارات متاحة لهذه المادة</p>';
                    return;
                }

                // Build checkboxes HTML
                let html = '<div class="space-y-2">';
                quizzes.forEach(quiz => {
                    const difficultyBadge = {
                        'easy': '<span class="text-xs bg-green-100 text-green-700 px-2 py-0.5 rounded">سهل</span>',
                        'medium': '<span class="text-xs bg-yellow-100 text-yellow-700 px-2 py-0.5 rounded">متوسط</span>',
                        'hard': '<span class="text-xs bg-red-100 text-red-700 px-2 py-0.5 rounded">صعب</span>'
                    };

                    html += `
                        <label class="flex items-center p-3 bg-white border border-purple-200 rounded-lg hover:bg-purple-50 cursor-pointer transition-colors">
                            <input type="checkbox" name="quiz_ids[]" value="${quiz.id}"
                                   class="w-4 h-4 text-purple-600 border-gray-300 rounded focus:ring-purple-500">
                            <div class="mr-3 flex-1">
                                <div class="font-medium text-gray-900">${quiz.title_ar}</div>
                                <div class="text-xs text-gray-600 mt-1">
                                    <span><i class="fas fa-question-circle mr-1"></i>${quiz.total_questions || 0} سؤال</span>
                                    <span class="mr-3">${difficultyBadge[quiz.difficulty_level] || ''}</span>
                                    <span class="text-purple-600">${quiz.quiz_type || ''}</span>
                                </div>
                            </div>
                        </label>
                    `;
                });
                html += '</div>';

                container.innerHTML = html;
            })
            .catch(error => {
                console.error('Error loading quizzes:', error);
                container.innerHTML = '<p class="text-red-500 text-sm">حدث خطأ في تحميل الاختبارات</p>';
            });
    } else {
        container.innerHTML = '<p class="text-gray-400 text-sm">يرجى اختيار المادة أولاً</p>';
    }
}

// Trigger on page load if selections exist (for old() values)
window.addEventListener('DOMContentLoaded', function() {
    if (document.getElementById('phase_id').value) {
        document.getElementById('phase_id').dispatchEvent(new Event('change'));
    }
});

@if(isset($prefilledSubject) && $prefilledSubject)
// Auto-fill academic fields when subject_id is provided
document.addEventListener('DOMContentLoaded', function() {
    @if($prefilledSubject->academicStream)
    // Subject has stream (3-level hierarchy: Phase -> Year -> Stream -> Subject)
    const phaseId = {{ $prefilledSubject->academicStream->academicYear->academicPhase->id }};
    const yearId = {{ $prefilledSubject->academicStream->academic_year_id }};
    const streamId = {{ $prefilledSubject->academic_stream_id }};
    const subjectId = {{ $prefilledSubject->id }};

    // Pre-select phase
    document.getElementById('phase_id').value = phaseId;
    document.getElementById('phase_id').dispatchEvent(new Event('change'));

    // Pre-select year (after phase loads years)
    setTimeout(() => {
        document.getElementById('academic_year_id').value = yearId;
        document.getElementById('academic_year_id').dispatchEvent(new Event('change'));

        // Pre-select stream (after year loads streams)
        setTimeout(() => {
            document.getElementById('stream_id').value = streamId;
            document.getElementById('stream_id').dispatchEvent(new Event('change'));

            // Pre-select subject (after stream loads subjects)
            setTimeout(() => {
                document.getElementById('subject_id').value = subjectId;
                document.getElementById('subject_id').dispatchEvent(new Event('change'));

                // Make fields read-only and add hidden inputs
                ['phase_id', 'academic_year_id', 'stream_id', 'subject_id'].forEach(field => {
                    const element = document.getElementById(field);
                    element.disabled = true;
                    element.classList.add('bg-gray-100', 'cursor-not-allowed');

                    // Add hidden input to ensure value is submitted
                    const hidden = document.createElement('input');
                    hidden.type = 'hidden';
                    hidden.name = field;
                    hidden.value = element.value;
                    document.querySelector('form').appendChild(hidden);
                });
            }, 300);
        }, 300);
    }, 300);
    @else
    // Subject has no stream (2-level hierarchy: Phase -> Year -> Subject)
    const phaseId = {{ $prefilledSubject->academicYear->academicPhase->id }};
    const yearId = {{ $prefilledSubject->academic_year_id }};
    const subjectId = {{ $prefilledSubject->id }};

    // Pre-select phase
    document.getElementById('phase_id').value = phaseId;
    document.getElementById('phase_id').dispatchEvent(new Event('change'));

    // Pre-select year (after phase loads years)
    setTimeout(() => {
        document.getElementById('academic_year_id').value = yearId;
        document.getElementById('academic_year_id').dispatchEvent(new Event('change'));

        // Pre-select subject (after year loads subjects)
        setTimeout(() => {
            document.getElementById('subject_id').value = subjectId;
            document.getElementById('subject_id').dispatchEvent(new Event('change'));

            // Make fields read-only and add hidden inputs
            ['phase_id', 'academic_year_id', 'subject_id'].forEach(field => {
                const element = document.getElementById(field);
                element.disabled = true;
                element.classList.add('bg-gray-100', 'cursor-not-allowed');

                // Add hidden input to ensure value is submitted
                const hidden = document.createElement('input');
                hidden.type = 'hidden';
                hidden.name = field;
                hidden.value = element.value;
                document.querySelector('form').appendChild(hidden);
            });

            // Note: stream field remains enabled for non-stream subjects
        }, 300);
    }, 300);
    @endif
});
@endif

// Auto-save functionality (optional, can be implemented later)
// let autoSaveTimer;
// const form = document.getElementById('contentForm');
// form.addEventListener('input', function() {
//     clearTimeout(autoSaveTimer);
//     autoSaveTimer = setTimeout(() => {
//         console.log('Auto-saving...');
//         // Implement auto-save AJAX call here
//     }, 120000); // 2 minutes
// });
</script>

<style>
.tab-button.active {
    border-color: #2563eb;
    color: #2563eb;
}
</style>
@endsection
