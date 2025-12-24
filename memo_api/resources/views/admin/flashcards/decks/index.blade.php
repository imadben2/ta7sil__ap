@extends('layouts.admin')

@section('title', 'إدارة البطاقات التعليمية')

@section('content')
<div class="p-6">
    <!-- Header -->
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-6">
        <div>
            <h1 class="text-2xl font-bold text-gray-900">البطاقات التعليمية</h1>
            <p class="text-gray-600 mt-1">إدارة مجموعات البطاقات التعليمية بنظام التكرار المتباعد</p>
        </div>
        <a href="{{ route('admin.flashcard-decks.create') }}"
           class="inline-flex items-center gap-2 px-5 py-2.5 bg-gradient-to-l from-pink-500 to-pink-600 text-white rounded-xl font-bold shadow-lg hover:shadow-xl transition-all">
            <i class="fas fa-plus"></i>
            إنشاء مجموعة جديدة
        </a>
    </div>

    <!-- Statistics Cards -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div class="bg-white rounded-xl shadow-sm p-5 border-r-4 border-pink-500">
            <div class="flex items-center gap-4">
                <div class="w-12 h-12 bg-pink-100 rounded-xl flex items-center justify-center">
                    <i class="fas fa-layer-group text-pink-600 text-xl"></i>
                </div>
                <div>
                    <p class="text-gray-500 text-sm">إجمالي المجموعات</p>
                    <p class="text-2xl font-bold text-gray-900">{{ number_format($stats['total_decks']) }}</p>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm p-5 border-r-4 border-green-500">
            <div class="flex items-center gap-4">
                <div class="w-12 h-12 bg-green-100 rounded-xl flex items-center justify-center">
                    <i class="fas fa-check-circle text-green-600 text-xl"></i>
                </div>
                <div>
                    <p class="text-gray-500 text-sm">المنشورة</p>
                    <p class="text-2xl font-bold text-gray-900">{{ number_format($stats['published_decks']) }}</p>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm p-5 border-r-4 border-blue-500">
            <div class="flex items-center gap-4">
                <div class="w-12 h-12 bg-blue-100 rounded-xl flex items-center justify-center">
                    <i class="fas fa-clone text-blue-600 text-xl"></i>
                </div>
                <div>
                    <p class="text-gray-500 text-sm">إجمالي البطاقات</p>
                    <p class="text-2xl font-bold text-gray-900">{{ number_format($stats['total_cards']) }}</p>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm p-5 border-r-4 border-purple-500">
            <div class="flex items-center gap-4">
                <div class="w-12 h-12 bg-purple-100 rounded-xl flex items-center justify-center">
                    <i class="fas fa-sync text-purple-600 text-xl"></i>
                </div>
                <div>
                    <p class="text-gray-500 text-sm">جلسات المراجعة</p>
                    <p class="text-2xl font-bold text-gray-900">{{ number_format($stats['total_reviews']) }}</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Filters -->
    <div class="bg-white rounded-xl shadow-sm p-4 mb-6">
        <div class="grid grid-cols-1 md:grid-cols-5 gap-4">
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">المادة</label>
                <select id="filter_subject" class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500">
                    <option value="">كل المواد</option>
                    @foreach($subjects as $subject)
                        <option value="{{ $subject->id }}">{{ $subject->name_ar }}</option>
                    @endforeach
                </select>
            </div>

            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">الشعبة</label>
                <select id="filter_stream" class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500">
                    <option value="">كل الشعب</option>
                    @foreach($streams as $stream)
                        <option value="{{ $stream->id }}">{{ $stream->name_ar }}</option>
                    @endforeach
                </select>
            </div>

            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">الصعوبة</label>
                <select id="filter_difficulty" class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500">
                    <option value="">كل المستويات</option>
                    <option value="easy">سهل</option>
                    <option value="medium">متوسط</option>
                    <option value="hard">صعب</option>
                </select>
            </div>

            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">الحالة</label>
                <select id="filter_status" class="w-full rounded-lg border-gray-300 focus:border-pink-500 focus:ring-pink-500">
                    <option value="">الكل</option>
                    <option value="published">منشور</option>
                    <option value="draft">مسودة</option>
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
        <table id="decks_table" class="w-full">
            <thead class="bg-gray-50 border-b">
                <tr>
                    <th class="px-4 py-3 text-right text-xs font-bold text-gray-600 uppercase">العنوان</th>
                    <th class="px-4 py-3 text-right text-xs font-bold text-gray-600 uppercase">المادة</th>
                    <th class="px-4 py-3 text-right text-xs font-bold text-gray-600 uppercase">الشعبة</th>
                    <th class="px-4 py-3 text-center text-xs font-bold text-gray-600 uppercase">الصعوبة</th>
                    <th class="px-4 py-3 text-center text-xs font-bold text-gray-600 uppercase">البطاقات</th>
                    <th class="px-4 py-3 text-center text-xs font-bold text-gray-600 uppercase">الحالة</th>
                    <th class="px-4 py-3 text-center text-xs font-bold text-gray-600 uppercase">إجراءات</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>
</div>

@push('styles')
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.tailwindcss.min.css">
@endpush

@push('scripts')
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script>
$(document).ready(function() {
    const table = $('#decks_table').DataTable({
        processing: true,
        serverSide: true,
        ajax: {
            url: '{{ route("admin.flashcard-decks.index") }}',
            data: function(d) {
                d.subject_id = $('#filter_subject').val();
                d.stream_id = $('#filter_stream').val();
                d.difficulty = $('#filter_difficulty').val();
                d.status = $('#filter_status').val();
            }
        },
        columns: [
            { data: 'title', name: 'title_ar' },
            { data: 'subject', name: 'subject.name_ar' },
            { data: 'stream', name: 'academicStream.name_ar' },
            { data: 'difficulty', name: 'difficulty_level', className: 'text-center' },
            { data: 'cards', name: 'total_cards', className: 'text-center' },
            { data: 'status', name: 'is_published', className: 'text-center' },
            { data: 'actions', name: 'actions', orderable: false, searchable: false, className: 'text-center' }
        ],
        language: {
            url: '//cdn.datatables.net/plug-ins/1.13.6/i18n/ar.json',
        },
        order: [[0, 'asc']],
        pageLength: 25,
    });

    // Filters
    $('#filter_subject, #filter_stream, #filter_difficulty, #filter_status').on('change', function() {
        table.ajax.reload();
    });

    $('#btn_reset_filters').on('click', function() {
        $('#filter_subject, #filter_stream, #filter_difficulty, #filter_status').val('');
        table.ajax.reload();
    });
});
</script>
@endpush
@endsection
