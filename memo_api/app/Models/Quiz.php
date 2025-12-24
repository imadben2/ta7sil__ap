<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Quiz extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'subject_id',
        'academic_stream_id',
        'chapter_id',
        'title_ar',
        'slug',
        'description_ar',
        'quiz_type',
        'time_limit_minutes',
        'passing_score',
        'difficulty_level',
        'estimated_duration_minutes',
        'shuffle_questions',
        'shuffle_answers',
        'show_correct_answers',
        'allow_review',
        'tags',
        'total_questions',
        'average_score',
        'total_attempts',
        'is_published',
        'is_premium',
        'created_by',
    ];

    protected $casts = [
        'tags' => 'array',
        'shuffle_questions' => 'boolean',
        'shuffle_answers' => 'boolean',
        'show_correct_answers' => 'boolean',
        'allow_review' => 'boolean',
        'is_published' => 'boolean',
        'is_premium' => 'boolean',
        'average_score' => 'decimal:2',
    ];

    // Relationships

    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    public function academicStream(): BelongsTo
    {
        return $this->belongsTo(AcademicStream::class);
    }

    public function chapter(): BelongsTo
    {
        return $this->belongsTo(ContentChapter::class, 'chapter_id');
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function questions(): HasMany
    {
        return $this->hasMany(QuizQuestion::class)->orderBy('question_order');
    }

    public function attempts(): HasMany
    {
        return $this->hasMany(QuizAttempt::class);
    }

    public function completedAttempts(): HasMany
    {
        return $this->hasMany(QuizAttempt::class)->where('status', 'completed');
    }

    // Scopes

    public function scopePublished($query)
    {
        return $query->where('is_published', true);
    }

    public function scopeFree($query)
    {
        return $query->where('is_premium', false);
    }

    public function scopePremium($query)
    {
        return $query->where('is_premium', true);
    }

    public function scopeBySubject($query, $subjectId)
    {
        return $query->where('subject_id', $subjectId);
    }

    public function scopeByDifficulty($query, $difficulty)
    {
        return $query->where('difficulty_level', $difficulty);
    }

    public function scopeByType($query, $type)
    {
        return $query->where('quiz_type', $type);
    }

    public function scopeByTags($query, array $tags)
    {
        return $query->where(function ($q) use ($tags) {
            foreach ($tags as $tag) {
                $q->orWhereJsonContains('tags', $tag);
            }
        });
    }

    public function scopeByStream($query, $streamId)
    {
        return $query->where(function ($q) use ($streamId) {
            $q->where('academic_stream_id', $streamId)
              ->orWhereNull('academic_stream_id'); // Include quizzes available to all streams
        });
    }

    public function scopeForStream($query, $streamId)
    {
        // Strict filter - only quizzes for this stream (excludes null)
        return $query->where('academic_stream_id', $streamId);
    }

    // Helper Methods

    public function updateStatistics(): void
    {
        $this->total_questions = $this->questions()->count();
        $completedAttempts = $this->completedAttempts();
        $this->total_attempts = $completedAttempts->count();
        $this->average_score = $completedAttempts->avg('score_percentage') ?? 0;
        $this->save();
    }

    public function getUserAttempts(User $user)
    {
        return $this->attempts()
            ->where('user_id', $user->id)
            ->orderBy('started_at', 'desc')
            ->get();
    }

    public function getUserBestScore(User $user): ?float
    {
        return $this->attempts()
            ->where('user_id', $user->id)
            ->where('status', 'completed')
            ->max('score_percentage');
    }

    public function getUserAverageScore(User $user): ?float
    {
        return $this->attempts()
            ->where('user_id', $user->id)
            ->where('status', 'completed')
            ->avg('score_percentage');
    }

    public function getUserLastAttempt(User $user): ?QuizAttempt
    {
        return $this->attempts()
            ->where('user_id', $user->id)
            ->where('status', 'completed')
            ->latest('completed_at')
            ->first();
    }

    public function canUserStart(User $user): bool
    {
        // Check if there's an in-progress attempt
        $inProgressAttempt = $this->attempts()
            ->where('user_id', $user->id)
            ->where('status', 'in_progress')
            ->exists();

        return !$inProgressAttempt;
    }

    public function isPublished(): bool
    {
        return $this->is_published;
    }

    public function isPremium(): bool
    {
        return $this->is_premium;
    }

    public function isTimed(): bool
    {
        return $this->quiz_type === 'timed' || $this->quiz_type === 'exam';
    }

    public function isExamMode(): bool
    {
        return $this->quiz_type === 'exam';
    }

    public function getDurationCategory(): string
    {
        if ($this->estimated_duration_minutes < 15) {
            return 'short';
        } elseif ($this->estimated_duration_minutes <= 30) {
            return 'medium';
        } else {
            return 'long';
        }
    }
}
