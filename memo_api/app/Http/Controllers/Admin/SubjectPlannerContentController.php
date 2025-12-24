<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\SubjectPlannerContent;
use App\Models\AcademicPhase;
use App\Models\AcademicYear;
use App\Models\AcademicStream;
use App\Models\Subject;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Yajra\DataTables\Facades\DataTables;

class SubjectPlannerContentController extends Controller
{
    /**
     * Level labels in Arabic
     */
    protected $levelLabels = [
        'learning_axis' => 'محور تعلمي',
        'unit' => 'وحدة',
        'topic' => 'موضوع',
        'subtopic' => 'موضوع فرعي',
        'learning_objective' => 'هدف تعلمي',
    ];

    /**
     * Level colors for badges
     */
    protected $levelColors = [
        'learning_axis' => 'blue',
        'unit' => 'green',
        'topic' => 'yellow',
        'subtopic' => 'orange',
        'learning_objective' => 'purple',
    ];

    /**
     * Display a listing of subject planner content (flat view with DataTables).
     */
    public function index(Request $request)
    {
        if ($request->ajax()) {
            return $this->getDataTable($request);
        }

        $phases = AcademicPhase::where('is_active', true)->orderBy('order')->get();
        $levels = $this->levelLabels;

        return view('admin.subject-planner-content.index', compact('phases', 'levels'));
    }

    /**
     * Get data for DataTables.
     */
    private function getDataTable(Request $request)
    {
        $query = SubjectPlannerContent::with(['academicPhase', 'academicYear', 'subject', 'parent'])
            ->withCount('children');

        // Filter by phase
        if ($request->filled('phase_id')) {
            $query->where('academic_phase_id', $request->phase_id);
        }

        // Filter by year
        if ($request->filled('year_id')) {
            $query->where('academic_year_id', $request->year_id);
        }

        // Filter by stream (JSON array)
        if ($request->filled('stream_id')) {
            $query->whereJsonContains('academic_stream_ids', (int) $request->stream_id);
        }

        // Filter by subject
        if ($request->filled('subject_id')) {
            $query->where('subject_id', $request->subject_id);
        }

        // Filter by level
        if ($request->filled('level')) {
            $query->where('level', $request->level);
        }

        // Filter by BAC priority
        if ($request->filled('bac_priority')) {
            $query->where('is_bac_priority', $request->bac_priority === '1');
        }

        // Filter by status
        if ($request->filled('status')) {
            if ($request->status === 'published') {
                $query->where('is_published', true);
            } elseif ($request->status === 'draft') {
                $query->where('is_published', false);
            } elseif ($request->status === 'active') {
                $query->where('is_active', true);
            } elseif ($request->status === 'inactive') {
                $query->where('is_active', false);
            }
        }

        return DataTables::of($query)
            ->filter(function ($query) use ($request) {
                if ($request->has('search') && $request->search['value']) {
                    $searchValue = $request->search['value'];
                    $query->where(function($q) use ($searchValue) {
                        $q->where('title_ar', 'LIKE', "%{$searchValue}%")
                          ->orWhere('code', 'LIKE', "%{$searchValue}%")
                          ->orWhere('description_ar', 'LIKE', "%{$searchValue}%");
                    });
                }
            })
            ->addColumn('checkbox', function ($content) {
                return '<input type="checkbox" class="row-checkbox" value="' . $content->id . '">';
            })
            ->addColumn('title_info', function ($content) {
                $html = '<div>';
                $html .= '<div class="font-medium text-gray-900">' . e($content->title_ar) . '</div>';
                if ($content->code) {
                    $html .= '<div class="text-xs text-gray-500 mt-1">' . e($content->code) . '</div>';
                }
                if ($content->parent) {
                    $html .= '<div class="text-xs text-blue-600 mt-1"><i class="fas fa-level-up-alt mr-1"></i>' . e($content->parent->title_ar) . '</div>';
                }
                $html .= '</div>';
                return $html;
            })
            ->addColumn('level_badge', function ($content) {
                $color = $this->levelColors[$content->level] ?? 'gray';
                $label = $this->levelLabels[$content->level] ?? $content->level;
                $colorClasses = [
                    'blue' => 'bg-blue-100 text-blue-800',
                    'green' => 'bg-green-100 text-green-800',
                    'yellow' => 'bg-yellow-100 text-yellow-800',
                    'orange' => 'bg-orange-100 text-orange-800',
                    'purple' => 'bg-purple-100 text-purple-800',
                    'gray' => 'bg-gray-100 text-gray-800',
                ];
                return '<span class="px-2 py-1 text-xs rounded-full ' . $colorClasses[$color] . '">' . $label . '</span>';
            })
            ->addColumn('subject_info', function ($content) {
                if ($content->subject) {
                    return '<div class="text-sm">' .
                           '<div class="font-medium">' . e($content->subject->name_ar) . '</div>' .
                           '</div>';
                }
                return '<span class="text-gray-400">-</span>';
            })
            ->addColumn('bac_priority_badge', function ($content) {
                if ($content->is_bac_priority) {
                    return '<span class="px-2 py-1 text-xs rounded-full bg-red-100 text-red-800 font-semibold">' .
                           '<i class="fas fa-star mr-1"></i>أولوية' .
                           '</span>';
                }
                return '<span class="text-gray-400">-</span>';
            })
            ->addColumn('status_badges', function ($content) {
                $html = '<div class="flex flex-col gap-1">';

                // Published status
                if ($content->is_published) {
                    $html .= '<span class="px-2 py-1 text-xs rounded-full bg-green-100 text-green-800">منشور</span>';
                } else {
                    $html .= '<span class="px-2 py-1 text-xs rounded-full bg-gray-100 text-gray-800">مسودة</span>';
                }

                // Active status
                if (!$content->is_active) {
                    $html .= '<span class="px-2 py-1 text-xs rounded-full bg-red-100 text-red-800">غير نشط</span>';
                }

                $html .= '</div>';
                return $html;
            })
            ->addColumn('children_count', function ($content) {
                if ($content->children_count > 0) {
                    return '<span class="px-2 py-1 text-xs rounded-full bg-blue-100 text-blue-800">' . $content->children_count . '</span>';
                }
                return '<span class="text-gray-400">0</span>';
            })
            ->addColumn('actions', function ($content) {
                return view('admin.subject-planner-content.partials.actions', compact('content'))->render();
            })
            ->rawColumns(['checkbox', 'title_info', 'level_badge', 'subject_info', 'bac_priority_badge', 'status_badges', 'children_count', 'actions'])
            ->make(true);
    }

