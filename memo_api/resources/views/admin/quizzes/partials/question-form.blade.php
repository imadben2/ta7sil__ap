{{-- Question Form Partial - Handles all 8 question types --}}
@php
    // Map database types to form types
    $dbToFormType = [
        'mcq_single' => 'single_choice',
        'mcq_multiple' => 'multiple_choice',
        'true_false' => 'true_false',
        'matching' => 'matching',
        'sequence' => 'ordering',
        'fill_blank' => 'fill_blank',
        'short_answer' => 'short_answer',
    ];

    $formType = $question ? ($dbToFormType[$question->question_type] ?? 'single_choice') : 'single_choice';

    // Extract options - handle all possible formats
    $existingOptions = [];
    if ($question && $question->options && is_array($question->options)) {
        foreach ($question->options as $opt) {
            if (is_array($opt)) {
                $existingOptions[] = ['text' => $opt['text'] ?? ''];
            } elseif (is_string($opt)) {
                $existingOptions[] = ['text' => $opt];
            }
        }
    }

    // Get correct answer for single choice
    $correctAnswerIndex = null;
    $correctAnswerIndexes = [];
    if ($question && $question->correct_answer) {
        $ca = $question->correct_answer;
        if (isset($ca['answer']) && is_numeric($ca['answer'])) {
            $correctAnswerIndex = (int)$ca['answer'];
        }
        if (isset($ca['answers']) && is_array($ca['answers'])) {
            $correctAnswerIndexes = array_map('intval', $ca['answers']);
        }
    }

    // True/False - MUST convert to string for radio buttons
    $trueFalseValue = '';
    if ($question && $question->question_type === 'true_false') {
        $answer = $question->correct_answer['answer'] ?? null;
        if ($answer === true || $answer === 'true' || $answer === 1 || $answer === '1') {
            $trueFalseValue = 'true';
        } elseif ($answer === false || $answer === 'false' || $answer === 0 || $answer === '0') {
            $trueFalseValue = 'false';
        }
    }

    // Fill blank
    $fillBlankAnswer = '';
    if ($question && $question->question_type === 'fill_blank') {
        $fillBlankAnswer = $question->correct_answer['answer'] ?? '';
    }

    // Short answer
    $modelAnswer = '';
    $keywords = '';
    if ($question && $question->question_type === 'short_answer') {
        $modelAnswer = $question->correct_answer['model_answer'] ?? '';
        $keywords = $question->correct_answer['keywords'] ?? '';
    }

    // Matching
    $matchingLeft = [];
    $matchingRight = [];
    $matchingPairs = '';
    if ($question && $question->question_type === 'matching' && $question->options) {
        $matchingLeft = $question->options['left'] ?? ['', ''];
        $matchingRight = $question->options['right'] ?? ['', ''];
        $matchingPairs = $question->correct_answer['pairs'] ?? '';
    }

    // Ordering - handle various formats
    $orderingItems = [];
    if ($question && $question->question_type === 'sequence' && $question->options) {
        foreach ($question->options as $item) {
            if (is_array($item)) {
                $orderingItems[] = $item['text'] ?? '';
            } elseif (is_string($item)) {
                $orderingItems[] = $item;
            }
        }
    }

    // Numeric
    $numericAnswer = '';
    $numericTolerance = '';
    if ($question && isset($question->correct_answer['answer']) && is_numeric($question->correct_answer['answer'])) {
        $numericAnswer = $question->correct_answer['answer'];
        $numericTolerance = $question->correct_answer['tolerance'] ?? '';
    }

    // Build Alpine data - ensure all values are properly typed
    $alpineData = [
        'type' => $formType,
        'options' => !empty($existingOptions) ? $existingOptions : [['text' => ''], ['text' => ''], ['text' => ''], ['text' => '']],
        'correctAnswer' => $correctAnswerIndex,
        'correctAnswers' => $correctAnswerIndexes,
        'trueFalseValue' => $trueFalseValue,
        'fillBlankAnswer' => $fillBlankAnswer,
        'modelAnswer' => $modelAnswer,
        'keywords' => $keywords,
        'matchingLeft' => !empty($matchingLeft) ? $matchingLeft : ['', ''],
        'matchingRight' => !empty($matchingRight) ? $matchingRight : ['', ''],
        'matchingPairs' => $matchingPairs,
        'orderingItems' => !empty($orderingItems) ? $orderingItems : ['', '', ''],
        'numericAnswer' => $numericAnswer,
        'numericTolerance' => $numericTolerance,
    ];
