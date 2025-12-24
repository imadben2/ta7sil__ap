<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\AnalyticsService;
use App\Services\ReportGenerationService;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Response;

class AnalyticsController extends Controller
{
    protected AnalyticsService $analyticsService;
    protected ReportGenerationService $reportService;

    public function __construct(
        AnalyticsService $analyticsService,
        ReportGenerationService $reportService
    ) {
        $this->analyticsService = $analyticsService;
        $this->reportService = $reportService;
    }

    /**
     * Get complete analytics dashboard (aggregated data).
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function dashboard(Request $request): JsonResponse
    {
        $period = $request->get('period', 'last_30_days');
        $user = $request->user();

        try {
            // Get overview data
            $overview = $this->analyticsService->getOverview($user, $period);

            // Get patterns
            $patterns = $this->analyticsService->identifyPatterns($user);

            // Get recommendations
            $recommendations = $this->analyticsService->getRecommendations($user);

            // Aggregate all data
            $dashboardData = [
                'overview' => $overview,
                'weekly_activity' => $overview['study']['weekly_breakdown'] ?? [],
                'subject_performance' => $overview['subjects'] ?? [],
                'weak_areas' => $overview['weak_areas'] ?? [],
                'study_patterns' => $patterns,
                'recommendations' => $recommendations,
            ];

            return response()->json([
                'success' => true,
                'data' => $dashboardData,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load analytics dashboard',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get analytics overview.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function overview(Request $request): JsonResponse
    {
        $period = $request->get('period', 'last_30_days');

        $data = $this->analyticsService->getOverview($request->user(), $period);

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    /**
     * Get trends data for charts.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function trends(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'metric' => 'required|in:study_time,scores,sessions',
            'period' => 'required|in:week,month,year',
        ]);

        $data = $this->analyticsService->getTrends(
            $request->user(),
            $validated['metric'],
            $validated['period']
        );

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    /**
     * Get activity heatmap data.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function heatmap(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
        ]);

        $startDate = Carbon::parse($validated['start_date']);
        $endDate = Carbon::parse($validated['end_date']);

        // Limit to 365 days
        if ($startDate->diffInDays($endDate) > 365) {
            return response()->json([
                'success' => false,
                'message' => 'Date range cannot exceed 365 days',
            ], 400);
        }

        $data = $this->analyticsService->getHeatmapData(
            $request->user(),
            $startDate,
            $endDate
        );

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    /**
     * Generate detailed report.
     *
     * @param Request $request
     * @return JsonResponse|\Symfony\Component\HttpFoundation\BinaryFileResponse
     */
    public function report(Request $request)
    {
        $validated = $request->validate([
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'format' => 'sometimes|in:json,pdf',
        ]);

        $startDate = Carbon::parse($validated['start_date']);
        $endDate = Carbon::parse($validated['end_date']);
        $format = $validated['format'] ?? 'json';

        $data = $this->analyticsService->generateReport(
            $request->user(),
            $startDate,
            $endDate
        );

        if ($format === 'pdf') {
            try {
                $pdfPath = $this->reportService->generatePdfReport($request->user(), $data);

                return Response::download($pdfPath, basename($pdfPath), [
                    'Content-Type' => 'application/pdf',
                ])->deleteFileAfterSend(true);
            } catch (\Exception $e) {
                return response()->json([
                    'success' => false,
                    'message' => 'Failed to generate PDF report',
                    'error' => $e->getMessage(),
                ], 500);
            }
        }

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    /**
     * Compare two time periods.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function compare(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'period1' => 'required|in:this_week,last_week,this_month,last_month',
            'period2' => 'required|in:this_week,last_week,this_month,last_month',
        ]);

        $user = $request->user();

        // Get data for both periods
        $data1 = $this->getComparisonData($user, $validated['period1']);
        $data2 = $this->getComparisonData($user, $validated['period2']);

        // Calculate differences
        $comparison = [
            'period1' => [
                'name' => $this->getPeriodName($validated['period1']),
                'data' => $data1,
            ],
            'period2' => [
                'name' => $this->getPeriodName($validated['period2']),
                'data' => $data2,
            ],
            'differences' => [
                'study_hours' => [
                    'value' => $data1['study']['total_hours'] - $data2['study']['total_hours'],
                    'percentage' => $data2['study']['total_hours'] > 0
                        ? round((($data1['study']['total_hours'] - $data2['study']['total_hours']) / $data2['study']['total_hours']) * 100, 1)
                        : 0,
                ],
                'completion_rate' => [
                    'value' => $data1['study']['completion_rate'] - $data2['study']['completion_rate'],
                    'percentage' => $data1['study']['completion_rate'] - $data2['study']['completion_rate'],
                ],
                'average_score' => [
                    'value' => $data1['performance']['average_quiz_score'] - $data2['performance']['average_quiz_score'],
                    'percentage' => $data2['performance']['average_quiz_score'] > 0
                        ? round((($data1['performance']['average_quiz_score'] - $data2['performance']['average_quiz_score']) / $data2['performance']['average_quiz_score']) * 100, 1)
                        : 0,
                ],
            ],
        ];

        return response()->json([
            'success' => true,
            'data' => $comparison,
        ]);
    }

    /**
     * Get patterns and insights.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function patterns(Request $request): JsonResponse
    {
        $patterns = $this->analyticsService->identifyPatterns($request->user());

        return response()->json([
            'success' => true,
            'data' => $patterns,
        ]);
    }

    /**
     * Get personalized recommendations.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function recommendations(Request $request): JsonResponse
    {
        $recommendations = $this->analyticsService->getRecommendations($request->user());

        return response()->json([
            'success' => true,
            'data' => $recommendations,
        ]);
    }

    /**
     * Get comparison data for a period.
     */
    private function getComparisonData($user, string $period): array
    {
        $mappedPeriod = match ($period) {
            'this_week' => 'last_7_days',
            'last_week' => 'last_7_days', // Will be adjusted
            'this_month' => 'this_month',
            'last_month' => 'last_month',
            default => 'last_30_days',
        };

        return $this->analyticsService->getOverview($user, $mappedPeriod);
    }

    /**
     * Get human-readable period name.
     */
    private function getPeriodName(string $period): string
    {
        return match ($period) {
            'this_week' => 'هذا الأسبوع',
            'last_week' => 'الأسبوع الماضي',
            'this_month' => 'هذا الشهر',
            'last_month' => 'الشهر الماضي',
            default => $period,
        };
    }

    /**
     * Get enhanced planner analytics.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function plannerAnalytics(Request $request): JsonResponse
    {
        $period = $request->get('period', 'last_30_days');
        $user = $request->user();

        try {
            $analytics = $this->analyticsService->getPlannerAnalytics($user, $period);

            return response()->json([
                'success' => true,
                'data' => $analytics,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load planner analytics',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get subject-specific analytics.
     *
     * @param Request $request
     * @param int $subject_id
     * @return JsonResponse
     */
    public function subjectAnalytics(Request $request, int $subject_id): JsonResponse
    {
        $period = $request->get('period', 'last_30_days');
        $user = $request->user();

        try {
            $analytics = $this->analyticsService->getSubjectAnalytics($user, $subject_id, $period);

            return response()->json([
                'success' => true,
                'data' => $analytics,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load subject analytics',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get weak areas list.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function weakAreas(Request $request): JsonResponse
    {
        $filter = $request->get('filter'); // critical, important, needs_improvement
        $subjectId = $request->get('subject_id');
        $user = $request->user();

        try {
            $weakAreas = $this->analyticsService->getWeakAreas($user, $filter, $subjectId);

            return response()->json([
                'success' => true,
                'data' => $weakAreas,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load weak areas',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get weak area detail.
     *
     * @param Request $request
     * @param int $topic_id
     * @return JsonResponse
     */
    public function weakAreaDetail(Request $request, int $topic_id): JsonResponse
    {
        $user = $request->user();

        try {
            $detail = $this->analyticsService->getWeakAreaDetail($user, $topic_id);

            return response()->json([
                'success' => true,
                'data' => $detail,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load weak area detail',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Create improvement plan for weak area.
     *
     * @param Request $request
     * @param int $topic_id
     * @return JsonResponse
     */
    public function createImprovementPlan(Request $request, int $topic_id): JsonResponse
    {
        $validated = $request->validate([
            'start_date' => 'sometimes|date',
            'preferred_time_slots' => 'sometimes|array',
            'preferred_time_slots.*' => 'in:morning,afternoon,evening,night',
            'hours_per_day' => 'sometimes|numeric|min:0.5|max:8',
        ]);

        $user = $request->user();

        try {
            $plan = $this->analyticsService->createImprovementPlan($user, $topic_id, $validated);

            return response()->json([
                'success' => true,
                'data' => $plan,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to create improvement plan',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get progress tracking data.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function progress(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'period' => 'required|in:week,month,3_months,custom',
            'start_date' => 'required_if:period,custom|date',
            'end_date' => 'required_if:period,custom|date|after_or_equal:start_date',
        ]);

        $user = $request->user();

        try {
            $progress = $this->analyticsService->getProgress(
                $user,
                $validated['period'],
                $validated['start_date'] ?? null,
                $validated['end_date'] ?? null
            );

            return response()->json([
                'success' => true,
                'data' => $progress,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load progress data',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Export analytics report with enhanced options.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function exportReport(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'report_type' => 'required|in:comprehensive,summary,subject',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'format' => 'required|in:pdf,csv,json',
            'language' => 'sometimes|in:ar,fr,en',
            'include_charts' => 'sometimes|boolean',
            'include_recommendations' => 'sometimes|boolean',
            'subject_id' => 'required_if:report_type,subject|integer',
        ]);

        $user = $request->user();

        try {
            $result = $this->analyticsService->generateExportReport($user, $validated);

            return response()->json([
                'success' => true,
                'data' => $result,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to generate export report',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Compare performance across subjects.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function compareSubjects(Request $request): JsonResponse
    {
        $period = $request->get('period', 'last_30_days');
        $user = $request->user();

        try {
            $comparison = $this->analyticsService->compareSubjects($user, $period);

            return response()->json([
                'success' => true,
                'data' => $comparison,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to compare subjects',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
