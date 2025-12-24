<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>Planning d'etude</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'DejaVu Sans', sans-serif;
            font-size: 10px;
            line-height: 1.5;
            color: #333;
            background: #fff;
        }

        .container {
            padding: 15px;
        }

        /* Header */
        .header {
            text-align: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 3px solid #6366f1;
        }

        .header h1 {
            color: #6366f1;
            font-size: 20px;
            margin-bottom: 5px;
        }

        .header .subtitle {
            color: #666;
            font-size: 12px;
            margin-bottom: 8px;
        }

        .header .date-range {
            margin-top: 8px;
            padding: 8px 15px;
            background: #f3f4f6;
            display: inline-block;
            font-size: 11px;
        }

        /* Stats Table */
        .stats-table {
            width: 100%;
            margin-bottom: 20px;
            border-collapse: collapse;
        }

        .stats-table td {
            width: 25%;
            text-align: center;
            padding: 12px 8px;
            background: #f8fafc;
            border: 1px solid #e5e7eb;
        }

        .stat-value {
            font-size: 18px;
            font-weight: bold;
            color: #6366f1;
            display: block;
            margin-bottom: 3px;
        }

        .stat-label {
            font-size: 9px;
            color: #666;
        }

        /* Day Section */
        .day-section {
            margin-bottom: 15px;
            page-break-inside: avoid;
        }

        .day-header {
            background: #6366f1;
            color: white;
            padding: 8px 12px;
            font-size: 12px;
            font-weight: bold;
        }

        /* Sessions Table */
        .sessions-table {
            width: 100%;
            border-collapse: collapse;
            background: white;
        }

        .sessions-table th {
            background: #f3f4f6;
            padding: 8px 10px;
            text-align: center;
            font-weight: bold;
            font-size: 9px;
            color: #374151;
            border: 1px solid #e5e7eb;
        }

        .sessions-table td {
            padding: 6px 10px;
            border: 1px solid #e5e7eb;
            font-size: 9px;
            text-align: center;
        }

        /* Row colors */
        .row-study {
            background: #fff;
        }

        .row-break {
            background: #ecfdf5;
        }

        .row-prayer {
            background: #fffbeb;
        }

        /* Time */
        .time-cell {
            font-weight: bold;
            color: #6366f1;
            width: 60px;
        }

        /* Subject */
        .subject-cell {
            font-weight: bold;
            color: #4338ca;
        }

        .break-text {
            color: #10b981;
            font-weight: bold;
        }

        .prayer-text {
            color: #f59e0b;
            font-weight: bold;
        }

        /* Duration */
        .duration-cell {
            color: #6b7280;
            width: 50px;
        }

        /* Footer */
        .footer {
            margin-top: 20px;
            text-align: center;
            padding-top: 15px;
            border-top: 2px solid #e5e7eb;
            color: #9ca3af;
            font-size: 9px;
        }

        .footer .logo {
            color: #6366f1;
            font-weight: bold;
            font-size: 12px;
            margin-bottom: 3px;
        }

        .page-break {
            page-break-after: always;
        }

        /* Color indicators */
        .indicator {
            display: inline-block;
            width: 8px;
            height: 8px;
            margin-left: 5px;
            vertical-align: middle;
        }
        .indicator-study { background: #6366f1; }
        .indicator-break { background: #10b981; }
        .indicator-prayer { background: #f59e0b; }
    </style>
</head>
<body>
    <div class="container">
        <!-- Header -->
        <div class="header">
            <h1>MEMO - Planificateur Intelligent</h1>
            <div class="subtitle">Planning d'etude personnel</div>
            <div class="date-range">
                Du {{ $startDate->format('d/m/Y') }} au {{ $endDate->format('d/m/Y') }}
            </div>
        </div>

        <!-- Stats -->
        <table class="stats-table">
            <tr>
                <td>
                    <span class="stat-value">{{ $totalSessions }}</span>
                    <span class="stat-label">Seances d'etude</span>
                </td>
                <td>
                    <span class="stat-value">{{ $totalBreaks }}</span>
                    <span class="stat-label">Pauses</span>
                </td>
                <td>
                    <span class="stat-value">{{ round($totalStudyMinutes / 60, 1) }}</span>
                    <span class="stat-label">Heures d'etude</span>
                </td>
                <td>
                    <span class="stat-value">{{ $sessionsByDate->count() }}</span>
                    <span class="stat-label">Jours</span>
                </td>
            </tr>
        </table>

        <!-- Legend -->
        <div style="margin-bottom: 15px; font-size: 9px; text-align: center;">
            <span class="indicator indicator-study"></span> Etude
            <span style="margin-left: 15px;"><span class="indicator indicator-break"></span> Pause</span>
            <span style="margin-left: 15px;"><span class="indicator indicator-prayer"></span> Priere</span>
        </div>

        <!-- Sessions by Day -->
        @foreach($sessionsByDate as $date => $daySessions)
            @php
                $dateCarbon = \Carbon\Carbon::parse($date);
                $frenchDays = [
                    'Sunday' => 'Dimanche',
                    'Monday' => 'Lundi',
                    'Tuesday' => 'Mardi',
                    'Wednesday' => 'Mercredi',
                    'Thursday' => 'Jeudi',
                    'Friday' => 'Vendredi',
                    'Saturday' => 'Samedi',
                ];
                $dayName = $frenchDays[$dateCarbon->format('l')] ?? $dateCarbon->format('l');
            @endphp

            <div class="day-section">
                <div class="day-header">
                    {{ $dayName }} - {{ $dateCarbon->format('d/m/Y') }}
                </div>

                <table class="sessions-table">
                    <thead>
                        <tr>
                            <th>Heure</th>
                            <th>Matiere / Activite</th>
                            <th>Duree</th>
                            <th>Contenu</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($daySessions as $session)
                            @php
                                $isBreak = $session->is_break ?? false;
                                $contentTitle = $session->content_title ?? '';
                                $isPrayer = mb_strpos($contentTitle, 'صلا') !== false;
                                $rowClass = $isPrayer ? 'row-prayer' : ($isBreak ? 'row-break' : 'row-study');

                                // Get French subject name
                                $subjectName = 'Matiere';
                                if ($session->subject) {
                                    $subjectName = $session->subject->name_fr
                                        ?? $session->subject->name_en
                                        ?? $session->subject->name
                                        ?? 'Matiere';
                                }

                                // Session type translation
                                $sessionTypes = [
                                    'study' => 'Etude',
                                    'revision' => 'Revision',
                                    'practice' => 'Exercices',
                                    'longRevision' => 'Revision approfondie',
                                    'test' => 'Test',
                                    'break' => 'Pause',
                                ];
                                $sessionType = $sessionTypes[$session->session_type ?? 'study'] ?? 'Etude';
                            @endphp
                            <tr class="{{ $rowClass }}">
                                <td class="time-cell">
                                    {{ substr($session->scheduled_start_time, 0, 5) }}
                                </td>
                                <td>
                                    @if($isBreak)
                                        @if($isPrayer)
                                            <span class="prayer-text">Priere</span>
                                        @else
                                            <span class="break-text">Pause</span>
                                        @endif
                                    @else
                                        <span class="subject-cell">{{ $subjectName }}</span>
                                    @endif
                                </td>
                                <td class="duration-cell">
                                    {{ $session->duration_minutes }} min
                                </td>
                                <td>
                                    @if(!$isBreak)
                                        {{ $sessionType }}
                                    @else
                                        -
                                    @endif
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>

            @if(!$loop->last && $loop->iteration % 4 == 0)
                <div class="page-break"></div>
            @endif
        @endforeach

        <!-- Footer -->
        <div class="footer">
            <div class="logo">MEMO - Planificateur Intelligent</div>
            <div>Genere le {{ $generatedAt->format('d/m/Y') }} a {{ $generatedAt->format('H:i') }}</div>
        </div>
    </div>
</body>
</html>
