@extends('layouts.admin')

@section('title', 'إضافة موضوع بكالوريا')
@section('page-title', 'إضافة موضوع بكالوريا جديد')
@section('page-description', 'رفع موضوع بكالوريا مع الإجابة النموذجية')

@section('content')
<div class="space-y-6">
    <div class="flex items-center justify-between">
        <a href="{{ route('admin.bac.index') }}" class="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors">
            <i class="fas fa-arrow-right mr-2"></i>
            العودة إلى القائمة
        </a>
    </div>

    <form method="POST" action="{{ route('admin.bac.store') }}" enctype="multipart/form-data" class="space-y-6" x-data="bacForm()">
        @csrf

        <!-- Basic Information -->
        <div class="bg-white rounded-lg shadow-md p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-6">
                <i class="fas fa-info-circle text-blue-600 mr-2"></i>
                المعلومات الأساسية
            </h3>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <!-- BAC Year -->
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">
                        السنة <span class="text-red-500">*</span>
                    </label>
                    <select name="bac_year_id" id="bac_year_id" required class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                        <option value="">اختر السنة</option>
                        @foreach($years as $year)
                            <option value="{{ $year->id }}" {{ old('bac_year_id') == $year->id ? 'selected' : '' }}>
                                {{ $year->year }}
                            </option>
                        @endforeach
                    </select>
                    @error('bac_year_id')
                        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                </div>

                <!-- BAC Session -->
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">
                        الدورة <span class="text-red-500">*</span>
                    </label>
                    <select name="bac_session_id" id="bac_session_id" required class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                        <option value="">اختر الدورة</option>
                    </select>
                    @error('bac_session_id')
                        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                </div>

                <!-- Academic Phase -->
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">
                        المرحلة الدراسية <span class="text-red-500">*</span>
                    </label>
                    <select name="academic_phase_id" id="academic_phase_id" required class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                        <option value="">اختر المرحلة</option>
                        @foreach(\App\Models\AcademicPhase::orderBy('order')->get() as $phase)
                            <option value="{{ $phase->id }}" {{ old('academic_phase_id') == $phase->id ? 'selected' : '' }}>
                                {{ $phase->name_ar }}
                            </option>
                        @endforeach
                    </select>
                    @error('academic_phase_id')
                        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                </div>

                <!-- Academic Year -->
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">
                        السنة الدراسية <span class="text-red-500">*</span>
                    </label>
                    <select name="academic_year_id" id="academic_year_id" required class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                        <option value="">اختر السنة</option>
                    </select>
                    @error('academic_year_id')
                        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                </div>

                <!-- Academic Stream -->
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">
                        الشعبة الدراسية <span class="text-red-500">*</span>
                    </label>
                    <select name="academic_stream_id" id="academic_stream_id" required class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                        <option value="">اختر الشعبة</option>
                    </select>
                    @error('academic_stream_id')
                        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                </div>

                <!-- Subject -->
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">
                        المادة <span class="text-red-500">*</span>
                    </label>
                    <select name="subject_id" id="subject_id" required class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                        <option value="">اختر المادة</option>
                    </select>
                    @error('subject_id')
                        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                </div>

                <!-- Title -->
                <div class="md:col-span-2">
                    <label class="block text-sm font-medium text-gray-700 mb-2">
                        عنوان الموضوع <span class="text-red-500">*</span>
                    </label>
                    <input type="text" name="title_ar" required value="{{ old('title_ar') }}"
                           class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                           placeholder="مثال: موضوع الرياضيات - بكالوريا 2023 دورة جوان - شعبة علوم تجريبية">
                    @error('title_ar')
                        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                </div>

                <!-- Duration -->
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">
                        مدة الامتحان (بالدقائق) <span class="text-red-500">*</span>
                    </label>
                    <input type="number" name="duration_minutes" required value="{{ old('duration_minutes', 180) }}" min="1" max="300"
                           class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                    @error('duration_minutes')
                        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                </div>
            </div>
        </div>

        <!-- File Uploads -->
        <div class="bg-white rounded-lg shadow-md p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-6">
                <i class="fas fa-file-pdf text-red-600 mr-2"></i>
                رفع الملفات
            </h3>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <!-- Subject File -->
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">
                        ملف الموضوع (PDF) <span class="text-red-500">*</span>
                    </label>
                    <input type="file" name="file" required accept=".pdf"
                           class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                    <p class="mt-1 text-sm text-gray-500">الحد الأقصى: 10 ميغابايت</p>
                    @error('file')
                        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                </div>

                <!-- Correction File -->
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">
                        ملف التصحيح (PDF) (اختياري)
                    </label>
                    <input type="file" name="correction_file" accept=".pdf"
                           class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                    <p class="mt-1 text-sm text-gray-500">الحد الأقصى: 10 ميغابايت</p>
                    @error('correction_file')
                        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                    @enderror
                </div>
            </div>
        </div>

        <!-- Chapters -->
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between mb-6">
                <h3 class="text-lg font-semibold text-gray-900">
                    <i class="fas fa-book text-purple-600 mr-2"></i>
                    الفصول (اختياري)
                </h3>
                <button type="button" @click="addChapter()" class="px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors">
                    <i class="fas fa-plus mr-2"></i>
                    إضافة فصل
                </button>
            </div>

            <div x-show="chapters.length === 0" class="text-center py-8 text-gray-500">
                <i class="fas fa-info-circle text-4xl mb-3"></i>
                <p>لم يتم إضافة أي فصول بعد</p>
            </div>

            <div class="space-y-3">
                <template x-for="(chapter, index) in chapters" :key="index">
                    <div class="flex gap-3 items-start">
                        <span class="flex items-center justify-center w-8 h-8 bg-purple-100 text-purple-600 rounded-full text-sm font-bold flex-shrink-0 mt-2" x-text="index + 1"></span>
                        <input type="text" :name="'chapters[' + index + '][title_ar]'" x-model="chapter.title_ar" required
                               class="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                               placeholder="عنوان الفصل">
                        <button type="button" @click="removeChapter(index)" class="px-3 py-2 bg-red-100 text-red-600 rounded-lg hover:bg-red-200 transition-colors">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </template>
            </div>
        </div>

        <!-- Submit Buttons -->
        <div class="flex justify-end gap-3">
            <a href="{{ route('admin.bac.index') }}" class="px-6 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors">
                إلغاء
            </a>
            <button type="submit" class="px-6 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors">
                <i class="fas fa-save mr-2"></i>
                حفظ الموضوع
            </button>
        </div>
    </form>
