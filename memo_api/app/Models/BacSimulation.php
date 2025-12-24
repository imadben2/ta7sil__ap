<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class BacSimulation extends Model
{
    protected $fillable = [
        'user_id',
        'bac_subject_id',
        'started_at',
        'submitted_at',
        'duration_seconds',
        'time_limit_seconds',
        'status',
        'user_score',
        'self_evaluated',
        'chapter_scores',
        'difficulty_felt',
        'user_notes'
    ];

    protected $casts = [
        'started_at' => 'datetime',
        'submitted_at' => 'datetime',
        'duration_seconds' => 'integer',
        'time_limit_seconds' => 'integer',
        'user_score' => 'decimal:2',
        'self_evaluated' => 'boolean',
        'chapter_scores' => 'array',
    ];

    /**
     * Get the user who took this simulation
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the BAC subject
     */
    public function bacSubject()
    {
        return $this->belongsTo(BacSubject::class);
    }

    /**
     * Check if the simulation is still in progress
     */
    public function isInProgress()
    {
        return $this->status === 'started';
    }

    /**
     * Check if the simulation is completed
     */
    public function isCompleted()
    {
        return $this->status === 'completed';
    }

    /**
     * Check if the simulation is abandoned
     */
    public function isAbandoned()
    {
        return $this->status === 'abandoned';
    }

    /**
     * Get remaining time in seconds
     */
    public function getRemainingTimeSeconds()
    {
        if ($this->status !== 'started') {
            return 0;
        }

        $allowedDuration = $this->bacSubject->duration_minutes * 60;
        $elapsed = Carbon::now()->diffInSeconds($this->started_at);
        $remaining = $allowedDuration - $elapsed;

        return max(0, $remaining);
    }

    /**
     * Check if the simulation has expired
     */
    public function hasExpired()
    {
        return $this->getRemainingTimeSeconds() === 0;
    }

    /**
     * Mark simulation as completed
     */
    public function markAsCompleted()
    {
        $this->update([
            'status' => 'completed',
            'submitted_at' => now(),
            'duration_seconds' => Carbon::now()->diffInSeconds($this->started_at)
        ]);
    }

    /**
     * Mark simulation as abandoned
     */
    public function markAsAbandoned()
    {
        $this->update([
            'status' => 'abandoned',
            'duration_seconds' => Carbon::now()->diffInSeconds($this->started_at)
        ]);
    }

    /**
     * Scope for active simulations
     */
    public function scopeActive($query)
    {
        return $query->where('status', 'started');
    }

    /**
     * Scope for completed simulations
     */
    public function scopeCompleted($query)
    {
        return $query->where('status', 'completed');
    }

    /**
     * Save chapter scores and other submission data
     */
    public function saveSubmissionData(array $data)
    {
        $updateData = [
            'status' => 'completed',
            'submitted_at' => now(),
            'duration_seconds' => Carbon::now()->diffInSeconds($this->started_at),
            'self_evaluated' => true
        ];

        if (isset($data['user_score'])) {
            $updateData['user_score'] = $data['user_score'];
        }

        if (isset($data['chapter_scores'])) {
            $updateData['chapter_scores'] = $data['chapter_scores'];
        }

        if (isset($data['difficulty_felt'])) {
            $updateData['difficulty_felt'] = $data['difficulty_felt'];
        }

        if (isset($data['user_notes'])) {
            $updateData['user_notes'] = $data['user_notes'];
        }

        $this->update($updateData);
    }

    /**
     * Get grade label based on score
     */
    public function getGradeLabel()
    {
        if (!$this->user_score) {
            return null;
        }

        $score = $this->user_score;

        if ($score >= 16) {
            return 'ممتاز';
        } elseif ($score >= 14) {
            return 'جيد جداً';
        } elseif ($score >= 12) {
            return 'جيد';
        } elseif ($score >= 10) {
            return 'متوسط';
        } else {
            return 'ضعيف';
        }
    }

    /**
     * Calculate percentage score
     */
    public function getPercentage()
    {
        if (!$this->user_score || !$this->bacSubject) {
            return 0;
        }

        $totalPoints = $this->bacSubject->total_points ?? 20;
        return round(($this->user_score / $totalPoints) * 100, 2);
    }
}
