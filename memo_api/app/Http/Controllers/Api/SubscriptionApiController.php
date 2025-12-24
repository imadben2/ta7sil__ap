<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Course;
use App\Models\SubscriptionPackage;
use App\Models\SubscriptionCode;
use App\Models\PaymentReceipt;
use App\Services\SubscriptionService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Storage;

class SubscriptionApiController extends Controller
{
    protected SubscriptionService $subscriptionService;

    public function __construct(SubscriptionService $subscriptionService)
    {
        $this->subscriptionService = $subscriptionService;
    }

    /**
     * Get user's active subscriptions
     * GET /api/my-subscriptions
     */
    public function mySubscriptions(Request $request): JsonResponse
    {
        $user = $request->user();
        $subscriptions = $this->subscriptionService->getUserSubscriptions($user);

        return response()->json([
            'success' => true,
            'data' => $subscriptions,
        ]);
    }

    /**
     * Subscribe using a code
     * POST /api/subscriptions/redeem-code
     */
    public function redeemCode(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'code' => 'required|string',
        ]);

        $user = $request->user();

        try {
            $subscription = $this->subscriptionService->subscribeWithCode($user, $validated['code']);

            return response()->json([
                'success' => true,
                'message' => 'تم تفعيل الرمز بنجاح',
                'data' => $subscription->load(['course', 'package']),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Validate a subscription code
     * POST /api/subscriptions/validate-code
     */
    public function validateCode(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'code' => 'required|string',
        ]);

        $code = SubscriptionCode::where('code', strtoupper($validated['code']))->first();

        if (!$code) {
            return response()->json([
                'success' => false,
                'valid' => false,
                'message' => 'رمز الاشتراك غير موجود',
            ]);
        }

        $isValid = $code->isValid();

        $data = [
            'success' => true,
            'valid' => $isValid,
            'code' => [
                'code' => $code->code,
                'type' => $code->code_type,
                'remaining_uses' => $code->getRemainingUses(),
                'expires_at' => $code->expires_at?->format('Y-m-d H:i:s'),
            ],
        ];

        if ($isValid) {
            if ($code->code_type === 'single_course') {
                $data['course'] = $code->course;
            } elseif ($code->code_type === 'package') {
                $data['package'] = $code->package->load('courses');
            }
            $data['message'] = 'الرمز صالح للاستخدام';
        } else {
            $data['message'] = 'الرمز غير صالح أو منتهي الصلاحية';
        }

        return response()->json($data);
    }

    /**
     * Get available subscription packages
     * GET /api/subscription-packages
     */
    public function packages(): JsonResponse
    {
        $packages = SubscriptionPackage::where('is_active', true)
            ->with(['courses' => function ($q) {
                $q->where('is_published', true);
            }])
            ->get();

        return response()->json([
            'success' => true,
            'data' => $packages,
        ]);
    }

    /**
     * Submit payment receipt
     * POST /api/subscriptions/submit-receipt
     */
    public function submitReceipt(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'course_id' => 'nullable|required_without:package_id|exists:courses,id',
            'package_id' => 'nullable|required_without:course_id|exists:subscription_packages,id',
            'receipt_image' => 'required|image|max:5120', // 5MB
            'amount_dzd' => 'required|integer|min:0',
            'payment_method' => 'nullable|string|max:255',
            'transaction_reference' => 'nullable|string|max:255',
            'user_notes' => 'nullable|string',
        ]);

        $user = $request->user();

        try {
            $course = isset($validated['course_id']) ? Course::find($validated['course_id']) : null;
            $package = isset($validated['package_id']) ? SubscriptionPackage::find($validated['package_id']) : null;

            $receipt = $this->subscriptionService->submitPaymentReceipt(
                $user,
                $course,
                $package,
                $request->file('receipt_image'),
                $validated
            );

            return response()->json([
                'success' => true,
                'message' => 'تم إرسال الإيصال بنجاح، سيتم مراجعته من قبل الإدارة',
                'data' => $receipt,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء إرسال الإيصال: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get user's payment receipts
     * GET /api/my-payment-receipts?status=pending|approved|rejected
     */
    public function myPaymentReceipts(Request $request): JsonResponse
    {
        $user = $request->user();

        $query = PaymentReceipt::where('user_id', $user->id)
            ->with(['course', 'package', 'subscription']);

        // Filter by status if provided
        if ($request->has('status') && $request->status) {
            $query->where('status', $request->status);
        }

        $receipts = $query->orderBy('submitted_at', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => $receipts,
        ]);
    }

    /**
     * Get payment receipt details
     * GET /api/payment-receipts/{id}
     */
    public function receiptDetails(Request $request, $id): JsonResponse
    {
        $user = $request->user();

        $receipt = PaymentReceipt::where('user_id', $user->id)
            ->where('id', $id)
            ->with(['course', 'package', 'subscription', 'reviewer'])
            ->firstOrFail();

        // Add receipt image URL
        $receipt->receipt_image_full_url = Storage::url($receipt->receipt_image_url);

        return response()->json([
            'success' => true,
            'data' => $receipt,
        ]);
    }

    /**
     * Check if user has access to a course
     * GET /api/courses/{id}/check-access
     */
    public function checkCourseAccess(Request $request, $id): JsonResponse
    {
        $user = $request->user();
        $course = Course::findOrFail($id);

        $hasAccess = $this->subscriptionService->hasAccessToCourse($user, $course);

        $response = [
            'success' => true,
            'has_access' => $hasAccess,
            'course' => [
                'id' => $course->id,
                'title_ar' => $course->title_ar,
                'is_free' => $course->is_free,
                'price_dzd' => $course->price_dzd,
            ],
        ];

        if (!$hasAccess) {
            // Get subscription options
            $response['subscription_options'] = [
                'direct_purchase' => !$course->is_free,
                'available_packages' => SubscriptionPackage::whereHas('courses', function ($q) use ($course) {
                    $q->where('courses.id', $course->id);
                })->where('is_active', true)->get(),
            ];
        }

        return response()->json($response);
    }

    /**
     * Get subscription statistics for user
     * GET /api/my-subscription-stats
     */
    public function myStats(Request $request): JsonResponse
    {
        $user = $request->user();

        $stats = [
            'active_subscriptions' => $user->subscriptions()
                ->where('is_active', true)
                ->where('expires_at', '>', now())
                ->count(),
            'expired_subscriptions' => $user->subscriptions()
                ->where('expires_at', '<=', now())
                ->count(),
            'pending_receipts' => PaymentReceipt::where('user_id', $user->id)->where('status', 'pending')->count(),
            'approved_receipts' => PaymentReceipt::where('user_id', $user->id)->where('status', 'approved')->count(),
            'rejected_receipts' => PaymentReceipt::where('user_id', $user->id)->where('status', 'rejected')->count(),
        ];

        return response()->json([
            'success' => true,
            'data' => $stats,
        ]);
    }

    /**
     * Admin: List all payment receipts with filtering
     * GET /api/admin/payment-receipts?status=pending
     */
    public function adminListReceipts(Request $request): JsonResponse
    {
        $query = PaymentReceipt::with(['user', 'course', 'package', 'reviewer']);

        // Filter by status if provided
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Order by submission date (newest first)
        $query->orderBy('submitted_at', 'desc');

        $receipts = $query->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $receipts,
        ]);
    }

    /**
     * Admin: Approve a payment receipt
     * POST /api/admin/payment-receipts/{id}/approve
     */
    public function adminApproveReceipt(Request $request, $id): JsonResponse
    {
        $validated = $request->validate([
            'admin_notes' => 'nullable|string',
        ]);

        try {
            $receipt = PaymentReceipt::findOrFail($id);
            $admin = $request->user();

            $subscription = $this->subscriptionService->approvePaymentReceipt(
                $receipt,
                $admin,
                $validated['admin_notes'] ?? null
            );

            return response()->json([
                'success' => true,
                'message' => 'تم الموافقة على الإيصال وتفعيل الاشتراك',
                'data' => [
                    'receipt' => $receipt->fresh(['user', 'course', 'package']),
                    'subscription' => $subscription,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء الموافقة على الإيصال: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Admin: Reject a payment receipt
     * POST /api/admin/payment-receipts/{id}/reject
     */
    public function adminRejectReceipt(Request $request, $id): JsonResponse
    {
        $validated = $request->validate([
            'rejection_reason' => 'required|string',
            'admin_notes' => 'nullable|string',
        ]);

        try {
            $receipt = PaymentReceipt::findOrFail($id);
            $admin = $request->user();

            $this->subscriptionService->rejectPaymentReceipt(
                $receipt,
                $admin,
                $validated['rejection_reason'],
                $validated['admin_notes'] ?? null
            );

            return response()->json([
                'success' => true,
                'message' => 'تم رفض الإيصال',
                'data' => $receipt->fresh(['user', 'course', 'package']),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء رفض الإيصال: ' . $e->getMessage(),
            ], 500);
        }
    }
}
