@extends('layouts.admin')

@section('title', 'إضافة مادة جديدة')
@section('page-title', 'إضافة مادة جديدة')
@section('page-description', 'إضافة مادة دراسية جديدة')

@section('content')
<div class="p-8">
    <!-- Header -->
    <div class="mb-6">
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-3xl font-bold text-gray-800">إضافة مادة جديدة</h1>
                <p class="text-gray-600 mt-2">قم بإدخال معلومات المادة الدراسية الجديدة</p>
            </div>
            <a href="{{ route('admin.subjects.index') }}" class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded-lg transition">
                <i class="fas fa-arrow-right mr-2"></i>
                العودة إلى القائمة
            </a>
        </div>
    </div>

    <!-- Form -->
    <div class="bg-white rounded-xl shadow-md">
        <form method="POST" action="{{ route('admin.subjects.store') }}" class="p-6" x-data="subjectForm()" x-init="init()" dir="rtl">
            @csrf

            <!-- Error Messages -->
            @if($errors->any())
            <div class="bg-red-50 border-r-4 border-red-500 p-4 mb-6 rounded">
                <div class="flex items-start">
                    <i class="fas fa-exclamation-circle text-red-500 mr-3 mt-1"></i>
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

            <!-- Basic Information Section -->
            <div class="mb-8">
                <h2 class="text-xl font-semibold text-gray-800 mb-4 border-b pb-2">
                    <i class="fas fa-book text-blue-600 mr-2"></i>
                    المعلومات الأساسية
                </h2>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <!-- Name -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            اسم المادة <span class="text-red-500">*</span>
                        </label>
                        <input type="text"
                               name="name_ar"
                               value="{{ old('name_ar') }}"
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                               placeholder="مثال: الرياضيات"
                               dir="rtl"
                               required>
                        @error('name_ar')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                        @enderror
                    </div>

                    <!-- Slug -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            الاسم المختصر (Slug)
                        </label>
                        <input type="text"
                               name="slug"
                               value="{{ old('slug') }}"
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                               placeholder="mathematics"
                               dir="ltr">
                        <p class="text-sm text-gray-500 mt-1">سيتم إنشاؤه تلقائياً إذا ترك فارغاً</p>
                        @error('slug')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                        @enderror
                    </div>

                    <!-- Order -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            الترتيب
                        </label>
                        <input type="number"
                               name="order"
                               value="{{ old('order', 0) }}"
                               min="0"
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                               placeholder="0">
                        @error('order')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                        @enderror
                    </div>

                    <!-- Color -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            اللون
                        </label>
                        <input type="color"
                               name="color"
                               value="{{ old('color', '#3B82F6') }}"
                               class="w-full h-10 px-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                        @error('color')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                        @enderror
                    </div>

                    <!-- Icon -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            الأيقونة (Font Awesome)
                        </label>
                        <input type="text"
                               name="icon"
                               value="{{ old('icon') }}"
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                               placeholder="fa-calculator"
                               dir="ltr">
                        @error('icon')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                        @enderror
                    </div>
                </div>

                <!-- Description -->
                <div class="mt-6">
                    <label class="block text-gray-700 font-semibold mb-2">
                        الوصف
                    </label>
                    <textarea name="description_ar"
                              rows="4"
                              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                              placeholder="وصف مختصر عن المادة..."
                              dir="rtl">{{ old('description_ar') }}</textarea>
                    @error('description_ar')
                    <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                    @enderror
                </div>
            </div>

            <!-- Academic Scope Section -->
            <div class="mb-8">
                <h2 class="text-xl font-semibold text-gray-800 mb-4 border-b pb-2">
                    <i class="fas fa-graduation-cap text-blue-600 mr-2"></i>
                    النطاق الأكاديمي
                </h2>

                <div class="bg-blue-50 border-r-4 border-blue-500 p-4 mb-6 rounded">
                    <p class="text-blue-800 text-sm">
                        <i class="fas fa-info-circle mr-2"></i>
                        اختر إما <strong>سنة دراسية</strong> (مادة مشتركة لجميع الشعب) أو <strong>شعبة محددة</strong>
                    </p>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <!-- Academic Phase -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            المرحلة الدراسية <span class="text-red-500">*</span>
                        </label>
                        <select name="phase_id"
                                x-model="phaseId"
                                @change="loadYears()"
                                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                dir="rtl"
                                required>
                            <option value="">اختر المرحلة الدراسية</option>
                            @foreach($phases as $phase)
                            <option value="{{ $phase->id }}" {{ old('phase_id') == $phase->id ? 'selected' : '' }}>
                                {{ $phase->name_ar }}
                            </option>
                            @endforeach
                        </select>
                        @error('phase_id')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                        @enderror
                    </div>

                    <!-- Academic Year -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            السنة الدراسية <span class="text-red-500">*</span>
                        </label>
                        <select name="academic_year_id"
                                x-model="academicYearId"
                                @change="loadStreams()"
                                :disabled="!phaseId || loadingYears"
                                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-100 disabled:cursor-not-allowed"
                                dir="rtl"
                                required>
                            <option value="">
                                <span x-show="!phaseId">اختر المرحلة أولاً</span>
                                <span x-show="phaseId && loadingYears">جاري التحميل...</span>
                                <span x-show="phaseId && !loadingYears">اختر السنة الدراسية</span>
                            </option>
                            <template x-for="year in years" :key="year.id">
                                <option :value="year.id" x-text="year.name_ar" :selected="year.id == {{ old('academic_year_id', '0') }}"></option>
                            </template>
                        </select>
                        @error('academic_year_id')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                        @enderror
                    </div>

                    <!-- Academic Streams (Multi-select) -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            الشعب (اختياري للمواد المشتركة)
                        </label>
                        <select name="academic_stream_ids[]"
                                x-model="selectedStreamIds"
                                @change="updateStreamCoefficients()"
                                :disabled="!academicYearId || loadingStreams"
                                multiple
                                size="4"
                                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-100 disabled:cursor-not-allowed"
                                dir="rtl">
                            <template x-for="stream in streams" :key="stream.id">
                                <option :value="stream.id" x-text="stream.name_ar"></option>
                            </template>
                        </select>
                        <p class="text-sm text-gray-500 mt-1">اضغط Ctrl للاختيار المتعدد. اترك فارغاً للمواد المشتركة بين جميع الشعب</p>
                        @error('academic_stream_ids')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                        @enderror
                    </div>
                </div>

                <!-- Per-Stream Coefficients Section -->
                <div x-show="selectedStreamIds.length > 0" x-cloak class="mt-6">
                    <h3 class="text-lg font-semibold text-gray-700 mb-3">
                        <i class="fas fa-sliders-h text-amber-600 mr-2"></i>
                        المعاملات حسب الشعبة <span class="text-red-500">*</span>
                    </h3>
                    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                        <template x-for="streamId in selectedStreamIds" :key="streamId">
                            <div class="bg-gray-50 p-4 rounded-lg border border-gray-200">
                                <label class="block text-gray-700 font-medium mb-2">
                                    <span x-text="getStreamName(streamId)"></span>
                                </label>
                                <input type="number"
                                       :name="'stream_coefficients[' + streamId + ']'"
                                       x-model="streamCoefficients[streamId]"
                                       step="0.5"
                                       min="1"
                                       max="9"
                                       class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
                                       placeholder="أدخل المعامل"
                                       required>
                            </div>
                        </template>
                    </div>
                </div>
            </div>

            <!-- Settings Section -->
            <div class="mb-8">
                <h2 class="text-xl font-semibold text-gray-800 mb-4 border-b pb-2">
                    <i class="fas fa-cog text-blue-600 mr-2"></i>
                    الإعدادات
                </h2>
                <div class="flex items-center">
                    <input type="checkbox"
                           name="is_active"
                           id="is_active"
                           value="1"
                           {{ old('is_active', true) ? 'checked' : '' }}
                           class="w-5 h-5 text-blue-600 rounded focus:ring-2 focus:ring-blue-500">
                    <label for="is_active" class="mr-3 text-gray-700 font-semibold">
                        تفعيل المادة
                    </label>
                    <span class="text-sm text-gray-500 mr-2">(نشطة افتراضياً)</span>
                </div>
            </div>

            <!-- Action Buttons -->
            <div class="flex items-center gap-4 pt-6 border-t">
                <button type="submit"
                        class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg font-semibold transition flex items-center">
                    <i class="fas fa-save mr-2"></i>
                    حفظ المادة
                </button>
                <a href="{{ route('admin.subjects.index') }}"
                   class="bg-gray-500 hover:bg-gray-600 text-white px-6 py-3 rounded-lg font-semibold transition">
                    إلغاء
                </a>
            </div>
        </form>
    </div>
