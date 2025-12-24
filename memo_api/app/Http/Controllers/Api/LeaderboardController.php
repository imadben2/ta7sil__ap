<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\LeaderboardService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class LeaderboardController extends Controller
{
    protected LeaderboardService $leaderboardService;

    public function __construct(LeaderboardService $leaderboardService)
    {
        $this->leaderboardService = $leaderboardService;
    }

    /**
     * Get leaderboard by user's academic stream
     *
     * GET /api/v1/leaderboard/stream
     * Query params:
     *   - period: 'week' | 'month' | 'all' (default: 'all')
     *   - limit: int (default: 50, max: 100)
     */
    public function byStream(Request $request): JsonResponse
    {
        $request->validate([
            'period' => 'nullable|in:week,month,all',
            'limit' => 'nullable|integer|min:1|max:100',
        ]);

        $user = $request->user();
        $period = $request->input('period', 'all');
        $limit = $request->input('limit', 50);

        $result = $this->leaderboardService->getStreamLeaderboard(
            $user,
            $period,
            $limit
        );

        return response()->json([
            'success' => true,
            'data' => $result,
            'meta' => [
                'period' => $period,
                'limit' => $limit,
            ],
        ]);
    }

    /**
     * Get leaderboard by subject
     *
     * GET /api/v1/leaderboard/subject/{subjectId}
     * Query params:
     *   - period: 'week' | 'month' | 'all' (default: 'all')
     *   - limit: int (default: 50, max: 100)
     */
    public function bySubject(Request $request, int $subjectId): JsonResponse
    {
        $request->validate([
            'period' => 'nullable|in:week,month,all',
            'limit' => 'nullable|integer|min:1|max:100',
        ]);

        $user = $request->user();
        $period = $request->input('period', 'all');
        $limit = $request->input('limit', 50);

        $result = $this->leaderboardService->getSubjectLeaderboard(
            $user,
            $subjectId,
            $period,
            $limit
        );

        return response()->json([
            'success' => true,
            'data' => $result,
            'meta' => [
                'period' => $period,
                'limit' => $limit,
                'subject_id' => $subjectId,
            ],
        ]);
    }
}
