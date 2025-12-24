@extends('layouts.admin')

@section('title', 'تعديل: ' . $deck->title_ar)

@section('content')
<div class="p-6">
    <!-- Header -->
    <div class="flex items-center gap-4 mb-6">
        <a href="{{ route('admin.flashcard-decks.show', $deck->id) }}"
           class="w-10 h-10 bg-gray-100 hover:bg-gray-200 rounded-xl flex items-center justify-center transition">
            <i class="fas fa-arrow-right text-gray-600"></i>
        </a>
        <div>
            <h1 class="text-2xl font-bold text-gray-900">تعديل المجموعة</h1>
            <p class="text-gray-600">{{ $deck->title_ar }}</p>
        </div>
    </div>

    <form action="{{ route('admin.flashcard-decks.update', $deck->id) }}" method="POST" class="space-y-6" x-data="flashcardDeckEditForm()" x-init="init()">
        @csrf
        @method('PUT')

        <!-- Error Messages -->
        @if($errors->any())
        <div class="bg-red-50 border-r-4 border-red-500 p-4 mb-6 rounded">
            <div class="flex items-start">
                <i class="fas fa-exclamation-circle text-red-500 ml-3 mt-1"></i>
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

        <!-- Academic Selection -->
        <div class="bg-white rounded-xl shadow-sm p-6">
            <h2 class="text-lg font-bold text-gray-900 mb-4 flex items-center gap-2">
                <i class="fas fa-school text-pink-500"></i>
                التصنيف الأكاديمي
            </h2>

            <div class="bg-blue-50 border-r-4 border-blue-500 p-4 mb-6 rounded">
                <p class="text-blue-800 text-sm">
                    <i class="fas fa-info-circle ml-2"></i>
                    اختر المرحلة والسنة الدراسية، ثم اختر الشعب التي تريد إضافة البطاقات لها. اترك الشعب فارغة للمحتوى المشترك بين جميع الشعب.
                </p>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                <!-- Phase -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">المرحلة الدراسية <span class="text-red-500">*</span></label>
                    <select x-model="phaseId" @change="loadYears()"
                            class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500">
                        <option value="">اختر المرحلة</option>
                        @foreach($phases as $phase)
                            <option value="{{ $phase->id }}">{{ $phase->name_ar }}</option>
                        @endforeach
                    </select>
                </div>

                <!-- Year -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">السنة الدراسية <span class="text-red-500">*</span></label>
                    <select x-model="yearId" @change="loadStreamsAndSubjects()"
                            :disabled="!phaseId || loadingYears"
                            class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500 disabled:bg-gray-100">
                        <option value="">اختر السنة</option>
                        <template x-for="year in years" :key="year.id">
                            <option :value="year.id" x-text="year.name_ar"></option>
                        </template>
                    </select>
                </div>

                <!-- Streams (Multi-select) -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">الشعب (اختياري للمحتوى المشترك)</label>
                    <select name="academic_stream_ids[]" x-model="selectedStreamIds" @change="loadSubjects()"
                            :disabled="!yearId || loadingStreams"
                            multiple
                            size="4"
                            class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500 disabled:bg-gray-100">
                        <template x-for="stream in streams" :key="stream.id">
                            <option :value="stream.id" x-text="stream.name_ar"></option>
                        </template>
                    </select>
                    <p class="text-xs text-gray-500 mt-1">اضغط Ctrl للاختيار المتعدد. اترك فارغاً للمحتوى المشترك</p>
                </div>

                <!-- Subject -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">المادة <span class="text-red-500">*</span></label>
                    <select name="subject_id" x-model="subjectId" @change="loadChapters()" required
                            :disabled="!yearId || loadingSubjects"
                            class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500 disabled:bg-gray-100">
                        <option value="">اختر المادة</option>
                        <template x-for="subject in subjects" :key="subject.id">
                            <option :value="subject.id" x-text="subject.name_ar"></option>
                        </template>
                    </select>
                    @error('subject_id')
                        <p class="text-red-500 text-xs mt-1">{{ $message }}</p>
                    @enderror
                </div>

                <!-- Chapter -->
                <div class="md:col-span-2">
                    <label class="block text-sm font-semibold text-gray-700 mb-1">الفصل (اختياري)</label>
                    <select name="chapter_id" x-model="chapterId"
                            :disabled="!subjectId || loadingChapters"
                            class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500 disabled:bg-gray-100">
                        <option value="">كل الفصول</option>
                        <template x-for="chapter in chapters" :key="chapter.id">
                            <option :value="chapter.id" x-text="chapter.title_ar"></option>
                        </template>
                    </select>
                </div>
            </div>

            <!-- Selected Streams Display -->
            <div x-show="selectedStreamIds.length > 0" x-cloak class="mt-4 p-4 bg-purple-50 rounded-lg">
                <h4 class="text-sm font-semibold text-purple-800 mb-2">
                    <i class="fas fa-check-circle ml-1"></i>
                    الشعب المختارة:
                </h4>
                <div class="flex flex-wrap gap-2">
                    <template x-for="streamId in selectedStreamIds" :key="streamId">
                        <span class="px-3 py-1 bg-purple-200 text-purple-800 rounded-full text-sm font-semibold"
                              x-text="getStreamName(streamId)"></span>
                    </template>
                </div>
            </div>
        </div>

        <!-- Basic Info -->
        <div class="bg-white rounded-xl shadow-sm p-6">
            <h2 class="text-lg font-bold text-gray-900 mb-4 flex items-center gap-2">
                <i class="fas fa-info-circle text-blue-500"></i>
                المعلومات الأساسية
            </h2>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">العنوان بالعربية <span class="text-red-500">*</span></label>
                    <input type="text" name="title_ar" value="{{ old('title_ar', $deck->title_ar) }}" required
                           class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500">
                    @error('title_ar')
                        <p class="text-red-500 text-xs mt-1">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">العنوان بالفرنسية</label>
                    <input type="text" name="title_fr" value="{{ old('title_fr', $deck->title_fr) }}" dir="ltr"
                           class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500">
                </div>

                <div class="md:col-span-2">
                    <label class="block text-sm font-semibold text-gray-700 mb-1">الوصف بالعربية</label>
                    <textarea name="description_ar" rows="3"
                              class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500">{{ old('description_ar', $deck->description_ar) }}</textarea>
                </div>
            </div>
        </div>

        <!-- Settings -->
        <div class="bg-white rounded-xl shadow-sm p-6">
            <h2 class="text-lg font-bold text-gray-900 mb-4 flex items-center gap-2">
                <i class="fas fa-cog text-gray-500"></i>
                الإعدادات
            </h2>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">مستوى الصعوبة <span class="text-red-500">*</span></label>
                    <select name="difficulty_level" required
                            class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500">
                        <option value="easy" {{ old('difficulty_level', $deck->difficulty_level) == 'easy' ? 'selected' : '' }}>سهل</option>
                        <option value="medium" {{ old('difficulty_level', $deck->difficulty_level) == 'medium' ? 'selected' : '' }}>متوسط</option>
                        <option value="hard" {{ old('difficulty_level', $deck->difficulty_level) == 'hard' ? 'selected' : '' }}>صعب</option>
                    </select>
                </div>

                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">الوقت المقدر (دقائق)</label>
                    <input type="number" name="estimated_study_minutes" value="{{ old('estimated_study_minutes', $deck->estimated_study_minutes) }}" min="1"
                           class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500">
                </div>

                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">الترتيب</label>
                    <input type="number" name="order" value="{{ old('order', $deck->order) }}" min="0"
                           class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500">
                </div>

                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">اللون</label>
                    <input type="color" name="color" value="{{ old('color', $deck->color ?? '#EC4899') }}"
                           class="w-full h-10 rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500">
                </div>

                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">صورة الغلاف (URL)</label>
                    <input type="url" name="cover_image_url" value="{{ old('cover_image_url', $deck->cover_image_url) }}" dir="ltr"
                           class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500">
                </div>

                <div class="flex items-center pt-6">
                    <label class="flex items-center gap-3 cursor-pointer">
                        <input type="checkbox" name="is_premium" value="1" {{ old('is_premium', $deck->is_premium) ? 'checked' : '' }}
                               class="w-5 h-5 rounded text-pink-600 focus:ring-pink-500">
                        <span class="font-semibold text-gray-700">محتوى مدفوع</span>
                    </label>
                </div>
            </div>
        </div>

        <!-- Submit -->
        <div class="flex items-center gap-4">
            <button type="submit"
                    class="px-6 py-3 bg-gradient-to-l from-pink-500 to-pink-600 text-white rounded-xl font-bold shadow-lg hover:shadow-xl transition-all">
                <i class="fas fa-save ml-2"></i>
                حفظ التغييرات
            </button>
            <a href="{{ route('admin.flashcard-decks.show', $deck->id) }}"
               class="px-6 py-3 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-xl font-semibold transition">
                إلغاء
            </a>
        </div>
    </form>
