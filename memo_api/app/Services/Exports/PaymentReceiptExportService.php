<?php

namespace App\Services\Exports;

use App\Models\PaymentReceipt;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Response;

class PaymentReceiptExportService
{
    /**
     * Export payment receipts to CSV
     */
    public function exportToCSV(array $filters = [])
    {
        $receipts = $this->getReceipts($filters);

        $filename = 'payment_receipts_' . date('Y-m-d_His') . '.csv';

        $headers = [
            'Content-Type' => 'text/csv; charset=UTF-8',
            'Content-Disposition' => 'attachment; filename="' . $filename . '"',
        ];

        $callback = function() use ($receipts) {
            $file = fopen('php://output', 'w');

            // UTF-8 BOM
            fprintf($file, chr(0xEF).chr(0xBB).chr(0xBF));

            // Headers
            fputcsv($file, [
                'ID',
                'اسم الطالب',
                'البريد الإلكتروني',
                'الدورة/الباقة',
                'المبلغ (دج)',
                'طريقة الدفع',
                'مرجع المعاملة',
                'الحالة',
                'تاريخ الإرسال',
                'تاريخ المراجعة',
                'راجعه',
                'ملاحظات الإدارة',
            ]);

            foreach ($receipts as $receipt) {
                $courseOrPackage = $receipt->course
                    ? $receipt->course->title_ar
                    : ($receipt->package ? $receipt->package->name_ar : '');

                fputcsv($file, [
                    $receipt->id,
                    $receipt->user->full_name_ar,
                    $receipt->user->email,
                    $courseOrPackage,
                    $receipt->amount_dzd,
                    $receipt->payment_method ?? '',
                    $receipt->transaction_reference ?? '',
                    $receipt->status,
                    $receipt->submitted_at?->format('Y-m-d H:i:s') ?? '',
                    $receipt->reviewed_at?->format('Y-m-d H:i:s') ?? '',
                    $receipt->reviewer?->full_name_ar ?? '',
                    $receipt->admin_notes ?? '',
                ]);
            }

            fclose($file);
        };

        return Response::stream($callback, 200, $headers);
    }

    /**
     * Export payment receipts statistics
     */
    public function exportStatisticsToCSV(array $filters = [])
    {
        $query = PaymentReceipt::with(['user', 'course', 'package']);

        if (isset($filters['start_date'])) {
            $query->where('submitted_at', '>=', $filters['start_date']);
        }

        if (isset($filters['end_date'])) {
            $query->where('submitted_at', '<=', $filters['end_date']);
        }

        $receipts = $query->get();

        $filename = 'payment_receipts_statistics_' . date('Y-m-d_His') . '.csv';

        $headers = [
            'Content-Type' => 'text/csv; charset=UTF-8',
            'Content-Disposition' => 'attachment; filename="' . $filename . '"',
        ];

        $callback = function() use ($receipts) {
            $file = fopen('php://output', 'w');

            // UTF-8 BOM
            fprintf($file, chr(0xEF).chr(0xBB).chr(0xBF));

            // Summary statistics
            $totalReceipts = $receipts->count();
            $pendingReceipts = $receipts->where('status', 'pending')->count();
            $approvedReceipts = $receipts->where('status', 'approved')->count();
            $rejectedReceipts = $receipts->where('status', 'rejected')->count();
            $totalApprovedAmount = $receipts->where('status', 'approved')->sum('amount_dzd');

            // Write summary
            fputcsv($file, ['===== ملخص إحصائيات إيصالات الدفع =====']);
            fputcsv($file, ['']);
            fputcsv($file, ['إجمالي الإيصالات', $totalReceipts]);
            fputcsv($file, ['الإيصالات المعلقة', $pendingReceipts]);
            fputcsv($file, ['الإيصالات المقبولة', $approvedReceipts]);
            fputcsv($file, ['الإيصالات المرفوضة', $rejectedReceipts]);
            fputcsv($file, ['إجمالي المبلغ المقبول (دج)', number_format($totalApprovedAmount, 2)]);
            fputcsv($file, ['']);
            fputcsv($file, ['']);

            // Detailed breakdown
            fputcsv($file, ['===== التفاصيل =====']);
            fputcsv($file, [
                'التاريخ',
                'اسم الطالب',
                'الدورة/الباقة',
                'المبلغ (دج)',
                'الحالة',
                'المراجع',
            ]);

            foreach ($receipts as $receipt) {
                $courseOrPackage = $receipt->course
                    ? $receipt->course->title_ar
                    : ($receipt->package ? $receipt->package->name_ar : '');

                fputcsv($file, [
                    $receipt->submitted_at?->format('Y-m-d'),
                    $receipt->user->full_name_ar,
                    $courseOrPackage,
                    $receipt->amount_dzd,
                    $receipt->status,
                    $receipt->reviewer?->full_name_ar ?? '',
                ]);
            }

            fclose($file);
        };

        return Response::stream($callback, 200, $headers);
    }

    /**
     * Get receipts with filters
     */
    private function getReceipts(array $filters = []): Collection
    {
        $query = PaymentReceipt::with(['user', 'course', 'package', 'reviewer']);

        if (isset($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        if (isset($filters['course_id'])) {
            $query->where('course_id', $filters['course_id']);
        }

        if (isset($filters['package_id'])) {
            $query->where('package_id', $filters['package_id']);
        }

        if (isset($filters['start_date'])) {
            $query->where('submitted_at', '>=', $filters['start_date']);
        }

        if (isset($filters['end_date'])) {
            $query->where('submitted_at', '<=', $filters['end_date']);
        }

        return $query->get();
    }
}
