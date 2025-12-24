@extends('layouts.admin')

@section('title', 'بطاقات: ' . $deck->title_ar)

@section('content')
<div class="p-6">
    <!-- Header -->
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-6">
        <div class="flex items-start gap-4">
            <a href="{{ route('admin.flashcard-decks.show', $deck->id) }}"
               class="w-10 h-10 bg-gray-100 hover:bg-gray-200 rounded-xl flex items-center justify-center transition flex-shrink-0 mt-1">
                <i class="fas fa-arrow-right text-gray-600"></i>
            </a>
            <div>
                <h1 class="text-2xl font-bold text-gray-900">بطاقات المجموعة</h1>
                <p class="text-gray-600 mt-1">
                    {{ $deck->title_ar }}
                    @if($deck->subject)
                        <span class="text-gray-400 mx-1">›</span>
                        <span class="px-2 py-1 bg-blue-100 text-blue-700 rounded-full text-xs font-semibold">{{ $deck->subject->name_ar }}</span>
                    @endif
                </p>
            </div>
        </div>
        <div class="flex gap-2">
            <button onclick="openCardModal()"
                    class="px-4 py-2 bg-gradient-to-l from-pink-500 to-pink-600 text-white rounded-xl font-bold shadow-lg hover:shadow-xl transition-all">
                <i class="fas fa-plus ml-1"></i>
                إضافة بطاقة
            </button>
        </div>
    </div>

    <!-- Filters -->
    <div class="bg-white rounded-xl shadow-sm p-4 mb-6">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">نوع البطاقة</label>
                <select id="filter_type" class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500">
                    <option value="">الكل</option>
                    <option value="basic">أساسي</option>
                    <option value="cloze">إملاء</option>
                    <option value="image">صورة</option>
                    <option value="audio">صوت</option>
                </select>
            </div>

            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">الصعوبة</label>
                <select id="filter_difficulty" class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500">
                    <option value="">الكل</option>
                    <option value="easy">سهل</option>
                    <option value="medium">متوسط</option>
                    <option value="hard">صعب</option>
                </select>
            </div>

            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">الحالة</label>
                <select id="filter_status" class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500">
                    <option value="">الكل</option>
                    <option value="active">نشط</option>
                    <option value="inactive">غير نشط</option>
                </select>
            </div>

            <div class="flex items-end">
                <button id="btn_reset_filters" class="w-full px-4 py-2 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-lg font-semibold transition">
                    <i class="fas fa-redo-alt ml-1"></i> إعادة تعيين
                </button>
            </div>
        </div>
    </div>

    <!-- Data Table -->
    <div class="bg-white rounded-xl shadow-sm overflow-hidden">
        <table id="cards_table" class="w-full">
            <thead class="bg-gray-50 border-b">
                <tr>
                    <th class="px-4 py-3 text-center text-xs font-bold text-gray-600 uppercase w-16">الترتيب</th>
                    <th class="px-4 py-3 text-center text-xs font-bold text-gray-600 uppercase w-24">النوع</th>
                    <th class="px-4 py-3 text-right text-xs font-bold text-gray-600 uppercase">الوجه الأمامي</th>
                    <th class="px-4 py-3 text-right text-xs font-bold text-gray-600 uppercase">الوجه الخلفي</th>
                    <th class="px-4 py-3 text-center text-xs font-bold text-gray-600 uppercase w-20">الصعوبة</th>
                    <th class="px-4 py-3 text-center text-xs font-bold text-gray-600 uppercase w-20">الحالة</th>
                    <th class="px-4 py-3 text-center text-xs font-bold text-gray-600 uppercase w-24">إجراءات</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>
</div>

