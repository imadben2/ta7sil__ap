<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>شهادة إتمام - {{ $certificate_number }}</title>
    <style>
        @page {
            margin: 0;
            padding: 0;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Cairo', 'Amiri', 'DejaVu Sans', sans-serif;
            direction: rtl;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .certificate {
            width: 1000px;
            height: 700px;
            background: #fff;
            border-radius: 20px;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.3);
            position: relative;
            overflow: hidden;
        }

        .certificate::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 10px;
            background: linear-gradient(90deg, #667eea, #764ba2, #f093fb, #f5576c);
        }

        .certificate::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 10px;
            background: linear-gradient(90deg, #667eea, #764ba2, #f093fb, #f5576c);
        }

        .border-decoration {
            position: absolute;
            top: 20px;
            left: 20px;
            right: 20px;
            bottom: 20px;
            border: 3px solid #667eea;
            border-radius: 15px;
            pointer-events: none;
        }

        .corner-decoration {
            position: absolute;
            width: 80px;
            height: 80px;
            border: 3px solid #764ba2;
        }

        .corner-top-right {
            top: 35px;
            right: 35px;
            border-left: none;
            border-bottom: none;
            border-top-right-radius: 15px;
        }

        .corner-top-left {
            top: 35px;
            left: 35px;
            border-right: none;
            border-bottom: none;
            border-top-left-radius: 15px;
        }

        .corner-bottom-right {
            bottom: 35px;
            right: 35px;
            border-left: none;
            border-top: none;
            border-bottom-right-radius: 15px;
        }

        .corner-bottom-left {
            bottom: 35px;
            left: 35px;
            border-right: none;
            border-top: none;
            border-bottom-left-radius: 15px;
        }

        .content {
            padding: 60px 80px;
            text-align: center;
            position: relative;
            z-index: 1;
        }

        .logo-section {
            margin-bottom: 20px;
        }

        .logo {
            width: 80px;
            height: 80px;
            margin: 0 auto;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 28px;
            font-weight: bold;
        }

        .title {
            font-size: 42px;
            font-weight: bold;
            color: #333;
            margin-bottom: 10px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .subtitle {
            font-size: 20px;
            color: #666;
            margin-bottom: 30px;
        }

        .certify-text {
            font-size: 18px;
            color: #555;
            margin-bottom: 15px;
        }

        .student-name {
            font-size: 36px;
            font-weight: bold;
            color: #333;
            margin-bottom: 20px;
            padding: 10px 40px;
            display: inline-block;
            border-bottom: 3px solid #764ba2;
        }

        .completion-text {
            font-size: 18px;
            color: #555;
            margin-bottom: 15px;
        }

        .course-title {
            font-size: 24px;
            font-weight: bold;
            color: #667eea;
            margin-bottom: 25px;
            padding: 10px 30px;
            background: rgba(102, 126, 234, 0.1);
            border-radius: 10px;
            display: inline-block;
        }

        .details-section {
            display: flex;
            justify-content: space-around;
            margin-top: 30px;
            padding-top: 25px;
            border-top: 2px dashed #ddd;
        }

        .detail-item {
            text-align: center;
        }

        .detail-label {
            font-size: 12px;
            color: #888;
            margin-bottom: 5px;
        }

        .detail-value {
            font-size: 16px;
            font-weight: bold;
            color: #333;
        }

        .signatures-section {
            display: flex;
            justify-content: space-between;
            margin-top: 40px;
            padding: 0 60px;
        }

        .signature-item {
            text-align: center;
            width: 200px;
        }

        .signature-line {
            border-top: 2px solid #333;
            padding-top: 10px;
            margin-top: 40px;
        }

        .signature-name {
            font-size: 14px;
            font-weight: bold;
            color: #333;
        }

        .signature-title {
            font-size: 12px;
            color: #666;
        }

        .qr-section {
            position: absolute;
            bottom: 50px;
            left: 50px;
            text-align: center;
        }

        .qr-code {
            width: 80px;
            height: 80px;
            background: #f0f0f0;
            border: 2px solid #ddd;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 10px;
            color: #999;
        }

        .qr-label {
            font-size: 10px;
            color: #888;
            margin-top: 5px;
        }

        .certificate-number {
            position: absolute;
            bottom: 50px;
            right: 50px;
            text-align: left;
        }

        .cert-num-label {
            font-size: 10px;
            color: #888;
        }

        .cert-num-value {
            font-size: 14px;
            font-weight: bold;
            color: #667eea;
            font-family: monospace;
        }

        .score-badge {
            display: inline-block;
            padding: 5px 15px;
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
            color: white;
            border-radius: 20px;
            font-size: 14px;
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <div class="certificate">
        <div class="border-decoration"></div>
        <div class="corner-decoration corner-top-right"></div>
        <div class="corner-decoration corner-top-left"></div>
        <div class="corner-decoration corner-bottom-right"></div>
        <div class="corner-decoration corner-bottom-left"></div>

        <div class="content">
            <div class="logo-section">
                <div class="logo">MB</div>
            </div>

            <h1 class="title">شهادة إتمام</h1>
            <p class="subtitle">Certificate of Completion</p>

            <p class="certify-text">نشهد بأن</p>
            <div class="student-name">{{ $student_name }}</div>

            <p class="completion-text">قد أتم بنجاح دورة</p>
            <div class="course-title">{{ $course_title }}</div>

            @if($average_score)
            <div class="score-badge">
                المعدل: {{ number_format($average_score, 1) }}%
            </div>
            @endif

            <div class="details-section">
                <div class="detail-item">
                    <div class="detail-label">تاريخ الإتمام</div>
                    <div class="detail-value">{{ $completion_date }}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">المدرب</div>
                    <div class="detail-value">{{ $instructor_name ?? 'Memo BAC' }}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">تاريخ الإصدار</div>
                    <div class="detail-value">{{ now()->format('Y/m/d') }}</div>
                </div>
            </div>

            <div class="signatures-section">
                <div class="signature-item">
                    <div class="signature-line">
                        <div class="signature-name">{{ $instructor_name ?? 'Memo BAC' }}</div>
                        <div class="signature-title">المدرب</div>
                    </div>
                </div>
                <div class="signature-item">
                    <div class="signature-line">
                        <div class="signature-name">منصة Memo BAC</div>
                        <div class="signature-title">إدارة المنصة</div>
                    </div>
                </div>
            </div>
        </div>

        <div class="qr-section">
            <div class="qr-code">
                QR
            </div>
            <div class="qr-label">امسح للتحقق</div>
        </div>

        <div class="certificate-number">
            <div class="cert-num-label">رقم الشهادة</div>
            <div class="cert-num-value">{{ $certificate_number }}</div>
        </div>
    </div>
</body>
</html>
