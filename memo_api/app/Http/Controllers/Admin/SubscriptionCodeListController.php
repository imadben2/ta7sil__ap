<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\SubscriptionCodeList;
use App\Models\Course;
use App\Models\SubscriptionPackage;
use App\Services\CodeListService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;
use Yajra\DataTables\Facades\DataTables;

class SubscriptionCodeListController extends Controller
{
    protected CodeListService $listService;

    public function __construct(CodeListService $listService)
    {
        $this->listService = $listService;
    }

    /**
     * Display all code lists
     */
    public function index(Request $request)
    {
        // Handle DataTables AJAX request
        if ($request->ajax()) {
            $query = SubscriptionCodeList::with(['course', 'package', 'creator'])
                ->withCount([
                    'codes',
                    'codes as used_codes_count' => function ($q) {
                        $q->where('current_uses', '>', 0);
                    },
                    'codes as valid_codes_count' => function ($q) {
                        $q->where('is_active', true)
                          ->where(function ($q2) {
                              $q2->whereNull('expires_at')
                                 ->orWhere('expires_at', '>', now());
                          })
                          ->whereRaw('current_uses < max_uses');
                    },
                ])
                ->withSum('codes', 'current_uses');

            // Apply filters
            if ($request->filled('code_type')) {
                $query->where('code_type', $request->code_type);
            }

            if ($request->filled('course_id')) {
                $query->where('course_id', $request->course_id);
            }

            if ($request->filled('package_id')) {
                $query->where('package_id', $request->package_id);
            }

            return DataTables::of($query)
                ->addColumn('name_display', function ($list) {
                    return '<div class="font-semibold text-lg text-gray-900">' . e($list->name) . '</div>';
                })
                ->addColumn('type_badge', function ($list) {
                    $typeColors = [
                        'single_course' => 'bg-blue-100 text-blue-800',
                        'package' => 'bg-purple-100 text-purple-800',
                        'general' => 'bg-green-100 text-green-800',
                    ];
                    $typeLabels = [
                        'single_course' => 'دورة واحدة',
                        'package' => 'باقة',
                        'general' => 'عام',
                    ];

                    $color = $typeColors[$list->code_type] ?? 'bg-gray-100 text-gray-800';
                    $label = $typeLabels[$list->code_type] ?? $list->code_type;

                    return '<span class="px-3 py-1 inline-flex text-xs font-semibold rounded-full ' . $color . '">' . $label . '</span>';
                })
                ->addColumn('item', function ($list) {
                    if ($list->course) {
                        return '<span class="text-sm">' . e($list->course->title_ar) . '</span>';
                    } elseif ($list->package) {
                        return '<span class="text-sm">' . e($list->package->name_ar) . '</span>';
                    }
                    return '<span class="text-gray-500 text-sm">جميع المحتويات</span>';
                })
                ->addColumn('stats', function ($list) {
                    return '<div class="text-sm">
                                <div class="font-bold text-gray-900">' . $list->codes_count . ' أكواد</div>
                                <div class="text-green-600">' . $list->valid_codes_count . ' صالح</div>
                            </div>';
                })
                ->addColumn('revenue', function ($list) {
                    $totalUses = $list->codes_sum_current_uses ?? 0;
                    $revenue = 0;

                    if ($list->course) {
                        $revenue = $totalUses * $list->course->price_dzd;
                    } elseif ($list->package) {
                        $revenue = $totalUses * $list->package->price_dzd;
                    }

                    return '<div class="text-sm">
                                <div class="font-bold text-green-700">' . number_format($revenue, 2) . ' دج</div>
                                <div class="text-gray-600 text-xs">' . $totalUses . ' استخدام</div>
                            </div>';
                })
                ->addColumn('created', function ($list) {
                    return '<div class="text-sm text-gray-600">' . $list->created_at->format('Y-m-d') . '</div>';
                })
                ->addColumn('actions', function ($list) {
                    return '<div class="flex gap-2">
                                <a href="' . route('admin.subscription-code-lists.show', $list) . '"
                                   class="px-3 py-1.5 bg-blue-50 hover:bg-blue-100 text-blue-600 rounded-lg text-sm font-medium transition-colors flex items-center gap-1">
                                    <i class="fas fa-eye"></i>
                                    عرض
                                </a>
                                <form action="' . route('admin.subscription-code-lists.destroy', $list) . '" method="POST" class="inline-block" onsubmit="return confirm(\'هل أنت متأكد من حذف هذه القائمة؟ سيتم الاحتفاظ بالأكواد ولكن ستفقد ارتباطها بالقائمة.\')">
                                    ' . csrf_field() . '
                                    ' . method_field('DELETE') . '
                                    <button type="submit" class="px-3 py-1.5 bg-red-50 hover:bg-red-100 text-red-600 rounded-lg text-sm font-medium transition-colors flex items-center gap-1">
                                        <i class="fas fa-trash"></i>
                                        حذف
                                    </button>
                                </form>
                            </div>';
                })
                ->rawColumns(['name_display', 'type_badge', 'item', 'stats', 'revenue', 'created', 'actions'])
                ->make(true);
        }

        // Regular page load
        $stats = [
            'total_lists' => SubscriptionCodeList::count(),
            'total_codes' => SubscriptionCodeList::sum('total_codes'),
        ];

        $courses = Course::orderBy('title_ar')->get();
        $packages = SubscriptionPackage::orderBy('name_ar')->get();

        return view('admin.subscription-code-lists.index', compact('stats', 'courses', 'packages'));
    }

