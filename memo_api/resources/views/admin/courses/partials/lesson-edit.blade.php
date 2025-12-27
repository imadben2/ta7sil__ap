<div class="relative top-10 mx-auto p-0 border-0 w-full max-w-4xl">
    <div class="bg-white rounded-2xl shadow-2xl overflow-hidden">
        <!-- Modal Header -->
        <div class="bg-gradient-to-r from-green-500 to-green-600 px-6 py-4 flex items-center justify-between">
            <div class="flex items-center gap-3 text-white">
                <i class="fas fa-edit text-2xl"></i>
                <h3 class="text-xl font-bold">تعديل الدرس</h3>
            </div>
            <button type="button" onclick="closeModal('editLessonModal')" class="text-white hover:bg-white/20 rounded-lg p-2 transition-all">
                <i class="fas fa-times text-xl"></i>
            </button>
        </div>

        <!-- Modal Body -->
        <form action="{{ route('admin.courses.lessons.update', $lesson) }}" method="POST" enctype="multipart/form-data" id="editLessonForm{{ $lesson->id }}">
            @csrf
            @method('PUT')
            <div class="p-6 space-y-5 max-h-[70vh] overflow-y-auto">
                <!-- Basic Info -->
                <div class="bg-gradient-to-r from-blue-50 to-indigo-50 border-2 border-blue-200 rounded-xl p-4">
                    <div class="mb-4">
                        <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                            <i class="fas fa-heading text-blue-500"></i>
                            عنوان الدرس *
                        </label>
                        <input type="text" name="title_ar" value="{{ old('title_ar', $lesson->title_ar) }}" required
                               class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 transition-all">
                    </div>

                    <div class="mb-4">
                        <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                            <i class="fas fa-align-right text-blue-500"></i>
                            الوصف
                        </label>
                        <textarea name="description_ar" rows="3"
                                  class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 transition-all">{{ old('description_ar', $lesson->description_ar) }}</textarea>
                    </div>

                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                            <i class="fas fa-sort-numeric-down text-blue-500"></i>
                            الترتيب
                        </label>
                        <input type="number" name="order" value="{{ old('order', $lesson->order) }}" min="0"
                               class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 transition-all">
                    </div>
                </div>

                <!-- Content Type Selector -->
                <div class="bg-gradient-to-r from-indigo-50 to-purple-50 border-2 border-indigo-200 rounded-xl p-4">
                    <label class="block text-sm font-bold text-gray-700 mb-3 flex items-center gap-2">
                        <i class="fas fa-layer-group text-indigo-500"></i>
                        نوع المحتوى *
                    </label>
                    <div class="grid grid-cols-2 md:grid-cols-4 gap-3">
                        <label class="content-type-option-edit-{{ $lesson->id }}">
                            <input type="radio" name="content_type" value="video"
                                   {{ old('content_type', $lesson->content_type ?? 'video') === 'video' ? 'checked' : '' }}
                                   onclick="toggleContentFieldsEdit{{ $lesson->id }}('video')" class="hidden">
                            <div class="flex flex-col items-center gap-2 p-4 border-2 border-gray-300 rounded-xl cursor-pointer hover:border-purple-500 hover:bg-purple-50 transition-all">
                                <i class="fas fa-video text-2xl text-purple-600"></i>
                                <span class="text-sm font-bold">فيديو</span>
                            </div>
                        </label>

                        <label class="content-type-option-edit-{{ $lesson->id }}">
                            <input type="radio" name="content_type" value="document"
                                   {{ old('content_type', $lesson->content_type ?? 'video') === 'document' ? 'checked' : '' }}
                                   onclick="toggleContentFieldsEdit{{ $lesson->id }}('document')" class="hidden">
                            <div class="flex flex-col items-center gap-2 p-4 border-2 border-gray-300 rounded-xl cursor-pointer hover:border-blue-500 hover:bg-blue-50 transition-all">
                                <i class="fas fa-file-pdf text-2xl text-blue-600"></i>
                                <span class="text-sm font-bold">مستند</span>
                            </div>
                        </label>

                        <label class="content-type-option-edit-{{ $lesson->id }}">
                            <input type="radio" name="content_type" value="quiz"
                                   {{ old('content_type', $lesson->content_type ?? 'video') === 'quiz' ? 'checked' : '' }}
                                   onclick="toggleContentFieldsEdit{{ $lesson->id }}('quiz')" class="hidden">
                            <div class="flex flex-col items-center gap-2 p-4 border-2 border-gray-300 rounded-xl cursor-pointer hover:border-green-500 hover:bg-green-50 transition-all">
                                <i class="fas fa-question-circle text-2xl text-green-600"></i>
                                <span class="text-sm font-bold">كويز</span>
                            </div>
                        </label>

                        <label class="content-type-option-edit-{{ $lesson->id }}">
                            <input type="radio" name="content_type" value="text"
                                   {{ old('content_type', $lesson->content_type ?? 'video') === 'text' ? 'checked' : '' }}
                                   onclick="toggleContentFieldsEdit{{ $lesson->id }}('text')" class="hidden">
                            <div class="flex flex-col items-center gap-2 p-4 border-2 border-gray-300 rounded-xl cursor-pointer hover:border-orange-500 hover:bg-orange-50 transition-all">
                                <i class="fas fa-align-right text-2xl text-orange-600"></i>
                                <span class="text-sm font-bold">نص</span>
                            </div>
                        </label>
                    </div>
                </div>

                <!-- Video Content Fields -->
                <div id="edit_video_fields_{{ $lesson->id }}" class="content-fields-edit-{{ $lesson->id }} {{ old('content_type', $lesson->content_type ?? 'video') !== 'video' ? 'hidden' : '' }}">
                    <div class="bg-purple-50 border-2 border-purple-200 rounded-xl p-4 space-y-4">
                        @php
                            $allowedVideoType = $lesson->module->course->allowed_video_type ?? 'both';
                        @endphp
                        <div class="grid grid-cols-2 gap-4">
                            <div>
                                <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                                    <i class="fas fa-video text-purple-500"></i>
                                    نوع الفيديو *
                                </label>
                                <select name="video_type" id="edit_video_type_{{ $lesson->id }}"
                                        class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 transition-all"
                                        onchange="toggleVideoInputEdit({{ $lesson->id }})">
                                    @if($allowedVideoType === 'both' || $allowedVideoType === 'youtube')
                                        <option value="youtube" {{ old('video_type', $lesson->video_type) === 'youtube' ? 'selected' : '' }}>YouTube</option>
                                    @endif
                                    @if($allowedVideoType === 'both' || $allowedVideoType === 'upload')
                                        <option value="upload" {{ old('video_type', $lesson->video_type) === 'upload' ? 'selected' : '' }}>رفع ملف</option>
                                    @endif
                                </select>
                                @if($allowedVideoType !== 'both')
                                    <p class="text-xs text-purple-600 mt-1">
                                        <i class="fas fa-info-circle"></i>
                                        هذه الدورة تسمح بـ {{ $allowedVideoType === 'youtube' ? 'YouTube فقط' : 'رفع ملف فقط' }}
                                    </p>
                                @endif
                            </div>
                            <div>
                                <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                                    <i class="fas fa-clock text-purple-500"></i>
                                    مدة الفيديو (بالثواني) *
                                </label>
                                <input type="number" name="video_duration_seconds"
                                       value="{{ old('video_duration_seconds', $lesson->video_duration_seconds) }}"
                                       min="0" class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 transition-all">
                            </div>
                        </div>

                        <div id="edit_youtube_input_{{ $lesson->id }}" class="{{ old('video_type', $lesson->video_type) === 'upload' ? 'hidden' : '' }}">
                            <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                                <i class="fab fa-youtube text-red-500"></i>
                                رابط YouTube
                            </label>
                            <input type="text" name="video_url" value="{{ old('video_url', $lesson->video_url) }}"
                                   placeholder="https://www.youtube.com/watch?v=..."
                                   class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 transition-all">
                            @if($lesson->video_type === 'youtube' && $lesson->video_url)
                            <p class="text-xs text-gray-500 mt-1">الرابط الحالي: {{ $lesson->video_url }}</p>
                            @endif
                        </div>

                        <div id="edit_upload_input_{{ $lesson->id }}" class="{{ old('video_type', $lesson->video_type) === 'youtube' ? 'hidden' : '' }}">
                            <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                                <i class="fas fa-upload text-purple-500"></i>
                                رفع فيديو جديد
                            </label>
                            <input type="file" name="video" accept="video/mp4,video/mov,video/avi"
                                   class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 transition-all">
                            @if($lesson->video_type === 'upload' && ($lesson->video_path || $lesson->video_url))
                            <div class="mt-2 p-3 bg-green-50 rounded-lg border border-green-200">
                                <p class="text-xs text-gray-600 mb-1 flex items-center gap-1">
                                    <i class="fas fa-check-circle text-green-500"></i>
                                    الفيديو الحالي:
                                </p>
                                @php
                                    $videoSrc = $lesson->video_path ? Storage::url($lesson->video_path) : $lesson->video_url;
                                @endphp
                                <video controls class="w-full max-h-48 rounded-lg mt-2">
                                    <source src="{{ $videoSrc }}" type="video/mp4">
                                </video>
                                <p class="text-xs text-gray-500 mt-1 truncate" title="{{ $videoSrc }}">{{ basename($videoSrc) }}</p>
                            </div>
                            @endif
                        </div>

                        <div>
                            <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                                <i class="fas fa-image text-purple-500"></i>
                                صورة مصغرة
                            </label>
                            <input type="file" name="video_thumbnail" accept="image/*"
                                   class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 transition-all">
                            @if($lesson->video_thumbnail_url)
                            <div class="mt-2">
                                <p class="text-xs text-gray-500 mb-1">الصورة الحالية:</p>
                                <img src="{{ $lesson->video_thumbnail_url }}" alt="Current thumbnail" class="rounded-lg max-h-32 border-2 border-gray-200">
                            </div>
                            @endif
                        </div>
                    </div>
                </div>

                <!-- Document Content Fields -->
                <div id="edit_document_fields_{{ $lesson->id }}" class="content-fields-edit-{{ $lesson->id }} {{ old('content_type', $lesson->content_type ?? 'video') !== 'document' ? 'hidden' : '' }}">
                    <div class="bg-blue-50 border-2 border-blue-200 rounded-xl p-4">
                        <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                            <i class="fas fa-file-upload text-blue-500"></i>
                            رفع مستند جديد
                        </label>
                        <input type="file" name="document" accept=".pdf,.doc,.docx,.ppt,.pptx,.xls,.xlsx"
                               class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 transition-all">
                        <p class="text-xs text-gray-500 mt-2">صيغ مدعومة: PDF, DOC, DOCX, PPT, PPTX, XLS, XLSX (الحد الأقصى: 20 ميجابايت)</p>
                        @if($lesson->document_path)
                        <div class="mt-3 p-3 bg-blue-100 rounded-lg">
                            <p class="text-xs text-gray-600 mb-1">المستند الحالي:</p>
                            <a href="{{ Storage::url($lesson->document_path) }}" target="_blank" class="text-blue-600 hover:underline font-semibold">
                                <i class="fas fa-file-pdf mr-1"></i> عرض المستند
                            </a>
                        </div>
                        @endif
                    </div>
                </div>

                <!-- Quiz Content Fields -->
                <div id="edit_quiz_fields_{{ $lesson->id }}" class="content-fields-edit-{{ $lesson->id }} {{ old('content_type', $lesson->content_type ?? 'video') !== 'quiz' ? 'hidden' : '' }}">
                    <div class="bg-green-50 border-2 border-green-200 rounded-xl p-4">
                        <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                            <i class="fas fa-list text-green-500"></i>
                            اختر الكويز *
                        </label>
                        <select name="quiz_id" class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-green-500 transition-all">
                            <option value="">-- اختر كويز --</option>
                            @foreach(\App\Models\Quiz::where('is_published', true)->orderBy('title_ar')->get() as $quiz)
                                <option value="{{ $quiz->id }}" {{ old('quiz_id', $lesson->quiz_id) == $quiz->id ? 'selected' : '' }}>
                                    {{ $quiz->title_ar }}
                                </option>
                            @endforeach
                        </select>
                        <a href="{{ route('admin.quizzes.index') }}" target="_blank" class="inline-block mt-2 text-sm text-green-600 hover:text-green-700">
                            <i class="fas fa-external-link-alt"></i>
                            إدارة الكويزات
                        </a>
                    </div>
                </div>

                <!-- Text Content Fields -->
                <div id="edit_text_fields_{{ $lesson->id }}" class="content-fields-edit-{{ $lesson->id }} {{ old('content_type', $lesson->content_type ?? 'video') !== 'text' ? 'hidden' : '' }}">
                    <div class="bg-orange-50 border-2 border-orange-200 rounded-xl p-4">
                        <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                            <i class="fas fa-paragraph text-orange-500"></i>
                            محتوى النص *
                        </label>
                        <textarea name="content_text_ar" rows="8"
                                  class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-orange-500 transition-all"
                                  placeholder="اكتب محتوى الدرس النصي هنا...">{{ old('content_text_ar', $lesson->content_text_ar) }}</textarea>
                    </div>
                </div>

                <!-- Attachments Section -->
                @if($lesson->attachments && $lesson->attachments->count() > 0)
                <div class="bg-gray-50 border-2 border-gray-200 rounded-xl p-4">
                    <p class="text-sm font-bold text-gray-700 mb-3 flex items-center gap-2">
                        <i class="fas fa-paperclip text-gray-500"></i>
                        المرفقات الحالية
                    </p>
                    <div class="space-y-2">
                        @foreach($lesson->attachments as $attachment)
                        <div class="flex items-center justify-between p-3 bg-white rounded-lg border border-gray-200">
                            <div class="flex items-center gap-2">
                                <i class="fas fa-file text-blue-500"></i>
                                <span class="text-sm font-semibold">{{ $attachment->original_filename }}</span>
                            </div>
                            <button type="button" onclick="deleteAttachment({{ $attachment->id }})"
                                    class="text-red-600 hover:text-red-800 text-sm px-3 py-1 hover:bg-red-50 rounded transition-all">
                                <i class="fas fa-trash"></i> حذف
                            </button>
                        </div>
                        @endforeach
                    </div>
                </div>
                @endif

                <!-- New Attachment -->
                <div class="bg-gray-50 border-2 border-gray-200 rounded-xl p-4">
                    <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                        <i class="fas fa-plus-circle text-gray-500"></i>
                        إضافة مرفق جديد
                    </label>
                    <input type="file" name="new_attachment"
                           class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 transition-all">
                    <p class="text-xs text-gray-500 mt-2">الحد الأقصى: 10 ميجابايت</p>
                </div>

                <!-- Common Options -->
                <div class="flex items-center gap-4 bg-gradient-to-r from-blue-50 to-purple-50 border-2 border-blue-200 rounded-xl p-4">
                    <div class="flex items-center">
                        <input type="checkbox" name="is_free_preview" value="1" id="edit_is_free_{{ $lesson->id }}"
                               {{ old('is_free_preview', $lesson->is_free_preview) ? 'checked' : '' }}
                               class="w-5 h-5 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
                        <label for="edit_is_free_{{ $lesson->id }}" class="mr-3 text-sm font-bold text-gray-700 flex items-center gap-2 cursor-pointer">
                            <i class="fas fa-eye text-blue-500"></i>
                            معاينة مجانية
                        </label>
                    </div>
                    <div class="flex items-center">
                        <input type="checkbox" name="is_published" value="1" id="edit_lesson_published_{{ $lesson->id }}"
                               {{ old('is_published', $lesson->is_published ?? true) ? 'checked' : '' }}
                               class="w-5 h-5 text-green-600 border-gray-300 rounded focus:ring-green-500">
                        <label for="edit_lesson_published_{{ $lesson->id }}" class="mr-3 text-sm font-bold text-gray-700 flex items-center gap-2 cursor-pointer">
                            <i class="fas fa-globe text-green-500"></i>
                            منشور
                        </label>
                    </div>
                </div>
            </div>

            <!-- Modal Footer -->
            <div class="bg-gray-50 px-6 py-4 flex justify-end gap-3 border-t border-gray-200">
                <button type="button" onclick="closeModal('editLessonModal')"
                        class="px-6 py-3 border-2 border-gray-300 rounded-xl text-gray-700 hover:bg-gray-50 font-bold transition-all">
                    <i class="fas fa-times ml-2"></i>
                    إلغاء
                </button>
                <button type="submit"
                        class="px-6 py-3 bg-gradient-to-r from-green-600 to-green-700 hover:from-green-700 hover:to-green-800 text-white rounded-xl font-bold shadow-lg transition-all">
                    <i class="fas fa-save ml-2"></i>
                    حفظ التعديلات
                </button>
            </div>
        </form>
    </div>
