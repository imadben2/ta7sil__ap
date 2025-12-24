<?php

namespace App\Exports;

use Illuminate\Support\Collection;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;
use Maatwebsite\Excel\Concerns\WithStyles;
use Maatwebsite\Excel\Concerns\WithColumnWidths;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;

class CourseStatisticsExport implements FromCollection, WithHeadings, WithMapping, WithStyles, WithColumnWidths
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
            'العنوان',
            'المادة',
            'المستوى',
            'عدد الوحدات',
            'عدد الدروس',
            'إجمالي مدة الفيديوهات (دقيقة)',
            'عدد المسجلين',
            'الاشتراكات النشطة',
            'متوسط التقييم',
            'عدد المراجعات',
            'عدد المشاهدات',
        ];
    }

    public function map($course): array
    {
        $activeSubscriptions = $course->subscriptions()->where('status', 'active')->count();
        $totalVideoDuration = $course->modules()
            ->with('lessons')
            ->get()
            ->flatMap->lessons
            ->sum('video_duration_seconds') / 60;

        return [
            $course->title_ar,
            $course->subject->name_ar ?? '',
            $course->level,
            $course->total_modules,
            $course->total_lessons,
            number_format($totalVideoDuration, 2),
            $course->enrollment_count,
            $activeSubscriptions,
            number_format($course->average_rating, 2),
            $course->total_reviews,
            $course->view_count,
        ];
    }

    public function styles(Worksheet $sheet)
    {
        return [
            1 => ['font' => ['bold' => true], 'fill' => ['fillType' => 'solid', 'startColor' => ['rgb' => '10B981']]],
        ];
    }

    public function columnWidths(): array
    {
        return [
            'A' => 35,
            'B' => 20,
            'C' => 12,
            'D' => 12,
            'E' => 12,
            'F' => 28,
            'G' => 14,
            'H' => 18,
            'I' => 14,
            'J' => 14,
            'K' => 14,
        ];
    }
}
