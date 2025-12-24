<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Subject;
use App\Models\SubjectStream;
use App\Models\AcademicPhase;
use App\Models\AcademicYear;
use App\Models\AcademicStream;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;
use Yajra\DataTables\Facades\DataTables;

class SubjectController extends Controller
{
    /**
     * Display a listing of subjects.
     */
    public function index(Request $request)
    {
        if ($request->ajax()) {
            return $this->getDataTable($request);
        }

        $phases = AcademicPhase::where('is_active', true)->orderBy('order')->get();
        $years = AcademicYear::where('is_active', true)->orderBy('order')->get();
        $streams = AcademicStream::where('is_active', true)->orderBy('order')->get();

        return view('admin.subjects.index', compact('phases', 'years', 'streams'));
    }

    /**
     * Get subjects data for DataTables.
     */
    private function getDataTable(Request $request)
    {
        $query = Subject::with(['academicYear.academicPhase', 'subjectStreams.academicStream'])
            ->withCount('contents');

        // Filter by phase
        if ($request->filled('phase_id')) {
            $query->where(function($q) use ($request) {
                $q->whereHas('streams.academicYear.academicPhase', function($sq) use ($request) {
                    $sq->where('id', $request->phase_id);
                })->orWhereHas('academicYear.academicPhase', function($sq) use ($request) {
                    $sq->where('id', $request->phase_id);
                });
            });
        }

        // Filter by year
        if ($request->filled('year_id')) {
            $query->where(function($q) use ($request) {
                $q->where('academic_year_id', $request->year_id)
                  ->orWhereHas('streams', function($sq) use ($request) {
                      $sq->where('academic_year_id', $request->year_id);
                  });
            });
        }

        // Filter by stream
        if ($request->filled('stream_id')) {
            $query->forStream($request->stream_id);
        }

        return DataTables::of($query)
            ->filter(function ($query) use ($request) {
                if ($request->has('search') && $request->search['value']) {
                    $searchValue = $request->search['value'];
                    $query->where('name_ar', 'LIKE', "%{$searchValue}%");
                }
            })
            ->addColumn('subject_info', function ($subject) {
                $html = '<div class="flex items-center">';
                if ($subject->color) {
                    $html .= '<div class="w-3 h-3 rounded-full mr-3" style="background-color: ' . $subject->color . '"></div>';
                }
                $html .= '<div>';
                $html .= '<div class="font-medium text-gray-900">' . $subject->name_ar . '</div>';
                if ($subject->icon) {
                    $html .= '<div class="text-xs text-gray-500"><i class="fas fa-' . $subject->icon . '"></i> ' . $subject->icon . '</div>';
                }
                $html .= '</div></div>';
                return $html;
            })
            ->addColumn('academic_info', function ($subject) {
                $streams = $subject->academicStreams();
                if ($streams->count() > 0) {
                    $html = '<div class="text-sm">';
                    if ($subject->academicYear) {
                        $html .= '<div class="font-medium">' . $subject->academicYear->academicPhase->name_ar . '</div>';
                        $html .= '<div class="text-gray-600">' . $subject->academicYear->name_ar . '</div>';
                    }
                    $streamNames = $streams->pluck('name_ar')->implode(', ');
                    $html .= '<div class="text-gray-600">' . $streamNames . '</div>';
                    $html .= '</div>';
                    return $html;
                } elseif ($subject->academicYear) {
                    return '<div class="text-sm">' .
                           '<div class="font-medium">' . $subject->academicYear->academicPhase->name_ar . '</div>' .
                           '<div class="text-gray-600">' . $subject->academicYear->name_ar . '</div>' .
                           '<div class="text-gray-500 text-xs">(مادة مشتركة)</div>' .
                           '</div>';
                }
                return '<span class="text-gray-400">-</span>';
            })
            ->addColumn('coefficient_badge', function ($subject) {
                // Show coefficients from pivot table (per stream)
                if ($subject->subjectStreams->isNotEmpty()) {
                    $html = '<div class="flex flex-wrap gap-1">';
                    foreach ($subject->subjectStreams as $pivot) {
                        $streamName = $pivot->academicStream->name_ar ?? 'شعبة';
                        $html .= '<span class="px-2 py-1 inline-flex text-xs leading-4 font-semibold rounded-full bg-blue-100 text-blue-800" title="' . e($streamName) . '">' .
                                 e($streamName) . ': ' . $pivot->coefficient .
                                 '</span>';
                    }
                    $html .= '</div>';
                    return $html;
                }
                // Fallback to old coefficient column if no pivot data
                if ($subject->coefficient) {
                    return '<span class="px-3 py-1 inline-flex text-sm leading-5 font-semibold rounded-full bg-gray-100 text-gray-800">' .
                           $subject->coefficient . ' (عام)' .
                           '</span>';
                }
                return '<span class="text-gray-400">-</span>';
            })
            ->addColumn('contents_count', function ($subject) {
                return $subject->contents_count ?? 0;
            })
            ->addColumn('status', function ($subject) {
                if ($subject->is_active) {
                    return '<span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">نشط</span>';
                }
                return '<span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">غير نشط</span>';
            })
            ->addColumn('actions', function ($subject) {
                return view('admin.subjects.partials.actions', compact('subject'))->render();
            })
            ->rawColumns(['subject_info', 'academic_info', 'coefficient_badge', 'status', 'actions'])
            ->make(true);
    }

