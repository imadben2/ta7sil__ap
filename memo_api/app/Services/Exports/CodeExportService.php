<?php

namespace App\Services\Exports;

use App\Models\SubscriptionCode;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Response;

class CodeExportService
{
    /**
     * Export subscription codes to CSV
     */
    public function exportToCSV(array $filters = [])
    {
        $codes = $this->getCodes($filters);

        $filename = 'subscription_codes_' . date('Y-m-d_His') . '.csv';

        $headers = [
            'Content-Type' => 'text/csv; charset=UTF-8',
            'Content-Disposition' => 'attachment; filename="' . $filename . '"',
        ];

        $callback = function() use ($codes) {
            $file = fopen('php://output', 'w');

            // UTF-8 BOM
            fprintf($file, chr(0xEF).chr(0xBB).chr(0xBF));

            // Headers
            fputcsv($file, [
                'الرمز',
                'النوع',
                'الدورة/الباقة',
                'عدد الاستخدامات المتاحة',
                'عدد الاستخدامات الحالية',
                'تاريخ الانتهاء',
                'الحالة',
                'أنشأه',
                'تاريخ الإنشاء',
            ]);

            foreach ($codes as $code) {
                $courseOrPackage = '';
                if ($code->code_type === 'single_course' && $code->course) {
                    $courseOrPackage = $code->course->title_ar;
                } elseif ($code->code_type === 'package' && $code->package) {
                    $courseOrPackage = $code->package->name_ar;
                } else {
                    $courseOrPackage = 'عام';
                }

                fputcsv($file, [
                    $code->code,
                    $code->code_type,
                    $courseOrPackage,
                    $code->max_uses,
                    $code->current_uses,
                    $code->expires_at?->format('Y-m-d H:i:s') ?? 'غير محدد',
                    $code->is_active ? 'نشط' : 'غير نشط',
                    $code->creator?->full_name_ar ?? '',
                    $code->created_at->format('Y-m-d H:i:s'),
                ]);
            }

            fclose($file);
        };

        return Response::stream($callback, 200, $headers);
    }

    /**
     * Export usage statistics for codes
     */
    public function exportUsageStatisticsToCSV()
    {
        $codes = SubscriptionCode::with(['course', 'package', 'subscriptions'])->get();

        $filename = 'code_usage_statistics_' . date('Y-m-d_His') . '.csv';

        $headers = [
            'Content-Type' => 'text/csv; charset=UTF-8',
            'Content-Disposition' => 'attachment; filename="' . $filename . '"',
        ];

        $callback = function() use ($codes) {
            $file = fopen('php://output', 'w');

            // UTF-8 BOM
            fprintf($file, chr(0xEF).chr(0xBB).chr(0xBF));

            // Headers
            fputcsv($file, [
                'الرمز',
                'النوع',
                'الدورة/الباقة',
                'عدد الاستخدامات',
                'عدد الاستخدامات المتاحة',
                'الاستخدامات المتبقية',
                'معدل الاستخدام (%)',
                'تاريخ آخر استخدام',
                'الحالة',
            ]);

            foreach ($codes as $code) {
                $courseOrPackage = '';
                if ($code->code_type === 'single_course' && $code->course) {
                    $courseOrPackage = $code->course->title_ar;
                } elseif ($code->code_type === 'package' && $code->package) {
                    $courseOrPackage = $code->package->name_ar;
                } else {
                    $courseOrPackage = 'عام';
                }

                $usageRate = $code->max_uses > 0 ? ($code->current_uses / $code->max_uses) * 100 : 0;
                $lastUsed = $code->subscriptions()->latest()->first()?->created_at;

                fputcsv($file, [
                    $code->code,
                    $code->code_type,
                    $courseOrPackage,
                    $code->current_uses,
                    $code->max_uses,
                    $code->getRemainingUses(),
                    number_format($usageRate, 2),
                    $lastUsed?->format('Y-m-d H:i:s') ?? 'لم يستخدم',
                    $code->isValid() ? 'صالح' : 'غير صالح',
                ]);
            }

            fclose($file);
        };

        return Response::stream($callback, 200, $headers);
    }

    /**
     * Get codes with filters
     */
    private function getCodes(array $filters = []): Collection
    {
        $query = SubscriptionCode::with(['course', 'package', 'creator']);

        if (isset($filters['code_type'])) {
            $query->where('code_type', $filters['code_type']);
        }

        if (isset($filters['is_active'])) {
            $query->where('is_active', $filters['is_active']);
        }

        if (isset($filters['course_id'])) {
            $query->where('course_id', $filters['course_id']);
        }

        if (isset($filters['package_id'])) {
            $query->where('package_id', $filters['package_id']);
        }

        return $query->get();
    }
}
