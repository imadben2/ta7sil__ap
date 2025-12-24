<?php

namespace App\Services;

use App\Models\User;
use App\Models\Course;
use App\Models\Coupon;
use App\Models\CouponUsage;
use App\Models\Order;
use App\Models\SubscriptionPackage;
use Illuminate\Support\Facades\DB;

class CouponService
{
    /**
     * Validate a coupon code for a user and course/package
     */
    public function validate(string $code, ?int $courseId, ?int $packageId, User $user): array
    {
        $coupon = Coupon::where('code', $code)->first();

        if (!$coupon) {
            return [
                'valid' => false,
                'message' => 'رمز الكوبون غير موجود',
            ];
        }

        if (!$coupon->isValid()) {
            return [
                'valid' => false,
                'message' => 'رمز الكوبون غير صالح أو منتهي الصلاحية',
            ];
        }

        if (!$coupon->canBeUsedByUser($user)) {
            return [
                'valid' => false,
                'message' => 'لقد استخدمت هذا الكوبون الحد الأقصى من المرات',
            ];
        }

        // Get the item (course or package) for validation
        $course = $courseId ? Course::find($courseId) : null;
        $package = $packageId ? SubscriptionPackage::find($packageId) : null;

        if (!$course && !$package) {
            return [
                'valid' => false,
                'message' => 'يجب تحديد دورة أو باقة لتطبيق الكوبون',
            ];
        }

        // Check applicability
        if ($course && !$coupon->isApplicableToCourse($course)) {
            return [
                'valid' => false,
                'message' => 'هذا الكوبون غير قابل للتطبيق على هذه الدورة',
            ];
        }

        if ($package && !$coupon->isApplicableToPackage($package)) {
            return [
                'valid' => false,
                'message' => 'هذا الكوبون غير قابل للتطبيق على هذه الباقة',
            ];
        }

        // Calculate discount
        $originalPrice = $course ? $course->price_dzd : $package->price_dzd;
        $discount = $coupon->calculateDiscount($originalPrice);

        if ($discount['discount_amount'] === 0) {
            return [
                'valid' => false,
                'message' => 'الحد الأدنى للشراء غير مستوفى',
            ];
        }

        return [
            'valid' => true,
            'message' => 'الكوبون صالح',
            'coupon_id' => $coupon->id,
            'code' => $coupon->code,
            'discount_type' => $coupon->discount_type,
            'discount_value' => $coupon->discount_value,
            'discount_percentage' => $discount['discount_percentage'],
            'discount_amount' => $discount['discount_amount'],
            'original_price' => $originalPrice,
            'new_total' => $discount['final_price'],
        ];
    }

    /**
     * Calculate discount for a given coupon and price
     */
    public function calculateDiscount(Coupon $coupon, int $originalPrice): array
    {
        return $coupon->calculateDiscount($originalPrice);
    }

    /**
     * Record coupon usage
     */
    public function recordUsage(Coupon $coupon, User $user, Order $order, int $discountApplied): void
    {
        DB::transaction(function () use ($coupon, $user, $order, $discountApplied) {
            CouponUsage::create([
                'coupon_id' => $coupon->id,
                'user_id' => $user->id,
                'order_id' => $order->id,
                'discount_applied_dzd' => $discountApplied,
                'used_at' => now(),
            ]);

            $coupon->incrementUsage();
        });
    }

    /**
     * Check if coupon is eligible for user and item
     */
    public function isEligible(Coupon $coupon, User $user, ?Course $course, ?SubscriptionPackage $package): bool
    {
        if (!$coupon->isValid()) {
            return false;
        }

        if (!$coupon->canBeUsedByUser($user)) {
            return false;
        }

        if ($course && !$coupon->isApplicableToCourse($course)) {
            return false;
        }

        if ($package && !$coupon->isApplicableToPackage($package)) {
            return false;
        }

        return true;
    }

    /**
     * Get user's usage count for a coupon
     */
    public function getUserUsageCount(Coupon $coupon, User $user): int
    {
        return $coupon->usages()->where('user_id', $user->id)->count();
    }

    /**
     * Find coupon by code
     */
    public function findByCode(string $code): ?Coupon
    {
        return Coupon::where('code', $code)->first();
    }
}
