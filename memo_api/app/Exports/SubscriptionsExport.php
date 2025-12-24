<?php

namespace App\Exports;

use Illuminate\Support\Collection;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;
use Maatwebsite\Excel\Concerns\WithStyles;
use Maatwebsite\Excel\Concerns\WithColumnWidths;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;

class SubscriptionsExport implements FromCollection, WithHeadings, WithMapping, WithStyles, WithColumnWidths
{
    protected Collection $subscriptions;

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
        ];
    }

    public function map($subscription): array
    {
        $courseName = $subscription->course
            ? $subscription->course->title_ar
            : ($subscription->package ? $subscription->package->name_ar : '');

        $type = $subscription->course ? 'دورة' : 'باقة';

        return [
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
        ];
    }

    public function styles(Worksheet $sheet)
    {
        return [
            1 => ['font' => ['bold' => true], 'fill' => ['fillType' => 'solid', 'startColor' => ['rgb' => '9333EA']]],
        ];
    }

    public function columnWidths(): array
    {
        return [
            'A' => 8,
            'B' => 25,
            'C' => 25,
            'D' => 30,
            'E' => 10,
            'F' => 18,
            'G' => 12,
            'H' => 20,
            'I' => 20,
            'J' => 20,
        ];
    }
}
