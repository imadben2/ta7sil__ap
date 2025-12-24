<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\FlashcardDeck;
use App\Models\Flashcard;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Yajra\DataTables\Facades\DataTables;

class FlashcardController extends Controller
{
    /**
     * Display cards for a deck
     */
    public function index(Request $request, $deckId)
    {
        $deck = FlashcardDeck::with('subject')->findOrFail($deckId);

        if ($request->ajax()) {
            return $this->getDataTable($request, $deckId);
        }

        return view('admin.flashcards.cards.index', compact('deck'));
    }

    /**
     * Get DataTables data
     */
    private function getDataTable(Request $request, $deckId)
    {
        $query = Flashcard::where('deck_id', $deckId)->orderBy('order');

        // Filters
        if ($request->filled('type')) {
            $query->where('card_type', $request->type);
        }

        if ($request->filled('difficulty')) {
            $query->where('difficulty_level', $request->difficulty);
        }

        if ($request->filled('status')) {
            if ($request->status === 'active') {
                $query->where('is_active', true);
            } elseif ($request->status === 'inactive') {
                $query->where('is_active', false);
            }
        }

        return DataTables::of($query)
            ->addColumn('order_display', function($card) {
                return '<span class="font-bold text-gray-600">#' . $card->order . '</span>';
            })
            ->addColumn('type', function($card) {
                $types = [
                    'basic' => ['text' => 'أساسي', 'color' => 'blue', 'icon' => 'fa-file-alt'],
                    'cloze' => ['text' => 'إملاء', 'color' => 'purple', 'icon' => 'fa-fill-drip'],
                    'image' => ['text' => 'صورة', 'color' => 'green', 'icon' => 'fa-image'],
                    'audio' => ['text' => 'صوت', 'color' => 'orange', 'icon' => 'fa-volume-up'],
                ];
                $type = $types[$card->card_type] ?? ['text' => $card->card_type, 'color' => 'gray', 'icon' => 'fa-question'];
                return '<span class="px-2 py-1 bg-' . $type['color'] . '-100 text-' . $type['color'] . '-700 rounded-full text-xs font-semibold">
                    <i class="fas ' . $type['icon'] . ' ml-1"></i>' . $type['text'] . '</span>';
            })
            ->addColumn('front', function($card) {
                $text = $card->card_type === 'cloze' ? $card->cloze_template : $card->front_text_ar;
                $text = Str($text)->limit(80);
                $html = '<div class="text-gray-900 text-sm">' . e($text) . '</div>';

                if ($card->front_image_url) {
                    $html .= '<span class="text-xs text-blue-500"><i class="fas fa-image"></i> مع صورة</span>';
                }
                if ($card->front_audio_url) {
                    $html .= '<span class="text-xs text-orange-500 mr-2"><i class="fas fa-volume-up"></i> مع صوت</span>';
                }

                return $html;
            })
            ->addColumn('back', function($card) {
                $text = Str($card->back_text_ar)->limit(60);
                return '<div class="text-gray-600 text-sm">' . e($text) . '</div>';
            })
            ->addColumn('difficulty', function($card) {
                $badges = [
                    'easy' => '<span class="px-2 py-1 bg-green-100 text-green-700 rounded-full text-xs font-semibold">سهل</span>',
                    'medium' => '<span class="px-2 py-1 bg-yellow-100 text-yellow-700 rounded-full text-xs font-semibold">متوسط</span>',
                    'hard' => '<span class="px-2 py-1 bg-red-100 text-red-700 rounded-full text-xs font-semibold">صعب</span>',
                ];
                return $badges[$card->difficulty_level] ?? '-';
            })
            ->addColumn('status', function($card) {
                if ($card->is_active) {
                    return '<span class="px-2 py-1 bg-green-100 text-green-700 rounded-full text-xs font-bold">نشط</span>';
                } else {
                    return '<span class="px-2 py-1 bg-gray-100 text-gray-500 rounded-full text-xs font-bold">غير نشط</span>';
                }
            })
            ->addColumn('actions', function($card) {
                return '
                    <div class="flex gap-1">
                        <button onclick="editCard(' . $card->id . ')"
                           class="px-2 py-1 bg-yellow-100 hover:bg-yellow-200 text-yellow-700 rounded text-xs font-semibold transition">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button onclick="deleteCard(' . $card->id . ')"
                           class="px-2 py-1 bg-red-100 hover:bg-red-200 text-red-700 rounded text-xs font-semibold transition">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                ';
            })
            ->rawColumns(['order_display', 'type', 'front', 'back', 'difficulty', 'status', 'actions'])
            ->make(true);
    }

