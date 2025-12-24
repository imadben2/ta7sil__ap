<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class FcmToken extends Model
{
    protected $fillable = [
        'user_id',
        'token',
        'device_uuid',
        'device_platform',
        'is_active',
        'last_used_at',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'last_used_at' => 'datetime',
    ];

    /**
     * Get the user.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Scope a query to only include active tokens.
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope for specific platform.
     */
    public function scopeForPlatform($query, string $platform)
    {
        return $query->where('device_platform', $platform);
    }

    /**
     * Scope for specific device.
     */
    public function scopeForDevice($query, string $deviceUuid)
    {
        return $query->where('device_uuid', $deviceUuid);
    }

    /**
     * Mark token as used.
     */
    public function markAsUsed(): void
    {
        $this->update(['last_used_at' => now()]);
    }

    /**
     * Deactivate token.
     */
    public function deactivate(): void
    {
        $this->update(['is_active' => false]);
    }

    /**
     * Activate token.
     */
    public function activate(): void
    {
        $this->update(['is_active' => true]);
    }
}
