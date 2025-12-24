<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\FlashcardDeck;
use App\Models\Flashcard;
use App\Models\Subject;
use App\Models\ContentChapter;
use App\Models\AcademicPhase;
use App\Models\AcademicYear;
use App\Models\AcademicStream;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Yajra\DataTables\Facades\DataTables;

class FlashcardDeckController extends Controller
{
    /**
     * Display flashcard decks overview
     */
    public function index(Request $request)
    {
        if ($request->ajax()) {
            return $this->getDataTable($request);
        }

        $subjects = Subject::orderBy('name_ar')->get();
        $streams = AcademicStream::orderBy('name_ar')->get();

        // Statistics
        $stats = [
            'total_decks' => FlashcardDeck::count(),
            'published_decks' => FlashcardDeck::where('is_published', true)->count(),
            'total_cards' => Flashcard::count(),
            'total_reviews' => \DB::table('flashcard_review_sessions')->count(),
        ];

        return view('admin.flashcards.decks.index', compact('subjects', 'streams', 'stats'));
    }

    /**
     * Get DataTables data
     */
    private function getDataTable(Request $request)
    {
        $query = FlashcardDeck::with(['subject', 'chapter', 'academicStreams', 'creator']);

        // Filters
        if ($request->filled('subject_id')) {
            $query->where('subject_id', $request->subject_id);
        }

        if ($request->filled('stream_id')) {
            $query->whereHas('academicStreams', function($q) use ($request) {
                $q->where('academic_streams.id', $request->stream_id);
            });
        }

        if ($request->filled('difficulty')) {
            $query->where('difficulty_level', $request->difficulty);
        }

        if ($request->filled('status')) {
            if ($request->status === 'published') {
                $query->where('is_published', true);
            } elseif ($request->status === 'draft') {
                $query->where('is_published', false);
            }
        }

        return DataTables::of($query)
            ->addColumn('title', function($deck) {
                $html = '<div class="font-semibold text-gray-900">' . e($deck->title_ar) . '</div>';
                if ($deck->chapter) {
                    $html .= '<div class="text-xs text-gray-500 mt-1">' . e($deck->chapter->title_ar) . '</div>';
                }
                return $html;
            })
            ->addColumn('subject', function($deck) {
                return $deck->subject
                    ? '<span class="px-2 py-1 bg-blue-100 text-blue-700 rounded-full text-xs font-semibold">' . e($deck->subject->name_ar) . '</span>'
                    : '-';
            })
            ->addColumn('stream', function($deck) {
                $streams = $deck->academicStreams;
                if ($streams->isEmpty()) {
                    return '<span class="text-gray-400">كل الشعب</span>';
                }
                return $streams->map(function($stream) {
                    return '<span class="px-2 py-1 bg-purple-100 text-purple-700 rounded-full text-xs font-semibold ml-1">' . e($stream->name_ar) . '</span>';
                })->implode('');
            })
            ->addColumn('difficulty', function($deck) {
                $badges = [
                    'easy' => '<span class="px-2 py-1 bg-green-100 text-green-700 rounded-full text-xs font-semibold">سهل</span>',
                    'medium' => '<span class="px-2 py-1 bg-yellow-100 text-yellow-700 rounded-full text-xs font-semibold">متوسط</span>',
                    'hard' => '<span class="px-2 py-1 bg-red-100 text-red-700 rounded-full text-xs font-semibold">صعب</span>',
                ];
                return $badges[$deck->difficulty_level] ?? '-';
            })
            ->addColumn('cards', function($deck) {
                return '<div class="text-center"><span class="font-bold text-pink-600">' . $deck->total_cards . '</span> <span class="text-xs text-gray-500">بطاقة</span></div>';
            })
            ->addColumn('status', function($deck) {
                if ($deck->is_published) {
                    return '<span class="px-3 py-1 bg-green-100 text-green-700 rounded-full text-xs font-bold">منشور</span>';
                } else {
                    return '<span class="px-3 py-1 bg-gray-100 text-gray-700 rounded-full text-xs font-bold">مسودة</span>';
                }
            })
            ->addColumn('actions', function($deck) {
                return '
                    <div class="flex gap-2">
                        <a href="' . route('admin.flashcard-decks.show', $deck->id) . '"
                           class="px-3 py-1 bg-blue-100 hover:bg-blue-200 text-blue-700 rounded text-sm font-semibold transition">
                            <i class="fas fa-eye"></i> عرض
                        </a>
                        <a href="' . route('admin.flashcard-decks.edit', $deck->id) . '"
                           class="px-3 py-1 bg-yellow-100 hover:bg-yellow-200 text-yellow-700 rounded text-sm font-semibold transition">
                            <i class="fas fa-edit"></i> تعديل
                        </a>
                    </div>
                ';
            })
            ->rawColumns(['title', 'subject', 'stream', 'difficulty', 'cards', 'status', 'actions'])
            ->make(true);
    }

