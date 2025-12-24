@extends('layouts.admin')

@section('title', 'اليوم ' . $day->day_number)
@section('page-title', 'اليوم ' . $day->day_number . ' - ' . ($day->title_ar ?? 'جدول المراجعة'))
@section('page-description', 'تفاصيل اليوم ' . $day->day_number . ' من جدول مراجعة البكالوريا')

@section('content')

    <!-- Breadcrumb -->
    <div class="mb-6">
        <a href="{{ route('admin.bac-study-schedule.days') }}" class="text-blue-500 hover:text-blue-700">
            <i class="fas fa-arrow-right ml-2"></i>العودة لقائمة الأيام
        </a>
    </div>

    <!-- Day Header -->
    <div class="bg-white rounded-lg shadow-md overflow-hidden mb-6">
        <div class="px-6 py-4 {{ $day->day_type === 'review' ? 'bg-gradient-to-r from-purple-500 to-purple-600' : ($day->day_type === 'reward' ? 'bg-gradient-to-r from-yellow-500 to-orange-500' : 'bg-gradient-to-r from-blue-500 to-blue-600') }}">
            <div class="flex items-center justify-between">
                <div>
                    <h1 class="text-2xl font-bold text-white">اليوم {{ $day->day_number }}</h1>
                    @if($day->title_ar)
                        <p class="text-white text-opacity-80 mt-1">{{ $day->title_ar }}</p>
                    @endif
                </div>
                <div class="text-left">
                    <span class="px-3 py-1 text-sm rounded-full bg-white bg-opacity-20 text-white">
                        الأسبوع {{ $day->week_number }}
                    </span>
                    <p class="text-white text-opacity-80 text-sm mt-2">
                        {{ $day->academicStream->name_ar ?? 'N/A' }}
                    </p>
                </div>
            </div>
        </div>
        <div class="px-6 py-4 flex items-center justify-between bg-gray-50">
            <div class="flex items-center gap-4">
                <span class="text-gray-600">
                    <i class="fas {{ $day->day_type === 'study' ? 'fa-book-open text-blue-500' : ($day->day_type === 'review' ? 'fa-redo text-purple-500' : 'fa-gift text-yellow-500') }} mr-2"></i>
                    {{ $day->day_type === 'study' ? 'يوم دراسة' : ($day->day_type === 'review' ? 'يوم مراجعة' : 'يوم مكافأة') }}
                </span>
                <span class="{{ $day->is_active ? 'text-green-500' : 'text-red-500' }}">
                    <i class="fas {{ $day->is_active ? 'fa-check-circle' : 'fa-times-circle' }} mr-1"></i>
                    {{ $day->is_active ? 'نشط' : 'معطل' }}
                </span>
            </div>
            <a href="{{ route('admin.bac-study-schedule.days.edit', $day->id) }}"
               class="bg-yellow-500 text-white px-4 py-2 rounded-lg hover:bg-yellow-600 transition-colors">
                <i class="fas fa-edit mr-2"></i>تعديل اليوم
            </a>
        </div>
    </div>

    <!-- Subjects and Topics -->
    <div class="space-y-6">
        @forelse($day->daySubjects as $daySubject)
            <div class="bg-white rounded-lg shadow-md overflow-hidden">
                <div class="px-6 py-4 bg-gray-100 border-b flex items-center justify-between">
                    <div>
                        <h2 class="text-lg font-semibold text-gray-800">{{ $daySubject->subject->name_ar ?? 'N/A' }}</h2>
                        <p class="text-sm text-gray-500">{{ $daySubject->topics->count() }} درس</p>
                    </div>
                    <form action="{{ route('admin.bac-study-schedule.days.subjects.destroy', [$day->id, $daySubject->id]) }}" method="POST" class="inline">
                        @csrf
                        @method('DELETE')
                        <button type="submit" onclick="return confirm('هل أنت متأكد من حذف هذه المادة؟')"
                                class="text-red-500 hover:text-red-700">
                            <i class="fas fa-trash"></i>
                        </button>
                    </form>
                </div>
                <div class="p-6">
                    @if($daySubject->topics->count() > 0)
                        <div class="space-y-3">
                            @foreach($daySubject->topics as $topic)
                                <div class="flex items-start justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                                    <div class="flex-1">
                                        <div class="flex items-center gap-2 mb-1">
                                            <span class="px-2 py-0.5 text-xs rounded
                                                @if($topic->task_type === 'study') bg-blue-100 text-blue-800
                                                @elseif($topic->task_type === 'memorize') bg-green-100 text-green-800
                                                @elseif($topic->task_type === 'solve') bg-purple-100 text-purple-800
                                                @elseif($topic->task_type === 'review') bg-yellow-100 text-yellow-800
                                                @else bg-gray-100 text-gray-800
                                                @endif">
                                                @if($topic->task_type === 'study') دراسة
                                                @elseif($topic->task_type === 'memorize') حفظ
                                                @elseif($topic->task_type === 'solve') حل
                                                @elseif($topic->task_type === 'review') مراجعة
                                                @else تمرين
                                                @endif
                                            </span>
                                        </div>
                                        <p class="text-gray-800 font-medium">{{ $topic->topic_ar }}</p>
                                        @if($topic->description_ar)
                                            <p class="text-gray-500 text-sm mt-1">{{ $topic->description_ar }}</p>
                                        @endif
                                    </div>
                                    <div class="flex items-center gap-2 mr-4">
                                        <button type="button" onclick="openEditTopicModal({{ json_encode($topic) }})"
                                                class="text-blue-500 hover:text-blue-700">
                                            <i class="fas fa-edit"></i>
                                        </button>
                                        <form action="{{ route('admin.bac-study-schedule.topics.destroy', $topic->id) }}" method="POST" class="inline">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" onclick="return confirm('هل أنت متأكد من حذف هذا الدرس؟')"
                                                    class="text-red-500 hover:text-red-700">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            @endforeach
                        </div>
                    @else
                        <p class="text-gray-500 text-center py-4">لا توجد دروس</p>
                    @endif

                    <!-- Add Topic Form -->
                    <div class="mt-4 pt-4 border-t">
                        <form action="{{ route('admin.bac-study-schedule.topics.store', $daySubject->id) }}" method="POST" class="flex flex-wrap gap-3">
                            @csrf
                            <input type="text" name="topic_ar" placeholder="عنوان الدرس"
                                   class="flex-1 min-w-[200px] border rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500" required>
                            <select name="task_type" class="border rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500" required>
                                <option value="study">دراسة</option>
                                <option value="memorize">حفظ</option>
                                <option value="solve">حل</option>
                                <option value="review">مراجعة</option>
                                <option value="exercise">تمرين</option>
                            </select>
                            <button type="submit" class="bg-green-500 text-white px-4 py-2 rounded-lg hover:bg-green-600 transition-colors">
                                <i class="fas fa-plus mr-2"></i>إضافة درس
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        @empty
            <div class="bg-white rounded-lg shadow-md p-8 text-center">
                <i class="fas fa-book text-gray-300 text-6xl mb-4"></i>
                <p class="text-gray-500 text-lg">لا توجد مواد في هذا اليوم</p>
            </div>
        @endforelse
    </div>

    <!-- Add Subject Form -->
    <div class="bg-white rounded-lg shadow-md p-6 mt-6">
        <h3 class="text-lg font-semibold text-gray-800 mb-4">إضافة مادة جديدة</h3>
        <form action="{{ route('admin.bac-study-schedule.days.subjects.store', $day->id) }}" method="POST" class="flex gap-3">
            @csrf
            <select name="subject_id" class="flex-1 border rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500" required>
                <option value="">اختر المادة</option>
                @foreach($subjects as $subject)
                    @if(!$day->daySubjects->pluck('subject_id')->contains($subject->id))
                        <option value="{{ $subject->id }}">{{ $subject->name_ar }}</option>
                    @endif
                @endforeach
            </select>
            <button type="submit" class="bg-blue-500 text-white px-6 py-2 rounded-lg hover:bg-blue-600 transition-colors">
                <i class="fas fa-plus mr-2"></i>إضافة مادة
            </button>
        </form>
    </div>

    <!-- Edit Topic Modal -->
    <div id="editTopicModal" class="fixed inset-0 bg-black bg-opacity-50 hidden items-center justify-center z-50">
        <div class="bg-white rounded-lg shadow-xl w-full max-w-md mx-4">
            <div class="px-6 py-4 border-b">
                <h3 class="text-lg font-semibold text-gray-800">تعديل الدرس</h3>
            </div>
            <form id="editTopicForm" method="POST">
                @csrf
                @method('PUT')
                <div class="p-6 space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">عنوان الدرس</label>
                        <input type="text" name="topic_ar" id="editTopicAr"
                               class="w-full border rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500" required>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">الوصف (اختياري)</label>
                        <textarea name="description_ar" id="editDescriptionAr" rows="3"
                                  class="w-full border rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500"></textarea>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">نوع المهمة</label>
                        <select name="task_type" id="editTaskType" class="w-full border rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500" required>
                            <option value="study">دراسة</option>
                            <option value="memorize">حفظ</option>
                            <option value="solve">حل</option>
                            <option value="review">مراجعة</option>
                            <option value="exercise">تمرين</option>
                        </select>
                    </div>
                </div>
                <div class="px-6 py-4 border-t bg-gray-50 flex justify-end gap-3">
                    <button type="button" onclick="closeEditTopicModal()"
                            class="px-4 py-2 text-gray-600 hover:text-gray-800">إلغاء</button>
                    <button type="submit" class="bg-blue-500 text-white px-4 py-2 rounded-lg hover:bg-blue-600">حفظ التعديلات</button>
                </div>
            </form>
        </div>
    </div>

@endsection

@push('scripts')
<script>
    function openEditTopicModal(topic) {
        document.getElementById('editTopicForm').action = '{{ url("admin/bac-study-schedule/topics") }}/' + topic.id;
        document.getElementById('editTopicAr').value = topic.topic_ar;
        document.getElementById('editDescriptionAr').value = topic.description_ar || '';
        document.getElementById('editTaskType').value = topic.task_type;
        document.getElementById('editTopicModal').classList.remove('hidden');
        document.getElementById('editTopicModal').classList.add('flex');
    }

    function closeEditTopicModal() {
        document.getElementById('editTopicModal').classList.add('hidden');
        document.getElementById('editTopicModal').classList.remove('flex');
    }

    // Close modal on outside click
    document.getElementById('editTopicModal').addEventListener('click', function(e) {
        if (e.target === this) {
            closeEditTopicModal();
        }
    });
</script>
@endpush
