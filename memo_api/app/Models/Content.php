<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Content extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'subject_id',
        'academic_stream_id',
        'content_type_id',
        'chapter_id',
        'title_ar',
        'slug',
        'description_ar',
        'content_body_ar',
        'difficulty_level',
        'estimated_duration_minutes',
        'order',
        'prerequisites',
        'has_file',
        'file_path',
        'file_type',
        'file_size',
        'has_video',
        'video_type',
        'video_url',
        'video_duration_seconds',
        'is_published',
        'published_at',
        'is_premium',
        'tags',
        'search_keywords',
        'views_count',
        'downloads_count',
        'created_by',
        'updated_by',
    ];

    protected $casts = [
        'prerequisites' => 'array',
        'tags' => 'array',
        'has_file' => 'boolean',
        'has_video' => 'boolean',
        'is_published' => 'boolean',
        'is_premium' => 'boolean',
        'published_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];

    /**
     * Get the subject that owns this content.
     */
    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    /**
     * Get the academic stream this content belongs to.
     * Null means content is shared across all streams.
     */
    public function academicStream(): BelongsTo
    {
        return $this->belongsTo(AcademicStream::class);
    }

    /**
     * Get the content type that owns this content.
     */
    public function contentType(): BelongsTo
    {
        return $this->belongsTo(ContentType::class, 'content_type_id');
    }

    /**
     * Get the chapter that owns this content.
     */
    public function chapter(): BelongsTo
    {
        return $this->belongsTo(ContentChapter::class, 'chapter_id');
    }

    /**
     * Get the user who created this content.
     */
    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    /**
     * Get the user who last updated this content.
     */
    public function updater(): BelongsTo
    {
        return $this->belongsTo(User::class, 'updated_by');
    }

    /**
     * Get the ratings for this content.
     */
    public function ratings(): HasMany
    {
        return $this->hasMany(ContentRating::class);
    }

    /**
     * Get the user progress records for this content.
     */
    public function userProgress(): HasMany
    {
        return $this->hasMany(UserContentProgress::class);
    }

    /**
     * Get the session activities for this content.
     */
    public function sessionActivities(): HasMany
    {
        return $this->hasMany(SessionActivity::class);
    }

    /**
     * Get the bookmarks for this content.
     */
    public function bookmarks(): HasMany
    {
        return $this->hasMany(ContentBookmark::class);
    }

    /**
     * Get the quizzes linked to this content (many-to-many).
     */
    public function quizzes(): BelongsToMany
    {
        return $this->belongsToMany(Quiz::class, 'content_quiz')
            ->withTimestamps();
    }

    /**
     * Scope a query to only include published content.
     */
    public function scopePublished($query)
    {
        return $query->where('is_published', true);
    }

    /**
     * Scope a query to only include free content.
     */
    public function scopeFree($query)
    {
        return $query->where('is_premium', false);
    }

    /**
     * Scope a query to only include premium content.
     */
    public function scopePremium($query)
    {
        return $query->where('is_premium', true);
    }

    /**
     * Scope to filter by difficulty.
     */
    public function scopeDifficulty($query, $level)
    {
        return $query->where('difficulty_level', $level);
    }

    /**
     * Scope to search by keywords.
     */
    public function scopeSearch($query, $search)
    {
        return $query->where(function($q) use ($search) {
            $q->where('title_ar', 'LIKE', "%{$search}%")
              ->orWhere('description_ar', 'LIKE', "%{$search}%")
              ->orWhere('search_keywords', 'LIKE', "%{$search}%");
        });
    }

    /**
     * Scope to filter by academic stream.
     * Returns content specific to the stream OR shared content (null stream).
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

    /**
     * Get average rating.
     */
    public function getAverageRatingAttribute()
    {
        return $this->ratings()->avg('rating') ?? 0;
    }

    /**
     * Get total ratings count.
     */
    public function getTotalRatingsAttribute()
    {
        return $this->ratings()->count();
    }
}
