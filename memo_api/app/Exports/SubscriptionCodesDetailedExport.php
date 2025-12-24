<?php

namespace App\Exports;

use App\Models\SubscriptionCodeList;
use App\Models\SubscriptionCode;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;
use Maatwebsite\Excel\Concerns\WithStyles;
use Maatwebsite\Excel\Concerns\WithColumnWidths;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;
use Illuminate\Support\Collection;

class SubscriptionCodesDetailedExport implements FromCollection, WithHeadings, WithMapping, WithStyles, WithColumnWidths
{
    protected $filters;

    public function __construct($filters = [])
    {
        $this->filters = $filters;
    }

    /**
     * @return Collection
     */
    public function collection()
    {
        $query = SubscriptionCode::with(['course', 'package', 'creator', 'list'])
            ->whereNotNull('list_id');

        // Apply filters based on list criteria
        if (!empty($this->filters['code_type'])) {
            $query->whereHas('list', function ($q) {
                $q->where('code_type', $this->filters['code_type']);
            });
        }

        if (!empty($this->filters['course_id'])) {
            $query->whereHas('list', function ($q) {
                $q->where('course_id', $this->filters['course_id']);
            });
        }

        if (!empty($this->filters['package_id'])) {
            $query->whereHas('list', function ($q) {
                $q->where('package_id', $this->filters['package_id']);
            });
        }

        return $query->orderBy('created_at', 'desc')->get();
    }

    /**
     * @return array
     */
    public function headings(): array
    {
        return [
            'اسم القائمة',
            'الكود',
            'نوع الكود',
            'الدورة',
            'الباقة',
            'الاستخدام الحالي',
            'الحد الأقصى للاستخدام',
            'الاستخدامات المتبقية',
            'مستخدم؟',
            'الحالة',
            'تاريخ الانتهاء',
            'منتهي؟',
            'تاريخ الإنشاء',
            'المنشئ',
        ];
    }

    /**
     * @param mixed $code
     * @return array
     */
    public function map($code): array
    {
        // Get type label
        $typeLabels = [
            'single_course' => 'دورة واحدة',
            'package' => 'باقة',
            'general' => 'عام',
        ];
        $typeLabel = $typeLabels[$code->code_type ?? ''] ?? 'غير محدد';

        // Check if used
        $isUsed = $code->current_uses > 0 ? 'نعم' : 'لا';

        // Check status
        $status = 'نشط';
        if (!$code->is_active) {
            $status = 'معطل';
        } elseif ($code->expires_at && $code->expires_at->isPast()) {
            $status = 'منتهي';
        } elseif ($code->current_uses >= $code->max_uses) {
            $status = 'مستخدم بالكامل';
        }

        // Check if expired
        $isExpired = ($code->expires_at && $code->expires_at->isPast()) ? 'نعم' : 'لا';

        // Remaining uses
        $remainingUses = max(0, $code->max_uses - $code->current_uses);

        return [
            $code->list->name ?? 'غير محدد',
            $code->code,
            $typeLabel,
            $code->course->title_ar ?? '-',
            $code->package->name_ar ?? '-',
            $code->current_uses,
            $code->max_uses,
            $remainingUses,
            $isUsed,
            $status,
            $code->expires_at ? $code->expires_at->format('Y-m-d') : 'غير محدد',
            $isExpired,
            $code->created_at->format('Y-m-d H:i'),
            $code->creator->name ?? 'غير معروف',
        ];
    }

    /**
     * @param Worksheet $sheet
     * @return array
     */
    public function styles(Worksheet $sheet)
    {
        return [
            // Style the first row as bold text
            1 => ['font' => ['bold' => true, 'size' => 12]],
        ];
    }

    /**
     * @return array
     */
    public function columnWidths(): array
    {
        return [
            'A' => 30,  // اسم القائمة
            'B' => 20,  // الكود
            'C' => 15,  // نوع الكود
            'D' => 30,  // الدورة
            'E' => 30,  // الباقة
            'F' => 15,  // الاستخدام الحالي
            'G' => 20,  // الحد الأقصى
            'H' => 20,  // المتبقية
            'I' => 12,  // مستخدم؟
            'J' => 15,  // الحالة
            'K' => 15,  // تاريخ الانتهاء
            'L' => 12,  // منتهي؟
            'M' => 20,  // تاريخ الإنشاء
            'N' => 25,  // المنشئ
        ];
    }
}
