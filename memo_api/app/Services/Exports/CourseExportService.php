<?php

namespace App\Services\Exports;

use App\Models\Course;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Response;
use Maatwebsite\Excel\Facades\Excel;
use App\Exports\CoursesExport;
use App\Exports\CourseStatisticsExport;
use Barryvdh\DomPDF\Facade\Pdf;
use App\Helpers\ArabicHelper;

class CourseExportService
{
    /**
     * Export courses to CSV
     */
    public function exportToCSV(array $filters = [])
    {
        $courses = $this->getCourses($filters);

        $filename = 'courses_export_' . date('Y-m-d_His') . '.csv';

        $headers = [
            'Content-Type' => 'text/csv; charset=UTF-8',
            'Content-Disposition' => 'attachment; filename="' . $filename . '"',
        ];

        $callback = function() use ($courses) {
            $file = fopen('php://output', 'w');

            // UTF-8 BOM for Excel
            fprintf($file, chr(0xEF).chr(0xBB).chr(0xBF));

            // Headers
            fputcsv($file, [
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
            ]);

            foreach ($courses as $course) {
                fputcsv($file, [
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
                ]);
            }

            fclose($file);
        };

        return Response::stream($callback, 200, $headers);
    }

    /**
     * Export courses to Excel
     */
    public function exportToExcel(array $filters = [])
    {
        $courses = $this->getCourses($filters);
        $filename = 'courses_export_' . date('Y-m-d_His') . '.xlsx';

        return Excel::download(new CoursesExport($courses), $filename);
    }

    /**
     * Export courses to PDF
     */
    public function exportToPDF(array $filters = [])
    {
        $courses = $this->getCourses($filters);

        // Prepare Arabic text for PDF
        $courses = $courses->map(function($course) {
            $course->title_ar_pdf = ArabicHelper::prepareForPDF($course->title_ar);
            $course->subject_name_pdf = $course->subject ? ArabicHelper::prepareForPDF($course->subject->name_ar) : '';
            $course->instructor_name_pdf = ArabicHelper::prepareForPDF($course->instructor_name);
            $course->level_pdf = ArabicHelper::prepareForPDF($course->level);
            return $course;
        });

        $filename = 'courses_export_' . date('Y-m-d_His') . '.pdf';

        $pdf = Pdf::loadView('admin.reports.courses-pdf', ['courses' => $courses])
            ->setPaper('a4', 'landscape')
            ->setOption('isRemoteEnabled', true)
            ->setOption('isHtml5ParserEnabled', true);

        return $pdf->download($filename);
    }

    /**
     * Export course enrollments to CSV
     */
    public function exportEnrollmentsToCSV($courseId)
    {
        $course = Course::with(['subscriptions.user'])->findOrFail($courseId);

        $filename = 'course_' . $course->id . '_enrollments_' . date('Y-m-d_His') . '.csv';

        $headers = [
            'Content-Type' => 'text/csv; charset=UTF-8',
            'Content-Disposition' => 'attachment; filename="' . $filename . '"',
        ];

        $callback = function() use ($course) {
            $file = fopen('php://output', 'w');

            // UTF-8 BOM
            fprintf($file, chr(0xEF).chr(0xBB).chr(0xBF));

            // Headers
            fputcsv($file, [
                'ID الطالب',
                'الاسم الكامل',
                'البريد الإلكتروني',
                'رقم الهاتف',
                'طريقة الاشتراك',
                'تاريخ البدء',
                'تاريخ الانتهاء',
                'الحالة',
            ]);

            foreach ($course->subscriptions as $subscription) {
                fputcsv($file, [
                    $subscription->user->id,
                    $subscription->user->full_name_ar,
                    $subscription->user->email,
                    $subscription->user->phone_number,
                    $subscription->subscription_method,
                    $subscription->started_at?->format('Y-m-d H:i:s'),
                    $subscription->expires_at?->format('Y-m-d H:i:s') ?? 'غير محدد',
                    $subscription->status,
                ]);
            }

            fclose($file);
        };

        return Response::stream($callback, 200, $headers);
    }

    /**
     * Get courses with filters
     */
    private function getCourses(array $filters = []): Collection
    {
        $query = Course::with(['subject']);

        if (isset($filters['is_published'])) {
            $query->where('is_published', $filters['is_published']);
        }

        if (isset($filters['subject_id'])) {
            $query->where('subject_id', $filters['subject_id']);
        }

        if (isset($filters['level'])) {
            $query->where('level', $filters['level']);
        }

        if (isset($filters['is_free'])) {
            $query->where('is_free', $filters['is_free']);
        }

        return $query->get();
    }

    /**
     * Export course statistics to CSV
     */
    public function exportStatisticsToCSV()
    {
        $courses = Course::with(['subject'])->get();

        $filename = 'course_statistics_' . date('Y-m-d_His') . '.csv';

        $headers = [
            'Content-Type' => 'text/csv; charset=UTF-8',
            'Content-Disposition' => 'attachment; filename="' . $filename . '"',
        ];

        $callback = function() use ($courses) {
            $file = fopen('php://output', 'w');

            // UTF-8 BOM
            fprintf($file, chr(0xEF).chr(0xBB).chr(0xBF));

            // Headers
            fputcsv($file, [
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
                'معدل الإكمال (%)',
            ]);

            foreach ($courses as $course) {
                $activeSubscriptions = $course->subscriptions()->where('status', 'active')->count();
                $totalVideoDuration = $course->modules()
                    ->with('lessons')
                    ->get()
                    ->flatMap->lessons
                    ->sum('video_duration_seconds') / 60;

                fputcsv($file, [
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
                    '0', // TODO: Calculate completion rate from UserCourseProgress
                ]);
            }

            fclose($file);
        };

        return Response::stream($callback, 200, $headers);
    }

    /**
     * Export course statistics to Excel
     */
    public function exportStatisticsToExcel()
    {
        $courses = Course::with(['subject'])->get();
        $filename = 'course_statistics_' . date('Y-m-d_His') . '.xlsx';

        return Excel::download(new CourseStatisticsExport($courses), $filename);
    }

    /**
     * Export course statistics to PDF
     */
    public function exportStatisticsToPDF()
    {
        $courses = Course::with(['subject'])->get();
        $filename = 'course_statistics_' . date('Y-m-d_His') . '.pdf';

        // Calculate statistics for each course
        $statistics = $courses->map(function($course) {
            $activeSubscriptions = $course->subscriptions()->where('status', 'active')->count();
            $totalVideoDuration = $course->modules()
                ->with('lessons')
                ->get()
                ->flatMap->lessons
                ->sum('video_duration_seconds') / 60;

            return [
                'title' => $course->title_ar,
                'subject' => $course->subject->name_ar ?? '',
                'level' => $course->level,
                'total_modules' => $course->total_modules,
                'total_lessons' => $course->total_lessons,
                'video_duration' => number_format($totalVideoDuration, 2),
                'enrollment_count' => $course->enrollment_count,
                'active_subscriptions' => $activeSubscriptions,
                'average_rating' => number_format($course->average_rating, 2),
                'total_reviews' => $course->total_reviews,
                'view_count' => $course->view_count,
            ];
        });

        $pdf = Pdf::loadView('admin.reports.course-statistics-pdf', ['statistics' => $statistics])
            ->setPaper('a4', 'landscape')
            ->setOption('isRemoteEnabled', true)
            ->setOption('isHtml5ParserEnabled', true);

        return $pdf->download($filename);
    }
}
