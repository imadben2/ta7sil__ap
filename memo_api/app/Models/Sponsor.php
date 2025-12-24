<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Builder;

/**
 * Sponsor Model
 *
 * Represents a sponsor/professor for "هاد التطبيق برعاية" section
 *
 * @property int $id
 * @property string $name_ar
 * @property string $photo_url
 * @property string $external_link
 * @property string|null $youtube_link
 * @property string|null $facebook_link
 * @property string|null $instagram_link
 * @property string|null $telegram_link
 * @property string|null $title
 * @property string|null $specialty
 * @property int $click_count
 * @property int $youtube_clicks
 * @property int $facebook_clicks
 * @property int $instagram_clicks
 * @property int $telegram_clicks
 * @property bool $is_active
 * @property int $display_order
 * @property \Carbon\Carbon $created_at
 * @property \Carbon\Carbon $updated_at
 */
class Sponsor extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name_ar',
        'photo_url',
        'external_link',
        'youtube_link',
        'facebook_link',
        'instagram_link',
        'telegram_link',
        'title',
        'specialty',
        'click_count',
        'youtube_clicks',
        'facebook_clicks',
        'instagram_clicks',
        'telegram_clicks',
        'is_active',
        'display_order',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'click_count' => 'integer',
        'youtube_clicks' => 'integer',
        'facebook_clicks' => 'integer',
        'instagram_clicks' => 'integer',
        'telegram_clicks' => 'integer',
        'is_active' => 'boolean',
        'display_order' => 'integer',
    ];

    /**
     * Scope a query to only include active sponsors.
     */
    public function scopeActive(Builder $query): Builder
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope a query to order by display order.
     */
    public function scopeOrdered(Builder $query): Builder
    {
        return $query->orderBy('display_order', 'asc');
    }

    /**
     * Increment the click count for a specific platform.
     *
     * @param string $platform youtube, facebook, instagram, telegram, or general
     * @return int The new click count for that platform
     */
    public function incrementClickCount(string $platform = 'general'): int
    {
        // Always increment total click count
        $this->increment('click_count');

        // Increment platform-specific click count
        $platformColumn = match ($platform) {
            'youtube' => 'youtube_clicks',
            'facebook' => 'facebook_clicks',
            'instagram' => 'instagram_clicks',
            'telegram' => 'telegram_clicks',
            default => null,
        };

        if ($platformColumn) {
            $this->increment($platformColumn);
            return $this->$platformColumn;
        }

        return $this->click_count;
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
     * Get total clicks across all platforms
     *
     * @return int
     */
    public function getTotalPlatformClicksAttribute(): int
    {
        return $this->youtube_clicks + $this->facebook_clicks +
               $this->instagram_clicks + $this->telegram_clicks;
    }

    /**
     * Check if sponsor has any social links
     *
     * @return bool
     */
    public function getHasSocialLinksAttribute(): bool
    {
        return $this->youtube_link || $this->facebook_link ||
               $this->instagram_link || $this->telegram_link;
    }

    /**
     * Get available social links as array
     *
     * @return array
     */
    public function getAvailableLinksAttribute(): array
    {
        $links = [];

        if ($this->youtube_link) {
            $links['youtube'] = [
                'url' => $this->youtube_link,
                'clicks' => $this->youtube_clicks,
            ];
        }
        if ($this->facebook_link) {
            $links['facebook'] = [
                'url' => $this->facebook_link,
                'clicks' => $this->facebook_clicks,
            ];
        }
        if ($this->instagram_link) {
            $links['instagram'] = [
                'url' => $this->instagram_link,
                'clicks' => $this->instagram_clicks,
            ];
        }
        if ($this->telegram_link) {
            $links['telegram'] = [
                'url' => $this->telegram_link,
                'clicks' => $this->telegram_clicks,
            ];
        }

        return $links;
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
}