</div>

<script>
function toggleVideoInputEdit(lessonId) {
    const videoType = document.getElementById('edit_video_type_' + lessonId).value;
    const youtubeInput = document.getElementById('edit_youtube_input_' + lessonId);
    const uploadInput = document.getElementById('edit_upload_input_' + lessonId);

    if (videoType === 'youtube') {
        youtubeInput.classList.remove('hidden');
        uploadInput.classList.add('hidden');
    } else {
        youtubeInput.classList.add('hidden');
        uploadInput.classList.remove('hidden');
    }
}

function toggleContentFieldsEdit{{ $lesson->id }}(contentType) {
    // Hide all content field divs
    document.querySelectorAll('.content-fields-edit-{{ $lesson->id }}').forEach(el => el.classList.add('hidden'));

    // Show the selected content type fields
    const selectedFields = document.getElementById('edit_' + contentType + '_fields_{{ $lesson->id }}');
    if (selectedFields) {
        selectedFields.classList.remove('hidden');
    }

    // Update radio button styling to highlight selection
    document.querySelectorAll('.content-type-option-edit-{{ $lesson->id }}').forEach(label => {
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

// Initialize on load
document.addEventListener('DOMContentLoaded', function() {
    const currentType = document.querySelector('.content-type-option-edit-{{ $lesson->id }} input:checked');
    if (currentType) {
        toggleContentFieldsEdit{{ $lesson->id }}(currentType.value);
    }
});

function deleteAttachment(attachmentId) {
    if (confirm('هل أنت متأكد من حذف هذا المرفق؟')) {
        fetch(`/admin/courses/lessons/attachments/${attachmentId}`, {
            method: 'DELETE',
            headers: {
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content,
                'Accept': 'application/json',
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                location.reload();
            } else {
                alert('حدث خطأ أثناء حذف المرفق');
            }
        })
        .catch(error => {
            alert('حدث خطأ أثناء حذف المرفق');
        });
    }
}
</script>

<style>
/* Content Type Radio Button Styles for Edit Modal */
.content-type-option-edit-{{ $lesson->id }} input[type="radio"]:checked + div {
    border-width: 4px !important;
    background-color: rgb(243 232 255) !important;
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
    transform: scale(1.05);
}

.content-type-option-edit-{{ $lesson->id }} div {
    transition: all 0.3s ease-in-out;
}

.content-type-option-edit-{{ $lesson->id }}:hover div {
    transform: translateY(-2px);
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

/* Content Fields Transition for Edit Modal */
.content-fields-edit-{{ $lesson->id }} {
    transition: opacity 0.3s ease-in-out, max-height 0.3s ease-in-out;
}

.content-fields-edit-{{ $lesson->id }}.hidden {
    opacity: 0;
    max-height: 0;
    overflow: hidden;
}

.content-fields-edit-{{ $lesson->id }}:not(.hidden) {
    opacity: 1;
    max-height: 1000px;
}
</style>
