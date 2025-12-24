<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>تقرير الاشتراكات</title>
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
            background: linear-gradient(135deg, #9333ea 0%, #7e22ce 100%);
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
            background-color: #faf5ff;
            border: 2px solid #9333ea;
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
            border-left: 1px solid #e9d5ff;
            width: 25%;
        }
        .stat-item:last-child {
            border-left: none;
        }
        .stat-label {
            font-size: 9px;
            color: #581c87;
            margin-bottom: 5px;
        }
        .stat-value {
            font-size: 18px;
            font-weight: bold;
            color: #9333ea;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
            font-size: 8px;
        }
        thead tr {
            background-color: #9333ea;
            color: white;
        }
        th {
            padding: 10px 5px;
            text-align: center;
            font-weight: bold;
            font-size: 9px;
            border: 1px solid #e9d5ff;
        }
        td {
            padding: 8px 5px;
            text-align: center;
            border: 1px solid #e5e7eb;
            font-size: 8px;
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
        .badge {
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 7px;
            font-weight: bold;
        }
        .badge-course {
            background-color: #dbeafe;
            color: #1e40af;
        }
        .badge-package {
            background-color: #fce7f3;
            color: #be185d;
        }
        .badge-active {
            background-color: #d1fae5;
            color: #065f46;
        }
        .badge-inactive {
            background-color: #fee2e2;
            color: #991b1b;
        }
        .badge-pending {
            background-color: #fef3c7;
            color: #92400e;
        }
        .summary-row {
            background-color: #fef3c7 !important;
            font-weight: bold;
            font-size: 10px;
        }
        .summary-row td {
            padding: 12px 5px;
            border-top: 3px solid #9333ea;
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
        <h1>تقرير الاشتراكات</h1>
        <p>تقرير شامل لجميع اشتراكات الطلاب في الدورات والباقات</p>
        <p>تاريخ التصدير: {{ date('Y-m-d H:i:s') }}</p>
    </div>

    @php
        $totalSubscriptions = $subscriptions->count();
        $activeSubscriptions = $subscriptions->where('status', 'active')->count();
        $inactiveSubscriptions = $subscriptions->where('status', 'inactive')->count();
        $pendingSubscriptions = $subscriptions->where('status', 'pending')->count();
        $courseSubscriptions = $subscriptions->whereNotNull('course_id')->count();
        $packageSubscriptions = $subscriptions->whereNotNull('package_id')->count();
    @endphp

    <div class="statistics-box">
        <div class="stat-row">
            <div class="stat-item">
                <div class="stat-label">إجمالي الاشتراكات</div>
                <div class="stat-value">{{ $totalSubscriptions }}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">الاشتراكات النشطة</div>
                <div class="stat-value" style="color: #10b981;">{{ $activeSubscriptions }}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">اشتراكات الدورات</div>
                <div class="stat-value" style="color: #3b82f6;">{{ $courseSubscriptions }}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">اشتراكات الباقات</div>
                <div class="stat-value" style="color: #ec4899;">{{ $packageSubscriptions }}</div>
            </div>
        </div>
    </div>

    <table>
        <thead>
            <tr>
                <th style="width: 4%;">ID</th>
                <th style="width: 15%;">اسم الطالب</th>
                <th style="width: 18%;">البريد الإلكتروني</th>
                <th style="width: 20%;">الدورة/الباقة</th>
                <th style="width: 7%;">النوع</th>
                <th style="width: 10%;">طريقة الاشتراك</th>
                <th style="width: 8%;">الحالة</th>
                <th style="width: 9%;">تاريخ البدء</th>
                <th style="width: 9%;">تاريخ الانتهاء</th>
            </tr>
        </thead>
        <tbody>
            @foreach($subscriptions as $subscription)
            @php
                $courseName = $subscription->course
                    ? $subscription->course->title_ar
                    : ($subscription->package ? $subscription->package->name_ar : '-');
                $type = $subscription->course ? 'دورة' : 'باقة';
                $statusBadge = match($subscription->status) {
                    'active' => 'badge-active',
                    'inactive' => 'badge-inactive',
                    'pending' => 'badge-pending',
                    default => ''
                };
                $statusText = match($subscription->status) {
                    'active' => 'نشط',
                    'inactive' => 'غير نشط',
                    'pending' => 'قيد الانتظار',
                    default => $subscription->status
                };
            @endphp
            <tr>
                <td>{{ $subscription->id }}</td>
                <td class="text-right">{{ $subscription->user->full_name_ar }}</td>
                <td>{{ $subscription->user->email }}</td>
                <td class="text-right">{{ $courseName }}</td>
                <td><span class="badge {{ $subscription->course ? 'badge-course' : 'badge-package' }}">{{ $type }}</span></td>
                <td>{{ $subscription->subscription_method }}</td>
                <td><span class="badge {{ $statusBadge }}">{{ $statusText }}</span></td>
                <td>{{ $subscription->started_at?->format('Y-m-d') ?? '-' }}</td>
                <td>{{ $subscription->expires_at?->format('Y-m-d') ?? 'غير محدد' }}</td>
            </tr>
            @endforeach
        </tbody>
        <tfoot>
            <tr class="summary-row">
                <td colspan="3" style="text-align: center;">الإجمالي</td>
                <td colspan="2">{{ $totalSubscriptions }} اشتراك</td>
                <td colspan="2">نشط: {{ $activeSubscriptions }}</td>
                <td colspan="2">غير نشط: {{ $inactiveSubscriptions }}</td>
            </tr>
        </tfoot>
    </table>

    <div class="footer">
        <p><strong>تقرير الاشتراكات</strong></p>
        <p>تم إنشاء هذا التقرير بواسطة نظام إدارة المنصة التعليمية</p>
        <p>جميع الحقوق محفوظة © {{ date('Y') }}</p>
    </div>
</body>
</html>
