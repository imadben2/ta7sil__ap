<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Sponsor;
use App\Models\AppSetting;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Sponsor Controller
 *
 * Handles API endpoints for "هاد التطبيق برعاية" section
 */
class SponsorController extends Controller
{
    /**
     * Get all active sponsors ordered by display_order.
     *
     * GET /api/v1/sponsors
     *
     * @return JsonResponse
     */
    public function index(): JsonResponse
    {
        // Check if sponsors section is enabled
        $sectionEnabled = AppSetting::isSponsorsEnabled();

        if (!$sectionEnabled) {
            return response()->json([
                'success' => true,
                'message' => 'قسم الرعاة معطل حالياً',
                'data' => [
                    'section_enabled' => false,
                    'sponsors' => [],
                ],
            ]);
        }

        $sponsors = Sponsor::active()
            ->ordered()
            ->get()
            ->map(function ($sponsor) {
                return [
                    'id' => $sponsor->id,
                    'name_ar' => $sponsor->name_ar,
                    'photo_url' => $sponsor->photo_url,
                    'external_link' => $sponsor->external_link,
                    'youtube_link' => $sponsor->youtube_link,
                    'facebook_link' => $sponsor->facebook_link,
                    'instagram_link' => $sponsor->instagram_link,
                    'telegram_link' => $sponsor->telegram_link,
                    'title' => $sponsor->title,
                    'specialty' => $sponsor->specialty,
                    'click_count' => $sponsor->click_count,
                    'youtube_clicks' => $sponsor->youtube_clicks,
                    'facebook_clicks' => $sponsor->facebook_clicks,
                    'instagram_clicks' => $sponsor->instagram_clicks,
                    'telegram_clicks' => $sponsor->telegram_clicks,
                    'display_order' => $sponsor->display_order,
                ];
            });

        return response()->json([
            'success' => true,
            'message' => 'تم جلب الرعاة بنجاح',
            'data' => [
                'section_enabled' => true,
                'sponsors' => $sponsors,
            ],
        ]);
    }

    /**
     * Record a click on a sponsor's social link.
     *
     * POST /api/v1/sponsors/{sponsor}/click
     *
     * @param Request $request
     * @param Sponsor $sponsor
     * @return JsonResponse
     */
    public function recordClick(Request $request, Sponsor $sponsor): JsonResponse
    {
        $platform = $request->input('platform', 'general');

        // Validate platform
        $validPlatforms = ['general', 'youtube', 'facebook', 'instagram', 'telegram'];
        if (!in_array($platform, $validPlatforms)) {
            $platform = 'general';
        }

        $newClickCount = $sponsor->incrementClickCount($platform);

        return response()->json([
            'success' => true,
            'message' => 'تم تسجيل الزيارة',
            'data' => [
                'platform' => $platform,
                'click_count' => $newClickCount,
                'total_clicks' => $sponsor->click_count,
            ],
        ]);
    }

    /**
     * Get a single sponsor by ID.
     *
     * GET /api/v1/sponsors/{sponsor}
     *
     * @param Sponsor $sponsor
     * @return JsonResponse
     */
    public function show(Sponsor $sponsor): JsonResponse
    {
        if (!$sponsor->is_active) {
            return response()->json([
                'success' => false,
                'message' => 'الراعي غير موجود',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'تم جلب بيانات الراعي بنجاح',
            'data' => [
                'id' => $sponsor->id,
                'name_ar' => $sponsor->name_ar,
                'photo_url' => $sponsor->photo_url,
                'external_link' => $sponsor->external_link,
                'youtube_link' => $sponsor->youtube_link,
                'facebook_link' => $sponsor->facebook_link,
                'instagram_link' => $sponsor->instagram_link,
                'telegram_link' => $sponsor->telegram_link,
                'title' => $sponsor->title,
                'specialty' => $sponsor->specialty,
                'click_count' => $sponsor->click_count,
                'youtube_clicks' => $sponsor->youtube_clicks,
                'facebook_clicks' => $sponsor->facebook_clicks,
                'instagram_clicks' => $sponsor->instagram_clicks,
                'telegram_clicks' => $sponsor->telegram_clicks,
                'display_order' => $sponsor->display_order,
            ],
        ]);
    }

    /**
     * Get sponsors section settings.
     *
     * GET /api/v1/sponsors/settings
     *
     * @return JsonResponse
     */
    public function settings(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => [
                'section_enabled' => AppSetting::isSponsorsEnabled(),
            ],
        ]);
    }
}
