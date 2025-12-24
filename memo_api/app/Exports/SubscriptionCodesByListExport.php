<?php

namespace App\Exports;

use App\Models\SubscriptionCodeList;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;
use Maatwebsite\Excel\Concerns\WithStyles;
use Maatwebsite\Excel\Concerns\WithColumnWidths;
use Maatwebsite\Excel\Concerns\WithTitle;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;
use Illuminate\Support\Collection;

class SubscriptionCodesByListExport implements FromCollection, WithHeadings, WithMapping, WithStyles, WithColumnWidths, WithTitle
{
    protected $list;

    public function __construct(SubscriptionCodeList $list)
    {
        $this->list = $list;
    }

    /**
     * @return Collection
     */
    public function collection()
    {
        return $this->list->codes()
            ->with(['course', 'package', 'creator'])
            ->orderBy('created_at', 'desc')
            ->get();
    }

    /**
     * @return array
     */
    public function headings(): array
    {
        return [
            'الكود',
            'نوع الكود',
            'الدورة',
            'الباقة',
            'الاستخدام الحالي',
            'الاستخدامات المتبقية',
            'مستخدم؟',
            'الحالة',
            'تاريخ الانتهاء',
            'منتهي؟',
            'نشط؟',
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

        // Check if active
        $isActive = $code->is_active ? 'نعم' : 'لا';

        // Remaining uses
        $remainingUses = max(0, $code->max_uses - $code->current_uses);

        return [
            $code->code,
            $typeLabel,
            $code->course->title_ar ?? '-',
            $code->package->name_ar ?? '-',
            $code->current_uses,
            $remainingUses,
            $isUsed,
            $status,
            $code->expires_at ? $code->expires_at->format('Y-m-d') : 'غير محدد',
            $isExpired,
            $isActive,
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
            'A' => 20,  // الكود
            'B' => 15,  // نوع الكود
            'C' => 30,  // الدورة
            'D' => 30,  // الباقة
            'E' => 15,  // الاستخدام الحالي
            'F' => 20,  // المتبقية
            'G' => 12,  // مستخدم؟
            'H' => 20,  // الحالة
            'I' => 15,  // تاريخ الانتهاء
            'J' => 12,  // منتهي؟
            'K' => 12,  // نشط؟
        ];
    }

    /**
     * @return string
     */
    public function title(): string
    {
        // Clean the list name for use as sheet title (max 31 chars)
        $title = substr($this->list->name, 0, 31);
        // Remove invalid characters for Excel sheet names
        $title = str_replace([':', '\\', '/', '?', '*', '[', ']'], '', $title);
        return $title;
    }
}
