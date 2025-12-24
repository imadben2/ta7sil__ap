<?php

namespace App\Exports;

use Illuminate\Support\Collection;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;
use Maatwebsite\Excel\Concerns\WithStyles;
use Maatwebsite\Excel\Concerns\WithColumnWidths;
use Maatwebsite\Excel\Concerns\WithEvents;
use Maatwebsite\Excel\Events\AfterSheet;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;
use PhpOffice\PhpSpreadsheet\Style\Fill;
use PhpOffice\PhpSpreadsheet\Style\Alignment;

class RevenueReportExport implements FromCollection, WithHeadings, WithMapping, WithStyles, WithColumnWidths, WithEvents
{
    protected Collection $subscriptions;
    protected $totalRevenue = 0;

    public function __construct(Collection $subscriptions)
    {
        $this->subscriptions = $subscriptions;
    }

    public function collection()
    {
        return $this->subscriptions;
    }

    public function headings(): array
    {
        return [
            'التاريخ',
            'اسم الطالب',
            'الدورة/الباقة',
            'طريقة الدفع',
            'المبلغ (دج)',
            'الحالة',
        ];
    }

    public function map($subscription): array
    {
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

        $this->totalRevenue += $amount;

        return [
            $subscription->created_at->format('Y-m-d H:i:s'),
            $subscription->user->full_name_ar,
            $courseName,
            $subscription->subscription_method,
            $amount,
            $subscription->status,
        ];
    }

    public function styles(Worksheet $sheet)
    {
        return [
            1 => ['font' => ['bold' => true], 'fill' => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['rgb' => '10B981']]],
        ];
    }

    public function columnWidths(): array
    {
        return [
            'A' => 20,
            'B' => 25,
            'C' => 30,
            'D' => 18,
            'E' => 15,
            'F' => 12,
        ];
    }

    public function registerEvents(): array
    {
        return [
            AfterSheet::class => function(AfterSheet $event) {
                $lastRow = $event->sheet->getHighestRow() + 2;

                // Add total label
                $event->sheet->setCellValue('D' . $lastRow, 'الإجمالي');
                $event->sheet->setCellValue('E' . $lastRow, $this->totalRevenue);

                // Style the total row
                $event->sheet->getStyle('D' . $lastRow . ':E' . $lastRow)->applyFromArray([
                    'font' => ['bold' => true, 'size' => 12],
                    'fill' => [
                        'fillType' => Fill::FILL_SOLID,
                        'startColor' => ['rgb' => 'FEF3C7']
                    ],
                    'alignment' => [
                        'horizontal' => Alignment::HORIZONTAL_CENTER,
                    ],
                ]);
            },
        ];
    }
}
