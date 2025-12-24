<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserStats extends Model
{
    const CREATED_AT = null; // No created_at column

    protected $fillable = [
        'user_id',
        'total_study_minutes',
        'total_sessions',
        'total_sessions_completed',
        'total_contents_completed',
        'total_quizzes_completed',
        'total_quizzes_taken',
        'total_quizzes_passed',
        'average_quiz_score',
        'total_simulations_completed',
        'total_content_viewed',
        'average_daily_study_minutes',
        'current_week_minutes',
        'current_month_minutes',
        'current_streak_days',
        'longest_streak_days',
        'last_study_date',
        'level',
        'experience_points',
        'gamification_points',
        'total_achievements_unlocked',
    ];

    protected $casts = [
        'total_study_minutes' => 'integer',
        'total_sessions' => 'integer',
        'total_sessions_completed' => 'integer',
        'total_contents_completed' => 'integer',
        'total_quizzes_completed' => 'integer',
        'total_quizzes_taken' => 'integer',
        'total_quizzes_passed' => 'integer',
        'average_quiz_score' => 'decimal:2',
        'total_simulations_completed' => 'integer',
        'total_content_viewed' => 'integer',
        'average_daily_study_minutes' => 'integer',
        'current_week_minutes' => 'integer',
        'current_month_minutes' => 'integer',
        'current_streak_days' => 'integer',
        'longest_streak_days' => 'integer',
        'last_study_date' => 'date',
        'level' => 'integer',
        'experience_points' => 'integer',
        'gamification_points' => 'integer',
        'total_achievements_unlocked' => 'integer',
    ];

    /**
     * Get the user that owns the stats.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
