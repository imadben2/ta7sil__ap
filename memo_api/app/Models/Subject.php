<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Subject extends Model
{
    // Subject categories - DEPRECATED: Now stored per stream in subject_stream.category
    // Kept for backward compatibility only
    public const CATEGORY_HARD_CORE = 'HARD_CORE';
    public const CATEGORY_LANGUAGE = 'LANGUAGE';
    public const CATEGORY_MEMORIZATION = 'MEMORIZATION';
    public const CATEGORY_OTHER = 'OTHER';

    protected $fillable = [
        'academic_stream_ids',
        'academic_year_id',
        'name_ar',
        'slug',
        'description_ar',
        'color',
        'icon',
        'coefficient',
        'category',
        'order',
        'is_active',
    ];

    protected $casts = [
        'academic_stream_ids' => 'array',
        'coefficient' => 'float',
        'is_active' => 'boolean',
    ];

    /**
     * Check if this is a HARD_CORE subject (رياضيات/فيزياء/علوم)
     * @deprecated Use SubjectStream->isHardCore() for stream-specific category
     */
    public function isHardCore(): bool
    {
        return $this->category === self::CATEGORY_HARD_CORE;
    }

    /**
     * Check if this is a LANGUAGE subject (العربية/الفرنسية/الإنجليزية)
     * @deprecated Use SubjectStream->isLanguage() for stream-specific category
     */
    public function isLanguage(): bool
    {
        return $this->category === self::CATEGORY_LANGUAGE;
    }

    /**
     * Check if this is a MEMORIZATION subject (إسلامية/تاريخ-جغرافيا/فلسفة)
     * @deprecated Use SubjectStream->isMemorization() for stream-specific category
     */
    public function isMemorization(): bool
    {
        return $this->category === self::CATEGORY_MEMORIZATION;
    }

    /**
     * Get the category weight for priority calculation
     * @deprecated Use SubjectStream->getCategoryWeight() for stream-specific category
     */
    public function getCategoryWeight(): float
    {
        return match ($this->category) {
            self::CATEGORY_HARD_CORE => 1.10,
            self::CATEGORY_LANGUAGE => 0.95,
            self::CATEGORY_MEMORIZATION => 1.00,
            default => 1.00,
        };
    }

    /**
     * Get preferred energy levels for this subject's category
     * @deprecated Use SubjectStream->getPreferredEnergyOrder() for stream-specific category
     */
    public function getPreferredEnergyOrder(): array
    {
        return match ($this->category) {
            self::CATEGORY_HARD_CORE => ['HIGH', 'MEDIUM', 'LOW'],
            self::CATEGORY_MEMORIZATION => ['MEDIUM', 'LOW', 'HIGH'],
            self::CATEGORY_LANGUAGE => ['LOW', 'MEDIUM', 'HIGH'],
            default => ['MEDIUM', 'HIGH', 'LOW'],
        };
    }

    /**
     * Get the category for a specific stream.
     * Returns the stream-specific category from subject_stream table.
     */
    public function getCategoryForStream(int $streamId): ?string
    {
        $pivot = $this->subjectStreams()
            ->where('academic_stream_id', $streamId)
            ->first();

        return $pivot ? $pivot->category : $this->category;
    }

    /**
     * Get the streams relationship via pivot table.
     * Returns BelongsToMany with coefficient as pivot attribute.
     */
    public function streams(): BelongsToMany
    {
        return $this->belongsToMany(AcademicStream::class, 'subject_stream')
            ->withPivot(['coefficient', 'is_active'])
            ->withTimestamps();
    }

    /**
     * Get the subject_stream pivot records.
     */
    public function subjectStreams(): HasMany
    {
        return $this->hasMany(SubjectStream::class);
    }

    /**
     * Get the academic streams associated with this subject.
     * Returns a Collection of AcademicStream models.
     * @deprecated Use streams() relationship instead
     */
    public function academicStreams()
    {
        return AcademicStream::whereIn('id', $this->academic_stream_ids ?? [])->get();
    }

    /**
     * Check if this subject belongs to a specific academic stream.
     */
    public function belongsToStream(int $streamId): bool
    {
        return in_array($streamId, $this->academic_stream_ids ?? []);
    }

    /**
     * Get the coefficient for a specific stream.
     * Falls back to the subject's default coefficient if not found in pivot.
     */
    public function getCoefficientForStream(int $streamId): float
    {
        $pivot = $this->subjectStreams()
            ->where('academic_stream_id', $streamId)
            ->first();

        return $pivot ? $pivot->coefficient : ($this->coefficient ?? 1.0);
    }

    /**
     * Scope a query to filter subjects by academic stream.
     * Uses JSON contains for array field.
     */
    public function scopeForStream($query, $streamId)
    {
        // Cast to integer - important because whereJsonContains matches type exactly
        $streamId = (int) $streamId;

        return $query->where(function ($q) use ($streamId) {
            $q->whereJsonContains('academic_stream_ids', $streamId)
              ->orWhereNull('academic_stream_ids');
        });
    }

    /**
     * Get the academic year that owns this subject.
     */
    public function academicYear(): BelongsTo
    {
        return $this->belongsTo(AcademicYear::class);
    }

    /**
     * Get the contents for this subject.
     */
    public function contents(): HasMany
    {
        return $this->hasMany(Content::class);
    }

    /**
     * Get the content chapters for this subject.
     */
    public function contentChapters(): HasMany
    {
        return $this->hasMany(ContentChapter::class);
    }

    /**
     * Get the subject priorities for this subject.
     */
    public function subjectPriorities(): HasMany
    {
        return $this->hasMany(SubjectPriority::class);
    }

    /**
     * Get the exam schedules for this subject.
     */
    public function examSchedules(): HasMany
    {
        return $this->hasMany(ExamSchedule::class);
    }

    /**
     * Get the users that have selected this subject.
     */
    public function users(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'user_subjects')
            ->withTimestamps();
    }

    /**
     * Get the BAC subjects for this subject.
     */
    public function bacSubjects(): HasMany
    {
        return $this->hasMany(BacSubject::class);
    }

    /**
     * Get the user progress records for this subject.
     */
    public function progress(): HasMany
    {
        return $this->hasMany(UserSubjectProgress::class);
    }

    /**
     * Get the progress for a specific user.
     */
    public function userProgress($userId)
    {
        return $this->progress()->where('user_id', $userId)->first();
    }
}
