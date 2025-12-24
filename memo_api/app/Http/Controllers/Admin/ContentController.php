<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Content;
use App\Models\Subject;
use App\Models\ContentType;
use App\Models\ContentChapter;
use App\Models\AcademicPhase;
use App\Models\AcademicYear;
use App\Models\AcademicStream;
use App\Services\ContentService;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Storage;
use Yajra\DataTables\Facades\DataTables;

class ContentController extends Controller
{
    protected ContentService $contentService;

    public function __construct(ContentService $contentService)
    {
        $this->contentService = $contentService;
    }
    /**
     * Display a listing of contents.
     */
    public function index(Request $request)
    {
        if ($request->ajax()) {
            return $this->getDataTable($request);
        }

        $subjects = Subject::where('is_active', true)->orderBy('name_ar')->get();
        $contentTypes = ContentType::all();

        return view('admin.contents.index', compact('subjects', 'contentTypes'));
    }

    /**
     * Get DataTables data for contents
     */
    private function getDataTable(Request $request)
    {
        $query = Content::with(['subject', 'contentType', 'chapter']);

        // Filter by subject
        if ($request->filled('subject_id')) {
            $query->where('subject_id', $request->subject_id);
        }

        // Filter by content type
        if ($request->filled('content_type_id')) {
            $query->where('content_type_id', $request->content_type_id);
        }

        // Filter by difficulty
        if ($request->filled('difficulty')) {
            $query->where('difficulty_level', $request->difficulty);
        }

        // Filter by status
        if ($request->filled('status')) {
            if ($request->status === 'published') {
                $query->where('is_published', true);
            } elseif ($request->status === 'draft') {
                $query->where('is_published', false);
            }
        }

        return DataTables::of($query)
            ->addColumn('title', function($content) {
                return '
                    <div class="font-semibold text-gray-900">' . e($content->title_ar) . '</div>
                    ' . ($content->description_ar ? '<div class="text-xs text-gray-500 mt-1">' . e(Str::limit($content->description_ar, 60)) . '</div>' : '') . '
                ';
            })
            ->addColumn('subject', function($content) {
                return $content->subject
                    ? '<span class="px-2 py-1 bg-blue-100 text-blue-700 rounded-full text-xs font-semibold">' . e($content->subject->name_ar) . '</span>'
                    : '-';
            })
            ->addColumn('type', function($content) {
                $colors = [
                    'lesson' => 'purple',
                    'exercise' => 'green',
                    'exam' => 'red',
                    'summary' => 'yellow',
                ];
                $color = $colors[$content->contentType->slug ?? 'lesson'] ?? 'gray';
                return $content->contentType
                    ? '<span class="px-2 py-1 bg-' . $color . '-100 text-' . $color . '-700 rounded-full text-xs font-semibold">' . e($content->contentType->name_ar) . '</span>'
                    : '-';
            })
            ->addColumn('difficulty', function($content) {
                $badges = [
                    'easy' => '<span class="px-2 py-1 bg-green-100 text-green-700 rounded-full text-xs font-semibold">سهل</span>',
                    'medium' => '<span class="px-2 py-1 bg-yellow-100 text-yellow-700 rounded-full text-xs font-semibold">متوسط</span>',
                    'hard' => '<span class="px-2 py-1 bg-red-100 text-red-700 rounded-full text-xs font-semibold">صعب</span>',
                ];
                return $badges[$content->difficulty_level] ?? '-';
            })
            ->addColumn('stats', function($content) {
                return '
                    <div class="text-xs text-gray-600">
                        <div><i class="fas fa-eye text-blue-500"></i> ' . number_format($content->views_count) . ' مشاهدة</div>
                        <div><i class="fas fa-download text-green-500"></i> ' . number_format($content->downloads_count) . ' تحميل</div>
                    </div>
                ';
            })
            ->addColumn('status', function($content) {
                if ($content->is_published) {
                    return '<span class="px-3 py-1 bg-green-100 text-green-700 rounded-full text-xs font-bold">منشور</span>';
                } else {
                    return '<span class="px-3 py-1 bg-gray-100 text-gray-700 rounded-full text-xs font-bold">مسودة</span>';
                }
            })
            ->addColumn('actions', function($content) {
                return '
                    <div class="flex gap-2">
                        <a href="' . route('admin.contents.show', $content->id) . '"
                           class="px-3 py-1 bg-blue-100 hover:bg-blue-200 text-blue-700 rounded text-sm font-semibold transition">
                            <i class="fas fa-eye"></i> عرض
                        </a>
                        <a href="' . route('admin.contents.edit', $content->id) . '"
                           class="px-3 py-1 bg-yellow-100 hover:bg-yellow-200 text-yellow-700 rounded text-sm font-semibold transition">
                            <i class="fas fa-edit"></i> تعديل
                        </a>
                    </div>
                ';
            })
            ->rawColumns(['title', 'subject', 'type', 'difficulty', 'stats', 'status', 'actions'])
            ->make(true);
    }