<!-- Card Modal -->
<div id="cardModal" class="fixed inset-0 z-50 hidden overflow-y-auto" dir="rtl">
    <div class="flex items-center justify-center min-h-screen px-4 pt-4 pb-20 text-center sm:p-0">
        <div class="fixed inset-0 bg-gray-500 bg-opacity-75" onclick="closeCardModal()"></div>

        <div class="relative bg-white rounded-2xl text-right overflow-hidden shadow-xl sm:max-w-2xl sm:w-full" style="transform: none !important;">
            <div class="bg-gradient-to-l from-pink-500 to-pink-600 px-6 py-4 flex items-center justify-between">
                <button onclick="closeCardModal()" class="text-white hover:text-pink-200">
                    <i class="fas fa-times text-xl"></i>
                </button>
                <h3 id="modalTitle" class="text-lg font-bold text-white">إضافة بطاقة جديدة</h3>
            </div>

            <form id="cardForm" class="p-6 space-y-4" dir="rtl">
                <input type="hidden" id="card_id" name="card_id">

                <!-- Card Type -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1 text-right">نوع البطاقة <span class="text-red-500">*</span></label>
                    <select id="card_type" name="card_type" required onchange="toggleCardTypeFields()"
                            class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500 text-right" dir="rtl">
                        <option value="basic">أساسي (سؤال وجواب)</option>
                        <option value="cloze">إملاء (ملء الفراغات)</option>
                        <option value="image">صورة</option>
                        <option value="audio">صوت</option>
                    </select>
                </div>

                <!-- Basic Type Fields -->
                <div id="basicFields">
                    <div>
                        <label class="block text-sm font-semibold text-gray-700 mb-1 text-right">السؤال / الوجه الأمامي <span class="text-red-500">*</span></label>
                        <textarea id="front_text_ar" name="front_text_ar" rows="3" dir="rtl"
                                  class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500 text-right"
                                  placeholder="اكتب السؤال أو النص الذي سيظهر في الوجه الأمامي"></textarea>
                    </div>
                </div>

                <!-- Cloze Type Fields -->
                <div id="clozeFields" class="hidden">
                    <div>
                        <label class="block text-sm font-semibold text-gray-700 mb-1 text-right">قالب الإملاء <span class="text-red-500">*</span></label>
                        <textarea id="cloze_template" name="cloze_template" rows="3" dir="rtl"
                                  class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500 text-right"
                                  placeholder="استخدم @{{c1::الكلمة}} لتحديد الفراغات. مثال: الدالة @{{c1::التربيعية}} هي f(x) = x²"></textarea>
                        <p class="text-xs text-gray-500 mt-1 text-right">مثال: @{{c1::الجواب::تلميح}} - التلميح اختياري</p>
                    </div>
                </div>

                <!-- Back Text (Answer) -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1 text-right">الجواب / الوجه الخلفي <span class="text-red-500">*</span></label>
                    <textarea id="back_text_ar" name="back_text_ar" rows="3" required dir="rtl"
                              class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500 text-right"
                              placeholder="اكتب الجواب أو الشرح"></textarea>
                </div>

                <!-- Media Fields - Images -->
                <div id="mediaFields" class="hidden">
                    <div class="grid grid-cols-2 gap-4">
                        <!-- Front Image -->
                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-1 text-right">صورة الوجه الأمامي</label>
                            <div class="space-y-2">
                                <!-- Upload Option -->
                                <div class="flex items-center gap-2">
                                    <label class="flex-1 cursor-pointer">
                                        <div class="flex items-center justify-center px-4 py-3 border-2 border-dashed border-gray-300 rounded-lg hover:border-pink-400 transition">
                                            <i class="fas fa-cloud-upload-alt text-gray-400 ml-2"></i>
                                            <span class="text-sm text-gray-600">رفع صورة</span>
                                        </div>
                                        <input type="file" class="hidden" accept="image/*" onchange="uploadImage(this, 'front')">
                                    </label>
                                </div>
                                <!-- URL Option -->
                                <input type="url" id="front_image_url" name="front_image_url" dir="ltr"
                                       class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500 text-left text-sm"
                                       placeholder="أو أدخل رابط الصورة https://...">
                                <!-- Preview -->
                                <div id="front_image_preview" class="hidden">
                                    <div class="relative inline-block">
                                        <img id="front_image_preview_img" src="" class="max-h-24 rounded-lg border">
                                        <button type="button" onclick="removeImage('front')" class="absolute -top-2 -right-2 w-6 h-6 bg-red-500 text-white rounded-full text-xs hover:bg-red-600">
                                            <i class="fas fa-times"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- Back Image -->
                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-1 text-right">صورة الوجه الخلفي</label>
                            <div class="space-y-2">
                                <!-- Upload Option -->
                                <div class="flex items-center gap-2">
                                    <label class="flex-1 cursor-pointer">
                                        <div class="flex items-center justify-center px-4 py-3 border-2 border-dashed border-gray-300 rounded-lg hover:border-pink-400 transition">
                                            <i class="fas fa-cloud-upload-alt text-gray-400 ml-2"></i>
                                            <span class="text-sm text-gray-600">رفع صورة</span>
                                        </div>
                                        <input type="file" class="hidden" accept="image/*" onchange="uploadImage(this, 'back')">
                                    </label>
                                </div>
                                <!-- URL Option -->
                                <input type="url" id="back_image_url" name="back_image_url" dir="ltr"
                                       class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500 text-left text-sm"
                                       placeholder="أو أدخل رابط الصورة https://...">
                                <!-- Preview -->
                                <div id="back_image_preview" class="hidden">
                                    <div class="relative inline-block">
                                        <img id="back_image_preview_img" src="" class="max-h-24 rounded-lg border">
                                        <button type="button" onclick="removeImage('back')" class="absolute -top-2 -right-2 w-6 h-6 bg-red-500 text-white rounded-full text-xs hover:bg-red-600">
                                            <i class="fas fa-times"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Audio Fields -->
                <div id="audioFields" class="hidden">
                    <div class="grid grid-cols-2 gap-4">
                        <!-- Front Audio -->
                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-1 text-right">صوت الوجه الأمامي</label>
                            <div class="space-y-2">
                                <!-- Upload Option -->
                                <div class="flex items-center gap-2">
                                    <label class="flex-1 cursor-pointer">
                                        <div class="flex items-center justify-center px-4 py-3 border-2 border-dashed border-gray-300 rounded-lg hover:border-pink-400 transition">
                                            <i class="fas fa-microphone text-gray-400 ml-2"></i>
                                            <span class="text-sm text-gray-600">رفع ملف صوتي</span>
                                        </div>
                                        <input type="file" class="hidden" accept="audio/*" onchange="uploadAudio(this, 'front')">
                                    </label>
                                </div>
                                <!-- URL Option -->
                                <input type="url" id="front_audio_url" name="front_audio_url" dir="ltr"
                                       class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500 text-left text-sm"
                                       placeholder="أو أدخل رابط الصوت https://...">
                                <!-- Preview -->
                                <div id="front_audio_preview" class="hidden">
                                    <div class="flex items-center gap-2 p-2 bg-gray-100 rounded-lg">
                                        <audio id="front_audio_player" controls class="h-8 flex-1"></audio>
                                        <button type="button" onclick="removeAudio('front')" class="w-6 h-6 bg-red-500 text-white rounded-full text-xs hover:bg-red-600">
                                            <i class="fas fa-times"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- Back Audio -->
                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-1 text-right">صوت الوجه الخلفي</label>
                            <div class="space-y-2">
                                <!-- Upload Option -->
                                <div class="flex items-center gap-2">
                                    <label class="flex-1 cursor-pointer">
                                        <div class="flex items-center justify-center px-4 py-3 border-2 border-dashed border-gray-300 rounded-lg hover:border-pink-400 transition">
                                            <i class="fas fa-microphone text-gray-400 ml-2"></i>
                                            <span class="text-sm text-gray-600">رفع ملف صوتي</span>
                                        </div>
                                        <input type="file" class="hidden" accept="audio/*" onchange="uploadAudio(this, 'back')">
                                    </label>
                                </div>
                                <!-- URL Option -->
                                <input type="url" id="back_audio_url" name="back_audio_url" dir="ltr"
                                       class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500 text-left text-sm"
                                       placeholder="أو أدخل رابط الصوت https://...">
                                <!-- Preview -->
                                <div id="back_audio_preview" class="hidden">
                                    <div class="flex items-center gap-2 p-2 bg-gray-100 rounded-lg">
                                        <audio id="back_audio_player" controls class="h-8 flex-1"></audio>
                                        <button type="button" onclick="removeAudio('back')" class="w-6 h-6 bg-red-500 text-white rounded-full text-xs hover:bg-red-600">
                                            <i class="fas fa-times"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Hint & Explanation -->
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-semibold text-gray-700 mb-1 text-right">الصعوبة</label>
                        <select id="difficulty_level" name="difficulty_level" dir="rtl"
                                class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500 text-right">
                            <option value="">تلقائي</option>
                            <option value="easy">سهل</option>
                            <option value="medium">متوسط</option>
                            <option value="hard">صعب</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-semibold text-gray-700 mb-1 text-right">تلميح</label>
                        <input type="text" id="hint_ar" name="hint_ar" dir="rtl"
                               class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500 text-right"
                               placeholder="تلميح يظهر عند الطلب">
                    </div>
                </div>

                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1 text-right">شرح إضافي</label>
                    <textarea id="explanation_ar" name="explanation_ar" rows="2" dir="rtl"
                              class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500 text-right"
                              placeholder="شرح يظهر بعد الإجابة"></textarea>
                </div>

                <div class="flex items-center justify-start gap-3 pt-4 border-t">
                    <button type="submit"
                            class="px-6 py-2 bg-gradient-to-l from-pink-500 to-pink-600 text-white rounded-lg font-bold shadow hover:shadow-lg transition">
                        <i class="fas fa-save ml-1"></i>
                        <span id="submitBtnText">إضافة</span>
                    </button>
                    <button type="button" onclick="closeCardModal()"
                            class="px-4 py-2 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-lg font-semibold transition">
                        إلغاء
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

