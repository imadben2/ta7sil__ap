<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PlannerSetting extends Model
{
    protected $fillable = [
        'user_id',
        // Study time window
        'study_start_time',
        'study_end_time',
        'study_days',
        // Sleep schedule
        'sleep_start_time',
        'sleep_end_time',
        // Exercise settings
        'exercise_enabled',
        'exercise_days',
        'exercise_time',
        'exercise_duration_minutes',
        // Energy levels (1-10 scale)
        'morning_energy_level',
        'afternoon_energy_level',
        'evening_energy_level',
        'night_energy_level',
        // Pomodoro settings
        'use_pomodoro',
        'pomodoro_duration',
        'short_break',
        'long_break',
        'pomodoros_before_long_break',
        // Priority weights
        'priority_formula',
        'coefficient_weight',
        'exam_proximity_weight',
        'difficulty_weight',
        'inactivity_weight',
        'performance_gap_weight',
        // Limits
        'max_study_hours_per_day',
        'min_break_between_sessions',
        // Auto features
        'auto_reschedule_missed',
        'smart_content_suggestions',
        'adapt_to_performance_enabled',
        // Prayer settings
        'enable_prayer_times',
        'prayer_duration_minutes',
        'city_for_prayer',
        // Algorithm settings from promt.md
        'buffer_rate',
        'max_coef7_per_day',
        'max_hard_per_day',
        'mock_day_of_week',
        'mock_duration_minutes',
        'language_daily_guarantee',
        'no_consecutive_hard',
        // Coefficient duration map
        'coefficient_durations',
    ];

    protected $casts = [
        'exercise_enabled' => 'boolean',
        'exercise_days' => 'array',
        'study_days' => 'array',
        'use_pomodoro' => 'boolean',
        'priority_formula' => 'array',
        'coefficient_durations' => 'array',
        'auto_reschedule_missed' => 'boolean',
        'smart_content_suggestions' => 'boolean',
        'adapt_to_performance_enabled' => 'boolean',
        'enable_prayer_times' => 'boolean',
        'pomodoro_duration' => 'integer',
        'short_break' => 'integer',
        'long_break' => 'integer',
        'pomodoros_before_long_break' => 'integer',
        'exercise_duration_minutes' => 'integer',
        'prayer_duration_minutes' => 'integer',
        // Energy levels
        'morning_energy_level' => 'integer',
        'afternoon_energy_level' => 'integer',
        'evening_energy_level' => 'integer',
        'night_energy_level' => 'integer',
        // Priority weights
        'coefficient_weight' => 'integer',
        'exam_proximity_weight' => 'integer',
        'difficulty_weight' => 'integer',
        'inactivity_weight' => 'integer',
        'performance_gap_weight' => 'integer',
        // Limits
        'max_study_hours_per_day' => 'integer',
        'min_break_between_sessions' => 'integer',
        // Algorithm settings
        'buffer_rate' => 'float',
        'max_coef7_per_day' => 'integer',
        'max_hard_per_day' => 'integer',
        'mock_duration_minutes' => 'integer',
        'language_daily_guarantee' => 'boolean',
        'no_consecutive_hard' => 'boolean',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get energy level string for a given hour
     */
    public function getEnergyLevelForHour(int $hour): string
    {
        $level = $this->getEnergyLevelValueForHour($hour);

        if ($level >= 7) return 'high';
        if ($level >= 4) return 'medium';
        return 'low';
    }

    /**
     * Get energy level value (1-10) for a given hour
     */
    public function getEnergyLevelValueForHour(int $hour): int
    {
        // Energy level by time period (aligned with PLANNER_ALGORITHM_DOCUMENTATION.html)
        // Morning: 05:00-12:00, Afternoon: 12:00-17:00, Evening: 17:00-22:00, Night: 22:00-05:00
        if ($hour >= 5 && $hour < 12) {
            return $this->morning_energy_level ?? 7;
        } elseif ($hour >= 12 && $hour < 17) {
            return $this->afternoon_energy_level ?? 6;
        } elseif ($hour >= 17 && $hour < 22) {
            return $this->evening_energy_level ?? 8;
        } else {
            // Night: 22:00-04:59
            return $this->night_energy_level ?? 4;
        }
    }

    /**
     * Get session duration for a coefficient (from user settings or default)
     */
    public function getDurationForCoefficient(int $coefficient): int
    {
        $durations = $this->coefficient_durations ?? self::getDefaultCoefficientDurations();
        return $durations[$coefficient] ?? 60;
    }

    /**
     * Get default coefficient durations
     */
    public static function getDefaultCoefficientDurations(): array
    {
        return [
            7 => 90,  // High coefficient → 90 minutes
            6 => 80,  // Medium-high+ → 80 minutes
            5 => 75,  // Medium-high → 75 minutes
            4 => 60,  // Medium → 60 minutes
            3 => 50,  // Medium-low → 50 minutes
            2 => 40,  // Low → 40 minutes
            1 => 30,  // Very low → 30 minutes
        ];
    }

    public static function getDefaultPriorityFormula(): array
    {
        return [
            'coefficient_weight' => 35,
            'exam_proximity_weight' => 25,
            'difficulty_weight' => 15,
            'inactivity_weight' => 10,
            'performance_gap_weight' => 5,
            'historical_performance_gap_weight' => 10, // معدل السنة الماضية
        ];
    }
}
