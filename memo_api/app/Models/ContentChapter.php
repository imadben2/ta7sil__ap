<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ContentChapter extends Model
{
    protected $fillable = [
        'subject_id',
        'academic_stream_id',
        'title_ar',
        'slug',
        'description_ar',
        'order',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'order' => 'integer',
    ];

    // Relationships
    public function subject()
    {
        return $this->belongsTo(Subject::class);
    }

    /**
     * Get the academic stream this chapter belongs to.
     * Null means chapter is shared across all streams.
     */
    public function academicStream()
    {
        return $this->belongsTo(AcademicStream::class);
    }

    public function contents()
    {
        return $this->hasMany(Content::class, 'chapter_id');
    }

    /**
     * Scope to filter by academic stream.
     * Returns chapters specific to the stream OR shared chapters (null stream).
     *
     * @param \Illuminate\Database\Eloquent\Builder $query
     * @param int|null $streamId
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeForStream($query, $streamId)
    {
        if ($streamId === null) {
            return $query;
        }

        return $query->where(function ($q) use ($streamId) {
            $q->where('academic_stream_id', $streamId)
              ->orWhereNull('academic_stream_id');
        });
    }
}