</div>

@push('scripts')
<script>
function bacForm() {
    return {
        chapters: [],

        addChapter() {
            this.chapters.push({
                title_ar: ''
            });
        },

        removeChapter(index) {
            this.chapters.splice(index, 1);
        }
    }
}

// Cascading dropdowns with AJAX: Year -> Session, Phase -> Year -> Stream -> Subject

// Load sessions when BAC year is selected
document.getElementById('bac_year_id').addEventListener('change', async function() {
    const yearId = this.value;
    const sessionSelect = document.getElementById('bac_session_id');

    // Clear sessions
    sessionSelect.innerHTML = '<option value="">اختر الدورة</option>';

    if (!yearId) return;

    try {
        const sessionsResponse = await fetch(`/admin/bac/ajax/sessions/${yearId}`);
        const sessions = await sessionsResponse.json();

        sessions.forEach(session => {
            const option = document.createElement('option');
            option.value = session.id;
            option.textContent = session.name_ar;
            sessionSelect.appendChild(option);
        });
    } catch (error) {
        console.error('Error loading sessions:', error);
    }
});

// Load academic years when phase is selected
document.getElementById('academic_phase_id').addEventListener('change', async function() {
    const phaseId = this.value;
    const yearSelect = document.getElementById('academic_year_id');
    const streamSelect = document.getElementById('academic_stream_id');
    const subjectSelect = document.getElementById('subject_id');

    // Clear dependent dropdowns
    yearSelect.innerHTML = '<option value="">اختر السنة</option>';
    streamSelect.innerHTML = '<option value="">اختر الشعبة</option>';
    subjectSelect.innerHTML = '<option value="">اختر المادة</option>';

    if (!phaseId) return;

    try {
        const response = await fetch(`/admin/quizzes/ajax/years/${phaseId}`);
        const years = await response.json();

        years.forEach(year => {
            const option = document.createElement('option');
            option.value = year.id;
            option.textContent = year.name_ar;
            yearSelect.appendChild(option);
        });
    } catch (error) {
        console.error('Error loading years:', error);
    }
});

// Load streams when academic year is selected
document.getElementById('academic_year_id').addEventListener('change', async function() {
    const yearId = this.value;
    const streamSelect = document.getElementById('academic_stream_id');
    const subjectSelect = document.getElementById('subject_id');

    // Clear dependent dropdowns
    streamSelect.innerHTML = '<option value="">اختر الشعبة</option>';
    subjectSelect.innerHTML = '<option value="">اختر المادة</option>';

    if (!yearId) return;

    try {
        const response = await fetch(`/admin/quizzes/ajax/streams/${yearId}`);
        const streams = await response.json();

        streams.forEach(stream => {
            const option = document.createElement('option');
            option.value = stream.id;
            option.textContent = stream.name_ar;
            streamSelect.appendChild(option);
        });
    } catch (error) {
        console.error('Error loading streams:', error);
    }
});

// Load subjects when stream is selected
document.getElementById('academic_stream_id').addEventListener('change', async function() {
    const phaseId = document.getElementById('academic_phase_id').value;
    const yearId = document.getElementById('academic_year_id').value;
    const streamId = this.value;
    const subjectSelect = document.getElementById('subject_id');

    // Clear subjects
    subjectSelect.innerHTML = '<option value="">اختر المادة</option>';

    if (!streamId) return;

    try {
        const params = new URLSearchParams();
        if (phaseId) params.append('phase_id', phaseId);
        if (yearId) params.append('year_id', yearId);
        if (streamId) params.append('stream_id', streamId);

        const response = await fetch(`/admin/quizzes/ajax/subjects?${params}`);
        const subjects = await response.json();

        subjects.forEach(subject => {
            const option = document.createElement('option');
            option.value = subject.id;
            option.textContent = subject.name_ar;
            subjectSelect.appendChild(option);
        });
    } catch (error) {
        console.error('Error loading subjects:', error);
    }
});
</script>
@endpush
@endsection
