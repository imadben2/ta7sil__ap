<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Promo;
use App\Models\AppSetting;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Promo Controller
 *
 * Handles API endpoints for promotional slider on home page
 */
class PromoController extends Controller
{
    /**
     * Get all active promos ordered by display_order.
     *
     * GET /api/v1/promos
     *
     * @return JsonResponse
     */
    public function index(): JsonResponse
    {
        // Check if promos section is enabled
        $sectionEnabled = AppSetting::isPromosEnabled();

        if (!$sectionEnabled) {
            return response()->json([
                'success' => true,
                'message' => 'قسم العروض الترويجية معطل حالياً',
                'data' => [
                    'section_enabled' => false,
                    'promos' => [],
                ],
            ]);
        }

        // Get visible promos with countdown promos first
        $promos = Promo::visible()
            ->countdownFirst()
            ->get()
            ->map(fn($promo) => $promo->toApiResponse());

        return response()->json([
            'success' => true,
            'message' => 'تم جلب العروض الترويجية بنجاح',
            'data' => [
                'section_enabled' => true,
                'promos' => $promos,
            ],
        ]);
    }

    /**
     * Get a single promo by ID.
     *
     * GET /api/v1/promos/{promo}
     *
     * @param Promo $promo
     * @return JsonResponse
     */
    public function show(Promo $promo): JsonResponse
    {
        if (!$promo->isCurrentlyActive()) {
            return response()->json([
                'success' => false,
                'message' => 'العرض الترويجي غير متاح',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'تم جلب بيانات العرض الترويجي بنجاح',
            'data' => $promo->toApiResponse(),
        ]);
    }

    /**
     * Record a click on a promo (for analytics tracking).
     *
     * POST /api/v1/promos/{promo}/click
     *
     * @param Request $request
     * @param Promo $promo
     * @return JsonResponse
     */
    public function recordClick(Request $request, Promo $promo): JsonResponse
    {
        $platform = $request->input('platform', 'mobile');

        $newClickCount = $promo->incrementClickCount();

        return response()->json([
            'success' => true,
            'message' => 'تم تسجيل النقرة',
            'data' => [
                'promo_id' => $promo->id,
                'platform' => $platform,
                'click_count' => $newClickCount,
            ],
        ]);
    }

    /**
     * Get promos section settings.
     *
     * GET /api/v1/promos/settings
     *
     * @return JsonResponse
     */
    public function settings(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => [
                'section_enabled' => AppSetting::isPromosEnabled(),
            ],
        ]);
    }
}