    /**
     * Show create form
     */
    public function create()
    {
        $phases = AcademicPhase::orderBy('order')->get();

        return view('admin.flashcards.decks.create', compact('phases'));
    }

    /**
     * Store new deck
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'subject_id' => 'required|exists:subjects,id',
            'chapter_id' => 'nullable|exists:content_chapters,id',
            'academic_stream_ids' => 'nullable|array',
            'academic_stream_ids.*' => 'exists:academic_streams,id',
            'title_ar' => 'required|string|max:255',
            'title_fr' => 'nullable|string|max:255',
            'description_ar' => 'nullable|string',
            'description_fr' => 'nullable|string',
            'cover_image_url' => 'nullable|url',
            'color' => 'nullable|string|max:7',
            'icon' => 'nullable|string|max:50',
            'difficulty_level' => 'required|in:easy,medium,hard',
            'estimated_study_minutes' => 'nullable|integer|min:1',
            'tags' => 'nullable|array',
            'is_premium' => 'boolean',
            'order' => 'nullable|integer',
        ]);

        try {
            // Remove stream ids from validated array (will be synced separately)
            $streamIds = $validated['academic_stream_ids'] ?? [];
            unset($validated['academic_stream_ids']);

            $validated['slug'] = Str::slug($validated['title_ar']) . '-' . Str::random(6);
            $validated['created_by'] = auth()->id();
            $validated['total_cards'] = 0;
            $validated['is_published'] = false;

            $deck = FlashcardDeck::create($validated);

            // Attach streams
            if (!empty($streamIds)) {
                $deck->academicStreams()->sync($streamIds);
            }

            return redirect()->route('admin.flashcard-decks.show', $deck->id)
                ->with('success', 'تم إنشاء مجموعة البطاقات بنجاح');

        } catch (\Exception $e) {
            return back()->withInput()
                ->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Show deck details
     */
    public function show($id)
    {
        $deck = FlashcardDeck::with(['subject', 'chapter', 'academicStreams', 'creator', 'flashcards'])
            ->findOrFail($id);

        // Card type distribution
        $cardTypes = $deck->flashcards->groupBy('card_type')->map->count();

        // Difficulty distribution
        $difficulties = $deck->flashcards->groupBy('difficulty_level')->map->count();

        return view('admin.flashcards.decks.show', compact('deck', 'cardTypes', 'difficulties'));
    }

    /**
     * Show edit form
     */
    public function edit($id)
    {
        $deck = FlashcardDeck::with(['subject.academicYear.academicPhase', 'academicStreams'])->findOrFail($id);
        $phases = AcademicPhase::orderBy('order')->get();

        return view('admin.flashcards.decks.edit', compact('deck', 'phases'));
    }

