<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Pivot model for Subject-Stream relationship.
 * Stores stream-specific data like coefficient.
 */
class SubjectStream extends Model
{
    protected $table = 'subject_stream';

    // Subject categories - now stored per stream
    public const CATEGORY_HARD_CORE = 'HARD_CORE';
    public const CATEGORY_LANGUAGE = 'LANGUAGE';
    public const CATEGORY_MEMORIZATION = 'MEMORIZATION';
    public const CATEGORY_OTHER = 'OTHER';

    protected $fillable = [
        'subject_id',
        'academic_stream_id',
        'coefficient',
        'category',
        'is_active',
    ];

    protected $casts = [
        'coefficient' => 'float',
        'is_active' => 'boolean',
    ];

    /**
     * Get the subject.
     */
    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    /**
     * Get the academic stream.
     */
    public function academicStream(): BelongsTo
    {
        return $this->belongsTo(AcademicStream::class);
    }

    /**
     * Check if this is a HARD_CORE subject in this stream.
     */
    public function isHardCore(): bool
    {
        return $this->category === self::CATEGORY_HARD_CORE;
    }

    /**
     * Check if this is a LANGUAGE subject in this stream.
     */
    public function isLanguage(): bool
    {
        return $this->category === self::CATEGORY_LANGUAGE;
    }

    /**
     * Check if this is a MEMORIZATION subject in this stream.
     */
    public function isMemorization(): bool
    {
        return $this->category === self::CATEGORY_MEMORIZATION;
    }

    /**
     * Get the category weight for priority calculation.
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
     * Get preferred energy levels for this subject's category.
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
}