    /**
     * Display the tree view of subject planner content.
     */
    public function tree(Request $request)
    {
        $phases = AcademicPhase::where('is_active', true)->orderBy('order')->get();
        $levels = $this->levelLabels;
        $levelColors = $this->levelColors;

        // Get root items (no parent) with filters
        $query = SubjectPlannerContent::with(['subject', 'children'])
            ->whereNull('parent_id')
            ->orderBy('order');

        // Cascading filters: Phase -> Year -> Stream -> Subject
        if ($request->filled('phase_id')) {
            $query->where('academic_phase_id', $request->phase_id);
        }
        if ($request->filled('year_id')) {
            $query->where('academic_year_id', $request->year_id);
        }
        if ($request->filled('stream_id')) {
            $query->whereJsonContains('academic_stream_ids', (int) $request->stream_id);
        }
        if ($request->filled('subject_id')) {
            $query->where('subject_id', $request->subject_id);
        }

        $rootItems = $query->get();

        return view('admin.subject-planner-content.tree', compact('phases', 'levels', 'levelColors', 'rootItems'));
    }

    /**
     * Show the form for creating a new content item.
     */
    public function create(Request $request)
    {
        $phases = AcademicPhase::where('is_active', true)->orderBy('order')->get();
        $levels = $this->levelLabels;

        // Pre-fill parent if specified
        $parentId = $request->get('parent_id');
        $parent = null;
        if ($parentId) {
            $parent = SubjectPlannerContent::with(['academicPhase', 'academicYear', 'subject'])->find($parentId);
        }

        return view('admin.subject-planner-content.create', compact('phases', 'levels', 'parent'));
    }

