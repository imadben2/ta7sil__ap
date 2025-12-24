<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Promo;
use App\Models\AppSetting;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Yajra\DataTables\Facades\DataTables;

class PromoController extends Controller
{
    /**
     * Available internal routes for promos in Flutter app.
     * Extracted from memo_app/lib/app_router.dart
     */
    public static function getAvailableRoutes(): array
    {
        return [
            // Main Navigation
            '/home' => 'الصفحة الرئيسية',
            '/dashboard' => 'لوحة التحكم (يحول للرئيسية)',

            // Courses
            '/courses' => 'جميع الدورات',
            '/subscriptions' => 'الاشتراكات والباقات',
            '/my-receipts' => 'إيصالاتي',

            // Content Library
            '/subjects-list' => 'قائمة المواد الدراسية',

            // BAC Archives
            '/bac-archives' => 'أرشيف البكالوريا',
            '/bac-archives-by-year' => 'أرشيف البكالوريا (حسب السنة)',
            '/bac-simulation' => 'محاكاة البكالوريا',
            '/bac-results' => 'نتائج البكالوريا',
            '/bac-performance' => 'أداء البكالوريا',

            // Quiz System
            '/quiz' => 'الكويزات والاختبارات',

            // Planner
            '/planner' => 'المخطط الذكي',
            '/planner/today' => 'المخطط - اليوم',
            '/planner/week' => 'المخطط - الأسبوع',
            '/planner/history' => 'سجل الجلسات',
            '/planner/subjects' => 'مواد المخطط',
            '/planner/exams' => 'اختبارات المخطط',
            '/planner/analytics' => 'تحليلات المخطط',
            '/planner/settings' => 'إعدادات المخطط',
            '/planner/wizard' => 'معالج إنشاء الجدول',

            // Profile & Settings
            '/profile' => 'الملف الشخصي',
            '/profile/edit' => 'تعديل الملف الشخصي',
            '/profile/settings' => 'الإعدادات',
            '/profile/settings/tab-order' => 'ترتيب التبويبات',
            '/profile/change-password' => 'تغيير كلمة المرور',

            // Notifications
            '/notifications' => 'الإشعارات',

            // Authentication (for special cases)
            '/onboarding' => 'شاشة الترحيب',
            '/auth/login' => 'تسجيل الدخول',
            '/auth/register' => 'إنشاء حساب',
            '/auth/academic-selection' => 'اختيار التخصص الأكاديمي',
        ];
    }

    /**
     * Display a listing of promos.
     */
    public function index(Request $request)
    {
        if ($request->ajax()) {
            return $this->getDataTable($request);
        }

        $stats = [
            'total' => Promo::count(),
            'active' => Promo::where('is_active', true)->count(),
            'inactive' => Promo::where('is_active', false)->count(),
            'total_clicks' => Promo::sum('click_count'),
        ];

        $sectionEnabled = AppSetting::isPromosEnabled();

        return view('admin.promos.index', compact('stats', 'sectionEnabled'));
    }

