<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserActivityLog extends Model
{
    const UPDATED_AT = null; // Only created_at

    protected $fillable = [
        'user_id',
        'activity_type',
        'activity_description',
        'metadata',
        'ip_address',
        'user_agent',
    ];

    protected $casts = [
        'metadata' => 'array',
        'created_at' => 'datetime',
    ];

    /**
     * Activity types constants.
     */
    const TYPE_LOGIN = 'login';
    const TYPE_LOGOUT = 'logout';
    const TYPE_STUDY_SESSION_START = 'study_session_start';
    const TYPE_STUDY_SESSION_END = 'study_session_end';
    const TYPE_QUIZ_ATTEMPT = 'quiz_attempt';
    const TYPE_QUIZ_COMPLETE = 'quiz_complete';
    const TYPE_CONTENT_VIEW = 'content_view';
    const TYPE_CONTENT_DOWNLOAD = 'content_download';
    const TYPE_PROFILE_UPDATE = 'profile_update';
    const TYPE_PASSWORD_CHANGE = 'password_change';
    const TYPE_DEVICE_TRANSFER = 'device_transfer';
    const TYPE_SUBSCRIPTION_PURCHASE = 'subscription_purchase';
    const TYPE_ACHIEVEMENT_UNLOCKED = 'achievement_unlocked';

    /**
     * Get the user.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Log an activity for a user.
     */
    public static function log(
        int $userId,
        string $activityType,
        ?string $description = null,
        ?array $metadata = null
    ): self {
        return self::create([
            'user_id' => $userId,
            'activity_type' => $activityType,
            'activity_description' => $description,
            'metadata' => $metadata,
            'ip_address' => request()->ip(),
            'user_agent' => request()->userAgent(),
        ]);
    }

    /**
     * Scope to filter by activity type.
     */
    public function scopeOfType($query, string $type)
    {
        return $query->where('activity_type', $type);
    }

    /**
     * Scope to get recent activities.
     */
    public function scopeRecent($query, int $days = 30)
    {
        return $query->where('created_at', '>=', now()->subDays($days));
    }

    /**
     * Scope to order by most recent first.
     */
    public function scopeLatest($query)
    {
        return $query->orderBy('created_at', 'desc');
    }
}
