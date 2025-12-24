@extends('layouts.admin')

@section('title', 'إضافة مستخدم جديد')

@section('content')
<div class="p-6">
    <!-- Header -->
    <div class="mb-6">
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-3xl font-bold text-gray-800">إضافة مستخدم جديد</h1>
                <p class="text-gray-600 mt-2">قم بإدخال معلومات المستخدم الجديد</p>
            </div>
            <a href="{{ route('admin.users.index') }}" class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded-lg transition">
                <i class="fas fa-arrow-right mr-2"></i>
                العودة إلى القائمة
            </a>
        </div>
    </div>

    <!-- Form -->
    <div class="bg-white rounded-xl shadow-md">
        <form method="POST" action="{{ route('admin.users.store') }}" class="p-6" x-data="userCreateForm()" dir="rtl">
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
                    <i class="fas fa-user text-blue-600 mr-2"></i>
                    المعلومات الأساسية
                </h2>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <!-- Name -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            الاسم الكامل <span class="text-red-500">*</span>
                        </label>
                        <input type="text"
                               name="name"
                               value="{{ old('name') }}"
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                               placeholder="أدخل الاسم الكامل"
                               dir="rtl"
                               required>
                        @error('name')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                        @enderror
                    </div>

                    <!-- Email -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            البريد الإلكتروني <span class="text-red-500">*</span>
                        </label>
                        <input type="email"
                               name="email"
                               value="{{ old('email') }}"
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                               placeholder="مثال@بريد.com"
                               dir="ltr"
                               required>
                        @error('email')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                        @enderror
                    </div>

                    <!-- Phone -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            رقم الهاتف
                        </label>
                        <input type="tel"
                               name="phone"
                               value="{{ old('phone') }}"
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                               placeholder="0555123456"
                               dir="ltr">
                        @error('phone')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                        @enderror
                    </div>

                    <!-- Role -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            الدور
                        </label>
                        <select name="role"
                                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                dir="rtl">
                            <option value="student" {{ old('role') == 'student' ? 'selected' : '' }}>طالب</option>
                            <option value="teacher" {{ old('role') == 'teacher' ? 'selected' : '' }}>معلم</option>
                            <option value="admin" {{ old('role') == 'admin' ? 'selected' : '' }}>مدير</option>
                        </select>
                        @error('role')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                        @enderror
                    </div>
                </div>
            </div>

            <!-- Password Section -->
            <div class="mb-8">
                <h2 class="text-xl font-semibold text-gray-800 mb-4 border-b pb-2">
                    <i class="fas fa-lock text-blue-600 mr-2"></i>
                    كلمة المرور
                </h2>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <!-- Password -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            كلمة المرور
                        </label>
                        <div class="relative">
                            <input :type="showPassword ? 'text' : 'password'"
                                   name="password"
                                   x-model="password"
                                   class="w-full px-4 py-2 pl-10 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                   placeholder="اتركه فارغاً لتوليد كلمة مرور عشوائية"
                                   dir="rtl">
                            <button type="button"
                                    @click="showPassword = !showPassword"
                                    class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-700">
                                <i :class="showPassword ? 'fas fa-eye-slash' : 'fas fa-eye'"></i>
                            </button>
                        </div>
                        <p class="text-sm text-gray-500 mt-1">الحد الأدنى 8 أحرف</p>
                        @error('password')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                        @enderror
                    </div>

                    <!-- Generate Password Button -->
                    <div class="flex items-end">
                        <button type="button"
                                @click="generatePassword()"
                                class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg transition">
                            <i class="fas fa-random mr-2"></i>
                            توليد كلمة مرور عشوائية
                        </button>
                    </div>
                </div>
                <div x-show="generatedPassword" class="mt-4 p-4 bg-green-50 border border-green-200 rounded-lg">
                    <p class="text-green-800 font-semibold mb-2">كلمة المرور المولدة:</p>
                    <div class="flex items-center gap-3">
                        <code class="bg-white px-3 py-2 rounded border flex-1 text-lg" dir="ltr" x-text="generatedPassword"></code>
                        <button type="button"
                                @click="copyPassword()"
                                class="bg-green-600 hover:bg-green-700 text-white px-3 py-2 rounded transition">
                            <i class="fas fa-copy"></i>
                        </button>
                    </div>
                    <p class="text-sm text-green-700 mt-2">
                        <i class="fas fa-info-circle mr-1"></i>
                        تأكد من حفظ كلمة المرور قبل المتابعة
                    </p>
                </div>
            </div>

            <!-- Academic Information Section -->
            <div class="mb-8">
                <h2 class="text-xl font-semibold text-gray-800 mb-4 border-b pb-2">
                    <i class="fas fa-graduation-cap text-blue-600 mr-2"></i>
                    المعلومات الأكاديمية
                </h2>
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <!-- Academic Phase -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            المرحلة التعليمية <span class="text-red-500">*</span>
                        </label>
                        <select name="academic_phase_id"
                                x-ref="phaseSelect"
                                @change="onPhaseChange($event)"
                                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                dir="rtl"
                                required>
                            <option value="">اختر المرحلة</option>
                            @foreach($academicPhases as $phase)
                            <option value="{{ $phase->id }}" {{ old('academic_phase_id') == $phase->id ? 'selected' : '' }}>
                                {{ $phase->name_ar }}
                            </option>
                            @endforeach
                        </select>
                        @error('academic_phase_id')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                        @enderror
                    </div>

                    <!-- Academic Year -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            السنة الدراسية <span class="text-red-500">*</span>
                        </label>
                        <select name="academic_year_id"
                                x-ref="yearSelect"
                                @change="onYearChange($event)"
                                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                dir="rtl"
                                :disabled="!selectedPhaseId"
                                required>
                            <option value="">اختر السنة الدراسية</option>
                        </select>
                        @error('academic_year_id')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                        @enderror
                    </div>

                    <!-- Academic Stream -->
                    <div>
                        <label class="block text-gray-700 font-semibold mb-2">
                            الشعبة <span class="text-red-500" x-show="streamRequired">*</span>
                        </label>
                        <select name="academic_stream_id"
                                x-ref="streamSelect"
                                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                dir="rtl"
                                :disabled="!selectedYearId"
                                :required="streamRequired">
                            <option value="">اختر الشعبة</option>
                        </select>
                        <p class="text-sm text-gray-500 mt-1" x-show="!streamRequired">اختياري</p>
                        @error('academic_stream_id')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                        @enderror
                    </div>
                </div>
            </div>

            <!-- Settings Section -->
            <div class="mb-8">
                <h2 class="text-xl font-semibold text-gray-800 mb-4 border-b pb-2">
                    <i class="fas fa-cog text-blue-600 mr-2"></i>
                    الإعدادات
                </h2>
                <div class="space-y-4">
                    <!-- Active Status -->
                    <div class="flex items-center">
                        <input type="checkbox"
                               name="is_active"
                               id="is_active"
                               value="1"
                               {{ old('is_active', true) ? 'checked' : '' }}
                               class="w-5 h-5 text-blue-600 rounded focus:ring-2 focus:ring-blue-500">
                        <label for="is_active" class="mr-3 text-gray-700 font-semibold">
                            تفعيل الحساب
                        </label>
                        <span class="text-sm text-gray-500 mr-2">(الحساب نشط افتراضياً)</span>
                    </div>

                    <!-- Send Welcome Email -->
                    <div class="flex items-center">
                        <input type="checkbox"
                               name="send_welcome_email"
                               id="send_welcome_email"
                               value="1"
                               {{ old('send_welcome_email') ? 'checked' : '' }}
                               class="w-5 h-5 text-blue-600 rounded focus:ring-2 focus:ring-blue-500">
                        <label for="send_welcome_email" class="mr-3 text-gray-700 font-semibold">
                            إرسال بريد ترحيبي
                        </label>
                        <span class="text-sm text-gray-500 mr-2">(سيتم إرسال بيانات الدخول عبر البريد الإلكتروني)</span>
                    </div>
                </div>
            </div>

            <!-- Action Buttons -->
            <div class="flex items-center gap-4 pt-6 border-t">
                <button type="submit"
                        class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg font-semibold transition flex items-center">
                    <i class="fas fa-save mr-2"></i>
                    حفظ المستخدم
                </button>
                <a href="{{ route('admin.users.index') }}"
                   class="bg-gray-500 hover:bg-gray-600 text-white px-6 py-3 rounded-lg font-semibold transition">
                    إلغاء
                </a>
            </div>
        </form>
    </div>