    /**
     * Get years by phase for AJAX.
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
     * Get streams by year for AJAX.
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
     * Get subjects by stream for AJAX.
     */
    public function getSubjectsByStream($streamId)
    {
        $subjects = Subject::forStream($streamId)
            ->where('is_active', true)
            ->orderBy('name_ar')
            ->get(['id', 'name_ar']);

        return response()->json($subjects);
    }

    /**
     * Show the form for creating a new subject.
     */
    public function create()
    {
        $phases = AcademicPhase::where('is_active', true)->orderBy('order')->get();
        $years = AcademicYear::where('is_active', true)->with('academicPhase')->orderBy('order')->get();
        $streams = AcademicStream::where('is_active', true)->with('academicYear')->orderBy('order')->get();

        return view('admin.subjects.create', compact('phases', 'years', 'streams'));
    }

    /**
     * Store a newly created subject.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name_ar' => 'required|string|max:100',
            'description_ar' => 'nullable|string',
            'phase_id' => 'required|exists:academic_phases,id',
            'academic_year_id' => 'required|exists:academic_years,id',
            'academic_stream_ids' => 'nullable|array',
            'academic_stream_ids.*' => 'exists:academic_streams,id',
            'stream_coefficients' => 'nullable|array',
            'stream_coefficients.*' => 'required|numeric|min:0.5|max:10',
            'stream_categories' => 'nullable|array',
            'stream_categories.*' => 'required|in:HARD_CORE,LANGUAGE,MEMORIZATION,OTHER',
            'color' => 'nullable|string|max:20',
            'icon' => 'nullable|string|max:50',
            'order' => 'nullable|integer',
            'is_active' => 'boolean',
        ]);

        // Remove phase_id as it's not stored in subjects table (used only for cascading)
        unset($validated['phase_id']);

        // Extract stream_coefficients and stream_categories before creating subject
        $streamCoefficients = $validated['stream_coefficients'] ?? [];
        $streamCategories = $validated['stream_categories'] ?? [];
        unset($validated['stream_coefficients']);
        unset($validated['stream_categories']);

        $validated['slug'] = Str::slug($request->name_ar . '-' . time());
        $validated['is_active'] = $request->has('is_active');

        // Convert empty array to null for academic_stream_ids
        if (empty($validated['academic_stream_ids'])) {
            $validated['academic_stream_ids'] = null;
        }

        DB::transaction(function () use ($validated, $streamCoefficients, $streamCategories) {
            $subject = Subject::create($validated);

            // Create pivot records for each selected stream
            if (!empty($validated['academic_stream_ids'])) {
                foreach ($validated['academic_stream_ids'] as $streamId) {
                    // Use stream-specific coefficient and category (required)
                    $coefficient = $streamCoefficients[$streamId] ?? 1;
                    $category = $streamCategories[$streamId] ?? 'OTHER';

                    SubjectStream::create([
                        'subject_id' => $subject->id,
                        'academic_stream_id' => $streamId,
                        'coefficient' => $coefficient,
                        'category' => $category,
                        'is_active' => true,
                    ]);
                }
            }
        });

        return redirect()->route('admin.subjects.index')
            ->with('success', 'تم إضافة المادة بنجاح');
    }

    /**
     * Display the specified subject.
     */
    public function show(Request $request, Subject $subject)
    {
        // Handle AJAX request for DataTables
        if ($request->ajax()) {
            return $this->getContentsDataTable($request, $subject);
        }

        // Load relationships for regular page view
        $subject->load([
            'academicYear.academicPhase',
            'subjectStreams.academicStream',
            'contentChapters' => function($q) {
                $q->where('is_active', true)->orderBy('order');
            }
        ]);

        // Calculate statistics
        $stats = [
            'total_contents' => $subject->contents()->count(),
            'published_contents' => $subject->contents()->where('is_published', true)->count(),
            'total_chapters' => $subject->contentChapters()->where('is_active', true)->count(),
        ];

        // Get content types for filter UI
        $contentTypes = \App\Models\ContentType::whereIn('slug', ['lesson', 'summary', 'exercise', 'test'])
            ->orderByRaw("FIELD(slug, 'lesson', 'summary', 'exercise', 'test')")
            ->get();

        return view('admin.subjects.show', compact('subject', 'stats', 'contentTypes'));
    }