    /**
     * Store a newly created content item.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'academic_phase_id' => 'required|exists:academic_phases,id',
            'academic_year_id' => 'required|exists:academic_years,id',
            'academic_stream_ids' => 'nullable|array',
            'academic_stream_ids.*' => 'exists:academic_streams,id',
            'subject_id' => 'required|exists:subjects,id',
            'parent_id' => 'nullable|exists:subject_planner_content,id',
            'level' => 'required|in:learning_axis,unit,topic,subtopic,learning_objective',
            'code' => 'nullable|string|max:50',
            'title_ar' => 'required|string|max:255',
            'description_ar' => 'nullable|string',
            'order' => 'nullable|integer|min:0',
            'content_type' => 'nullable|in:theory,exercise,review,memorization,practice,exam_prep',
            'difficulty_level' => 'nullable|in:easy,medium,hard',
            'estimated_duration_minutes' => 'nullable|integer|min:1',
            'requires_understanding' => 'boolean',
            'requires_review' => 'boolean',
            'requires_theory_practice' => 'boolean',
            'requires_exercise_practice' => 'boolean',
            'learning_objectives' => 'nullable|array',
            'competencies' => 'nullable|array',
            'prerequisites' => 'nullable|array',
            'bac_exam_years' => 'nullable|array',
            'is_bac_priority' => 'boolean',
            'bac_frequency' => 'nullable|integer|min:0',
            'is_active' => 'boolean',
            'is_published' => 'boolean',
        ]);

        // Set defaults
        $validated['requires_understanding'] = $request->has('requires_understanding');
        $validated['requires_review'] = $request->has('requires_review');
        $validated['requires_theory_practice'] = $request->has('requires_theory_practice');
        $validated['requires_exercise_practice'] = $request->has('requires_exercise_practice');
        $validated['is_bac_priority'] = $request->has('is_bac_priority');
        $validated['is_active'] = $request->has('is_active');
        $validated['is_published'] = $request->has('is_published');
        $validated['order'] = $validated['order'] ?? 0;
        $validated['created_by'] = Auth::id();
        $validated['updated_by'] = Auth::id();

        if ($validated['is_published']) {
            $validated['published_at'] = now();
        }

        SubjectPlannerContent::create($validated);

        return redirect()->route('admin.subject-planner-content.index')
            ->with('success', 'تم إضافة المحتوى بنجاح');
    }

    /**
     * Display the specified content item.
     */
    public function show(Request $request, SubjectPlannerContent $content)
    {
        // Handle AJAX request for children DataTable
        if ($request->ajax()) {
            return $this->getChildrenDataTable($content);
        }

        $content->load([
            'academicPhase',
            'academicYear',
            'subject',
            'parent',
            'children' => function($q) {
                $q->orderBy('order');
            },
            'creator',
            'updater',
        ]);

        $levels = $this->levelLabels;
        $levelColors = $this->levelColors;

        // Get breadcrumb path
        $breadcrumb = [];
        $current = $content;
        while ($current) {
            array_unshift($breadcrumb, $current);
            $current = $current->parent;
        }

        // Calculate statistics
        $stats = [
            'children_count' => $content->children()->count(),
            'descendants_count' => $this->countDescendants($content),
            'user_progress_count' => $content->userProgress()->count(),
        ];

        return view('admin.subject-planner-content.show', compact('content', 'levels', 'levelColors', 'breadcrumb', 'stats'));
    }

