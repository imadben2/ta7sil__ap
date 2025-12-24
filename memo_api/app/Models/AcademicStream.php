<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class AcademicStream extends Model
{
    protected $fillable = [
        'academic_year_id',
        'name_ar',
        'slug',
        'description_ar',
        'order',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    /**
     * Get the academic year that owns this stream.
     */
    public function academicYear(): BelongsTo
    {
        return $this->belongsTo(AcademicYear::class);
    }

    /**
     * Get the subjects for this stream via pivot table.
     * Returns BelongsToMany with coefficient as pivot attribute.
     */
    public function subjects(): BelongsToMany
    {
        return $this->belongsToMany(Subject::class, 'subject_stream')
            ->withPivot(['coefficient', 'is_active'])
            ->withTimestamps();
    }

    /**
     * Get the subject_stream pivot records for this stream.
     */
    public function subjectStreams(): HasMany
    {
        return $this->hasMany(SubjectStream::class, 'academic_stream_id');
    }

    /**
     * Get the user academic profiles for this stream.
     */
    public function userAcademicProfiles(): HasMany
    {
        return $this->hasMany(UserAcademicProfile::class);
    }

    /**
     * Get the BAC subjects for this stream.
     */
    public function bacSubjects(): HasMany
    {
        return $this->hasMany(BacSubject::class);
    }

    /**
     * Get the BAC study days for this stream.
     */
    public function bacStudyDays(): HasMany
    {
        return $this->hasMany(BacStudyDay::class)->orderBy('day_number');
    }

    /**
     * Get the BAC weekly rewards for this stream.
     */
    public function bacWeeklyRewards(): HasMany
    {
        return $this->hasMany(BacWeeklyReward::class)->orderBy('week_number');
    }
}
