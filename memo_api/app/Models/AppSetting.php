<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Cache;

/**
 * AppSetting Model
 *
 * Global application settings stored in database
 *
 * @property int $id
 * @property string $key
 * @property string|null $value
 * @property string $type
 * @property string $group
 * @property string|null $description
 * @property \Carbon\Carbon $created_at
 * @property \Carbon\Carbon $updated_at
 */
class AppSetting extends Model
{
    protected $fillable = [
        'key',
        'value',
        'type',
        'group',
        'description',
    ];

    /**
     * Get a setting value by key
     *
     * @param string $key
     * @param mixed $default
     * @return mixed
     */
    public static function getValue(string $key, mixed $default = null): mixed
    {
        $setting = Cache::remember("app_setting_{$key}", 3600, function () use ($key) {
            return static::where('key', $key)->first();
        });

        if (!$setting) {
            return $default;
        }

        return static::castValue($setting->value, $setting->type);
    }

    /**
     * Set a setting value
     *
     * @param string $key
     * @param mixed $value
     * @return void
     */
    public static function setValue(string $key, mixed $value): void
    {
        $setting = static::where('key', $key)->first();

        if ($setting) {
            $setting->update(['value' => (string) $value]);
        } else {
            static::create([
                'key' => $key,
                'value' => (string) $value,
            ]);
        }

        Cache::forget("app_setting_{$key}");
    }

    /**
     * Check if sponsors section is enabled
     *
     * @return bool
     */
    public static function isSponsorsEnabled(): bool
    {
        return (bool) static::getValue('sponsors_section_enabled', true);
    }

    /**
     * Toggle sponsors section
     *
     * @param bool|null $enabled
     * @return bool New state
     */
    public static function toggleSponsors(?bool $enabled = null): bool
    {
        if ($enabled === null) {
            $enabled = !static::isSponsorsEnabled();
        }

        static::setValue('sponsors_section_enabled', $enabled ? '1' : '0');

        return $enabled;
    }

    /**
     * Check if promos section is enabled
     *
     * @return bool
     */
    public static function isPromosEnabled(): bool
    {
        return (bool) static::getValue('promos_section_enabled', true);
    }

    /**
     * Toggle promos section
     *
     * @param bool|null $enabled
     * @return bool New state
     */
    public static function togglePromos(?bool $enabled = null): bool
    {
        if ($enabled === null) {
            $enabled = !static::isPromosEnabled();
        }

        static::setValue('promos_section_enabled', $enabled ? '1' : '0');

        return $enabled;
    }

    /**
     * Get minimum required app version
     *
     * @return string
     */
    public static function getMinAppVersion(): string
    {
        return (string) static::getValue('min_app_version', '1.0');
    }

    /**
     * Get application timezone
     *
     * @return string
     */
    public static function getTimezone(): string
    {
        return (string) static::getValue('timezone', 'Africa/Algiers');
    }

    /**
     * Set application timezone
     *
     * @param string $timezone
     * @return void
     */
    public static function setTimezone(string $timezone): void
    {
        static::setValue('timezone', $timezone);
    }

    // =====================================================
    // Google Sign-In Settings
    // =====================================================

    /**
     * Check if Google Sign-In is enabled
     *
     * @return bool
     */
    public static function isGoogleSignInEnabled(): bool
    {
        return (bool) static::getValue('google_signin_enabled', false);
    }

    /**
     * Toggle Google Sign-In
     *
     * @param bool|null $enabled
     * @return bool New state
     */
    public static function toggleGoogleSignIn(?bool $enabled = null): bool
    {
        if ($enabled === null) {
            $enabled = !static::isGoogleSignInEnabled();
        }

        static::setValue('google_signin_enabled', $enabled ? '1' : '0');

        return $enabled;
    }

    /**
     * Get Google Client ID (Web)
     *
     * @return string|null
     */
    public static function getGoogleClientId(): ?string
    {
        return static::getValue('google_client_id');
    }

    /**
     * Set Google Client ID (Web)
     *
     * @param string|null $clientId
     * @return void
     */
    public static function setGoogleClientId(?string $clientId): void
    {
        static::setValue('google_client_id', $clientId ?? '');
    }

    /**
     * Get Google iOS Client ID
     *
     * @return string|null
     */
    public static function getGoogleIosClientId(): ?string
    {
        return static::getValue('google_ios_client_id');
    }

    /**
     * Set Google iOS Client ID
     *
     * @param string|null $clientId
     * @return void
     */
    public static function setGoogleIosClientId(?string $clientId): void
    {
        static::setValue('google_ios_client_id', $clientId ?? '');
    }

    /**
     * Get Google Android Client ID
     *
     * @return string|null
     */
    public static function getGoogleAndroidClientId(): ?string
    {
        return static::getValue('google_android_client_id');
    }

    /**
     * Set Google Android Client ID
     *
     * @param string|null $clientId
     * @return void
     */
    public static function setGoogleAndroidClientId(?string $clientId): void
    {
        static::setValue('google_android_client_id', $clientId ?? '');
    }

    /**
     * Get all Google Sign-In settings
     *
     * @return array
     */
    public static function getGoogleSettings(): array
    {
        return [
            'enabled' => static::isGoogleSignInEnabled(),
            'client_id' => static::getGoogleClientId(),
            'ios_client_id' => static::getGoogleIosClientId(),
            'android_client_id' => static::getGoogleAndroidClientId(),
        ];
    }

