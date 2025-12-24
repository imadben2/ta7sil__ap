<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\UserSubscription;
use App\Models\Course;
use App\Models\SubscriptionPackage;
use App\Models\User;
use App\Services\SubscriptionService;
use Illuminate\Http\Request;
use Yajra\DataTables\Facades\DataTables;

class SubscriptionController extends Controller
{
    protected SubscriptionService $subscriptionService;

    public function __construct(SubscriptionService $subscriptionService)
    {
        $this->subscriptionService = $subscriptionService;
    }

    /**
     * Display subscriptions list
     */
    public function index(Request $request)
    {
        if ($request->ajax()) {
            return $this->getDataTable($request);
        }

        $courses = Course::orderBy('title_ar')->get();
        return view('admin.subscriptions.index', compact('courses'));
    }

    /**
     * Get DataTables data for subscriptions
     */
    private function getDataTable(Request $request)
    {
        $query = UserSubscription::with(['user', 'course', 'package']);

        // Filter by course
        if ($request->filled('course_id')) {
            $query->where('course_id', $request->course_id);
        }

        // Filter by status
        if ($request->filled('status')) {
            $status = $request->status;
            if ($status === 'active') {
                $query->where('status', 'active')->where('expires_at', '>', now());
            } elseif ($status === 'expired') {
                $query->where('expires_at', '<=', now());
            } elseif ($status === 'inactive') {
                $query->where('status', 'inactive');
            }
        }

        // Filter by subscription method
        if ($request->filled('subscription_method')) {
            $query->where('subscription_method', $request->subscription_method);
        }

        return DataTables::of($query)
            ->addColumn('user_info', function($subscription) {
                $userName = $subscription->user->name ?? 'N/A';
                $userEmail = $subscription->user->email ?? '';
                $initial = $userName !== 'N/A' ? mb_strtoupper(mb_substr($userName, 0, 1, 'UTF-8'), 'UTF-8') : 'U';

                return '
                    <div class="flex items-center gap-3">
                        <div class="w-10 h-10 bg-gradient-to-r from-blue-500 to-purple-500 rounded-full flex items-center justify-center text-white font-bold">
                            ' . $initial . '
                        </div>
                        <div>
                            <div class="font-semibold text-gray-900">' . e($userName) . '</div>
                            <div class="text-sm text-gray-500">' . e($userEmail) . '</div>
                        </div>
                    </div>
                ';
            })
            ->addColumn('subscription_type', function($subscription) {
                if ($subscription->course_id) {
                    return '<span class="px-2 py-1 bg-blue-100 text-blue-700 rounded-full text-xs font-semibold">دورة</span>';
                } elseif ($subscription->package_id) {
                    return '<span class="px-2 py-1 bg-purple-100 text-purple-700 rounded-full text-xs font-semibold">باقة</span>';
                } else {
                    return '<span class="px-2 py-1 bg-gray-100 text-gray-700 rounded-full text-xs font-semibold">غير محدد</span>';
                }
            })
            ->addColumn('details', function($subscription) {
                if ($subscription->course) {
                    return '<div class="font-medium text-gray-900">' . e($subscription->course->title_ar) . '</div>';
                } elseif ($subscription->package) {
                    return '<div class="font-medium text-gray-900">' . e($subscription->package->name_ar) . '</div>';
                } else {
                    return '<span class="text-gray-500">-</span>';
                }
            })
            ->addColumn('dates', function($subscription) {
                return '
                    <div class="text-sm">
                        <div><strong>البداية:</strong> ' . ($subscription->started_at ? $subscription->started_at->format('Y-m-d') : '-') . '</div>
                        <div><strong>الانتهاء:</strong> ' . ($subscription->expires_at ? $subscription->expires_at->format('Y-m-d') : '-') . '</div>
                    </div>
                ';
            })
            ->addColumn('status_badge', function($subscription) {
                if ($subscription->status === 'active' && $subscription->expires_at && $subscription->expires_at->isFuture()) {
                    return '<span class="px-3 py-1 bg-green-100 text-green-700 rounded-full text-xs font-bold">نشط</span>';
                } elseif ($subscription->status === 'expired' || ($subscription->expires_at && $subscription->expires_at->isPast())) {
                    return '<span class="px-3 py-1 bg-red-100 text-red-700 rounded-full text-xs font-bold">منتهي</span>';
                } elseif ($subscription->status === 'cancelled') {
                    return '<span class="px-3 py-1 bg-orange-100 text-orange-700 rounded-full text-xs font-bold">ملغي</span>';
                } else {
                    return '<span class="px-3 py-1 bg-gray-100 text-gray-700 rounded-full text-xs font-bold">غير نشط</span>';
                }
            })
            ->addColumn('actions', function($subscription) {
                $actions = '<div class="flex gap-2 flex-wrap">';

                // View button - always available
                $actions .= '<a href="' . route('admin.subscriptions.show', $subscription->id) . '"
                               class="px-3 py-1 bg-blue-100 hover:bg-blue-200 text-blue-700 rounded text-sm font-semibold transition">
                                <i class="fas fa-eye"></i> عرض
                            </a>';

                // Check if active and not expired
                $isActive = $subscription->status === 'active' && $subscription->expires_at && $subscription->expires_at->isFuture();
                $isExpired = $subscription->expires_at && $subscription->expires_at->isPast();

                if ($isActive) {
                    // Suspend button for active subscriptions
                    $actions .= '<form action="' . route('admin.subscriptions.suspend', $subscription->id) . '" method="POST" class="inline">
                                    ' . csrf_field() . '
                                    <button type="submit" onclick="return confirm(\'هل أنت متأكد من تعليق هذا الاشتراك؟\')"
                                            class="px-3 py-1 bg-orange-100 hover:bg-orange-200 text-orange-700 rounded text-sm font-semibold transition">
                                        <i class="fas fa-pause"></i> تعليق
                                    </button>
                                </form>';

                    // Extend button for active subscriptions
                    $actions .= '<a href="' . route('admin.subscriptions.show', $subscription->id) . '#extend"
                                   class="px-3 py-1 bg-green-100 hover:bg-green-200 text-green-700 rounded text-sm font-semibold transition">
                                    <i class="fas fa-clock"></i> تمديد
                                </a>';
                } elseif ($isExpired || $subscription->status === 'cancelled') {
                    // Reactivate button for expired/cancelled subscriptions
                    $actions .= '<form action="' . route('admin.subscriptions.reactivate', $subscription->id) . '" method="POST" class="inline">
                                    ' . csrf_field() . '
                                    <button type="submit" onclick="return confirm(\'هل أنت متأكد من إعادة تفعيل هذا الاشتراك؟\')"
                                            class="px-3 py-1 bg-green-100 hover:bg-green-200 text-green-700 rounded text-sm font-semibold transition">
                                        <i class="fas fa-play"></i> تفعيل
                                    </button>
                                </form>';
                }

                $actions .= '</div>';

                return $actions;
            })
            ->rawColumns(['user_info', 'subscription_type', 'details', 'dates', 'status_badge', 'actions'])
            ->make(true);
    }