    /**
     * Get contents data for DataTables (AJAX).
     */
    private function getContentsDataTable(Request $request, Subject $subject)
    {
        // Build base query with relationships
        $query = $subject->contents()
            ->with(['contentType', 'chapter']);

        // Filter by content type
        if ($request->filled('content_type_id')) {
            $query->where('content_type_id', $request->content_type_id);
        }

        // Filter by difficulty (future enhancement)
        if ($request->filled('difficulty')) {
            $query->where('difficulty_level', $request->difficulty);
        }

        // Filter by status (future enhancement)
        if ($request->filled('status')) {
            if ($request->status === 'published') {
                $query->where('is_published', true);
            } elseif ($request->status === 'draft') {
                $query->where('is_published', false);
            }
        }

        // Filter by chapter (future enhancement)
        if ($request->filled('chapter_id')) {
            $query->where('chapter_id', $request->chapter_id);
        }

        return DataTables::of($query)
            ->filter(function ($query) use ($request) {
                // Global search across title and description
                if ($request->has('search') && $request->search['value']) {
                    $searchValue = $request->search['value'];
                    $query->where(function($q) use ($searchValue) {
                        $q->where('title_ar', 'LIKE', "%{$searchValue}%")
                          ->orWhere('description_ar', 'LIKE', "%{$searchValue}%");
                    });
                }
            })
            ->addColumn('title_info', function ($content) {
                $html = '<div>';
                $html .= '<div class="font-medium text-gray-900">' . \Illuminate\Support\Str::limit($content->title_ar, 60) . '</div>';

                if ($content->chapter) {
                    $html .= '<div class="text-xs text-gray-500 mt-1">';
                    $html .= '<i class="fas fa-bookmark mr-1"></i>' . e($content->chapter->title_ar);
                    $html .= '</div>';
                }

                $html .= '</div>';
                return $html;
            })
            ->addColumn('type_badge', function ($content) {
                $iconMap = [
                    'lesson' => 'book-open',
                    'summary' => 'file-text',
                    'exercises' => 'edit',
                    'exam' => 'file-check',
                    'homework' => 'clipboard',
                    'video' => 'play-circle',
                    'solved-problems' => 'check-circle',
                    'flashcards' => 'layers',
                    'mind-maps' => 'share-2',
                    'practical-apps' => 'cpu',
                ];

                $icon = $iconMap[$content->contentType->slug] ?? 'file-alt';

                return '<span class="px-3 py-1 text-xs rounded-full bg-purple-100 text-purple-800 inline-flex items-center gap-1">' .
                       '<i class="fas fa-' . $icon . '"></i>' .
                       '<span>' . e($content->contentType->name_ar) . '</span>' .
                       '</span>';
            })
            ->addColumn('difficulty_badge', function ($content) {
                if (!$content->difficulty_level) {
                    return '<span class="text-gray-400">-</span>';
                }

                $badges = [
                    'easy' => '<span class="px-3 py-1 text-xs rounded-full bg-green-100 text-green-800 font-semibold">سهل</span>',
                    'medium' => '<span class="px-3 py-1 text-xs rounded-full bg-yellow-100 text-yellow-800 font-semibold">متوسط</span>',
                    'hard' => '<span class="px-3 py-1 text-xs rounded-full bg-red-100 text-red-800 font-semibold">صعب</span>',
                ];

                return $badges[$content->difficulty_level] ?? '<span class="text-gray-400">-</span>';
            })
            ->addColumn('views_count', function ($content) {
                return '<div class="text-sm text-gray-700">' . number_format($content->views_count ?? 0) . '</div>';
            })
            ->addColumn('status_badge', function ($content) {
                if ($content->is_published) {
                    return '<span class="px-3 py-1 text-xs rounded-full bg-green-100 text-green-800 font-semibold">منشور</span>';
                }
                return '<span class="px-3 py-1 text-xs rounded-full bg-gray-100 text-gray-800 font-semibold">مسودة</span>';
            })
            ->addColumn('actions', function ($content) {
                $actions = '<div class="flex gap-2">';

                // View button
                $actions .= '<a href="' . route('admin.contents.show', $content) . '" ' .
                           'class="text-blue-600 hover:text-blue-800 transition-colors" title="عرض">' .
                           '<i class="fas fa-eye"></i>' .
                           '</a>';

                // Edit button
                $actions .= '<a href="' . route('admin.contents.edit', $content) . '" ' .
                           'class="text-green-600 hover:text-green-800 transition-colors" title="تعديل">' .
                           '<i class="fas fa-edit"></i>' .
                           '</a>';

                $actions .= '</div>';

                return $actions;
            })
            ->rawColumns(['title_info', 'type_badge', 'difficulty_badge', 'views_count', 'status_badge', 'actions'])
            ->make(true);
    }

