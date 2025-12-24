@extends('layouts.admin')

@section('title', 'إدارة الإشعارات')

@section('content')
<div class="min-h-screen bg-gray-50">
    <div class="px-4 sm:px-6 lg:px-8 py-8">
        <!-- Header -->
        <div class="mb-8">
            <div class="flex justify-between items-center mb-4">
                <div>
                    <h1 class="text-3xl font-bold text-gray-900">إدارة الإشعارات</h1>
                    <p class="text-gray-600 mt-1">عرض وإدارة جميع الإشعارات المرسلة</p>
                </div>
                <div class="flex gap-3">
                    <a href="{{ route('admin.notifications.broadcast') }}" class="bg-gradient-to-r from-purple-600 to-indigo-600 hover:from-purple-700 hover:to-indigo-700 text-white px-6 py-3 rounded-lg shadow-md font-semibold">
                        <i class="fas fa-paper-plane ml-2"></i>
                        إرسال إشعار جماعي
                    </a>
                    <a href="{{ route('admin.notifications.statistics') }}" class="bg-green-600 hover:bg-green-700 text-white px-6 py-3 rounded-lg shadow-md font-semibold">
                        <i class="fas fa-chart-bar ml-2"></i>
                        الإحصائيات
                    </a>
                    <a href="{{ route('admin.notifications.settings') }}" class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg shadow-md font-semibold">
                        <i class="fas fa-cog ml-2"></i>
                        إعدادات المستخدمين
                    </a>
                </div>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
            <div class="bg-white rounded-xl shadow-md p-6 border-r-4 border-blue-500">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-gray-600 text-sm font-semibold">إجمالي الإشعارات</p>
                        <p class="text-3xl font-bold text-gray-900 mt-2">{{ number_format($stats['total']) }}</p>
                    </div>
                    <div class="bg-blue-100 p-4 rounded-full">
                        <i class="fas fa-bell text-blue-600 text-2xl"></i>
                    </div>
                </div>
            </div>

            <div class="bg-white rounded-xl shadow-md p-6 border-r-4 border-yellow-500">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-gray-600 text-sm font-semibold">قيد الانتظار</p>
                        <p class="text-3xl font-bold text-gray-900 mt-2">{{ number_format($stats['pending']) }}</p>
                    </div>
                    <div class="bg-yellow-100 p-4 rounded-full">
                        <i class="fas fa-clock text-yellow-600 text-2xl"></i>
                    </div>
                </div>
            </div>

            <div class="bg-white rounded-xl shadow-md p-6 border-r-4 border-green-500">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-gray-600 text-sm font-semibold">تم الإرسال</p>
                        <p class="text-3xl font-bold text-gray-900 mt-2">{{ number_format($stats['sent']) }}</p>
                    </div>
                    <div class="bg-green-100 p-4 rounded-full">
                        <i class="fas fa-check-circle text-green-600 text-2xl"></i>
                    </div>
                </div>
            </div>

            <div class="bg-white rounded-xl shadow-md p-6 border-r-4 border-red-500">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-gray-600 text-sm font-semibold">فشل الإرسال</p>
                        <p class="text-3xl font-bold text-gray-900 mt-2">{{ number_format($stats['failed']) }}</p>
                    </div>
                    <div class="bg-red-100 p-4 rounded-full">
                        <i class="fas fa-times-circle text-red-600 text-2xl"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Filters -->
        <div class="bg-white rounded-xl shadow-md p-6 mb-8">
            <form method="GET" action="{{ route('admin.notifications.index') }}" class="grid grid-cols-1 md:grid-cols-4 gap-4">
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">البحث</label>
                    <input type="text" name="search" value="{{ request('search') }}" placeholder="اسم المستخدم أو البريد..." class="w-full px-4 py-2.5 border-2 border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                </div>

                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">الحالة</label>
                    <select name="status" class="w-full px-4 py-2.5 border-2 border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                        <option value="">الكل</option>
                        <option value="pending" {{ request('status') == 'pending' ? 'selected' : '' }}>قيد الانتظار</option>
                        <option value="sent" {{ request('status') == 'sent' ? 'selected' : '' }}>تم الإرسال</option>
                        <option value="failed" {{ request('status') == 'failed' ? 'selected' : '' }}>فشل</option>
                    </select>
                </div>

                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">النوع</label>
                    <select name="type" class="w-full px-4 py-2.5 border-2 border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                        <option value="">الكل</option>
                        <option value="study_reminder" {{ request('type') == 'study_reminder' ? 'selected' : '' }}>تذكير دراسي</option>
                        <option value="exam_alert" {{ request('type') == 'exam_alert' ? 'selected' : '' }}>تنبيه امتحان</option>
                        <option value="daily_summary" {{ request('type') == 'daily_summary' ? 'selected' : '' }}>ملخص يومي</option>
                        <option value="course_update" {{ request('type') == 'course_update' ? 'selected' : '' }}>تحديث دورة</option>
                        <option value="achievement" {{ request('type') == 'achievement' ? 'selected' : '' }}>إنجاز</option>
                        <option value="system" {{ request('type') == 'system' ? 'selected' : '' }}>نظام</option>
                    </select>
                </div>

                <div class="flex items-end gap-2">
                    <button type="submit" class="flex-1 bg-blue-600 hover:bg-blue-700 text-white px-6 py-2.5 rounded-lg font-semibold">
                        <i class="fas fa-search ml-2"></i>
                        بحث
                    </button>
                    <a href="{{ route('admin.notifications.index') }}" class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-6 py-2.5 rounded-lg font-semibold">
                        <i class="fas fa-redo ml-2"></i>
                        إعادة تعيين
                    </a>
                </div>
            </form>
        </div>

        <!-- Notifications Table -->
        <div class="bg-white rounded-xl shadow-md overflow-hidden">
            <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase">المستخدم</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase">النوع</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase">العنوان</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase">الحالة</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase">الأولوية</th>
                            <th class="px-6 py-4 text-right text-xs font-bold text-gray-700 uppercase">التاريخ</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                        @forelse($notifications as $notification)
                        <tr class="hover:bg-gray-50">
                            <td class="px-6 py-4 whitespace-nowrap">
                                <div class="flex items-center">
                                    <div>
                                        <div class="text-sm font-semibold text-gray-900">{{ $notification->user->name }}</div>
                                        <div class="text-sm text-gray-500">{{ $notification->user->email }}</div>
                                    </div>
                                </div>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                @php
                                    $typeColors = [
                                        'study_reminder' => 'bg-blue-100 text-blue-800',
                                        'exam_alert' => 'bg-red-100 text-red-800',
                                        'daily_summary' => 'bg-green-100 text-green-800',
                                        'course_update' => 'bg-purple-100 text-purple-800',
                                        'achievement' => 'bg-yellow-100 text-yellow-800',
                                        'system' => 'bg-gray-100 text-gray-800',
                                    ];
                                    $typeLabels = [
                                        'study_reminder' => 'تذكير دراسي',
                                        'exam_alert' => 'تنبيه امتحان',
                                        'daily_summary' => 'ملخص يومي',
                                        'course_update' => 'تحديث دورة',
                                        'achievement' => 'إنجاز',
                                        'system' => 'نظام',
                                    ];
                                @endphp
                                <span class="px-3 py-1 inline-flex text-xs font-semibold rounded-full {{ $typeColors[$notification->type] ?? 'bg-gray-100 text-gray-800' }}">
                                    {{ $typeLabels[$notification->type] ?? $notification->type }}
                                </span>
                            </td>
                            <td class="px-6 py-4">
                                <div class="text-sm font-semibold text-gray-900">{{ $notification->title_ar }}</div>
                                <div class="text-sm text-gray-500">{{ Str::limit($notification->body_ar, 50) }}</div>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                @php
                                    $statusColors = [
                                        'pending' => 'bg-yellow-100 text-yellow-800',
                                        'sent' => 'bg-green-100 text-green-800',
                                        'failed' => 'bg-red-100 text-red-800',
                                    ];
                                    $statusLabels = [
                                        'pending' => 'قيد الانتظار',
                                        'sent' => 'تم الإرسال',
                                        'failed' => 'فشل',
                                    ];
                                @endphp
                                <span class="px-3 py-1 inline-flex text-xs font-semibold rounded-full {{ $statusColors[$notification->status] ?? 'bg-gray-100 text-gray-800' }}">
                                    {{ $statusLabels[$notification->status] ?? $notification->status }}
                                </span>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                @php
                                    $priorityColors = [
                                        'low' => 'bg-gray-100 text-gray-800',
                                        'normal' => 'bg-blue-100 text-blue-800',
                                        'high' => 'bg-red-100 text-red-800',
                                    ];
                                    $priorityLabels = [
                                        'low' => 'منخفضة',
                                        'normal' => 'عادية',
                                        'high' => 'عالية',
                                    ];
                                @endphp
                                <span class="px-3 py-1 inline-flex text-xs font-semibold rounded-full {{ $priorityColors[$notification->priority] ?? 'bg-gray-100 text-gray-800' }}">
                                    {{ $priorityLabels[$notification->priority] ?? $notification->priority }}
                                </span>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                <div>{{ $notification->created_at->format('Y-m-d') }}</div>
                                <div>{{ $notification->created_at->format('H:i') }}</div>
                            </td>
                        </tr>
                        @empty
                        <tr>
                            <td colspan="6" class="px-6 py-12 text-center">
                                <div class="text-gray-400">
                                    <i class="fas fa-bell-slash text-6xl mb-4"></i>
                                    <p class="text-xl font-semibold">لا توجد إشعارات</p>
                                </div>
                            </td>
                        </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>

            <!-- Pagination -->
            @if($notifications->hasPages())
            <div class="bg-gray-50 px-6 py-4 border-t border-gray-200">
                {{ $notifications->links() }}
            </div>
            @endif
        </div>
    </div>
</div>
@endsection
