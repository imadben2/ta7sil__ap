@extends('layouts.admin')

@section('title', 'إدارة الأسئلة')
@section('page-title', 'إدارة أسئلة الكويز')
@section('page-description', $quiz->title_ar)

@section('content')
<div class="space-y-6" x-data="questionManager()">
    <!-- Quiz Info Bar -->
    <div class="bg-white rounded-lg shadow-md p-4 flex items-center justify-between">
        <div>
            <h3 class="font-semibold text-gray-900">{{ $quiz->title_ar }}</h3>
            <p class="text-sm text-gray-600">
                <i class="fas fa-question-circle mr-1"></i>
                {{ $quiz->questions->count() }} سؤال
                <span class="mr-4">|</span>
                <i class="fas fa-star text-yellow-500 mr-1"></i>
                {{ $quiz->questions->sum('points') }} نقطة إجمالية
            </p>
        </div>
        <div class="flex gap-2">
            <button @click="showAddModal = true" class="px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors">
                <i class="fas fa-plus mr-2"></i>
                إضافة سؤال
            </button>
            <a href="{{ route('admin.quizzes.show', $quiz->id) }}" class="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors">
                <i class="fas fa-arrow-right mr-2"></i>
                العودة
            </a>
        </div>
    </div>

    <!-- Questions List -->
    <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">
            <i class="fas fa-list text-blue-600 mr-2"></i>
            قائمة الأسئلة
        </h3>

        @if($quiz->questions->count() > 0)
            <div id="questions-list" class="space-y-3">
                @foreach($quiz->questions as $index => $question)
                    <div class="border border-gray-200 rounded-lg p-4 hover:bg-gray-50 transition-colors" data-question-id="{{ $question->id }}">
                        <div class="flex items-start gap-4">
                            <!-- Drag Handle -->
                            <div class="cursor-move text-gray-400 hover:text-gray-600 pt-1">
                                <i class="fas fa-grip-vertical"></i>
                            </div>

                            <!-- Question Number -->
                            <span class="flex items-center justify-center w-8 h-8 bg-blue-100 text-blue-600 rounded-full text-sm font-bold flex-shrink-0">
                                {{ $index + 1 }}
                            </span>

                            <!-- Question Content -->
                            <div class="flex-1">
                                <h4 class="font-medium text-gray-900 mb-2">{{ $question->question_text_ar }}</h4>

                                <div class="flex flex-wrap gap-2 mb-2">
                                    <!-- Type Badge -->
                                    @if($question->question_type == 'mcq_single')
                                        <span class="px-2 py-1 text-xs font-semibold rounded bg-blue-100 text-blue-800">اختيار من متعدد</span>
                                    @elseif($question->question_type == 'mcq_multiple')
                                        <span class="px-2 py-1 text-xs font-semibold rounded bg-purple-100 text-purple-800">اختيار متعدد</span>
                                    @elseif($question->question_type == 'true_false')
                                        <span class="px-2 py-1 text-xs font-semibold rounded bg-green-100 text-green-800">صح/خطأ</span>
                                    @elseif($question->question_type == 'matching')
                                        <span class="px-2 py-1 text-xs font-semibold rounded bg-yellow-100 text-yellow-800">مطابقة</span>
                                    @elseif($question->question_type == 'sequence')
                                        <span class="px-2 py-1 text-xs font-semibold rounded bg-indigo-100 text-indigo-800">ترتيب</span>
                                    @elseif($question->question_type == 'fill_blank')
                                        <span class="px-2 py-1 text-xs font-semibold rounded bg-pink-100 text-pink-800">ملء الفراغات</span>
                                    @elseif($question->question_type == 'short_answer' || $question->question_type == 'long_answer')
                                        <span class="px-2 py-1 text-xs font-semibold rounded bg-teal-100 text-teal-800">إجابة قصيرة</span>
                                    @else
                                        <span class="px-2 py-1 text-xs font-semibold rounded bg-orange-100 text-orange-800">{{ $question->question_type }}</span>
                                    @endif

                                    <!-- Points -->
                                    <span class="px-2 py-1 text-xs font-semibold rounded bg-gray-100 text-gray-800">
                                        <i class="fas fa-star text-yellow-500 mr-1"></i>
                                        {{ $question->points }} نقطة
                                    </span>

                                    <!-- Difficulty -->
                                    @if($question->difficulty)
                                        @if($question->difficulty == 'easy')
                                            <span class="px-2 py-1 text-xs font-semibold rounded bg-green-100 text-green-800">سهل</span>
                                        @elseif($question->difficulty == 'medium')
                                            <span class="px-2 py-1 text-xs font-semibold rounded bg-yellow-100 text-yellow-800">متوسط</span>
                                        @else
                                            <span class="px-2 py-1 text-xs font-semibold rounded bg-red-100 text-red-800">صعب</span>
                                        @endif
                                    @endif
                                </div>

                                @if($question->explanation_ar)
                                    <p class="text-sm text-gray-600 mt-2">
                                        <i class="fas fa-info-circle text-blue-500 mr-1"></i>
                                        {{ Str::limit($question->explanation_ar, 100) }}
                                    </p>
                                @endif
                            </div>

                            <!-- Actions -->
                            <div class="flex gap-2 flex-shrink-0">
                                <button @click="editQuestion({{ $question->id }})" class="text-blue-600 hover:text-blue-800" title="تعديل">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <form method="POST" action="{{ route('admin.quizzes.deleteQuestion', [$quiz->id, $question->id]) }}"
                                      onsubmit="return confirm('هل أنت متأكد من حذف هذا السؤال؟')" class="inline">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="text-red-600 hover:text-red-800" title="حذف">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                @endforeach
            </div>
        @else
            <div class="text-center py-12">
                <i class="fas fa-question-circle text-6xl text-gray-300 mb-4"></i>
                <p class="text-gray-500 text-lg mb-4">لا توجد أسئلة في هذا الكويز</p>
                <button @click="showAddModal = true" class="px-6 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors">
                    <i class="fas fa-plus mr-2"></i>
                    إضافة سؤال جديد
                </button>
            </div>
        @endif
    </div>

    <!-- Add/Edit Question Modal -->
    <div x-show="showAddModal" x-cloak class="fixed inset-0 z-50 overflow-y-auto" style="display: none;">
        <div class="flex items-center justify-center min-h-screen px-4">
            <div @click="showAddModal = false" class="fixed inset-0 bg-black opacity-50"></div>

            <div class="relative bg-white rounded-lg shadow-xl max-w-4xl w-full max-h-[90vh] overflow-y-auto p-6">
                <div class="flex items-center justify-between mb-6">
                    <h3 class="text-xl font-bold text-gray-900">
                        <i class="fas fa-plus-circle text-purple-600 mr-2"></i>
                        <span x-text="editingQuestion ? 'تعديل السؤال' : 'إضافة سؤال جديد'"></span>
                    </h3>
                    <button @click="closeModal()" class="text-gray-400 hover:text-gray-600">
                        <i class="fas fa-times text-xl"></i>
                    </button>
                </div>

                <div id="modal-content">
                    @include('admin.quizzes.partials.question-form', ['quiz' => $quiz, 'question' => null])
                </div>
            </div>
        </div>
    </div>
