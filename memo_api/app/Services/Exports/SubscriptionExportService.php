<?php

namespace App\Services\Exports;

use App\Models\UserSubscription;
use App\Models\SubscriptionPackage;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Response;
use Maatwebsite\Excel\Facades\Excel;
use App\Exports\SubscriptionsExport;
use App\Exports\RevenueReportExport;
use Barryvdh\DomPDF\Facade\Pdf;

class SubscriptionExportService
{
    /**
     * Export subscriptions to CSV
     */
    public function exportToCSV(array $filters = [])
    {
        $subscriptions = $this->getSubscriptions($filters);

        $filename = 'subscriptions_export_' . date('Y-m-d_His') . '.csv';

        $headers = [
            'Content-Type' => 'text/csv; charset=UTF-8',
            'Content-Disposition' => 'attachment; filename="' . $filename . '"',
        ];

        $callback = function() use ($subscriptions) {
            $file = fopen('php://output', 'w');

            // UTF-8 BOM
            fprintf($file, chr(0xEF).chr(0xBB).chr(0xBF));

            // Headers
            fputcsv($file, [
                'ID',
                'اسم الطالب',
                'البريد الإلكتروني',
                'الدورة/الباقة',
                'النوع',
                'طريقة الاشتراك',
                'الحالة',
                'تاريخ البدء',
                'تاريخ الانتهاء',
                'تاريخ الإنشاء',
            ]);

            foreach ($subscriptions as $subscription) {
                $courseName = $subscription->course
                    ? $subscription->course->title_ar
                    : ($subscription->package ? $subscription->package->name_ar : '');

                $type = $subscription->course ? 'دورة' : 'باقة';

                fputcsv($file, [
                    $subscription->id,
                    $subscription->user->full_name_ar,
                    $subscription->user->email,
                    $courseName,
                    $type,
                    $subscription->subscription_method,
                    $subscription->status,
                    $subscription->started_at?->format('Y-m-d H:i:s') ?? '',
                    $subscription->expires_at?->format('Y-m-d H:i:s') ?? 'غير محدد',
                    $subscription->created_at->format('Y-m-d H:i:s'),
                ]);
            }

            fclose($file);
        };

        return Response::stream($callback, 200, $headers);
    }

    /**
     * Export subscriptions to Excel
     */
    public function exportToExcel(array $filters = [])
    {
        $subscriptions = $this->getSubscriptions($filters);
        $filename = 'subscriptions_export_' . date('Y-m-d_His') . '.xlsx';

        return Excel::download(new SubscriptionsExport($subscriptions), $filename);
    }

    /**
     * Export subscriptions to PDF
     */
    public function exportToPDF(array $filters = [])
    {
        $subscriptions = $this->getSubscriptions($filters);
        $filename = 'subscriptions_export_' . date('Y-m-d_His') . '.pdf';

        $pdf = Pdf::loadView('admin.reports.subscriptions-pdf', ['subscriptions' => $subscriptions])
            ->setPaper('a4', 'landscape')
            ->setOption('isRemoteEnabled', true)
            ->setOption('isHtml5ParserEnabled', true);

        return $pdf->download($filename);
    }

    /**
     * Export package statistics to CSV
     */
    public function exportPackageStatisticsToCSV()
    {
        $packages = SubscriptionPackage::with(['courses', 'subscriptions'])->get();

        $filename = 'package_statistics_' . date('Y-m-d_His') . '.csv';

        $headers = [
            'Content-Type' => 'text/csv; charset=UTF-8',
            'Content-Disposition' => 'attachment; filename="' . $filename . '"',
        ];

        $callback = function() use ($packages) {
            $file = fopen('php://output', 'w');

            // UTF-8 BOM
            fprintf($file, chr(0xEF).chr(0xBB).chr(0xBF));

            // Headers
            fputcsv($file, [
                'ID',
                'اسم الباقة',
                'السعر (دج)',
                'المدة (أيام)',
                'عدد الدورات',
                'الاشتراكات النشطة',
                'إجمالي الاشتراكات',
                'الحالة',
                'تاريخ الإنشاء',
            ]);

            foreach ($packages as $package) {
                $activeSubscriptions = $package->subscriptions()->where('status', 'active')->count();

                fputcsv($file, [
                    $package->id,
                    $package->name_ar,
                    $package->price_dzd,
                    $package->duration_days,
                    $package->courses->count(),
                    $activeSubscriptions,
                    $package->subscriptions->count(),
                    $package->is_active ? 'نشط' : 'غير نشط',
                    $package->created_at->format('Y-m-d H:i:s'),
                ]);
            }

            fclose($file);
        };

        return Response::stream($callback, 200, $headers);
    }