    /**
     * Get promos data for DataTables.
     */
    private function getDataTable(Request $request)
    {
        $query = Promo::query();

        // Filter by status
        if ($request->filled('status')) {
            if ($request->status === 'active') {
                $query->where('is_active', true);
            } elseif ($request->status === 'inactive') {
                $query->where('is_active', false);
            }
        }

        return DataTables::of($query)
            ->filter(function ($query) use ($request) {
                if ($request->has('search') && $request->search['value']) {
                    $searchValue = $request->search['value'];
                    $query->where(function ($q) use ($searchValue) {
                        $q->where('title', 'LIKE', "%{$searchValue}%")
                          ->orWhere('subtitle', 'LIKE', "%{$searchValue}%")
                          ->orWhere('badge', 'LIKE', "%{$searchValue}%");
                    });
                }
            })
            ->addColumn('promo_info', function ($promo) {
                $gradientColors = $promo->gradient_colors ?? ['#3B82F6', '#1D4ED8'];
                $gradient = "linear-gradient(135deg, {$gradientColors[0]}, {$gradientColors[1]})";

                $html = '<div class="flex items-center gap-3">';
                $html .= '<div class="w-12 h-12 rounded-xl flex items-center justify-center shadow-lg" style="background: ' . $gradient . '">';
                if ($promo->icon_name) {
                    $html .= '<i class="fas fa-' . $this->getIconClass($promo->icon_name) . ' text-white text-xl"></i>';
                } else {
                    $html .= '<i class="fas fa-bullhorn text-white text-xl"></i>';
                }
                $html .= '</div>';
                $html .= '<div>';
                $html .= '<div class="font-bold text-gray-900">' . e($promo->title) . '</div>';
                if ($promo->subtitle) {
                    $html .= '<div class="text-sm text-gray-500 truncate max-w-xs">' . e($promo->subtitle) . '</div>';
                }
                $html .= '</div></div>';
                return $html;
            })
            ->addColumn('badge_display', function ($promo) {
                if ($promo->badge) {
                    $gradientColors = $promo->gradient_colors ?? ['#3B82F6', '#1D4ED8'];
                    return '<span class="px-3 py-1 text-xs font-medium rounded-full text-white" style="background: ' . $gradientColors[0] . '">' . e($promo->badge) . '</span>';
                }
                return '<span class="text-gray-400">-</span>';
            })
            ->addColumn('action_display', function ($promo) {
                $typeLabels = [
                    'route' => '<span class="px-2 py-1 text-xs rounded bg-blue-100 text-blue-700">مسار</span>',
                    'url' => '<span class="px-2 py-1 text-xs rounded bg-green-100 text-green-700">رابط</span>',
                    'none' => '<span class="px-2 py-1 text-xs rounded bg-gray-100 text-gray-700">بدون</span>',
                ];
                $label = $typeLabels[$promo->action_type] ?? $typeLabels['none'];

                if ($promo->action_value) {
                    return $label . '<div class="text-xs text-gray-500 mt-1 truncate max-w-[150px]">' . e($promo->action_value) . '</div>';
                }
                return $label;
            })
            ->addColumn('click_count_display', function ($promo) {
                $formattedCount = $promo->formatted_click_count;
                return '<div class="flex items-center gap-2">
                    <i class="fas fa-mouse-pointer text-gray-400"></i>
                    <span class="font-semibold text-gray-700">' . $formattedCount . '</span>
                </div>';
            })
            ->addColumn('status_badge', function ($promo) {
                $isActive = $promo->isCurrentlyActive();
                if ($isActive) {
                    return '<span class="px-3 py-1 text-xs font-medium rounded-full bg-green-100 text-green-700">
                        <i class="fas fa-check-circle ml-1"></i> نشط
                    </span>';
                }

                if (!$promo->is_active) {
                    return '<span class="px-3 py-1 text-xs font-medium rounded-full bg-red-100 text-red-700">
                        <i class="fas fa-times-circle ml-1"></i> معطل
                    </span>';
                }

                // Active but outside date range
                return '<span class="px-3 py-1 text-xs font-medium rounded-full bg-yellow-100 text-yellow-700">
                    <i class="fas fa-clock ml-1"></i> مجدول
                </span>';
            })
            ->addColumn('date_range', function ($promo) {
                $html = '<div class="text-xs">';
                if ($promo->starts_at) {
                    $html .= '<div><span class="text-gray-500">من:</span> ' . $promo->starts_at->format('Y-m-d') . '</div>';
                }
                if ($promo->ends_at) {
                    $html .= '<div><span class="text-gray-500">إلى:</span> ' . $promo->ends_at->format('Y-m-d') . '</div>';
                }
                if (!$promo->starts_at && !$promo->ends_at) {
                    $html .= '<span class="text-gray-400">دائم</span>';
                }
                $html .= '</div>';
                return $html;
            })
            ->addColumn('actions', function ($promo) {
                return view('admin.promos.partials.actions', compact('promo'))->render();
            })
            ->rawColumns(['promo_info', 'badge_display', 'action_display', 'click_count_display', 'status_badge', 'date_range', 'actions'])
            ->make(true);
    }

