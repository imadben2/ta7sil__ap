<?php

namespace App\Jobs;

use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

/**
 * Heavy operation: Calculate comprehensive user statistics
 * This involves complex queries and calculations
 */
class CalculateUserStatisticsJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $tries = 3;
    public $timeout = 180;

    /**
     * Create a new job instance.
     */
    public function __construct(
        public int $userId
    ) {
        $this->onQueue('low'); // Low priority queue
    }

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        $user = User::find($this->userId);

        if (!$user) {
            return;
        }

        // Calculate complex statistics
        $stats = [
            'total_study_hours' => $this->calculateTotalStudyHours($user),
            'completed_sessions' => $this->calculateCompletedSessions($user),
            'quiz_performance' => $this->calculateQuizPerformance($user),
            'subject_progress' => $this->calculateSubjectProgress($user),
            'streak_days' => $this->calculateStreakDays($user),
            'calculated_at' => now(),
        ];

        // Cache the results for 1 hour
        Cache::put("user.{$userId}.stats", $stats, 3600);

        \Log::info("Statistics calculated for user {$userId}");
    }

    /**
     * Calculate total study hours
     */
    private function calculateTotalStudyHours(User $user): float
    {
        return DB::table('study_sessions')
            ->where('user_id', $user->id)
            ->where('status', 'completed')
            ->sum('duration_minutes') / 60;
    }

    /**
     * Calculate completed sessions
     */
    private function calculateCompletedSessions(User $user): int
    {
        return DB::table('study_sessions')
            ->where('user_id', $user->id)
            ->where('status', 'completed')
            ->count();
    }

    /**
     * Calculate quiz performance
     */
    private function calculateQuizPerformance(User $user): array
    {
        $attempts = DB::table('quiz_attempts')
            ->where('user_id', $user->id)
            ->whereNotNull('completed_at')
            ->select('score', 'max_score')
            ->get();

        if ($attempts->isEmpty()) {
            return [
                'total_quizzes' => 0,
                'average_score' => 0,
                'best_score' => 0,
            ];
        }

        $totalScore = 0;
        $bestScore = 0;

        foreach ($attempts as $attempt) {
            $percentage = ($attempt->score / $attempt->max_score) * 100;
            $totalScore += $percentage;
            $bestScore = max($bestScore, $percentage);
        }

        return [
            'total_quizzes' => $attempts->count(),
            'average_score' => round($totalScore / $attempts->count(), 2),
            'best_score' => round($bestScore, 2),
        ];
    }

    /**
     * Calculate progress by subject
     */
    private function calculateSubjectProgress(User $user): array
    {
        // Placeholder - implement based on actual progress tracking
        return [];
    }

    /**
     * Calculate study streak
     */
    private function calculateStreakDays(User $user): int
    {
        // Get distinct study dates, ordered descending
        $studyDates = DB::table('study_sessions')
            ->where('user_id', $user->id)
            ->where('status', 'completed')
            ->distinct()
            ->orderBy('scheduled_date', 'desc')
            ->pluck('scheduled_date')
            ->map(fn($date) => \Carbon\Carbon::parse($date)->startOfDay());

        if ($studyDates->isEmpty()) {
            return 0;
        }

        $streak = 1;
        $today = now()->startOfDay();

        // Check if user studied today or yesterday (to keep streak alive)
        if (!$studyDates->first()->eq($today) && !$studyDates->first()->eq($today->copy()->subDay())) {
            return 0;
        }

        // Count consecutive days
        for ($i = 0; $i < $studyDates->count() - 1; $i++) {
            $diff = $studyDates[$i]->diffInDays($studyDates[$i + 1]);
            if ($diff === 1) {
                $streak++;
            } else {
                break;
            }
        }

        return $streak;
    }

    /**
     * Handle a job failure.
     */
    public function failed(\Throwable $exception): void
    {
        \Log::error("CalculateUserStatisticsJob failed for user {$this->userId}: {$exception->getMessage()}");
    }
}
