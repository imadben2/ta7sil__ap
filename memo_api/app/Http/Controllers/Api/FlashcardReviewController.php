<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Flashcard;
use App\Models\FlashcardReviewSession;
use App\Services\FlashcardService;
use App\Services\SpacedRepetitionService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class FlashcardReviewController extends Controller
{
    protected FlashcardService $flashcardService;
    protected SpacedRepetitionService $spacedRepetitionService;

    public function __construct(
        FlashcardService $flashcardService,
        SpacedRepetitionService $spacedRepetitionService
    ) {
        $this->flashcardService = $flashcardService;
        $this->spacedRepetitionService = $spacedRepetitionService;
    }

    /**
     * Get cards due for review
     * GET /api/v1/flashcards/due
     * OPTIMIZED: Pre-loads user progress to avoid N+1 queries
     */
    public function getDueCards(Request $request): JsonResponse
    {
        $user = $request->user();
        $deckId = $request->input('deck_id');
        $limit = $request->input('limit', 50);

        $dueCards = $this->spacedRepetitionService->getDueCards($user, $deckId, $limit);
        $newCards = $this->spacedRepetitionService->getNewCards($user, $deckId, 20);

        // OPTIMIZATION: Eager load user progress for all cards at once
        // This prevents N+1 queries (was 1 query per card, now just 1 query total)
        $allCardIds = $dueCards->pluck('id')->merge($newCards->pluck('id'))->unique()->toArray();

        $userProgressMap = [];
        if (!empty($allCardIds)) {
            $userProgressMap = \App\Models\UserFlashcardProgress::where('user_id', $user->id)
                ->whereIn('flashcard_id', $allCardIds)
                ->get()
                ->keyBy('flashcard_id');
        }

        // Format cards using pre-fetched progress (NO queries in loop)
        $formatCard = function ($card) use ($userProgressMap) {
            $progress = $userProgressMap->get($card->id);

            return [
                'id' => $card->id,
                'deck_id' => $card->deck_id,
                'card_type' => $card->card_type,
                'formatted_content' => $card->getFormattedContent(),
                'deck' => $card->deck ? [
                    'id' => $card->deck->id,
                    'title_ar' => $card->deck->title_ar,
                    'color' => $card->deck->color,
                ] : null,
                'review_data' => $progress ? [
                    'learning_state' => $progress->learning_state,
                    'days_overdue' => $progress->getOverdueDays(),
                    'interval' => $progress->interval,
                ] : null,
            ];
        };

        return response()->json([
            'success' => true,
            'data' => [
                'due_cards' => $dueCards->map($formatCard),
                'new_cards' => $newCards->map($formatCard),
                'summary' => [
                    'total_due' => $dueCards->count(),
                    'total_new' => $newCards->count(),
                    'total_available' => $dueCards->count() + $newCards->count(),
                ],
            ],
        ]);
    }

    /**
     * Get new cards (never studied)
     * GET /api/v1/flashcards/new
     */
    public function getNewCards(Request $request): JsonResponse
    {
        $user = $request->user();
        $deckId = $request->input('deck_id');
        $limit = $request->input('limit', 20);

        $cards = $this->spacedRepetitionService->getNewCards($user, $deckId, $limit);

        return response()->json([
            'success' => true,
            'data' => [
                'new_cards' => $cards->map(function ($card) {
                    return [
                        'id' => $card->id,
                        'deck_id' => $card->deck_id,
                        'card_type' => $card->card_type,
                        'formatted_content' => $card->getFormattedContent(),
                        'deck' => $card->deck ? [
                            'id' => $card->deck->id,
                            'title_ar' => $card->deck->title_ar,
                            'color' => $card->deck->color,
                        ] : null,
                    ];
                }),
                'count' => $cards->count(),
            ],
        ]);
    }

    /**
     * Start a review session
     * POST /api/v1/flashcard-reviews/start
     */
    public function start(Request $request): JsonResponse
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'deck_id' => 'nullable|integer|exists:flashcard_decks,id',
            'card_limit' => 'nullable|integer|min:1|max:100',
            'browse_mode' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'بيانات غير صالحة',
                'errors' => $validator->errors(),
            ], 422);
        }

        $deckId = $request->input('deck_id');
        $cardLimit = $request->input('card_limit');
        $browseMode = $request->boolean('browse_mode', false);

        // Start session
        $session = $this->flashcardService->startReviewSession($user, $deckId, $cardLimit, $browseMode);

        // Get cards for review or browse
        $cardsData = $this->flashcardService->getCardsForSession($user, $deckId, $browseMode);

        return response()->json([
            'success' => true,
            'data' => [
                'session' => [
                    'id' => $session->id,
                    'deck_id' => $session->deck_id,
                    'started_at' => $session->started_at->toIso8601String(),
                    'status' => $session->status,
                    'browse_mode' => $browseMode,
                ],
                'cards' => $cardsData['cards']->map(function ($card) {
                    return [
                        'id' => $card->id,
                        'deck_id' => $card->deck_id,
                        'card_type' => $card->card_type,
                        'front_text_ar' => $card->front_text_ar ?? '',
                        'front_text_fr' => $card->front_text_fr,
                        'front_image_url' => $card->front_image_url,
                        'front_audio_url' => $card->front_audio_url,
                        'back_text_ar' => $card->back_text_ar ?? '',
                        'back_text_fr' => $card->back_text_fr,
                        'back_image_url' => $card->back_image_url,
                        'back_audio_url' => $card->back_audio_url,
                        'cloze_template' => $card->cloze_template,
                        'hint_ar' => $card->hint_ar,
                        'explanation_ar' => $card->explanation_ar,
                        'difficulty_level' => $card->difficulty_level ?? 'medium',
                        'order' => $card->order ?? 0,
                        'formatted_content' => $card->formatted_content,
                        'is_new' => $card->is_new ?? false,
                        'next_interval_preview' => $card->next_interval_preview ?? null,
                    ];
                }),
                'summary' => $cardsData['summary'],
            ],
        ]);
    }

    /**
     * Get current in-progress session
     * GET /api/v1/flashcard-reviews/current
     */
    public function getCurrentSession(Request $request): JsonResponse
    {
        $user = $request->user();

        $session = $this->flashcardService->getCurrentSession($user);

        if (!$session) {
            return response()->json([
                'success' => true,
                'data' => [
                    'session' => null,
                    'message' => 'لا توجد جلسة مراجعة نشطة',
                ],
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'session' => [
                    'id' => $session->id,
                    'deck_id' => $session->deck_id,
                    'deck' => $session->deck,
                    'started_at' => $session->started_at->toIso8601String(),
                    'status' => $session->status,
                    'progress' => [
                        'cards_reviewed' => $session->total_cards_reviewed,
                        'again_count' => $session->again_count,
                        'hard_count' => $session->hard_count,
                        'good_count' => $session->good_count,
                        'easy_count' => $session->easy_count,
                    ],
                ],
            ],
        ]);
    }

    /**
     * Submit answer for a card
     * POST /api/v1/flashcard-reviews/{sessionId}/answer
     */
    public function submitAnswer(Request $request, int $sessionId): JsonResponse
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'card_id' => 'required|integer|exists:flashcards,id',
            'response' => 'required|string|in:again,hard,good,easy',
            'response_time_seconds' => 'nullable|integer|min:0|max:3600',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'بيانات غير صالحة',
                'errors' => $validator->errors(),
            ], 422);
        }

        // Find session
        $session = FlashcardReviewSession::where('id', $sessionId)
            ->where('user_id', $user->id)
            ->inProgress()
            ->first();

        if (!$session) {
            return response()->json([
                'success' => false,
                'message' => 'الجلسة غير موجودة أو منتهية',
            ], 404);
        }

        // Find card
        $card = Flashcard::findOrFail($request->input('card_id'));

        // Submit answer
        $result = $this->flashcardService->submitAnswer(
            $session,
            $card,
            $request->input('response'),
            $request->input('response_time_seconds')
        );

        return response()->json([
            'success' => true,
            'data' => $result,
        ]);
    }

    /**
     * Complete a review session
     * POST /api/v1/flashcard-reviews/{sessionId}/complete
     */
    public function complete(Request $request, int $sessionId): JsonResponse
    {
        $user = $request->user();

        $session = FlashcardReviewSession::where('id', $sessionId)
            ->where('user_id', $user->id)
            ->first();

        if (!$session) {
            return response()->json([
                'success' => false,
                'message' => 'الجلسة غير موجودة',
            ], 404);
        }

        if ($session->isCompleted()) {
            return response()->json([
                'success' => true,
                'data' => [
                    'session' => $session,
                    'stats' => $session->getStats(),
                    'message' => 'الجلسة مكتملة بالفعل',
                ],
            ]);
        }

        $session = $this->flashcardService->completeSession($session);

        return response()->json([
            'success' => true,
            'data' => [
                'session' => [
                    'id' => $session->id,
                    'deck_id' => $session->deck_id,
                    'deck' => $session->deck,
                    'started_at' => $session->started_at->toIso8601String(),
                    'completed_at' => $session->completed_at->toIso8601String(),
                    'status' => $session->status,
                ],
                'stats' => $session->getStats(),
                'message' => 'تم إكمال الجلسة بنجاح!',
            ],
        ]);
    }

    /**
     * Abandon a review session
     * POST /api/v1/flashcard-reviews/{sessionId}/abandon
     */
    public function abandon(Request $request, int $sessionId): JsonResponse
    {
        $user = $request->user();

        $session = FlashcardReviewSession::where('id', $sessionId)
            ->where('user_id', $user->id)
            ->inProgress()
            ->first();

        if (!$session) {
            return response()->json([
                'success' => false,
                'message' => 'الجلسة غير موجودة أو منتهية بالفعل',
            ], 404);
        }

        $session = $this->flashcardService->abandonSession($session);

        return response()->json([
            'success' => true,
            'data' => [
                'session' => $session,
                'message' => 'تم إلغاء الجلسة',
            ],
        ]);
    }

    /**
     * Get review history
     * GET /api/v1/flashcard-reviews/history
     */
    public function history(Request $request): JsonResponse
    {
        $user = $request->user();
        $deckId = $request->input('deck_id');
        $perPage = $request->input('per_page', 20);

        $history = $this->flashcardService->getReviewHistory($user, $deckId, $perPage);

        return response()->json([
            'success' => true,
            'data' => [
                'sessions' => $history->items(),
                'meta' => [
                    'current_page' => $history->currentPage(),
                    'last_page' => $history->lastPage(),
                    'per_page' => $history->perPage(),
                    'total' => $history->total(),
                ],
            ],
        ]);
    }
}
