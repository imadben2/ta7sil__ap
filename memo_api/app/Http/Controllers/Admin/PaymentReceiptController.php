<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\PaymentReceipt;
use App\Services\SubscriptionService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Yajra\DataTables\Facades\DataTables;

class PaymentReceiptController extends Controller
{
    protected SubscriptionService $subscriptionService;

    public function __construct(SubscriptionService $subscriptionService)
    {
        $this->subscriptionService = $subscriptionService;
    }

    /**
     * Display receipts list
     */
    public function index(Request $request)
    {
        // Handle DataTables AJAX request
        if ($request->ajax()) {
            $query = PaymentReceipt::with(['user', 'course', 'package', 'reviewer']);

            // Filter by status
            if ($request->filled('status')) {
                $query->where('status', $request->status);
            }

            // Filter by course
            if ($request->filled('course_id')) {
                $query->where('course_id', $request->course_id);
            }

            // Filter by date range
            if ($request->filled('date_from')) {
                $query->whereDate('submitted_at', '>=', $request->date_from);
            }

            if ($request->filled('date_to')) {
                $query->whereDate('submitted_at', '<=', $request->date_to);
            }

            return DataTables::of($query)
                ->addColumn('user_info', function ($receipt) {
                    return '<div class="text-sm">
                                <div class="font-medium text-gray-900">' . e($receipt->user->full_name_ar) . '</div>
                                <div class="text-gray-500">' . e($receipt->user->email) . '</div>
                            </div>';
                })
                ->addColumn('item', function ($receipt) {
                    if ($receipt->course) {
                        return '<div class="flex items-center gap-2">
                                    <i class="fas fa-video text-blue-500"></i>
                                    <span class="text-sm">' . e($receipt->course->title_ar) . '</span>
                                </div>';
                    } elseif ($receipt->package) {
                        return '<div class="flex items-center gap-2">
                                    <i class="fas fa-box text-purple-500"></i>
                                    <span class="text-sm">' . e($receipt->package->name_ar) . '</span>
                                </div>';
                    }
                    return '-';
                })
                ->addColumn('amount', function ($receipt) {
                    return '<span class="font-bold text-green-600">' . number_format($receipt->amount_dzd) . ' دج</span>';
                })
                ->addColumn('date', function ($receipt) {
                    return '<div class="text-sm text-gray-600">' .
                           $receipt->submitted_at->format('Y-m-d') .
                           '<br><span class="text-xs text-gray-400">' .
                           $receipt->submitted_at->format('H:i') .
                           '</span></div>';
                })
                ->addColumn('status_badge', function ($receipt) {
                    $statusColors = [
                        'pending' => 'bg-yellow-100 text-yellow-800',
                        'approved' => 'bg-green-100 text-green-800',
                        'rejected' => 'bg-red-100 text-red-800',
                    ];
                    $statusIcons = [
                        'pending' => 'fa-clock',
                        'approved' => 'fa-check-circle',
                        'rejected' => 'fa-times-circle',
                    ];
                    $statusLabels = [
                        'pending' => 'قيد المراجعة',
                        'approved' => 'مقبول',
                        'rejected' => 'مرفوض',
                    ];

                    $color = $statusColors[$receipt->status] ?? 'bg-gray-100 text-gray-800';
                    $icon = $statusIcons[$receipt->status] ?? 'fa-question';
                    $label = $statusLabels[$receipt->status] ?? $receipt->status;

                    return '<span class="px-3 py-1 inline-flex items-center gap-1 text-xs font-semibold rounded-full ' . $color . '">
                                <i class="fas ' . $icon . '"></i>
                                ' . $label . '
                            </span>';
                })
                ->addColumn('actions', function ($receipt) {
                    $actions = '<div class="flex gap-2">';

                    // View button
                    $actions .= '<a href="' . route('admin.payment-receipts.show', $receipt) . '"
                                    class="px-3 py-1.5 bg-blue-50 hover:bg-blue-100 text-blue-600 rounded-lg text-sm font-medium transition-colors flex items-center gap-1">
                                    <i class="fas fa-eye"></i>
                                    عرض
                                 </a>';

                    // Approve button (only for pending)
                    if ($receipt->status === 'pending') {
                        $actions .= '<button onclick="approveReceipt(' . $receipt->id . ')"
                                        class="px-3 py-1.5 bg-green-50 hover:bg-green-100 text-green-600 rounded-lg text-sm font-medium transition-colors flex items-center gap-1">
                                        <i class="fas fa-check"></i>
                                        قبول
                                     </button>';
                    }

                    $actions .= '</div>';
                    return $actions;
                })
                ->rawColumns(['user_info', 'item', 'amount', 'date', 'status_badge', 'actions'])
                ->make(true);
        }

        // Regular page load - return view with filter data and stats
        $stats = [
            'pending' => PaymentReceipt::where('status', 'pending')->count(),
            'approved' => PaymentReceipt::where('status', 'approved')->count(),
            'rejected' => PaymentReceipt::where('status', 'rejected')->count(),
            'total_amount' => PaymentReceipt::where('status', 'approved')->sum('amount_dzd'),
        ];

        $courses = \App\Models\Course::orderBy('title_ar')->get();

        return view('admin.payment-receipts.index', compact('stats', 'courses'));
    }

