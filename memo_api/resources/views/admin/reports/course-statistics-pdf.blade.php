<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>إحصائيات الدورات</title>
    <style>
        @page {
            margin: 20px;
        }
        body {
            font-family: 'DejaVu Sans', sans-serif;
            direction: rtl;
            text-align: right;
            font-size: 9px;
            color: #333;
            unicode-bidi: bidi-override;
        }
        * {
            unicode-bidi: embed;
        }
        .report-header {
            text-align: center;
            margin-bottom: 25px;
            padding: 20px;
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
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
            background-color: #f0fdf4;
            border: 2px solid #10b981;
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
            padding: 8px 12px;
            text-align: center;
            border-left: 1px solid #d1fae5;
            width: 16.66%;
        }
        .stat-item:last-child {
            border-left: none;
        }
        .stat-label {
            font-size: 8px;
            color: #065f46;
            margin-bottom: 5px;
        }
        .stat-value {
            font-size: 16px;
            font-weight: bold;
            color: #10b981;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
            font-size: 7px;
        }
        thead tr {
            background-color: #10b981;
            color: white;
        }
        th {
            padding: 9px 4px;
            text-align: center;
            font-weight: bold;
            font-size: 8px;
            border: 1px solid #d1fae5;
        }
        td {
            padding: 7px 4px;
            text-align: center;
            border: 1px solid #e5e7eb;
            font-size: 7px;
        }
        tbody tr:nth-child(odd) {
            background-color: #ffffff;
        }
        tbody tr:nth-child(even) {
            background-color: #f9fafb;
        }
        .text-right {
            text-align: right !important;
            padding-right: 8px !important;
        }
        .summary-row {
            background-color: #fef3c7 !important;
            font-weight: bold;
            font-size: 9px;
        }
        .summary-row td {
            padding: 12px 4px;
            border-top: 3px solid #10b981;
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
    <div class="report-header">
        <h1>تقرير إحصائيات الدورات</h1>
        <p>تقرير تفصيلي لأداء جميع الدورات التعليمية</p>
        <p>تاريخ التصدير: {{ date('Y-m-d H:i:s') }}</p>
    </div>

    @php
        $totalCourses = $statistics->count();
        $totalModules = $statistics->sum('total_modules');
        $totalLessons = $statistics->sum('total_lessons');
        $totalEnrollments = $statistics->sum('enrollment_count');
        $totalActiveSubscriptions = $statistics->sum('active_subscriptions');
        $totalViews = $statistics->sum('view_count');
        $avgRating = $statistics->avg(function($stat) {
            return floatval($stat['average_rating']);
        });
    @endphp

    <div class="statistics-box">
        <div class="stat-row">
            <div class="stat-item">
                <div class="stat-label">إجمالي الدورات</div>
                <div class="stat-value">{{ $totalCourses }}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">إجمالي الوحدات</div>
                <div class="stat-value">{{ $totalModules }}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">إجمالي الدروس</div>
                <div class="stat-value">{{ $totalLessons }}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">إجمالي المسجلين</div>
                <div class="stat-value">{{ number_format($totalEnrollments) }}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">الاشتراكات النشطة</div>
                <div class="stat-value">{{ number_format($totalActiveSubscriptions) }}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">متوسط التقييم</div>
                <div class="stat-value">{{ number_format($avgRating, 2) }}</div>
            </div>
        </div>
    </div>

    <table>
        <thead>
            <tr>
                <th style="width: 3%;">الرقم</th>
                <th style="width: 20%;">عنوان الدورة</th>
                <th style="width: 10%;">المادة</th>
                <th style="width: 7%;">المستوى</th>
                <th style="width: 6%;">الوحدات</th>
                <th style="width: 6%;">الدروس</th>
                <th style="width: 8%;">مدة الفيديو</th>
                <th style="width: 7%;">المسجلين</th>
                <th style="width: 8%;">النشطة</th>
                <th style="width: 7%;">التقييم</th>
                <th style="width: 7%;">المراجعات</th>
                <th style="width: 7%;">المشاهدات</th>
            </tr>
        </thead>
        <tbody>
            @foreach($statistics as $index => $stat)
            <tr>
                <td>{{ $index + 1 }}</td>
                <td class="text-right">{{ $stat['title'] }}</td>
                <td>{{ $stat['subject'] }}</td>
                <td>{{ $stat['level'] }}</td>
                <td>{{ $stat['total_modules'] }}</td>
                <td>{{ $stat['total_lessons'] }}</td>
                <td>{{ $stat['video_duration'] }} دقيقة</td>
                <td>{{ $stat['enrollment_count'] }}</td>
                <td>{{ $stat['active_subscriptions'] }}</td>
                <td>{{ $stat['average_rating'] }}</td>
                <td>{{ $stat['total_reviews'] }}</td>
                <td>{{ $stat['view_count'] }}</td>
            </tr>
            @endforeach
        </tbody>
        <tfoot>
            <tr class="summary-row">
                <td colspan="4" style="text-align: center;">الإجمالي</td>
                <td>{{ $totalModules }}</td>
                <td>{{ $totalLessons }}</td>
                <td>-</td>
                <td>{{ number_format($totalEnrollments) }}</td>
                <td>{{ number_format($totalActiveSubscriptions) }}</td>
                <td colspan="2">متوسط: {{ number_format($avgRating, 2) }}</td>
                <td>{{ number_format($totalViews) }}</td>
            </tr>
        </tfoot>
    </table>

    <div class="footer">
        <p><strong>تقرير إحصائيات الدورات</strong></p>
        <p>تم إنشاء هذا التقرير بواسطة نظام إدارة المنصة التعليمية</p>
        <p>جميع الحقوق محفوظة © {{ date('Y') }}</p>
    </div>
</body>
</html>