@endphp

<form method="POST"
      action="{{ $question ? route('admin.quizzes.updateQuestion', [$quiz->id, $question->id]) : route('admin.quizzes.storeQuestion', $quiz->id) }}"
      class="space-y-6"
      x-data="questionFormData()"
      x-init="initForm(@js($alpineData))"
      @submit.prevent="submitForm($event)">

    @csrf
    @if($question)
        @method('PUT')
    @endif

    <!-- Question Type Selection -->
    <div>
        <label class="block text-sm font-medium text-gray-700 mb-2">
            نوع السؤال <span class="text-red-500">*</span>
        </label>
        <select name="question_type"
                x-model="questionType"
                required
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500">
            <option value="single_choice">اختيار من متعدد (Single Choice)</option>
            <option value="multiple_choice">اختيار متعدد (Multiple Choice)</option>
            <option value="true_false">صح أو خطأ (True/False)</option>
            <option value="matching">مطابقة (Matching)</option>
            <option value="ordering">ترتيب (Ordering)</option>
            <option value="fill_blank">ملء الفراغات (Fill in the Blank)</option>
            <option value="short_answer">إجابة قصيرة (Short Answer)</option>
            <option value="numeric">إجابة رقمية (Numeric)</option>
        </select>
    </div>

    <!-- Question Text -->
    <div>
        <label class="block text-sm font-medium text-gray-700 mb-2">
            نص السؤال <span class="text-red-500">*</span>
        </label>
        <textarea name="question_text_ar"
                  rows="3"
                  required
                  class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                  placeholder="اكتب نص السؤال هنا...">{{ old('question_text_ar', $question->question_text_ar ?? '') }}</textarea>
    </div>

    <!-- Question Image (Optional) -->
    <div>
        <label class="block text-sm font-medium text-gray-700 mb-2">
            رابط الصورة (اختياري)
        </label>
        <input type="url"
               name="question_image_url"
               value="{{ old('question_image_url', $question->question_image_url ?? '') }}"
               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
               placeholder="https://example.com/image.jpg">
    </div>

    <!-- Dynamic Options Based on Question Type -->

    {{-- Single Choice / Multiple Choice --}}
    <div x-show="questionType === 'single_choice' || questionType === 'multiple_choice'" x-cloak>
        <label class="block text-sm font-medium text-gray-700 mb-2">
            الخيارات <span class="text-red-500">*</span>
            <span class="text-xs text-gray-500">(حدد الإجابة الصحيحة بالنقر على المربع)</span>
        </label>
        <div id="options-container" class="space-y-2">
            <template x-for="(option, index) in options" :key="index">
                <div class="flex gap-2 items-center">
                    <input type="checkbox"
                           :name="questionType === 'multiple_choice' ? 'correct_answer[answers][]' : 'correct_answer[answer]'"
                           :value="index"
                           :checked="isCorrectAnswer(index)"
                           @change="handleCorrectAnswerChange($event, index)"
                           class="w-5 h-5 text-purple-600 border-gray-300 rounded focus:ring-purple-500 correct-answer-checkbox"
                           title="حدد كإجابة صحيحة">
                    <input type="text"
                           :name="'options[' + index + '][text]'"
                           x-model="option.text"
                           class="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                           placeholder="نص الخيار">
                    <button type="button"
                            @click="removeOption(index)"
                            x-show="options.length > 2"
                            class="px-3 py-2 text-red-600 hover:text-red-800">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            </template>
        </div>
        <button type="button"
                @click="addOption()"
                class="mt-2 px-4 py-2 text-sm text-purple-600 hover:text-purple-800">
            <i class="fas fa-plus mr-1"></i>
            إضافة خيار
        </button>
    </div>

    {{-- True/False --}}
    <div x-show="questionType === 'true_false'" x-cloak>
        <label class="block text-sm font-medium text-gray-700 mb-2">
            الإجابة الصحيحة <span class="text-red-500">*</span>
        </label>
        <div class="flex gap-4">
            <label class="flex items-center">
                <input type="radio" value="true"
                       x-model="trueFalseValue"
                       class="w-5 h-5 text-purple-600 border-gray-300 focus:ring-purple-500 true-false-radio">
                <span class="mr-2 text-gray-700">صحيح</span>
            </label>
            <label class="flex items-center">
                <input type="radio" value="false"
                       x-model="trueFalseValue"
                       class="w-5 h-5 text-purple-600 border-gray-300 focus:ring-purple-500 true-false-radio">
                <span class="mr-2 text-gray-700">خطأ</span>
            </label>
        </div>
    </div>

    {{-- Matching --}}
    <div x-show="questionType === 'matching'" x-cloak>
        <div class="grid grid-cols-2 gap-4">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">
                    العمود الأيسر <span class="text-red-500">*</span>
                </label>
                <div class="space-y-2">
                    <template x-for="(item, index) in matchingLeft" :key="'left-'+index">
                        <div class="flex gap-2">
                            <input type="text"
                                   :name="'options[left][' + index + ']'"
                                   x-model="matchingLeft[index]"
                                   class="flex-1 px-4 py-2 border border-gray-300 rounded-lg"
                                   placeholder="عنصر">
                            <button type="button"
                                    @click="removeMatchingItem('left', index)"
                                    x-show="matchingLeft.length > 2"
                                    class="px-3 py-2 text-red-600 hover:text-red-800">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                    </template>
                </div>
                <button type="button" @click="addMatchingItem('left')" class="mt-2 text-sm text-purple-600">
                    <i class="fas fa-plus mr-1"></i> إضافة
                </button>
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">
                    العمود الأيمن <span class="text-red-500">*</span>
                </label>
                <div class="space-y-2">
                    <template x-for="(item, index) in matchingRight" :key="'right-'+index">
                        <div class="flex gap-2">
                            <input type="text"
                                   :name="'options[right][' + index + ']'"
                                   x-model="matchingRight[index]"
                                   class="flex-1 px-4 py-2 border border-gray-300 rounded-lg"
                                   placeholder="مطابقة">
                            <button type="button"
                                    @click="removeMatchingItem('right', index)"
                                    x-show="matchingRight.length > 2"
                                    class="px-3 py-2 text-red-600 hover:text-red-800">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                    </template>
                </div>
                <button type="button" @click="addMatchingItem('right')" class="mt-2 text-sm text-purple-600">
                    <i class="fas fa-plus mr-1"></i> إضافة
                </button>
            </div>
        </div>
        <div class="mt-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">
                المطابقة الصحيحة (رقم الأيسر : رقم الأيمن) <span class="text-red-500">*</span>
            </label>
            <input type="text"
                   name="correct_answer[pairs]"
                   x-model="matchingPairs"
                   class="w-full px-4 py-2 border border-gray-300 rounded-lg"
                   placeholder="مثال: 0:0,1:1,2:2">
        </div>
    </div>

    {{-- Ordering --}}
    <div x-show="questionType === 'ordering'" x-cloak>
        <label class="block text-sm font-medium text-gray-700 mb-2">
            العناصر المطلوب ترتيبها <span class="text-red-500">*</span>
        </label>
        <div class="space-y-2">
            <template x-for="(item, index) in orderingItems" :key="'order-'+index">
                <div class="flex gap-2 items-center">
                    <span class="text-sm text-gray-600 w-8" x-text="(index + 1) + '.'"></span>
                    <input type="text"
                           :name="'options[' + index + ']'"
                           x-model="orderingItems[index]"
                           class="flex-1 px-4 py-2 border border-gray-300 rounded-lg"
                           placeholder="عنصر">
                    <button type="button"
                            @click="removeOrderingItem(index)"
                            x-show="orderingItems.length > 2"
                            class="px-3 py-2 text-red-600 hover:text-red-800">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            </template>
        </div>
        <button type="button" @click="addOrderingItem()" class="mt-2 text-sm text-purple-600">
            <i class="fas fa-plus mr-1"></i> إضافة عنصر
        </button>
        <input type="hidden" name="correct_answer[order]" :value="JSON.stringify(orderingItems.map((_, i) => i))">
    </div>

    {{-- Fill in the Blank --}}
    <div x-show="questionType === 'fill_blank'" x-cloak>
        <label class="block text-sm font-medium text-gray-700 mb-2">
            الإجابة الصحيحة <span class="text-red-500">*</span>
        </label>
        <input type="text"
               name="correct_answer[answer]"
               x-model="fillBlankAnswer"
               class="w-full px-4 py-2 border border-gray-300 rounded-lg"
               placeholder="الكلمة أو العبارة الصحيحة">
        <p class="mt-1 text-xs text-gray-500">ملاحظة: ضع خط سفلي _____ في نص السؤال لتحديد مكان الفراغ</p>
    </div>

    {{-- Short Answer --}}
    <div x-show="questionType === 'short_answer'" x-cloak>
        <div class="space-y-4">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">
                    الإجابة النموذجية <span class="text-red-500">*</span>
                </label>
                <textarea name="correct_answer[model_answer]"
                          rows="3"
                          x-model="modelAnswer"
                          class="w-full px-4 py-2 border border-gray-300 rounded-lg"
                          placeholder="اكتب الإجابة النموذجية..."></textarea>
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">
                    الكلمات المفتاحية (اختياري)
                </label>
                <input type="text"
                       name="correct_answer[keywords]"
                       x-model="keywords"
                       class="w-full px-4 py-2 border border-gray-300 rounded-lg"
                       placeholder="مثال: الجاذبية, نيوتن, قانون">
                <p class="mt-1 text-xs text-gray-500">افصل بينها بفاصلة</p>
            </div>
        </div>
    </div>

    {{-- Numeric Answer --}}
    <div x-show="questionType === 'numeric'" x-cloak>
        <div class="grid grid-cols-2 gap-4">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">
                    الإجابة الرقمية <span class="text-red-500">*</span>
                </label>
                <input type="number"
                       step="any"
                       name="correct_answer[answer]"
                       x-model="numericAnswer"
                       class="w-full px-4 py-2 border border-gray-300 rounded-lg"
                       placeholder="123.45">
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">
                    هامش الخطأ المسموح (اختياري)
                </label>
                <input type="number"
                       step="any"
                       name="correct_answer[tolerance]"
                       x-model="numericTolerance"
                       class="w-full px-4 py-2 border border-gray-300 rounded-lg"
                       placeholder="0.01">
            </div>
        </div>
    </div>

    <!-- Common Fields -->
    <div class="grid grid-cols-2 gap-4">
        <!-- Points -->
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
                النقاط <span class="text-red-500">*</span>
            </label>
            <input type="number"
                   name="points"
                   value="{{ old('points', $question->points ?? 1) }}"
                   min="1"
                   required
                   class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500">
        </div>

        <!-- Difficulty -->
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
                مستوى الصعوبة
            </label>
            <select name="difficulty" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500">
                <option value="">غير محدد</option>
                <option value="easy" {{ ($question->difficulty ?? '') === 'easy' ? 'selected' : '' }}>سهل</option>
                <option value="medium" {{ ($question->difficulty ?? '') === 'medium' ? 'selected' : '' }}>متوسط</option>
                <option value="hard" {{ ($question->difficulty ?? '') === 'hard' ? 'selected' : '' }}>صعب</option>
            </select>
        </div>
    </div>

    <!-- Explanation -->
    <div>
        <label class="block text-sm font-medium text-gray-700 mb-2">
            التوضيح (يظهر بعد الإجابة)
        </label>
        <textarea name="explanation_ar"
                  rows="2"
                  class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                  placeholder="اكتب توضيحاً للإجابة...">{{ old('explanation_ar', $question->explanation_ar ?? '') }}</textarea>
    </div>

    <!-- Tags -->
    <div>
        <label class="block text-sm font-medium text-gray-700 mb-2">
            الوسوم (Tags)
        </label>
        <input type="text"
               name="tags"
               value="{{ old('tags', is_array($question->tags ?? null) ? implode(', ', $question->tags) : '') }}"
               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
               placeholder="مثال: الجبر, المعادلات, الرياضيات">
        <p class="mt-1 text-xs text-gray-500">افصل بينها بفاصلة</p>
    </div>

    <!-- Actions -->
    <div class="flex gap-3 pt-4 border-t border-gray-200">
        <button type="submit" class="px-6 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors">
            <i class="fas fa-save mr-2"></i>
            {{ $question ? 'تحديث السؤال' : 'حفظ السؤال' }}
        </button>
        <button type="button" @click="showAddModal = false" class="px-6 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors">
            <i class="fas fa-times mr-2"></i>
            إلغاء
        </button>
    </div>