    /**
     * Update deck
     */
    public function update(Request $request, $id)
    {
        $deck = FlashcardDeck::findOrFail($id);

        $validated = $request->validate([
            'subject_id' => 'required|exists:subjects,id',
            'chapter_id' => 'nullable|exists:content_chapters,id',
            'academic_stream_ids' => 'nullable|array',
            'academic_stream_ids.*' => 'exists:academic_streams,id',
            'title_ar' => 'required|string|max:255',
            'title_fr' => 'nullable|string|max:255',
            'description_ar' => 'nullable|string',
            'description_fr' => 'nullable|string',
            'cover_image_url' => 'nullable|url',
            'color' => 'nullable|string|max:7',
            'icon' => 'nullable|string|max:50',
            'difficulty_level' => 'required|in:easy,medium,hard',
            'estimated_study_minutes' => 'nullable|integer|min:1',
            'tags' => 'nullable|array',
            'is_premium' => 'boolean',
            'order' => 'nullable|integer',
        ]);

        try {
            // Remove stream ids from validated array (will be synced separately)
            $streamIds = $validated['academic_stream_ids'] ?? [];
            unset($validated['academic_stream_ids']);

            $deck->update($validated);

            // Sync streams
            $deck->academicStreams()->sync($streamIds);

            return redirect()->route('admin.flashcard-decks.show', $deck->id)
                ->with('success', 'تم تحديث مجموعة البطاقات بنجاح');

        } catch (\Exception $e) {
            return back()->withInput()
                ->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Delete deck
     */
    public function destroy($id)
    {
        $deck = FlashcardDeck::findOrFail($id);

        try {
            // Soft delete will preserve flashcards
            $deck->delete();

            return redirect()->route('admin.flashcard-decks.index')
                ->with('success', 'تم حذف مجموعة البطاقات بنجاح');

        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Publish deck
     */
    public function publish($id)
    {
        $deck = FlashcardDeck::findOrFail($id);

        if ($deck->total_cards < 1) {
            return back()->with('error', 'لا يمكن نشر مجموعة فارغة. أضف بطاقات أولاً.');
        }

        $deck->update(['is_published' => true]);

        return back()->with('success', 'تم نشر مجموعة البطاقات بنجاح');
    }

    /**
     * Unpublish deck
     */
    public function unpublish($id)
    {
        $deck = FlashcardDeck::findOrFail($id);
        $deck->update(['is_published' => false]);

        return back()->with('success', 'تم إلغاء نشر مجموعة البطاقات');
    }

    /**
     * Duplicate deck
     */
    public function duplicate($id)
    {
        $deck = FlashcardDeck::with(['flashcards', 'academicStreams'])->findOrFail($id);

        try {
            // Create new deck
            $newDeck = $deck->replicate();
            $newDeck->title_ar = $deck->title_ar . ' (نسخة)';
            $newDeck->slug = Str::slug($newDeck->title_ar) . '-' . Str::random(6);
            $newDeck->is_published = false;
            $newDeck->created_by = auth()->id();
            $newDeck->total_cards = 0;
            $newDeck->save();

            // Copy streams
            $newDeck->academicStreams()->sync($deck->academicStreams->pluck('id')->toArray());

            // Duplicate cards
            foreach ($deck->flashcards as $card) {
                $newCard = $card->replicate();
                $newCard->deck_id = $newDeck->id;
                $newCard->save();
            }

            $newDeck->updateCardCount();

            return redirect()->route('admin.flashcard-decks.edit', $newDeck->id)
                ->with('success', 'تم نسخ مجموعة البطاقات بنجاح');

        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    // ========== AJAX Endpoints ==========

    /**
     * Get years by phase
     */
    public function getYearsByPhase($phaseId)
    {
        $years = AcademicYear::where('academic_phase_id', $phaseId)
            ->orderBy('order')
            ->get(['id', 'name_ar']);

        return response()->json($years);
    }

    /**
     * Get streams by year
     */
    public function getStreamsByYear($yearId)
    {
        $streams = AcademicStream::where('academic_year_id', $yearId)
            ->orderBy('order')
            ->get(['id', 'name_ar']);

        return response()->json($streams);
    }

    /**
     * Get subjects by year and stream
     */
    public function getSubjects(Request $request)
    {
        $query = Subject::where('is_active', true);

        if ($request->filled('year_id')) {
            $query->where('academic_year_id', $request->year_id);
        }

        if ($request->filled('stream_id')) {
            $query->forStream((int) $request->stream_id);
        }

        $subjects = $query->orderBy('name_ar')->get(['id', 'name_ar']);

        return response()->json($subjects);
    }

    /**
     * Get chapters for a subject
     */
    public function getChapters($subjectId)
    {
        $chapters = ContentChapter::where('subject_id', $subjectId)
            ->orderBy('order')
            ->get(['id', 'title_ar']);

        return response()->json($chapters);
    }
}
