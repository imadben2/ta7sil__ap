<div class="relative top-10 mx-auto p-0 border-0 w-full max-w-4xl">
    <div class="bg-white rounded-2xl shadow-2xl overflow-hidden">
        <!-- Modal Header -->
        <div class="bg-gradient-to-r from-blue-500 to-blue-600 px-6 py-4 flex items-center justify-between">
            <div class="flex items-center gap-3 text-white">
                <i class="fas fa-eye text-2xl"></i>
                <h3 class="text-xl font-bold">عرض تفاصيل الدرس</h3>
            </div>
            <button onclick="closeModal('viewLessonModal')" class="text-white hover:bg-white/20 rounded-lg p-2 transition-all">
                <i class="fas fa-times text-xl"></i>
            </button>
        </div>

        <!-- Modal Body -->
        <div class="p-6 space-y-4">
            <div class="grid grid-cols-2 gap-4">
                <div>
                    <p class="text-sm text-gray-500">عنوان الدرس</p>
                    <p class="font-semibold">{{ $lesson->title_ar }}</p>
                </div>
                <div>
                    <p class="text-sm text-gray-500">الترتيب</p>
                    <p class="font-semibold">#{{ $lesson->order }}</p>
                </div>
            </div>

            @if($lesson->description_ar)
            <div>
                <p class="text-sm text-gray-500">الوصف</p>
                <p class="text-gray-700">{{ $lesson->description_ar }}</p>
            </div>
            @endif

            <div class="grid grid-cols-2 gap-4">
                <div>
                    <p class="text-sm text-gray-500">نوع الفيديو</p>
                    <p class="font-semibold">
                        @if($lesson->video_type === 'youtube')
                            <i class="fab fa-youtube text-red-600 mr-1"></i> YouTube
                        @else
                            <i class="fas fa-upload text-blue-600 mr-1"></i> مرفوع
                        @endif
                    </p>
                </div>
                <div>
                    <p class="text-sm text-gray-500">مدة الفيديو</p>
                    <p class="font-semibold">{{ gmdate('H:i:s', $lesson->video_duration_seconds) }}</p>
                </div>
            </div>

            @if($lesson->video_type === 'youtube' && $lesson->video_url)
            <div>
                <p class="text-sm text-gray-500 mb-2">معاينة الفيديو</p>
                <div class="aspect-video bg-black rounded-lg overflow-hidden">
                    <iframe
                        width="100%"
                        height="100%"
                        src="https://www.youtube.com/embed/{{ $lesson->youtube_video_id }}"
                        frameborder="0"
                        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                        allowfullscreen>
                    </iframe>
                </div>
            </div>
            @elseif($lesson->video_type === 'upload' && $lesson->video_path)
            <div>
                <p class="text-sm text-gray-500">رابط الفيديو المرفوع</p>
                <a href="{{ Storage::url($lesson->video_path) }}" target="_blank" class="text-blue-600 hover:underline">
                    <i class="fas fa-external-link-alt mr-1"></i> مشاهدة الفيديو
                </a>
            </div>
            @endif

            @if($lesson->video_thumbnail_path)
            <div>
                <p class="text-sm text-gray-500 mb-2">الصورة المصغرة</p>
                <img src="{{ Storage::url($lesson->video_thumbnail_path) }}" alt="Thumbnail" class="rounded-lg max-h-48">
            </div>
            @endif

            @if($lesson->content_text_ar)
            <div>
                <p class="text-sm text-gray-500">المحتوى النصي</p>
                <div class="prose prose-sm max-w-none">
                    {!! nl2br(e($lesson->content_text_ar)) !!}
                </div>
            </div>
            @endif

            <div class="grid grid-cols-2 gap-4">
                <div>
                    <p class="text-sm text-gray-500">معاينة مجانية</p>
                    <p class="font-semibold">
                        @if($lesson->is_free_preview)
                            <span class="text-green-600"><i class="fas fa-check-circle mr-1"></i> نعم</span>
                        @else
                            <span class="text-gray-600"><i class="fas fa-times-circle mr-1"></i> لا</span>
                        @endif
                    </p>
                </div>
                <div>
                    <p class="text-sm text-gray-500">الحالة</p>
                    <p class="font-semibold">
                        @if($lesson->is_published)
                            <span class="text-green-600"><i class="fas fa-check-circle mr-1"></i> منشور</span>
                        @else
                            <span class="text-gray-600"><i class="fas fa-eye-slash mr-1"></i> مسودة</span>
                        @endif
                    </p>
                </div>
            </div>

            @if($lesson->attachments && $lesson->attachments->count() > 0)
            <div>
                <p class="text-sm text-gray-500 mb-2">المرفقات ({{ $lesson->attachments->count() }})</p>
                <div class="space-y-2">
                    @foreach($lesson->attachments as $attachment)
                    <div class="flex items-center justify-between p-2 bg-gray-50 rounded">
                        <div class="flex items-center gap-2">
                            <i class="fas fa-file text-gray-400"></i>
                            <span>{{ $attachment->original_filename }}</span>
                            <span class="text-xs text-gray-500">({{ number_format($attachment->file_size / 1024, 2) }} KB)</span>
                        </div>
                        <a href="{{ Storage::url($attachment->file_path) }}" target="_blank" class="text-blue-600 hover:text-blue-800">
                            <i class="fas fa-download"></i>
                        </a>
                    </div>
                    @endforeach
                </div>
            </div>
            @endif

            <div class="grid grid-cols-2 gap-4 pt-4 border-t">
                <div>
                    <p class="text-sm text-gray-500">تاريخ الإنشاء</p>
                    <p class="text-sm">{{ $lesson->created_at->format('Y-m-d H:i') }}</p>
                </div>
                <div>
                    <p class="text-sm text-gray-500">آخر تحديث</p>
                    <p class="text-sm">{{ $lesson->updated_at->format('Y-m-d H:i') }}</p>
                </div>
            </div>
        </div>

        <!-- Modal Footer -->
        <div class="bg-gray-50 px-6 py-4 flex justify-end gap-3">
            <button onclick="closeModal('viewLessonModal')" class="px-6 py-2 bg-gray-200 hover:bg-gray-300 text-gray-800 rounded-lg font-semibold transition-all">
                إغلاق
            </button>
            <button onclick="closeModal('viewLessonModal'); openEditLessonModal({{ $lesson->id }})" class="px-6 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg font-semibold transition-all">
                <i class="fas fa-edit ml-2"></i>
                تعديل
            </button>
        </div>
    </div>
</div>