    /**
     * Get children data for DataTable.
     */
    private function getChildrenDataTable(SubjectPlannerContent $content)
    {
        $query = $content->children()->with(['subject'])->withCount('children');

        return DataTables::of($query)
            ->addColumn('title_info', function ($child) {
                $html = '<div>';
                $html .= '<div class="font-medium text-gray-900">' . e($child->title_ar) . '</div>';
                if ($child->code) {
                    $html .= '<div class="text-xs text-gray-500 mt-1">' . e($child->code) . '</div>';
                }
                $html .= '</div>';
                return $html;
            })
            ->addColumn('level_badge', function ($child) {
                $color = $this->levelColors[$child->level] ?? 'gray';
                $label = $this->levelLabels[$child->level] ?? $child->level;
                $colorClasses = [
                    'blue' => 'bg-blue-100 text-blue-800',
                    'green' => 'bg-green-100 text-green-800',
                    'yellow' => 'bg-yellow-100 text-yellow-800',
                    'orange' => 'bg-orange-100 text-orange-800',
                    'purple' => 'bg-purple-100 text-purple-800',
                    'gray' => 'bg-gray-100 text-gray-800',
                ];
                return '<span class="px-2 py-1 text-xs rounded-full ' . $colorClasses[$color] . '">' . $label . '</span>';
            })
            ->addColumn('status_badge', function ($child) {
                if ($child->is_published) {
                    return '<span class="px-2 py-1 text-xs rounded-full bg-green-100 text-green-800">منشور</span>';
                }
                return '<span class="px-2 py-1 text-xs rounded-full bg-gray-100 text-gray-800">مسودة</span>';
            })
            ->addColumn('children_count', function ($child) {
                return $child->children_count ?? 0;
            })
            ->addColumn('actions', function ($child) {
                return view('admin.subject-planner-content.partials.actions', ['content' => $child])->render();
            })
            ->rawColumns(['title_info', 'level_badge', 'status_badge', 'actions'])
            ->make(true);
    }

    /**
     * Count all descendants recursively.
     */
    private function countDescendants(SubjectPlannerContent $content): int
    {
        $count = $content->children()->count();
        foreach ($content->children as $child) {
            $count += $this->countDescendants($child);
        }
        return $count;
    }

    /**
     * Show the form for editing the specified content item.
     */
    public function edit(SubjectPlannerContent $content)
    {
        $content->load(['academicPhase', 'academicYear', 'subject', 'parent']);

        $phases = AcademicPhase::where('is_active', true)->orderBy('order')->get();
        $years = AcademicYear::where('academic_phase_id', $content->academic_phase_id)
            ->where('is_active', true)
            ->orderBy('order')
            ->get();
        $streams = AcademicStream::where('academic_year_id', $content->academic_year_id)
            ->where('is_active', true)
            ->orderBy('order')
            ->get();

        // Get subjects based on academic_stream_ids
        $streamIds = $content->academic_stream_ids ?? [];
        $subjects = Subject::where(function($q) use ($streamIds, $content) {
            if (!empty($streamIds)) {
                $q->whereIn('academic_stream_id', $streamIds);
            }
            $q->orWhere('academic_year_id', $content->academic_year_id);
        })->where('is_active', true)->orderBy('name_ar')->get();

        // Get potential parents (same subject, exclude self and descendants)
        $potentialParents = SubjectPlannerContent::where('subject_id', $content->subject_id)
            ->where('id', '!=', $content->id)
            ->whereNotIn('id', $this->getDescendantIds($content))
            ->orderBy('order')
            ->get();

        $levels = $this->levelLabels;

        return view('admin.subject-planner-content.edit', compact(
            'content', 'phases', 'years', 'streams', 'subjects', 'potentialParents', 'levels'
        ));
    }

    /**
     * Get all descendant IDs for a content item.
     */
    private function getDescendantIds(SubjectPlannerContent $content): array
    {
        $ids = [];
        foreach ($content->children as $child) {
            $ids[] = $child->id;
            $ids = array_merge($ids, $this->getDescendantIds($child));
        }
        return $ids;
    }

