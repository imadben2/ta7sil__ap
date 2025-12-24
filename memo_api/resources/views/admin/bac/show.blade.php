@extends('layouts.admin')

@section('title', 'تفاصيل موضوع البكالوريا')
@section('page-title', $bacSubject->title_ar)
@section('page-description', 'عرض تفاصيل الموضوع')

@section('content')
<div class="space-y-6">
    <!-- Header Actions -->
    <div class="flex items-center justify-between">
        <a href="{{ route('admin.bac.index') }}" class="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors">
            <i class="fas fa-arrow-right mr-2"></i>
            العودة إلى القائمة
        </a>
        <div class="flex gap-2">
            <a href="{{ route('admin.bac.edit', $bacSubject->id) }}" class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
                <i class="fas fa-edit mr-2"></i>
                تعديل
            </a>
            <form method="POST" action="{{ route('admin.bac.destroy', $bacSubject->id) }}"
                  onsubmit="return confirm('هل أنت متأكد من حذف هذا الموضوع؟')" class="inline">
                @csrf
                @method('DELETE')
                <button type="submit" class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors">
                    <i class="fas fa-trash mr-2"></i>
                    حذف
                </button>
            </form>
        </div>
    </div>

    <!-- Basic Information -->
    <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-6">
            <i class="fas fa-info-circle text-blue-600 mr-2"></i>
            المعلومات الأساسية
        </h3>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
                <label class="block text-sm font-medium text-gray-500 mb-1">السنة</label>
                <p class="text-gray-900 font-medium">{{ $bacSubject->bacYear->year }}</p>
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-500 mb-1">الدورة</label>
                <p class="text-gray-900 font-medium">{{ $bacSubject->bacSession->name_ar }}</p>
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-500 mb-1">المادة</label>
                <p class="text-gray-900 font-medium">{{ $bacSubject->subject->name_ar }}</p>
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-500 mb-1">الشعبة</label>
                <p class="text-gray-900 font-medium">{{ $bacSubject->academicStream->name_ar }}</p>
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-500 mb-1">مدة الامتحان</label>
                <p class="text-gray-900 font-medium">{{ $bacSubject->duration_minutes }} دقيقة</p>
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-500 mb-1">تاريخ الإضافة</label>
                <p class="text-gray-900 font-medium">{{ $bacSubject->created_at->format('Y-m-d H:i') }}</p>
            </div>
        </div>
    </div>

    <!-- Statistics -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm font-medium text-gray-500">المشاهدات</p>
                    <p class="text-3xl font-bold text-blue-600 mt-2">{{ $bacSubject->views_count }}</p>
                </div>
                <div class="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                    <i class="fas fa-eye text-blue-600 text-xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm font-medium text-gray-500">التنزيلات</p>
                    <p class="text-3xl font-bold text-green-600 mt-2">{{ $bacSubject->downloads_count }}</p>
                </div>
                <div class="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                    <i class="fas fa-download text-green-600 text-xl"></i>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm font-medium text-gray-500">المحاكاة</p>
                    <p class="text-3xl font-bold text-purple-600 mt-2">{{ $bacSubject->simulations->count() }}</p>
                </div>
                <div class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                    <i class="fas fa-play-circle text-purple-600 text-xl"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Files -->
    <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-6">
            <i class="fas fa-file-pdf text-red-600 mr-2"></i>
            الملفات
        </h3>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <!-- Subject File -->
            <div class="border border-gray-200 rounded-lg p-4">
                <div class="flex items-start justify-between">
                    <div>
                        <p class="font-medium text-gray-900 mb-1">ملف الموضوع</p>
                        <p class="text-sm text-gray-500">{{ basename($bacSubject->file_path) }}</p>
                    </div>
                    <a href="{{ $bacSubject->getFileUrl() }}" target="_blank"
                       class="px-3 py-1 bg-blue-100 text-blue-600 rounded hover:bg-blue-200 transition-colors text-sm">
                        <i class="fas fa-external-link-alt mr-1"></i>
                        عرض
                    </a>
                </div>
            </div>

            <!-- Correction File -->
            @if($bacSubject->correction_file_path)
                <div class="border border-gray-200 rounded-lg p-4">
                    <div class="flex items-start justify-between">
                        <div>
                            <p class="font-medium text-gray-900 mb-1">ملف التصحيح</p>
                            <p class="text-sm text-gray-500">{{ basename($bacSubject->correction_file_path) }}</p>
                        </div>
                        <a href="{{ $bacSubject->getCorrectionUrl() }}" target="_blank"
                           class="px-3 py-1 bg-green-100 text-green-600 rounded hover:bg-green-200 transition-colors text-sm">
                            <i class="fas fa-external-link-alt mr-1"></i>
                            عرض
                        </a>
                    </div>
                </div>
            @else
                <div class="border border-dashed border-gray-300 rounded-lg p-4 text-center text-gray-500">
                    <i class="fas fa-times-circle text-2xl mb-2"></i>
                    <p class="text-sm">لا يوجد ملف تصحيح</p>
                </div>
            @endif
        </div>
    </div>

    <!-- Chapters -->
    <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-6">
            <i class="fas fa-book text-purple-600 mr-2"></i>
            الفصول ({{ $bacSubject->chapters->count() }})
        </h3>

        @if($bacSubject->chapters->count() > 0)
            <div class="space-y-2">
                @foreach($bacSubject->chapters as $chapter)
                    <div class="flex items-center gap-3 p-3 border border-gray-200 rounded-lg hover:bg-gray-50">
                        <span class="flex items-center justify-center w-8 h-8 bg-purple-100 text-purple-600 rounded-full text-sm font-bold flex-shrink-0">
                            {{ $chapter->order }}
                        </span>
                        <span class="text-gray-900">{{ $chapter->title_ar }}</span>
                    </div>
                @endforeach
            </div>
        @else
            <div class="text-center py-8 text-gray-500">
                <i class="fas fa-info-circle text-4xl mb-3"></i>
                <p>لا توجد فصول لهذا الموضوع</p>
            </div>
        @endif
    </div>
</div>
@endsection
