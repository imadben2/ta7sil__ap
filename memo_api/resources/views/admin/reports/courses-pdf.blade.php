<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>تقرير الدورات</title>
    <style>
        @page {
            margin: 20px;
        }
        body {
            font-family: 'DejaVu Sans', 'Arial', sans-serif;
            font-size: 9px;
            color: #333;
        }
        .rtl {
            direction: rtl;
            text-align: right;
        }
        .ltr {
            direction: ltr;
            text-align: left;
        }
        .report-header {
            text-align: center;
            margin-bottom: 25px;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 8px;
        }
        .report-header h1 {
            margin: 0 0 10px 0;
            font-size: 22px;
            font-weight: bold;
        }
        .report-header p {
            margin: 5px 0;
            font-size: 11px;
            opacity: 0.95;
        }
        .statistics-box {
            background-color: #f8f9fa;
            border: 2px solid #4F46E5;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 20px;
            display: table;
            width: 100%;
        }
        .stat-row {
            display: table-row;
        }
        .stat-item {
            display: table-cell;
            padding: 8px 15px;
            text-align: center;
            border-left: 1px solid #dee2e6;
            width: 20%;
        }
        .stat-item:last-child {
            border-left: none;
        }
        .stat-label {
            font-size: 9px;
            color: #6c757d;
            margin-bottom: 5px;
        }
        .stat-value {
            font-size: 18px;
            font-weight: bold;
            color: #4F46E5;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
            font-size: 8px;
        }
        thead tr {
            background-color: #4F46E5;
            color: white;
        }
        th {
            padding: 10px 6px;
            text-align: center;
            font-weight: bold;
            font-size: 9px;
            border: 1px solid #dee2e6;
        }
        td {
            padding: 8px 6px;
            text-align: center;
            border: 1px solid #dee2e6;
            font-size: 8px;
        }
        tbody tr:nth-child(odd) {
            background-color: #ffffff;
        }
        tbody tr:nth-child(even) {
            background-color: #f8f9fa;
        }
        tbody tr:hover {
            background-color: #e7e9fc;
        }
        .text-right {
            text-align: right !important;
            padding-right: 10px !important;
        }
        .badge {
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 7px;
            font-weight: bold;
        }
        .badge-success {
            background-color: #d4edda;
            color: #155724;
        }
        .badge-danger {
            background-color: #f8d7da;
            color: #721c24;
        }
        .summary-row {
            background-color: #fff3cd !important;
            font-weight: bold;
            font-size: 10px;
        }
        .summary-row td {
            padding: 12px 6px;
            border-top: 3px solid #4F46E5;
        }
        .footer {
            margin-top: 30px;
            padding-top: 15px;
            border-top: 2px solid #e9ecef;
            text-align: center;
            font-size: 8px;
            color: #6c757d;
        }
        .footer p {
            margin: 3px 0;
        }
    </style>
</head>
<body>
    <div class="report-header rtl">
        <h1>تقرير الدورات التعليمية</h1>
        <p>تقرير شامل لجميع الدورات المتاحة على المنصة</p>
        <p>تاريخ التصدير: {{ date('Y-m-d H:i:s') }}</p>
    </div>

    @php
        $totalCourses = $courses->count();
        $publishedCourses = $courses->where('is_published', true)->count();
        $freeCourses = $courses->where('is_free', true)->count();
        $totalEnrollments = $courses->sum('enrollment_count');
        $totalRevenue = $courses->where('is_free', false)->sum('price_dzd');
    @endphp

    <div class="statistics-box rtl">
        <div class="stat-row">
            <div class="stat-item">
                <div class="stat-label">إجمالي الدورات</div>
                <div class="stat-value">{{ $totalCourses }}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">الدورات المنشورة</div>
                <div class="stat-value">{{ $publishedCourses }}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">الدورات المجانية</div>
                <div class="stat-value">{{ $freeCourses }}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">إجمالي المسجلين</div>
                <div class="stat-value">{{ number_format($totalEnrollments) }}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">القيمة الإجمالية</div>
                <div class="stat-value">{{ number_format($totalRevenue) }} دج</div>
            </div>
        </div>
    </div>

    <table class="rtl">
        <thead>
            <tr>
                <th style="width: 3%;">الرقم</th>
                <th style="width: 22%;">عنوان الدورة</th>
                <th style="width: 8%;">المستوى</th>
                <th style="width: 12%;">المادة</th>
                <th style="width: 12%;">المدرب</th>
                <th style="width: 8%;">السعر</th>
                <th style="width: 5%;">مجانية</th>
                <th style="width: 5%;">منشورة</th>
                <th style="width: 5%;">الوحدات</th>
                <th style="width: 5%;">الدروس</th>
                <th style="width: 6%;">المسجلين</th>
                <th style="width: 6%;">التقييم</th>
                <th style="width: 5%;">المراجعات</th>
            </tr>
        </thead>
        <tbody>
            @foreach($courses as $index => $course)
            <tr>
                <td>{{ $index + 1 }}</td>
                <td class="text-right">{{ $course->title_ar_pdf ?? $course->title_ar }}</td>
                <td>{{ $course->level_pdf ?? $course->level }}</td>
                <td>{{ $course->subject_name_pdf ?? ($course->subject->name_ar ?? '-') }}</td>
                <td>{{ $course->instructor_name_pdf ?? $course->instructor_name }}</td>
                <td>{{ $course->is_free ? 'يناجم' : number_format($course->price_dzd) . ' جد' }}</td>
                <td><span class="badge {{ $course->is_free ? 'badge-success' : 'badge-danger' }}">{{ $course->is_free ? 'نعم' : 'لا' }}</span></td>
                <td><span class="badge {{ $course->is_published ? 'badge-success' : 'badge-danger' }}">{{ $course->is_published ? 'نعم' : 'لا' }}</span></td>
                <td>{{ $course->total_modules }}</td>
                <td>{{ $course->total_lessons }}</td>
                <td>{{ $course->enrollment_count }}</td>
                <td>{{ number_format($course->average_rating, 2) }}</td>
                <td>{{ $course->total_reviews }}</td>
            </tr>
            @endforeach
        </tbody>
        <tfoot>
            <tr class="summary-row">
                <td colspan="5" style="text-align: center;">الإجمالي</td>
                <td>{{ number_format($totalRevenue) }} دج</td>
                <td colspan="4"></td>
                <td>{{ number_format($totalEnrollments) }}</td>
                <td colspan="2"></td>
            </tr>
        </tfoot>
    </table>

    <div class="footer rtl">
        <p><strong>تقرير الدورات التعليمية</strong></p>
        <p>تم إنشاء هذا التقرير بواسطة نظام إدارة المنصة التعليمية</p>
        <p>جميع الحقوق محفوظة © {{ date('Y') }}</p>
    </div>
</body>
</html>
