@extends('layouts.admin')

@section('title', 'تعديل المحتوى التعليمي')
@section('page-title', 'تعديل: ' . $content->title_ar)
@section('page-description', 'تعديل المحتوى التعليمي')

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

    <form action="{{ route('admin.contents.update', $content) }}" method="POST" id="contentForm" enctype="multipart/form-data">
        @csrf
        @method('PUT')

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
                                    <label class="flex items-center p-3 border-2 border-gray-200 rounded-lg cursor-pointer hover:border-blue-500 transition-colors {{ $content->content_type_id == $type->id ? 'border-blue-500 bg-blue-50' : '' }}">
                                        <input type="radio" name="content_type_id" value="{{ $type->id }}"
                                               class="ml-2" {{ old('content_type_id', $content->content_type_id) == $type->id ? 'checked' : '' }} required>
                                        <div>
                                            <i class="fas fa-{{ $type->icon }} text-blue-600"></i>
                                            <span class="text-sm font-medium mr-1">{{ $type->name_ar }}</span>
                                        </div>
                                    </label>
                                    @endforeach
                                </div>
                            </div>

                            <!-- Subject -->
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">
                                    المادة <span class="text-red-500">*</span>
                                </label>
                                <select name="subject_id" id="subject_id"
                                        class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500" required>
                                    <option value="">اختر المادة</option>
                                    @foreach($subjects as $subject)
                                    <option value="{{ $subject->id }}" {{ old('subject_id', $content->subject_id) == $subject->id ? 'selected' : '' }}>
                                        {{ $subject->name_ar }}
                                    </option>
                                    @endforeach
                                </select>
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
                                            {{ old('chapter_id', $content->chapter_id) == $chapter->id ? 'selected' : '' }}>
                                        {{ $chapter->title_ar }}
                                    </option>
                                    @endforeach
                                </select>
                            </div>

                            <!-- Title -->
                            <div class="md:col-span-2">
                                <label class="block text-sm font-medium text-gray-700 mb-2">
                                    العنوان <span class="text-red-500">*</span>
                                </label>
                                <input type="text" name="title_ar" value="{{ old('title_ar', $content->title_ar) }}"
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
                                          class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">{{ old('description_ar', $content->description_ar) }}</textarea>
                            </div>

                            <!-- Difficulty -->
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">
                                    مستوى الصعوبة <span class="text-red-500">*</span>
                                </label>
                                <div class="flex gap-3">
                                    <label class="flex items-center">
                                        <input type="radio" name="difficulty_level" value="easy"
                                               class="ml-2" {{ old('difficulty_level', $content->difficulty_level) == 'easy' ? 'checked' : '' }} required>
                                        <span class="px-3 py-1 text-xs rounded-full bg-green-100 text-green-800">سهل</span>
                                    </label>
                                    <label class="flex items-center">
                                        <input type="radio" name="difficulty_level" value="medium"
                                               class="ml-2" {{ old('difficulty_level', $content->difficulty_level) == 'medium' ? 'checked' : '' }}>
                                        <span class="px-3 py-1 text-xs rounded-full bg-yellow-100 text-yellow-800">متوسط</span>
                                    </label>
                                    <label class="flex items-center">
                                        <input type="radio" name="difficulty_level" value="hard"
                                               class="ml-2" {{ old('difficulty_level', $content->difficulty_level) == 'hard' ? 'checked' : '' }}>
                                        <span class="px-3 py-1 text-xs rounded-full bg-red-100 text-red-800">صعب</span>
                                    </label>
                                </div>
                            </div>

                            <!-- Duration -->
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">
                                    المدة المقدرة (بالدقائق)
                                </label>
                                <input type="number" name="estimated_duration_minutes" value="{{ old('estimated_duration_minutes', $content->estimated_duration_minutes) }}"
                                       placeholder="60"
                                       class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                            </div>

                            <!-- Order -->
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">
                                    الترتيب
                                </label>
                                <input type="number" name="order" value="{{ old('order', $content->order) }}"
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
                                      class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 font-mono text-sm">{{ old('content_body_ar', $content->content_body_ar) }}</textarea>
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

                        <!-- Current Files Display -->
                        @if($content->has_file && $content->file_path)
                        <div class="mb-4 p-3 bg-green-50 rounded-lg border border-green-200">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center">
                                    <i class="fas fa-file-pdf text-red-600 mr-2"></i>
                                    <span class="text-sm font-medium">{{ basename($content->file_path) }}</span>
                                    @if($content->file_size)
                                    <span class="text-xs text-gray-500 mr-2">({{ number_format($content->file_size / 1024 / 1024, 2) }} MB)</span>
                                    @endif
                                </div>
                                <div class="flex items-center gap-2">
                                    <a href="{{ Storage::url($content->file_path) }}" target="_blank" class="text-blue-600 hover:text-blue-800 text-sm">
                                        <i class="fas fa-eye"></i> عرض
                                    </a>
                                    <a href="{{ Storage::url($content->file_path) }}" download class="text-green-600 hover:text-green-800 text-sm">
                                        <i class="fas fa-download"></i> تحميل
                                    </a>
                                </div>
                            </div>
                        </div>
                        @endif

                        <!-- PDF/DOC Upload -->
                        <div class="mb-6">
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                <i class="fas fa-file-pdf text-red-600 mr-1"></i>
                                ملف PDF أو Word {{ $content->has_file ? '(تحديث الملف الحالي)' : '' }}
                            </label>
                            <input type="file" name="file" accept=".pdf,.doc,.docx"
                                   class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                            <p class="text-xs text-gray-500 mt-1">الحجم الأقصى: 50 ميجابايت</p>
                        </div>

                        <!-- Video URL (YouTube) -->
                        <div class="mb-6">
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                <i class="fab fa-youtube text-red-600 mr-1"></i>
                                رابط فيديو YouTube
                            </label>
                            <input type="url" name="video_url" value="{{ old('video_url', $content->video_url) }}"
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
                            <input type="text" name="tags" value="{{ old('tags', is_array($content->tags) ? implode(', ', $content->tags) : '') }}"
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
                                      class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">{{ old('search_keywords', $content->search_keywords) }}</textarea>
                        </div>

                        <!-- Premium Content -->
                        <div class="mb-6">
                            <label class="flex items-center">
                                <input type="checkbox" name="is_premium" value="1"
                                       class="ml-2 w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
                                       {{ old('is_premium', $content->is_premium) ? 'checked' : '' }}>
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
                                   {{ old('is_published', $content->is_published) ? 'checked' : '' }}>
                            <span class="text-sm font-medium text-gray-700">منشور</span>
                        </label>
                        <p class="text-xs text-gray-500 mr-6 mt-1">
                            @if($content->is_published)
                                تم النشر بتاريخ: {{ $content->published_at?->format('Y-m-d H:i') }}
                            @else
                                إذا لم يتم التحديد، سيتم حفظه كمسودة
                            @endif
                        </p>
                    </div>

                    <div class="border-t border-gray-200 pt-4">
                        <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors mb-2">
                            <i class="fas fa-save mr-2"></i>
                            حفظ التغييرات
                        </button>
                        <a href="{{ route('admin.contents.index') }}" class="block w-full text-center bg-gray-200 hover:bg-gray-300 text-gray-700 px-4 py-2 rounded-lg transition-colors">
                            <i class="fas fa-times mr-2"></i>
                            إلغاء
                        </a>
                    </div>
                </div>

                <!-- Stats Card -->
                <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
                    <h3 class="text-lg font-semibold text-gray-800 mb-4">
                        <i class="fas fa-chart-bar mr-2 text-green-600"></i>
                        الإحصائيات
                    </h3>
                    <div class="space-y-3 text-sm">
                        <div class="flex justify-between">
                            <span class="text-gray-600">المشاهدات:</span>
                            <span class="font-semibold">{{ $content->views_count }}</span>
                        </div>
                        <div class="flex justify-between">
                            <span class="text-gray-600">التحميلات:</span>
                            <span class="font-semibold">{{ $content->downloads_count }}</span>
                        </div>
                        <div class="flex justify-between">
                            <span class="text-gray-600">التقييم:</span>
                            <span class="font-semibold">
                                @if($content->average_rating)
                                    {{ number_format($content->average_rating, 1) }} / 5
                                    <i class="fas fa-star text-yellow-500"></i>
                                @else
                                    لا يوجد
                                @endif
                            </span>
                        </div>
                        <div class="flex justify-between">
                            <span class="text-gray-600">التعليقات:</span>
                            <span class="font-semibold">{{ $content->total_ratings }}</span>
                        </div>
                    </div>
                </div>

                <!-- Help Card -->
                <div class="bg-blue-50 rounded-lg p-4 border border-blue-200">
                    <h4 class="font-semibold text-blue-900 mb-2">
                        <i class="fas fa-info-circle mr-1"></i>
                        آخر تحديث
                    </h4>
                    <p class="text-xs text-blue-800">
                        {{ $content->updated_at->diffForHumans() }}
                    </p>
                    @if($content->updater)
                    <p class="text-xs text-blue-800 mt-1">
                        بواسطة: {{ $content->updater->full_name }}
                    </p>
                    @endif
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

<style>
.tab-button.active {
    border-color: #2563eb;
    color: #2563eb;
}
</style>
@endsection