    /**
     * Show subscription details
     */
    public function show(UserSubscription $subscription)
    {
        $subscription->load([
            'user',
            'course.modules',
            'package.courses',
            'code',
            'receipt',
        ]);

        return view('admin.subscriptions.show', compact('subscription'));
    }

    /**
     * Suspend subscription
     */
    public function suspend(UserSubscription $subscription)
    {
        try {
            $this->subscriptionService->suspendSubscription($subscription);

            return back()->with('success', 'تم تعليق الاشتراك بنجاح');
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Reactivate subscription
     */
    public function reactivate(UserSubscription $subscription)
    {
        try {
            $this->subscriptionService->reactivateSubscription($subscription);

            return back()->with('success', 'تم تفعيل الاشتراك بنجاح');
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Extend subscription expiration date
     */
    public function extend(Request $request, UserSubscription $subscription)
    {
        $request->validate([
            'days' => 'required|integer|min:1|max:365',
            'notes' => 'nullable|string|max:500',
        ]);

        try {
            $this->subscriptionService->extendSubscription($subscription, $request->days);

            return back()->with('success', "تم تمديد الاشتراك بنجاح لمدة {$request->days} يوم");
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Expire subscriptions (manual trigger)
     */
    public function expireSubscriptions()
    {
        try {
            $count = $this->subscriptionService->expireSubscriptions();

            return back()->with('success', "تم انتهاء {$count} اشتراك");
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Display packages list
     */
    public function packages(Request $request)
    {
        $query = SubscriptionPackage::withCount('courses');

        // Search
        if ($request->filled('search')) {
            $search = $request->search;
            $query->where('name_ar', 'like', "%{$search}%");
        }

        // Filter by active status
        if ($request->filled('is_active')) {
            $query->where('is_active', $request->is_active);
        }

        $packages = $query->paginate(20);

        return view('admin.subscriptions.packages', compact('packages'));
    }

    /**
     * Show create package form
     */
    public function createPackage()
    {
        $courses = Course::where('is_published', true)->orderBy('title_ar')->get();

        return view('admin.subscriptions.create-package', compact('courses'));
    }

    /**
     * Store new package
     */
    public function storePackage(Request $request)
    {
        $validated = $request->validate([
            'name_ar' => 'required|string|max:255',
            'description_ar' => 'required|string',
            'price_dzd' => 'required|integer|min:0',
            'duration_days' => 'required|integer|min:1',
            'is_active' => 'boolean',
            'course_ids' => 'required|array|min:1',
            'course_ids.*' => 'exists:courses,id',
        ]);

        try {
            $package = $this->subscriptionService->createPackage($validated);

            return redirect()
                ->route('admin.subscriptions.packages')
                ->with('success', 'تم إنشاء الباقة بنجاح');
        } catch (\Exception $e) {
            return back()
                ->withInput()
                ->with('error', 'حدث خطأ أثناء إنشاء الباقة: ' . $e->getMessage());
        }
    }

    /**
     * Show edit package form
     */
    public function editPackage(SubscriptionPackage $package)
    {
        $courses = Course::where('is_published', true)->orderBy('title_ar')->get();
        $package->load('courses');

        return view('admin.subscriptions.edit-package', compact('package', 'courses'));
    }

    /**
     * Update package
     */
    public function updatePackage(Request $request, SubscriptionPackage $package)
    {
        $validated = $request->validate([
            'name_ar' => 'required|string|max:255',
            'description_ar' => 'required|string',
            'price_dzd' => 'required|integer|min:0',
            'duration_days' => 'required|integer|min:1',
            'is_active' => 'boolean',
            'course_ids' => 'required|array|min:1',
            'course_ids.*' => 'exists:courses,id',
        ]);

        try {
            $package = $this->subscriptionService->updatePackage($package, $validated);

            return redirect()
                ->route('admin.subscriptions.packages')
                ->with('success', 'تم تحديث الباقة بنجاح');
        } catch (\Exception $e) {
            return back()
                ->withInput()
                ->with('error', 'حدث خطأ أثناء تحديث الباقة: ' . $e->getMessage());
        }
    }

    /**
     * Delete package
     */
    public function destroyPackage(SubscriptionPackage $package)
    {
        try {
            $this->subscriptionService->deletePackage($package);

            return redirect()
                ->route('admin.subscriptions.packages')
                ->with('success', 'تم حذف الباقة بنجاح');
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ أثناء حذف الباقة: ' . $e->getMessage());
        }
    }
}
