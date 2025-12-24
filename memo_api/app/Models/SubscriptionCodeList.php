<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class SubscriptionCodeList extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'code_type',
        'course_id',
        'package_id',
        'total_codes',
        'max_uses_per_code',
        'expires_at',
        'created_by',
    ];

    protected $casts = [
        'course_id' => 'integer',
        'package_id' => 'integer',
        'total_codes' => 'integer',
        'max_uses_per_code' => 'integer',
        'expires_at' => 'datetime',
        'created_by' => 'integer',
    ];

    /**
     * Get all codes belonging to this list
     */
    public function codes(): HasMany
    {
        return $this->hasMany(SubscriptionCode::class, 'list_id');
    }

    /**
     * Get the course associated with this list (if single_course type)
     */
    public function course(): BelongsTo
    {
        return $this->belongsTo(Course::class);
    }

    /**
     * Get the package associated with this list (if package type)
     */
    public function package(): BelongsTo
    {
        return $this->belongsTo(SubscriptionPackage::class);
    }

    /**
     * Get the user who created this list
     */
    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    /**
     * Get count of codes that have been used at least once
     */
    public function getUsedCodesCountAttribute(): int
    {
        return $this->codes()->where('current_uses', '>', 0)->count();
    }

    /**
     * Get count of codes that are currently valid (active, not expired, has remaining uses)
     */
    public function getValidCodesCountAttribute(): int
    {
        return $this->codes()
            ->where('is_active', true)
            ->where(function ($q) {
                $q->whereNull('expires_at')
                  ->orWhere('expires_at', '>', now());
            })
            ->whereRaw('current_uses < max_uses')
            ->count();
    }

    /**
     * Get count of codes that have been fully used (current_uses >= max_uses)
     */
    public function getFullyUsedCodesCountAttribute(): int
    {
        return $this->codes()->whereRaw('current_uses >= max_uses')->count();
    }

    /**
     * Get count of codes that have expired
     */
    public function getExpiredCodesCountAttribute(): int
    {
        return $this->codes()
            ->whereNotNull('expires_at')
            ->where('expires_at', '<=', now())
            ->count();
    }
}
