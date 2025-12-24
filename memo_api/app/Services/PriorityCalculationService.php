<?php

namespace App\Services;

use App\Models\User;
use App\Models\Subject;
use App\Models\SubjectPriority;
use App\Models\ExamSchedule;
use App\Models\StudySession;
use App\Models\PlannerSetting;
use Carbon\Carbon;

class PriorityCalculationService
{
    /**
     * Calculate priority for all subjects of a user
     * If user has no subjects assigned, use subjects from their academic stream
     */
    public function calculateAllPriorities(User $user): void
    {
        // ALWAYS use subjects from academic stream (this includes ALL BAC subjects)
        // User's directly assigned subjects are a subset, not a replacement
        $subjects = collect();

        if ($user->academicProfile?->academic_stream_id) {
            $subjects = Subject::forStream($user->academicProfile->academic_stream_id)->get();
        }

        // Fallback to user's directly assigned subjects if no stream subjects
        if ($subjects->isEmpty()) {
            $subjects = $user->subjects;
        }

        $settings = $user->plannerSetting ?? new PlannerSetting();

        foreach ($subjects as $subject) {
            $this->calculateSubjectPriority($user, $subject, $settings);
        }
    }

    /**
     * Calculate priority for a specific subject
     */
    public function calculateSubjectPriority(User $user, Subject $subject, ?PlannerSetting $settings = null): SubjectPriority
    {
        $settings = $settings ?? $user->plannerSetting ?? new PlannerSetting();
        $formula = $settings->priority_formula ?? PlannerSetting::getDefaultPriorityFormula();

        // Calculate individual scores
        $coefficientScore = $this->calculateCoefficientScore($subject);
        $examProximityScore = $this->calculateExamProximityScore($user, $subject);
        $difficultyScore = $this->calculateDifficultyScore($user, $subject);
        $performanceGapScore = $this->calculatePerformanceGapScore($user, $subject);
        $inactivityScore = $this->calculateInactivityScore($user, $subject);
        $historicalPerformanceGapScore = $this->calculateHistoricalPerformanceGapScore($user, $subject);

        // Calculate total priority using weighted formula
        $totalPriority =
            ($coefficientScore * ($formula['coefficient_weight'] ?? 35)) +
            ($examProximityScore * ($formula['exam_proximity_weight'] ?? 25)) +
            ($difficultyScore * ($formula['difficulty_weight'] ?? 15)) +
            ($inactivityScore * ($formula['inactivity_weight'] ?? 10)) +
            ($performanceGapScore * ($formula['performance_gap_weight'] ?? 5)) +
            ($historicalPerformanceGapScore * ($formula['historical_performance_gap_weight'] ?? 10));

        // Update or create SubjectPriority record
        return SubjectPriority::updateOrCreate(
            [
                'user_id' => $user->id,
                'subject_id' => $subject->id,
            ],
            [
                'coefficient_score' => $coefficientScore,
                'exam_proximity_score' => $examProximityScore,
                'difficulty_score' => $difficultyScore,
                'performance_gap_score' => $performanceGapScore,
                'inactivity_score' => $inactivityScore,
                'historical_performance_gap_score' => $historicalPerformanceGapScore,
                'total_priority_score' => $totalPriority,
                'calculated_at' => now(),
            ]
        );
    }

    /**
     * Calculate coefficient score (0-10)
     * Higher coefficient = higher priority
     */
    protected function calculateCoefficientScore(Subject $subject): float
    {
        // Assuming coefficient is 1-10 scale
        $coefficient = $subject->coefficient ?? 5;
        return min(10, max(0, $coefficient));
    }

    /**
     * Calculate exam proximity score (0-10)
     * Closer exam = higher score
     */
    protected function calculateExamProximityScore(User $user, Subject $subject): float
    {
        $upcomingExam = ExamSchedule::where('user_id', $user->id)
            ->where('subject_id', $subject->id)
            ->where('is_completed', false)
            ->where('exam_date', '>=', Carbon::today())
            ->orderBy('exam_date', 'asc')
            ->first();

        if (!$upcomingExam) {
            return 0; // No upcoming exam
        }

        $daysUntilExam = Carbon::today()->diffInDays($upcomingExam->exam_date, false);

        // Score calculation:
        // 0-7 days: score 10 (intensive preparation)
        // 8-14 days: score 8
        // 15-30 days: score 6
        // 31-60 days: score 4
        // 61-90 days: score 2
        // 90+ days: score 1
        if ($daysUntilExam <= 7) {
            return 10;
        } elseif ($daysUntilExam <= 14) {
            return 8;
        } elseif ($daysUntilExam <= 30) {
            return 6;
        } elseif ($daysUntilExam <= 60) {
            return 4;
        } elseif ($daysUntilExam <= 90) {
            return 2;
        }

        return 1;
    }

