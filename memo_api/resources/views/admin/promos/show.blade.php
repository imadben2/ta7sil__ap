@extends('layouts.admin')

@section('title', 'عرض العرض الترويجي')
@section('page-title', 'تفاصيل العرض الترويجي')
@section('page-description', 'عرض تفاصيل "{{ $promo->title }}"')

@section('content')
<div class="max-w-4xl mx-auto space-y-6">

    <!-- Preview Card -->
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
        <h3 class="text-lg font-bold text-gray-900 mb-6 flex items-center gap-2">
            <i class="fas fa-eye text-blue-500"></i>
            معاينة العرض
        </h3>

        @php
            $gradientColors = $promo->gradient_colors ?? ['#3B82F6', '#1D4ED8'];
            $gradient = "linear-gradient(135deg, {$gradientColors[0]}, {$gradientColors[1]})";
        @endphp

        <!-- Promo Preview Card -->
        <div class="rounded-2xl p-6 text-white relative overflow-hidden" style="background: {{ $gradient }};">
            <!-- Decorative circles -->
            <div class="absolute -top-10 -right-10 w-40 h-40 bg-white/10 rounded-full"></div>
            <div class="absolute -bottom-5 -left-5 w-24 h-24 bg-white/10 rounded-full"></div>

            <div class="relative z-10">
                <div class="flex items-start justify-between">
                    <div class="flex-1">
                        @if($promo->badge)
                            <span class="inline-block px-3 py-1 text-xs font-bold rounded-full bg-white/20 backdrop-blur-sm mb-3">
                                {{ $promo->badge }}
                            </span>
                        @endif

                        <h2 class="text-2xl font-bold mb-2">{{ $promo->title }}</h2>

                        @if($promo->subtitle)
                            <p class="text-white/80 mb-4">{{ $promo->subtitle }}</p>
                        @endif

                        @if($promo->action_text && $promo->action_type !== 'none')
                            <button class="px-6 py-2.5 bg-white/20 backdrop-blur-sm rounded-xl font-semibold hover:bg-white/30 transition-colors">
                                {{ $promo->action_text }}
                                <i class="fas fa-arrow-left mr-2"></i>
                            </button>
                        @endif
                    </div>

                    <div class="w-20 h-20 bg-white/20 rounded-2xl flex items-center justify-center">
                        @if($promo->image_url)
                            <img src="{{ $promo->image_url }}" alt="" class="w-16 h-16 object-cover rounded-xl">
                        @elseif($promo->icon_name)
                            @php
                                $iconMap = [
                                    'school' => 'school',
                                    'emoji_events' => 'trophy',
                                    'assignment' => 'clipboard-list',
                                    'people' => 'users',
                                    'calendar_month' => 'calendar-alt',
                                    'celebration' => 'gift',
                                    'star' => 'star',
                                    'bolt' => 'bolt',
                                    'rocket' => 'rocket',
                                    'book' => 'book',
                                ];
                                $iconClass = $iconMap[$promo->icon_name] ?? 'bullhorn';
                            @endphp
                            <i class="fas fa-{{ $iconClass }} text-4xl"></i>
                        @else
                            <i class="fas fa-bullhorn text-4xl"></i>
                        @endif
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Details Card -->
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
        <h3 class="text-lg font-bold text-gray-900 mb-6 flex items-center gap-2">
            <i class="fas fa-info-circle text-purple-500"></i>
            تفاصيل العرض
        </h3>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
                <label class="text-sm text-gray-500">العنوان</label>
                <p class="font-semibold text-gray-900">{{ $promo->title }}</p>
            </div>

            <div>
                <label class="text-sm text-gray-500">العنوان الفرعي</label>
                <p class="font-semibold text-gray-900">{{ $promo->subtitle ?? '-' }}</p>
            </div>

            <div>
                <label class="text-sm text-gray-500">الشارة</label>
                @if($promo->badge)
                    <p><span class="px-3 py-1 text-xs font-medium rounded-full text-white" style="background: {{ $gradientColors[0] }}">{{ $promo->badge }}</span></p>
                @else
                    <p class="text-gray-400">-</p>
                @endif
            </div>

            <div>
                <label class="text-sm text-gray-500">نص الزر</label>
                <p class="font-semibold text-gray-900">{{ $promo->action_text ?? '-' }}</p>
            </div>

            <div>
                <label class="text-sm text-gray-500">نوع الإجراء</label>
                <p>
                    @switch($promo->action_type)
                        @case('route')
                            <span class="px-2 py-1 text-xs rounded bg-blue-100 text-blue-700">مسار داخلي</span>
                            @break
                        @case('url')
                            <span class="px-2 py-1 text-xs rounded bg-green-100 text-green-700">رابط خارجي</span>
                            @break
                        @default
                            <span class="px-2 py-1 text-xs rounded bg-gray-100 text-gray-700">بدون إجراء</span>
                    @endswitch
                </p>
            </div>

            <div>
                <label class="text-sm text-gray-500">قيمة الإجراء</label>
                <p class="font-semibold text-gray-900 break-all" dir="ltr">{{ $promo->action_value ?? '-' }}</p>
            </div>

            <div>
                <label class="text-sm text-gray-500">الأيقونة</label>
                <p class="font-semibold text-gray-900">{{ $promo->icon_name ?? '-' }}</p>
            </div>

            <div>
                <label class="text-sm text-gray-500">رابط الصورة</label>
                <p class="font-semibold text-gray-900 break-all" dir="ltr">{{ $promo->image_url ?? '-' }}</p>
            </div>

            <div>
                <label class="text-sm text-gray-500">ألوان التدرج</label>
                <div class="flex items-center gap-2 mt-1">
                    <div class="w-6 h-6 rounded border" style="background: {{ $gradientColors[0] }}"></div>
                    <span class="font-mono text-sm" dir="ltr">{{ $gradientColors[0] }}</span>
                    <i class="fas fa-arrow-left text-gray-400 mx-2"></i>
                    <div class="w-6 h-6 rounded border" style="background: {{ $gradientColors[1] }}"></div>
                    <span class="font-mono text-sm" dir="ltr">{{ $gradientColors[1] }}</span>
                </div>
            </div>
        </div>
    </div>

    <!-- Settings & Statistics Card -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <!-- Settings -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
            <h3 class="text-lg font-bold text-gray-900 mb-6 flex items-center gap-2">
                <i class="fas fa-cog text-gray-500"></i>
                الإعدادات
            </h3>

            <div class="space-y-4">
                <div class="flex justify-between items-center py-2 border-b border-gray-100">
                    <span class="text-gray-600">الحالة</span>
                    @if($promo->isCurrentlyActive())
                        <span class="px-3 py-1 text-xs font-medium rounded-full bg-green-100 text-green-700">
                            <i class="fas fa-check-circle ml-1"></i> نشط
                        </span>
                    @elseif(!$promo->is_active)
                        <span class="px-3 py-1 text-xs font-medium rounded-full bg-red-100 text-red-700">
                            <i class="fas fa-times-circle ml-1"></i> معطل
                        </span>
                    @else
                        <span class="px-3 py-1 text-xs font-medium rounded-full bg-yellow-100 text-yellow-700">
                            <i class="fas fa-clock ml-1"></i> مجدول
                        </span>
                    @endif
                </div>

                <div class="flex justify-between items-center py-2 border-b border-gray-100">
                    <span class="text-gray-600">ترتيب العرض</span>
                    <span class="font-semibold text-gray-900">{{ $promo->display_order }}</span>
                </div>

                <div class="flex justify-between items-center py-2 border-b border-gray-100">
                    <span class="text-gray-600">تاريخ البدء</span>
                    <span class="font-semibold text-gray-900">{{ $promo->starts_at?->format('Y-m-d H:i') ?? 'دائم' }}</span>
                </div>

                <div class="flex justify-between items-center py-2">
                    <span class="text-gray-600">تاريخ الانتهاء</span>
                    <span class="font-semibold text-gray-900">{{ $promo->ends_at?->format('Y-m-d H:i') ?? 'دائم' }}</span>
                </div>
            </div>
        </div>

        <!-- Statistics -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
            <h3 class="text-lg font-bold text-gray-900 mb-6 flex items-center gap-2">
                <i class="fas fa-chart-bar text-blue-500"></i>
                الإحصائيات
            </h3>

            <div class="space-y-4">
                <div class="flex justify-between items-center py-2 border-b border-gray-100">
                    <span class="text-gray-600">إجمالي النقرات</span>
                    <span class="text-2xl font-bold text-blue-600">{{ number_format($promo->click_count) }}</span>
                </div>

                <div class="flex justify-between items-center py-2 border-b border-gray-100">
                    <span class="text-gray-600">تاريخ الإنشاء</span>
                    <span class="font-semibold text-gray-900">{{ $promo->created_at->format('Y-m-d H:i') }}</span>
                </div>

                <div class="flex justify-between items-center py-2">
                    <span class="text-gray-600">آخر تحديث</span>
                    <span class="font-semibold text-gray-900">{{ $promo->updated_at->format('Y-m-d H:i') }}</span>
                </div>
            </div>
        </div>
    </div>

    <!-- Action Buttons -->
    <div class="flex items-center justify-between">
        <a href="{{ route('admin.promos.index') }}"
           class="px-6 py-3 border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors">
            <i class="fas fa-arrow-right ml-2"></i>
            رجوع للقائمة
        </a>
        <div class="flex gap-3">
            <button onclick="toggleStatus({{ $promo->id }})"
                    class="px-6 py-3 {{ $promo->is_active ? 'bg-red-100 text-red-700 hover:bg-red-200' : 'bg-green-100 text-green-700 hover:bg-green-200' }} rounded-xl transition-colors">
                <i class="fas {{ $promo->is_active ? 'fa-toggle-off' : 'fa-toggle-on' }} ml-2"></i>
                {{ $promo->is_active ? 'تعطيل' : 'تفعيل' }}
            </button>
            <a href="{{ route('admin.promos.edit', $promo) }}"
               class="px-8 py-3 bg-gradient-to-l from-blue-600 to-purple-600 text-white rounded-xl hover:from-blue-700 hover:to-purple-700 transition-all shadow-lg shadow-blue-500/25">
                <i class="fas fa-edit ml-2"></i>
                تعديل
            </a>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
function toggleStatus(id) {
    $.ajax({
        url: '/admin/promos/' + id + '/toggle-status',
        method: 'POST',
        data: {
            _token: '{{ csrf_token() }}'
        },
        success: function(response) {
            if (response.success) {
                location.reload();
            }
        },
        error: function() {
            alert('حدث خطأ أثناء تحديث الحالة');
        }
    });
}
</script>
@endpush
