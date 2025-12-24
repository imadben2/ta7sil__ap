<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\SubscriptionCode;
use App\Models\Course;
use App\Models\SubscriptionPackage;
use App\Services\CodeGenerationService;
use App\Services\CodeListService;
use App\Exports\SubscriptionCodeListsExport;
use App\Exports\SubscriptionCodesDetailedExport;
use App\Exports\SubscriptionCodesByListExport;
use App\Models\SubscriptionCodeList;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;
use Yajra\DataTables\Facades\DataTables;
use Maatwebsite\Excel\Facades\Excel;

class SubscriptionCodeController extends Controller
{
    protected CodeGenerationService $codeService;
    protected CodeListService $listService;

    public function __construct(CodeGenerationService $codeService, CodeListService $listService)
    {
        $this->codeService = $codeService;
        $this->listService = $listService;
    }

    /**
     * Display codes list
     */
    public function index(Request $request)
    {
        // Handle DataTables AJAX request
        if ($request->ajax()) {
            $query = SubscriptionCode::with(['course', 'package', 'creator']);

            // Filter by code type
            if ($request->filled('code_type')) {
                $query->where('code_type', $request->code_type);
            }

            // Filter by course
            if ($request->filled('course_id')) {
                $query->where('course_id', $request->course_id);
            }

            // Filter by package
            if ($request->filled('package_id')) {
                $query->where('package_id', $request->package_id);
            }

            // Filter by active status
            if ($request->filled('is_active')) {
                $query->where('is_active', $request->is_active);
            }

            // Filter by validity
            if ($request->filled('validity')) {
                if ($request->validity === 'valid') {
                    $query->where('is_active', true)
                        ->where(function ($q) {
                            $q->whereNull('expires_at')
                              ->orWhere('expires_at', '>', now());
                        })
                        ->whereRaw('current_uses < max_uses');
                } elseif ($request->validity === 'expired') {
                    $query->where('expires_at', '<=', now());
                } elseif ($request->validity === 'fully_used') {
                    $query->whereRaw('current_uses >= max_uses');
                }
            }

            return DataTables::of($query)
                ->addColumn('code_display', function ($code) {
                    return '<div class="font-mono font-bold text-lg text-gray-900">' . e($code->code) . '</div>';
                })
                ->addColumn('type_badge', function ($code) {
                    $typeColors = [
                        'single_course' => 'bg-blue-100 text-blue-800',
                        'package' => 'bg-purple-100 text-purple-800',
                        'general' => 'bg-green-100 text-green-800',
                    ];
                    $typeIcons = [
                        'single_course' => 'fa-video',
                        'package' => 'fa-box',
                        'general' => 'fa-star',
                    ];
                    $typeLabels = [
                        'single_course' => 'دورة واحدة',
                        'package' => 'باقة',
                        'general' => 'عام',
                    ];

                    $color = $typeColors[$code->code_type] ?? 'bg-gray-100 text-gray-800';
                    $icon = $typeIcons[$code->code_type] ?? 'fa-question';
                    $label = $typeLabels[$code->code_type] ?? $code->code_type;

                    return '<span class="px-3 py-1 inline-flex items-center gap-1 text-xs font-semibold rounded-full ' . $color . '">
                                <i class="fas ' . $icon . '"></i>
                                ' . $label . '
                            </span>';
                })
                ->addColumn('item', function ($code) {
                    if ($code->course) {
                        return '<div class="flex items-center gap-2">
                                    <i class="fas fa-video text-blue-500"></i>
                                    <span class="text-sm">' . e($code->course->title_ar) . '</span>
                                </div>';
                    } elseif ($code->package) {
                        return '<div class="flex items-center gap-2">
                                    <i class="fas fa-box text-purple-500"></i>
                                    <span class="text-sm">' . e($code->package->name_ar) . '</span>
                                </div>';
                    }
                    return '<span class="text-gray-500 text-sm">جميع المحتويات</span>';
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
                ->addColumn('expiry', function ($code) {
                    if (!$code->expires_at) {
                        return '<span class="text-sm text-gray-600">غير محدد</span>';
                    }

                    $isExpired = $code->expires_at->isPast();
                    $color = $isExpired ? 'text-red-600' : 'text-gray-600';

                    return '<div class="text-sm ' . $color . '">' .
                           $code->expires_at->format('Y-m-d') .
                           '</div>';
                })
                ->addColumn('status_badge', function ($code) {
                    if (!$code->is_active) {
                        return '<span class="px-3 py-1 inline-flex items-center gap-1 text-xs font-semibold rounded-full bg-gray-100 text-gray-800">
                                    <i class="fas fa-ban"></i>
                                    معطل
                                </span>';
                    }

                    $isExpired = $code->expires_at && $code->expires_at->isPast();
                    $isFullyUsed = $code->current_uses >= $code->max_uses;

                    if ($isExpired) {
                        return '<span class="px-3 py-1 inline-flex items-center gap-1 text-xs font-semibold rounded-full bg-red-100 text-red-800">
                                    <i class="fas fa-clock"></i>
                                    منتهي
                                </span>';
                    }

                    if ($isFullyUsed) {
                        return '<span class="px-3 py-1 inline-flex items-center gap-1 text-xs font-semibold rounded-full bg-orange-100 text-orange-800">
                                    <i class="fas fa-check-circle"></i>
                                    مستخدم بالكامل
                                </span>';
                    }

                    return '<span class="px-3 py-1 inline-flex items-center gap-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">
                                <i class="fas fa-check"></i>
                                نشط
                            </span>';
                })
                ->addColumn('actions', function ($code) {
                    $actions = '<div class="flex gap-2">';

                    // View button
                    $actions .= '<a href="' . route('admin.subscription-codes.show', $code) . '"
                                    class="px-3 py-1.5 bg-blue-50 hover:bg-blue-100 text-blue-600 rounded-lg text-sm font-medium transition-colors flex items-center gap-1">
                                    <i class="fas fa-eye"></i>
                                    عرض
                                 </a>';

                    // Toggle active/inactive
                    if ($code->is_active) {
                        $actions .= '<form action="' . route('admin.subscription-codes.deactivate', $code) . '" method="POST" class="inline">
                                        ' . csrf_field() . '
                                        <button type="submit" class="px-3 py-1.5 bg-red-50 hover:bg-red-100 text-red-600 rounded-lg text-sm font-medium transition-colors flex items-center gap-1">
                                            <i class="fas fa-ban"></i>
                                            تعطيل
                                        </button>
                                     </form>';
                    } else {
                        $actions .= '<form action="' . route('admin.subscription-codes.activate', $code) . '" method="POST" class="inline">
                                        ' . csrf_field() . '
                                        <button type="submit" class="px-3 py-1.5 bg-green-50 hover:bg-green-100 text-green-600 rounded-lg text-sm font-medium transition-colors flex items-center gap-1">
                                            <i class="fas fa-check"></i>
                                            تفعيل
                                        </button>
                                     </form>';
                    }

                    $actions .= '</div>';
                    return $actions;
                })
                ->rawColumns(['code_display', 'type_badge', 'item', 'usage', 'expiry', 'status_badge', 'actions'])
                ->make(true);
        }

        // Regular page load - return view with filter data and stats
        $stats = [
            'total' => SubscriptionCode::count(),
            'active' => SubscriptionCode::where('is_active', true)->count(),
            'expired' => SubscriptionCode::where('expires_at', '<=', now())->count(),
            'fully_used' => SubscriptionCode::whereRaw('current_uses >= max_uses')->count(),
        ];

        $courses = Course::orderBy('title_ar')->get();
        $packages = SubscriptionPackage::orderBy('name_ar')->get();

        return view('admin.subscription-codes.index', compact('stats', 'courses', 'packages'));
    }

    /**
     * Show codes grouped by list name
     */
    public function byList(Request $request)
    {
        // Handle DataTables AJAX request
        if ($request->ajax()) {
            $query = \App\Models\SubscriptionCodeList::with(['course', 'package', 'creator'])
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

            // Filter by code type
            if ($request->filled('code_type')) {
                $query->where('code_type', $request->code_type);
            }

            // Filter by course
            if ($request->filled('course_id')) {
                $query->where('course_id', $request->course_id);
            }

            // Filter by package
            if ($request->filled('package_id')) {
                $query->where('package_id', $request->package_id);
            }

            return DataTables::of($query)
                ->addColumn('list_name', function ($list) {
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
                                <div class="text-orange-600">' . $list->used_codes_count . ' مستخدم</div>
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
                                <a href="' . route('admin.subscription-codes.export-list', $list) . '"
                                   class="px-3 py-1.5 bg-green-50 hover:bg-green-100 text-green-600 rounded-lg text-sm font-medium transition-colors flex items-center gap-1">
                                    <i class="fas fa-file-excel"></i>
                                    تصدير
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
                ->rawColumns(['list_name', 'type_badge', 'item', 'stats', 'revenue', 'created', 'actions'])
                ->make(true);
        }

        // Regular page load
        $courses = Course::orderBy('title_ar')->get();
        $packages = SubscriptionPackage::orderBy('name_ar')->get();

        $stats = [
            'total_lists' => \App\Models\SubscriptionCodeList::count(),
            'total_codes' => SubscriptionCode::whereNotNull('list_id')->count(),
        ];

        return view('admin.subscription-codes.by-list', compact('courses', 'packages', 'stats'));
    }

    /**
     * Show create code form
     */
    public function create()
    {
        $courses = Course::where('is_published', true)->orderBy('title_ar')->get();
        $packages = SubscriptionPackage::where('is_active', true)->orderBy('name_ar')->get();

        return view('admin.subscription-codes.create', compact('courses', 'packages'));
    }

    /**
     * Store new code(s)
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'code_type' => 'required|in:single_course,package,general',
            'course_id' => 'required_if:code_type,single_course|nullable|exists:courses,id',
            'package_id' => 'required_if:code_type,package|nullable|exists:subscription_packages,id',
            'quantity' => 'required|integer|min:1|max:1000',
            'max_uses_per_code' => 'required|integer|min:1',
            'expires_at' => 'nullable|date|after:now',
            'custom_code' => 'nullable|string|max:50',
            'list_name' => 'required|string|max:255',
        ]);

        try {
            $expiresAt = $validated['expires_at'] ? Carbon::parse($validated['expires_at']) : null;
            $quantity = $validated['quantity'];
            $maxUses = $validated['max_uses_per_code'];
            $user = Auth::user();

            // Create a code list (list_name is now required)
            $course = $validated['code_type'] === 'single_course'
                ? Course::findOrFail($validated['course_id'])
                : null;
            $package = $validated['code_type'] === 'package'
                ? SubscriptionPackage::findOrFail($validated['package_id'])
                : null;

            $list = $this->listService->createCodeList(
                $validated['list_name'],
                $validated['code_type'],
                $user,
                $quantity,
                $maxUses,
                $expiresAt,
                $course,
                $package
            );

            return redirect()
                ->route('admin.subscription-code-lists.show', $list)
                ->with('success', "تم إنشاء قائمة '{$list->name}' بـ {$quantity} أكواد");

        } catch (\Exception $e) {
            return back()
                ->withInput()
                ->with('error', 'حدث خطأ أثناء إنشاء الرموز: ' . $e->getMessage());
        }
    }

    /**
     * Show code details
     */
    public function show(SubscriptionCode $code)
    {
        $code->load(['course', 'package', 'creator', 'userSubscriptions.user', 'userSubscriptions.course']);
        $stats = $this->codeService->getCodeStatistics($code);

        return view('admin.subscription-codes.show', compact('code', 'stats'));
    }

    /**
     * Deactivate code
     */
    public function deactivate(SubscriptionCode $code)
    {
        try {
            $this->codeService->deactivateCode($code);

            return back()->with('success', 'تم تعطيل الرمز بنجاح');
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Activate code
     */
    public function activate(SubscriptionCode $code)
    {
        try {
            $this->codeService->activateCode($code);

            return back()->with('success', 'تم تفعيل الرمز بنجاح');
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Delete code
     */
    public function destroy(SubscriptionCode $code)
    {
        try {
            $this->codeService->deleteCode($code);

            return redirect()
                ->route('admin.subscription-codes.index')
                ->with('success', 'تم حذف الرمز بنجاح');
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Extend expiration date
     */
    public function extendExpiration(Request $request, SubscriptionCode $code)
    {
        $validated = $request->validate([
            'new_expires_at' => 'required|date|after:now',
        ]);

        try {
            $this->codeService->extendCodeExpiration($code, Carbon::parse($validated['new_expires_at']));

            return back()->with('success', 'تم تمديد صلاحية الرمز بنجاح');
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Increase max uses
     */
    public function increaseMaxUses(Request $request, SubscriptionCode $code)
    {
        $validated = $request->validate([
            'additional_uses' => 'required|integer|min:1',
        ]);

        try {
            $this->codeService->increaseCodeMaxUses($code, $validated['additional_uses']);

            return back()->with('success', 'تم زيادة عدد الاستخدامات بنجاح');
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Export codes to CSV
     */
    public function export(Request $request)
    {
        try {
            $codes = SubscriptionCode::with(['course', 'package'])->get();
            $csv = $this->codeService->exportCodesToCSV($codes);

            return response($csv, 200)
                ->header('Content-Type', 'text/csv')
                ->header('Content-Disposition', 'attachment; filename="subscription-codes-' . now()->format('Y-m-d') . '.csv"');
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ أثناء التصدير: ' . $e->getMessage());
        }
    }

    /**
     * Bulk deactivate expired codes
     */
    public function deactivateExpired()
    {
        try {
            $count = $this->codeService->deactivateExpiredCodes();

            return back()->with('success', "تم تعطيل {$count} رمز منتهي الصلاحية");
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Validate code (AJAX)
     */
    public function validate(Request $request)
    {
        $validated = $request->validate([
            'code' => 'required|string',
        ]);

        try {
            $result = $this->codeService->validateCode($validated['code']);

            return response()->json($result);
        } catch (\Exception $e) {
            return response()->json([
                'valid' => false,
                'message' => 'حدث خطأ: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Export code lists summary to Excel
     */
    public function exportByListSummary(Request $request)
    {
        $filters = [
            'code_type' => $request->input('code_type'),
            'course_id' => $request->input('course_id'),
            'package_id' => $request->input('package_id'),
        ];

        $filename = 'subscription_code_lists_summary_' . now()->format('Y-m-d_H-i-s') . '.xlsx';

        return Excel::download(new SubscriptionCodeListsExport($filters), $filename);
    }

    /**
     * Export detailed codes by list to Excel
     */
    public function exportByListDetailed(Request $request)
    {
        $filters = [
            'code_type' => $request->input('code_type'),
            'course_id' => $request->input('course_id'),
            'package_id' => $request->input('package_id'),
        ];

        $filename = 'subscription_codes_detailed_' . now()->format('Y-m-d_H-i-s') . '.xlsx';

        return Excel::download(new SubscriptionCodesDetailedExport($filters), $filename);
    }

    /**
     * Export codes for a specific list to Excel
     */
    public function exportList(SubscriptionCodeList $list)
    {
        $list->load(['course', 'package']);

        // Clean filename
        $listName = preg_replace('/[^A-Za-z0-9\-_]/', '_', $list->name);
        $filename = 'codes_' . $listName . '_' . now()->format('Y-m-d_H-i-s') . '.xlsx';

        return Excel::download(new SubscriptionCodesByListExport($list), $filename);
    }
}
