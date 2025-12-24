<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Carbon\Carbon;

class Coupon extends Model
{
    protected $fillable = [
        'code',
        'discount_type',
        'discount_value',
        'min_purchase_amount',
        'max_discount_amount',
        'max_uses',
        'max_uses_per_user',
        'current_uses',
        'valid_from',
        'valid_until',
        'is_active',
        'course_ids',
        'package_ids',
        'user_ids',
        'first_purchase_only',
        'created_by',
    ];

    protected $casts = [
        'discount_value' => 'decimal:2',
        'min_purchase_amount' => 'integer',
        'max_discount_amount' => 'integer',
        'max_uses' => 'integer',
        'max_uses_per_user' => 'integer',
        'current_uses' => 'integer',
        'valid_from' => 'datetime',
        'valid_until' => 'datetime',
        'is_active' => 'boolean',
        'course_ids' => 'array',
        'package_ids' => 'array',
        'user_ids' => 'array',
        'first_purchase_only' => 'boolean',
    ];

    // Relationships
    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function usages(): HasMany
    {
        return $this->hasMany(CouponUsage::class);
    }

    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }

    // Validation methods
    public function isValid(): bool
    {
        if (!$this->is_active) {
            return false;
        }

        // Check validity period
        $now = Carbon::now();
        if ($this->valid_from && $now->lt($this->valid_from)) {
            return false;
        }
        if ($this->valid_until && $now->gt($this->valid_until)) {
            return false;
        }

        // Check usage limit
        if ($this->max_uses !== null && $this->current_uses >= $this->max_uses) {
            return false;
        }

        return true;
    }

    public function canBeUsedByUser(User $user): bool
    {
        if (!$this->isValid()) {
            return false;
        }

        // Check user-specific restriction
        if ($this->user_ids !== null && !in_array($user->id, $this->user_ids)) {
            return false;
        }

        // Check per-user usage limit
        $userUsageCount = $this->usages()->where('user_id', $user->id)->count();
        if ($userUsageCount >= $this->max_uses_per_user) {
            return false;
        }

        // Check first purchase only
        if ($this->first_purchase_only) {
            $hasOrders = Order::where('user_id', $user->id)
                ->where('status', 'completed')
                ->exists();
            if ($hasOrders) {
                return false;
            }
        }

        return true;
    }

    public function isApplicableToCourse(?Course $course): bool
    {
        if ($course === null) {
            return true;
        }

        // If no course restriction, applicable to all
        if ($this->course_ids === null || empty($this->course_ids)) {
            return true;
        }

        return in_array($course->id, $this->course_ids);
    }

    public function isApplicableToPackage(?SubscriptionPackage $package): bool
    {
        if ($package === null) {
            return true;
        }

        // If no package restriction, applicable to all
        if ($this->package_ids === null || empty($this->package_ids)) {
            return true;
        }

        return in_array($package->id, $this->package_ids);
    }

    public function calculateDiscount(int $originalPrice): array
    {
        if ($originalPrice < $this->min_purchase_amount) {
            return [
                'discount_amount' => 0,
                'final_price' => $originalPrice,
                'discount_percentage' => 0,
            ];
        }

        $discountAmount = 0;

        if ($this->discount_type === 'percentage') {
            $discountAmount = (int) round($originalPrice * ($this->discount_value / 100));

            // Apply max discount cap if set
            if ($this->max_discount_amount !== null && $discountAmount > $this->max_discount_amount) {
                $discountAmount = $this->max_discount_amount;
            }
        } else {
            // Fixed discount
            $discountAmount = (int) $this->discount_value;
        }

        // Ensure discount doesn't exceed original price
        if ($discountAmount > $originalPrice) {
            $discountAmount = $originalPrice;
        }

        $finalPrice = $originalPrice - $discountAmount;

        return [
            'discount_amount' => $discountAmount,
            'final_price' => $finalPrice,
            'discount_percentage' => $originalPrice > 0 ? round(($discountAmount / $originalPrice) * 100, 2) : 0,
        ];
    }

    public function incrementUsage(): void
    {
        $this->increment('current_uses');
    }
}
