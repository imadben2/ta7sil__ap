@extends('layouts.admin')

@section('title', 'تعديل المادة')
@section('page-title', 'تعديل المادة')
@section('page-description', 'تعديل معلومات المادة الدراسية')

@section('content')
<div class="p-8">
    <!-- Header -->
    <div class="mb-6">
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-3xl font-bold text-gray-800">تعديل: {{ $subject->name_ar }}</h1>
                <p class="text-gray-600 mt-2">تحديث معلومات المادة الدراسية</p>
            </div>
            <a href="{{ route('admin.subjects.index') }}" class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded-lg transition">
                <i class="fas fa-arrow-right mr-2"></i>
                العودة إلى القائمة
            </a>
        </div>
    </div>

    <!-- Form -->
    <div class="bg-white rounded-xl shadow-md">
        <form method="POST" action="{{ route('admin.subjects.update', $subject) }}" class="p-6" x-data="subjectForm()" dir="rtl">
            @csrf
            @method('PUT')

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
                               value="{{ old('name_ar', $subject->name_ar) }}"
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
                               value="{{ old('slug', $subject->slug) }}"
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                               placeholder="mathematics"
                               dir="ltr">
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
                               value="{{ old('order', $subject->order) }}"
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
                               value="{{ old('color', $subject->color ?? '#3B82F6') }}"
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
                               value="{{ old('icon', $subject->icon) }}"
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
                              dir="rtl">{{ old('description_ar', $subject->description_ar) }}</textarea>
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

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <!-- Academic Year -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            السنة الدراسية (للمواد المشتركة)
                        </label>
                        <select name="academic_year_id"
                                x-model="academicYearId"
                                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                dir="rtl">
                            <option value="">اختر السنة الدراسية (اختياري)</option>
                            @foreach($years as $year)
                            <option value="{{ $year->id }}" {{ old('academic_year_id', $subject->academic_year_id) == $year->id ? 'selected' : '' }}>
                                {{ $year->academicPhase->name_ar }} - {{ $year->name_ar }}
                            </option>
                            @endforeach
                        </select>
                        @error('academic_year_id')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                        @enderror
                    </div>

                    <!-- Academic Streams (Multi-select) -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            الشعب (للمواد الخاصة)
                        </label>
                        <select name="academic_stream_ids[]"
                                x-model="selectedStreamIds"
                                @change="updateStreamCoefficients()"
                                multiple
                                size="4"
                                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                dir="rtl">
                            @foreach($streams as $stream)
                            <option value="{{ $stream->id }}" {{ in_array($stream->id, old('academic_stream_ids', $subject->academic_stream_ids ?? [])) ? 'selected' : '' }}>
                                {{ $stream->academicYear->academicPhase->name_ar }} - {{ $stream->academicYear->name_ar }} - {{ $stream->name_ar }}
                            </option>
                            @endforeach
                        </select>
                        <p class="text-sm text-gray-500 mt-1">اضغط Ctrl للاختيار المتعدد. اترك فارغاً للمواد المشتركة بين جميع الشعب</p>
                        @error('academic_stream_ids')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                        @enderror
                    </div>
                </div>

                <!-- Per-Stream Coefficients and Categories Section -->
                <div x-show="selectedStreamIds.length > 0" x-cloak class="mt-6">
                    <h3 class="text-lg font-semibold text-gray-700 mb-3">
                        <i class="fas fa-sliders-h text-amber-600 mr-2"></i>
                        المعاملات والتصنيفات حسب الشعبة <span class="text-red-500">*</span>
                    </h3>
                    <div class="bg-amber-50 border-r-4 border-amber-500 p-4 mb-4 rounded">
                        <p class="text-amber-800 text-sm">
                            <i class="fas fa-info-circle mr-2"></i>
                            يمكن لنفس المادة أن تكون <strong>HARD_CORE</strong> في شعبة و<strong>MEMORIZATION</strong> في شعبة أخرى حسب أهميتها ومعاملها
                        </p>
                    </div>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <template x-for="streamId in selectedStreamIds" :key="streamId">
                            <div class="bg-gray-50 p-4 rounded-lg border border-gray-200">
                                <label class="block text-gray-700 font-bold mb-3">
                                    <i class="fas fa-graduation-cap text-blue-600 mr-1"></i>
                                    <span x-text="getStreamName(streamId)"></span>
                                </label>

                                <!-- Coefficient -->
                                <div class="mb-3">
                                    <label class="block text-gray-600 text-sm font-medium mb-1">
                                        المعامل
                                    </label>
                                    <input type="number"
                                           :name="'stream_coefficients[' + streamId + ']'"
                                           x-model="streamCoefficients[streamId]"
                                           step="0.5"
                                           min="1"
                                           max="9"
                                           class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
                                           placeholder="أدخل المعامل"
                                           required>
                                </div>

                                <!-- Category -->
                                <div>
                                    <label class="block text-gray-600 text-sm font-medium mb-1">
                                        التصنيف
                                    </label>
                                    <select :name="'stream_categories[' + streamId + ']'"
                                            x-model="streamCategories[streamId]"
                                            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
                                            required>
                                        <option value="HARD_CORE">🔴 HARD_CORE - مواد علمية (رياضيات، فيزياء، علوم)</option>
                                        <option value="MEMORIZATION">🟡 MEMORIZATION - مواد حفظ (إسلامية، تاريخ، فلسفة)</option>
                                        <option value="LANGUAGE">🟢 LANGUAGE - لغات (عربية، فرنسية، إنجليزية)</option>
                                        <option value="OTHER">⚪ OTHER - أخرى</option>
                                    </select>
                                    <p class="text-xs text-gray-500 mt-1">
                                        <span x-show="streamCategories[streamId] === 'HARD_CORE'">⚡ أولوية عالية في أوقات الطاقة العالية</span>
                                        <span x-show="streamCategories[streamId] === 'MEMORIZATION'">📝 أولوية في أوقات الطاقة المتوسطة</span>
                                        <span x-show="streamCategories[streamId] === 'LANGUAGE'">📖 أولوية في أوقات الطاقة المنخفضة</span>
                                        <span x-show="streamCategories[streamId] === 'OTHER'">📋 تصنيف عام</span>
                                    </p>
                                </div>
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
                           {{ old('is_active', $subject->is_active) ? 'checked' : '' }}
                           class="w-5 h-5 text-blue-600 rounded focus:ring-2 focus:ring-blue-500">
                    <label for="is_active" class="mr-3 text-gray-700 font-semibold">
                        تفعيل المادة
                    </label>
                </div>
            </div>

            <!-- Action Buttons -->
            <div class="flex items-center gap-4 pt-6 border-t">
                <button type="submit"
                        class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg font-semibold transition flex items-center">
                    <i class="fas fa-save mr-2"></i>
                    حفظ التغييرات
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
    // Build streams lookup from PHP data
    const streamsLookup = @json($streams->mapWithKeys(fn($s) => [$s->id => $s->name_ar]));

    // Get existing stream coefficients from pivot table
    const existingCoefficients = @json(
        $subject->subjectStreams->mapWithKeys(fn($pivot) => [
            $pivot->academic_stream_id => $pivot->coefficient
        ])
    );

    // Get existing stream categories from pivot table
    const existingCategories = @json(
        $subject->subjectStreams->mapWithKeys(fn($pivot) => [
            $pivot->academic_stream_id => $pivot->category ?? 'OTHER'
        ])
    );

    return {
        academicYearId: '{{ old('academic_year_id', $subject->academic_year_id) }}',
        selectedStreamIds: @json(old('academic_stream_ids', $subject->academic_stream_ids ?? [])),
        streamCoefficients: Object.assign({}, existingCoefficients, @json(old('stream_coefficients', []))),
        streamCategories: Object.assign({}, existingCategories, @json(old('stream_categories', []))),
        streamsLookup: streamsLookup,

        getStreamName(streamId) {
            return this.streamsLookup[streamId] || 'شعبة ' + streamId;
        },

        updateStreamCoefficients() {
            // Keep only coefficients and categories for selected streams
            const newCoefficients = {};
            const newCategories = {};
            this.selectedStreamIds.forEach(id => {
                if (this.streamCoefficients[id] !== undefined) {
                    newCoefficients[id] = this.streamCoefficients[id];
                }
                if (this.streamCategories[id] !== undefined) {
                    newCategories[id] = this.streamCategories[id];
                } else {
                    // Default to OTHER for new streams
                    newCategories[id] = 'OTHER';
                }
            });
            this.streamCoefficients = newCoefficients;
            this.streamCategories = newCategories;
        }
    }
}
</script>
@endsection