@push('styles')
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.tailwindcss.min.css">
@endpush

@push('scripts')
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script>
const deckId = {{ $deck->id }};
let cardsTable;

$(document).ready(function() {
    cardsTable = $('#cards_table').DataTable({
        processing: true,
        serverSide: true,
        ajax: {
            url: '{{ route("admin.flashcards.index", $deck->id) }}',
            data: function(d) {
                d.type = $('#filter_type').val();
                d.difficulty = $('#filter_difficulty').val();
                d.status = $('#filter_status').val();
            }
        },
        columns: [
            { data: 'order_display', name: 'order', className: 'text-center' },
            { data: 'type', name: 'card_type', className: 'text-center' },
            { data: 'front', name: 'front_text_ar' },
            { data: 'back', name: 'back_text_ar' },
            { data: 'difficulty', name: 'difficulty_level', className: 'text-center' },
            { data: 'status', name: 'is_active', className: 'text-center' },
            { data: 'actions', name: 'actions', orderable: false, searchable: false, className: 'text-center' }
        ],
        language: {
            url: '//cdn.datatables.net/plug-ins/1.13.6/i18n/ar.json',
        },
        order: [[0, 'asc']],
        pageLength: 25,
    });

    // Filters
    $('#filter_type, #filter_difficulty, #filter_status').on('change', function() {
        cardsTable.ajax.reload();
    });

    $('#btn_reset_filters').on('click', function() {
        $('#filter_type, #filter_difficulty, #filter_status').val('');
        cardsTable.ajax.reload();
    });

    // Form submission
    $('#cardForm').on('submit', function(e) {
        e.preventDefault();
        const cardId = $('#card_id').val();
        const url = cardId
            ? `{{ url('admin/flashcard-decks') }}/${deckId}/cards/${cardId}`
            : `{{ url('admin/flashcard-decks') }}/${deckId}/cards`;
        const method = cardId ? 'PUT' : 'POST';

        $.ajax({
            url: url,
            method: method,
            data: $(this).serialize() + '&_token={{ csrf_token() }}',
            success: function(response) {
                closeCardModal();
                cardsTable.ajax.reload();
                showToast(response.message, 'success');
            },
            error: function(xhr) {
                const message = xhr.responseJSON?.message || 'حدث خطأ';
                showToast(message, 'error');
            }
        });
    });
});

