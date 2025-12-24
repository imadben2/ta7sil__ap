<?php

namespace App\Services;

use App\Models\Quiz;
use App\Models\Subject;
use App\Models\User;
use App\Models\UserQuizPerformance;
use Carbon\Carbon;
use Illuminate\Support\Collection;

class QuizRecommendationService
{
    /**
     * Get recommended quizzes for a user
     */
    public function getRecommendedQuizzes(User $user, int $limit = 5): Collection
    {
        $recommendations = [];

        // 1. Quizzes for weak concepts
        $weakConceptQuizzes = $this->getQuizzesForWeakConcepts($user);
        foreach ($weakConceptQuizzes->take(2) as $quiz) {
            $recommendations[] = [
                'quiz' => $quiz,
                'reason' => 'يستهدف مفاهيم ضعيفة',
                'priority' => 10,
            ];
        }

        // 2. Quizzes for priority subjects (from planner)
        $prioritySubjectQuizzes = $this->getQuizzesForPrioritySubjects($user);
        foreach ($prioritySubjectQuizzes->take(2) as $quiz) {
            $recommendations[] = [
                'quiz' => $quiz,
                'reason' => 'مادة ذات أولوية عالية',
                'priority' => 8,
            ];
        }

        // 3. Popular quizzes not yet attempted
        $popularQuizzes = $this->getPopularQuizzes($user);
        foreach ($popularQuizzes->take(2) as $quiz) {
            $recommendations[] = [
                'quiz' => $quiz,
                'reason' => 'كويز شائع',
                'priority' => 6,
            ];
        }

        // 4. Recently added quizzes
        $newQuizzes = $this->getNewQuizzes($user);
        foreach ($newQuizzes->take(1) as $quiz) {
            $recommendations[] = [
                'quiz' => $quiz,
                'reason' => 'كويز جديد',
                'priority' => 4,
            ];
        }

        // Sort by priority and remove duplicates
        $recommendations = collect($recommendations)
            ->unique(function ($item) {
                return $item['quiz']->id;
            })
            ->sortByDesc('priority')
            ->take($limit)
            ->values();

        return $recommendations;
    }

    /**
     * Get quizzes targeting weak concepts
     */
    public function getQuizzesForWeakConcepts(User $user): Collection
    {
        // Get weak concepts from all quiz performances
        $weakConcepts = UserQuizPerformance::where('user_id', $user->id)
            ->whereNotNull('weak_concepts')
            ->get()
            ->pluck('weak_concepts')
            ->flatten(1)
            ->unique('tag')
            ->sortByDesc('error_rate')
            ->take(5)
            ->pluck('tag')
            ->toArray();

        if (empty($weakConcepts)) {
            return collect();
        }

        // Find quizzes that cover these concepts
        return Quiz::published()
            ->free()
            ->where(function ($query) use ($weakConcepts) {
                foreach ($weakConcepts as $concept) {
                    $query->orWhereJsonContains('tags', $concept);
                }
            })
            ->whereNotIn('id', function ($query) use ($user) {
                // Exclude recently attempted quizzes (< 7 days)
                $query->select('quiz_id')
                    ->from('quiz_attempts')
                    ->where('user_id', $user->id)
                    ->where('completed_at', '>=', Carbon::now()->subDays(7));
            })
            ->with('subject')
            ->limit(10)
            ->get();
    }

    /**
     * Get quizzes for priority subjects
     */
    public function getQuizzesForPrioritySubjects(User $user): Collection
    {
        // Get top priority subjects from planner
        $prioritySubjects = $user->subjectPriorities()
            ->orderBy('total_priority_score', 'desc')
            ->take(3)
            ->pluck('subject_id')
            ->toArray();

        if (empty($prioritySubjects)) {
            // Fallback to user's selected subjects
            $prioritySubjects = $user->subjects()
                ->pluck('subjects.id')
                ->toArray();
        }

        if (empty($prioritySubjects)) {
            return collect();
        }

        return Quiz::published()
            ->free()
            ->whereIn('subject_id', $prioritySubjects)
            ->whereNotIn('id', function ($query) use ($user) {
                // Exclude recently attempted quizzes (< 7 days)
                $query->select('quiz_id')
                    ->from('quiz_attempts')
                    ->where('user_id', $user->id)
                    ->where('completed_at', '>=', Carbon::now()->subDays(7));
            })
            ->orderBy('difficulty_level', 'asc') // Start with easier quizzes
            ->with('subject')
            ->limit(10)
            ->get();
    }

