<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\OrderService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class OrderController extends Controller
{
    protected OrderService $orderService;

    public function __construct(OrderService $orderService)
    {
        $this->orderService = $orderService;
    }

    /**
     * Create a new order
     *
     * POST /v1/orders/create
     * Body: { course_id?, package_id?, payment_method, coupon_code? }
     */
    public function create(Request $request): JsonResponse
    {
        $request->validate([
            'course_id' => 'nullable|integer|exists:courses,id',
            'package_id' => 'nullable|integer|exists:subscription_packages,id',
            'payment_method' => 'required|in:baridimob,ccp,credit_card',
            'coupon_code' => 'nullable|string|max:50',
        ]);

        // At least one of course_id or package_id must be provided
        if (!$request->course_id && !$request->package_id) {
            return response()->json([
                'success' => false,
                'message' => 'يجب تحديد دورة أو باقة',
            ], 422);
        }

        try {
            $order = $this->orderService->createOrder($request->user(), [
                'course_id' => $request->course_id,
                'package_id' => $request->package_id,
                'payment_method' => $request->payment_method,
                'coupon_code' => $request->coupon_code,
                'ip_address' => $request->ip(),
                'user_agent' => $request->userAgent(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'تم إنشاء الطلب بنجاح',
                'data' => [
                    'order_id' => $order->id,
                    'order_number' => $order->order_number,
                    'subtotal_dzd' => $order->subtotal_dzd,
                    'discount_dzd' => $order->discount_dzd,
                    'total_dzd' => $order->total_dzd,
                    'payment_method' => $order->payment_method,
                    'payment_url' => $order->payment_url,
                    'status' => $order->status,
                    'expires_at' => $order->expires_at->toIso8601String(),
                ],
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }
    }

    /**
     * Verify payment for an order
     *
     * POST /v1/orders/{orderNumber}/verify
     * Body: { payment_reference? }
     */
    public function verify(Request $request, string $orderNumber): JsonResponse
    {
        $request->validate([
            'payment_reference' => 'nullable|string|max:255',
        ]);

        $order = $this->orderService->getOrderByNumber($orderNumber);

        if (!$order) {
            return response()->json([
                'success' => false,
                'message' => 'الطلب غير موجود',
            ], 404);
        }

        // Ensure the order belongs to the current user
        if ($order->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'غير مصرح',
            ], 403);
        }

        if (!$order->isPending() && !$order->isProcessing()) {
            return response()->json([
                'success' => false,
                'message' => 'لا يمكن التحقق من هذا الطلب',
                'data' => [
                    'status' => $order->status,
                    'course_unlocked' => $order->isCompleted(),
                ],
            ], 422);
        }

        try {
            $subscription = $this->orderService->verifyPayment($order, [
                'payment_reference' => $request->payment_reference,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'تم التحقق من الدفع بنجاح',
                'data' => [
                    'status' => 'completed',
                    'course_unlocked' => true,
                    'subscription_id' => $subscription->id,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
                'data' => [
                    'status' => $order->fresh()->status,
                    'course_unlocked' => false,
                ],
            ], 422);
        }
    }

    /**
     * Get user's orders
     *
     * GET /v1/orders/my-orders
     * Query: status? (pending, completed, cancelled, etc.)
     */
    public function myOrders(Request $request): JsonResponse
    {
        $request->validate([
            'status' => 'nullable|in:pending,processing,completed,failed,cancelled,expired,refunded',
        ]);

        $orders = $this->orderService->getUserOrders(
            $request->user(),
            $request->status
        );

        return response()->json([
            'success' => true,
            'data' => $orders->map(function ($order) {
                return [
                    'id' => $order->id,
                    'order_number' => $order->order_number,
                    'item_title' => $order->getItemTitle(),
                    'course_id' => $order->course_id,
                    'package_id' => $order->package_id,
                    'subtotal_dzd' => $order->subtotal_dzd,
                    'discount_dzd' => $order->discount_dzd,
                    'total_dzd' => $order->total_dzd,
                    'payment_method' => $order->payment_method,
                    'status' => $order->status,
                    'created_at' => $order->created_at->toIso8601String(),
                    'paid_at' => $order->paid_at?->toIso8601String(),
                ];
            }),
        ]);
    }

    /**
     * Get a single order
     *
     * GET /v1/orders/{orderNumber}
     */
    public function show(Request $request, string $orderNumber): JsonResponse
    {
        $order = $this->orderService->getOrderByNumber($orderNumber);

        if (!$order) {
            return response()->json([
                'success' => false,
                'message' => 'الطلب غير موجود',
            ], 404);
        }

        // Ensure the order belongs to the current user
        if ($order->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'غير مصرح',
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $order->id,
                'order_number' => $order->order_number,
                'item_title' => $order->getItemTitle(),
                'course' => $order->course ? [
                    'id' => $order->course->id,
                    'title_ar' => $order->course->title_ar,
                    'thumbnail_url' => $order->course->thumbnail_url,
                ] : null,
                'package' => $order->package ? [
                    'id' => $order->package->id,
                    'name_ar' => $order->package->name_ar,
                ] : null,
                'coupon' => $order->coupon ? [
                    'code' => $order->coupon->code,
                    'discount_value' => $order->coupon->discount_value,
                    'discount_type' => $order->coupon->discount_type,
                ] : null,
                'subtotal_dzd' => $order->subtotal_dzd,
                'discount_dzd' => $order->discount_dzd,
                'total_dzd' => $order->total_dzd,
                'payment_method' => $order->payment_method,
                'payment_url' => $order->payment_url,
                'payment_reference' => $order->payment_reference,
                'status' => $order->status,
                'expires_at' => $order->expires_at?->toIso8601String(),
                'created_at' => $order->created_at->toIso8601String(),
                'paid_at' => $order->paid_at?->toIso8601String(),
            ],
        ]);
    }
}