    /**
     * Export revenue report to CSV
     */
    public function exportRevenueReportToCSV(array $filters = [])
    {
        $query = UserSubscription::with(['user', 'course', 'package', 'paymentReceipt']);

        if (isset($filters['start_date'])) {
            $query->where('created_at', '>=', $filters['start_date']);
        }

        if (isset($filters['end_date'])) {
            $query->where('created_at', '<=', $filters['end_date']);
        }

        if (isset($filters['subscription_method'])) {
            $query->where('subscription_method', $filters['subscription_method']);
        }

        $subscriptions = $query->get();

        $filename = 'revenue_report_' . date('Y-m-d_His') . '.csv';

        $headers = [
            'Content-Type' => 'text/csv; charset=UTF-8',
            'Content-Disposition' => 'attachment; filename="' . $filename . '"',
        ];

        $callback = function() use ($subscriptions) {
            $file = fopen('php://output', 'w');

            // UTF-8 BOM
            fprintf($file, chr(0xEF).chr(0xBB).chr(0xBF));

            // Headers
            fputcsv($file, [
                'التاريخ',
                'اسم الطالب',
                'الدورة/الباقة',
                'طريقة الدفع',
                'المبلغ (دج)',
                'الحالة',
            ]);

            $totalRevenue = 0;

            foreach ($subscriptions as $subscription) {
                $courseName = $subscription->course
                    ? $subscription->course->title_ar
                    : ($subscription->package ? $subscription->package->name_ar : '');

                $amount = 0;
                if ($subscription->subscription_method === 'receipt' && $subscription->paymentReceipt) {
                    $amount = $subscription->paymentReceipt->amount_dzd;
                } elseif ($subscription->course) {
                    $amount = $subscription->course->price_dzd;
                } elseif ($subscription->package) {
                    $amount = $subscription->package->price_dzd;
                }

                $totalRevenue += $amount;

                fputcsv($file, [
                    $subscription->created_at->format('Y-m-d H:i:s'),
                    $subscription->user->full_name_ar,
                    $courseName,
                    $subscription->subscription_method,
                    $amount,
                    $subscription->status,
                ]);
            }

            // Total row
            fputcsv($file, ['', '', '', '', '', '']);
            fputcsv($file, ['', '', '', 'الإجمالي', $totalRevenue, '']);

            fclose($file);
        };

        return Response::stream($callback, 200, $headers);
    }

    /**
     * Export revenue report to Excel
     */
    public function exportRevenueReportToExcel(array $filters = [])
    {
        $query = UserSubscription::with(['user', 'course', 'package', 'paymentReceipt']);

        if (isset($filters['start_date'])) {
            $query->where('created_at', '>=', $filters['start_date']);
        }

        if (isset($filters['end_date'])) {
            $query->where('created_at', '<=', $filters['end_date']);
        }

        if (isset($filters['subscription_method'])) {
            $query->where('subscription_method', $filters['subscription_method']);
        }

        if (isset($filters['payment_method'])) {
            $query->where('subscription_method', $filters['payment_method']);
        }

        $subscriptions = $query->get();
        $filename = 'revenue_report_' . date('Y-m-d_His') . '.xlsx';

        return Excel::download(new RevenueReportExport($subscriptions), $filename);
    }

    /**
     * Export revenue report to PDF
     */
    public function exportRevenueReportToPDF(array $filters = [])
    {
        $query = UserSubscription::with(['user', 'course', 'package', 'paymentReceipt']);

        if (isset($filters['start_date'])) {
            $query->where('created_at', '>=', $filters['start_date']);
        }

        if (isset($filters['end_date'])) {
            $query->where('created_at', '<=', $filters['end_date']);
        }

        if (isset($filters['subscription_method'])) {
            $query->where('subscription_method', $filters['subscription_method']);
        }

        if (isset($filters['payment_method'])) {
            $query->where('subscription_method', $filters['payment_method']);
        }

        $subscriptions = $query->get();

        // Calculate total revenue
        $totalRevenue = 0;
        $revenueData = $subscriptions->map(function($subscription) use (&$totalRevenue) {
            $courseName = $subscription->course
                ? $subscription->course->title_ar
                : ($subscription->package ? $subscription->package->name_ar : '');

            $amount = 0;
            if ($subscription->subscription_method === 'receipt' && $subscription->paymentReceipt) {
                $amount = $subscription->paymentReceipt->amount_dzd;
            } elseif ($subscription->course) {
                $amount = $subscription->course->price_dzd;
            } elseif ($subscription->package) {
                $amount = $subscription->package->price_dzd;
            }

            $totalRevenue += $amount;

            return [
                'date' => $subscription->created_at->format('Y-m-d H:i:s'),
                'student' => $subscription->user->full_name_ar,
                'course_package' => $courseName,
                'payment_method' => $subscription->subscription_method,
                'amount' => $amount,
                'status' => $subscription->status,
            ];
        });

        $filename = 'revenue_report_' . date('Y-m-d_His') . '.pdf';

        $pdf = Pdf::loadView('admin.reports.revenue-pdf', [
            'revenueData' => $revenueData,
            'totalRevenue' => $totalRevenue,
            'filters' => $filters
        ])
            ->setPaper('a4', 'landscape')
            ->setOption('isRemoteEnabled', true)
            ->setOption('isHtml5ParserEnabled', true);

        return $pdf->download($filename);
    }

    /**
     * Get subscriptions with filters
     */
    private function getSubscriptions(array $filters = []): Collection
    {
        $query = UserSubscription::with(['user', 'course', 'package']);

        if (isset($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        if (isset($filters['subscription_method'])) {
            $query->where('subscription_method', $filters['subscription_method']);
        }

        if (isset($filters['course_id'])) {
            $query->where('course_id', $filters['course_id']);
        }

        if (isset($filters['package_id'])) {
            $query->where('package_id', $filters['package_id']);
        }

        if (isset($filters['start_date'])) {
            $query->where('created_at', '>=', $filters['start_date']);
        }

        if (isset($filters['end_date'])) {
            $query->where('created_at', '<=', $filters['end_date']);
        }

        return $query->get();
    }
}