</div>

<script>
function flashcardDeckEditForm() {
    return {
        // Initial values from deck
        phaseId: '{{ $deck->subject && $deck->subject->academicYear ? $deck->subject->academicYear->academic_phase_id : '' }}',
        yearId: '{{ $deck->subject ? $deck->subject->academic_year_id : '' }}',
        selectedStreamIds: @json($deck->academicStreams->pluck('id')->map(fn($id) => (string)$id)->toArray()),
        subjectId: '{{ $deck->subject_id }}',
        chapterId: '{{ $deck->chapter_id ?? '' }}',

        years: [],
        streams: [],
        subjects: [],
        chapters: [],

        loadingYears: false,
        loadingStreams: false,
        loadingSubjects: false,
        loadingChapters: false,

        async init() {
            // Load initial data based on existing deck values
            if (this.phaseId) {
                await this.loadYearsInitial();
            }
        },

        getStreamName(streamId) {
            const stream = this.streams.find(s => s.id == streamId);
            return stream ? stream.name_ar : 'شعبة ' + streamId;
        },

        async loadYearsInitial() {
            this.loadingYears = true;
            try {
                const response = await fetch(`{{ url('admin/flashcard-decks/years-by-phase') }}/${this.phaseId}`);
                if (!response.ok) throw new Error('Failed to fetch years');
                this.years = await response.json();

                // Load streams and subjects after years
                if (this.yearId) {
                    await this.loadStreamsAndSubjectsInitial();
                }
            } catch (error) {
                console.error('Error loading years:', error);
                this.years = [];
            } finally {
                this.loadingYears = false;
            }
        },

        async loadStreamsAndSubjectsInitial() {
            // Load streams
            this.loadingStreams = true;
            try {
                const response = await fetch(`{{ url('admin/flashcard-decks/streams-by-year') }}/${this.yearId}`);
                if (!response.ok) throw new Error('Failed to fetch streams');
                this.streams = await response.json();
            } catch (error) {
                console.error('Error loading streams:', error);
                this.streams = [];
            } finally {
                this.loadingStreams = false;
            }

            // Load subjects
            await this.loadSubjectsInitial();
        },

        async loadSubjectsInitial() {
            this.loadingSubjects = true;
            try {
                let url = `{{ route('admin.flashcard-decks.subjects') }}?year_id=${this.yearId}`;
                if (this.selectedStreamIds.length === 1) {
                    url += `&stream_id=${this.selectedStreamIds[0]}`;
                }
                const response = await fetch(url);
                if (!response.ok) throw new Error('Failed to fetch subjects');
                this.subjects = await response.json();

                // Load chapters after subjects
                if (this.subjectId) {
                    await this.loadChaptersInitial();
                }
            } catch (error) {
                console.error('Error loading subjects:', error);
                this.subjects = [];
            } finally {
                this.loadingSubjects = false;
            }
        },

        async loadChaptersInitial() {
            this.loadingChapters = true;
            try {
                const response = await fetch(`{{ url('admin/flashcard-decks/chapters') }}/${this.subjectId}`);
                if (!response.ok) throw new Error('Failed to fetch chapters');
                this.chapters = await response.json();
            } catch (error) {
                console.error('Error loading chapters:', error);
                this.chapters = [];
            } finally {
                this.loadingChapters = false;
            }
        },

        async loadYears() {
            if (!this.phaseId) {
                this.years = [];
                this.yearId = '';
                this.streams = [];
                this.selectedStreamIds = [];
                this.subjects = [];
                this.subjectId = '';
                this.chapters = [];
                this.chapterId = '';
                return;
            }

            this.loadingYears = true;
            this.yearId = '';
            this.streams = [];
            this.selectedStreamIds = [];
            this.subjects = [];
            this.subjectId = '';
            this.chapters = [];
            this.chapterId = '';

            try {
                const response = await fetch(`{{ url('admin/flashcard-decks/years-by-phase') }}/${this.phaseId}`);
                if (!response.ok) throw new Error('Failed to fetch years');
                this.years = await response.json();
            } catch (error) {
                console.error('Error loading years:', error);
                this.years = [];
            } finally {
                this.loadingYears = false;
            }
        },

        async loadStreamsAndSubjects() {
            if (!this.yearId) {
                this.streams = [];
                this.selectedStreamIds = [];
                this.subjects = [];
                this.subjectId = '';
                this.chapters = [];
                this.chapterId = '';
                return;
            }

            // Load streams
            this.loadingStreams = true;
            this.selectedStreamIds = [];
            try {
                const response = await fetch(`{{ url('admin/flashcard-decks/streams-by-year') }}/${this.yearId}`);
                if (!response.ok) throw new Error('Failed to fetch streams');
                this.streams = await response.json();
            } catch (error) {
                console.error('Error loading streams:', error);
                this.streams = [];
            } finally {
                this.loadingStreams = false;
            }

            // Load subjects
            this.loadSubjects();
        },

        async loadSubjects() {
            if (!this.yearId) {
                this.subjects = [];
                this.subjectId = '';
                this.chapters = [];
                this.chapterId = '';
                return;
            }

            this.loadingSubjects = true;
            this.subjectId = '';
            this.chapters = [];
            this.chapterId = '';

            try {
                let url = `{{ route('admin.flashcard-decks.subjects') }}?year_id=${this.yearId}`;
                if (this.selectedStreamIds.length === 1) {
                    url += `&stream_id=${this.selectedStreamIds[0]}`;
                }

                const response = await fetch(url);
                if (!response.ok) throw new Error('Failed to fetch subjects');
                this.subjects = await response.json();
            } catch (error) {
                console.error('Error loading subjects:', error);
                this.subjects = [];
            } finally {
                this.loadingSubjects = false;
            }
        },

        async loadChapters() {
            if (!this.subjectId) {
                this.chapters = [];
                this.chapterId = '';
                return;
            }

            this.loadingChapters = true;
            this.chapterId = '';

            try {
                const response = await fetch(`{{ url('admin/flashcard-decks/chapters') }}/${this.subjectId}`);
                if (!response.ok) throw new Error('Failed to fetch chapters');
                this.chapters = await response.json();
            } catch (error) {
                console.error('Error loading chapters:', error);
                this.chapters = [];
            } finally {
                this.loadingChapters = false;
            }
        }
    }
}
</script>
@endsection
