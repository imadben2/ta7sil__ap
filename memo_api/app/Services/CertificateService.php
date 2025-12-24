<?php

namespace App\Services;

use App\Models\User;
use App\Models\Course;
use App\Models\Certificate;
use App\Models\UserCourseProgress;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Support\Facades\Storage;
use SimpleSoftwareIO\QrCode\Facades\QrCode;

class CertificateService
{
    /**
     * Generate a certificate for a completed course
     */
    public function generate(User $user, Course $course): Certificate
    {
        // Check if certificate already exists
        $existingCertificate = Certificate::where('user_id', $user->id)
            ->where('course_id', $course->id)
            ->first();

        if ($existingCertificate) {
            return $existingCertificate;
        }

        // Get user's progress
        $progress = UserCourseProgress::where('user_id', $user->id)
            ->where('course_id', $course->id)
            ->first();

        if (!$progress || !$progress->is_completed) {
            throw new \Exception('لم تكمل هذه الدورة بعد');
        }

        // Generate certificate number
        $certificateNumber = Certificate::generateCertificateNumber();

        // Create certificate record
        $certificate = Certificate::create([
            'certificate_number' => $certificateNumber,
            'user_id' => $user->id,
            'course_id' => $course->id,
            'user_course_progress_id' => $progress->id,
            'student_name' => $user->name,
            'course_title' => $course->title_ar,
            'instructor_name' => $course->instructor_name,
            'completion_date' => $progress->completed_at ?? now(),
            'average_score' => $progress->average_quiz_score,
            'is_verified' => true,
            'issued_at' => now(),
        ]);

        // Generate verification URL
        $verificationUrl = config('app.url') . '/api/v1/certificates/' . $certificateNumber . '/verify';
        $certificate->verification_url = $verificationUrl;

        // Generate QR code data
        $qrCodeData = $this->generateQrCode($certificate);
        $certificate->qr_code_data = $qrCodeData;

        // Generate PDF
        $pdfPath = $this->generatePdf($certificate);
        $certificate->pdf_path = $pdfPath;
        $certificate->pdf_url = Storage::url($pdfPath);

        $certificate->save();

        return $certificate;
    }

    /**
     * Verify a certificate by its number
     */
    public function verify(string $certificateNumber): ?Certificate
    {
        return Certificate::where('certificate_number', $certificateNumber)
            ->with(['user', 'course'])
            ->first();
    }

    /**
     * Generate QR code for verification
     */
    public function generateQrCode(Certificate $certificate): string
    {
        $verificationData = json_encode([
            'certificate_number' => $certificate->certificate_number,
            'student_name' => $certificate->student_name,
            'course_title' => $certificate->course_title,
            'completion_date' => $certificate->completion_date->format('Y-m-d'),
            'verification_url' => $certificate->verification_url,
        ], JSON_UNESCAPED_UNICODE);

        // Try to generate QR code SVG, fallback to base64 encoded URL
        try {
            if (class_exists('SimpleSoftwareIO\QrCode\Facades\QrCode')) {
                return QrCode::size(200)->generate($certificate->verification_url);
            }
        } catch (\Exception $e) {
            // Fallback: just return the verification URL for QR generation on frontend
        }

        return $certificate->verification_url;
    }

    /**
     * Generate certificate PDF
     */
    public function generatePdf(Certificate $certificate): string
    {
        $data = [
            'certificate' => $certificate,
            'student_name' => $certificate->student_name,
            'course_title' => $certificate->course_title,
            'instructor_name' => $certificate->instructor_name,
            'completion_date' => $certificate->completion_date->format('Y/m/d'),
            'certificate_number' => $certificate->certificate_number,
            'verification_url' => $certificate->verification_url,
            'average_score' => $certificate->average_score,
            'qr_code_data' => $certificate->qr_code_data,
        ];

        $pdf = Pdf::loadView('certificates.template', $data);
        $pdf->setPaper('a4', 'landscape');

        // Generate filename
        $filename = 'certificates/' . $certificate->certificate_number . '.pdf';

        // Store PDF
        Storage::put('public/' . $filename, $pdf->output());

        return $filename;
    }

    /**
     * Get user's certificates
     */
    public function getUserCertificates(User $user)
    {
        return Certificate::where('user_id', $user->id)
            ->with('course')
            ->orderBy('issued_at', 'desc')
            ->get();
    }

    /**
     * Revoke a certificate
     */
    public function revoke(Certificate $certificate, string $reason): void
    {
        $certificate->revoke($reason);
    }

    /**
     * Reinstate a revoked certificate
     */
    public function reinstate(Certificate $certificate): void
    {
        $certificate->reinstate();
    }

    /**
     * Check if user can get certificate for a course
     */
    public function canGenerateCertificate(User $user, Course $course): array
    {
        $progress = UserCourseProgress::where('user_id', $user->id)
            ->where('course_id', $course->id)
            ->first();

        if (!$progress) {
            return [
                'can_generate' => false,
                'reason' => 'لم تبدأ هذه الدورة بعد',
                'progress_percentage' => 0,
            ];
        }

        if (!$progress->is_completed) {
            return [
                'can_generate' => false,
                'reason' => 'لم تكمل جميع الدروس بعد',
                'progress_percentage' => $progress->progress_percentage ?? 0,
            ];
        }

        // Check if certificate already exists
        $existingCertificate = Certificate::where('user_id', $user->id)
            ->where('course_id', $course->id)
            ->first();

        if ($existingCertificate) {
            return [
                'can_generate' => true,
                'already_generated' => true,
                'certificate_id' => $existingCertificate->certificate_number,
                'progress_percentage' => 100,
            ];
        }

        return [
            'can_generate' => true,
            'already_generated' => false,
            'progress_percentage' => 100,
        ];
    }
}