</div>

@push('scripts')
<script src="https://cdn.jsdelivr.net/npm/sortablejs@1.15.0/Sortable.min.js"></script>
<script>
function questionManager() {
    return {
        showAddModal: false,
        editingQuestion: null,
        isLoading: false,

        init() {
            // Initialize drag and drop
            const el = document.getElementById('questions-list');
            if (el) {
                Sortable.create(el, {
                    animation: 150,
                    handle: '.cursor-move',
                    onEnd: () => {
                        this.saveOrder();
                    }
                });
            }
        },

        saveOrder() {
            const questions = Array.from(document.querySelectorAll('#questions-list > div'));
            const order = questions.map(q => q.dataset.questionId);

            fetch('{{ route('admin.quizzes.reorderQuestions', $quiz->id) }}', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': '{{ csrf_token() }}'
                },
                body: JSON.stringify({ order: order })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // Show success message
                    console.log('Order saved successfully');
                }
            })
            .catch(error => console.error('Error:', error));
        },

        async editQuestion(questionId) {
            this.isLoading = true;
            this.editingQuestion = questionId;

            try {
                // Fetch question data
                const response = await fetch(`/admin/quizzes/{{ $quiz->id }}/questions/${questionId}/edit`, {
                    headers: {
                        'Accept': 'application/json',
                        'X-CSRF-TOKEN': '{{ csrf_token() }}'
                    }
                });

                if (!response.ok) {
                    throw new Error('Failed to load question data');
                }

                const html = await response.text();

                // Update modal content
                const modalContent = document.getElementById('modal-content');

                // Destroy any existing Alpine components in the modal
                if (typeof Alpine !== 'undefined') {
                    const existingComponents = modalContent.querySelectorAll('[x-data]');
                    existingComponents.forEach(el => {
                        if (el._x_dataStack) {
                            Alpine.destroyTree(el);
                        }
                    });
                }

                // Clear and set new HTML
                modalContent.innerHTML = html;

                // Execute any scripts in the loaded content SYNCHRONOUSLY
                const scripts = modalContent.querySelectorAll('script');
                for (const script of scripts) {
                    const newScript = document.createElement('script');
                    newScript.textContent = script.textContent;
                    document.body.appendChild(newScript);
                    // Keep the script in DOM briefly to ensure execution
                    await new Promise(resolve => setTimeout(resolve, 10));
                }

                // Wait for DOM to settle
                await new Promise(resolve => setTimeout(resolve, 50));

                // Re-initialize Alpine.js for the new content
                if (typeof Alpine !== 'undefined') {
                    // Initialize the new tree
                    Alpine.initTree(modalContent);

                    // Additional wait for Alpine to fully process
                    await new Promise(resolve => setTimeout(resolve, 50));
                }

                // Show modal
                this.showAddModal = true;
            } catch (error) {
                console.error('Error loading question:', error);
                alert('حدث خطأ أثناء تحميل بيانات السؤال');
            } finally {
                this.isLoading = false;
            }
        },

        closeModal() {
            this.showAddModal = false;
            this.editingQuestion = null;
            // Reload form for adding new questions
            setTimeout(() => {
                if (!this.showAddModal) {
                    location.reload();
                }
            }, 300);
        }
    }
}
</script>
@endpush
@endsection
