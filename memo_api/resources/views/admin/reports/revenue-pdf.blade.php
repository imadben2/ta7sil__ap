<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>تقرير الإيرادات</title>
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
        .revenue-summary {
            background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
            border: 3px solid #10b981;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 25px;
            text-align: center;
        }
        .revenue-summary h2 {
            color: #065f46;
            margin: 0 0 15px 0;
            font-size: 16px;
            font-weight: bold;
        }
        .revenue-total {
            font-size: 32px;
            font-weight: bold;
            color: #059669;
            margin: 10px 0;
            text-shadow: 1px 1px 2px rgba(0,0,0,0.1);
        }
        .revenue-details {
            display: table;
            width: 100%;
            margin-top: 15px;
        }
        .revenue-row {
            display: table-row;
        }
        .revenue-item {
            display: table-cell;
            padding: 10px;
            text-align: center;
            border-left: 2px solid #86efac;
            width: 33.33%;
        }
        .revenue-item:last-child {
            border-left: none;
        }
        .revenue-label {
            font-size: 9px;
            color: #065f46;
            margin-bottom: 5px;
        }
        .revenue-value {
            font-size: 16px;
            font-weight: bold;
            color: #10b981;
        }
        .filter-info {
            background-color: #f3f4f6;
            padding: 10px 15px;
            border-radius: 6px;
            margin-bottom: 15px;
            font-size: 9px;
            text-align: center;
            border: 1px solid #d1d5db;
        }
        .filter-info strong {
            color: #059669;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
            font-size: 8px;
        }
        thead tr {
            background-color: #10b981;
            color: white;
        }
        th {
            padding: 10px 6px;
            text-align: center;
            font-weight: bold;
            font-size: 9px;
            border: 1px solid #d1fae5;
        }
        td {
            padding: 8px 6px;
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
        .amount-cell {
            font-weight: bold;
            color: #059669;
        }
        .badge {
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 7px;
            font-weight: bold;
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
        .total-row {
            background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%) !important;
            font-weight: bold;
            font-size: 11px;
            border-top: 4px solid #10b981 !important;
        }
        .total-row td {
            padding: 15px 6px;
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
        <h1>تقرير الإيرادات</h1>
        <p>تقرير مالي شامل لجميع المدفوعات والإيرادات</p>
        <p>تاريخ التصدير: {{ date('Y-m-d H:i:s') }}</p>
    </div>

    @php
        $transactionCount = $revenueData->count();
        $activeRevenue = 0;
        $pendingRevenue = 0;
        $inactiveRevenue = 0;

        foreach($revenueData as $data) {
            if($data['status'] == 'active') {
                $activeRevenue += $data['amount'];
            } elseif($data['status'] == 'pending') {
                $pendingRevenue += $data['amount'];
            } else {
                $inactiveRevenue += $data['amount'];
            }
        }
    @endphp

    @if(isset($filters['start_date']) || isset($filters['end_date']) || isset($filters['payment_method']))
    <div class="filter-info">
        <strong>الفلاتر المطبقة:</strong>
        @if(isset($filters['start_date']))
            من تاريخ: {{ $filters['start_date'] }}
        @endif
        @if(isset($filters['end_date']))
            إلى تاريخ: {{ $filters['end_date'] }}
        @endif
        @if(isset($filters['payment_method']))
            | طريقة الدفع: {{ $filters['payment_method'] }}
        @endif
    </div>
    @endif

    <div class="revenue-summary">
        <h2>ملخص الإيرادات</h2>
        <div class="revenue-total">{{ number_format($totalRevenue) }} دج</div>
        <div class="revenue-details">
            <div class="revenue-row">
                <div class="revenue-item">
                    <div class="revenue-label">عدد المعاملات</div>
                    <div class="revenue-value">{{ $transactionCount }}</div>
                </div>
                <div class="revenue-item">
                    <div class="revenue-label">الإيرادات النشطة</div>
                    <div class="revenue-value">{{ number_format($activeRevenue) }} دج</div>
                </div>
                <div class="revenue-item">
                    <div class="revenue-label">الإيرادات المعلقة</div>
                    <div class="revenue-value">{{ number_format($pendingRevenue) }} دج</div>
                </div>
            </div>
        </div>
    </div>

    <table>
        <thead>
            <tr>
                <th style="width: 4%;">الرقم</th>
                <th style="width: 13%;">التاريخ</th>
                <th style="width: 18%;">اسم الطالب</th>
                <th style="width: 24%;">الدورة/الباقة</th>
                <th style="width: 13%;">طريقة الدفع</th>
                <th style="width: 13%;">المبلغ (دج)</th>
                <th style="width: 10%;">الحالة</th>
            </tr>
        </thead>
        <tbody>
            @foreach($revenueData as $index => $data)
            @php
                $statusBadge = match($data['status']) {
                    'active' => 'badge-active',
                    'inactive' => 'badge-inactive',
                    'pending' => 'badge-pending',
                    default => ''
                };
                $statusText = match($data['status']) {
                    'active' => 'نشط',
                    'inactive' => 'غير نشط',
                    'pending' => 'قيد الانتظار',
                    default => $data['status']
                };
            @endphp
            <tr>
                <td>{{ $index + 1 }}</td>
                <td>{{ $data['date'] }}</td>
                <td class="text-right">{{ $data['student'] }}</td>
                <td class="text-right">{{ $data['course_package'] }}</td>
                <td>{{ $data['payment_method'] }}</td>
                <td class="amount-cell">{{ number_format($data['amount']) }}</td>
                <td><span class="badge {{ $statusBadge }}">{{ $statusText }}</span></td>
            </tr>
            @endforeach
        </tbody>
        <tfoot>
            <tr class="total-row">
                <td colspan="5" style="text-align: center; font-size: 12px;">
                    <strong>إجمالي الإيرادات</strong>
                </td>
                <td style="font-size: 13px; color: #059669;">
                    <strong>{{ number_format($totalRevenue) }} دج</strong>
                </td>
                <td>{{ $transactionCount }} معاملة</td>
            </tr>
        </tfoot>
    </table>

    <div class="footer">
        <p><strong>تقرير الإيرادات</strong></p>
        <p>تم إنشاء هذا التقرير بواسطة نظام إدارة المنصة التعليمية</p>
        <p>جميع الحقوق محفوظة © {{ date('Y') }}</p>
    </div>
</body>
</html>
