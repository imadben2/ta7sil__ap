<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserNotificationSetting extends Model
{
    protected $fillable = [
        'user_id',
        'notifications_enabled',
        'study_reminders',
        'exam_reminders',
        'daily_summary',
        'weekly_summary',
        'motivational_quotes',
        'course_updates',
        'quiet_hours_enabled',
        'quiet_start_time',
        'quiet_end_time',
    ];

    protected $casts = [
        'notifications_enabled' => 'boolean',
        'study_reminders' => 'boolean',
        'exam_reminders' => 'boolean',
        'daily_summary' => 'boolean',
        'weekly_summary' => 'boolean',
        'motivational_quotes' => 'boolean',
        'course_updates' => 'boolean',
        'quiet_hours_enabled' => 'boolean',
        'quiet_start_time' => 'datetime:H:i',
        'quiet_end_time' => 'datetime:H:i',
    ];

    /**
     * Get the user that owns the notification settings.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Check if user should receive a specific type of notification.
     */
    public function shouldReceive(string $type): bool
    {
        if (!$this->notifications_enabled) {
            return false;
        }

        if ($this->isInQuietHours()) {
            return false;
        }

        return match($type) {
            'study_reminder' => $this->study_reminders,
            'exam_alert' => $this->exam_reminders,
            'daily_summary' => $this->daily_summary,
            'weekly_summary' => $this->weekly_summary,
            'achievement' => $this->motivational_quotes,
            'course_update' => $this->course_updates,
            default => true,
        };
    }

    /**
     * Check if current time is within quiet hours.
     */
    public function isInQuietHours(): bool
    {
        if (!$this->quiet_hours_enabled || !$this->quiet_start_time || !$this->quiet_end_time) {
            return false;
        }

        $now = now()->format('H:i');
        $start = $this->quiet_start_time;
        $end = $this->quiet_end_time;

        // Handle overnight quiet hours (e.g., 22:00 - 07:00)
        if ($start > $end) {
            return $now >= $start || $now <= $end;
        }

        // Handle same-day quiet hours (e.g., 13:00 - 15:00)
        return $now >= $start && $now <= $end;
    }
}
