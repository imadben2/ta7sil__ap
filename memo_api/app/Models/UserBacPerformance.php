<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserBacPerformance extends Model
{
    const UPDATED_AT = 'updated_at';
    const CREATED_AT = null;

    protected $table = 'user_bac_performance';

    protected $fillable = [
        'user_id',
        'subject_id',
        'total_simulations',
        'average_score',
        'best_score',
        'weak_chapters'
    ];

    protected $casts = [
        'total_simulations' => 'integer',
        'average_score' => 'decimal:2',
        'best_score' => 'decimal:2',
        'weak_chapters' => 'array',
    ];

    /**
     * Get the user
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the subject
     */
    public function subject()
    {
        return $this->belongsTo(Subject::class);
    }

    /**
     * Update performance metrics after a simulation
     */
    public function updateAfterSimulation($score, $chapterScores)
    {
        // Update total simulations
        $this->increment('total_simulations');

        // Update best score if current score is higher
        if ($this->best_score === null || $score > $this->best_score) {
            $this->best_score = $score;
        }

        // Calculate new average score
        $totalScore = ($this->average_score ?? 0) * ($this->total_simulations - 1) + $score;
        $this->average_score = $totalScore / $this->total_simulations;

        // Update weak chapters (chapters with score < 50%)
        $weakChapters = [];
        foreach ($chapterScores as $chapterId => $chapterScore) {
            if ($chapterScore < 50) {
                $weakChapters[] = [
                    'chapter_id' => $chapterId,
                    'score' => $chapterScore
                ];
            }
        }
        $this->weak_chapters = $weakChapters;

        $this->save();
    }

    /**
     * Get weak chapters with details
     */
    public function getWeakChaptersWithDetails()
    {
        if (!$this->weak_chapters) {
            return collect();
        }

        $chapterIds = collect($this->weak_chapters)->pluck('chapter_id');
        $chapters = BacSubjectChapter::whereIn('id', $chapterIds)->get()->keyBy('id');

        return collect($this->weak_chapters)->map(function ($item) use ($chapters) {
            return [
                'chapter' => $chapters->get($item['chapter_id']),
                'score' => $item['score']
            ];
        });
    }
}