    /**
     * Show the form for creating new content.
     */
    public function create()
    {
        $phases = AcademicPhase::where('is_active', true)->orderBy('name_ar')->get();
        $contentTypes = ContentType::all();
        $chapters = ContentChapter::where('is_active', true)->orderBy('subject_id')->orderBy('order')->get();

        // Check if subject_id is provided for auto-fill
        $prefilledSubject = null;
        if (request()->has('subject_id')) {
            $prefilledSubject = Subject::with([
                'academicStream.academicYear.academicPhase',
                'academicYear.academicPhase'
            ])->find(request('subject_id'));
        }

        return view('admin.contents.create', compact('phases', 'contentTypes', 'chapters', 'prefilledSubject'));
    }

    /**
     * Store newly created content.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'subject_id' => 'required|exists:subjects,id',
            'content_type_id' => 'required|exists:content_types,id',
            'chapter_id' => 'nullable|exists:content_chapters,id',
            'quiz_ids' => 'nullable|array',
            'quiz_ids.*' => 'exists:quizzes,id',
            'title_ar' => 'required|string|max:255',
            'description_ar' => 'nullable|string',
            'content_body_ar' => 'nullable|string',
            'difficulty_level' => 'required|in:easy,medium,hard',
            'estimated_duration_minutes' => 'nullable|integer|min:1',
            'order' => 'nullable|integer',
            'tags' => 'nullable|string',
            'search_keywords' => 'nullable|string',
            'is_premium' => 'boolean',
            'is_published' => 'boolean',
            'file' => 'nullable|file|mimes:pdf,doc,docx|max:51200', // 50MB max
            'video_file' => 'nullable|file|mimes:mp4,mpeg,mov,avi|max:512000', // 500MB max
            'youtube_url' => 'nullable|url',
        ]);

        $validated['is_premium'] = $request->has('is_premium');
        $validated['is_published'] = $request->has('is_published');

        if ($request->has('tags')) {
            $validated['tags'] = array_map('trim', explode(',', $request->tags));
        }

        // Add uploaded files to data
        if ($request->hasFile('file')) {
            $validated['file'] = $request->file('file');
        }

        if ($request->hasFile('video_file')) {
            $validated['video_file'] = $request->file('video_file');
        }

        // Remove quiz_ids from validated data to prevent passing to createContent
        $quizIds = $validated['quiz_ids'] ?? [];
        unset($validated['quiz_ids']);

        try {
            $content = $this->contentService->createContent($validated, auth()->user());

            // Attach selected quizzes if any
            if (!empty($quizIds)) {
                $content->quizzes()->attach($quizIds);
            }

            return redirect()->route('admin.contents.index')
                ->with('success', 'تم إضافة المحتوى بنجاح');
        } catch (\Exception $e) {
            return redirect()->back()
                ->withInput()
                ->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Display the specified content.
     */
    public function show(Content $content)
    {
        $content->load(['subject', 'contentType', 'chapter', 'creator', 'updater']);

        return view('admin.contents.show', compact('content'));
    }

    /**
     * Show the form for editing content.
     */
    public function edit(Content $content)
    {
        $subjects = Subject::where('is_active', true)->orderBy('name_ar')->get();
        $contentTypes = ContentType::all();
        $chapters = ContentChapter::where('is_active', true)->orderBy('subject_id')->orderBy('order')->get();

        return view('admin.contents.edit', compact('content', 'subjects', 'contentTypes', 'chapters'));
    }

