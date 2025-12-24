<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class QuizQuestion extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'quiz_id',
        'question_type',
        'question_text_ar',
        'question_image_url',
        'options',
        'correct_answer',
        'points',
        'explanation_ar',
        'difficulty',
        'tags',
        'question_order',
    ];

    protected $casts = [
        'options' => 'array',
        'correct_answer' => 'array',
        'tags' => 'array',
    ];

    // Question types constants (database values)
    public const TYPE_SINGLE_CHOICE = 'mcq_single';
    public const TYPE_MULTIPLE_CHOICE = 'mcq_multiple';
    public const TYPE_TRUE_FALSE = 'true_false';
    public const TYPE_MATCHING = 'matching';
    public const TYPE_ORDERING = 'sequence';
    public const TYPE_FILL_BLANK = 'fill_blank';
    public const TYPE_SHORT_ANSWER = 'short_answer';
    public const TYPE_NUMERIC = 'short_answer';

    public static function getQuestionTypes(): array
    {
        return [
            self::TYPE_SINGLE_CHOICE,
            self::TYPE_MULTIPLE_CHOICE,
            self::TYPE_TRUE_FALSE,
            self::TYPE_MATCHING,
            self::TYPE_ORDERING,
            self::TYPE_FILL_BLANK,
            self::TYPE_SHORT_ANSWER,
            self::TYPE_NUMERIC,
        ];
    }

    // Relationships

    public function quiz(): BelongsTo
    {
        return $this->belongsTo(Quiz::class);
    }

    // Helper Methods

    public function isSingleChoice(): bool
    {
        return $this->question_type === self::TYPE_SINGLE_CHOICE;
    }

    public function isMultipleChoice(): bool
    {
        return $this->question_type === self::TYPE_MULTIPLE_CHOICE;
    }

    public function isTrueFalse(): bool
    {
        return $this->question_type === self::TYPE_TRUE_FALSE;
    }

    public function isMatching(): bool
    {
        return $this->question_type === self::TYPE_MATCHING;
    }

    public function isOrdering(): bool
    {
        return $this->question_type === self::TYPE_ORDERING;
    }

    public function isFillBlank(): bool
    {
        return $this->question_type === self::TYPE_FILL_BLANK;
    }

    public function isShortAnswer(): bool
    {
        return $this->question_type === self::TYPE_SHORT_ANSWER;
    }

    public function isNumeric(): bool
    {
        return $this->question_type === self::TYPE_NUMERIC;
    }

    public function requiresManualCorrection(): bool
    {
        return $this->isShortAnswer();
    }

    public function hasImage(): bool
    {
        return !empty($this->question_image_url);
    }

    public function getShuffledOptions(?int $seed = null): ?array
    {
        if (empty($this->options)) {
            return null;
        }

        $options = $this->options;

        if ($seed !== null) {
            mt_srand($seed);
        }

        shuffle($options);

        if ($seed !== null) {
            mt_srand(); // Reset seed
        }

        return $options;
    }

    public function formatForAttempt(bool $shuffle = false, ?int $seed = null): array
    {
        $data = [
            'id' => $this->id,
            'question_type' => $this->question_type,
            'question_text_ar' => $this->question_text_ar,
            'question_image_url' => $this->question_image_url,
            'points' => $this->points ?? 1.0,
            'question_order' => $this->question_order ?? 0,
            'difficulty' => $this->difficulty,
            'tags' => $this->tags,
            'explanation_ar' => null, // Hide explanation until review
        ];

        // Add options for applicable question types (without correct answers)
        if (in_array($this->question_type, [self::TYPE_SINGLE_CHOICE, self::TYPE_MULTIPLE_CHOICE])) {
            $options = $this->options ?? [];

            // Remove is_correct flag for security
            $options = array_map(function ($option) {
                unset($option['is_correct']);
                return $option;
            }, $options);

            if ($shuffle) {
                $options = $this->shuffleArray($options, $seed);
            }

            $data['options'] = $options;
        } elseif ($this->question_type === self::TYPE_MATCHING) {
            $data['options'] = $this->options; // Contains left and right items
        } elseif ($this->question_type === self::TYPE_ORDERING) {
            $options = $this->options ?? [];
            if ($shuffle) {
                $options = $this->shuffleArray($options, $seed);
            }
            $data['options'] = $options;
        } elseif ($this->question_type === self::TYPE_FILL_BLANK) {
            // For fill_blank, we need to tell the app how many blanks there are
            // without revealing the correct answers
            $correctAnswers = $this->correct_answer ?? [];
            $data['options'] = [
                'number_of_blanks' => count($correctAnswers),
            ];
        }

        return $data;
    }

    protected function shuffleArray(array $array, ?int $seed = null): array
    {
        if ($seed !== null) {
            mt_srand($seed);
        }

        shuffle($array);

        if ($seed !== null) {
            mt_srand();
        }

        return $array;
    }
}
