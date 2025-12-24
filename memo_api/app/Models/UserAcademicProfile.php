<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserAcademicProfile extends Model
{
    protected $fillable = [
        'user_id',
        'academic_phase_id',
        'academic_year_id',
        'academic_stream_id',
        'target_score',
        'study_hours_per_day',
        'onboarding_completed',
    ];

    protected $casts = [
        'target_score' => 'decimal:2',
        'study_hours_per_day' => 'integer',
    ];

    /**
     * Get the user that owns this academic profile.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the academic year.
     */
    public function academicYear(): BelongsTo
    {
        return $this->belongsTo(AcademicYear::class);
    }

    /**
     * Get the academic stream.
     */
    public function academicStream(): BelongsTo
    {
        return $this->belongsTo(AcademicStream::class);
    }

    /**
     * Get the academic phase.
     */
    public function academicPhase(): BelongsTo
    {
        return $this->belongsTo(AcademicPhase::class);
    }
}