    /**
     * Update the specified content item.
     */
    public function update(Request $request, SubjectPlannerContent $content)
    {
        $validated = $request->validate([
            'academic_phase_id' => 'required|exists:academic_phases,id',
            'academic_year_id' => 'required|exists:academic_years,id',
            'academic_stream_ids' => 'nullable|array',
            'academic_stream_ids.*' => 'exists:academic_streams,id',
            'subject_id' => 'required|exists:subjects,id',
            'parent_id' => 'nullable|exists:subject_planner_content,id',
            'level' => 'required|in:learning_axis,unit,topic,subtopic,learning_objective',
            'code' => 'nullable|string|max:50',
            'title_ar' => 'required|string|max:255',
            'description_ar' => 'nullable|string',
            'order' => 'nullable|integer|min:0',
            'content_type' => 'nullable|in:theory,exercise,review,memorization,practice,exam_prep',
            'difficulty_level' => 'nullable|in:easy,medium,hard',
            'estimated_duration_minutes' => 'nullable|integer|min:1',
            'requires_understanding' => 'boolean',
            'requires_review' => 'boolean',
            'requires_theory_practice' => 'boolean',
            'requires_exercise_practice' => 'boolean',
            'learning_objectives' => 'nullable|array',
            'competencies' => 'nullable|array',
            'prerequisites' => 'nullable|array',
            'bac_exam_years' => 'nullable|array',
            'is_bac_priority' => 'boolean',
            'bac_frequency' => 'nullable|integer|min:0',
            'is_active' => 'boolean',
            'is_published' => 'boolean',
        ]);

        // Prevent setting parent to self or descendants
        if ($validated['parent_id'] == $content->id || in_array($validated['parent_id'], $this->getDescendantIds($content))) {
            return back()->withErrors(['parent_id' => 'لا يمكن اختيار هذا العنصر كأب']);
        }

        // Set boolean values
        $validated['requires_understanding'] = $request->has('requires_understanding');
        $validated['requires_review'] = $request->has('requires_review');
        $validated['requires_theory_practice'] = $request->has('requires_theory_practice');
        $validated['requires_exercise_practice'] = $request->has('requires_exercise_practice');
        $validated['is_bac_priority'] = $request->has('is_bac_priority');
        $validated['is_active'] = $request->has('is_active');
        $validated['is_published'] = $request->has('is_published');
        $validated['updated_by'] = Auth::id();

        // Handle publishing
        if ($validated['is_published'] && !$content->is_published) {
            $validated['published_at'] = now();
        } elseif (!$validated['is_published']) {
            $validated['published_at'] = null;
        }

        $content->update($validated);

        return redirect()->route('admin.subject-planner-content.show', $content)
            ->with('success', 'تم تحديث المحتوى بنجاح');
    }

    /**
     * Remove the specified content item.
     */
    public function destroy(SubjectPlannerContent $content)
    {
        // Check if has children
        if ($content->children()->exists()) {
            return redirect()->back()
                ->with('error', 'لا يمكن حذف هذا العنصر لأنه يحتوي على عناصر فرعية');
        }

        $content->delete();

        return redirect()->route('admin.subject-planner-content.index')
            ->with('success', 'تم حذف المحتوى بنجاح');
    }

    /**
     * Toggle content active status.
     */
    public function toggleStatus(SubjectPlannerContent $content)
    {
        $content->update([
            'is_active' => !$content->is_active,
            'updated_by' => Auth::id(),
        ]);

        return redirect()->back()
            ->with('success', 'تم تحديث حالة المحتوى بنجاح');
    }

    /**
     * Toggle content publish status.
     */
    public function togglePublish(SubjectPlannerContent $content)
    {
        $isPublished = !$content->is_published;

        $content->update([
            'is_published' => $isPublished,
            'published_at' => $isPublished ? now() : null,
            'updated_by' => Auth::id(),
        ]);

        $message = $isPublished ? 'تم نشر المحتوى بنجاح' : 'تم إلغاء نشر المحتوى';

        return redirect()->back()->with('success', $message);
    }

    /**
     * Reorder content items via AJAX.
     */
    public function reorder(Request $request)
    {
        $request->validate([
            'items' => 'required|array',
            'items.*.id' => 'required|exists:subject_planner_content,id',
            'items.*.order' => 'required|integer|min:0',
        ]);

        foreach ($request->items as $item) {
            SubjectPlannerContent::where('id', $item['id'])->update([
                'order' => $item['order'],
                'updated_by' => Auth::id(),
            ]);
        }

        return response()->json(['success' => true, 'message' => 'تم تحديث الترتيب بنجاح']);
    }

