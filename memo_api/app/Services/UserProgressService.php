<?php

namespace App\Services;

use App\Models\User;
use App\Models\Content;
use App\Models\Subject;
use App\Models\UserContentProgress;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class UserProgressService
{
    /**
     * Track or update user progress on content.
     *
     * @param  User  $user
     * @param  Content  $content
     * @param  array  $data
     * @return UserContentProgress
     */
    public function trackProgress(User $user, Content $content, array $data): UserContentProgress
    {
        $progress = UserContentProgress::updateOrCreate(
            [
                'user_id' => $user->id,
                'content_id' => $content->id,
            ],
            [
                'status' => $data['status'] ?? 'in_progress',
                'progress_percentage' => $data['progress_percentage'] ?? 0,
                'time_spent_minutes' => $data['time_spent_minutes'] ?? 0,
                'last_accessed_at' => now(),
            ]
        );

        return $progress;
    }

    /**
     * Mark content as completed for user.
     *
     * @param  User  $user
     * @param  Content  $content
     * @param  int|null  $timeSpent
     * @return UserContentProgress
     */
    public function markAsCompleted(User $user, Content $content, ?int $timeSpent = null): UserContentProgress
    {
        $progress = UserContentProgress::updateOrCreate(
            [
                'user_id' => $user->id,
                'content_id' => $content->id,
            ],
            [
                'status' => 'completed',
                'progress_percentage' => 100,
                'time_spent_minutes' => $timeSpent ?? 0,
                'last_accessed_at' => now(),
                'completed_at' => now(),
            ]
        );

        // Award points for completion (if gamification is enabled)
        // This would integrate with the gamification module
        // event(new ContentCompleted($user, $content));

        return $progress;
    }

    /**
     * Get user's progress for a specific content.
     *
     * @param  User  $user
     * @param  Content  $content
     * @return UserContentProgress|null
     */
    public function getContentProgress(User $user, Content $content): ?UserContentProgress
    {
        return UserContentProgress::where('user_id', $user->id)
            ->where('content_id', $content->id)
            ->first();
    }

    /**
     * Get user's progress for all contents in a subject.
     *
     * @param  User  $user
     * @param  Subject  $subject
     * @return array
     */
    public function getSubjectProgress(User $user, Subject $subject): array
    {
        $contents = Content::where('subject_id', $subject->id)
            ->where('is_published', true)
            ->get();

        $totalContents = $contents->count();

        if ($totalContents === 0) {
            return [
                'total_contents' => 0,
                'completed_contents' => 0,
                'in_progress_contents' => 0,
                'not_started_contents' => 0,
                'progress_percentage' => 0,
                'total_study_minutes' => 0,
            ];
        }

        $userProgress = UserContentProgress::where('user_id', $user->id)
            ->whereIn('content_id', $contents->pluck('id'))
            ->get();

        $completedCount = $userProgress->where('status', 'completed')->count();
        $inProgressCount = $userProgress->where('status', 'in_progress')->count();
        $notStartedCount = $totalContents - ($completedCount + $inProgressCount);
        $totalTimeSpent = $userProgress->sum('time_spent_minutes');
        $progressPercentage = round(($completedCount / $totalContents) * 100, 2);

        return [
            'total_contents' => $totalContents,
            'completed_contents' => $completedCount,
            'in_progress_contents' => $inProgressCount,
            'not_started_contents' => $notStartedCount,
            'progress_percentage' => $progressPercentage,
            'total_study_minutes' => $totalTimeSpent,
        ];
    }

    /**
     * Get user's overall progress across all subjects.
     *
     * @param  User  $user
     * @return array
     */
    public function getOverallProgress(User $user): array
    {
        $allProgress = UserContentProgress::where('user_id', $user->id)->get();

        $totalContents = Content::where('is_published', true)->count();
        $completedCount = $allProgress->where('status', 'completed')->count();
        $inProgressCount = $allProgress->where('status', 'in_progress')->count();
        $totalTimeSpent = $allProgress->sum('time_spent_minutes');

        return [
            'total_contents' => $totalContents,
            'completed_contents' => $completedCount,
            'in_progress_contents' => $inProgressCount,
            'not_started_contents' => max(0, $totalContents - ($completedCount + $inProgressCount)),
            'progress_percentage' => $totalContents > 0 ? round(($completedCount / $totalContents) * 100, 2) : 0,
            'total_study_minutes' => $totalTimeSpent,
            'total_study_hours' => round($totalTimeSpent / 60, 2),
        ];
    }

    /**
     * Get user's recently accessed contents.
     *
     * @param  User  $user
     * @param  int  $limit
     * @return Collection
     */
    public function getRecentlyAccessed(User $user, int $limit = 10): Collection
    {
        return UserContentProgress::where('user_id', $user->id)
            ->with(['content.subject', 'content.contentType'])
            ->orderBy('last_accessed_at', 'desc')
            ->limit($limit)
            ->get();
    }

    /**
     * Get user's completed contents.
     *
     * @param  User  $user
     * @param  int|null  $subjectId
     * @return Collection
     */
    public function getCompletedContents(User $user, ?int $subjectId = null): Collection
    {
        $query = UserContentProgress::where('user_id', $user->id)
            ->where('status', 'completed')
            ->with(['content.subject', 'content.contentType']);

        if ($subjectId) {
            $query->whereHas('content', function ($q) use ($subjectId) {
                $q->where('subject_id', $subjectId);
            });
        }

        return $query->orderBy('completed_at', 'desc')->get();
    }

    /**
     * Get user's in-progress contents.
     *
     * @param  User  $user
     * @param  int|null  $subjectId
     * @return Collection
     */
    public function getInProgressContents(User $user, ?int $subjectId = null): Collection
    {
        $query = UserContentProgress::where('user_id', $user->id)
            ->where('status', 'in_progress')
            ->with(['content.subject', 'content.contentType']);

        if ($subjectId) {
            $query->whereHas('content', function ($q) use ($subjectId) {
                $q->where('subject_id', $subjectId);
            });
        }

        return $query->orderBy('last_accessed_at', 'desc')->get();
    }

    /**
     * Calculate average progress percentage for user.
     *
     * @param  User  $user
     * @return float
     */
    public function getAverageProgress(User $user): float
    {
        $avgProgress = UserContentProgress::where('user_id', $user->id)
            ->avg('progress_percentage');

        return round($avgProgress ?? 0, 2);
    }

    /**
     * Get study streak (consecutive days).
     *
     * @param  User  $user
     * @return int
     */
    public function getStudyStreak(User $user): int
    {
        $progressRecords = UserContentProgress::where('user_id', $user->id)
            ->where('last_accessed_at', '>=', now()->subDays(30))
            ->orderBy('last_accessed_at', 'desc')
            ->pluck('last_accessed_at')
            ->map(function ($date) {
                return $date->format('Y-m-d');
            })
            ->unique()
            ->values();

        if ($progressRecords->isEmpty()) {
            return 0;
        }

        $streak = 0;
        $expectedDate = now()->format('Y-m-d');

        foreach ($progressRecords as $date) {
            if ($date === $expectedDate) {
                $streak++;
                $expectedDate = now()->subDays($streak)->format('Y-m-d');
            } else {
                break;
            }
        }

        return $streak;
    }

    /**
     * Get recommended next content for user based on progress.
     *
     * @param  User  $user
     * @param  Subject|null  $subject
     * @param  int  $limit
     * @return Collection
     */
    public function getRecommendedContents(User $user, ?Subject $subject = null, int $limit = 5): Collection
    {
        // Get user's completed and in-progress content IDs
        $userContentIds = UserContentProgress::where('user_id', $user->id)
            ->whereIn('status', ['completed', 'in_progress'])
            ->pluck('content_id');

        // Find contents not yet started
        $query = Content::where('is_published', true)
            ->whereNotIn('id', $userContentIds);

        if ($subject) {
            $query->where('subject_id', $subject->id);
        }

        // Prioritize by order and difficulty (easy first)
        return $query->orderBy('order', 'asc')
            ->orderByRaw("FIELD(difficulty_level, 'easy', 'medium', 'hard')")
            ->limit($limit)
            ->get();
    }

    /**
     * Reset progress for a content.
     *
     * @param  User  $user
     * @param  Content  $content
     * @return bool
     */
    public function resetProgress(User $user, Content $content): bool
    {
        $progress = UserContentProgress::where('user_id', $user->id)
            ->where('content_id', $content->id)
            ->first();

        if ($progress) {
            return $progress->delete();
        }

        return false;
    }
}
