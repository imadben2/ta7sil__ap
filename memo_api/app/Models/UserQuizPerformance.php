<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserQuizPerformance extends Model
{
    use HasFactory;

    protected $table = 'user_quiz_performance';

    protected $fillable = [
        'user_id',
        'subject_id',
        'quiz_id',
        'total_attempts',
        'best_score',
        'average_score',
        'total_time_spent_minutes',
        'last_attempt_date',
        'weak_concepts',
    ];

    protected $casts = [
        'best_score' => 'decimal:2',
        'average_score' => 'decimal:2',
        'last_attempt_date' => 'datetime',
        'weak_concepts' => 'array',
    ];

    // Relationships

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    public function quiz(): BelongsTo
    {
        return $this->belongsTo(Quiz::class);
    }

    // Helper Methods

    public function updateFromAttempt(QuizAttempt $attempt): void
    {
        $this->total_attempts++;
        $this->best_score = max($this->best_score ?? 0, $attempt->score_percentage);

        // Recalculate average
        $totalScore = ($this->average_score ?? 0) * ($this->total_attempts - 1) + $attempt->score_percentage;
        $this->average_score = $totalScore / $this->total_attempts;

        $this->total_time_spent_minutes += ($attempt->time_spent_seconds ?? 0) / 60;
        $this->last_attempt_date = $attempt->completed_at;

        $this->save();
    }

    public function addWeakConcept(string $tag, float $errorRate): void
    {
        $weakConcepts = $this->weak_concepts ?? [];

        // Find if concept already exists
        $found = false;
        foreach ($weakConcepts as &$concept) {
            if ($concept['tag'] === $tag) {
                // Update error rate (average)
                $concept['error_rate'] = ($concept['error_rate'] + $errorRate) / 2;
                $found = true;
                break;
            }
        }

        // Add new concept if not found
        if (!$found) {
            $weakConcepts[] = [
                'tag' => $tag,
                'error_rate' => $errorRate,
            ];
        }

        // Sort by error rate (highest first)
        usort($weakConcepts, function ($a, $b) {
            return $b['error_rate'] <=> $a['error_rate'];
        });

        // Keep only top 10
        $this->weak_concepts = array_slice($weakConcepts, 0, 10);
        $this->save();
    }

    public function getTopWeakConcepts(int $limit = 5): array
    {
        $weakConcepts = $this->weak_concepts ?? [];
        return array_slice($weakConcepts, 0, $limit);
    }

    public function hasWeakConcepts(): bool
    {
        return !empty($this->weak_concepts);
    }

    public function getImprovementRate(): ?float
    {
        if ($this->total_attempts < 2) {
            return null;
        }

        // Simple improvement: best vs average
        if ($this->average_score == 0) {
            return 0;
        }

        return (($this->best_score - $this->average_score) / $this->average_score) * 100;
    }
}
