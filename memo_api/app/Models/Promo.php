<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Builder;
use Carbon\Carbon;

/**
 * Promo Model
 *
 * Represents a promotional slide for the home page slider
 *
 * @property int $id
 * @property string $title
 * @property string|null $subtitle
 * @property string|null $badge
 * @property string|null $action_text
 * @property string|null $icon_name
 * @property string|null $image_url
 * @property array|null $gradient_colors
 * @property string $action_type
 * @property string|null $action_value
 * @property int $click_count
 * @property int $display_order
 * @property bool $is_active
 * @property string $promo_type
 * @property \Carbon\Carbon|null $target_date
 * @property string|null $countdown_label
 * @property \Carbon\Carbon|null $starts_at
 * @property \Carbon\Carbon|null $ends_at
 * @property \Carbon\Carbon $created_at
 * @property \Carbon\Carbon $updated_at
 */
class Promo extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'title',
        'subtitle',
        'badge',
        'action_text',
        'icon_name',
        'image_url',
        'gradient_colors',
        'action_type',
        'action_value',
        'click_count',
        'display_order',
        'is_active',
        'promo_type',
        'target_date',
        'countdown_label',
        'starts_at',
        'ends_at',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'gradient_colors' => 'array',
        'click_count' => 'integer',
        'display_order' => 'integer',
        'is_active' => 'boolean',
        'target_date' => 'datetime',
        'starts_at' => 'datetime',
        'ends_at' => 'datetime',
    ];

    /**
     * Valid promo types
     */
    public const PROMO_TYPES = ['default', 'countdown'];

    /**
     * Valid action types
     */
    public const ACTION_TYPES = ['route', 'url', 'none'];

    /**
     * Scope a query to only include active promos.
     */
    public function scopeActive(Builder $query): Builder
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope a query to only include promos within their date range.
     */
    public function scopeInDateRange(Builder $query): Builder
    {
        $now = Carbon::now();

        return $query->where(function ($q) use ($now) {
            $q->whereNull('starts_at')
              ->orWhere('starts_at', '<=', $now);
        })->where(function ($q) use ($now) {
            $q->whereNull('ends_at')
              ->orWhere('ends_at', '>=', $now);
        });
    }

    /**
     * Scope a query to only include currently visible promos.
     * Combines active status and date range checks.
     */
    public function scopeVisible(Builder $query): Builder
    {
        return $query->active()->inDateRange();
    }

    /**
     * Scope a query to order by display order.
     */
    public function scopeOrdered(Builder $query): Builder
    {
        return $query->orderBy('display_order', 'asc');
    }

    /**
     * Increment the click count.
     *
     * @return int The new click count
     */
    public function incrementClickCount(): int
    {
        $this->increment('click_count');
        return $this->click_count;
    }

    /**
     * Check if promo is currently active (considering date range)
     *
     * @return bool
     */
    public function isCurrentlyActive(): bool
    {
        if (!$this->is_active) {
            return false;
        }

        $now = Carbon::now();

        if ($this->starts_at && $now->lt($this->starts_at)) {
            return false;
        }

        if ($this->ends_at && $now->gt($this->ends_at)) {
            return false;
        }

        return true;
    }

    /**
     * Get formatted click count (e.g., "1.2K")
     *
     * @return string
     */
    public function getFormattedClickCountAttribute(): string
    {
        return $this->formatNumber($this->click_count);
    }

    /**
     * Check if promo has an action
     *
     * @return bool
     */
    public function getHasActionAttribute(): bool
    {
        return $this->action_type !== 'none' && !empty($this->action_value);
    }

    /**
     * Check if promo has a visual (icon or image)
     *
     * @return bool
     */
    public function getHasVisualAttribute(): bool
    {
        return !empty($this->icon_name) || !empty($this->image_url);
    }

    /**
     * Get default gradient colors if none set
     *
     * @return array
     */
    public function getGradientColorsWithDefaultAttribute(): array
    {
        if (!empty($this->gradient_colors)) {
            return $this->gradient_colors;
        }

        // Default blue gradient
        return ['#2196F3', '#1565C0'];
    }

    /**
     * Format number to K/M notation
     *
     * @param int $count
     * @return string
     */
    private function formatNumber(int $count): string
    {
        if ($count >= 1000000) {
            return round($count / 1000000, 1) . 'M';
        }

        if ($count >= 1000) {
            return round($count / 1000, 1) . 'K';
        }

        return (string) $count;
    }

    /**
     * Convert promo to API response array
     *
     * @return array
     */
    public function toApiResponse(): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'subtitle' => $this->subtitle,
            'badge' => $this->badge,
            'action_text' => $this->action_text,
            'icon_name' => $this->icon_name,
            'image_url' => $this->image_url,
            'gradient_colors' => $this->gradient_colors_with_default,
            'action_type' => $this->action_type,
            'action_value' => $this->action_value,
            'display_order' => $this->display_order,
            'is_active' => $this->is_active,
            'promo_type' => $this->promo_type ?? 'default',
            'target_date' => $this->target_date?->toIso8601String(),
            'countdown_label' => $this->countdown_label,
        ];
    }

    /**
     * Check if promo is a countdown type
     *
     * @return bool
     */
    public function isCountdown(): bool
    {
        return $this->promo_type === 'countdown' && $this->target_date !== null;
    }

    /**
     * Get days remaining for countdown
     *
     * @return int
     */
    public function getDaysRemainingAttribute(): int
    {
        if (!$this->target_date) {
            return 0;
        }

        $now = Carbon::now();
        $diff = $now->diffInDays($this->target_date, false);

        return max(0, (int) $diff);
    }

    /**
     * Scope a query to order countdown promos first
     */
    public function scopeCountdownFirst(Builder $query): Builder
    {
        return $query->orderByRaw("CASE WHEN promo_type = 'countdown' THEN 0 ELSE 1 END")
                     ->orderBy('display_order', 'asc');
    }
}
