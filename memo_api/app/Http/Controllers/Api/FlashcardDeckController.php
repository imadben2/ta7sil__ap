<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\FlashcardDeck;
use App\Services\FlashcardService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FlashcardDeckController extends Controller
{
    protected FlashcardService $flashcardService;

    public function __construct(FlashcardService $flashcardService)
    {
        $this->flashcardService = $flashcardService;
    }

    /**
     * Get list of flashcard decks
     * GET /api/v1/flashcard-decks
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $filters = [
            'subject_id' => $request->input('subject_id'),
            'chapter_id' => $request->input('chapter_id'),
            'stream_id' => $request->input('stream_id', $user?->academicProfile?->academic_stream_id),
            'is_premium' => $request->has('is_premium') ? $request->boolean('is_premium') : null,
            'difficulty' => $request->input('difficulty'),
            'search' => $request->input('search'),
            'per_page' => $request->input('per_page', 20),
        ];

        // If user is not authenticated, return basic deck info
        if (!$user) {
            $decks = FlashcardDeck::query()
                ->published()
                ->with(['subject:id,name_ar,color,icon', 'chapter:id,title_ar'])
                ->withCount(['activeFlashcards as total_cards'])
                ->when($filters['subject_id'], fn($q, $id) => $q->bySubject($id))
                ->when($filters['chapter_id'], fn($q, $id) => $q->byChapter($id))
                ->when($filters['stream_id'], fn($q, $id) => $q->forStream($id))
                ->when($filters['difficulty'], fn($q, $d) => $q->where('difficulty_level', $d))
                ->when($filters['search'], fn($q, $s) => $q->search($s))
                ->orderBy('order')
                ->paginate($filters['per_page']);

            return response()->json([
                'success' => true,
                'data' => [
                    'decks' => $decks->items(),
                    'meta' => [
                        'current_page' => $decks->currentPage(),
                        'last_page' => $decks->lastPage(),
                        'per_page' => $decks->perPage(),
                        'total' => $decks->total(),
                    ],
                ],
            ]);
        }

        $decks = $this->flashcardService->getDecksForUser($user, $filters);

        return response()->json([
            'success' => true,
            'data' => [
                'decks' => $decks->items(),
                'meta' => [
                    'current_page' => $decks->currentPage(),
                    'last_page' => $decks->lastPage(),
                    'per_page' => $decks->perPage(),
                    'total' => $decks->total(),
                ],
            ],
        ]);
    }

    /**
     * Get a single deck with cards
     * GET /api/v1/flashcard-decks/{id}
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $user = $request->user();

        if (!$user) {
            // Return basic deck info for unauthenticated users
            $deck = FlashcardDeck::query()
                ->published()
                ->with([
                    'subject:id,name_ar,color,icon',
                    'chapter:id,title_ar',
                    'activeFlashcards' => fn($q) => $q->orderBy('order')->limit(3), // Preview only
                ])
                ->findOrFail($id);

            return response()->json([
                'success' => true,
                'data' => [
                    'deck' => $deck,
                    'preview_mode' => true,
                    'message' => 'سجل الدخول لبدء المراجعة',
                ],
            ]);
        }

        $deck = $this->flashcardService->getDeckWithCards($id, $user);

        return response()->json([
            'success' => true,
            'data' => [
                'deck' => $deck,
                'preview_mode' => false,
            ],
        ]);
    }

    /**
     * Get cards in a deck with pagination
     * GET /api/v1/flashcard-decks/{id}/cards
     */
    public function cards(Request $request, int $id): JsonResponse
    {
        $user = $request->user();

        $deck = FlashcardDeck::published()->findOrFail($id);

        $perPage = $request->input('per_page', 50);

        $cards = $deck->activeFlashcards()
            ->orderBy('order')
            ->paginate($perPage);

        // Attach user progress if authenticated
        if ($user) {
            $cards->getCollection()->transform(function ($card) use ($user) {
                $card->formatted_content = $card->getFormattedContent();
                $progress = $card->userProgress()->where('user_id', $user->id)->first();

                $card->user_review_data = $progress ? [
                    'learning_state' => $progress->learning_state,
                    'next_review_date' => $progress->next_review_date?->toDateString(),
                    'interval' => $progress->interval,
                    'total_reviews' => $progress->total_reviews,
                    'is_due' => $progress->isDue(),
                ] : null;

                return $card;
            });
        }

        return response()->json([
            'success' => true,
            'data' => [
                'deck_id' => $deck->id,
                'deck_title' => $deck->title_ar,
                'cards' => $cards->items(),
                'meta' => [
                    'current_page' => $cards->currentPage(),
                    'last_page' => $cards->lastPage(),
                    'per_page' => $cards->perPage(),
                    'total' => $cards->total(),
                ],
            ],
        ]);
    }

    /**
     * Get decks that have due cards for the user
     * GET /api/v1/flashcard-decks/due
     */
    public function withDueCards(Request $request): JsonResponse
    {
        $user = $request->user();

        $decks = $this->flashcardService->getDecksWithDueCards($user);

        return response()->json([
            'success' => true,
            'data' => [
                'decks' => $decks,
                'total_decks_with_due' => $decks->count(),
            ],
        ]);
    }
}
