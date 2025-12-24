<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Course;
use App\Models\Certificate;
use App\Services\CertificateService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Storage;

class CertificateController extends Controller
{
    protected CertificateService $certificateService;

    public function __construct(CertificateService $certificateService)
    {
        $this->certificateService = $certificateService;
    }

    /**
     * Generate a certificate for a completed course
     *
     * POST /v1/courses/{id}/certificate
     */
    public function generate(Request $request, int $id): JsonResponse
    {
        $course = Course::find($id);

        if (!$course) {
            return response()->json([
                'success' => false,
                'message' => 'الدورة غير موجودة',
            ], 404);
        }

        $user = $request->user();

        // Check if user can generate certificate
        $eligibility = $this->certificateService->canGenerateCertificate($user, $course);

        if (!$eligibility['can_generate']) {
            return response()->json([
                'success' => false,
                'message' => $eligibility['reason'],
                'data' => [
                    'progress_percentage' => $eligibility['progress_percentage'],
                ],
            ], 422);
        }

        // If certificate already exists, return it
        if (isset($eligibility['already_generated']) && $eligibility['already_generated']) {
            $certificate = Certificate::where('certificate_number', $eligibility['certificate_id'])->first();

            return response()->json([
                'success' => true,
                'message' => 'الشهادة موجودة بالفعل',
                'data' => [
                    'certificate_id' => $certificate->certificate_number,
                    'pdf_url' => $certificate->pdf_url,
                    'verification_url' => $certificate->verification_url,
                    'issued_at' => $certificate->issued_at->toIso8601String(),
                ],
            ]);
        }

        try {
            $certificate = $this->certificateService->generate($user, $course);

            return response()->json([
                'success' => true,
                'message' => 'تم إنشاء الشهادة بنجاح',
                'data' => [
                    'certificate_id' => $certificate->certificate_number,
                    'pdf_url' => $certificate->pdf_url,
                    'verification_url' => $certificate->verification_url,
                    'issued_at' => $certificate->issued_at->toIso8601String(),
                ],
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }
    }

    /**
     * Verify a certificate (Public endpoint)
     *
     * GET /v1/certificates/{certificateNumber}/verify
     */
    public function verify(string $certificateNumber): JsonResponse
    {
        $certificate = $this->certificateService->verify($certificateNumber);

        if (!$certificate) {
            return response()->json([
                'success' => false,
                'message' => 'الشهادة غير موجودة',
                'data' => [
                    'is_valid' => false,
                ],
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => $certificate->isValid() ? 'الشهادة صالحة' : 'الشهادة ملغاة',
            'data' => [
                'is_valid' => $certificate->isValid(),
                'certificate_number' => $certificate->certificate_number,
                'student_name' => $certificate->student_name,
                'course_title' => $certificate->course_title,
                'instructor_name' => $certificate->instructor_name,
                'completion_date' => $certificate->completion_date->format('Y-m-d'),
                'average_score' => $certificate->average_score,
                'issued_at' => $certificate->issued_at->toIso8601String(),
                'revoked_at' => $certificate->revoked_at?->toIso8601String(),
                'revocation_reason' => $certificate->revocation_reason,
            ],
        ]);
    }

    /**
     * Get user's certificates
     *
     * GET /v1/certificates/my-certificates
     */
    public function myCertificates(Request $request): JsonResponse
    {
        $certificates = $this->certificateService->getUserCertificates($request->user());

        return response()->json([
            'success' => true,
            'data' => $certificates->map(function ($certificate) {
                return [
                    'id' => $certificate->id,
                    'certificate_number' => $certificate->certificate_number,
                    'course_id' => $certificate->course_id,
                    'course_title' => $certificate->course_title,
                    'course_thumbnail' => $certificate->course?->thumbnail_url,
                    'completion_date' => $certificate->completion_date->format('Y-m-d'),
                    'average_score' => $certificate->average_score,
                    'pdf_url' => $certificate->pdf_url,
                    'verification_url' => $certificate->verification_url,
                    'is_valid' => $certificate->isValid(),
                    'issued_at' => $certificate->issued_at->toIso8601String(),
                ];
            }),
        ]);
    }

    /**
     * Download certificate PDF
     *
     * GET /v1/certificates/{certificateNumber}/download
     */
    public function download(Request $request, string $certificateNumber)
    {
        $certificate = Certificate::where('certificate_number', $certificateNumber)->first();

        if (!$certificate) {
            return response()->json([
                'success' => false,
                'message' => 'الشهادة غير موجودة',
            ], 404);
        }

        // Check if the certificate belongs to the user
        if ($certificate->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'غير مصرح',
            ], 403);
        }

        if (!$certificate->pdf_path || !Storage::exists('public/' . $certificate->pdf_path)) {
            // Regenerate PDF if not exists
            try {
                $pdfPath = $this->certificateService->generatePdf($certificate);
                $certificate->pdf_path = $pdfPath;
                $certificate->pdf_url = Storage::url($pdfPath);
                $certificate->save();
            } catch (\Exception $e) {
                return response()->json([
                    'success' => false,
                    'message' => 'فشل في تحميل الشهادة',
                ], 500);
            }
        }

        $filename = 'certificate-' . $certificate->certificate_number . '.pdf';

        return Storage::download('public/' . $certificate->pdf_path, $filename, [
            'Content-Type' => 'application/pdf',
        ]);
    }
}
