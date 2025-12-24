<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Sponsor;
use App\Models\AppSetting;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Yajra\DataTables\Facades\DataTables;

class SponsorController extends Controller
{
    /**
     * Display a listing of sponsors.
     */
    public function index(Request $request)
    {
        if ($request->ajax()) {
            return $this->getDataTable($request);
        }

        $stats = [
            'total' => Sponsor::count(),
            'active' => Sponsor::where('is_active', true)->count(),
            'inactive' => Sponsor::where('is_active', false)->count(),
            'total_clicks' => Sponsor::sum('click_count'),
        ];

        $sectionEnabled = AppSetting::isSponsorsEnabled();

        return view('admin.sponsors.index', compact('stats', 'sectionEnabled'));
    }

    /**
     * Get sponsors data for DataTables.
     */
    private function getDataTable(Request $request)
    {
        $query = Sponsor::query();

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
                        $q->where('name_ar', 'LIKE', "%{$searchValue}%")
                          ->orWhere('title', 'LIKE', "%{$searchValue}%")
                          ->orWhere('specialty', 'LIKE', "%{$searchValue}%");
                    });
                }
            })
            ->addColumn('sponsor_info', function ($sponsor) {
                $html = '<div class="flex items-center gap-3">';
                $html .= '<img src="' . $sponsor->photo_url . '" alt="' . $sponsor->name_ar . '" class="w-12 h-12 rounded-full object-cover border-2 border-purple-200">';
                $html .= '<div>';
                $html .= '<div class="font-bold text-gray-900">' . $sponsor->name_ar . '</div>';
                if ($sponsor->title) {
                    $html .= '<div class="text-sm text-gray-500">' . $sponsor->title . '</div>';
                }
                $html .= '</div></div>';
                return $html;
            })
            ->addColumn('specialty_badge', function ($sponsor) {
                if ($sponsor->specialty) {
                    return '<span class="px-3 py-1 text-xs font-medium rounded-full bg-purple-100 text-purple-700">' . $sponsor->specialty . '</span>';
                }
                return '<span class="text-gray-400">-</span>';
            })
            ->addColumn('click_count_display', function ($sponsor) {
                $formattedCount = $sponsor->formatted_click_count;
                return '<div class="flex items-center gap-2">
                    <i class="fas fa-mouse-pointer text-gray-400"></i>
                    <span class="font-semibold text-gray-700">' . $formattedCount . '</span>
                </div>';
            })
            ->addColumn('status_badge', function ($sponsor) {
                if ($sponsor->is_active) {
                    return '<span class="px-3 py-1 text-xs font-medium rounded-full bg-green-100 text-green-700">
                        <i class="fas fa-check-circle ml-1"></i> نشط
                    </span>';
                }
                return '<span class="px-3 py-1 text-xs font-medium rounded-full bg-red-100 text-red-700">
                    <i class="fas fa-times-circle ml-1"></i> معطل
                </span>';
            })
            ->addColumn('social_links_display', function ($sponsor) {
                $links = [];
                if ($sponsor->youtube_link) {
                    $links[] = '<span class="text-red-500" title="YouTube"><i class="fab fa-youtube"></i></span>';
                }
                if ($sponsor->facebook_link) {
                    $links[] = '<span class="text-blue-600" title="Facebook"><i class="fab fa-facebook"></i></span>';
                }
                if ($sponsor->instagram_link) {
                    $links[] = '<span class="text-pink-500" title="Instagram"><i class="fab fa-instagram"></i></span>';
                }
                if ($sponsor->telegram_link) {
                    $links[] = '<span class="text-blue-400" title="Telegram"><i class="fab fa-telegram"></i></span>';
                }
                if (empty($links)) {
                    return '<span class="text-gray-400">-</span>';
                }
                return '<div class="flex items-center gap-2">' . implode('', $links) . '</div>';
            })
            ->addColumn('actions', function ($sponsor) {
                return view('admin.sponsors.partials.actions', compact('sponsor'))->render();
            })
            ->rawColumns(['sponsor_info', 'specialty_badge', 'click_count_display', 'status_badge', 'social_links_display', 'actions'])
            ->make(true);
    }

    /**
     * Show the form for creating a new sponsor.
     */
    public function create()
    {
        return view('admin.sponsors.create');
    }

    /**
     * Store a newly created sponsor.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name_ar' => 'required|string|max:255',
            'photo' => 'nullable|image|mimes:jpeg,png,jpg,webp|max:2048',
            'photo_url' => 'required_without:photo|nullable|url|max:500',
            'external_link' => 'nullable|url|max:500',
            'youtube_link' => 'nullable|url|max:500',
            'facebook_link' => 'nullable|url|max:500',
            'instagram_link' => 'nullable|url|max:500',
            'telegram_link' => 'nullable|url|max:500',
            'title' => 'nullable|string|max:255',
            'specialty' => 'nullable|string|max:255',
            'display_order' => 'nullable|integer|min:0',
            'is_active' => 'boolean',
        ]);

        $validated['is_active'] = $request->has('is_active');
        $validated['display_order'] = $validated['display_order'] ?? Sponsor::max('display_order') + 1;

        // Handle photo upload
        if ($request->hasFile('photo')) {
            $path = $request->file('photo')->store('sponsors', 'public');
            $validated['photo_url'] = asset('storage/' . $path);
        }

        // Remove photo from validated data (it's not a model field)
        unset($validated['photo']);

        Sponsor::create($validated);

        return redirect()->route('admin.sponsors.index')
            ->with('success', 'تم إضافة الراعي بنجاح');
    }

    /**
     * Display the specified sponsor.
     */
    public function show(Sponsor $sponsor)
    {
        return view('admin.sponsors.show', compact('sponsor'));
    }

    /**
     * Show the form for editing the specified sponsor.
     */
    public function edit(Sponsor $sponsor)
    {
        return view('admin.sponsors.edit', compact('sponsor'));
    }

    /**
     * Update the specified sponsor.
     */
    public function update(Request $request, Sponsor $sponsor)
    {
        $validated = $request->validate([
            'name_ar' => 'required|string|max:255',
            'photo' => 'nullable|image|mimes:jpeg,png,jpg,webp|max:2048',
            'photo_url' => 'nullable|url|max:500',
            'external_link' => 'nullable|url|max:500',
            'youtube_link' => 'nullable|url|max:500',
            'facebook_link' => 'nullable|url|max:500',
            'instagram_link' => 'nullable|url|max:500',
            'telegram_link' => 'nullable|url|max:500',
            'title' => 'nullable|string|max:255',
            'specialty' => 'nullable|string|max:255',
            'display_order' => 'nullable|integer|min:0',
            'is_active' => 'boolean',
        ]);

        $validated['is_active'] = $request->has('is_active');

        // Handle photo upload
        if ($request->hasFile('photo')) {
            // Delete old photo if it's stored locally
            if ($sponsor->photo_url && str_contains($sponsor->photo_url, '/storage/sponsors/')) {
                $oldPath = 'sponsors/' . basename($sponsor->photo_url);
                if (Storage::disk('public')->exists($oldPath)) {
                    Storage::disk('public')->delete($oldPath);
                }
            }

            // Store new photo
            $path = $request->file('photo')->store('sponsors', 'public');
            $validated['photo_url'] = asset('storage/' . $path);
        } elseif (empty($validated['photo_url'])) {
            // Keep existing photo URL if no new photo and no URL provided
            unset($validated['photo_url']);
        }

        // Remove photo from validated data (it's not a model field)
        unset($validated['photo']);

        $sponsor->update($validated);

        return redirect()->route('admin.sponsors.index')
            ->with('success', 'تم تحديث الراعي بنجاح');
    }

    /**
     * Remove the specified sponsor.
     */
    public function destroy(Sponsor $sponsor)
    {
        $sponsor->delete();

        return redirect()->route('admin.sponsors.index')
            ->with('success', 'تم حذف الراعي بنجاح');
    }

    /**
     * Toggle sponsor active status.
     */
    public function toggleStatus(Sponsor $sponsor)
    {
        $sponsor->update(['is_active' => !$sponsor->is_active]);

        return response()->json([
            'success' => true,
            'message' => $sponsor->is_active ? 'تم تفعيل الراعي' : 'تم تعطيل الراعي',
            'is_active' => $sponsor->is_active,
        ]);
    }

    /**
     * Toggle sponsors section visibility.
     */
    public function toggleSection()
    {
        $newState = AppSetting::toggleSponsors();

        return response()->json([
            'success' => true,
            'message' => $newState ? 'تم تفعيل قسم الرعاة' : 'تم تعطيل قسم الرعاة',
            'enabled' => $newState,
        ]);
    }

    /**
     * Update display order via AJAX.
     */
    public function updateOrder(Request $request)
    {
        $request->validate([
            'sponsors' => 'required|array',
            'sponsors.*.id' => 'required|exists:sponsors,id',
            'sponsors.*.order' => 'required|integer|min:0',
        ]);

        foreach ($request->sponsors as $item) {
            Sponsor::where('id', $item['id'])->update(['display_order' => $item['order']]);
        }

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث الترتيب بنجاح',
        ]);
    }

    /**
     * Reset click count for a sponsor.
     */
    public function resetClicks(Sponsor $sponsor)
    {
        $sponsor->update([
            'click_count' => 0,
            'youtube_clicks' => 0,
            'facebook_clicks' => 0,
            'instagram_clicks' => 0,
            'telegram_clicks' => 0,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'تم إعادة تعيين عداد النقرات',
        ]);
    }
}
