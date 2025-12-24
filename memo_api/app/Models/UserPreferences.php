<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserPreferences extends Model
{
    protected $fillable = [
        'user_id',
        // Notifications
        'notifications_enabled',
        'study_session_reminders',
        'exam_reminders',
        'daily_summary',
        'weekly_summary',
        // Display
        'theme',
        'font_size',
        // Pomodoro
        'pomodoro_duration',
        'short_break_duration',
        'long_break_duration',
        'sessions_before_long_break',
        // Ramadan mode
        'ramadan_mode_enabled',
        // Other
        'motivational_quotes_enabled',
        'sound_effects_enabled',
    ];

    protected $casts = [
        'notifications_enabled' => 'boolean',
        'study_session_reminders' => 'boolean',
        'exam_reminders' => 'boolean',
        'daily_summary' => 'boolean',
        'weekly_summary' => 'boolean',
        'ramadan_mode_enabled' => 'boolean',
        'motivational_quotes_enabled' => 'boolean',
        'sound_effects_enabled' => 'boolean',
        'pomodoro_duration' => 'integer',
        'short_break_duration' => 'integer',
        'long_break_duration' => 'integer',
        'sessions_before_long_break' => 'integer',
    ];

    protected $attributes = [
        'notifications_enabled' => true,
        'study_session_reminders' => true,
        'exam_reminders' => true,
        'daily_summary' => true,
        'weekly_summary' => true,
        'theme' => 'light',
        'font_size' => 'medium',
        'pomodoro_duration' => 25,
        'short_break_duration' => 5,
        'long_break_duration' => 15,
        'sessions_before_long_break' => 4,
        'ramadan_mode_enabled' => false,
        'motivational_quotes_enabled' => true,
        'sound_effects_enabled' => true,
    ];

    /**
     * Get the user that owns these preferences.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Validate theme value.
     */
    public static function validateTheme(?string $theme): bool
    {
        return in_array($theme, ['light', 'dark', 'auto']);
    }

    /**
     * Validate font size value.
     */
    public static function validateFontSize(?string $fontSize): bool
    {
        return in_array($fontSize, ['small', 'medium', 'large']);
    }

    /**
     * Validate pomodoro duration.
     */
    public static function validatePomodoroDuration(?int $duration): bool
    {
        return $duration >= 15 && $duration <= 60;
    }

    /**
     * Validate break duration.
     */
    public static function validateBreakDuration(?int $duration): bool
    {
        return $duration >= 5 && $duration <= 20;
    }
}
