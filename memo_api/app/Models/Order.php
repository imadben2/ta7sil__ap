<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Carbon\Carbon;

class Order extends Model
{
    protected $fillable = [
        'order_number',
        'user_id',
        'course_id',
        'package_id',
        'subtotal_dzd',
        'discount_dzd',
        'total_dzd',
        'coupon_id',
        'payment_method',
        'payment_reference',
        'payment_url',
        'status',
        'expires_at',
        'paid_at',
        'cancelled_at',
        'refunded_at',
        'ip_address',
        'user_agent',
        'metadata',
        'notes',
    ];

    protected $casts = [
        'subtotal_dzd' => 'integer',
        'discount_dzd' => 'integer',
        'total_dzd' => 'integer',
        'expires_at' => 'datetime',
        'paid_at' => 'datetime',
        'cancelled_at' => 'datetime',
        'refunded_at' => 'datetime',
        'metadata' => 'array',
    ];

    // Status constants
    const STATUS_PENDING = 'pending';
    const STATUS_PROCESSING = 'processing';
    const STATUS_COMPLETED = 'completed';
    const STATUS_FAILED = 'failed';
    const STATUS_CANCELLED = 'cancelled';
    const STATUS_EXPIRED = 'expired';
    const STATUS_REFUNDED = 'refunded';

    // Payment method constants
    const PAYMENT_BARIDIMOB = 'baridimob';
    const PAYMENT_CCP = 'ccp';
    const PAYMENT_CREDIT_CARD = 'credit_card';
    const PAYMENT_CODE = 'code';
    const PAYMENT_RECEIPT = 'receipt';

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
        return $this->belongsTo(SubscriptionPackage::class, 'package_id');
    }

    public function coupon(): BelongsTo
    {
        return $this->belongsTo(Coupon::class);
    }

    public function subscription(): HasOne
    {
        return $this->hasOne(UserSubscription::class);
    }

    // Status helpers
    public function isPending(): bool
    {
        return $this->status === self::STATUS_PENDING;
    }

    public function isProcessing(): bool
    {
        return $this->status === self::STATUS_PROCESSING;
    }

    public function isCompleted(): bool
    {
        return $this->status === self::STATUS_COMPLETED;
    }

    public function isFailed(): bool
    {
        return $this->status === self::STATUS_FAILED;
    }

    public function isCancelled(): bool
    {
        return $this->status === self::STATUS_CANCELLED;
    }

    public function isExpired(): bool
    {
        return $this->status === self::STATUS_EXPIRED;
    }

    public function isRefunded(): bool
    {
        return $this->status === self::STATUS_REFUNDED;
    }

    public function canBeCancelled(): bool
    {
        return in_array($this->status, [self::STATUS_PENDING, self::STATUS_PROCESSING]);
    }

    public function canBeRefunded(): bool
    {
        return $this->status === self::STATUS_COMPLETED && $this->paid_at !== null;
    }

    // Status transitions
    public function markAsProcessing(): void
    {
        $this->status = self::STATUS_PROCESSING;
        $this->save();
    }

    public function markAsCompleted(?string $paymentReference = null): void
    {
        $this->status = self::STATUS_COMPLETED;
        $this->paid_at = Carbon::now();
        if ($paymentReference) {
            $this->payment_reference = $paymentReference;
        }
        $this->save();
    }

    public function markAsFailed(?string $reason = null): void
    {
        $this->status = self::STATUS_FAILED;
        if ($reason) {
            $this->notes = $reason;
        }
        $this->save();
    }

    public function markAsCancelled(?string $reason = null): void
    {
        $this->status = self::STATUS_CANCELLED;
        $this->cancelled_at = Carbon::now();
        if ($reason) {
            $this->notes = $reason;
        }
        $this->save();
    }

    public function markAsExpired(): void
    {
        $this->status = self::STATUS_EXPIRED;
        $this->save();
    }

    public function markAsRefunded(?string $reason = null): void
    {
        $this->status = self::STATUS_REFUNDED;
        $this->refunded_at = Carbon::now();
        if ($reason) {
            $this->notes = $reason;
        }
        $this->save();
    }

    // Utility methods
    public function getItemTitle(): string
    {
        if ($this->course) {
            return $this->course->title_ar;
        }
        if ($this->package) {
            return $this->package->name_ar;
        }
        return 'عنصر غير معروف';
    }

    public function hasExpired(): bool
    {
        return $this->expires_at !== null && Carbon::now()->gt($this->expires_at);
    }

    // Generate unique order number
    public static function generateOrderNumber(): string
    {
        do {
            $number = 'ORD-' . strtoupper(substr(md5(uniqid(mt_rand(), true)), 0, 8));
        } while (self::where('order_number', $number)->exists());

        return $number;
    }
}
