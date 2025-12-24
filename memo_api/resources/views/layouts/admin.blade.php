<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'لوحة التحكم') - MEMO</title>

    <!-- Tailwind CSS CDN with RTL support -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- Cairo Font from Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        * {
            font-family: 'Cairo', sans-serif;
        }

        /* RTL-specific adjustments - only flip icons that need it */
        [dir="rtl"] .rtl-flip {
            transform: scaleX(-1);
        }

        /* RTL form elements */
        [dir="rtl"] input[type="text"],
        [dir="rtl"] input[type="email"],
        [dir="rtl"] input[type="tel"],
        [dir="rtl"] input[type="password"],
        [dir="rtl"] textarea,
        [dir="rtl"] select {
            text-align: right;
            direction: rtl;
        }

        /* LTR override for specific inputs */
        input[dir="ltr"],
        textarea[dir="ltr"] {
            text-align: left !important;
            direction: ltr !important;
        }

        /* Placeholder RTL support */
        [dir="rtl"] input::placeholder,
        [dir="rtl"] textarea::placeholder {
            text-align: right;
        }

        input[dir="ltr"]::placeholder,
        textarea[dir="ltr"]::placeholder {
            text-align: left;
        }

        /* Custom scrollbar */
        ::-webkit-scrollbar {
            width: 8px;
            height: 8px;
        }

        ::-webkit-scrollbar-track {
            background: #f1f1f1;
        }

        ::-webkit-scrollbar-thumb {
            background: #888;
            border-radius: 4px;
        }

        ::-webkit-scrollbar-thumb:hover {
            background: #555;
        }

        /* Sidebar scrollbar - custom styling */
        aside nav::-webkit-scrollbar {
            width: 6px;
        }

        aside nav::-webkit-scrollbar-track {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 3px;
        }

        aside nav::-webkit-scrollbar-thumb {
            background: rgba(255, 255, 255, 0.3);
            border-radius: 3px;
        }

        aside nav::-webkit-scrollbar-thumb:hover {
            background: rgba(255, 255, 255, 0.5);
        }

        /* Smooth transitions for menu items */
        [x-cloak] {
            display: none !important;
        }
    </style>

    @stack('styles')
