<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasManyThrough;

class AcademicPhase extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'name_ar',
        'slug',
        'order',
    ];

    /**
     * Get the academic years for this phase.
     */
    public function academicYears(): HasMany
    {
        return $this->hasMany(AcademicYear::class);
    }

    /**
     * Get the academic streams for this phase (through academic years).
     */
    public function academicStreams(): HasManyThrough
    {
        return $this->hasManyThrough(AcademicStream::class, AcademicYear::class);
    }
}