    /**
     * Show create card form (AJAX modal)
     */
    public function create($deckId)
    {
        $deck = FlashcardDeck::findOrFail($deckId);

        if (request()->ajax()) {
            return view('admin.flashcards.cards.partials.form', [
                'deck' => $deck,
                'card' => null,
            ])->render();
        }

        return view('admin.flashcards.cards.create', compact('deck'));
    }

    /**
     * Store new card
     */
    public function store(Request $request, $deckId)
    {
        $deck = FlashcardDeck::findOrFail($deckId);

        $validated = $request->validate([
            'card_type' => 'required|in:basic,cloze,image,audio',
            'front_text_ar' => 'required_unless:card_type,cloze|nullable|string',
            'front_text_fr' => 'nullable|string',
            'front_image_url' => 'nullable|string', // Can be URL or uploaded file path
            'front_audio_url' => 'nullable|string', // Can be URL or uploaded file path
            'back_text_ar' => 'required|string',
            'back_text_fr' => 'nullable|string',
            'back_image_url' => 'nullable|string', // Can be URL or uploaded file path
            'back_audio_url' => 'nullable|string', // Can be URL or uploaded file path
            'cloze_template' => 'required_if:card_type,cloze|nullable|string',
            'hint_ar' => 'nullable|string|max:500',
            'hint_fr' => 'nullable|string|max:500',
            'explanation_ar' => 'nullable|string',
            'explanation_fr' => 'nullable|string',
            'tags' => 'nullable|array',
            'difficulty_level' => 'nullable|in:easy,medium,hard',
        ]);

        try {
            // Get next order
            $maxOrder = Flashcard::where('deck_id', $deckId)->max('order') ?? 0;
            $validated['deck_id'] = $deckId;
            $validated['order'] = $maxOrder + 1;
            $validated['is_active'] = true;

            // Parse cloze deletions if cloze type
            if ($validated['card_type'] === 'cloze' && !empty($validated['cloze_template'])) {
                $validated['cloze_deletions'] = $this->parseClozeTemplate($validated['cloze_template']);
            }

            $card = Flashcard::create($validated);
            $deck->updateCardCount();

            if ($request->ajax()) {
                return response()->json([
                    'success' => true,
                    'message' => 'تم إضافة البطاقة بنجاح',
                    'card' => $card,
                ]);
            }

            return back()->with('success', 'تم إضافة البطاقة بنجاح');

        } catch (\Exception $e) {
            if ($request->ajax()) {
                return response()->json([
                    'success' => false,
                    'message' => 'حدث خطأ: ' . $e->getMessage(),
                ], 400);
            }
            return back()->withInput()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Show card details (AJAX)
     */
    public function show($deckId, $cardId)
    {
        $card = Flashcard::where('deck_id', $deckId)->findOrFail($cardId);

        if (request()->ajax()) {
            return response()->json($card);
        }

        $deck = FlashcardDeck::findOrFail($deckId);
        return view('admin.flashcards.cards.show', compact('deck', 'card'));
    }

    /**
     * Show edit form (AJAX)
     */
    public function edit($deckId, $cardId)
    {
        $deck = FlashcardDeck::findOrFail($deckId);
        $card = Flashcard::where('deck_id', $deckId)->findOrFail($cardId);

        if (request()->ajax()) {
            return view('admin.flashcards.cards.partials.form', [
                'deck' => $deck,
                'card' => $card,
            ])->render();
        }

        return view('admin.flashcards.cards.edit', compact('deck', 'card'));
    }

    /**
     * Update card
     */
    public function update(Request $request, $deckId, $cardId)
    {
        $card = Flashcard::where('deck_id', $deckId)->findOrFail($cardId);

        $validated = $request->validate([
            'card_type' => 'required|in:basic,cloze,image,audio',
            'front_text_ar' => 'required_unless:card_type,cloze|nullable|string',
            'front_text_fr' => 'nullable|string',
            'front_image_url' => 'nullable|string', // Can be URL or uploaded file path
            'front_audio_url' => 'nullable|string', // Can be URL or uploaded file path
            'back_text_ar' => 'required|string',
            'back_text_fr' => 'nullable|string',
            'back_image_url' => 'nullable|string', // Can be URL or uploaded file path
            'back_audio_url' => 'nullable|string', // Can be URL or uploaded file path
            'cloze_template' => 'required_if:card_type,cloze|nullable|string',
            'hint_ar' => 'nullable|string|max:500',
            'hint_fr' => 'nullable|string|max:500',
            'explanation_ar' => 'nullable|string',
            'explanation_fr' => 'nullable|string',
            'tags' => 'nullable|array',
            'difficulty_level' => 'nullable|in:easy,medium,hard',
            'is_active' => 'boolean',
        ]);

        try {
            // Parse cloze deletions if cloze type
            if ($validated['card_type'] === 'cloze' && !empty($validated['cloze_template'])) {
                $validated['cloze_deletions'] = $this->parseClozeTemplate($validated['cloze_template']);
            }

            $card->update($validated);

            if ($request->ajax()) {
                return response()->json([
                    'success' => true,
                    'message' => 'تم تحديث البطاقة بنجاح',
                    'card' => $card->fresh(),
                ]);
            }

            return back()->with('success', 'تم تحديث البطاقة بنجاح');

        } catch (\Exception $e) {
            if ($request->ajax()) {
                return response()->json([
                    'success' => false,
                    'message' => 'حدث خطأ: ' . $e->getMessage(),
                ], 400);
            }
            return back()->withInput()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Delete card
     */
    public function destroy($deckId, $cardId)
    {
        $deck = FlashcardDeck::findOrFail($deckId);
        $card = Flashcard::where('deck_id', $deckId)->findOrFail($cardId);

        try {
            $card->delete();
            $deck->updateCardCount();

            if (request()->ajax()) {
                return response()->json([
                    'success' => true,
                    'message' => 'تم حذف البطاقة بنجاح',
                ]);
            }

            return back()->with('success', 'تم حذف البطاقة بنجاح');

        } catch (\Exception $e) {
            if (request()->ajax()) {
                return response()->json([
                    'success' => false,
                    'message' => 'حدث خطأ: ' . $e->getMessage(),
                ], 400);
            }
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Toggle card active status
     */
    public function toggleActive($deckId, $cardId)
    {
        $card = Flashcard::where('deck_id', $deckId)->findOrFail($cardId);
        $card->update(['is_active' => !$card->is_active]);

        $deck = FlashcardDeck::findOrFail($deckId);
        $deck->updateCardCount();

        return response()->json([
            'success' => true,
            'is_active' => $card->is_active,
            'message' => $card->is_active ? 'تم تفعيل البطاقة' : 'تم إلغاء تفعيل البطاقة',
        ]);
    }

    /**
     * Reorder cards
     */
    public function reorder(Request $request, $deckId)
    {
        $validated = $request->validate([
            'order' => 'required|array',
            'order.*' => 'integer|exists:flashcards,id',
        ]);

        try {
            foreach ($validated['order'] as $index => $cardId) {
                Flashcard::where('id', $cardId)
                    ->where('deck_id', $deckId)
                    ->update(['order' => $index + 1]);
            }

            return response()->json([
                'success' => true,
                'message' => 'تم إعادة ترتيب البطاقات بنجاح',
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ: ' . $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Bulk actions
     */
    public function bulkAction(Request $request, $deckId)
    {
        $validated = $request->validate([
            'action' => 'required|in:activate,deactivate,delete',
            'card_ids' => 'required|array',
            'card_ids.*' => 'integer|exists:flashcards,id',
        ]);

        $deck = FlashcardDeck::findOrFail($deckId);

        try {
            $query = Flashcard::where('deck_id', $deckId)
                ->whereIn('id', $validated['card_ids']);

            switch ($validated['action']) {
                case 'activate':
                    $query->update(['is_active' => true]);
                    $message = 'تم تفعيل البطاقات المحددة';
                    break;

                case 'deactivate':
                    $query->update(['is_active' => false]);
                    $message = 'تم إلغاء تفعيل البطاقات المحددة';
                    break;

                case 'delete':
                    $query->delete();
                    $message = 'تم حذف البطاقات المحددة';
                    break;
            }

            $deck->updateCardCount();

            return response()->json([
                'success' => true,
                'message' => $message,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ: ' . $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Parse cloze template and extract deletions
     */
    private function parseClozeTemplate(string $template): array
    {
        $deletions = [];
        $pattern = '/\{\{(c\d+)::([^}:]+)(?:::([^}]+))?\}\}/';

        preg_match_all($pattern, $template, $matches, PREG_SET_ORDER);

        foreach ($matches as $match) {
            $deletions[] = [
                'id' => $match[1],
                'answer' => $match[2],
                'hint' => $match[3] ?? null,
            ];
        }

        return $deletions;
    }

    /**
     * Upload image for flashcard
     */
    public function uploadImage(Request $request)
    {
        $request->validate([
            'image' => 'required|image|mimes:jpeg,png,jpg,gif,webp|max:5120', // 5MB max
            'type' => 'required|in:front,back',
        ]);

        try {
            $file = $request->file('image');
            $filename = 'flashcard_' . time() . '_' . uniqid() . '.' . $file->getClientOriginalExtension();

            // Store in public/flashcards directory
            $path = $file->storeAs('flashcards', $filename, 'public');

            $url = Storage::disk('public')->url($path);

            return response()->json([
                'success' => true,
                'url' => $url,
                'path' => $path,
                'message' => 'تم رفع الصورة بنجاح',
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء رفع الصورة: ' . $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Upload audio for flashcard
     */
    public function uploadAudio(Request $request)
    {
        $request->validate([
            'audio' => 'required|mimes:mp3,wav,ogg,m4a|max:10240', // 10MB max
            'type' => 'required|in:front,back',
        ]);

        try {
            $file = $request->file('audio');
            $filename = 'flashcard_audio_' . time() . '_' . uniqid() . '.' . $file->getClientOriginalExtension();

            // Store in public/flashcards/audio directory
            $path = $file->storeAs('flashcards/audio', $filename, 'public');

            $url = Storage::disk('public')->url($path);

            return response()->json([
                'success' => true,
                'url' => $url,
                'path' => $path,
                'message' => 'تم رفع الملف الصوتي بنجاح',
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء رفع الملف الصوتي: ' . $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Delete uploaded file
     */
    public function deleteFile(Request $request)
    {
        $request->validate([
            'path' => 'required|string',
        ]);

        try {
            $path = $request->path;

            // Security: ensure the path is within flashcards directory
            if (!str_starts_with($path, 'flashcards/')) {
                return response()->json([
                    'success' => false,
                    'message' => 'مسار غير صالح',
                ], 400);
            }

            if (Storage::disk('public')->exists($path)) {
                Storage::disk('public')->delete($path);
            }

            return response()->json([
                'success' => true,
                'message' => 'تم حذف الملف بنجاح',
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء حذف الملف: ' . $e->getMessage(),
            ], 400);
        }
    }
}
