<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\Exports\CourseExportService;
use App\Services\Exports\SubscriptionExportService;
use App\Services\Exports\CodeExportService;
use App\Services\Exports\PaymentReceiptExportService;
use Illuminate\Http\Request;

class ExportController extends Controller
{
    protected CourseExportService $courseExportService;
    protected SubscriptionExportService $subscriptionExportService;
    protected CodeExportService $codeExportService;
    protected PaymentReceiptExportService $receiptExportService;

    public function __construct(
        CourseExportService $courseExportService,
        SubscriptionExportService $subscriptionExportService,
        CodeExportService $codeExportService,
        PaymentReceiptExportService $receiptExportService
    ) {
        $this->courseExportService = $courseExportService;
        $this->subscriptionExportService = $subscriptionExportService;
        $this->codeExportService = $codeExportService;
        $this->receiptExportService = $receiptExportService;
    }

    /**
     * Display the unified reports page
     * GET /admin/exports
     */
    public function index()
    {
        return view('admin.reports.index');
    }

    // ===== Course Exports =====

    /**
     * Export courses with format selection
     * GET /admin/exports/courses
     */
    public function exportCourses(Request $request)
    {
        $filters = $request->only(['is_published', 'subject_id', 'level', 'is_free']);
        $format = $request->get('format', 'csv');

        return match($format) {
            'excel' => $this->courseExportService->exportToExcel($filters),
            'pdf' => $this->courseExportService->exportToPDF($filters),
            default => $this->courseExportService->exportToCSV($filters)
        };
    }

    /**
     * Export course enrollments
     * GET /admin/exports/courses/{id}/enrollments
     */
    public function exportCourseEnrollments($id)
    {
        return $this->courseExportService->exportEnrollmentsToCSV($id);
    }

    /**
     * Export course statistics with format selection
     * GET /admin/exports/courses/statistics
     */
    public function exportCourseStatistics(Request $request)
    {
        $format = $request->get('format', 'csv');

        return match($format) {
            'excel' => $this->courseExportService->exportStatisticsToExcel(),
            'pdf' => $this->courseExportService->exportStatisticsToPDF(),
            default => $this->courseExportService->exportStatisticsToCSV()
        };
    }

    // ===== Subscription Exports =====

    /**
     * Export subscriptions with format selection
     * GET /admin/exports/subscriptions
     */
    public function exportSubscriptions(Request $request)
    {
        $filters = $request->only([
            'status',
            'subscription_method',
            'course_id',
            'package_id',
            'start_date',
            'end_date'
        ]);
        $format = $request->get('format', 'csv');

        return match($format) {
            'excel' => $this->subscriptionExportService->exportToExcel($filters),
            'pdf' => $this->subscriptionExportService->exportToPDF($filters),
            default => $this->subscriptionExportService->exportToCSV($filters)
        };
    }

    /**
     * Export package statistics
     * GET /admin/exports/packages/statistics
     */
    public function exportPackageStatistics()
    {
        return $this->subscriptionExportService->exportPackageStatisticsToCSV();
    }

    /**
     * Export revenue report with format selection
     * GET /admin/exports/revenue
     */
    public function exportRevenue(Request $request)
    {
        $filters = $request->only(['start_date', 'end_date', 'subscription_method', 'payment_method']);
        $format = $request->get('format', 'csv');

        return match($format) {
            'excel' => $this->subscriptionExportService->exportRevenueReportToExcel($filters),
            'pdf' => $this->subscriptionExportService->exportRevenueReportToPDF($filters),
            default => $this->subscriptionExportService->exportRevenueReportToCSV($filters)
        };
    }

    // ===== Subscription Code Exports =====

    /**
     * Export subscription codes
     * GET /admin/exports/codes
     */
    public function exportCodes(Request $request)
    {
        $filters = $request->only(['code_type', 'is_active', 'course_id', 'package_id']);
        return $this->codeExportService->exportToCSV($filters);
    }

    /**
     * Export code usage statistics
     * GET /admin/exports/codes/usage
     */
    public function exportCodeUsageStatistics()
    {
        return $this->codeExportService->exportUsageStatisticsToCSV();
    }

    // ===== Payment Receipt Exports =====

    /**
     * Export payment receipts
     * GET /admin/exports/receipts
     */
    public function exportReceipts(Request $request)
    {
        $filters = $request->only(['status', 'course_id', 'package_id', 'start_date', 'end_date']);
        return $this->receiptExportService->exportToCSV($filters);
    }

    /**
     * Export payment receipts statistics
     * GET /admin/exports/receipts/statistics
     */
    public function exportReceiptStatistics(Request $request)
    {
        $filters = $request->only(['start_date', 'end_date']);
        return $this->receiptExportService->exportStatisticsToCSV($filters);
    }
}