</head>
<body class="bg-gray-50">

    <!-- Sidebar -->
    <aside class="fixed top-0 right-0 h-screen w-72 bg-gradient-to-b from-indigo-950 via-blue-900 to-blue-800 text-white shadow-2xl z-40 flex flex-col"
           x-data="{
               openMenus: {
                   users: {{ request()->routeIs('admin.users.*') ? 'true' : 'false' }},
                   academic: {{ request()->routeIs('admin.academic-*', 'admin.subjects.*') ? 'true' : 'false' }},
                   subjectPlanner: {{ request()->routeIs('admin.subject-planner-content.*') ? 'true' : 'false' }},
                   content: {{ request()->routeIs('admin.contents.*') ? 'true' : 'false' }},
                   planner: {{ request()->routeIs('admin.planner.*') ? 'true' : 'false' }},
                   bacSchedule: {{ request()->routeIs('admin.bac-study-schedule.*') ? 'true' : 'false' }},
                   quizzes: {{ request()->routeIs('admin.quizzes.*') ? 'true' : 'false' }},
                   flashcards: {{ request()->routeIs('admin.flashcard-decks.*', 'admin.flashcards.*') ? 'true' : 'false' }},
                   bac: {{ request()->routeIs('admin.bac.*') ? 'true' : 'false' }},
                   courses: {{ request()->routeIs('admin.courses.*', 'admin.course-reviews.*') ? 'true' : 'false' }},
                   promos: {{ request()->routeIs('admin.promos.*') ? 'true' : 'false' }},
                   sponsors: {{ request()->routeIs('admin.sponsors.*') ? 'true' : 'false' }},
                   payments: {{ request()->routeIs('admin.subscriptions.*', 'admin.subscription-codes.*', 'admin.payment-receipts.*') ? 'true' : 'false' }},
                   notifications: {{ request()->routeIs('admin.notifications.*') ? 'true' : 'false' }},
                   reports: {{ request()->routeIs('admin.exports.*') ? 'true' : 'false' }}
               }
           }">
        <!-- Sidebar Header -->
        <div class="p-6 flex-shrink-0 bg-indigo-950/50 border-b border-blue-700/30">
            <div class="flex items-center gap-3">
                <div class="w-12 h-12 bg-gradient-to-br from-yellow-400 to-orange-500 rounded-xl flex items-center justify-center shadow-lg">
                    <i class="fas fa-graduation-cap text-white text-xl"></i>
                </div>
                <div>
                    <h1 class="text-2xl font-bold bg-gradient-to-l from-yellow-400 to-orange-400 bg-clip-text text-transparent">MEMO</h1>
                    <p class="text-blue-300 text-xs font-medium">لوحة التحكم الإدارية</p>
                </div>
            </div>
        </div>

        <!-- Scrollable Navigation -->
        <nav class="flex-1 overflow-y-auto overflow-x-hidden px-3 py-4 space-y-1" style="scrollbar-width: thin; scrollbar-color: rgba(255,255,255,0.3) transparent;">

            <!-- Dashboard -->
            <a href="{{ route('admin.dashboard') }}"
               class="flex items-center gap-3 px-4 py-3 rounded-xl hover:bg-white/10 transition-all duration-200 group {{ request()->routeIs('admin.dashboard') ? 'bg-gradient-to-l from-yellow-500/20 to-orange-500/20 border-r-4 border-yellow-400 shadow-lg' : '' }}">
                <div class="w-9 h-9 rounded-lg bg-blue-800/50 flex items-center justify-center group-hover:bg-yellow-500/20 transition-colors {{ request()->routeIs('admin.dashboard') ? 'bg-yellow-500/30' : '' }}">
                    <i class="fas fa-home text-lg {{ request()->routeIs('admin.dashboard') ? 'text-yellow-300' : '' }}"></i>
                </div>
                <span class="font-semibold {{ request()->routeIs('admin.dashboard') ? 'text-yellow-200' : '' }}">الصفحة الرئيسية</span>
            </a>

            <!-- SECTION: إدارة النظام -->
            <div class="pt-4 pb-2 px-3">
                <div class="flex items-center gap-2 text-xs font-bold text-blue-300 uppercase tracking-wider">
                    <i class="fas fa-cog text-xs"></i>
                    <span>إدارة النظام</span>
                </div>
            </div>

            <!-- Users -->
            <div>
                <button @click="openMenus.users = !openMenus.users"
                        class="w-full flex items-center justify-between gap-3 px-4 py-3 rounded-xl hover:bg-white/10 transition-all duration-200 group {{ request()->routeIs('admin.users.*') ? 'bg-white/10' : '' }}">
                    <div class="flex items-center gap-3">
                        <div class="w-9 h-9 rounded-lg bg-blue-800/50 flex items-center justify-center group-hover:bg-purple-500/20 transition-colors {{ request()->routeIs('admin.users.*') ? 'bg-purple-500/30' : '' }}">
                            <i class="fas fa-users text-lg {{ request()->routeIs('admin.users.*') ? 'text-purple-300' : '' }}"></i>
                        </div>
                        <span class="font-semibold">المستخدمون</span>
                    </div>
                    <i class="fas fa-chevron-down text-xs transition-transform duration-200" :class="openMenus.users ? 'rotate-180' : ''"></i>
                </button>
                <div x-show="openMenus.users" x-collapse class="mr-12 mt-1 space-y-1">
                    <a href="{{ route('admin.users.index') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.users.index') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-list text-xs w-4"></i>
                        <span>قائمة المستخدمين</span>
                    </a>
                    <a href="{{ route('admin.users.create') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.users.create') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-user-plus text-xs w-4"></i>
                        <span>إضافة مستخدم جديد</span>
                    </a>
                    <a href="{{ route('admin.users.analytics') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.users.analytics') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-chart-bar text-xs w-4"></i>
                        <span>إحصائيات المستخدمين</span>
                    </a>
                </div>
            </div>

            <div class="my-4 border-t border-blue-700/30"></div>

            <!-- SECTION: الهيكل الأكاديمي -->
            <div class="pt-2 pb-2 px-3">
                <div class="flex items-center gap-2 text-xs font-bold text-emerald-300 uppercase tracking-wider">
                    <i class="fas fa-school text-xs"></i>
                    <span>الهيكل الأكاديمي</span>
                </div>
            </div>

            <!-- Academic Structure Collapsible -->
            <div>
                <button @click="openMenus.academic = !openMenus.academic"
                        class="w-full flex items-center justify-between gap-3 px-4 py-3 rounded-xl hover:bg-white/10 transition-all duration-200 group {{ request()->routeIs('admin.academic-*', 'admin.subjects.*') ? 'bg-white/10' : '' }}">
                    <div class="flex items-center gap-3">
                        <div class="w-9 h-9 rounded-lg bg-blue-800/50 flex items-center justify-center group-hover:bg-emerald-500/20 transition-colors {{ request()->routeIs('admin.academic-*', 'admin.subjects.*') ? 'bg-emerald-500/30' : '' }}">
                            <i class="fas fa-sitemap text-lg {{ request()->routeIs('admin.academic-*', 'admin.subjects.*') ? 'text-emerald-300' : '' }}"></i>
                        </div>
                        <span class="font-semibold">التنظيم الأكاديمي</span>
                    </div>
                    <i class="fas fa-chevron-down text-xs transition-transform duration-200" :class="openMenus.academic ? 'rotate-180' : ''"></i>
                </button>
                <div x-show="openMenus.academic" x-collapse class="mr-12 mt-1 space-y-1">
                    <a href="{{ route('admin.academic-phases.index') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.academic-phases.*') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-layer-group text-xs w-4"></i>
                        <span>المراحل الدراسية</span>
                    </a>
                    <a href="{{ route('admin.academic-years.index') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.academic-years.*') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-calendar-alt text-xs w-4"></i>
                        <span>السنوات الدراسية</span>
                    </a>
                    <a href="{{ route('admin.academic-streams.index') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.academic-streams.*') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-stream text-xs w-4"></i>
                        <span>الشعب الدراسية</span>
                    </a>
                    <a href="{{ route('admin.subjects.index') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.subjects.*') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-book text-xs w-4"></i>
                        <span>المواد الدراسية</span>
                    </a>
                </div>
            </div>

            <!-- Subject Planner Content (مخطط المحتوى) -->
            <div>
                <button @click="openMenus.subjectPlanner = !openMenus.subjectPlanner"
                        class="w-full flex items-center justify-between gap-3 px-4 py-3 rounded-xl hover:bg-white/10 transition-all duration-200 group {{ request()->routeIs('admin.subject-planner-content.*') ? 'bg-white/10' : '' }}">
                    <div class="flex items-center gap-3">
                        <div class="w-9 h-9 rounded-lg bg-blue-800/50 flex items-center justify-center group-hover:bg-indigo-500/20 transition-colors {{ request()->routeIs('admin.subject-planner-content.*') ? 'bg-indigo-500/30' : '' }}">
                            <i class="fas fa-project-diagram text-lg {{ request()->routeIs('admin.subject-planner-content.*') ? 'text-indigo-300' : '' }}"></i>
                        </div>
                        <span class="font-semibold">مخطط المحتوى</span>
                    </div>
                    <i class="fas fa-chevron-down text-xs transition-transform duration-200" :class="openMenus.subjectPlanner ? 'rotate-180' : ''"></i>
                </button>
                <div x-show="openMenus.subjectPlanner" x-collapse class="mr-12 mt-1 space-y-1">
                    <a href="{{ route('admin.subject-planner-content.index') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.subject-planner-content.index') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-list text-xs w-4"></i>
                        <span>القائمة المسطحة</span>
                    </a>
                    <a href="{{ route('admin.subject-planner-content.tree') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.subject-planner-content.tree') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-sitemap text-xs w-4"></i>
                        <span>العرض الشجري</span>
                    </a>
                    <a href="{{ route('admin.subject-planner-content.create') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.subject-planner-content.create') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-plus text-xs w-4"></i>
                        <span>إضافة محتوى</span>
                    </a>
                </div>
            </div>

            <!-- Educational Content -->
            <div>
                <button @click="openMenus.content = !openMenus.content"
                        class="w-full flex items-center justify-between gap-3 px-4 py-3 rounded-xl hover:bg-white/10 transition-all duration-200 group {{ request()->routeIs('admin.contents.*') ? 'bg-white/10' : '' }}">
                    <div class="flex items-center gap-3">
                        <div class="w-9 h-9 rounded-lg bg-blue-800/50 flex items-center justify-center group-hover:bg-teal-500/20 transition-colors {{ request()->routeIs('admin.contents.*') ? 'bg-teal-500/30' : '' }}">
                            <i class="fas fa-file-alt text-lg {{ request()->routeIs('admin.contents.*') ? 'text-teal-300' : '' }}"></i>
                        </div>
                        <span class="font-semibold">المحتوى التعليمي</span>
                    </div>
                    <i class="fas fa-chevron-down text-xs transition-transform duration-200" :class="openMenus.content ? 'rotate-180' : ''"></i>
                </button>
                <div x-show="openMenus.content" x-collapse class="mr-12 mt-1 space-y-1">
                    <a href="{{ route('admin.contents.index') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.contents.index') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-list text-xs w-4"></i>
                        <span>إدارة المحتوى</span>
                    </a>
                    <a href="{{ route('admin.contents.analytics') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.contents.analytics') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-chart-line text-xs w-4"></i>
                        <span>تحليلات المحتوى</span>
                    </a>
                </div>
            </div>

            <div class="my-4 border-t border-blue-700/30"></div>

            <!-- SECTION: الأدوات التفاعلية -->
            <div class="pt-2 pb-2 px-3">
                <div class="flex items-center gap-2 text-xs font-bold text-cyan-300 uppercase tracking-wider">
                    <i class="fas fa-tools text-xs"></i>
                    <span>الأدوات التفاعلية</span>
                </div>
            </div>

            <!-- Intelligent Planner -->
            <div>
                <button @click="openMenus.planner = !openMenus.planner"
                        class="w-full flex items-center justify-between gap-3 px-4 py-3 rounded-xl hover:bg-white/10 transition-all duration-200 group {{ request()->routeIs('admin.planner.*') ? 'bg-white/10' : '' }}">
                    <div class="flex items-center gap-3">
                        <div class="w-9 h-9 rounded-lg bg-blue-800/50 flex items-center justify-center group-hover:bg-cyan-500/20 transition-colors {{ request()->routeIs('admin.planner.*') ? 'bg-cyan-500/30' : '' }}">
                            <i class="fas fa-brain text-lg {{ request()->routeIs('admin.planner.*') ? 'text-cyan-300' : '' }}"></i>
                        </div>
                        <span class="font-semibold">المخطط الذكي</span>
                    </div>
                    <i class="fas fa-chevron-down text-xs transition-transform duration-200" :class="openMenus.planner ? 'rotate-180' : ''"></i>
                </button>
                <div x-show="openMenus.planner" x-collapse class="mr-12 mt-1 space-y-1">
                    <a href="{{ route('admin.planner.index') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.planner.index') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-home text-xs w-4"></i>
                        <span>نظرة عامة</span>
                    </a>
                    <a href="{{ route('admin.planner.schedules') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.planner.schedules*') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-calendar-check text-xs w-4"></i>
                        <span>الجداول الدراسية</span>
                    </a>
                    <a href="{{ route('admin.planner.sessions') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.planner.sessions*') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-book-reader text-xs w-4"></i>
                        <span>جلسات الدراسة</span>
                    </a>
                    <a href="{{ route('admin.planner.priorities') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.planner.priorities') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-sort-amount-up text-xs w-4"></i>
                        <span>أولويات المواد</span>
                    </a>
                    <a href="{{ route('admin.planner.analytics') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.planner.analytics') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-chart-pie text-xs w-4"></i>
                        <span>تحليلات الخطة</span>
                    </a>
                </div>
            </div>

            <!-- BAC Study Schedule (98 Days Planner) -->
            <div>
                <button @click="openMenus.bacSchedule = !openMenus.bacSchedule"
                        class="w-full flex items-center justify-between gap-3 px-4 py-3 rounded-xl hover:bg-white/10 transition-all duration-200 group {{ request()->routeIs('admin.bac-study-schedule.*') ? 'bg-white/10' : '' }}">
                    <div class="flex items-center gap-3">
                        <div class="w-9 h-9 rounded-lg bg-blue-800/50 flex items-center justify-center group-hover:bg-orange-500/20 transition-colors {{ request()->routeIs('admin.bac-study-schedule.*') ? 'bg-orange-500/30' : '' }}">
                            <i class="fas fa-calendar-check text-lg {{ request()->routeIs('admin.bac-study-schedule.*') ? 'text-orange-300' : '' }}"></i>
                        </div>
                        <span class="font-semibold">جدول 98 يوم</span>
                    </div>
                    <i class="fas fa-chevron-down text-xs transition-transform duration-200" :class="openMenus.bacSchedule ? 'rotate-180' : ''"></i>
                </button>
                <div x-show="openMenus.bacSchedule" x-collapse class="mr-12 mt-1 space-y-1">
                    <a href="{{ route('admin.bac-study-schedule.index') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.bac-study-schedule.index') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-home text-xs w-4"></i>
                        <span>نظرة عامة</span>
                    </a>
                    <a href="{{ route('admin.bac-study-schedule.days') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.bac-study-schedule.days*') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-calendar-day text-xs w-4"></i>
                        <span>إدارة الأيام</span>
                    </a>
                    <a href="{{ route('admin.bac-study-schedule.rewards') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.bac-study-schedule.rewards*') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-gift text-xs w-4"></i>
                        <span>المكافآت الأسبوعية</span>
                    </a>
                    <a href="{{ route('admin.bac-study-schedule.progress') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.bac-study-schedule.progress') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-chart-line text-xs w-4"></i>
                        <span>تقدم المستخدمين</span>
                    </a>
                </div>
            </div>

            <!-- Quiz System -->
            <div>
                <button @click="openMenus.quizzes = !openMenus.quizzes"
                        class="w-full flex items-center justify-between gap-3 px-4 py-3 rounded-xl hover:bg-white/10 transition-all duration-200 group {{ request()->routeIs('admin.quizzes.*') ? 'bg-white/10' : '' }}">
                    <div class="flex items-center gap-3">
                        <div class="w-9 h-9 rounded-lg bg-blue-800/50 flex items-center justify-center group-hover:bg-pink-500/20 transition-colors {{ request()->routeIs('admin.quizzes.*') ? 'bg-pink-500/30' : '' }}">
                            <i class="fas fa-clipboard-question text-lg {{ request()->routeIs('admin.quizzes.*') ? 'text-pink-300' : '' }}"></i>
                        </div>
                        <span class="font-semibold">نظام الكويزات</span>
                    </div>
                    <i class="fas fa-chevron-down text-xs transition-transform duration-200" :class="openMenus.quizzes ? 'rotate-180' : ''"></i>
                </button>
                <div x-show="openMenus.quizzes" x-collapse class="mr-12 mt-1 space-y-1">
                    <a href="{{ route('admin.quizzes.index') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.quizzes.index') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-list text-xs w-4"></i>
                        <span>جميع الكويزات</span>
                    </a>
                    <a href="{{ route('admin.quizzes.create') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.quizzes.create') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-plus text-xs w-4"></i>
                        <span>إضافة كويز جديد</span>
                    </a>
                    <a href="{{ route('admin.quizzes.import') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.quizzes.import') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-file-excel text-xs w-4"></i>
                        <span>استيراد من Excel</span>
                    </a>
                    <a href="{{ route('admin.quizzes.analytics') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.quizzes.analytics') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-chart-bar text-xs w-4"></i>
                        <span>تحليلات الأداء</span>
                    </a>
                </div>
            </div>

            <!-- Flashcards System -->
            <div>
                <button @click="openMenus.flashcards = !openMenus.flashcards"
                        class="w-full flex items-center justify-between gap-3 px-4 py-3 rounded-xl hover:bg-white/10 transition-all duration-200 group {{ request()->routeIs('admin.flashcard-decks.*', 'admin.flashcards.*') ? 'bg-white/10' : '' }}">
                    <div class="flex items-center gap-3">
                        <div class="w-9 h-9 rounded-lg bg-blue-800/50 flex items-center justify-center group-hover:bg-pink-500/20 transition-colors {{ request()->routeIs('admin.flashcard-decks.*', 'admin.flashcards.*') ? 'bg-pink-500/30' : '' }}">
                            <i class="fas fa-clone text-lg {{ request()->routeIs('admin.flashcard-decks.*', 'admin.flashcards.*') ? 'text-pink-300' : '' }}"></i>
                        </div>
                        <span class="font-semibold">البطاقات التعليمية</span>
                    </div>
                    <i class="fas fa-chevron-down text-xs transition-transform duration-200" :class="openMenus.flashcards ? 'rotate-180' : ''"></i>
                </button>
                <div x-show="openMenus.flashcards" x-collapse class="mr-12 mt-1 space-y-1">
                    <a href="{{ route('admin.flashcard-decks.index') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.flashcard-decks.index') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-list text-xs w-4"></i>
                        <span>جميع المجموعات</span>
                    </a>
                    <a href="{{ route('admin.flashcard-decks.create') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.flashcard-decks.create') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-plus text-xs w-4"></i>
                        <span>إضافة مجموعة جديدة</span>
                    </a>
                </div>
            </div>

            <!-- BAC Archive -->
            <div>
                <button @click="openMenus.bac = !openMenus.bac"
                        class="w-full flex items-center justify-between gap-3 px-4 py-3 rounded-xl hover:bg-white/10 transition-all duration-200 group {{ request()->routeIs('admin.bac.*') ? 'bg-white/10' : '' }}">
                    <div class="flex items-center gap-3">
                        <div class="w-9 h-9 rounded-lg bg-blue-800/50 flex items-center justify-center group-hover:bg-amber-500/20 transition-colors {{ request()->routeIs('admin.bac.*') ? 'bg-amber-500/30' : '' }}">
                            <i class="fas fa-graduation-cap text-lg {{ request()->routeIs('admin.bac.*') ? 'text-amber-300' : '' }}"></i>
                        </div>
                        <span class="font-semibold">أرشيف البكالوريا</span>
                    </div>
                    <i class="fas fa-chevron-down text-xs transition-transform duration-200" :class="openMenus.bac ? 'rotate-180' : ''"></i>
                </button>
                <div x-show="openMenus.bac" x-collapse class="mr-12 mt-1 space-y-1">
                    <a href="{{ route('admin.bac.index') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.bac.index') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-list text-xs w-4"></i>
                        <span>جميع المواضيع</span>
                    </a>
                    <a href="{{ route('admin.bac.create') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.bac.create') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-plus text-xs w-4"></i>
                        <span>إضافة موضوع</span>
                    </a>
                    <a href="{{ route('admin.bac.years') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.bac.years') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-calendar-alt text-xs w-4"></i>
                        <span>إدارة السنوات</span>
                    </a>
                    <a href="{{ route('admin.bac.statistics') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.bac.statistics') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-chart-pie text-xs w-4"></i>
                        <span>الإحصائيات</span>
                    </a>
                </div>
            </div>

            <div class="my-4 border-t border-blue-700/30"></div>

            <!-- SECTION: الدورات المدفوعة -->
            <div class="pt-2 pb-2 px-3">
                <div class="flex items-center gap-2 text-xs font-bold text-yellow-300 uppercase tracking-wider">
                    <i class="fas fa-dollar-sign text-xs"></i>
                    <span>الدورات المدفوعة</span>
                </div>
            </div>

            <!-- Courses Management -->
            <div>
                <button @click="openMenus.courses = !openMenus.courses"
                        class="w-full flex items-center justify-between gap-3 px-4 py-3 rounded-xl hover:bg-white/10 transition-all duration-200 group {{ request()->routeIs('admin.courses.*', 'admin.course-reviews.*') ? 'bg-white/10' : '' }}">
                    <div class="flex items-center gap-3">
                        <div class="w-9 h-9 rounded-lg bg-blue-800/50 flex items-center justify-center group-hover:bg-yellow-500/20 transition-colors {{ request()->routeIs('admin.courses.*', 'admin.course-reviews.*') ? 'bg-yellow-500/30' : '' }}">
                            <i class="fas fa-video text-lg {{ request()->routeIs('admin.courses.*', 'admin.course-reviews.*') ? 'text-yellow-300' : '' }}"></i>
                        </div>
                        <span class="font-semibold">إدارة الدورات</span>
                    </div>
                    <i class="fas fa-chevron-down text-xs transition-transform duration-200" :class="openMenus.courses ? 'rotate-180' : ''"></i>
                </button>
                <div x-show="openMenus.courses" x-collapse class="mr-12 mt-1 space-y-1">
                    <a href="{{ route('admin.courses.index') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.courses.index') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-list text-xs w-4"></i>
                        <span>جميع الدورات</span>
                    </a>
                    <a href="{{ route('admin.courses.create') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.courses.create') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-plus text-xs w-4"></i>
                        <span>إضافة دورة جديدة</span>
                    </a>
                    <a href="{{ route('admin.course-reviews.index') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.course-reviews.*') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-star text-xs w-4"></i>
                        <span>التقييمات والمراجعات</span>
                    </a>
                </div>
            </div>

            <!-- Promos Management (العروض الترويجية) -->
            <div>
                <button @click="openMenus.promos = !openMenus.promos"
                        class="w-full flex items-center justify-between gap-3 px-4 py-3 rounded-xl hover:bg-white/10 transition-all duration-200 group {{ request()->routeIs('admin.promos.*') ? 'bg-white/10' : '' }}">
                    <div class="flex items-center gap-3">
                        <div class="w-9 h-9 rounded-lg bg-blue-800/50 flex items-center justify-center group-hover:bg-pink-500/20 transition-colors {{ request()->routeIs('admin.promos.*') ? 'bg-pink-500/30' : '' }}">
                            <i class="fas fa-bullhorn text-lg {{ request()->routeIs('admin.promos.*') ? 'text-pink-300' : '' }}"></i>
                        </div>
                        <span class="font-semibold">العروض الترويجية</span>
                    </div>
                    <i class="fas fa-chevron-down text-xs transition-transform duration-200" :class="openMenus.promos ? 'rotate-180' : ''"></i>
                </button>
                <div x-show="openMenus.promos" x-collapse class="mr-12 mt-1 space-y-1">
                    <a href="{{ route('admin.promos.index') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.promos.index') ? 'bg-white/10 text-pink-200' : 'text-blue-100' }}">
                        <i class="fas fa-list text-xs w-4"></i>
                        <span>جميع العروض</span>
                    </a>
                    <a href="{{ route('admin.promos.create') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.promos.create') ? 'bg-white/10 text-pink-200' : 'text-blue-100' }}">
                        <i class="fas fa-plus text-xs w-4"></i>
                        <span>إضافة عرض جديد</span>
                    </a>
                </div>
            </div>

            <!-- Sponsors Management (هاد التطبيق برعاية) -->
            <div>
                <button @click="openMenus.sponsors = !openMenus.sponsors"
                        class="w-full flex items-center justify-between gap-3 px-4 py-3 rounded-xl hover:bg-white/10 transition-all duration-200 group {{ request()->routeIs('admin.sponsors.*') ? 'bg-white/10' : '' }}">
                    <div class="flex items-center gap-3">
                        <div class="w-9 h-9 rounded-lg bg-blue-800/50 flex items-center justify-center group-hover:bg-purple-500/20 transition-colors {{ request()->routeIs('admin.sponsors.*') ? 'bg-purple-500/30' : '' }}">
                            <i class="fas fa-handshake text-lg {{ request()->routeIs('admin.sponsors.*') ? 'text-purple-300' : '' }}"></i>
                        </div>
                        <span class="font-semibold">الرعاة</span>
                    </div>
                    <i class="fas fa-chevron-down text-xs transition-transform duration-200" :class="openMenus.sponsors ? 'rotate-180' : ''"></i>
                </button>
                <div x-show="openMenus.sponsors" x-collapse class="mr-12 mt-1 space-y-1">
                    <a href="{{ route('admin.sponsors.index') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.sponsors.index') ? 'bg-white/10 text-purple-200' : 'text-blue-100' }}">
                        <i class="fas fa-list text-xs w-4"></i>
                        <span>جميع الرعاة</span>
                    </a>
                    <a href="{{ route('admin.sponsors.create') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.sponsors.create') ? 'bg-white/10 text-purple-200' : 'text-blue-100' }}">
                        <i class="fas fa-plus text-xs w-4"></i>
                        <span>إضافة راعي جديد</span>
                    </a>
                </div>
            </div>

            <!-- Payments & Subscriptions -->
            <div>
                <button @click="openMenus.payments = !openMenus.payments"
                        class="w-full flex items-center justify-between gap-3 px-4 py-3 rounded-xl hover:bg-white/10 transition-all duration-200 group {{ request()->routeIs('admin.subscriptions.*', 'admin.subscription-codes.*', 'admin.payment-receipts.*') ? 'bg-white/10' : '' }}">
                    <div class="flex items-center gap-3">
                        <div class="w-9 h-9 rounded-lg bg-blue-800/50 flex items-center justify-center group-hover:bg-green-500/20 transition-colors {{ request()->routeIs('admin.subscriptions.*', 'admin.subscription-codes.*', 'admin.payment-receipts.*') ? 'bg-green-500/30' : '' }}">
                            <i class="fas fa-wallet text-lg {{ request()->routeIs('admin.subscriptions.*', 'admin.subscription-codes.*', 'admin.payment-receipts.*') ? 'text-green-300' : '' }}"></i>
                        </div>
                        <span class="font-semibold">الاشتراكات</span>
                    </div>
                    <i class="fas fa-chevron-down text-xs transition-transform duration-200" :class="openMenus.payments ? 'rotate-180' : ''"></i>
                </button>
                <div x-show="openMenus.payments" x-collapse class="mr-12 mt-1 space-y-1">
                    <a href="{{ route('admin.subscriptions.index') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.subscriptions.index') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-users text-xs w-4"></i>
                        <span>الاشتراكات النشطة</span>
                    </a>
                    <a href="{{ route('admin.subscriptions.packages') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.subscriptions.packages*') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-box text-xs w-4"></i>
                        <span>باقات الاشتراك</span>
                    </a>
                    <a href="{{ route('admin.subscription-codes.index') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.subscription-codes.index') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-qrcode text-xs w-4"></i>
                        <span>أكواد الاشتراك</span>
                    </a>
                    <a href="{{ route('admin.subscription-codes.create') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.subscription-codes.create') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-plus-circle text-xs w-4"></i>
                        <span>توليد أكواد جديدة</span>
                    </a>
                    <a href="{{ route('admin.subscription-codes.by-list') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.subscription-codes.by-list') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-layer-group text-xs w-4"></i>
                        <span>عرض حسب القائمة</span>
                    </a>
                    <div class="border-t border-blue-700/20 my-1"></div>
                    <a href="{{ route('admin.payment-receipts.index') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.payment-receipts.index') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-receipt text-xs w-4"></i>
                        <span>إيصالات الدفع</span>
                    </a>
                    <div class="border-t border-blue-700/20 my-1"></div>
                    <a href="{{ route('admin.subscriptions.assign.courses.index') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.subscriptions.assign.courses.*') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-user-plus text-xs w-4"></i>
                        <span>تعيين دورات للطلاب</span>
                    </a>
                    <a href="{{ route('admin.subscriptions.assign.packages.index') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.subscriptions.assign.packages.*') ? 'bg-white/10 text-yellow-200' : 'text-blue-100' }}">
                        <i class="fas fa-gift text-xs w-4"></i>
                        <span>تعيين باقات للطلاب</span>
                    </a>
                </div>
            </div>

            <div class="my-4 border-t border-blue-700/30"></div>

            <!-- SECTION: التقارير -->
            <div class="pt-2 pb-2 px-3">
                <div class="flex items-center gap-2 text-xs font-bold text-indigo-300 uppercase tracking-wider">
                    <i class="fas fa-chart-line text-xs"></i>
                    <span>التقارير والإحصائيات</span>
                </div>
            </div>

            <!-- Analytics Dashboard -->
            <a href="{{ route('admin.analytics.index') }}"
               class="flex items-center gap-3 px-4 py-3 rounded-xl hover:bg-white/10 transition-all duration-200 group {{ request()->routeIs('admin.analytics.*') ? 'bg-white/10' : '' }}">
                <div class="w-9 h-9 rounded-lg bg-blue-800/50 flex items-center justify-center group-hover:bg-cyan-500/20 transition-colors {{ request()->routeIs('admin.analytics.*') ? 'bg-cyan-500/30' : '' }}">
                    <i class="fas fa-chart-line text-lg {{ request()->routeIs('admin.analytics.*') ? 'text-cyan-300' : '' }}"></i>
                </div>
                <span class="font-semibold">لوحة التحليلات</span>
            </a>

            <!-- Notifications Management -->
            <div>
                <button @click="openMenus.notifications = !openMenus.notifications"
                        class="w-full flex items-center justify-between gap-3 px-4 py-3 rounded-xl hover:bg-white/10 transition-all duration-200 group {{ request()->routeIs('admin.notifications.*') ? 'bg-white/10' : '' }}">
                    <div class="flex items-center gap-3">
                        <div class="w-9 h-9 rounded-lg bg-blue-800/50 flex items-center justify-center group-hover:bg-purple-500/20 transition-colors {{ request()->routeIs('admin.notifications.*') ? 'bg-purple-500/30' : '' }}">
                            <i class="fas fa-bell text-lg {{ request()->routeIs('admin.notifications.*') ? 'text-purple-300' : '' }}"></i>
                        </div>
                        <span class="font-semibold">إدارة الإشعارات</span>
                    </div>
                    <i class="fas fa-chevron-down text-xs transition-transform duration-200" :class="openMenus.notifications ? 'rotate-180' : ''"></i>
                </button>
                <div x-show="openMenus.notifications" x-collapse class="mr-12 mt-1 space-y-1">
                    <a href="{{ route('admin.notifications.index') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.notifications.index') ? 'bg-white/10 text-purple-200' : 'text-blue-100' }}">
                        <i class="fas fa-list text-xs w-4"></i>
                        <span>جميع الإشعارات</span>
                    </a>
                    <a href="{{ route('admin.notifications.broadcast') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.notifications.broadcast*') ? 'bg-white/10 text-purple-200' : 'text-blue-100' }}">
                        <i class="fas fa-paper-plane text-xs w-4"></i>
                        <span>إرسال إشعارات</span>
                    </a>
                    <a href="{{ route('admin.notifications.settings') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.notifications.settings') ? 'bg-white/10 text-purple-200' : 'text-blue-100' }}">
                        <i class="fas fa-users-cog text-xs w-4"></i>
                        <span>إعدادات المستخدمين</span>
                    </a>
                    <a href="{{ route('admin.notifications.configuration') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.notifications.configuration*') ? 'bg-white/10 text-purple-200' : 'text-blue-100' }}">
                        <i class="fas fa-sliders-h text-xs w-4"></i>
                        <span>الإعدادات العامة</span>
                    </a>
                    <a href="{{ route('admin.notifications.statistics') }}"
                       class="flex items-center gap-3 px-4 py-2.5 rounded-lg hover:bg-white/5 transition-all text-sm {{ request()->routeIs('admin.notifications.statistics') ? 'bg-white/10 text-purple-200' : 'text-blue-100' }}">
                        <i class="fas fa-chart-bar text-xs w-4"></i>
                        <span>الإحصائيات</span>
                    </a>
                </div>
            </div>

            <!-- Reports & Exports -->
            <div>
                <a href="{{ route('admin.exports.index') }}"
                   class="w-full flex items-center gap-3 px-4 py-3 rounded-xl hover:bg-white/10 transition-all duration-200 group {{ request()->routeIs('admin.exports.*') ? 'bg-white/10' : '' }}">
                    <div class="w-9 h-9 rounded-lg bg-blue-800/50 flex items-center justify-center group-hover:bg-indigo-500/20 transition-colors {{ request()->routeIs('admin.exports.*') ? 'bg-indigo-500/30' : '' }}">
                        <i class="fas fa-file-export text-lg {{ request()->routeIs('admin.exports.*') ? 'text-indigo-300' : '' }}"></i>
                    </div>
                    <span class="font-semibold">التقارير والتصدير</span>
                </a>
            </div>

        </nav>

        <!-- User Profile Footer (Fixed at bottom) -->
        <div class="flex-shrink-0 border-t border-blue-700/30" x-data="{ open: false }">
            <div class="relative">
                <button @click="open = !open" class="w-full p-4 hover:bg-white/5 transition-colors flex items-center gap-3">
                    <!-- Profile Picture -->
                    <div class="w-11 h-11 rounded-full border-2 border-blue-400 flex items-center justify-center overflow-hidden bg-gradient-to-br from-blue-500 to-purple-600 flex-shrink-0">
                        @if(auth()->user()->profile_picture)
                            <img src="{{ Storage::url(auth()->user()->profile_picture) }}" alt="{{ auth()->user()->name }}" class="w-full h-full object-cover">
                        @else
                            <span class="text-lg font-bold text-white">{{ substr(auth()->user()->name, 0, 1) }}</span>
                        @endif
                    </div>
                    <!-- User Info -->
                    <div class="flex-1 text-right min-w-0">
                        <p class="font-bold truncate text-sm">{{ auth()->user()->name }}</p>
                        <p class="text-xs text-blue-200 truncate">{{ auth()->user()->role_display ?? 'مدير' }}</p>
                    </div>
                    <i class="fas fa-chevron-up text-xs transition-transform" :class="open ? 'rotate-180' : ''"></i>
                </button>

                <!-- Dropdown Menu -->
                <div x-show="open"
                     @click.away="open = false"
                     class="absolute bottom-full right-0 left-0 mb-2 bg-white rounded-xl shadow-2xl overflow-hidden border border-gray-200"
                     style="display: none;">

                    <!-- Simple Profile Header -->
                    <div class="bg-gray-50 border-b border-gray-200 p-4">
                        <div class="text-center">
                            <div class="w-16 h-16 rounded-full mx-auto mb-3 border-2 border-blue-500 flex items-center justify-center overflow-hidden bg-gradient-to-br from-blue-500 to-indigo-600 shadow-md">
                                @if(auth()->user()->profile_picture)
                                    <img src="{{ Storage::url(auth()->user()->profile_picture) }}" alt="{{ auth()->user()->name }}" class="w-full h-full object-cover">
                                @else
                                    <span class="text-2xl font-bold text-white">{{ substr(auth()->user()->name, 0, 1) }}</span>
                                @endif
                            </div>
                            <p class="font-bold text-gray-900 text-sm truncate">{{ auth()->user()->name }}</p>
                            <p class="text-xs text-gray-500 truncate mt-1">{{ auth()->user()->email }}</p>
                        </div>
                    </div>

                    <!-- Menu Items -->
                    <div class="p-2">
                        <a href="{{ route('admin.profile.index') }}" class="flex items-center gap-3 px-4 py-3 rounded-lg hover:bg-gray-50 transition-colors text-gray-700 group">
                            <div class="w-9 h-9 rounded-lg bg-blue-50 flex items-center justify-center group-hover:bg-blue-100 transition-colors">
                                <i class="fas fa-user text-blue-600"></i>
                            </div>
                            <div>
                                <p class="font-semibold text-sm">الملف الشخصي</p>
                                <p class="text-xs text-gray-500">عرض وتعديل معلوماتك</p>
                            </div>
                        </a>

                        <a href="{{ route('admin.settings.index') }}" class="flex items-center gap-3 px-4 py-3 rounded-lg hover:bg-gray-50 transition-colors text-gray-700 group">
                            <div class="w-9 h-9 rounded-lg bg-purple-50 flex items-center justify-center group-hover:bg-purple-100 transition-colors">
                                <i class="fas fa-cog text-purple-600"></i>
                            </div>
                            <div>
                                <p class="font-semibold text-sm">الإعدادات</p>
                                <p class="text-xs text-gray-500">تخصيص التطبيق</p>
                            </div>
                        </a>

                        <div class="border-t border-gray-200 my-2"></div>

                        <form method="POST" action="{{ route('admin.logout') }}">
                            @csrf
                            <button type="submit" class="w-full flex items-center gap-3 px-4 py-3 rounded-lg hover:bg-red-50 transition-colors text-red-600 group">
                                <div class="w-9 h-9 rounded-lg bg-red-50 flex items-center justify-center group-hover:bg-red-100 transition-colors">
                                    <i class="fas fa-sign-out-alt text-red-600"></i>
                                </div>
                                <div class="text-right">
                                    <p class="font-semibold text-sm">تسجيل الخروج</p>
                                    <p class="text-xs text-red-500">إنهاء الجلسة الحالية</p>
                                </div>
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </aside>

    <!-- Main Content -->
    <main class="mr-72">
        <!-- Top Bar -->
        <header class="bg-white shadow-sm sticky top-0 z-30" x-data="{ notificationsOpen: false, profileOpen: false }">
            <div class="px-8 py-4 flex justify-between items-center">
                <div>
                    <h2 class="text-2xl font-bold text-gray-800">@yield('page-title', 'لوحة التحكم')</h2>
                    <p class="text-gray-500 text-sm">@yield('page-description', '')</p>
                </div>

                <div class="flex items-center gap-3">
                    <!-- Notifications Dropdown -->
                    <div class="relative">
                        <button @click="notificationsOpen = !notificationsOpen" class="relative p-2.5 rounded-lg hover:bg-gray-100 transition-colors">
                            <i class="fas fa-bell text-gray-600 text-lg"></i>
                            <span class="absolute top-1 left-1 w-2.5 h-2.5 bg-red-500 rounded-full border-2 border-white"></span>
                        </button>

                        <!-- Notifications Dropdown Panel -->
                        <div x-show="notificationsOpen"
                             @click.away="notificationsOpen = false"
                             class="absolute left-0 mt-2 w-80 bg-white rounded-xl shadow-2xl border border-gray-200 overflow-hidden"
                             style="display: none;">
                            <div class="p-4 bg-gradient-to-r from-blue-600 to-indigo-600">
                                <h3 class="font-bold text-white">الإشعارات</h3>
                            </div>
                            <div class="max-h-96 overflow-y-auto">
                                <div class="p-4 text-center text-gray-500">
                                    <i class="fas fa-bell-slash text-3xl mb-2"></i>
                                    <p>لا توجد إشعارات جديدة</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Quick Settings -->
                    <a href="{{ route('admin.settings.index') }}" class="p-2.5 rounded-lg hover:bg-gray-100 transition-colors" title="الإعدادات">
                        <i class="fas fa-cog text-gray-600 text-lg"></i>
                    </a>

                    <!-- Profile Dropdown -->
                    <div class="relative">
                        <button @click="profileOpen = !profileOpen" class="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-gray-100 transition-colors">
                            <div class="w-9 h-9 rounded-full border-2 border-blue-200 flex items-center justify-center overflow-hidden bg-gradient-to-br from-blue-500 to-purple-600">
                                @if(auth()->user()->profile_picture)
                                    <img src="{{ Storage::url(auth()->user()->profile_picture) }}" alt="{{ auth()->user()->name }}" class="w-full h-full object-cover">
                                @else
                                    <span class="text-sm font-bold text-white">{{ substr(auth()->user()->name, 0, 1) }}</span>
                                @endif
                            </div>
                            <div class="text-right hidden md:block">
                                <p class="font-semibold text-sm text-gray-800">{{ auth()->user()->name }}</p>
                                <p class="text-xs text-gray-500">{{ auth()->user()->role_display ?? 'مدير' }}</p>
                            </div>
                            <i class="fas fa-chevron-down text-xs text-gray-500"></i>
                        </button>

                        <!-- Profile Dropdown Panel -->
                        <div x-show="profileOpen"
                             @click.away="profileOpen = false"
                             class="absolute left-0 mt-2 w-64 bg-white rounded-xl shadow-2xl border border-gray-200 overflow-hidden"
                             style="display: none;">

                            <!-- Profile Header -->
                            <div class="bg-gradient-to-r from-blue-600 to-indigo-600 p-4">
                                <div class="flex items-center gap-3">
                                    <div class="w-12 h-12 rounded-full border-2 border-white flex items-center justify-center overflow-hidden bg-white">
                                        @if(auth()->user()->profile_picture)
                                            <img src="{{ Storage::url(auth()->user()->profile_picture) }}" alt="{{ auth()->user()->name }}" class="w-full h-full object-cover">
                                        @else
                                            <span class="text-xl font-bold text-blue-600">{{ substr(auth()->user()->name, 0, 1) }}</span>
                                        @endif
                                    </div>
                                    <div class="flex-1 min-w-0">
                                        <p class="font-bold text-white truncate text-sm">{{ auth()->user()->name }}</p>
                                        <p class="text-xs text-blue-100 truncate">{{ auth()->user()->email }}</p>
                                    </div>
                                </div>
                            </div>

                            <!-- Menu Items -->
                            <div class="p-2">
                                <a href="{{ route('admin.profile.index') }}" class="flex items-center gap-3 px-3 py-2.5 rounded-lg hover:bg-gray-50 transition-colors text-gray-700">
                                    <i class="fas fa-user text-blue-600 w-5"></i>
                                    <span class="text-sm font-medium">الملف الشخصي</span>
                                </a>

                                <a href="{{ route('admin.profile.edit') }}" class="flex items-center gap-3 px-3 py-2.5 rounded-lg hover:bg-gray-50 transition-colors text-gray-700">
                                    <i class="fas fa-edit text-green-600 w-5"></i>
                                    <span class="text-sm font-medium">تعديل الملف</span>
                                </a>

                                <a href="{{ route('admin.profile.change-password') }}" class="flex items-center gap-3 px-3 py-2.5 rounded-lg hover:bg-gray-50 transition-colors text-gray-700">
                                    <i class="fas fa-lock text-purple-600 w-5"></i>
                                    <span class="text-sm font-medium">تغيير كلمة المرور</span>
                                </a>

                                <a href="{{ route('admin.settings.index') }}" class="flex items-center gap-3 px-3 py-2.5 rounded-lg hover:bg-gray-50 transition-colors text-gray-700">
                                    <i class="fas fa-cog text-orange-600 w-5"></i>
                                    <span class="text-sm font-medium">الإعدادات</span>
                                </a>

                                <div class="border-t border-gray-200 my-2"></div>

                                <form method="POST" action="{{ route('admin.logout') }}">
                                    @csrf
                                    <button type="submit" class="w-full flex items-center gap-3 px-3 py-2.5 rounded-lg hover:bg-red-50 transition-colors text-red-600">
                                        <i class="fas fa-sign-out-alt w-5"></i>
                                        <span class="text-sm font-medium">تسجيل الخروج</span>
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </header>

        <!-- Page Content -->
        <div class="p-8">
            @if(session('success'))
                <div class="mb-6 bg-green-50 border-r-4 border-green-500 p-4 rounded-lg">
                    <div class="flex items-center">
                        <i class="fas fa-check-circle text-green-500 mr-3"></i>
                        <p class="text-green-800">{{ session('success') }}</p>
                    </div>
                </div>
            @endif

            @if(session('error'))
                <div class="mb-6 bg-red-50 border-r-4 border-red-500 p-4 rounded-lg">
                    <div class="flex items-center">
                        <i class="fas fa-exclamation-circle text-red-500 mr-3"></i>
                        <p class="text-red-800">{{ session('error') }}</p>
                    </div>
                </div>
            @endif

            @yield('content')
        </div>
    </main>

    <!-- jQuery (required for Select2) -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

    <!-- Alpine.js for interactive components -->
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>

    <!-- Chart.js for graphs -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    @stack('scripts')
</body>
</html>
