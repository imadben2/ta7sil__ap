<?php

namespace App\Services;

use App\Models\User;
use App\Models\Course;
use App\Models\Order;
use App\Models\Coupon;
use App\Models\UserSubscription;
use App\Models\SubscriptionPackage;
use App\Notifications\SubscriptionActivatedNotification;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class OrderService
{
    protected CouponService $couponService;
    protected SubscriptionService $subscriptionService;

    public function __construct(CouponService $couponService, SubscriptionService $subscriptionService)
    {
        $this->couponService = $couponService;
        $this->subscriptionService = $subscriptionService;
    }

    /**
     * Create a new order
     */
    public function createOrder(User $user, array $data): Order
    {
        DB::beginTransaction();

        try {
            // Get the item
            $course = isset($data['course_id']) ? Course::findOrFail($data['course_id']) : null;
            $package = isset($data['package_id']) ? SubscriptionPackage::findOrFail($data['package_id']) : null;

            if (!$course && !$package) {
                throw new \Exception('يجب تحديد دورة أو باقة');
            }

            // Check if user already has access
            if ($course && $this->subscriptionService->hasAccessToCourse($user, $course)) {
                throw new \Exception('لديك اشتراك نشط بالفعل في هذه الدورة');
            }

            // Calculate pricing
            $subtotal = $course ? $course->price_dzd : $package->price_dzd;
            $discount = 0;
            $coupon = null;

            // Apply coupon if provided
            if (!empty($data['coupon_code'])) {
                $couponResult = $this->couponService->validate(
                    $data['coupon_code'],
                    $course?->id,
                    $package?->id,
                    $user
                );

                if ($couponResult['valid']) {
                    $coupon = Coupon::find($couponResult['coupon_id']);
                    $discount = $couponResult['discount_amount'];
                }
            }

            $total = $subtotal - $discount;

            // Create order
            $order = Order::create([
                'order_number' => Order::generateOrderNumber(),
                'user_id' => $user->id,
                'course_id' => $course?->id,
                'package_id' => $package?->id,
                'subtotal_dzd' => $subtotal,
                'discount_dzd' => $discount,
                'total_dzd' => $total,
                'coupon_id' => $coupon?->id,
                'payment_method' => $data['payment_method'] ?? Order::PAYMENT_BARIDIMOB,
                'status' => Order::STATUS_PENDING,
                'expires_at' => Carbon::now()->addHours(24), // Order expires in 24 hours
                'ip_address' => $data['ip_address'] ?? null,
                'user_agent' => $data['user_agent'] ?? null,
            ]);

            // Generate payment URL (mock for now - integrate with real payment gateway)
            $paymentUrl = $this->generatePaymentUrl($order);
            $order->payment_url = $paymentUrl;
            $order->save();

            DB::commit();

            return $order;
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Apply coupon to an existing order
     */
    public function applyCoupon(Order $order, string $couponCode): Order
    {
        if (!$order->isPending()) {
            throw new \Exception('لا يمكن تعديل طلب غير معلق');
        }

        $user = $order->user;
        $couponResult = $this->couponService->validate(
            $couponCode,
            $order->course_id,
            $order->package_id,
            $user
        );

        if (!$couponResult['valid']) {
            throw new \Exception($couponResult['message']);
        }

        $coupon = Coupon::find($couponResult['coupon_id']);
        $discount = $couponResult['discount_amount'];
        $total = $order->subtotal_dzd - $discount;

        $order->update([
            'coupon_id' => $coupon->id,
            'discount_dzd' => $discount,
            'total_dzd' => $total,
        ]);

        return $order->fresh();
    }

    /**
     * Verify payment and create subscription
     */
    public function verifyPayment(Order $order, array $paymentData): UserSubscription
    {
        DB::beginTransaction();

        try {
            // Verify with payment gateway (mock implementation)
            $paymentVerified = $this->verifyWithGateway($order, $paymentData);

            if (!$paymentVerified) {
                $order->markAsFailed('فشل التحقق من الدفع');
                throw new \Exception('فشل التحقق من الدفع');
            }

            // Mark order as completed
            $order->markAsCompleted($paymentData['payment_reference'] ?? null);

            // Record coupon usage if applicable
            if ($order->coupon_id) {
                $coupon = $order->coupon;
                $this->couponService->recordUsage($coupon, $order->user, $order, $order->discount_dzd);
            }

            // Create subscription
            $subscription = $this->createSubscriptionFromOrder($order);

            DB::commit();

            return $subscription;
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Create subscription from completed order
     */
    private function createSubscriptionFromOrder(Order $order): UserSubscription
    {
        $user = $order->user;

        if ($order->course_id) {
            $subscription = UserSubscription::create([
                'user_id' => $user->id,
                'course_id' => $order->course_id,
                'activated_by' => 'order',
                'order_id' => $order->id,
                'is_active' => true,
                'activated_at' => now(),
                'expires_at' => null, // Course subscriptions don't expire
            ]);

            // Increment enrollment count
            $order->course->incrementEnrollmentCount();

            // Send notification
            $user->notify(new SubscriptionActivatedNotification($subscription));

            return $subscription;
        }

        // Package subscription
        $package = $order->package;
        $expiresAt = now()->addDays($package->duration_days);
        $subscription = null;

        foreach ($package->courses as $course) {
            $existingSubscription = UserSubscription::where('user_id', $user->id)
                ->where('course_id', $course->id)
                ->where('is_active', true)
                ->first();

            if ($existingSubscription && $existingSubscription->isActive()) {
                continue; // Skip if already subscribed
            }

            $newSubscription = UserSubscription::create([
                'user_id' => $user->id,
                'course_id' => $course->id,
                'package_id' => $package->id,
                'activated_by' => 'order',
                'order_id' => $order->id,
                'is_active' => true,
                'activated_at' => now(),
                'expires_at' => $expiresAt,
            ]);

            $course->incrementEnrollmentCount();

            if (!$subscription) {
                $subscription = $newSubscription;
            }
        }

        // Send notification
        $user->notify(new SubscriptionActivatedNotification($subscription));

        return $subscription;
    }

    /**
     * Generate payment URL (mock - replace with real gateway integration)
     */
    private function generatePaymentUrl(Order $order): string
    {
        // This is a mock implementation
        // Replace with actual payment gateway integration (Baridi Mob, CCP, etc.)
        $baseUrl = config('app.url');
        return "{$baseUrl}/api/v1/orders/{$order->order_number}/pay";
    }

    /**
     * Verify payment with gateway (mock - replace with real verification)
     */
    private function verifyWithGateway(Order $order, array $paymentData): bool
    {
        // This is a mock implementation
        // Replace with actual payment gateway verification

        // For now, accept any payment with a reference
        return !empty($paymentData['payment_reference']) || !empty($paymentData['force_verify']);
    }

    /**
     * Cancel expired orders
     */
    public function cancelExpiredOrders(): int
    {
        $expiredCount = 0;

        Order::where('status', Order::STATUS_PENDING)
            ->whereNotNull('expires_at')
            ->where('expires_at', '<=', now())
            ->chunk(100, function ($orders) use (&$expiredCount) {
                foreach ($orders as $order) {
                    $order->markAsExpired();
                    $expiredCount++;
                }
            });

        return $expiredCount;
    }

    /**
     * Get user's orders
     */
    public function getUserOrders(User $user, ?string $status = null)
    {
        $query = Order::where('user_id', $user->id)
            ->with(['course', 'package', 'coupon'])
            ->orderBy('created_at', 'desc');

        if ($status) {
            $query->where('status', $status);
        }

        return $query->get();
    }

    /**
     * Get order by order number
     */
    public function getOrderByNumber(string $orderNumber): ?Order
    {
        return Order::where('order_number', $orderNumber)
            ->with(['course', 'package', 'coupon', 'user'])
            ->first();
    }
}
