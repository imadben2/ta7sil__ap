<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;

class FlashcardDeck extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'subject_id',
        'chapter_id',
        'academic_stream_id',
        'title_ar',
        'title_fr',
        'slug',
        'description_ar',
        'description_fr',
        'cover_image_url',
        'color',
        'icon',
        'total_cards',
        'estimated_study_minutes',
        'difficulty_level',
        'tags',
        'is_published',
        'is_premium',
        'order',
        'created_by',
    ];

    protected $casts = [
        'tags' => 'array',
        'is_published' => 'boolean',
        'is_premium' => 'boolean',
        'total_cards' => 'integer',
        'estimated_study_minutes' => 'integer',
        'order' => 'integer',
    ];

    /**
     * Boot method for generating slug
     */
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($deck) {
            if (empty($deck->slug)) {
                $deck->slug = Str::slug($deck->title_ar) . '-' . Str::random(6);
            }
        });
    }

    // ==================== Relationships ====================

    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    public function chapter(): BelongsTo
    {
        return $this->belongsTo(ContentChapter::class, 'chapter_id');
    }

    /**
     * Single stream relationship (legacy, for backward compatibility)
     */
    public function academicStream(): BelongsTo
    {
        return $this->belongsTo(AcademicStream::class);
    }

    /**
     * Many-to-many relationship with academic streams.
     * A flashcard deck can belong to multiple streams (like subjects).
     */
    public function academicStreams(): BelongsToMany
    {
        return $this->belongsToMany(AcademicStream::class, 'flashcard_deck_stream')
            ->withTimestamps();
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function flashcards(): HasMany
    {
        return $this->hasMany(Flashcard::class, 'deck_id');
    }

    public function activeFlashcards(): HasMany
    {
        return $this->flashcards()->where('is_active', true)->orderBy('order');
    }

    public function reviewSessions(): HasMany
    {
        return $this->hasMany(FlashcardReviewSession::class, 'deck_id');
    }

    // ==================== Scopes ====================

    public function scopePublished($query)
    {
        return $query->where('is_published', true);
    }

    public function scopeBySubject($query, $subjectId)
    {
        return $query->where('subject_id', $subjectId);
    }

    public function scopeByChapter($query, $chapterId)
    {
        return $query->where('chapter_id', $chapterId);
    }

    /**
     * Scope to filter decks available for a specific stream.
     * Includes decks that:
     * - Have no streams assigned (available to all)
     * - Have the specified stream in the pivot table
     * - Have the specified stream in the legacy column (backward compatibility)
     */
    public function scopeForStream($query, $streamId)
    {
        return $query->where(function ($q) use ($streamId) {
            // No streams assigned = available to all
            $q->whereDoesntHave('academicStreams')
              ->where(function ($sub) {
                  $sub->whereNull('academic_stream_id');
              });
        })->orWhere(function ($q) use ($streamId) {
            // Has the stream in pivot table
            $q->whereHas('academicStreams', function ($sub) use ($streamId) {
                $sub->where('academic_streams.id', $streamId);
            });
        })->orWhere(function ($q) use ($streamId) {
            // Legacy: has the stream in the single column
            $q->where('academic_stream_id', $streamId);
        });
    }

    public function scopePremium($query, $isPremium = true)
    {
        return $query->where('is_premium', $isPremium);
    }

    public function scopeFree($query)
    {
        return $query->where('is_premium', false);
    }

    public function scopeSearch($query, $search)
    {
        return $query->where(function ($q) use ($search) {
            $q->where('title_ar', 'like', "%{$search}%")
              ->orWhere('title_fr', 'like', "%{$search}%")
              ->orWhere('description_ar', 'like', "%{$search}%");
        });
    }

    // ==================== Helpers ====================

    /**
     * Update the card count (call after adding/removing cards)
     */
    public function updateCardCount(): void
    {
        $this->update([
            'total_cards' => $this->activeFlashcards()->count(),
        ]);
    }

    /**
     * Get user's progress for this deck
     */
    public function getUserProgress($userId): array
    {
        $cardIds = $this->activeFlashcards()->pluck('id');

        if ($cardIds->isEmpty()) {
            return [
                'cards_studied' => 0,
                'cards_mastered' => 0,
                'cards_due' => 0,
                'cards_new' => $this->total_cards,
                'mastery_percentage' => 0,
                'average_retention' => 0,
                'last_studied_at' => null,
            ];
        }

        $progress = UserFlashcardProgress::where('user_id', $userId)
            ->whereIn('flashcard_id', $cardIds)
            ->get();

        $cardsStudied = $progress->count();
        $cardsMastered = $progress->where('interval', '>=', 21)->count();
        $cardsDue = $progress->filter(function ($p) {
            return $p->next_review_date && $p->next_review_date <= now()->toDateString();
        })->count();
        $cardsNew = $this->total_cards - $cardsStudied;

        $avgRetention = $progress->avg(function ($p) {
            return $p->total_reviews > 0 ? ($p->correct_reviews / $p->total_reviews) * 100 : 0;
        }) ?? 0;

        $lastStudied = $progress->max('last_review_date');

        return [
            'cards_studied' => $cardsStudied,
            'cards_mastered' => $cardsMastered,
            'cards_due' => $cardsDue,
            'cards_new' => $cardsNew,
            'mastery_percentage' => $this->total_cards > 0 ? round(($cardsMastered / $this->total_cards) * 100, 1) : 0,
            'average_retention' => round($avgRetention, 1),
            'last_studied_at' => $lastStudied,
        ];
    }

    /**
     * Get cards due for review for a user
     */
    public function getDueCardsForUser($userId, $limit = 50)
    {
        $today = now()->toDateString();

        return $this->activeFlashcards()
            ->whereHas('userProgress', function ($q) use ($userId, $today) {
                $q->where('user_id', $userId)
                  ->where('next_review_date', '<=', $today);
            })
            ->with(['userProgress' => function ($q) use ($userId) {
                $q->where('user_id', $userId);
            }])
            ->limit($limit)
            ->get();
    }

    /**
     * Get new cards (never studied) for a user
     */
    public function getNewCardsForUser($userId, $limit = 20)
    {
        return $this->activeFlashcards()
            ->whereDoesntHave('userProgress', function ($q) use ($userId) {
                $q->where('user_id', $userId);
            })
            ->limit($limit)
            ->get();
    }
}