    /**
     * Show receipt details
     */
    public function show(PaymentReceipt $receipt)
    {
        $receipt->load(['user', 'course', 'package', 'reviewer', 'subscription']);

        return view('admin.payment-receipts.show', compact('receipt'));
    }

    /**
     * Approve receipt
     */
    public function approve(Request $request, PaymentReceipt $receipt)
    {
        $validated = $request->validate([
            'admin_notes' => 'nullable|string',
        ]);

        try {
            $admin = Auth::user();
            $subscription = $this->subscriptionService->approvePaymentReceipt(
                $receipt,
                $admin,
                $validated['admin_notes'] ?? null
            );

            return redirect()
                ->route('admin.payment-receipts.show', $receipt)
                ->with('success', 'تم قبول الإيصال وإنشاء الاشتراك بنجاح');
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ أثناء قبول الإيصال: ' . $e->getMessage());
        }
    }

    /**
     * Reject receipt
     */
    public function reject(Request $request, PaymentReceipt $receipt)
    {
        $validated = $request->validate([
            'rejection_reason' => 'required|string',
            'admin_notes' => 'nullable|string',
        ]);

        try {
            $admin = Auth::user();
            $this->subscriptionService->rejectPaymentReceipt(
                $receipt,
                $admin,
                $validated['rejection_reason'],
                $validated['admin_notes'] ?? null
            );

            return redirect()
                ->route('admin.payment-receipts.show', $receipt)
                ->with('success', 'تم رفض الإيصال بنجاح');
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ أثناء رفض الإيصال: ' . $e->getMessage());
        }
    }

    /**
     * Bulk approve receipts
     */
    public function bulkApprove(Request $request)
    {
        $validated = $request->validate([
            'receipt_ids' => 'required|array',
            'receipt_ids.*' => 'exists:payment_receipts,id',
        ]);

        try {
            $admin = Auth::user();
            $count = 0;

            foreach ($validated['receipt_ids'] as $receiptId) {
                $receipt = PaymentReceipt::find($receiptId);

                if ($receipt && $receipt->isPending()) {
                    $this->subscriptionService->approvePaymentReceipt($receipt, $admin);
                    $count++;
                }
            }

            return back()->with('success', "تم قبول {$count} إيصال بنجاح");
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Download receipt image
     */
    public function downloadReceipt(PaymentReceipt $receipt)
    {
        $path = storage_path('app/public/' . $receipt->receipt_image_url);

        if (!file_exists($path)) {
            abort(404, 'الملف غير موجود');
        }

        return response()->download($path);
    }
}
