<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\FlashcardService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FlashcardStatsController extends Controller
{
    protected FlashcardService $flashcardService;

    public function __construct(FlashcardService $flashcardService)
    {
        $this->flashcardService = $flashcardService;
    }

    /**
     * Get user flashcard statistics
     * GET /api/v1/flashcard-stats
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $deckId = $request->input('deck_id');

        $stats = $this->flashcardService->getUserStats($user, $deckId);

        return response()->json([
            'success' => true,
            'data' => [
                'stats' => $stats,
            ],
        ]);
    }

    /**
     * Get review forecast for upcoming days
     * GET /api/v1/flashcard-stats/forecast
     */
    public function forecast(Request $request): JsonResponse
    {
        $user = $request->user();
        $days = $request->input('days', 7);
        $days = min(max($days, 1), 30); // Clamp between 1 and 30

        $forecast = $this->flashcardService->getReviewForecast($user, $days);

        // Calculate totals
        $totalDue = array_sum(array_column($forecast, 'cards_due'));

        return response()->json([
            'success' => true,
            'data' => [
                'forecast' => $forecast,
                'summary' => [
                    'total_cards_due' => $totalDue,
                    'days_covered' => count($forecast),
                    'average_per_day' => $totalDue > 0 ? round($totalDue / count($forecast), 1) : 0,
                ],
            ],
        ]);
    }

    /**
     * Get review activity heatmap
     * GET /api/v1/flashcard-stats/heatmap
     */
    public function heatmap(Request $request): JsonResponse
    {
        $user = $request->user();
        $days = $request->input('days', 365);
        $days = min(max($days, 30), 365); // Clamp between 30 and 365

        $heatmap = $this->flashcardService->getReviewHeatmap($user, $days);

        // Calculate summary stats
        $counts = array_column($heatmap, 'count');
        $totalReviews = array_sum($counts);
        $activeDays = count(array_filter($heatmap, fn($day) => $day['count'] > 0));
        $maxReviewsInDay = !empty($counts) ? max($counts) : 0;

        return response()->json([
            'success' => true,
            'data' => [
                'heatmap' => $heatmap,
                'summary' => [
                    'total_reviews' => $totalReviews,
                    'active_days' => $activeDays,
                    'days_covered' => count($heatmap),
                    'max_reviews_in_day' => $maxReviewsInDay,
                    'average_per_active_day' => $activeDays > 0 ? round($totalReviews / $activeDays, 1) : 0,
                ],
            ],
        ]);
    }

    /**
     * Get stats for a specific deck
     * GET /api/v1/flashcard-stats/deck/{deckId}
     */
    public function deckStats(Request $request, int $deckId): JsonResponse
    {
        $user = $request->user();

        $stats = $this->flashcardService->getDeckStats($user, $deckId);

        return response()->json([
            'success' => true,
            'data' => $stats,
        ]);
    }

    /**
     * Get summary for today's reviews
     * GET /api/v1/flashcard-stats/today
     */
    public function todaySummary(Request $request): JsonResponse
    {
        $user = $request->user();

        $stats = $this->flashcardService->getUserStats($user);

        return response()->json([
            'success' => true,
            'data' => [
                'today' => [
                    'reviews_completed' => $stats['reviews_today'],
                    'sessions_completed' => $stats['sessions_today'],
                    'time_studied' => $stats['time_studied_today_formatted'],
                    'time_studied_seconds' => $stats['time_studied_today_seconds'],
                ],
                'streak' => [
                    'current' => $stats['current_streak'],
                    'longest' => $stats['longest_streak'],
                ],
                'overall' => [
                    'cards_due' => $stats['cards_due'] ?? 0,
                    'cards_mastered' => $stats['cards_mastered'] ?? 0,
                    'retention_rate' => $stats['retention_rate'] ?? 0,
                ],
            ],
        ]);
    }
}