    /**
     * Perform bulk actions on selected items.
     */
    public function bulkAction(Request $request)
    {
        $request->validate([
            'action' => 'required|in:publish,unpublish,activate,deactivate,delete',
            'ids' => 'required|array',
            'ids.*' => 'exists:subject_planner_content,id',
        ]);

        $ids = $request->ids;
        $action = $request->action;
        $count = count($ids);

        switch ($action) {
            case 'publish':
                SubjectPlannerContent::whereIn('id', $ids)->update([
                    'is_published' => true,
                    'published_at' => now(),
                    'updated_by' => Auth::id(),
                ]);
                $message = "تم نشر {$count} عنصر بنجاح";
                break;

            case 'unpublish':
                SubjectPlannerContent::whereIn('id', $ids)->update([
                    'is_published' => false,
                    'published_at' => null,
                    'updated_by' => Auth::id(),
                ]);
                $message = "تم إلغاء نشر {$count} عنصر";
                break;

            case 'activate':
                SubjectPlannerContent::whereIn('id', $ids)->update([
                    'is_active' => true,
                    'updated_by' => Auth::id(),
                ]);
                $message = "تم تفعيل {$count} عنصر بنجاح";
                break;

            case 'deactivate':
                SubjectPlannerContent::whereIn('id', $ids)->update([
                    'is_active' => false,
                    'updated_by' => Auth::id(),
                ]);
                $message = "تم إلغاء تفعيل {$count} عنصر";
                break;

            case 'delete':
                // Only delete items without children
                $itemsWithChildren = SubjectPlannerContent::whereIn('id', $ids)
                    ->whereHas('children')
                    ->pluck('id')
                    ->toArray();

                $deletableIds = array_diff($ids, $itemsWithChildren);
                $deletedCount = SubjectPlannerContent::whereIn('id', $deletableIds)->delete();

                if (count($itemsWithChildren) > 0) {
                    $message = "تم حذف {$deletedCount} عنصر. " . count($itemsWithChildren) . " عناصر لم يتم حذفها لأنها تحتوي على عناصر فرعية";
                } else {
                    $message = "تم حذف {$deletedCount} عنصر بنجاح";
                }
                break;

            default:
                return redirect()->back()->with('error', 'إجراء غير صالح');
        }

        return redirect()->back()->with('success', $message);
    }

    /**
     * Get years by phase for AJAX cascading dropdown.
     */
    public function getYearsByPhase($phaseId)
    {
        $years = AcademicYear::where('academic_phase_id', $phaseId)
            ->where('is_active', true)
            ->orderBy('order')
            ->get(['id', 'name_ar']);

        return response()->json($years);
    }

    /**
     * Get streams by year for AJAX cascading dropdown.
     */
    public function getStreamsByYear($yearId)
    {
        $streams = AcademicStream::where('academic_year_id', $yearId)
            ->where('is_active', true)
            ->orderBy('order')
            ->get(['id', 'name_ar']);

        return response()->json($streams);
    }

    /**
     * Get subjects by stream for AJAX cascading dropdown.
     * Uses forStream scope which checks academic_stream_ids JSON array.
     */
    public function getSubjectsByStream($streamId)
    {
        // Get subjects for this stream (uses JSON contains) or shared subjects
        $subjects = Subject::forStream((int) $streamId)
            ->where('is_active', true)
            ->orderBy('name_ar')
            ->get(['id', 'name_ar']);

        return response()->json($subjects);
    }

    /**
     * Get subjects by year for AJAX cascading dropdown (for shared subjects).
     */
    public function getSubjectsByYear($yearId)
    {
        // Get all subjects for this year (both shared and stream-specific)
        $subjects = Subject::where('academic_year_id', $yearId)
            ->where('is_active', true)
            ->orderBy('name_ar')
            ->get(['id', 'name_ar']);

        return response()->json($subjects);
    }

    /**
     * Get potential parent items by subject for AJAX.
     */
    public function getParentsBySubject($subjectId)
    {
        $parents = SubjectPlannerContent::where('subject_id', $subjectId)
            ->orderBy('order')
            ->get(['id', 'title_ar', 'level', 'code'])
            ->map(function($item) {
                return [
                    'id' => $item->id,
                    'title_ar' => $item->title_ar,
                    'level' => $this->levelLabels[$item->level] ?? $item->level,
                    'code' => $item->code,
                    'full_title' => ($item->code ? $item->code . ' - ' : '') . $item->title_ar . ' (' . ($this->levelLabels[$item->level] ?? $item->level) . ')',
                ];
            });

        return response()->json($parents);
    }