</div>

<script>
function userCreateForm() {
    return {
        password: '',
        generatedPassword: '',
        showPassword: false,
        selectedPhaseId: '{{ old("academic_phase_id") }}',
        selectedYearId: '{{ old("academic_year_id") }}',
        streamRequired: false,

        init() {
            // If there's an old phase selection (from validation errors), load its years
            if (this.selectedPhaseId) {
                this.loadYears(this.selectedPhaseId, '{{ old("academic_year_id") }}');
            }
            // If there's an old year selection, load its streams
            if (this.selectedYearId) {
                this.loadStreams(this.selectedYearId, '{{ old("academic_stream_id") }}');
            }
        },

        generatePassword() {
            const length = 12;
            const charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*';
            let password = '';
            for (let i = 0; i < length; i++) {
                password += charset.charAt(Math.floor(Math.random() * charset.length));
            }
            this.password = password;
            this.generatedPassword = password;
        },

        copyPassword() {
            navigator.clipboard.writeText(this.generatedPassword).then(() => {
                alert('تم نسخ كلمة المرور!');
            });
        },

        async onPhaseChange(event) {
            const phaseId = event.target.value;
            this.selectedPhaseId = phaseId;
            this.selectedYearId = '';

            // Reset year and stream selects
            this.$refs.yearSelect.innerHTML = '<option value="">اختر السنة الدراسية</option>';
            this.$refs.streamSelect.innerHTML = '<option value="">اختر الشعبة</option>';
            this.streamRequired = false;

            if (!phaseId) return;

            await this.loadYears(phaseId);
        },

        async loadYears(phaseId, selectedYearId = null) {
            try {
                const response = await fetch(`/admin/users/ajax/years-by-phase/${phaseId}`);
                const data = await response.json();

                if (data.success && data.data.length > 0) {
                    let options = '<option value="">اختر السنة الدراسية</option>';
                    data.data.forEach(year => {
                        const selected = selectedYearId && selectedYearId == year.id ? 'selected' : '';
                        options += `<option value="${year.id}" ${selected}>${year.name_ar}</option>`;
                    });
                    this.$refs.yearSelect.innerHTML = options;

                    // If we preselected a year, load its streams
                    if (selectedYearId) {
                        this.selectedYearId = selectedYearId;
                        await this.loadStreams(selectedYearId);
                    }
                }
            } catch (error) {
                console.error('Error loading years:', error);
                alert('حدث خطأ أثناء تحميل السنوات الدراسية');
            }
        },

        async onYearChange(event) {
            const yearId = event.target.value;
            this.selectedYearId = yearId;

            // Reset stream select
            this.$refs.streamSelect.innerHTML = '<option value="">اختر الشعبة</option>';
            this.streamRequired = false;

            if (!yearId) return;

            await this.loadStreams(yearId);
        },

        async loadStreams(yearId, selectedStreamId = null) {
            try {
                const response = await fetch(`/admin/users/ajax/streams-by-year/${yearId}`);
                const data = await response.json();

                if (data.success) {
                    this.streamRequired = data.requires_stream;

                    if (data.data.length > 0) {
                        let options = '<option value="">اختر الشعبة</option>';
                        data.data.forEach(stream => {
                            const selected = selectedStreamId && selectedStreamId == stream.id ? 'selected' : '';
                            options += `<option value="${stream.id}" ${selected}>${stream.name_ar}</option>`;
                        });
                        this.$refs.streamSelect.innerHTML = options;
                    }
                }
            } catch (error) {
                console.error('Error loading streams:', error);
                alert('حدث خطأ أثناء تحميل الشعب');
            }
        }
    }
}
</script>
@endsection
