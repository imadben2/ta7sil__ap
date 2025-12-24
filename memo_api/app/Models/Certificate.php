<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Carbon\Carbon;

class Certificate extends Model
{
    protected $fillable = [
        'certificate_number',
        'user_id',
        'course_id',
        'user_course_progress_id',
        'student_name',
        'course_title',
        'instructor_name',
        'completion_date',
        'average_score',
        'pdf_path',
        'pdf_url',
        'qr_code_data',
        'verification_url',
        'is_verified',
        'revoked_at',
        'revocation_reason',
        'issued_at',
    ];

    protected $casts = [
        'completion_date' => 'date',
        'average_score' => 'decimal:2',
        'is_verified' => 'boolean',
        'revoked_at' => 'datetime',
        'issued_at' => 'datetime',
    ];

    // Relationships
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function course(): BelongsTo
    {
        return $this->belongsTo(Course::class);
    }

    public function progress(): BelongsTo
    {
        return $this->belongsTo(UserCourseProgress::class, 'user_course_progress_id');
    }

    // Status helpers
    public function isRevoked(): bool
    {
        return $this->revoked_at !== null;
    }

    public function isValid(): bool
    {
        return $this->is_verified && !$this->isRevoked();
    }

    // Actions
    public function revoke(string $reason): void
    {
        $this->revoked_at = Carbon::now();
        $this->revocation_reason = $reason;
        $this->is_verified = false;
        $this->save();
    }

    public function reinstate(): void
    {
        $this->revoked_at = null;
        $this->revocation_reason = null;
        $this->is_verified = true;
        $this->save();
    }

    // Generate unique certificate number
    public static function generateCertificateNumber(): string
    {
        do {
            $number = 'CERT-' . strtoupper(substr(md5(uniqid(mt_rand(), true)), 0, 6));
        } while (self::where('certificate_number', $number)->exists());

        return $number;
    }

    // Get verification data for QR code
    public function getVerificationData(): array
    {
        return [
            'certificate_number' => $this->certificate_number,
            'student_name' => $this->student_name,
            'course_title' => $this->course_title,
            'completion_date' => $this->completion_date->format('Y-m-d'),
            'is_valid' => $this->isValid(),
            'verification_url' => $this->verification_url,
        ];
    }
}
