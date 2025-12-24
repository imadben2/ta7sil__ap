<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;

class SubscriptionCode extends Model
{
    protected $fillable = [
        'code',
        'code_type',
        'course_id',
        'package_id',
        'list_id',
        'max_uses',
        'current_uses',
        'is_active',
        'expires_at',
        'created_by',
    ];

    protected $casts = [
        'course_id' => 'integer',
        'package_id' => 'integer',
        'max_uses' => 'integer',
        'current_uses' => 'integer',
        'is_active' => 'boolean',
        'expires_at' => 'datetime',
        'created_by' => 'integer',
    ];

    // Relationships
    public function course(): BelongsTo
    {
        return $this->belongsTo(Course::class);
    }

    public function package(): BelongsTo
    {
        return $this->belongsTo(SubscriptionPackage::class);
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function list(): BelongsTo
    {
        return $this->belongsTo(SubscriptionCodeList::class, 'list_id');
    }

    public function userSubscriptions()
    {
        return $this->hasMany(UserSubscription::class, 'code_id');
    }

    // Helper methods
    public static function generateUniqueCode(int $length = 6): string
    {
        do {
            // Generate 6-digit numeric code (000000 to 999999)
            $code = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);
        } while (self::where('code', $code)->exists());

        return $code;
    }

    public function isValid(): bool
    {
        if (!$this->is_active) {
            return false;
        }

        if ($this->expires_at && $this->expires_at->isPast()) {
            return false;
        }

        if ($this->current_uses >= $this->max_uses) {
            return false;
        }

        return true;
    }

    public function canBeUsed(): bool
    {
        return $this->isValid();
    }

    public function incrementUses(): void
    {
        $this->increment('current_uses');

        if ($this->current_uses >= $this->max_uses) {
            $this->is_active = false;
            $this->save();
        }
    }

    public function getRemainingUses(): int
    {
        return max(0, $this->max_uses - $this->current_uses);
    }
}
