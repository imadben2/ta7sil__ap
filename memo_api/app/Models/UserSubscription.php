<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserSubscription extends Model
{
    protected $fillable = [
        'user_id',
        'course_id',
        'package_id',
        'activated_by',
        'code_id',
        'receipt_id',
        'order_id',
        'activated_at',
        'started_at',
        'expires_at',
        'is_active',
        'status',
    ];

    protected $casts = [
        'user_id' => 'integer',
        'course_id' => 'integer',
        'package_id' => 'integer',
        'code_id' => 'integer',
        'receipt_id' => 'integer',
        'order_id' => 'integer',
        'is_active' => 'boolean',
        'activated_at' => 'datetime',
        'started_at' => 'datetime',
        'expires_at' => 'datetime',
    ];

    // Relationships
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function course(): BelongsTo
    {
        return $this->belongsTo(Course::class);
    }

    public function package(): BelongsTo
    {
        return $this->belongsTo(SubscriptionPackage::class);
    }

    public function code(): BelongsTo
    {
        return $this->belongsTo(SubscriptionCode::class, 'code_id');
    }

    public function receipt(): BelongsTo
    {
        return $this->belongsTo(PaymentReceipt::class, 'receipt_id');
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    // Helper methods
    public function isActive(): bool
    {
        if (!$this->is_active) {
            return false;
        }

        if ($this->expires_at && $this->expires_at->isPast()) {
            return false;
        }

        return true;
    }

    public function isExpired(): bool
    {
        if (!$this->expires_at) {
            return false;
        }

        return $this->expires_at->isPast();
    }

    public function getRemainingDays(): ?int
    {
        if (!$this->expires_at) {
            return null;
        }

        if ($this->expires_at->isPast()) {
            return 0;
        }

        return now()->diffInDays($this->expires_at);
    }

    public function activate(): void
    {
        $this->is_active = true;
        $this->status = 'active';
        $this->activated_at = now();

        // If subscription has expired, extend it by 30 days from now
        if (!$this->expires_at || $this->expires_at->isPast()) {
            $this->expires_at = now()->addDays(30);
        }

        $this->save();
    }

    public function suspend(): void
    {
        $this->is_active = false;
        $this->status = 'cancelled';
        $this->save();
    }

    public function expire(): void
    {
        $this->is_active = false;
        $this->save();
    }
}
