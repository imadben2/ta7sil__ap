<?php

namespace App\Exports;

use Illuminate\Support\Collection;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;
use Maatwebsite\Excel\Concerns\WithStyles;
use Maatwebsite\Excel\Concerns\WithColumnWidths;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;

class CoursesExport implements FromCollection, WithHeadings, WithMapping, WithStyles, WithColumnWidths
{
    protected Collection $courses;

    public function __construct(Collection $courses)
    {
        $this->courses = $courses;
    }

    public function collection()
    {
        return $this->courses;
    }

    public function headings(): array
    {
        return [
            'ID',
            'العنوان',
            'المستوى',
            'المادة',
            'المدرب',
            'السعر (دج)',
            'مجانية',
            'منشورة',
            'عدد الوحدات',
            'عدد الدروس',
            'عدد المسجلين',
            'متوسط التقييم',
            'عدد المراجعات',
            'تاريخ الإنشاء',
        ];
    }

    public function map($course): array
    {
        return [
            $course->id,
            $course->title_ar,
            $course->level,
            $course->subject->name_ar ?? '',
            $course->instructor_name,
            $course->price_dzd,
            $course->is_free ? 'نعم' : 'لا',
            $course->is_published ? 'نعم' : 'لا',
            $course->total_modules,
            $course->total_lessons,
            $course->enrollment_count,
            number_format($course->average_rating, 2),
            $course->total_reviews,
            $course->created_at->format('Y-m-d H:i:s'),
        ];
    }

    public function styles(Worksheet $sheet)
    {
        return [
            1 => ['font' => ['bold' => true], 'fill' => ['fillType' => 'solid', 'startColor' => ['rgb' => '4F46E5']]],
        ];
    }

    public function columnWidths(): array
    {
        return [
            'A' => 8,
            'B' => 35,
            'C' => 12,
            'D' => 20,
            'E' => 20,
            'F' => 12,
            'G' => 10,
            'H' => 10,
            'I' => 12,
            'J' => 12,
            'K' => 14,
            'L' => 14,
            'M' => 14,
            'N' => 20,
        ];
    }
}