    /**
     * Update all Google Sign-In settings
     *
     * @param array $settings
     * @return void
     */
    public static function updateGoogleSettings(array $settings): void
    {
        if (isset($settings['enabled'])) {
            static::toggleGoogleSignIn((bool) $settings['enabled']);
        }
        if (array_key_exists('client_id', $settings)) {
            static::setGoogleClientId($settings['client_id']);
        }
        if (array_key_exists('ios_client_id', $settings)) {
            static::setGoogleIosClientId($settings['ios_client_id']);
        }
        if (array_key_exists('android_client_id', $settings)) {
            static::setGoogleAndroidClientId($settings['android_client_id']);
        }
    }

    // =====================================================
    // Video Player Settings
    // =====================================================

    /**
     * Check if a video player is enabled
     *
     * @param string $player (chewie, media_kit, simple_youtube, omni, orax)
     * @return bool
     */
    public static function isVideoPlayerEnabled(string $player): bool
    {
        // Default enabled players: chewie and simple_youtube
        $defaultEnabled = in_array($player, ['chewie', 'simple_youtube']);
        return (bool) static::getValue("video_player_{$player}_enabled", $defaultEnabled);
    }

    /**
     * Toggle video player enabled status
     *
     * @param string $player
     * @param bool|null $enabled
     * @return bool New state
     */
    public static function toggleVideoPlayer(string $player, ?bool $enabled = null): bool
    {
        if ($enabled === null) {
            $enabled = !static::isVideoPlayerEnabled($player);
        }

        static::setValue("video_player_{$player}_enabled", $enabled ? '1' : '0');

        return $enabled;
    }

    /**
     * Get default player for uploaded videos
     *
     * @return string
     */
    public static function getDefaultUploadPlayer(): string
    {
        return (string) static::getValue('default_upload_player', 'chewie');
    }

    /**
     * Set default player for uploaded videos
     *
     * @param string $player
     * @return void
     */
    public static function setDefaultUploadPlayer(string $player): void
    {
        static::setValue('default_upload_player', $player);
    }

    /**
     * Get default YouTube player
     *
     * @return string
     */
    public static function getDefaultYoutubePlayer(): string
    {
        return static::getValue('default_youtube_player') ?? 'simple_youtube';
    }

    /**
     * Set default YouTube player
     *
     * @param string $player
     * @return void
     */
    public static function setDefaultYoutubePlayer(string $player): void
    {
        static::setValue('default_youtube_player', $player);
    }

    /**
     * Get all video player settings
     *
     * @return array
     */
    public static function getVideoPlayerSettings(): array
    {
        return [
            'chewie_enabled' => static::isVideoPlayerEnabled('chewie'),
            'media_kit_enabled' => static::isVideoPlayerEnabled('media_kit'),
            'simple_youtube_enabled' => static::isVideoPlayerEnabled('simple_youtube'),
            'omni_enabled' => static::isVideoPlayerEnabled('omni'),
            'orax_enabled' => static::isVideoPlayerEnabled('orax'),
            'default_upload_player' => static::getDefaultUploadPlayer(),
            'default_youtube_player' => static::getDefaultYoutubePlayer(),
            // Support types (youtube, upload, both)
            'chewie_supports' => static::getVideoPlayerSupports('chewie', 'upload'),
            'media_kit_supports' => static::getVideoPlayerSupports('media_kit', 'upload'),
            'simple_youtube_supports' => static::getVideoPlayerSupports('simple_youtube', 'youtube'),
            'omni_supports' => static::getVideoPlayerSupports('omni', 'both'),
            'orax_supports' => static::getVideoPlayerSupports('orax', 'both'),
        ];
    }

    /**
     * Get video player support type
     *
     * @param string $player
     * @param string $default
     * @return string
     */
    public static function getVideoPlayerSupports(string $player, string $default = 'both'): string
    {
        $value = static::getValue("video_player_{$player}_supports");
        return $value ?? $default;
    }

    /**
     * Set video player support type
     *
     * @param string $player
     * @param string $supports (youtube, upload, both)
     * @return void
     */
    public static function setVideoPlayerSupports(string $player, string $supports): void
    {
        static::setValue("video_player_{$player}_supports", $supports);
    }

    /**
     * Update all video player settings
     *
     * @param array $settings
     * @return void
     */
    public static function updateVideoPlayerSettings(array $settings): void
    {
        $players = ['chewie', 'media_kit', 'simple_youtube', 'omni', 'orax'];

        foreach ($players as $player) {
            // Update enabled status
            $enabledKey = "{$player}_enabled";
            if (array_key_exists($enabledKey, $settings)) {
                static::toggleVideoPlayer($player, (bool) $settings[$enabledKey]);
            }

            // Update support type
            $supportsKey = "{$player}_supports";
            if (array_key_exists($supportsKey, $settings)) {
                static::setVideoPlayerSupports($player, $settings[$supportsKey]);
            }
        }

        if (array_key_exists('default_upload_player', $settings)) {
            static::setDefaultUploadPlayer($settings['default_upload_player']);
        }

        if (array_key_exists('default_youtube_player', $settings)) {
            static::setDefaultYoutubePlayer($settings['default_youtube_player']);
        }
    }

    /**
     * Cast value based on type
     *
     * @param string|null $value
     * @param string $type
     * @return mixed
     */
    private static function castValue(?string $value, string $type): mixed
    {
        if ($value === null) {
            return null;
        }

        return match ($type) {
            'boolean' => (bool) $value,
            'integer' => (int) $value,
            'json' => json_decode($value, true),
            default => $value,
        };
    }
}
