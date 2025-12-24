@extends('layouts.admin')

@section('title', 'إحصائيات الإشعارات')

@section('content')
<div class="min-h-screen bg-gray-50">
    <div class="px-4 sm:px-6 lg:px-8 py-8">
        <!-- Header -->
        <div class="mb-8">
            <div class="flex justify-between items-center mb-4">
                <div>
                    <h1 class="text-3xl font-bold text-gray-900">إحصائيات الإشعارات</h1>
                    <p class="text-gray-600 mt-1">تحليل شامل لنظام الإشعارات</p>
                </div>
                <a href="{{ route('admin.notifications.index') }}" class="bg-gray-600 hover:bg-gray-700 text-white px-6 py-3 rounded-lg shadow-md font-semibold">
                    <i class="fas fa-arrow-right ml-2"></i>
                    العودة
                </a>
            </div>
        </div>

        <!-- Main Stats -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <div class="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl shadow-md p-6 text-white">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-blue-100 text-sm font-semibold">إجمالي الإشعارات</p>
                        <p class="text-4xl font-bold mt-2">{{ number_format($stats['total_notifications']) }}</p>
                    </div>
                    <div class="bg-white bg-opacity-20 p-4 rounded-full">
                        <i class="fas fa-bell text-3xl"></i>
                    </div>
                </div>
            </div>

            <div class="bg-gradient-to-br from-green-500 to-green-600 rounded-xl shadow-md p-6 text-white">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-green-100 text-sm font-semibold">تم الإرسال اليوم</p>
                        <p class="text-4xl font-bold mt-2">{{ number_format($stats['sent_today']) }}</p>
                    </div>
                    <div class="bg-white bg-opacity-20 p-4 rounded-full">
                        <i class="fas fa-paper-plane text-3xl"></i>
                    </div>
                </div>
            </div>

            <div class="bg-gradient-to-br from-yellow-500 to-yellow-600 rounded-xl shadow-md p-6 text-white">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-yellow-100 text-sm font-semibold">قيد الانتظار</p>
                        <p class="text-4xl font-bold mt-2">{{ number_format($stats['pending']) }}</p>
                    </div>
                    <div class="bg-white bg-opacity-20 p-4 rounded-full">
                        <i class="fas fa-clock text-3xl"></i>
                    </div>
                </div>
            </div>

            <div class="bg-gradient-to-br from-red-500 to-red-600 rounded-xl shadow-md p-6 text-white">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-red-100 text-sm font-semibold">فشل الإرسال</p>
                        <p class="text-4xl font-bold mt-2">{{ number_format($stats['failed']) }}</p>
                    </div>
                    <div class="bg-white bg-opacity-20 p-4 rounded-full">
                        <i class="fas fa-exclamation-triangle text-3xl"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Notifications by Type -->
        <div class="bg-white rounded-xl shadow-md p-6 mb-8">
            <h2 class="text-2xl font-bold text-gray-900 mb-6">
                <i class="fas fa-chart-pie ml-2 text-blue-600"></i>
                الإشعارات حسب النوع
            </h2>

            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                @php
                    $typeInfo = [
                        'study_reminder' => ['label' => 'تذكير دراسي', 'icon' => 'book-reader', 'color' => 'blue'],
                        'exam_alert' => ['label' => 'تنبيه امتحان', 'icon' => 'graduation-cap', 'color' => 'red'],
                        'daily_summary' => ['label' => 'ملخص يومي', 'icon' => 'calendar-day', 'color' => 'green'],
                        'course_update' => ['label' => 'تحديث دورة', 'icon' => 'chalkboard-teacher', 'color' => 'purple'],
                        'achievement' => ['label' => 'إنجاز', 'icon' => 'trophy', 'color' => 'yellow'],
                        'system' => ['label' => 'نظام', 'icon' => 'cog', 'color' => 'gray'],
                    ];
                @endphp

                @foreach($typeInfo as $type => $info)
                <div class="bg-{{ $info['color'] }}-50 border-2 border-{{ $info['color'] }}-200 rounded-xl p-6">
                    <div class="flex items-center justify-between mb-4">
                        <div class="bg-{{ $info['color'] }}-100 p-3 rounded-full">
                            <i class="fas fa-{{ $info['icon'] }} text-{{ $info['color'] }}-600 text-2xl"></i>
                        </div>
                        <div class="text-left">
                            <p class="text-3xl font-bold text-{{ $info['color'] }}-900">
                                {{ number_format($stats['by_type'][$type] ?? 0) }}
                            </p>
                        </div>
                    </div>
                    <p class="text-{{ $info['color'] }}-800 font-semibold">{{ $info['label'] }}</p>
                </div>
                @endforeach
            </div>
        </div>

        <!-- User Settings Stats -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="bg-white rounded-xl shadow-md p-6">
                <h3 class="text-xl font-bold text-gray-900 mb-4">
                    <i class="fas fa-bell-slash ml-2 text-red-600"></i>
                    مستخدمون معطلة الإشعارات
                </h3>
                <div class="flex items-end gap-4">
                    <p class="text-5xl font-bold text-red-600">{{ number_format($stats['users_with_notifications_disabled']) }}</p>
                    <p class="text-gray-600 mb-2">مستخدم</p>
                </div>
            </div>

            <div class="bg-white rounded-xl shadow-md p-6">
                <h3 class="text-xl font-bold text-gray-900 mb-4">
                    <i class="fas fa-moon ml-2 text-indigo-600"></i>
                    مستخدمون مع ساعات هدوء
                </h3>
                <div class="flex items-end gap-4">
                    <p class="text-5xl font-bold text-indigo-600">{{ number_format($stats['users_with_quiet_hours']) }}</p>
                    <p class="text-gray-600 mb-2">مستخدم</p>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
