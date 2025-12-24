<?php

namespace App\Services;

use App\Models\User;
use Carbon\Carbon;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Support\Facades\View;

class ReportGenerationService
{
    protected AnalyticsService $analyticsService;

    public function __construct(AnalyticsService $analyticsService)
    {
        $this->analyticsService = $analyticsService;
    }

    /**
     * Generate PDF report for a user.
     */
    public function generatePdfReport(User $user, array $data): string
    {
        $pdf = Pdf::loadView('reports.analytics', [
            'user' => $user,
            'data' => $data,
            'generated_at' => now()->format('Y-m-d H:i'),
        ]);

        $pdf->setPaper('a4', 'portrait');

        $filename = sprintf(
            'report_%s_%s.pdf',
            $user->id,
            now()->format('Y-m-d_His')
        );

        $path = storage_path('app/reports/' . $filename);

        // Ensure directory exists
        if (!file_exists(storage_path('app/reports'))) {
            mkdir(storage_path('app/reports'), 0755, true);
        }

        $pdf->save($path);

        return $path;
    }

    /**
     * Generate weekly report for a user.
     */
    public function generateWeeklyReport(User $user): array
    {
        $startDate = now()->startOfWeek();
        $endDate = now()->endOfWeek();

        return $this->generatePeriodReport($user, $startDate, $endDate, 'أسبوعي');
    }

    /**
     * Generate monthly report for a user.
     */
    public function generateMonthlyReport(User $user): array
    {
        $startDate = now()->startOfMonth();
        $endDate = now()->endOfMonth();

        return $this->generatePeriodReport($user, $startDate, $endDate, 'شهري');
    }

    /**
     * Generate report for a specific period.
     */
    private function generatePeriodReport(User $user, Carbon $startDate, Carbon $endDate, string $periodType): array
    {
        $data = $this->analyticsService->generateReport($user, $startDate, $endDate);

        return [
            'type' => $periodType,
            'period' => [
                'start' => $startDate->format('Y-m-d'),
                'end' => $endDate->format('Y-m-d'),
            ],
            'summary' => $this->generateSummary($data),
            'highlights' => $this->generateHighlights($data),
            'insights' => $data['recommendations'],
            'full_data' => $data,
        ];
    }

    /**
     * Generate summary text for report.
     */
    private function generateSummary(array $data): string
    {
        $study = $data['overview']['study'];
        $performance = $data['overview']['performance'];

        $summary = sprintf(
            'خلال الفترة من %s إلى %s، ',
            $data['period']['start'],
            $data['period']['end']
        );

        $summary .= sprintf(
            'أكملت %d جلسة دراسية بإجمالي %.1f ساعة. ',
            $study['sessions_completed'],
            $study['total_hours']
        );

        if ($performance['quizzes_taken'] > 0) {
            $summary .= sprintf(
                'أنجزت %d اختبار بمتوسط %.1f%%. ',
                $performance['quizzes_taken'],
                $performance['average_quiz_score']
            );
        }

        if ($study['current_streak'] > 0) {
            $summary .= sprintf(
                'حافظت على streak لمدة %d أيام.',
                $study['current_streak']
            );
        }

        return $summary;
    }

    /**
     * Generate highlights list.
     */
    private function generateHighlights(array $data): array
    {
        $highlights = [];
        $study = $data['overview']['study'];
        $performance = $data['overview']['performance'];

        // Study highlights
        if ($study['completion_rate'] >= 80) {
            $highlights[] = [
                'icon' => 'fa-check-circle',
                'color' => 'green',
                'text' => sprintf('نسبة إكمال ممتازة: %.1f%%', $study['completion_rate']),
            ];
        }

        if ($study['current_streak'] >= 7) {
            $highlights[] = [
                'icon' => 'fa-fire',
                'color' => 'orange',
                'text' => sprintf('Streak رائع: %d أيام متتالية', $study['current_streak']),
            ];
        }

        // Performance highlights
        if ($performance['average_quiz_score'] >= 75) {
            $highlights[] = [
                'icon' => 'fa-star',
                'color' => 'gold',
                'text' => sprintf('أداء جيد: متوسط %.1f%% في الاختبارات', $performance['average_quiz_score']),
            ];
        }

        if ($performance['improvement_rate'] > 10) {
            $highlights[] = [
                'icon' => 'fa-chart-line',
                'color' => 'blue',
                'text' => sprintf('تحسن ملحوظ: +%.1f%%', $performance['improvement_rate']),
            ];
        }

        // Subject highlights
        foreach ($data['overview']['subjects'] as $subject) {
            if ($subject['status'] === 'strong') {
                $highlights[] = [
                    'icon' => 'fa-trophy',
                    'color' => 'purple',
                    'text' => sprintf('تفوق في %s: %.1f%%', $subject['subject'], $subject['average_score']),
                ];
                break; // Only show one strong subject
            }
        }

        return $highlights;
    }

    /**
     * Generate weekly summary for all active users.
     */
    public function generateWeeklySummariesForAll(): int
    {
        $users = User::where('role', 'student')
            ->where('status', 'active')
            ->get();

        $generated = 0;

        foreach ($users as $user) {
            try {
                $this->generateWeeklyReport($user);
                $generated++;
            } catch (\Exception $e) {
                \Log::error("Failed to generate weekly report for user {$user->id}: " . $e->getMessage());
            }
        }

        return $generated;
    }

    /**
     * Generate monthly summary for all active users.
     */
    public function generateMonthlySummariesForAll(): int
    {
        $users = User::where('role', 'student')
            ->where('status', 'active')
            ->get();

        $generated = 0;

        foreach ($users as $user) {
            try {
                $this->generateMonthlyReport($user);
                $generated++;
            } catch (\Exception $e) {
                \Log::error("Failed to generate monthly report for user {$user->id}: " . $e->getMessage());
            }
        }

        return $generated;
    }
}
