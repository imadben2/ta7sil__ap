<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class AcademicYear extends Model
{
    protected $fillable = [
        'academic_phase_id',
        'name_ar',
        'level_number',
        'order',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    /**
     * Get the phase that owns this academic year.
     */
    public function academicPhase(): BelongsTo
    {
        return $this->belongsTo(AcademicPhase::class);
    }

    /**
     * Get the academic streams for this year.
     */
    public function academicStreams(): HasMany
    {
        return $this->hasMany(AcademicStream::class);
    }

    /**
     * Get the subjects for this academic year.
     */
    public function subjects(): HasMany
    {
        return $this->hasMany(Subject::class);
    }

    /**
     * Get the user academic profiles for this year.
     */
    public function userAcademicProfiles(): HasMany
    {
        return $this->hasMany(UserAcademicProfile::class);
    }
}