function openCardModal(cardId = null) {
    resetCardForm();

    if (cardId) {
        $('#modalTitle').text('تعديل البطاقة');
        $('#submitBtnText').text('حفظ التغييرات');
        $('#card_id').val(cardId);

        // Load card data
        $.get(`{{ url('admin/flashcard-decks') }}/${deckId}/cards/${cardId}`, function(card) {
            $('#card_type').val(card.card_type);
            $('#front_text_ar').val(card.front_text_ar);
            $('#back_text_ar').val(card.back_text_ar);
            $('#cloze_template').val(card.cloze_template);
            $('#front_image_url').val(card.front_image_url);
            $('#back_image_url').val(card.back_image_url);
            $('#front_audio_url').val(card.front_audio_url);
            $('#back_audio_url').val(card.back_audio_url);
            $('#hint_ar').val(card.hint_ar);
            $('#explanation_ar').val(card.explanation_ar);
            $('#difficulty_level').val(card.difficulty_level || '');
            toggleCardTypeFields();

            // Show existing image previews
            if (card.front_image_url) {
                $('#front_image_preview_img').attr('src', card.front_image_url);
                $('#front_image_preview').removeClass('hidden');
            }
            if (card.back_image_url) {
                $('#back_image_preview_img').attr('src', card.back_image_url);
                $('#back_image_preview').removeClass('hidden');
            }

            // Show existing audio previews
            if (card.front_audio_url) {
                $('#front_audio_player').attr('src', card.front_audio_url);
                $('#front_audio_preview').removeClass('hidden');
            }
            if (card.back_audio_url) {
                $('#back_audio_player').attr('src', card.back_audio_url);
                $('#back_audio_preview').removeClass('hidden');
            }
        });
    } else {
        $('#modalTitle').text('إضافة بطاقة جديدة');
        $('#submitBtnText').text('إضافة');
    }

    $('#cardModal').removeClass('hidden');
}