</form>

<script>
// Define the Alpine component function
function questionFormData() {
    return {
        questionType: 'single_choice',
        options: [{text: ''}, {text: ''}, {text: ''}, {text: ''}],
        correctAnswer: null,
        correctAnswers: [],
        matchingLeft: ['', ''],
        matchingRight: ['', ''],
        orderingItems: ['', '', ''],
        trueFalseValue: '',
        fillBlankAnswer: '',
        modelAnswer: '',
        keywords: '',
        numericAnswer: '',
        numericTolerance: '',
        matchingPairs: '',

        initForm(data) {
            console.log('initForm called with:', data);

            if (!data) return;

            // Set question type
            this.questionType = data.type || 'single_choice';

            // Set options - deep copy to ensure reactivity
            if (Array.isArray(data.options) && data.options.length > 0) {
                this.options = data.options.map(opt => ({text: opt.text || ''}));
            }

            // Set correct answer for single choice
            this.correctAnswer = data.correctAnswer;

            // Set correct answers for multiple choice
            if (Array.isArray(data.correctAnswers)) {
                this.correctAnswers = [...data.correctAnswers];
            }

            // True/False - ensure it's a string
            this.trueFalseValue = String(data.trueFalseValue || '');

            // Fill blank
            this.fillBlankAnswer = String(data.fillBlankAnswer || '');

            // Short answer
            this.modelAnswer = String(data.modelAnswer || '');
            this.keywords = String(data.keywords || '');

            // Matching - deep copy arrays
            if (Array.isArray(data.matchingLeft)) {
                this.matchingLeft = [...data.matchingLeft];
            }
            if (Array.isArray(data.matchingRight)) {
                this.matchingRight = [...data.matchingRight];
            }
            this.matchingPairs = String(data.matchingPairs || '');

            // Ordering - handle array of strings
            if (Array.isArray(data.orderingItems) && data.orderingItems.length > 0) {
                this.orderingItems = data.orderingItems.map(item => String(item || ''));
            }

            // Numeric
            this.numericAnswer = String(data.numericAnswer || '');
            this.numericTolerance = String(data.numericTolerance || '');

            console.log('After init - questionType:', this.questionType);
            console.log('After init - options:', this.options);
            console.log('After init - correctAnswer:', this.correctAnswer);
            console.log('After init - correctAnswers:', this.correctAnswers);
            console.log('After init - trueFalseValue:', this.trueFalseValue, 'type:', typeof this.trueFalseValue);
        },

        isCorrectAnswer(index) {
            if (this.questionType === 'multiple_choice') {
                return Array.isArray(this.correctAnswers) && this.correctAnswers.includes(index);
            }
            return this.correctAnswer === index;
        },

        handleCorrectAnswerChange(event, index) {
            if (this.questionType === 'single_choice') {
                // For single choice, only one can be selected
                if (event.target.checked) {
                    this.correctAnswer = index;
                    // Uncheck all other checkboxes
                    this.$el.querySelectorAll('.correct-answer-checkbox').forEach((cb, i) => {
                        if (i !== index) cb.checked = false;
                    });
                } else {
                    this.correctAnswer = null;
                }
            } else {
                // For multiple choice, toggle in array
                if (event.target.checked) {
                    if (!this.correctAnswers.includes(index)) {
                        this.correctAnswers.push(index);
                    }
                } else {
                    this.correctAnswers = this.correctAnswers.filter(i => i !== index);
                }
            }
        },

        addOption() {
            this.options.push({text: ''});
        },

        removeOption(index) {
            if (this.options.length > 2) {
                this.options.splice(index, 1);
                // Update correct answer if necessary
                if (this.correctAnswer === index) {
                    this.correctAnswer = null;
                } else if (this.correctAnswer > index) {
                    this.correctAnswer--;
                }
                // Update correct answers array for multiple choice
                this.correctAnswers = this.correctAnswers
                    .filter(i => i !== index)
                    .map(i => i > index ? i - 1 : i);
            }
        },

        addMatchingItem(side) {
            if (side === 'left') {
                this.matchingLeft.push('');
            } else {
                this.matchingRight.push('');
            }
        },

        removeMatchingItem(side, index) {
            if (side === 'left' && this.matchingLeft.length > 2) {
                this.matchingLeft.splice(index, 1);
            } else if (side === 'right' && this.matchingRight.length > 2) {
                this.matchingRight.splice(index, 1);
            }
        },

        addOrderingItem() {
            this.orderingItems.push('');
        },

        removeOrderingItem(index) {
            if (this.orderingItems.length > 2) {
                this.orderingItems.splice(index, 1);
            }
        },

        async submitForm(event) {
            const type = this.questionType;
            let isValid = true;
            let errorMessage = '';

            // Validate based on question type
            if (type === 'single_choice' || type === 'multiple_choice') {
                const checkboxes = this.$el.querySelectorAll('.correct-answer-checkbox:checked');
                if (checkboxes.length === 0) {
                    errorMessage = 'يرجى تحديد الإجابة الصحيحة';
                    isValid = false;
                }
                // Check that options have text
                const hasEmptyOption = this.options.some(opt => !opt.text || opt.text.trim() === '');
                if (hasEmptyOption) {
                    errorMessage = 'يرجى ملء جميع الخيارات';
                    isValid = false;
                }
            } else if (type === 'true_false') {
                if (!this.trueFalseValue) {
                    errorMessage = 'يرجى تحديد الإجابة الصحيحة (صحيح أو خطأ)';
                    isValid = false;
                }
            } else if (type === 'fill_blank') {
                if (!this.fillBlankAnswer || this.fillBlankAnswer.trim() === '') {
                    errorMessage = 'يرجى إدخال الإجابة الصحيحة';
                    isValid = false;
                }
            } else if (type === 'short_answer') {
                if (!this.modelAnswer || this.modelAnswer.trim() === '') {
                    errorMessage = 'يرجى إدخال الإجابة النموذجية';
                    isValid = false;
                }
            } else if (type === 'numeric') {
                if (!this.numericAnswer && this.numericAnswer !== '0') {
                    errorMessage = 'يرجى إدخال الإجابة الرقمية';
                    isValid = false;
                }
            } else if (type === 'matching') {
                if (!this.matchingPairs || this.matchingPairs.trim() === '') {
                    errorMessage = 'يرجى إدخال المطابقة الصحيحة';
                    isValid = false;
                }
            } else if (type === 'ordering') {
                const hasEmptyItem = this.orderingItems.some(item => !item || item.trim() === '');
                if (hasEmptyItem) {
                    errorMessage = 'يرجى ملء جميع عناصر الترتيب';
                    isValid = false;
                }
            }

            if (!isValid) {
                alert(errorMessage);
                return false;
            }

            // Build form data manually to ensure correct values
            const formData = new FormData(this.$el);

            // Remove any existing correct_answer fields and rebuild based on type
            const keysToRemove = [];
            for (const key of formData.keys()) {
                if (key.startsWith('correct_answer')) {
                    keysToRemove.push(key);
                }
            }
            keysToRemove.forEach(key => formData.delete(key));

            // Add correct_answer based on question type
            switch (type) {
                case 'true_false':
                    formData.append('correct_answer[answer]', this.trueFalseValue);
                    break;
                case 'single_choice':
                    if (this.correctAnswer !== null) {
                        formData.append('correct_answer[answer]', this.correctAnswer);
                    }
                    break;
                case 'multiple_choice':
                    if (this.correctAnswers.length > 0) {
                        this.correctAnswers.forEach(idx => {
                            formData.append('correct_answer[answers][]', idx);
                        });
                    }
                    break;
                case 'fill_blank':
                    formData.append('correct_answer[answer]', this.fillBlankAnswer);
                    break;
                case 'short_answer':
                    formData.append('correct_answer[model_answer]', this.modelAnswer);
                    formData.append('correct_answer[keywords]', this.keywords);
                    break;
                case 'numeric':
                    formData.append('correct_answer[answer]', this.numericAnswer);
                    formData.append('correct_answer[tolerance]', this.numericTolerance);
                    break;
                case 'matching':
                    formData.append('correct_answer[pairs]', this.matchingPairs);
                    break;
                case 'ordering':
                    formData.append('correct_answer[order]', JSON.stringify(this.orderingItems.map((_, i) => i)));
                    break;
            }

            // Submit via fetch
            try {
                const response = await fetch(this.$el.action, {
                    method: 'POST',
                    body: formData,
                    headers: {
                        'X-Requested-With': 'XMLHttpRequest',
                        'Accept': 'text/html'
                    }
                });

                if (response.redirected) {
                    window.location.href = response.url;
                } else if (response.ok) {
                    window.location.reload();
                } else {
                    const text = await response.text();
                    console.error('Form submission error:', text);
                    alert('حدث خطأ أثناء حفظ السؤال');
                }
            } catch (error) {
                console.error('Submit error:', error);
                alert('حدث خطأ أثناء حفظ السؤال');
            }
        }
    }
}
</script>