    /**
     * Update the specified content.
     */
    public function update(Request $request, Content $content)
    {
        $validated = $request->validate([
            'subject_id' => 'required|exists:subjects,id',
            'content_type_id' => 'required|exists:content_types,id',
            'chapter_id' => 'nullable|exists:content_chapters,id',
            'quiz_ids' => 'nullable|array',
            'quiz_ids.*' => 'exists:quizzes,id',
            'title_ar' => 'required|string|max:255',
            'description_ar' => 'nullable|string',
            'content_body_ar' => 'nullable|string',
            'difficulty_level' => 'required|in:easy,medium,hard',
            'estimated_duration_minutes' => 'nullable|integer|min:1',
            'order' => 'nullable|integer',
            'tags' => 'nullable|string',
            'search_keywords' => 'nullable|string',
            'is_premium' => 'boolean',
            'is_published' => 'boolean',
            'file' => 'nullable|file|mimes:pdf,doc,docx|max:51200', // 50MB max
            'video_file' => 'nullable|file|mimes:mp4,mpeg,mov,avi|max:512000', // 500MB max
            'youtube_url' => 'nullable|url',
            'delete_file' => 'boolean',
        ]);

        $validated['is_premium'] = $request->has('is_premium');
        $validated['is_published'] = $request->has('is_published');
        $validated['delete_file'] = $request->has('delete_file');

        if ($request->has('tags')) {
            $validated['tags'] = array_map('trim', explode(',', $request->tags));
        }

        // Add uploaded files to data
        if ($request->hasFile('file')) {
            $validated['file'] = $request->file('file');
        }

        if ($request->hasFile('video_file')) {
            $validated['video_file'] = $request->file('video_file');
        }

        // Remove quiz_ids from validated data to prevent passing to updateContent
        $quizIds = $validated['quiz_ids'] ?? [];
        unset($validated['quiz_ids']);

        try {
            $content = $this->contentService->updateContent($content, $validated, auth()->user());

            // Sync selected quizzes (adds new, removes unchecked)
            $content->quizzes()->sync($quizIds);

            return redirect()->route('admin.contents.index')
                ->with('success', 'تم تحديث المحتوى بنجاح');
        } catch (\Exception $e) {
            return redirect()->back()
                ->withInput()
                ->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Remove the specified content.
     */
    public function destroy(Content $content)
    {
        try {
            $this->contentService->deleteContent($content);

            return redirect()->route('admin.contents.index')
                ->with('success', 'تم حذف المحتوى بنجاح');
        } catch (\Exception $e) {
            return redirect()->back()
                ->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Publish content.
     */
    public function publish(Content $content)
    {
        $this->contentService->publishContent($content);

        return redirect()->back()
            ->with('success', 'تم نشر المحتوى بنجاح');
    }

    /**
     * Unpublish content.
     */
    public function unpublish(Content $content)
    {
        $this->contentService->unpublishContent($content);

        return redirect()->back()
            ->with('success', 'تم إلغاء نشر المحتوى بنجاح');
    }

    /**
     * Show content analytics dashboard.
     */
    public function analytics()
    {
        $stats = [
            'total_contents' => Content::count(),
            'published_contents' => Content::where('is_published', true)->count(),
            'draft_contents' => Content::where('is_published', false)->count(),
            'total_views' => Content::sum('views_count'),
            'total_downloads' => Content::sum('downloads_count'),
        ];

        $topViewed = Content::with(['subject', 'contentType'])
            ->orderBy('views_count', 'desc')
            ->take(10)
            ->get();

        $topRated = Content::with(['subject', 'contentType'])
            ->whereHas('ratings')
            ->get()
            ->sortByDesc('average_rating')
            ->take(10);

        $contentsByType = Content::selectRaw('content_type_id, count(*) as count')
            ->groupBy('content_type_id')
            ->with('contentType')
            ->get();

        $contentsBySubject = Content::selectRaw('subject_id, count(*) as count')
            ->groupBy('subject_id')
            ->with('subject')
            ->orderBy('count', 'desc')
            ->take(10)
            ->get();

        return view('admin.contents.analytics', compact(
            'stats',
            'topViewed',
            'topRated',
            'contentsByType',
            'contentsBySubject'
        ));
    }
}