    /**
     * Map icon names to Font Awesome classes.
     */
    private function getIconClass(string $iconName): string
    {
        $iconMap = [
            'school' => 'school',
            'emoji_events' => 'trophy',
            'assignment' => 'clipboard-list',
            'people' => 'users',
            'calendar_month' => 'calendar-alt',
            'celebration' => 'gift',
            'star' => 'star',
            'bolt' => 'bolt',
            'rocket' => 'rocket',
            'book' => 'book',
            'graduation-cap' => 'graduation-cap',
        ];

        return $iconMap[$iconName] ?? 'bullhorn';
    }

    /**
     * Show the form for creating a new promo.
     */
    public function create()
    {
        $availableRoutes = self::getAvailableRoutes();
        return view('admin.promos.create', compact('availableRoutes'));
    }

    /**
     * Store a newly created promo.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'subtitle' => 'nullable|string|max:500',
            'badge' => 'nullable|string|max:50',
            'action_text' => 'nullable|string|max:100',
            'icon_name' => 'nullable|string|max:50',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp|max:2048',
            'image_url' => 'nullable|url|max:500',
            'gradient_start' => 'nullable|string|max:20',
            'gradient_end' => 'nullable|string|max:20',
            'action_type' => 'required|in:route,url,none',
            'action_value' => 'nullable|string|max:500',
            'display_order' => 'nullable|integer|min:0',
            'is_active' => 'boolean',
            'starts_at' => 'nullable|date',
            'ends_at' => 'nullable|date|after_or_equal:starts_at',
            // Countdown fields
            'promo_type' => 'nullable|in:default,countdown',
            'target_date' => 'nullable|date|required_if:promo_type,countdown',
            'countdown_label' => 'nullable|string|max:100',
        ]);

        $validated['is_active'] = $request->has('is_active');
        $validated['promo_type'] = $validated['promo_type'] ?? 'default';

        // Countdown promos always have display_order 0 to appear first
        if ($validated['promo_type'] === 'countdown') {
            $validated['display_order'] = 0;
        } else {
            $validated['display_order'] = $validated['display_order'] ?? Promo::max('display_order') + 1;
        }

        // Handle image upload
        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('promos', 'public');
            $validated['image_url'] = asset('storage/' . $path);
        }
        unset($validated['image']);

        // Handle gradient colors
        if ($request->gradient_start && $request->gradient_end) {
            $validated['gradient_colors'] = [$request->gradient_start, $request->gradient_end];
        }
        unset($validated['gradient_start'], $validated['gradient_end']);

        Promo::create($validated);

        return redirect()->route('admin.promos.index')
            ->with('success', 'تم إضافة العرض الترويجي بنجاح');
    }

    /**
     * Display the specified promo.
     */
    public function show(Promo $promo)
    {
        return view('admin.promos.show', compact('promo'));
    }

    /**
     * Show the form for editing the specified promo.
     */
    public function edit(Promo $promo)
    {
        $availableRoutes = self::getAvailableRoutes();
        return view('admin.promos.edit', compact('promo', 'availableRoutes'));
    }