</div>

<script>
function subjectForm() {
    return {
        phaseId: '{{ old('phase_id') }}',
        academicYearId: '{{ old('academic_year_id') }}',
        selectedStreamIds: @json(old('academic_stream_ids', [])),
        streamCoefficients: @json(old('stream_coefficients', [])),
        years: [],
        streams: [],
        loadingYears: false,
        loadingStreams: false,

        init() {
            // If old values exist, load dependent dropdowns
            if (this.phaseId) {
                this.loadYears();
            }
            if (this.academicYearId) {
                this.loadStreams();
            }
            // Initialize stream coefficients if old values exist
            this.updateStreamCoefficients();
        },

        getStreamName(streamId) {
            const stream = this.streams.find(s => s.id == streamId);
            return stream ? stream.name_ar : 'شعبة ' + streamId;
        },

        updateStreamCoefficients() {
            // Keep only coefficients for selected streams
            const newCoefficients = {};
            this.selectedStreamIds.forEach(id => {
                if (this.streamCoefficients[id] !== undefined) {
                    newCoefficients[id] = this.streamCoefficients[id];
                }
            });
            this.streamCoefficients = newCoefficients;
        },

        async loadYears() {
            if (!this.phaseId) {
                this.years = [];
                this.academicYearId = '';
                this.streams = [];
                this.selectedStreamIds = [];
                this.streamCoefficients = {};
                return;
            }

            this.loadingYears = true;
            this.academicYearId = '';
            this.streams = [];
            this.selectedStreamIds = [];
            this.streamCoefficients = {};

            try {
                const response = await fetch(`/admin/subjects/ajax/years/${this.phaseId}`);
                if (!response.ok) throw new Error('Failed to fetch years');

                const data = await response.json();
                this.years = data;
            } catch (error) {
                console.error('Error loading years:', error);
                alert('حدث خطأ أثناء تحميل السنوات الدراسية');
                this.years = [];
            } finally {
                this.loadingYears = false;
            }
        },

        async loadStreams() {
            if (!this.academicYearId) {
                this.streams = [];
                this.selectedStreamIds = [];
                this.streamCoefficients = {};
                return;
            }

            this.loadingStreams = true;
            this.selectedStreamIds = [];
            this.streamCoefficients = {};

            try {
                const response = await fetch(`/admin/subjects/ajax/streams/${this.academicYearId}`);
                if (!response.ok) throw new Error('Failed to fetch streams');

                const data = await response.json();
                this.streams = data;
            } catch (error) {
                console.error('Error loading streams:', error);
                alert('حدث خطأ أثناء تحميل الشعب الدراسية');
                this.streams = [];
            } finally {
                this.loadingStreams = false;
            }
        }
    }
}
</script>
@endsection
