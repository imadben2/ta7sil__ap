<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Facades\Storage;

class SubscriptionPackage extends Model
{
    protected $fillable = [
        'name_ar',
        'description_ar',
        'image_url',
        'badge_text',
        'background_color',
        'price_dzd',
        'duration_days',
        'is_active',
        'is_featured',
        'sort_order',
    ];

    protected $casts = [
        'price_dzd' => 'integer',
        'duration_days' => 'integer',
        'is_active' => 'boolean',
        'is_featured' => 'boolean',
        'sort_order' => 'integer',
    ];

    protected $appends = ['image_full_url'];

    /**
     * Get full URL for the package image
     */
    public function getImageFullUrlAttribute(): ?string
    {
        if (!$this->image_url) {
            return null;
        }
        return asset('storage/' . $this->image_url);
    }

    // Relationships
    public function courses(): BelongsToMany
    {
        return $this->belongsToMany(Course::class, 'package_courses', 'package_id', 'course_id');
    }

    public function subscriptionCodes(): HasMany
    {
        return $this->hasMany(SubscriptionCode::class, 'package_id');
    }

    public function subscriptions(): HasMany
    {
        return $this->hasMany(UserSubscription::class, 'package_id');
    }

    public function paymentReceipts(): HasMany
    {
        return $this->hasMany(PaymentReceipt::class, 'package_id');
    }

    // Helper methods
    public function getCourseCount(): int
    {
        return $this->courses()->count();
    }

    public function getFormattedDuration(): string
    {
        if ($this->duration_days < 30) {
            return $this->duration_days . ' يوم';
        }

        $months = floor($this->duration_days / 30);
        $remainingDays = $this->duration_days % 30;

        if ($remainingDays === 0) {
            return $months . ' شهر';
        }

        return $months . ' شهر و ' . $remainingDays . ' يوم';
    }
}
