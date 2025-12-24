<?php

namespace App\Exports;

use App\Models\SubscriptionCodeList;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;
use Maatwebsite\Excel\Concerns\WithStyles;
use Maatwebsite\Excel\Concerns\WithColumnWidths;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;
use Illuminate\Support\Collection;

class SubscriptionCodeListsExport implements FromCollection, WithHeadings, WithMapping, WithStyles, WithColumnWidths
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
        $query = SubscriptionCodeList::with(['course', 'package', 'creator', 'codes'])
            ->withCount([
                'codes',
                'codes as used_codes_count' => function ($q) {
                    $q->where('current_uses', '>', 0);
                },
                'codes as valid_codes_count' => function ($q) {
                    $q->where('is_active', true)
                      ->where(function ($q2) {
                          $q2->whereNull('expires_at')
                             ->orWhere('expires_at', '>', now());
                      })
                      ->whereRaw('current_uses < max_uses');
                },
                'codes as fully_used_codes_count' => function ($q) {
                    $q->whereRaw('current_uses >= max_uses');
                },
            ])
            ->withSum('codes', 'current_uses');

        // Apply filters
        if (!empty($this->filters['code_type'])) {
            $query->where('code_type', $this->filters['code_type']);
        }

        if (!empty($this->filters['course_id'])) {
            $query->where('course_id', $this->filters['course_id']);
        }

        if (!empty($this->filters['package_id'])) {
            $query->where('package_id', $this->filters['package_id']);
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
            'نوع الكود',
            'الدورة/الباقة',
            'إجمالي الأكواد',
            'الأكواد الصالحة',
            'الأكواد المستخدمة',
            'الأكواد المستخدمة بالكامل',
            'إجمالي الاستخدامات',
            'الإيرادات (دج)',
            'تاريخ الإنشاء',
            'المنشئ',
        ];
    }

    /**
     * @param mixed $list
     * @return array
     */
    public function map($list): array
    {
        // Calculate revenue
        $totalUses = $list->codes_sum_current_uses ?? 0;
        $revenue = 0;

        if ($list->course) {
            $revenue = $totalUses * $list->course->price_dzd;
        } elseif ($list->package) {
            $revenue = $totalUses * $list->package->price_dzd;
        }

        // Get type label
        $typeLabels = [
            'single_course' => 'دورة واحدة',
            'package' => 'باقة',
            'general' => 'عام',
        ];
        $typeLabel = $typeLabels[$list->code_type] ?? $list->code_type;

        // Get course/package name
        $itemName = 'غير محدد';
        if ($list->course) {
            $itemName = $list->course->title_ar;
        } elseif ($list->package) {
            $itemName = $list->package->name_ar;
        }

        return [
            $list->name,
            $typeLabel,
            $itemName,
            $list->codes_count,
            $list->valid_codes_count,
            $list->used_codes_count,
            $list->fully_used_codes_count ?? 0,
            $totalUses,
            number_format($revenue, 2),
            $list->created_at->format('Y-m-d H:i'),
            $list->creator->name ?? 'غير معروف',
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
            'B' => 15,  // نوع الكود
            'C' => 30,  // الدورة/الباقة
            'D' => 15,  // إجمالي الأكواد
            'E' => 15,  // الأكواد الصالحة
            'F' => 15,  // الأكواد المستخدمة
            'G' => 20,  // الأكواد المستخدمة بالكامل
            'H' => 20,  // إجمالي الاستخدامات
            'I' => 20,  // الإيرادات
            'J' => 20,  // تاريخ الإنشاء
            'K' => 25,  // المنشئ
        ];
    }
}