    /**
     * Get children of a content item for AJAX tree loading.
     */
    public function getChildren($id)
    {
        $content = SubjectPlannerContent::findOrFail($id);

        $children = $content->children()
            ->with(['children', 'subject'])
            ->withCount('children')
            ->orderBy('order')
            ->get()
            ->map(function($child) {
                return [
                    'id' => $child->id,
                    'title_ar' => $child->title_ar,
                    'code' => $child->code,
                    'level' => $child->level,
                    'level_label' => $this->levelLabels[$child->level] ?? $child->level,
                    'level_color' => $this->levelColors[$child->level] ?? 'gray',
                    'is_published' => $child->is_published,
                    'is_active' => $child->is_active,
                    'is_bac_priority' => $child->is_bac_priority,
                    'children_count' => $child->children_count,
                    'has_children' => $child->children_count > 0,
                    'order' => $child->order,
                    'subject_name' => $child->subject ? $child->subject->name_ar : null,
                ];
            });

        return response()->json($children);
    }

    /**
     * Move an item to a new parent (drag & drop).
     */
    public function move(Request $request)
    {
        $request->validate([
            'item_id' => 'required|exists:subject_planner_content,id',
            'new_parent_id' => 'nullable|exists:subject_planner_content,id',
            'items' => 'required|array',
            'items.*.id' => 'required|exists:subject_planner_content,id',
            'items.*.order' => 'required|integer|min:0',
        ]);

        $item = SubjectPlannerContent::findOrFail($request->item_id);
        $newParentId = $request->new_parent_id;

        // Prevent moving an item to itself or its descendants
        if ($newParentId) {
            $newParent = SubjectPlannerContent::findOrFail($newParentId);

            // Check if the new parent is a descendant of the item being moved
            if ($this->isDescendant($item->id, $newParentId)) {
                return response()->json([
                    'success' => false,
                    'message' => 'لا يمكن نقل العنصر إلى أحد فروعه'
                ], 400);
            }

            // Copy academic context from new parent if moving to a different subject
            if ($newParent->subject_id !== $item->subject_id) {
                $item->subject_id = $newParent->subject_id;
                $item->academic_phase_id = $newParent->academic_phase_id;
                $item->academic_year_id = $newParent->academic_year_id;
                $item->academic_stream_ids = $newParent->academic_stream_ids;
            }
        }

        // Update the parent
        $item->parent_id = $newParentId;
        $item->save();

        // Update order for all items in the target container
        foreach ($request->items as $itemData) {
            SubjectPlannerContent::where('id', $itemData['id'])
                ->update(['order' => $itemData['order']]);
        }

        // Also update children's academic context recursively if subject changed
        if ($newParentId) {
            $newParent = SubjectPlannerContent::find($newParentId);
            if ($newParent && $newParent->subject_id !== $item->subject_id) {
                $this->updateChildrenContext($item, $newParent);
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'تم نقل العنصر بنجاح'
        ]);
    }

    /**
     * Check if a potential parent is a descendant of the item.
     */
    private function isDescendant($itemId, $potentialDescendantId)
    {
        $current = SubjectPlannerContent::find($potentialDescendantId);

        while ($current) {
            if ($current->id == $itemId) {
                return true;
            }
            $current = $current->parent;
        }

        return false;
    }

    /**
     * Recursively update children's academic context.
     */
    private function updateChildrenContext($item, $newParent)
    {
        $children = $item->children;

        foreach ($children as $child) {
            $child->subject_id = $newParent->subject_id;
            $child->academic_phase_id = $newParent->academic_phase_id;
            $child->academic_year_id = $newParent->academic_year_id;
            $child->academic_stream_ids = $newParent->academic_stream_ids;
            $child->save();

            // Recursively update grandchildren
            $this->updateChildrenContext($child, $newParent);
        }
    }
}