    /**
     * Calculate difficulty score (0-10)
     * Higher difficulty = higher priority
     *
     * Priority order:
     * 1. User-set difficulty from planner_subjects (difficulty_level 1-5 → score 2-10)
     * 2. Average difficulty from completed study sessions
     * 3. Default value (5)
     */
    protected function calculateDifficultyScore(User $user, Subject $subject): float
    {
        // First: Try to get user-set difficulty from PlannerSubject
        $plannerSubject = \App\Models\PlannerSubject::where('user_id', $user->id)
            ->where('subject_id', $subject->id)
            ->where('is_active', true)
            ->first();

        if ($plannerSubject && $plannerSubject->difficulty_level) {
            // Convert 1-5 scale to 0-10 scale (1→2, 2→4, 3→5, 4→7, 5→10)
            $difficultyMapping = [1 => 2, 2 => 4, 3 => 5, 4 => 7, 5 => 10];
            return $difficultyMapping[$plannerSubject->difficulty_level] ?? 5;
        }

        // Second: Try to get average difficulty from planner study sessions
        try {
            $avgDifficulty = \App\Models\PlannerStudySession::where('user_id', $user->id)
                ->where('subject_id', $subject->id)
                ->where('created_at', '>=', Carbon::now()->subDays(30))
                ->whereNotNull('difficulty')
                ->avg('difficulty');

            if ($avgDifficulty) {
                return min(10, max(0, $avgDifficulty));
            }
        } catch (\Exception $e) {
            // Column doesn't exist, continue with default
        }

        return 5; // Default medium difficulty
    }

    /**
     * Calculate performance gap score (0-10)
     * Lower performance = higher priority
     */
    protected function calculatePerformanceGapScore(User $user, Subject $subject): float
    {
        // Get average score from completed exams
        $avgScore = ExamSchedule::where('user_id', $user->id)
            ->where('subject_id', $subject->id)
            ->where('is_completed', true)
            ->whereNotNull('actual_score')
            ->avg('actual_score');

        if (!$avgScore) {
            return 5; // Default if no performance data
        }

        // Convert score (0-20) to gap score (0-10)
        // Lower actual_score = higher gap score
        // 0-8: gap score 10 (very weak)
        // 9-11: gap score 8
        // 12-14: gap score 6
        // 15-16: gap score 4
        // 17-18: gap score 2
        // 19-20: gap score 1 (excellent)
        if ($avgScore <= 8) {
            return 10;
        } elseif ($avgScore <= 11) {
            return 8;
        } elseif ($avgScore <= 14) {
            return 6;
        } elseif ($avgScore <= 16) {
            return 4;
        } elseif ($avgScore <= 18) {
            return 2;
        }

        return 1;
    }

    /**
     * Calculate inactivity score (0-10)
     * Longer inactivity = higher priority
     */
    protected function calculateInactivityScore(User $user, Subject $subject): float
    {
        // Try PlannerStudySession first, then fall back to StudySession
        $lastSession = \App\Models\PlannerStudySession::where('user_id', $user->id)
            ->where('subject_id', $subject->id)
            ->where('status', 'completed')
            ->orderBy('scheduled_date', 'desc')
            ->first();

        if (!$lastSession) {
            // Try old StudySession table
            try {
                $lastSession = StudySession::where('user_id', $user->id)
                    ->where('subject_id', $subject->id)
                    ->orderBy('created_at', 'desc')
                    ->first();
            } catch (\Exception $e) {
                // Table may not exist
            }
        }

        if (!$lastSession) {
            return 10; // Never studied = highest priority
        }

        $lastDate = $lastSession->scheduled_date ?? $lastSession->created_at;
        $daysSinceLastStudy = Carbon::now()->diffInDays($lastDate);

        // Score calculation:
        // 0-1 days: score 0 (recently studied)
        // 2-3 days: score 2
        // 4-7 days: score 5
        // 8-14 days: score 7
        // 15-30 days: score 9
        // 30+ days: score 10
        if ($daysSinceLastStudy <= 1) {
            return 0;
        } elseif ($daysSinceLastStudy <= 3) {
            return 2;
        } elseif ($daysSinceLastStudy <= 7) {
            return 5;
        } elseif ($daysSinceLastStudy <= 14) {
            return 7;
        } elseif ($daysSinceLastStudy <= 30) {
            return 9;
        }

        return 10;
    }

    /**
     * Calculate historical performance gap score (0-10)
     * Lower last year average = higher priority
     *
     * Uses last_year_average from planner_subjects table (user input)
     * Target is 14/20 (BAC passing score)
     */
    protected function calculateHistoricalPerformanceGapScore(User $user, Subject $subject): float
    {
        $targetAverage = 14.0; // BAC target score

        // Get last_year_average from PlannerSubject (user input from UI)
        $plannerSubject = \App\Models\PlannerSubject::where('user_id', $user->id)
            ->where('subject_id', $subject->id)
            ->where('is_active', true)
            ->first();

        if (!$plannerSubject || $plannerSubject->last_year_average === null) {
            return 0; // No data = neutral priority
        }

        $lastYearAverage = (float) $plannerSubject->last_year_average;

        // Calculate gap from target (14/20)
        // Gap can be negative (student exceeded target) - treat as 0
        $gap = max(0, $targetAverage - $lastYearAverage);

        // Convert gap (0-14) to score (0-10)
        // gap = 0 (avg 14+) → score 0 (no boost needed)
        // gap = 6 (avg 8) → score 4.3
        // gap = 10 (avg 4) → score 7.1
        // gap = 14 (avg 0) → score 10
        return min(10, ($gap / 14.0) * 10);
    }

    /**
     * Get subjects ordered by priority for a user
     */
    public function getPrioritizedSubjects(User $user, int $limit = null)
    {
        $query = SubjectPriority::where('user_id', $user->id)
            ->with('subject')
            ->orderBy('total_priority_score', 'desc');

        if ($limit) {
            $query->limit($limit);
        }

        return $query->get();
    }
}