    /**
     * Show the form for editing the specified subject.
     */
    public function edit(Subject $subject)
    {
        // Load subjectStreams to get existing coefficients
        $subject->load('subjectStreams');

        $phases = AcademicPhase::where('is_active', true)->orderBy('order')->get();
        $years = AcademicYear::where('is_active', true)->with('academicPhase')->orderBy('order')->get();
        $streams = AcademicStream::where('is_active', true)->with(['academicYear.academicPhase'])->orderBy('order')->get();

        return view('admin.subjects.edit', compact('subject', 'phases', 'years', 'streams'));
    }

    /**
     * Update the specified subject.
     */
    public function update(Request $request, Subject $subject)
    {
        $validated = $request->validate([
            'name_ar' => 'required|string|max:100',
            'description_ar' => 'nullable|string',
            'academic_year_id' => 'nullable|exists:academic_years,id',
            'academic_stream_ids' => 'nullable|array',
            'academic_stream_ids.*' => 'exists:academic_streams,id',
            'stream_coefficients' => 'nullable|array',
            'stream_coefficients.*' => 'required|numeric|min:0.5|max:10',
            'stream_categories' => 'nullable|array',
            'stream_categories.*' => 'required|in:HARD_CORE,LANGUAGE,MEMORIZATION,OTHER',
            'color' => 'nullable|string|max:20',
            'icon' => 'nullable|string|max:50',
            'order' => 'nullable|integer',
            'is_active' => 'boolean',
        ]);

        $validated['is_active'] = $request->has('is_active');

        // Extract stream_coefficients and stream_categories before updating subject
        $streamCoefficients = $validated['stream_coefficients'] ?? [];
        $streamCategories = $validated['stream_categories'] ?? [];
        unset($validated['stream_coefficients']);
        unset($validated['stream_categories']);

        // Convert empty array to null for academic_stream_ids
        if (empty($validated['academic_stream_ids'])) {
            $validated['academic_stream_ids'] = null;
        }

        DB::transaction(function () use ($subject, $validated, $streamCoefficients, $streamCategories) {
            $subject->update($validated);

            // Delete existing pivot records
            SubjectStream::where('subject_id', $subject->id)->delete();

            // Create new pivot records for each selected stream
            if (!empty($validated['academic_stream_ids'])) {
                foreach ($validated['academic_stream_ids'] as $streamId) {
                    // Use stream-specific coefficient and category (required)
                    $coefficient = $streamCoefficients[$streamId] ?? 1;
                    $category = $streamCategories[$streamId] ?? 'OTHER';

                    SubjectStream::create([
                        'subject_id' => $subject->id,
                        'academic_stream_id' => $streamId,
                        'coefficient' => $coefficient,
                        'category' => $category,
                        'is_active' => true,
                    ]);
                }
            }
        });

        return redirect()->route('admin.subjects.index')
            ->with('success', 'تم تحديث المادة بنجاح');
    }

    /**
     * Remove the specified subject.
     */
    public function destroy(Subject $subject)
    {
        $subject->delete();

        return redirect()->route('admin.subjects.index')
            ->with('success', 'تم حذف المادة بنجاح');
    }

    /**
     * Toggle subject active status.
     */
    public function toggleStatus(Subject $subject)
    {
        $subject->update(['is_active' => !$subject->is_active]);

        return redirect()->back()
            ->with('success', 'تم تحديث حالة المادة بنجاح');
    }
}
