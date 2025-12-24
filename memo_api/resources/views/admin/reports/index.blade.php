@extends('layouts.admin')

@section('content')
<div class="min-h-screen bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-50 p-8">
    <div class="max-w-7xl mx-auto">
        <!-- Header -->
        <div class="mb-8">
            <h1 class="text-4xl font-bold text-gray-800 mb-2">
                <i class="fas fa-file-export text-indigo-600 ml-3"></i>
                التقارير والتصدير
            </h1>
            <p class="text-gray-600 text-lg">اختر التقرير والصيغة المناسبة للتصدير</p>
        </div>

        <!-- Report Selection Cards -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
            <!-- Export Courses Card -->
            <div class="bg-white rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 overflow-hidden border border-gray-100">
                <div class="bg-gradient-to-r from-blue-500 to-blue-600 p-6">
                    <div class="flex items-center gap-4">
                        <div class="w-14 h-14 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm">
                            <i class="fas fa-graduation-cap text-3xl text-white"></i>
                        </div>
                        <div>
                            <h2 class="text-2xl font-bold text-white">تصدير الدورات</h2>
                            <p class="text-blue-100 text-sm">جميع بيانات الدورات التعليمية</p>
                        </div>
                    </div>
                </div>
                <div class="p-6">
                    <form action="{{ route('admin.exports.courses') }}" method="GET" class="space-y-4">
                        <!-- Filters -->
                        <div class="space-y-3">
                            <div>
                                <label class="block text-sm font-semibold text-gray-700 mb-2">حالة النشر</label>
                                <select name="is_published" class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                                    <option value="">الكل</option>
                                    <option value="1">منشور</option>
                                    <option value="0">غير منشور</option>
                                </select>
                            </div>
                            <div>
                                <label class="block text-sm font-semibold text-gray-700 mb-2">النوع</label>
                                <select name="is_free" class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                                    <option value="">الكل</option>
                                    <option value="1">مجاني</option>
                                    <option value="0">مدفوع</option>
                                </select>
                            </div>
                        </div>

                        <!-- Format Selection -->
                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-3">صيغة التصدير</label>
                            <div class="grid grid-cols-3 gap-3">
                                <label class="relative">
                                    <input type="radio" name="format" value="csv" checked class="peer sr-only">
                                    <div class="px-4 py-3 border-2 border-gray-300 rounded-lg text-center cursor-pointer peer-checked:border-blue-500 peer-checked:bg-blue-50 peer-checked:text-blue-700 hover:border-blue-300 transition-all">
                                        <i class="fas fa-file-csv text-xl mb-1"></i>
                                        <p class="text-xs font-bold">CSV</p>
                                    </div>
                                </label>
                                <label class="relative">
                                    <input type="radio" name="format" value="excel" class="peer sr-only">
                                    <div class="px-4 py-3 border-2 border-gray-300 rounded-lg text-center cursor-pointer peer-checked:border-green-500 peer-checked:bg-green-50 peer-checked:text-green-700 hover:border-green-300 transition-all">
                                        <i class="fas fa-file-excel text-xl mb-1"></i>
                                        <p class="text-xs font-bold">Excel</p>
                                    </div>
                                </label>
                                <label class="relative">
                                    <input type="radio" name="format" value="pdf" class="peer sr-only">
                                    <div class="px-4 py-3 border-2 border-gray-300 rounded-lg text-center cursor-pointer peer-checked:border-red-500 peer-checked:bg-red-50 peer-checked:text-red-700 hover:border-red-300 transition-all">
                                        <i class="fas fa-file-pdf text-xl mb-1"></i>
                                        <p class="text-xs font-bold">PDF</p>
                                    </div>
                                </label>
                            </div>
                        </div>

                        <!-- Download Button -->
                        <button type="submit" class="w-full bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white font-bold py-4 rounded-lg transition-all duration-300 shadow-md hover:shadow-lg flex items-center justify-center gap-2">
                            <i class="fas fa-download"></i>
                            <span>تحميل التقرير</span>
                        </button>
                    </form>
                </div>
            </div>

            <!-- Export Subscriptions Card -->
            <div class="bg-white rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 overflow-hidden border border-gray-100">
                <div class="bg-gradient-to-r from-purple-500 to-purple-600 p-6">
                    <div class="flex items-center gap-4">
                        <div class="w-14 h-14 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm">
                            <i class="fas fa-users text-3xl text-white"></i>
                        </div>
                        <div>
                            <h2 class="text-2xl font-bold text-white">تصدير الاشتراكات</h2>
                            <p class="text-purple-100 text-sm">بيانات اشتراكات الطلاب</p>
                        </div>
                    </div>
                </div>
                <div class="p-6">
                    <form action="{{ route('admin.exports.subscriptions') }}" method="GET" class="space-y-4">
                        <!-- Filters -->
                        <div class="space-y-3">
                            <div>
                                <label class="block text-sm font-semibold text-gray-700 mb-2">حالة الاشتراك</label>
                                <select name="status" class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent">
                                    <option value="">الكل</option>
                                    <option value="active">نشط</option>
                                    <option value="inactive">غير نشط</option>
                                    <option value="pending">قيد الانتظار</option>
                                </select>
                            </div>
                            <div>
                                <label class="block text-sm font-semibold text-gray-700 mb-2">تاريخ البداية</label>
                                <input type="date" name="start_date" class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent">
                            </div>
                            <div>
                                <label class="block text-sm font-semibold text-gray-700 mb-2">تاريخ النهاية</label>
                                <input type="date" name="end_date" class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent">
                            </div>
                        </div>

                        <!-- Format Selection -->
                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-3">صيغة التصدير</label>
                            <div class="grid grid-cols-3 gap-3">
                                <label class="relative">
                                    <input type="radio" name="format" value="csv" checked class="peer sr-only">
                                    <div class="px-4 py-3 border-2 border-gray-300 rounded-lg text-center cursor-pointer peer-checked:border-purple-500 peer-checked:bg-purple-50 peer-checked:text-purple-700 hover:border-purple-300 transition-all">
                                        <i class="fas fa-file-csv text-xl mb-1"></i>
                                        <p class="text-xs font-bold">CSV</p>
                                    </div>
                                </label>
                                <label class="relative">
                                    <input type="radio" name="format" value="excel" class="peer sr-only">
                                    <div class="px-4 py-3 border-2 border-gray-300 rounded-lg text-center cursor-pointer peer-checked:border-green-500 peer-checked:bg-green-50 peer-checked:text-green-700 hover:border-green-300 transition-all">
                                        <i class="fas fa-file-excel text-xl mb-1"></i>
                                        <p class="text-xs font-bold">Excel</p>
                                    </div>
                                </label>
                                <label class="relative">
                                    <input type="radio" name="format" value="pdf" class="peer sr-only">
                                    <div class="px-4 py-3 border-2 border-gray-300 rounded-lg text-center cursor-pointer peer-checked:border-red-500 peer-checked:bg-red-50 peer-checked:text-red-700 hover:border-red-300 transition-all">
                                        <i class="fas fa-file-pdf text-xl mb-1"></i>
                                        <p class="text-xs font-bold">PDF</p>
                                    </div>
                                </label>
                            </div>
                        </div>

                        <!-- Download Button -->
                        <button type="submit" class="w-full bg-gradient-to-r from-purple-500 to-purple-600 hover:from-purple-600 hover:to-purple-700 text-white font-bold py-4 rounded-lg transition-all duration-300 shadow-md hover:shadow-lg flex items-center justify-center gap-2">
                            <i class="fas fa-download"></i>
                            <span>تحميل التقرير</span>
                        </button>
                    </form>
                </div>
            </div>

            <!-- Revenue Report Card -->
            <div class="bg-white rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 overflow-hidden border border-gray-100">
                <div class="bg-gradient-to-r from-green-500 to-green-600 p-6">
                    <div class="flex items-center gap-4">
                        <div class="w-14 h-14 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm">
                            <i class="fas fa-chart-line text-3xl text-white"></i>
                        </div>
                        <div>
                            <h2 class="text-2xl font-bold text-white">تقرير الإيرادات</h2>
                            <p class="text-green-100 text-sm">تفاصيل المدفوعات والإيرادات</p>
                        </div>
                    </div>
                </div>
                <div class="p-6">
                    <form action="{{ route('admin.exports.revenue') }}" method="GET" class="space-y-4">
                        <!-- Filters -->
                        <div class="space-y-3">
                            <div>
                                <label class="block text-sm font-semibold text-gray-700 mb-2">تاريخ البداية</label>
                                <input type="date" name="start_date" class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent">
                            </div>
                            <div>
                                <label class="block text-sm font-semibold text-gray-700 mb-2">تاريخ النهاية</label>
                                <input type="date" name="end_date" class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent">
                            </div>
                            <div>
                                <label class="block text-sm font-semibold text-gray-700 mb-2">طريقة الدفع</label>
                                <select name="payment_method" class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent">
                                    <option value="">الكل</option>
                                    <option value="ccp">CCP</option>
                                    <option value="baridi_mob">بريدي موب</option>
                                    <option value="code">رمز الاشتراك</option>
                                </select>
                            </div>
                        </div>

                        <!-- Format Selection -->
                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-3">صيغة التصدير</label>
                            <div class="grid grid-cols-3 gap-3">
                                <label class="relative">
                                    <input type="radio" name="format" value="csv" checked class="peer sr-only">
                                    <div class="px-4 py-3 border-2 border-gray-300 rounded-lg text-center cursor-pointer peer-checked:border-green-500 peer-checked:bg-green-50 peer-checked:text-green-700 hover:border-green-300 transition-all">
                                        <i class="fas fa-file-csv text-xl mb-1"></i>
                                        <p class="text-xs font-bold">CSV</p>
                                    </div>
                                </label>
                                <label class="relative">
                                    <input type="radio" name="format" value="excel" class="peer sr-only">
                                    <div class="px-4 py-3 border-2 border-gray-300 rounded-lg text-center cursor-pointer peer-checked:border-green-500 peer-checked:bg-green-50 peer-checked:text-green-700 hover:border-green-300 transition-all">
                                        <i class="fas fa-file-excel text-xl mb-1"></i>
                                        <p class="text-xs font-bold">Excel</p>
                                    </div>
                                </label>
                                <label class="relative">
                                    <input type="radio" name="format" value="pdf" class="peer sr-only">
                                    <div class="px-4 py-3 border-2 border-gray-300 rounded-lg text-center cursor-pointer peer-checked:border-red-500 peer-checked:bg-red-50 peer-checked:text-red-700 hover:border-red-300 transition-all">
                                        <i class="fas fa-file-pdf text-xl mb-1"></i>
                                        <p class="text-xs font-bold">PDF</p>
                                    </div>
                                </label>
                            </div>
                        </div>

                        <!-- Download Button -->
                        <button type="submit" class="w-full bg-gradient-to-r from-green-500 to-green-600 hover:from-green-600 hover:to-green-700 text-white font-bold py-4 rounded-lg transition-all duration-300 shadow-md hover:shadow-lg flex items-center justify-center gap-2">
                            <i class="fas fa-download"></i>
                            <span>تحميل التقرير</span>
                        </button>
                    </form>
                </div>
            </div>

            <!-- Course Statistics Card -->
            <div class="bg-white rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 overflow-hidden border border-gray-100">
                <div class="bg-gradient-to-r from-indigo-500 to-indigo-600 p-6">
                    <div class="flex items-center gap-4">
                        <div class="w-14 h-14 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm">
                            <i class="fas fa-chart-bar text-3xl text-white"></i>
                        </div>
                        <div>
                            <h2 class="text-2xl font-bold text-white">إحصائيات الدورات</h2>
                            <p class="text-indigo-100 text-sm">تقرير شامل عن أداء الدورات</p>
                        </div>
                    </div>
                </div>
                <div class="p-6">
                    <form action="{{ route('admin.exports.courses.statistics') }}" method="GET" class="space-y-4">
                        <!-- Info Message -->
                        <div class="bg-indigo-50 border-r-4 border-indigo-500 p-4 rounded-lg">
                            <p class="text-sm text-indigo-800">
                                <i class="fas fa-info-circle ml-2"></i>
                                يتضمن التقرير: عدد الطلاب، التقييمات، نسبة الإكمال، والإيرادات لكل دورة
                            </p>
                        </div>

                        <!-- Format Selection -->
                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-3">صيغة التصدير</label>
                            <div class="grid grid-cols-3 gap-3">
                                <label class="relative">
                                    <input type="radio" name="format" value="csv" checked class="peer sr-only">
                                    <div class="px-4 py-3 border-2 border-gray-300 rounded-lg text-center cursor-pointer peer-checked:border-indigo-500 peer-checked:bg-indigo-50 peer-checked:text-indigo-700 hover:border-indigo-300 transition-all">
                                        <i class="fas fa-file-csv text-xl mb-1"></i>
                                        <p class="text-xs font-bold">CSV</p>
                                    </div>
                                </label>
                                <label class="relative">
                                    <input type="radio" name="format" value="excel" class="peer sr-only">
                                    <div class="px-4 py-3 border-2 border-gray-300 rounded-lg text-center cursor-pointer peer-checked:border-green-500 peer-checked:bg-green-50 peer-checked:text-green-700 hover:border-green-300 transition-all">
                                        <i class="fas fa-file-excel text-xl mb-1"></i>
                                        <p class="text-xs font-bold">Excel</p>
                                    </div>
                                </label>
                                <label class="relative">
                                    <input type="radio" name="format" value="pdf" class="peer sr-only">
                                    <div class="px-4 py-3 border-2 border-gray-300 rounded-lg text-center cursor-pointer peer-checked:border-red-500 peer-checked:bg-red-50 peer-checked:text-red-700 hover:border-red-300 transition-all">
                                        <i class="fas fa-file-pdf text-xl mb-1"></i>
                                        <p class="text-xs font-bold">PDF</p>
                                    </div>
                                </label>
                            </div>
                        </div>

                        <!-- Download Button -->
                        <button type="submit" class="w-full bg-gradient-to-r from-indigo-500 to-indigo-600 hover:from-indigo-600 hover:to-indigo-700 text-white font-bold py-4 rounded-lg transition-all duration-300 shadow-md hover:shadow-lg flex items-center justify-center gap-2">
                            <i class="fas fa-download"></i>
                            <span>تحميل التقرير</span>
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <!-- Quick Access Links -->
        <div class="bg-white rounded-2xl shadow-lg p-6 border border-gray-100">
            <h3 class="text-xl font-bold text-gray-800 mb-4 flex items-center gap-3">
                <i class="fas fa-link text-blue-600"></i>
                روابط سريعة لتقارير إضافية
            </h3>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <a href="{{ route('admin.exports.codes') }}" class="flex items-center gap-3 p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-all border border-gray-200">
                    <i class="fas fa-ticket-alt text-2xl text-orange-600"></i>
                    <div>
                        <p class="font-bold text-gray-800">أكواد الاشتراك</p>
                        <p class="text-sm text-gray-600">CSV فقط</p>
                    </div>
                </a>
                <a href="{{ route('admin.exports.codes.usage') }}" class="flex items-center gap-3 p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-all border border-gray-200">
                    <i class="fas fa-chart-pie text-2xl text-teal-600"></i>
                    <div>
                        <p class="font-bold text-gray-800">إحصائيات الأكواد</p>
                        <p class="text-sm text-gray-600">CSV فقط</p>
                    </div>
                </a>
                <a href="{{ route('admin.exports.receipts') }}" class="flex items-center gap-3 p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-all border border-gray-200">
                    <i class="fas fa-receipt text-2xl text-pink-600"></i>
                    <div>
                        <p class="font-bold text-gray-800">وصولات الدفع</p>
                        <p class="text-sm text-gray-600">CSV فقط</p>
                    </div>
                </a>
            </div>
        </div>
    </div>
</div>
@endsection