    /**
     * Show code list details
     */
    public function show(SubscriptionCodeList $list, Request $request)
    {
        $list->load(['course', 'package', 'creator']);

        // Handle DataTables AJAX request for codes in this list
        if ($request->ajax()) {
            $query = $list->codes()->with(['course', 'package']);

            return DataTables::of($query)
                ->addColumn('code_display', function ($code) {
                    return '<div class="font-mono font-bold text-lg text-gray-900">' . e($code->code) . '</div>';
                })
                ->addColumn('usage', function ($code) {
                    $percentage = $code->max_uses > 0 ? ($code->current_uses / $code->max_uses) * 100 : 0;
                    $color = $percentage >= 100 ? 'bg-red-500' : ($percentage >= 75 ? 'bg-orange-500' : 'bg-green-500');

                    return '<div class="space-y-1">
                                <div class="text-sm font-medium text-gray-900">' . $code->current_uses . ' / ' . $code->max_uses . '</div>
                                <div class="w-full bg-gray-200 rounded-full h-2">
                                    <div class="' . $color . ' h-2 rounded-full" style="width: ' . min($percentage, 100) . '%"></div>
                                </div>
                            </div>';
                })
                ->addColumn('status_badge', function ($code) {
                    if (!$code->is_active) {
                        return '<span class="px-3 py-1 text-xs font-semibold rounded-full bg-gray-100 text-gray-800">معطل</span>';
                    }

                    $isExpired = $code->expires_at && $code->expires_at->isPast();
                    $isFullyUsed = $code->current_uses >= $code->max_uses;

                    if ($isExpired) {
                        return '<span class="px-3 py-1 text-xs font-semibold rounded-full bg-red-100 text-red-800">منتهي</span>';
                    }

                    if ($isFullyUsed) {
                        return '<span class="px-3 py-1 text-xs font-semibold rounded-full bg-orange-100 text-orange-800">مستخدم بالكامل</span>';
                    }

                    return '<span class="px-3 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">نشط</span>';
                })
                ->addColumn('actions', function ($code) {
                    return '<a href="' . route('admin.subscription-codes.show', $code) . '"
                               class="px-3 py-1.5 bg-blue-50 hover:bg-blue-100 text-blue-600 rounded-lg text-sm font-medium transition-colors">
                                <i class="fas fa-eye"></i> عرض
                            </a>';
                })
                ->rawColumns(['code_display', 'usage', 'status_badge', 'actions'])
                ->make(true);
        }

        // Regular page load
        $stats = $this->listService->getListStatistics($list);

        return view('admin.subscription-code-lists.show', compact('list', 'stats'));
    }

    /**
     * Delete a code list
     */
    public function destroy(SubscriptionCodeList $list)
    {
        try {
            $this->listService->deleteList($list);

            return redirect()
                ->route('admin.subscription-code-lists.index')
                ->with('success', 'تم حذف القائمة بنجاح');
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }
}