function closeCardModal() {
    $('#cardModal').addClass('hidden');
    resetCardForm();
}

function resetCardForm() {
    $('#cardForm')[0].reset();
    $('#card_id').val('');
    toggleCardTypeFields();

    // Reset image previews
    removeImage('front');
    removeImage('back');

    // Reset audio previews
    removeAudio('front');
    removeAudio('back');
}

function toggleCardTypeFields() {
    const type = $('#card_type').val();

    $('#basicFields, #clozeFields, #mediaFields, #audioFields').addClass('hidden');

    switch (type) {
        case 'basic':
            $('#basicFields').removeClass('hidden');
            break;
        case 'cloze':
            $('#clozeFields').removeClass('hidden');
            break;
        case 'image':
            $('#basicFields, #mediaFields').removeClass('hidden');
            break;
        case 'audio':
            $('#basicFields, #audioFields').removeClass('hidden');
            break;
    }
}

function editCard(cardId) {
    openCardModal(cardId);
}

function deleteCard(cardId) {
    if (!confirm('هل أنت متأكد من حذف هذه البطاقة؟')) return;

    $.ajax({
        url: `{{ url('admin/flashcard-decks') }}/${deckId}/cards/${cardId}`,
        method: 'DELETE',
        data: { _token: '{{ csrf_token() }}' },
        success: function(response) {
            cardsTable.ajax.reload();
            showToast(response.message, 'success');
        },
        error: function(xhr) {
            showToast('حدث خطأ أثناء الحذف', 'error');
        }
    });
}

function showToast(message, type = 'success') {
    const bgColor = type === 'success' ? 'bg-green-500' : 'bg-red-500';
    const toast = $(`<div class="fixed bottom-4 left-4 ${bgColor} text-white px-6 py-3 rounded-lg shadow-lg z-50">${message}</div>`);
    $('body').append(toast);
    setTimeout(() => toast.remove(), 3000);
}

// ========== File Upload Functions ==========

