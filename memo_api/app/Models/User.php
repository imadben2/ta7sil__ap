<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Facades\Schema;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasFactory, Notifiable, HasApiTokens;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'phone',
        'role',
        'profile_image',
        'photo_url',
        'phone_number',
        'bio',
        'date_of_birth',
        'gender',
        'city',
        'country',
        'timezone',
        'latitude',
        'longitude',
        'device_uuid',
        'device_name',
        'device_model',
        'device_os',
        'last_login_at',
        'last_activity_at',
        'login_count',
        'is_active',
        'is_banned',
        'banned_reason',
        'banned_at',
        'total_points',
        'current_level',
        'points_to_next_level',
        // Google Sign-In fields
        'google_id',
        'is_social_account',
        'google_linked_at',
        'email_verified_at',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'date_of_birth' => 'date',
            'last_login_at' => 'datetime',
            'last_activity_at' => 'datetime',
            'is_active' => 'boolean',
            'is_banned' => 'boolean',
            'banned_at' => 'datetime',
            'latitude' => 'decimal:7',
            'longitude' => 'decimal:7',
        ];
    }

    /**
     * Get the user's profile.
     */
    public function userProfile(): HasOne
    {
        return $this->hasOne(UserProfile::class);
    }

    /**
     * Get the user's academic profile.
     */
    public function academicProfile(): HasOne
    {
        return $this->hasOne(UserAcademicProfile::class);
    }

    /**
     * Get the subjects selected by the user.
     */
    public function subjects(): BelongsToMany
    {
        return $this->belongsToMany(Subject::class, 'user_subjects')
            ->withTimestamps();
    }

    /**
     * Get the user's content progress records.
     */
    public function contentProgress(): HasMany
    {
        return $this->hasMany(UserContentProgress::class);
    }

    /**
     * Get the user's content bookmarks.
     */
    public function contentBookmarks(): HasMany
    {
        return $this->hasMany(ContentBookmark::class);
    }

    /**
     * Get the user's study sessions.
     */
    public function studySessions(): HasMany
    {
        return $this->hasMany(StudySession::class);
    }

    /**
     * Get the user's planner setting.
     */
    public function plannerSetting(): HasOne
    {
        return $this->hasOne(PlannerSetting::class);
    }

    /**
     * Get the user's study schedules.
     */
    public function studySchedules(): HasMany
    {
        return $this->hasMany(StudySchedule::class);
    }

    /**
     * Get the user's subject priorities.
     */
    public function subjectPriorities(): HasMany
    {
        return $this->hasMany(SubjectPriority::class);
    }

    /**
     * Get the user's quiz attempts.
     */
    public function quizAttempts(): HasMany
    {
        return $this->hasMany(QuizAttempt::class);
    }

    /**
     * Get the user's quiz performance records.
     */
    public function quizPerformances(): HasMany
    {
        return $this->hasMany(UserQuizPerformance::class);
    }

    /**
     * Get the user's exam schedules.
     */
    public function examSchedules(): HasMany
    {
        return $this->hasMany(ExamSchedule::class);
    }

    /**
     * Get the user's prayer times.
     */
    public function prayerTimes(): HasMany
    {
        return $this->hasMany(PrayerTime::class);
    }

    /**
     * Get the user's achievements.
     */
    public function achievements(): BelongsToMany
    {
        return $this->belongsToMany(Achievement::class, 'user_achievements')
            ->withPivot(['unlocked_at', 'progress'])
            ->withTimestamps();
    }

    /**
     * Get the user's statistics.
     */
    public function stats(): HasOne
    {
        return $this->hasOne(UserStats::class);
    }

    /**
     * Get the user's notifications.
     */
    public function notifications(): HasMany
    {
        return $this->hasMany(Notification::class);
    }

    /**
     * Get the user's notification settings.
     */
    public function notificationSettings(): HasOne
    {
        return $this->hasOne(UserNotificationSetting::class);
    }

    /**
     * Get the user's FCM tokens.
     */
    public function fcmTokens(): HasMany
    {
        return $this->hasMany(FcmToken::class);
    }

    /**
     * Get device transfer requests initiated by this user.
     */
    public function deviceTransferRequests(): HasMany
    {
        return $this->hasMany(DeviceTransferRequest::class);
    }

    /**
     * Get the user's preferences.
     */
    public function preferences(): HasOne
    {
        return $this->hasOne(UserPreferences::class);
    }

    /**
     * Get the user's activity logs.
     */
    public function activityLogs(): HasMany
    {
        return $this->hasMany(UserActivityLog::class);
    }

    /**
     * Get the user's subject settings.
     */
    public function userSubjects(): HasMany
    {
        return $this->hasMany(UserSubject::class);
    }

    /**
     * Get the user's settings.
     */
    public function settings(): HasOne
    {
        return $this->hasOne(UserSettings::class);
    }

    /**
     * Get the user's device sessions.
     */
    public function deviceSessions(): HasMany
    {
        return $this->hasMany(DeviceSession::class);
    }

    /**
     * Get the user's course subscriptions.
     */
    public function subscriptions(): HasMany
    {
        return $this->hasMany(UserSubscription::class);
    }

    /**
     * Get the user's orders.
     */
    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }

    /**
     * Get the user's certificates.
     */
    public function certificates(): HasMany
    {
        return $this->hasMany(Certificate::class);
    }

    /**
     * Get the user's coupon usages.
     */
    public function couponUsages(): HasMany
    {
        return $this->hasMany(CouponUsage::class);
    }

    /**
     * Get active device sessions.
     */
    public function activeDeviceSessions(): HasMany
    {
        return $this->deviceSessions()
            ->where(function ($query) {
                $query->whereNull('expires_at')
                    ->orWhere('expires_at', '>', now());
            });
    }

    /**
     * Get the current device session.
     */
    public function currentDeviceSession(): HasOne
    {
        return $this->hasOne(DeviceSession::class)->where('is_current', true);
    }

    /**
     * Check if the user's device matches the provided UUID.
     */
    public function isDeviceValid(string $deviceUuid): bool
    {
        return $this->device_uuid === $deviceUuid;
    }

    /**
     * Bind a device to the user account.
     */
    public function bindDevice(string $uuid, string $name, string $model, string $os): void
    {
        $this->update([
            'device_uuid' => $uuid,
            'device_name' => $name,
            'device_model' => $model,
            'device_os' => $os,
        ]);
    }

    /**
     * Check if the user has a device bound.
     */
    public function hasDeviceBound(): bool
    {
        return !is_null($this->device_uuid);
    }

    /**
     * Increment login counter and update last login time.
     */
    public function recordLogin(): void
    {
        // Only increment if columns exist
        if (Schema::hasColumn('users', 'login_count')) {
            $this->increment('login_count');
        }

        if (Schema::hasColumn('users', 'last_login_at')) {
            $this->update(['last_login_at' => now()]);
        }
    }

    /**
     * Scope a query to only include active users.
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true)->where('is_banned', false);
    }

    /**
     * Scope a query to only include banned users.
     */
    public function scopeBanned($query)
    {
        return $query->where('is_banned', true);
    }

    /**
     * Scope a query to filter by role.
     */
    public function scopeRole($query, string $role)
    {
        return $query->where('role', $role);
    }

    /**
     * Get the user's full name in Arabic.
     */
    public function getFullNameArAttribute(): string
    {
        return $this->name;
    }

    /**
     * Get the user's full name in English.
     */
    public function getFullNameEnAttribute(): string
    {
        return $this->name;
    }

    /**
     * Check if user is admin.
     */
    public function getIsAdminAttribute(): bool
    {
        // Check if is_admin column exists (for backward compatibility)
        if (Schema::hasColumn('users', 'is_admin')) {
            return (bool) $this->attributes['is_admin'] ?? false;
        }

        // Fallback to role-based check
        return $this->role === 'admin';
    }

    /**
     * Get the user's academic year through academic profile.
     * Used by SubjectPlannerContentController for curriculum filtering.
     */
    public function getAcademicYearAttribute()
    {
        return $this->academicProfile?->academicYear;
    }

    /**
     * Get the user's academic stream through academic profile.
     * Used by SubjectPlannerContentController for curriculum filtering.
     */
    public function getAcademicStreamAttribute()
    {
        return $this->academicProfile?->academicStream;
    }

    /**
     * Get the user's academic phase through academic profile.
     * Used by SubjectPlannerContentController for curriculum filtering.
     */
    public function getAcademicPhaseAttribute()
    {
        return $this->academicProfile?->academicPhase;
    }
}