    /**
     * Get quizzes for a specific subject
     */
    public function getQuizzesForSubject(User $user, Subject $subject, int $limit = 10): Collection
    {
        // Get user's performance for this subject
        $performance = UserQuizPerformance::where('user_id', $user->id)
            ->where('subject_id', $subject->id)
            ->first();

        $query = Quiz::published()
            ->free()
            ->where('subject_id', $subject->id)
            ->whereNotIn('id', function ($query) use ($user) {
                // Exclude very recently attempted (< 3 days)
                $query->select('quiz_id')
                    ->from('quiz_attempts')
                    ->where('user_id', $user->id)
                    ->where('completed_at', '>=', Carbon::now()->subDays(3));
            });

        // Adjust difficulty based on performance
        if ($performance && $performance->average_score >= 80) {
            // High performer - suggest medium to hard
            $query->whereIn('difficulty_level', ['medium', 'hard']);
        } elseif ($performance && $performance->average_score < 60) {
            // Struggling - suggest easy to medium
            $query->whereIn('difficulty_level', ['easy', 'medium']);
        }

        return $query->limit($limit)->get();
    }

    /**
     * Get popular quizzes
     */
    protected function getPopularQuizzes(User $user): Collection
    {
        return Quiz::published()
            ->free()
            ->where('total_attempts', '>', 10)
            ->where('average_score', '>=', 60) // Not too difficult
            ->whereNotIn('id', function ($query) use ($user) {
                // Exclude already attempted
                $query->select('quiz_id')
                    ->from('quiz_attempts')
                    ->where('user_id', $user->id);
            })
            ->orderBy('total_attempts', 'desc')
            ->with('subject')
            ->limit(10)
            ->get();
    }

    /**
     * Get newly added quizzes
     */
    protected function getNewQuizzes(User $user): Collection
    {
        return Quiz::published()
            ->free()
            ->where('created_at', '>=', Carbon::now()->subDays(30))
            ->whereNotIn('id', function ($query) use ($user) {
                // Exclude already attempted
                $query->select('quiz_id')
                    ->from('quiz_attempts')
                    ->where('user_id', $user->id);
            })
            ->orderBy('created_at', 'desc')
            ->with('subject')
            ->limit(10)
            ->get();
    }

    /**
     * Get next quiz in a series/progression
     */
    public function getNextQuizInProgression(User $user, Quiz $currentQuiz): ?Quiz
    {
        // Get user's best score on current quiz
        $bestScore = $currentQuiz->getUserBestScore($user);

        if ($bestScore === null || $bestScore < 70) {
            // Retry same difficulty
            return Quiz::published()
                ->free()
                ->where('subject_id', $currentQuiz->subject_id)
                ->where('difficulty_level', $currentQuiz->difficulty_level)
                ->where('id', '!=', $currentQuiz->id)
                ->inRandomOrder()
                ->first();
        }

        // Progress to next difficulty level
        $nextDifficulty = match ($currentQuiz->difficulty_level) {
            'easy' => 'medium',
            'medium' => 'hard',
            'hard' => 'hard', // Stay at hard
            default => 'medium',
        };

        return Quiz::published()
            ->free()
            ->where('subject_id', $currentQuiz->subject_id)
            ->where('difficulty_level', $nextDifficulty)
            ->inRandomOrder()
            ->first();
    }

    /**
     * Get adaptive quiz recommendations based on performance trends
     */
    public function getAdaptiveRecommendations(User $user, int $limit = 3): Collection
    {
        $recentAttempts = $user->quizAttempts()
            ->completed()
            ->with('quiz')
            ->orderBy('completed_at', 'desc')
            ->take(10)
            ->get();

        if ($recentAttempts->isEmpty()) {
            // No history - recommend easy quizzes
            return Quiz::published()
                ->free()
                ->where('difficulty_level', 'easy')
                ->inRandomOrder()
                ->limit($limit)
                ->get();
        }

        // Analyze performance trend
        $averageScore = $recentAttempts->avg('score_percentage');
        $recentScores = $recentAttempts->take(3)->pluck('score_percentage')->toArray();
        $isImproving = count($recentScores) >= 2 && end($recentScores) > $recentScores[0];

        if ($averageScore >= 80 || $isImproving) {
            // Challenge the user
            return Quiz::published()
                ->free()
                ->whereIn('difficulty_level', ['medium', 'hard'])
                ->whereNotIn('id', $recentAttempts->pluck('quiz_id'))
                ->inRandomOrder()
                ->limit($limit)
                ->get();
        } elseif ($averageScore < 60) {
            // Reinforce fundamentals
            return Quiz::published()
                ->free()
                ->where('difficulty_level', 'easy')
                ->whereNotIn('id', $recentAttempts->pluck('quiz_id'))
                ->inRandomOrder()
                ->limit($limit)
                ->get();
        } else {
            // Balanced mix
            return Quiz::published()
                ->free()
                ->where('difficulty_level', 'medium')
                ->whereNotIn('id', $recentAttempts->pluck('quiz_id'))
                ->inRandomOrder()
                ->limit($limit)
                ->get();
        }
    }
}
