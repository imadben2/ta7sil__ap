<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Carbon\Carbon;

class DeviceSession extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'user_id',
        'device_name',
        'device_type',
        'device_os',
        'os_version',
        'app_version',
        'token_id',
        'ip_address',
        'user_agent',
        'location',
        'latitude',
        'longitude',
        'is_current',
        'last_active_at',
        'expires_at',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'is_current' => 'boolean',
        'last_active_at' => 'datetime',
        'expires_at' => 'datetime',
        'latitude' => 'decimal:7',
        'longitude' => 'decimal:7',
    ];

    /**
     * Get the user that owns the session.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Check if session is active.
     *
     * @return bool
     */
    public function isActive(): bool
    {
        if (!$this->expires_at) {
            return true;
        }

        return $this->expires_at->isFuture();
    }

    /**
     * Check if session was recently active (within last 5 minutes).
     *
     * @return bool
     */
    public function isRecentlyActive(): bool
    {
        if (!$this->last_active_at) {
            return false;
        }

        return $this->last_active_at->diffInMinutes(now()) <= 5;
    }

    /**
     * Get human-readable last active time.
     *
     * @return string
     */
    public function getLastActiveForHumans(): string
    {
        if (!$this->last_active_at) {
            return 'Never';
        }

        if ($this->isRecentlyActive()) {
            return 'Active now';
        }

        return $this->last_active_at->diffForHumans();
    }

    /**
     * Get device icon based on type and OS.
     *
     * @return string
     */
    public function getDeviceIcon(): string
    {
        $icons = [
            'mobile' => [
                'iOS' => 'phone_iphone',
                'Android' => 'phone_android',
                'default' => 'smartphone',
            ],
            'tablet' => [
                'iOS' => 'tablet_mac',
                'Android' => 'tablet_android',
                'default' => 'tablet',
            ],
            'web' => [
                'default' => 'computer',
            ],
        ];

        $type = strtolower($this->device_type);
        $os = $this->device_os;

        if (isset($icons[$type][$os])) {
            return $icons[$type][$os];
        }

        return $icons[$type]['default'] ?? 'devices';
    }

    /**
     * Scope a query to only include active sessions.
     */
    public function scopeActive($query)
    {
        return $query->where(function ($q) {
            $q->whereNull('expires_at')
                ->orWhere('expires_at', '>', now());
        });
    }

    /**
     * Scope a query to only include expired sessions.
     */
    public function scopeExpired($query)
    {
        return $query->whereNotNull('expires_at')
            ->where('expires_at', '<=', now());
    }

    /**
     * Scope a query to order by last active.
     */
    public function scopeRecentlyActive($query)
    {
        return $query->orderBy('last_active_at', 'desc');
    }

    /**
     * Mark session as current device.
     */
    public function markAsCurrent(): void
    {
        // Unmark all other sessions for this user
        static::where('user_id', $this->user_id)
            ->where('id', '!=', $this->id)
            ->update(['is_current' => false]);

        $this->update(['is_current' => true]);
    }

    /**
     * Update last active timestamp.
     */
    public function updateLastActive(): void
    {
        $this->update(['last_active_at' => now()]);
    }
}