    /**
     * Update the specified promo.
     */
    public function update(Request $request, Promo $promo)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'subtitle' => 'nullable|string|max:500',
            'badge' => 'nullable|string|max:50',
            'action_text' => 'nullable|string|max:100',
            'icon_name' => 'nullable|string|max:50',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp|max:2048',
            'image_url' => 'nullable|url|max:500',
            'remove_image' => 'nullable|boolean',
            'gradient_start' => 'nullable|string|max:20',
            'gradient_end' => 'nullable|string|max:20',
            'action_type' => 'required|in:route,url,none',
            'action_value' => 'nullable|string|max:500',
            'display_order' => 'nullable|integer|min:0',
            'is_active' => 'boolean',
            'starts_at' => 'nullable|date',
            'ends_at' => 'nullable|date|after_or_equal:starts_at',
            // Countdown fields
            'promo_type' => 'nullable|in:default,countdown',
            'target_date' => 'nullable|date|required_if:promo_type,countdown',
            'countdown_label' => 'nullable|string|max:100',
        ]);

        $validated['is_active'] = $request->has('is_active');
        $validated['promo_type'] = $validated['promo_type'] ?? 'default';

        // Countdown promos always have display_order 0 to appear first
        if ($validated['promo_type'] === 'countdown') {
            $validated['display_order'] = 0;
        }

        // Handle image upload
        if ($request->hasFile('image')) {
            // Delete old image if it's stored locally
            if ($promo->image_url && str_contains($promo->image_url, '/storage/promos/')) {
                $oldPath = 'promos/' . basename($promo->image_url);
                if (Storage::disk('public')->exists($oldPath)) {
                    Storage::disk('public')->delete($oldPath);
                }
            }

            // Store new image
            $path = $request->file('image')->store('promos', 'public');
            $validated['image_url'] = asset('storage/' . $path);
        } elseif ($request->has('remove_image') && $request->remove_image) {
            // Remove existing image
            if ($promo->image_url && str_contains($promo->image_url, '/storage/promos/')) {
                $oldPath = 'promos/' . basename($promo->image_url);
                if (Storage::disk('public')->exists($oldPath)) {
                    Storage::disk('public')->delete($oldPath);
                }
            }
            $validated['image_url'] = null;
        } elseif (empty($validated['image_url'])) {
            // Keep existing image URL if no new image and no URL provided
            unset($validated['image_url']);
        }
        unset($validated['image'], $validated['remove_image']);

        // Handle gradient colors
        if ($request->gradient_start && $request->gradient_end) {
            $validated['gradient_colors'] = [$request->gradient_start, $request->gradient_end];
        }
        unset($validated['gradient_start'], $validated['gradient_end']);

        $promo->update($validated);

        return redirect()->route('admin.promos.index')
            ->with('success', 'تم تحديث العرض الترويجي بنجاح');
    }

    /**
     * Remove the specified promo.
     */
    public function destroy(Promo $promo)
    {
        $promo->delete();

        return redirect()->route('admin.promos.index')
            ->with('success', 'تم حذف العرض الترويجي بنجاح');
    }

    /**
     * Toggle promo active status.
     */
    public function toggleStatus(Promo $promo)
    {
        $promo->update(['is_active' => !$promo->is_active]);

        return response()->json([
            'success' => true,
            'message' => $promo->is_active ? 'تم تفعيل العرض' : 'تم تعطيل العرض',
            'is_active' => $promo->is_active,
        ]);
    }

    /**
     * Toggle promos section visibility.
     */
    public function toggleSection()
    {
        $newState = AppSetting::togglePromos();

        return response()->json([
            'success' => true,
            'message' => $newState ? 'تم تفعيل قسم العروض الترويجية' : 'تم تعطيل قسم العروض الترويجية',
            'enabled' => $newState,
        ]);
    }

    /**
     * Update display order via AJAX.
     */
    public function updateOrder(Request $request)
    {
        $request->validate([
            'promos' => 'required|array',
            'promos.*.id' => 'required|exists:promos,id',
            'promos.*.order' => 'required|integer|min:0',
        ]);

        foreach ($request->promos as $item) {
            Promo::where('id', $item['id'])->update(['display_order' => $item['order']]);
        }

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث الترتيب بنجاح',
        ]);
    }

    /**
     * Reset click count for a promo.
     */
    public function resetClicks(Promo $promo)
    {
        $promo->update(['click_count' => 0]);

        return response()->json([
            'success' => true,
            'message' => 'تم إعادة تعيين عداد النقرات',
        ]);
    }
}
