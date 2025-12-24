<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UserSubjectProgress extends Model
{
    use HasFactory;

    protected $table = 'user_subject_progress';

    protected $fillable = [
        'user_id',
        'subject_id',
        'difficulty_level',
        'progress_percentage',
        'last_studied_at',
        'total_chapters',
        'completed_chapters',
        'average_score',
        'last_year_average',
    ];

    protected $casts = [
        'difficulty_level' => 'integer',
        'progress_percentage' => 'decimal:2',
        'last_studied_at' => 'datetime',
        'total_chapters' => 'integer',
        'completed_chapters' => 'integer',
        'average_score' => 'decimal:2',
        'last_year_average' => 'decimal:2',
    ];

    /**
     * Get the user that owns this progress
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the subject for this progress
     */
    public function subject()
    {
        return $this->belongsTo(Subject::class);
    }

    /**
     * Update last studied timestamp
     */
    public function updateLastStudied()
    {
        $this->last_studied_at = now();
        $this->save();
    }

    /**
     * Increment completed chapters
     */
    public function completeChapter()
    {
        $this->completed_chapters = min($this->completed_chapters + 1, $this->total_chapters);
        $this->updateProgressPercentage();
        $this->save();
    }

    /**
     * Update progress percentage based on completed chapters
     */
    protected function updateProgressPercentage()
    {
        if ($this->total_chapters > 0) {
            $this->progress_percentage = ($this->completed_chapters / $this->total_chapters) * 100;
        }
    }

    /**
     * Update average score
     */
    public function updateAverageScore($newScore)
    {
        // Simple moving average - can be enhanced with weighted average
        if ($this->average_score === null) {
            $this->average_score = $newScore;
        } else {
            // Weight new score at 30%, existing average at 70%
            $this->average_score = ($this->average_score * 0.7) + ($newScore * 0.3);
        }
        $this->save();
    }
}
