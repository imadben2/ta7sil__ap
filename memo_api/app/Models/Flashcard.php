<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Flashcard extends Model
{
    use HasFactory, SoftDeletes;

    // Card type constants
    public const TYPE_BASIC = 'basic';
    public const TYPE_CLOZE = 'cloze';
    public const TYPE_IMAGE = 'image';
    public const TYPE_AUDIO = 'audio';

    protected $fillable = [
        'deck_id',
        'card_type',
        'front_text_ar',
        'front_text_fr',
        'front_image_url',
        'front_audio_url',
        'back_text_ar',
        'back_text_fr',
        'back_image_url',
        'back_audio_url',
        'cloze_template',
        'cloze_deletions',
        'hint_ar',
        'hint_fr',
        'explanation_ar',
        'explanation_fr',
        'tags',
        'difficulty_level',
        'order',
        'is_active',
    ];

    protected $casts = [
        'cloze_deletions' => 'array',
        'tags' => 'array',
        'is_active' => 'boolean',
        'order' => 'integer',
    ];

    // ==================== Relationships ====================

    public function deck(): BelongsTo
    {
        return $this->belongsTo(FlashcardDeck::class, 'deck_id');
    }

    public function userProgress(): HasMany
    {
        return $this->hasMany(UserFlashcardProgress::class, 'flashcard_id');
    }

    public function reviewLogs(): HasMany
    {
        return $this->hasMany(FlashcardReviewLog::class, 'flashcard_id');
    }

    /**
     * Get progress for a specific user
     */
    public function progressForUser($userId): HasOne
    {
        return $this->hasOne(UserFlashcardProgress::class, 'flashcard_id')
            ->where('user_id', $userId);
    }

    // ==================== Scopes ====================

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeByType($query, $type)
    {
        return $query->where('card_type', $type);
    }

    public function scopeOrdered($query)
    {
        return $query->orderBy('order');
    }

    public function scopeDueForUser($query, $userId)
    {
        $today = now()->toDateString();

        return $query->whereHas('userProgress', function ($q) use ($userId, $today) {
            $q->where('user_id', $userId)
              ->where('next_review_date', '<=', $today);
        });
    }

    public function scopeNewForUser($query, $userId)
    {
        return $query->whereDoesntHave('userProgress', function ($q) use ($userId) {
            $q->where('user_id', $userId);
        });
    }

    // ==================== Helpers ====================

    /**
     * Get or create progress for a user
     */
    public function getOrCreateProgress($userId): UserFlashcardProgress
    {
        return UserFlashcardProgress::firstOrCreate(
            [
                'user_id' => $userId,
                'flashcard_id' => $this->id,
            ],
            [
                'ease_factor' => 2.50,
                'interval' => 0,
                'repetitions' => 0,
                'learning_state' => 'new',
            ]
        );
    }

    /**
     * Check if card is due for a user
     */
    public function isDueForUser($userId): bool
    {
        $progress = $this->userProgress()->where('user_id', $userId)->first();

        if (!$progress) {
            return true; // New card is always "due"
        }

        return $progress->isDue();
    }

    /**
     * Parse cloze card for display
     * Returns array with question (blanks shown) and answer parts
     */
    public function parseCloze(): array
    {
        if ($this->card_type !== self::TYPE_CLOZE || !$this->cloze_template) {
            return [
                'question' => $this->front_text_ar,
                'answer' => $this->back_text_ar,
                'blanks' => [],
            ];
        }

        $template = $this->cloze_template;
        $blanks = [];

        // Pattern: {{c1::answer::hint}} or {{c1::answer}}
        $pattern = '/\{\{(c\d+)::([^}:]+)(?:::([^}]+))?\}\}/';

        preg_match_all($pattern, $template, $matches, PREG_SET_ORDER);

        foreach ($matches as $match) {
            $blanks[] = [
                'id' => $match[1],
                'answer' => $match[2],
                'hint' => $match[3] ?? null,
            ];
        }

        // Create question with blanks
        $question = preg_replace($pattern, '______', $template);

        // Create answer with revealed text
        $answer = preg_replace($pattern, '$2', $template);

        return [
            'question' => $question,
            'answer' => $answer,
            'blanks' => $blanks,
        ];
    }

    /**
     * Get formatted content based on card type
     */
    public function getFormattedContent(): array
    {
        $base = [
            'id' => $this->id,
            'type' => $this->card_type,
            'hint' => $this->hint_ar,
            'explanation' => $this->explanation_ar,
        ];

        switch ($this->card_type) {
            case self::TYPE_CLOZE:
                $parsed = $this->parseCloze();
                return array_merge($base, [
                    'front' => [
                        'text' => $parsed['question'],
                        'blanks' => $parsed['blanks'],
                    ],
                    'back' => [
                        'text' => $parsed['answer'],
                        'original' => $this->back_text_ar,
                    ],
                ]);

            case self::TYPE_IMAGE:
                return array_merge($base, [
                    'front' => [
                        'text' => $this->front_text_ar,
                        'image_url' => $this->front_image_url,
                    ],
                    'back' => [
                        'text' => $this->back_text_ar,
                        'image_url' => $this->back_image_url,
                    ],
                ]);

            case self::TYPE_AUDIO:
                return array_merge($base, [
                    'front' => [
                        'text' => $this->front_text_ar,
                        'audio_url' => $this->front_audio_url,
                    ],
                    'back' => [
                        'text' => $this->back_text_ar,
                        'audio_url' => $this->back_audio_url,
                    ],
                ]);

            case self::TYPE_BASIC:
            default:
                return array_merge($base, [
                    'front' => [
                        'text' => $this->front_text_ar,
                    ],
                    'back' => [
                        'text' => $this->back_text_ar,
                    ],
                ]);
        }
    }
}