function uploadImage(input, type) {
    if (!input.files || !input.files[0]) return;

    const file = input.files[0];

    // Validate file size (5MB max)
    if (file.size > 5 * 1024 * 1024) {
        showToast('حجم الصورة يجب أن يكون أقل من 5 ميجابايت', 'error');
        input.value = '';
        return;
    }

    // Validate file type
    if (!file.type.startsWith('image/')) {
        showToast('يرجى اختيار ملف صورة صالح', 'error');
        input.value = '';
        return;
    }

    const formData = new FormData();
    formData.append('image', file);
    formData.append('type', type);
    formData.append('_token', '{{ csrf_token() }}');

    // Show loading state
    const uploadBtn = $(input).closest('label').find('div');
    const originalHtml = uploadBtn.html();
    uploadBtn.html('<i class="fas fa-spinner fa-spin text-pink-500"></i> <span class="text-sm text-pink-600">جاري الرفع...</span>');

    $.ajax({
        url: '{{ route("admin.flashcards.upload-image") }}',
        method: 'POST',
        data: formData,
        processData: false,
        contentType: false,
        success: function(response) {
            if (response.success) {
                // Set the URL in the hidden input
                $(`#${type}_image_url`).val(response.url);

                // Show preview
                $(`#${type}_image_preview_img`).attr('src', response.url);
                $(`#${type}_image_preview`).removeClass('hidden');

                showToast(response.message, 'success');
            } else {
                showToast(response.message || 'حدث خطأ أثناء رفع الصورة', 'error');
            }
        },
        error: function(xhr) {
            const message = xhr.responseJSON?.message || 'حدث خطأ أثناء رفع الصورة';
            showToast(message, 'error');
        },
        complete: function() {
            uploadBtn.html(originalHtml);
            input.value = '';
        }
    });
}

function removeImage(type) {
    $(`#${type}_image_url`).val('');
    $(`#${type}_image_preview`).addClass('hidden');
    $(`#${type}_image_preview_img`).attr('src', '');
}

function uploadAudio(input, type) {
    if (!input.files || !input.files[0]) return;

    const file = input.files[0];

    // Validate file size (10MB max)
    if (file.size > 10 * 1024 * 1024) {
        showToast('حجم الملف الصوتي يجب أن يكون أقل من 10 ميجابايت', 'error');
        input.value = '';
        return;
    }

    // Validate file type
    if (!file.type.startsWith('audio/')) {
        showToast('يرجى اختيار ملف صوتي صالح', 'error');
        input.value = '';
        return;
    }

    const formData = new FormData();
    formData.append('audio', file);
    formData.append('type', type);
    formData.append('_token', '{{ csrf_token() }}');

    // Show loading state
    const uploadBtn = $(input).closest('label').find('div');
    const originalHtml = uploadBtn.html();
    uploadBtn.html('<i class="fas fa-spinner fa-spin text-pink-500"></i> <span class="text-sm text-pink-600">جاري الرفع...</span>');

    $.ajax({
        url: '{{ route("admin.flashcards.upload-audio") }}',
        method: 'POST',
        data: formData,
        processData: false,
        contentType: false,
        success: function(response) {
            if (response.success) {
                // Set the URL in the hidden input
                $(`#${type}_audio_url`).val(response.url);

                // Show preview with audio player
                $(`#${type}_audio_player`).attr('src', response.url);
                $(`#${type}_audio_preview`).removeClass('hidden');

                showToast(response.message, 'success');
            } else {
                showToast(response.message || 'حدث خطأ أثناء رفع الملف الصوتي', 'error');
            }
        },
        error: function(xhr) {
            const message = xhr.responseJSON?.message || 'حدث خطأ أثناء رفع الملف الصوتي';
            showToast(message, 'error');
        },
        complete: function() {
            uploadBtn.html(originalHtml);
            input.value = '';
        }
    });
}

function removeAudio(type) {
    $(`#${type}_audio_url`).val('');
    $(`#${type}_audio_preview`).addClass('hidden');
    $(`#${type}_audio_player`).attr('src', '');
}

// Update image/audio previews when URL is entered manually
$('#front_image_url, #back_image_url').on('change', function() {
    const type = this.id.includes('front') ? 'front' : 'back';
    const url = $(this).val();
    if (url) {
        $(`#${type}_image_preview_img`).attr('src', url);
        $(`#${type}_image_preview`).removeClass('hidden');
    } else {
        $(`#${type}_image_preview`).addClass('hidden');
    }
});

$('#front_audio_url, #back_audio_url').on('change', function() {
    const type = this.id.includes('front') ? 'front' : 'back';
    const url = $(this).val();
    if (url) {
        $(`#${type}_audio_player`).attr('src', url);
        $(`#${type}_audio_preview`).removeClass('hidden');
    } else {
        $(`#${type}_audio_preview`).addClass('hidden');
    }
});
</script>
@endpush
@endsection
