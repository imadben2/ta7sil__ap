<?php

namespace App\Services;

use App\Models\User;
use App\Models\Subject;
use App\Models\QuizAttempt;
use App\Models\UserAcademicProfile;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class LeaderboardService
{
    /**
     * Get leaderboard by academic stream
     * Returns rankings of users in the same academic stream
     */
    public function getStreamLeaderboard(User $user, string $period = 'all', int $limit = 50): array
    {
        $academicProfile = $user->academicProfile;

        if (!$academicProfile || !$academicProfile->academic_stream_id) {
            return $this->emptyLeaderboard($user);
        }

        $streamId = $academicProfile->academic_stream_id;
        $yearId = $academicProfile->academic_year_id;
        $dateFilter = $this->getDateFilter($period);

        // Get users in same stream and year with their quiz scores
        $query = DB::table('users')
            ->join('user_academic_profiles', 'users.id', '=', 'user_academic_profiles.user_id')
            ->leftJoin('quiz_attempts', function ($join) use ($dateFilter) {
                $join->on('users.id', '=', 'quiz_attempts.user_id')
                    ->where('quiz_attempts.status', '=', 'completed');
                if ($dateFilter) {
                    $join->where('quiz_attempts.completed_at', '>=', $dateFilter);
                }
            })
            ->where('user_academic_profiles.academic_stream_id', $streamId)
            ->where('user_academic_profiles.academic_year_id', $yearId)
            ->where('users.role', 'student')
            ->where('users.is_active', true)
            ->select(
                'users.id',
                'users.name',
                'users.photo_url as avatar',
                'users.total_points',
                DB::raw('COALESCE(AVG(quiz_attempts.score_percentage), 0) as average_score'),
                DB::raw('COALESCE(MAX(quiz_attempts.score_percentage), 0) as best_score'),
                DB::raw('COUNT(quiz_attempts.id) as total_attempts')
            )
            ->groupBy('users.id', 'users.name', 'users.photo_url', 'users.total_points')
            ->havingRaw('COUNT(quiz_attempts.id) > 0') // Only users with attempts
            ->orderByDesc('average_score')
            ->orderByDesc('total_attempts')
            ->limit($limit)
            ->get();

        return $this->formatLeaderboard($query, $user, 'stream');
    }

    /**
     * Get leaderboard by subject
     * Returns rankings of users for a specific subject
     */
    public function getSubjectLeaderboard(User $user, int $subjectId, string $period = 'all', int $limit = 50): array
    {
        $dateFilter = $this->getDateFilter($period);

        // Validate subject exists
        $subject = Subject::find($subjectId);
        if (!$subject) {
            return $this->emptyLeaderboard($user, 'subject');
        }

        // Get users with quiz attempts for this subject
        $query = DB::table('users')
            ->join('quiz_attempts', 'users.id', '=', 'quiz_attempts.user_id')
            ->join('quizzes', 'quiz_attempts.quiz_id', '=', 'quizzes.id')
            ->where('quizzes.subject_id', $subjectId)
            ->where('quiz_attempts.status', 'completed')
            ->where('users.role', 'student')
            ->where('users.is_active', true)
            ->when($dateFilter, function ($q) use ($dateFilter) {
                $q->where('quiz_attempts.completed_at', '>=', $dateFilter);
            })
            ->select(
                'users.id',
                'users.name',
                'users.photo_url as avatar',
                'users.total_points',
                DB::raw('COALESCE(AVG(quiz_attempts.score_percentage), 0) as average_score'),
                DB::raw('COALESCE(MAX(quiz_attempts.score_percentage), 0) as best_score'),
                DB::raw('COUNT(quiz_attempts.id) as total_attempts')
            )
            ->groupBy('users.id', 'users.name', 'users.photo_url', 'users.total_points')
            ->orderByDesc('average_score')
            ->orderByDesc('total_attempts')
            ->limit($limit)
            ->get();

        $result = $this->formatLeaderboard($query, $user, 'subject');
        $result['subject'] = [
            'id' => $subject->id,
            'name_ar' => $subject->name_ar,
            'color' => $subject->color,
            'icon' => $subject->icon,
        ];

        return $result;
    }

    /**
     * Get date filter based on period
     */
    protected function getDateFilter(string $period): ?Carbon
    {
        return match ($period) {
            'week' => Carbon::now()->subDays(7),
            'month' => Carbon::now()->subDays(30),
            default => null, // 'all' - no date filter
        };
    }

    /**
     * Format leaderboard data for response
     */
    protected function formatLeaderboard($rankings, User $currentUser, string $type = 'stream'): array
    {
        $entries = [];
        $currentUserRank = null;
        $currentUserEntry = null;

        foreach ($rankings as $index => $user) {
            $rank = $index + 1;
            $name = $user->name ?? 'مستخدم ' . $user->id;

            $entry = [
                'rank' => $rank,
                'user_id' => $user->id,
                'name' => $name,
                'avatar' => $user->avatar,
                'average_score' => round((float) $user->average_score, 1),
                'best_score' => round((float) $user->best_score, 1),
                'total_attempts' => (int) $user->total_attempts,
                'total_points' => (int) ($user->total_points ?? 0),
                'is_current_user' => $user->id === $currentUser->id,
            ];

            $entries[] = $entry;

            if ($user->id === $currentUser->id) {
                $currentUserRank = $rank;
                $currentUserEntry = $entry;
            }
        }

        // Get top 3 for podium
        $podium = array_slice($entries, 0, 3);

        // If current user is not in the list, try to get their rank
        if ($currentUserRank === null) {
            $currentUserData = $this->getCurrentUserRankData($currentUser, $type);
            if ($currentUserData) {
                $currentUserEntry = $currentUserData;
            }
        }

        return [
            'type' => $type,
            'podium' => $podium,
            'rankings' => $entries,
            'current_user' => [
                'rank' => $currentUserRank,
                'entry' => $currentUserEntry,
                'in_list' => $currentUserRank !== null,
            ],
            'total_participants' => count($entries),
        ];
    }

    /**
     * Get current user's rank data if not in the top list
     */
    protected function getCurrentUserRankData(User $user, string $type): ?array
    {
        // Get user's quiz stats
        $stats = DB::table('quiz_attempts')
            ->where('user_id', $user->id)
            ->where('status', 'completed')
            ->select(
                DB::raw('AVG(score_percentage) as average_score'),
                DB::raw('MAX(score_percentage) as best_score'),
                DB::raw('COUNT(*) as total_attempts')
            )
            ->first();

        if (!$stats || $stats->total_attempts == 0) {
            return null;
        }

        $name = $user->name ?? 'مستخدم ' . $user->id;

        return [
            'rank' => null, // Not in top list
            'user_id' => $user->id,
            'name' => $name,
            'avatar' => $user->avatar,
            'average_score' => round((float) $stats->average_score, 1),
            'best_score' => round((float) $stats->best_score, 1),
            'total_attempts' => (int) $stats->total_attempts,
            'total_points' => (int) ($user->total_points ?? 0),
            'is_current_user' => true,
        ];
    }

    /**
     * Return empty leaderboard structure
     */
    protected function emptyLeaderboard(User $user, string $type = 'stream'): array
    {
        return [
            'type' => $type,
            'podium' => [],
            'rankings' => [],
            'current_user' => [
                'rank' => null,
                'entry' => null,
                'in_list' => false,
            ],
            'total_participants' => 0,
        ];
    }
}
