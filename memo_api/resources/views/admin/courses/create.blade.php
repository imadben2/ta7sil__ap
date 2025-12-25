@extends('layouts.admin')

@section('title', 'إضافة دورة جديدة')
@section('page-title', 'إضافة دورة جديدة')
@section('page-description', 'إنشاء دورة مدفوعة جديدة')

@section('content')
<form action="{{ route('admin.courses.store') }}" method="POST" enctype="multipart/form-data" class="space-y-6">
    @csrf

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Main Content -->
        <div class="lg:col-span-2 space-y-6">
            <!-- Basic Information -->
            <div class="bg-white rounded-lg shadow-sm p-6">
                <h3 class="text-lg font-semibold text-gray-900 mb-4">المعلومات الأساسية</h3>

                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">عنوان الدورة *</label>
                        <input type="text" name="title_ar" value="{{ old('title_ar') }}" required
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 @error('title_ar') border-red-500 @enderror">
                        @error('title_ar')
                            <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">وصف مختصر *</label>
                        <textarea name="short_description_ar" rows="2" required
                                  class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 @error('short_description_ar') border-red-500 @enderror">{{ old('short_description_ar') }}</textarea>
                        @error('short_description_ar')
                            <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">الوصف الكامل *</label>
                        <textarea name="description_ar" rows="6" required
                                  class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 @error('description_ar') border-red-500 @enderror">{{ old('description_ar') }}</textarea>
                        @error('description_ar')
                            <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                        @enderror
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">المرحلة الدراسية</label>
                            <select name="phase_id" id="phase_id"
                                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                                <option value="">اختر المرحلة</option>
                                @foreach(\App\Models\AcademicPhase::orderBy('order')->get() as $phase)
                                    <option value="{{ $phase->id }}" {{ old('phase_id') == $phase->id ? 'selected' : '' }}>
                                        {{ $phase->name_ar }}
                                    </option>
                                @endforeach
                            </select>
                        </div>

                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">السنة الدراسية</label>
                            <select name="year_id" id="year_id"
                                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                                <option value="">اختر السنة</option>
                            </select>
                        </div>

                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">الشعبة الدراسية</label>
                            <select name="stream_id" id="stream_id"
                                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                                <option value="">اختر الشعبة</option>
                            </select>
                        </div>

                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">المادة *</label>
                            <select name="subject_id" id="subject_id" required
                                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 @error('subject_id') border-red-500 @enderror">
                                <option value="">اختر المادة</option>
                            </select>
                            @error('subject_id')
                                <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                            @enderror
                        </div>

                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">المستوى *</label>
                            <select name="level" required
                                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 @error('level') border-red-500 @enderror">
                                <option value="">اختر المستوى</option>
                                <option value="beginner" {{ old('level') == 'beginner' ? 'selected' : '' }}>مبتدئ</option>
                                <option value="intermediate" {{ old('level') == 'intermediate' ? 'selected' : '' }}>متوسط</option>
                                <option value="advanced" {{ old('level') == 'advanced' ? 'selected' : '' }}>متقدم</option>
                            </select>
                            @error('level')
                                <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                            @enderror
                        </div>
                    </div>
                </div>
            </div>

            <!-- Instructor Information -->
            <div class="bg-white rounded-lg shadow-sm p-6">
                <h3 class="text-lg font-semibold text-gray-900 mb-4">معلومات المدرب</h3>

                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">اسم المدرب *</label>
                        <input type="text" name="instructor_name" value="{{ old('instructor_name') }}" required
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 @error('instructor_name') border-red-500 @enderror">
                        @error('instructor_name')
                            <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">نبذة عن المدرب</label>
                        <textarea name="instructor_bio_ar" rows="4"
                                  class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">{{ old('instructor_bio_ar') }}</textarea>
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">صورة المدرب</label>
                        <input type="file" name="instructor_photo" accept="image/*"
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                    </div>
                </div>
            </div>

            <!-- Course Content Section -->
            <div class="bg-white rounded-xl shadow-lg p-6 border-r-4 border-purple-500 hover:shadow-xl transition-shadow">
                <div class="flex items-center gap-3 mb-6">
                    <div class="w-10 h-10 bg-gradient-to-br from-purple-500 to-purple-600 rounded-lg flex items-center justify-center text-white">
                        <i class="fas fa-graduation-cap"></i>
                    </div>
                    <h3 class="text-xl font-bold text-gray-900">محتوى الدورة التعليمي</h3>
                </div>

                <div class="space-y-5">
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                            <i class="fas fa-lightbulb text-yellow-500 text-xs"></i>
                            ما ستتعلمه (سطر واحد لكل نقطة)
                        </label>
                        <textarea name="what_you_will_learn" rows="5" placeholder="أدخل كل نقطة في سطر منفصل"
                                  class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500 transition-all">{{ old('what_you_will_learn') }}</textarea>
                        <p class="text-xs text-gray-500 mt-1">مثال: فهم المفاهيم الأساسية بشكل عميق ومفصّل</p>
                    </div>

                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                            <i class="fas fa-clipboard-check text-orange-500 text-xs"></i>
                            المتطلبات الأساسية (سطر واحد لكل نقطة)
                        </label>
                        <textarea name="requirements" rows="4" placeholder="أدخل كل نقطة في سطر منفصل"
                                  class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500 transition-all">{{ old('requirements') }}</textarea>
                        <p class="text-xs text-gray-500 mt-1">مثال: معرفة أساسية بالمادة</p>
                    </div>

                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                            <i class="fas fa-users text-blue-500 text-xs"></i>
                            لمن هذه الدورة (سطر واحد لكل نقطة)
                        </label>
                        <textarea name="target_audience" rows="4" placeholder="أدخل كل نقطة في سطر منفصل"
                                  class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500 transition-all">{{ old('target_audience') }}</textarea>
                        <p class="text-xs text-gray-500 mt-1">مثال: طلاب السنة الثالثة ثانوي</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Sidebar -->
        <div class="space-y-6">
            <!-- Media -->
            <div class="bg-white rounded-lg shadow-sm p-6">
                <h3 class="text-lg font-semibold text-gray-900 mb-4">الصور والفيديو</h3>

                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">صورة الغلاف *</label>
                        <input type="file" name="thumbnail" accept="image/*" required
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 @error('thumbnail') border-red-500 @enderror">
                        <p class="text-xs text-gray-500 mt-1">الحجم الموصى به: 1280x720</p>
                        @error('thumbnail')
                            <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">فيديو تعريفي</label>
                        <select name="trailer_video_type" class="w-full px-4 py-2 border border-gray-300 rounded-lg mb-2">
                            <option value="youtube">YouTube</option>
                            <option value="vimeo">Vimeo</option>
                            <option value="uploaded">رفع مباشر</option>
                        </select>
                        <input type="text" name="trailer_video_url" placeholder="رابط الفيديو أو قم برفعه"
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                    </div>
                </div>
            </div>

            <!-- Pricing -->
            <div class="bg-white rounded-lg shadow-sm p-6">
                <h3 class="text-lg font-semibold text-gray-900 mb-4">السعر</h3>

                <div class="space-y-4">
                    <div class="flex items-center">
                        <input type="checkbox" name="is_free" id="is_free" value="1"
                               {{ old('is_free') ? 'checked' : '' }}
                               class="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
                               onchange="document.getElementById('price_field').disabled = this.checked">
                        <label for="is_free" class="mr-2 text-sm text-gray-700">دورة مجانية</label>
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">السعر (دج)</label>
                        <input type="number" name="price_dzd" id="price_field" value="{{ old('price_dzd', 0) }}" min="0"
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                    </div>
                </div>
            </div>

            <!-- Settings -->
            <div class="bg-white rounded-lg shadow-sm p-6">
                <h3 class="text-lg font-semibold text-gray-900 mb-4">الإعدادات</h3>

                <div class="space-y-3">
                    <div class="flex items-center">
                        <input type="checkbox" name="is_published" id="is_published" value="1"
                               {{ old('is_published') ? 'checked' : '' }}
                               class="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
                        <label for="is_published" class="mr-2 text-sm text-gray-700">نشر الدورة فوراً</label>
                    </div>

                    <div class="flex items-center">
                        <input type="checkbox" name="featured" id="featured" value="1"
                               {{ old('featured') ? 'checked' : '' }}
                               class="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
                        <label for="featured" class="mr-2 text-sm text-gray-700">دورة مميزة</label>
                    </div>

                    <div class="flex items-center bg-green-50 border border-green-200 rounded-lg p-3 hover:bg-green-100 transition-colors cursor-pointer">
                        <input type="checkbox" name="certificate_available" id="certificate_available" value="1"
                               {{ old('certificate_available', 1) ? 'checked' : '' }}
                               class="w-5 h-5 text-green-600 border-gray-300 rounded focus:ring-green-500">
                        <label for="certificate_available" class="mr-3 text-sm font-bold text-gray-700 flex items-center gap-2 cursor-pointer">
                            <i class="fas fa-certificate text-green-500"></i>
                            شهادة إتمام متاحة
                        </label>
                    </div>
                </div>
            </div>

            <!-- Tags -->
            <div class="bg-white rounded-lg shadow-sm p-6">
                <h3 class="text-lg font-semibold text-gray-900 mb-4">الوسوم</h3>
                <input type="text" name="tags" value="{{ old('tags') }}" placeholder="أدخل الوسوم مفصولة بفواصل"
                       class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                <p class="text-xs text-gray-500 mt-1">مثال: برمجة, تصميم, تطوير</p>
            </div>
        </div>
    </div>

    <!-- Actions -->
    <div class="flex justify-end gap-3 bg-white rounded-lg shadow-sm p-6">
        <a href="{{ route('admin.courses.index') }}"
           class="px-6 py-3 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50">
            إلغاء
        </a>
        <button type="submit"
                class="px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg flex items-center gap-2">
            <i class="fas fa-save"></i>
            <span>حفظ الدورة</span>
        </button>
    </div>
</form>

@push('scripts')
<script>
// Cascading dropdowns with AJAX: Phase -> Year -> Stream -> Subject

// Load years when phase is selected
document.getElementById('phase_id').addEventListener('change', async function() {
    const phaseId = this.value;
    const yearSelect = document.getElementById('year_id');
    const streamSelect = document.getElementById('stream_id');
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

// Load streams when year is selected
document.getElementById('year_id').addEventListener('change', async function() {
    const yearId = this.value;
    const streamSelect = document.getElementById('stream_id');
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
document.getElementById('stream_id').addEventListener('change', async function() {
    const phaseId = document.getElementById('phase_id').value;
    const yearId = document.getElementById('year_id').value;
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
