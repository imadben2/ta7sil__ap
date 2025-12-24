<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\CouponService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class CouponController extends Controller
{
    protected CouponService $couponService;

    public function __construct(CouponService $couponService)
    {
        $this->couponService = $couponService;
    }

    /**
     * Validate a coupon code
     *
     * POST /v1/coupons/validate
     * Body: { code, course_id?, package_id? }
     * Response: { valid, discount_percentage?, discount_amount?, new_total?, message }
     */
    public function validate(Request $request): JsonResponse
    {
        $request->validate([
            'code' => 'required|string|max:50',
            'course_id' => 'nullable|integer|exists:courses,id',
            'package_id' => 'nullable|integer|exists:subscription_packages,id',
        ]);

        // At least one of course_id or package_id must be provided
        if (!$request->course_id && !$request->package_id) {
            return response()->json([
                'success' => false,
                'message' => 'يجب تحديد دورة أو باقة لتطبيق الكوبون',
                'data' => [
                    'valid' => false,
                ],
            ], 422);
        }

        $user = $request->user();
        $result = $this->couponService->validate(
            $request->code,
            $request->course_id,
            $request->package_id,
            $user
        );

        if (!$result['valid']) {
            return response()->json([
                'success' => false,
                'message' => $result['message'],
                'data' => [
                    'valid' => false,
                ],
            ], 200);
        }

        return response()->json([
            'success' => true,
            'message' => $result['message'],
            'data' => [
                'valid' => true,
                'coupon_id' => $result['coupon_id'],
                'code' => $result['code'],
                'discount_type' => $result['discount_type'],
                'discount_value' => $result['discount_value'],
                'discount_percentage' => $result['discount_percentage'],
                'discount_amount' => $result['discount_amount'],
                'original_price' => $result['original_price'],
                'new_total' => $result['new_total'],
            ],
        ]);
    }
}
