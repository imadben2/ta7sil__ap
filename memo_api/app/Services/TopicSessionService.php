<?php

namespace App\Services;

use App\Models\User;
use App\Models\Subject;
use App\Models\SubjectPlannerContent;
use App\Models\UserSubjectPlannerProgress;
use App\Models\PlannerStudySession;
use App\Models\PlannerSchedule;
use Carbon\Carbon;
use Illuminate\Support\Collection;

/**
 * TopicSessionService
 *
 * Handles Topic-based session generation from subject_planner_content
 * Implements the algorithm from promt.md for content allocation
 */
class TopicSessionService
{
    /**
     * Subject category constants (from promt.md)
     */
    const CATEGORY_HARD_CORE = 'HARD_CORE';       // رياضيات/فيزياء/علوم
    const CATEGORY_LANGUAGE = 'LANGUAGE';         // العربية/الفرنسية/الإنجليزية
    const CATEGORY_MEMORIZATION = 'MEMORIZATION'; // إسلامية/تاريخ-جغرافيا/فلسفة
    const CATEGORY_OTHER = 'OTHER';

    /**
     * Session types (from promt.md)
     */
    const TYPE_LESSON_REVIEW = 'lesson_review';
    const TYPE_EXERCISES = 'exercises';
    const TYPE_TOPIC_TEST = 'topic_test';
    const TYPE_SPACED_REVIEW = 'spaced_review';
    const TYPE_LANGUAGE_DAILY = 'language_daily';
    const TYPE_MOCK_TEST = 'mock_test';

    /**
     * Content phases
     */
    const PHASE_UNDERSTANDING = 'understanding';
    const PHASE_REVIEW = 'review';
    const PHASE_THEORY_PRACTICE = 'theory_practice';
    const PHASE_EXERCISE_PRACTICE = 'exercise_practice';
    const PHASE_TEST = 'test';

    /**
     * Spaced review intervals (from promt.md)
     */
    const REVIEW_INTERVALS_DEFAULT = [1, 3, 7, 14, 30];
    const REVIEW_INTERVALS_MEMORIZATION = [1, 2, 4, 7, 14];

    /**
     * Base duration by coefficient (from promt.md)
     */
    const BASE_DURATION = [
        7 => 90,
        6 => 80,
        5 => 75,
        4 => 60,
        3 => 50,
        2 => 40,
        1 => 30,
    ];

    /**
     * Get all published topics for a subject based on user's academic context
     */
    public function getTopicsForSubject(int $subjectId, User $user): Collection
    {
        // Get academic context from user_academic_profiles table
        $academicContext = $this->getUserAcademicContext($user);

        if (!$academicContext['phase_id'] || !$academicContext['year_id']) {
            return collect();
        }

        return SubjectPlannerContent::with(['parent.parent'])
            ->forAcademicContext(
                $academicContext['phase_id'],
                $academicContext['year_id'],
                $academicContext['stream_id']
            )
            ->forSubject($subjectId)
            ->published()
            ->where('level', 'topic')
            ->orderBy('order')
            ->get();
    }

    /**
     * Check if a subject has any published content for the user's academic context
     */
    public function subjectHasContent(int $subjectId, User $user): bool
    {
        // Get academic context from user_academic_profiles table
        $academicContext = $this->getUserAcademicContext($user);

        if (!$academicContext['phase_id'] || !$academicContext['year_id']) {
            return false;
        }

        return SubjectPlannerContent::forAcademicContext(
                $academicContext['phase_id'],
                $academicContext['year_id'],
                $academicContext['stream_id']
            )
            ->forSubject($subjectId)
            ->published()
            ->exists();
    }

    /**
     * Get academic context from user's academic profile (user_academic_profiles table)
     * Returns array with phase_id, year_id, stream_id (can be null if user has no profile)
     */
    protected function getUserAcademicContext(User $user): array
    {
        // Load academic profile if not loaded
        if (!$user->relationLoaded('academicProfile')) {
            $user->load('academicProfile');
        }

        $profile = $user->academicProfile;

        if (!$profile) {
            return [
                'phase_id' => null,
                'year_id' => null,
                'stream_id' => null,
            ];
        }

        return [
            'phase_id' => $profile->academic_phase_id,
            'year_id' => $profile->academic_year_id,
            'stream_id' => $profile->academic_stream_id,
        ];
    }

    /**
     * Calculate required sessions for a topic based on promt.md algorithm
     *
     * lessonRequired:
     *   difficulty 1-2: 1 session
     *   difficulty 3: 2 sessions
     *   difficulty 4-5: 3 sessions
     *
     * exerciseRequired:
     *   max(1, ceil((estimatedHours*60 - lessonMin) / BaseDuration))
     */
    public function calculateTopicSessions(SubjectPlannerContent $topic, int $coefficient): array
    {
        $difficulty = $this->getDifficultyLevel($topic);
        $estimatedMinutes = $topic->estimated_duration_minutes ?? 60;
        $baseDuration = self::BASE_DURATION[$coefficient] ?? 60;

        // Calculate lesson required based on difficulty (promt.md algorithm)
        if ($difficulty <= 2) {
            $lessonRequired = 1;
        } elseif ($difficulty == 3) {
            $lessonRequired = 2;
        } else {
            $lessonRequired = 3;
        }

        // Calculate exercise required
        $lessonMinutes = $lessonRequired * $baseDuration;
        $remainingMinutes = max(0, $estimatedMinutes - $lessonMinutes);
        $exerciseRequired = max(1, (int) ceil($remainingMinutes / $baseDuration));

        return [
            'topic' => $topic,
            'lesson_required' => $lessonRequired,
            'exercise_required' => $exerciseRequired,
            'base_duration' => $baseDuration,
            'total_sessions' => $lessonRequired + $exerciseRequired + 1, // +1 for topic test
            'difficulty' => $difficulty,
            'importance' => $topic->is_bac_priority ? 5 : 3,
        ];
    }

    /**
     * Build session backlog for a subject with its topics
     * Returns array of session entries ready for scheduling
     */
    public function buildTopicBacklog(
        int $subjectId,
        User $user,
        Subject $subject,
        ?Carbon $examDate = null
    ): array {
        $backlog = [];

        // Check if subject has any content
        if (!$this->subjectHasContent($subjectId, $user)) {
            // No content - add placeholder session
            $backlog[] = [
                'subject_id' => $subjectId,
                'subject' => $subject,
                'has_content' => false,
                'content' => null,
                'topic_id' => null,
                'session_type' => self::TYPE_LESSON_REVIEW,
                'content_phase' => self::PHASE_UNDERSTANDING,
                'priority' => $this->calculatePriority(
                    $subject->coefficient,
                    3, // default importance
                    3, // default difficulty
                    $examDate,
                    false,
                    false,
                    false,
                    $this->getSubjectCategory($subject)
                ),
            ];
            return $backlog;
        }

        // Get all topics for subject
        $topics = $this->getTopicsForSubject($subjectId, $user);

        // Get user progress for all topics
        $progressMap = UserSubjectPlannerProgress::where('user_id', $user->id)
            ->whereIn('subject_planner_content_id', $topics->pluck('id'))
            ->get()
            ->keyBy('subject_planner_content_id');

        foreach ($topics as $topic) {
            $requirements = $this->calculateTopicSessions($topic, $subject->coefficient);
            $progress = $progressMap->get($topic->id);
            $category = $this->getSubjectCategory($subject);

            // Calculate how many lessons already done
            $lessonsDone = 0;
            if ($progress) {
                if ($progress->understanding_completed) $lessonsDone++;
                if ($progress->review_completed) $lessonsDone++;
            }
            $lessonsNeeded = max(0, $requirements['lesson_required'] - $lessonsDone);

            // Add LESSON_REVIEW sessions
            for ($i = 0; $i < $lessonsNeeded; $i++) {
                $phase = ($i == 0 && !$progress?->understanding_completed)
                    ? self::PHASE_UNDERSTANDING
                    : self::PHASE_REVIEW;

                $backlog[] = [
                    'subject_id' => $subjectId,
                    'subject' => $subject,
                    'has_content' => true,
                    'content' => $topic,
                    'topic_id' => $topic->id,
                    'session_type' => self::TYPE_LESSON_REVIEW,
                    'content_phase' => $phase,
                    'priority' => $this->calculatePriority(
                        $subject->coefficient,
                        $requirements['importance'],
                        $requirements['difficulty'],
                        $examDate,
                        false,
                        false,
                        $category === self::CATEGORY_LANGUAGE,
                        $category
                    ),
                    'requirements' => $requirements,
                ];
            }

            // Calculate exercises done
            $exercisesDone = ($progress && $progress->exercise_practice_completed)
                ? $requirements['exercise_required']
                : 0;
            $exercisesNeeded = max(0, $requirements['exercise_required'] - $exercisesDone);

            // Add EXERCISES sessions
            for ($i = 0; $i < $exercisesNeeded; $i++) {
                $backlog[] = [
                    'subject_id' => $subjectId,
                    'subject' => $subject,
                    'has_content' => true,
                    'content' => $topic,
                    'topic_id' => $topic->id,
                    'session_type' => self::TYPE_EXERCISES,
                    'content_phase' => self::PHASE_EXERCISE_PRACTICE,
                    'priority' => $this->calculatePriority(
                        $subject->coefficient,
                        $requirements['importance'],
                        $requirements['difficulty'],
                        $examDate,
                        false,
                        false,
                        false,
                        $category
                    ),
                    'requirements' => $requirements,
                ];
            }

            // Add TOPIC_TEST if topic is ready
            $testDone = $progress && $progress->status === 'mastered';
            if (!$testDone && $this->isTopicReadyForTest($topic, $user->id, $progress)) {
                $backlog[] = [
                    'subject_id' => $subjectId,
                    'subject' => $subject,
                    'has_content' => true,
                    'content' => $topic,
                    'topic_id' => $topic->id,
                    'session_type' => self::TYPE_TOPIC_TEST,
                    'content_phase' => self::PHASE_TEST,
                    'priority' => $this->calculatePriority(
                        $subject->coefficient,
                        $requirements['importance'],
                        $requirements['difficulty'],
                        $examDate,
                        false,
                        false,
                        false,
                        $category
                    ) + 0.2, // Bonus for tests
                    'requirements' => $requirements,
                ];
            }
        }

        // Sort backlog by priority (descending)
        usort($backlog, fn($a, $b) => $b['priority'] <=> $a['priority']);

        return $backlog;
    }

    /**
     * Check if a topic is ready for its final test
     * Requires lesson and exercise phases to be completed
     */
    public function isTopicReadyForTest(
        SubjectPlannerContent $topic,
        int $userId,
        ?UserSubjectPlannerProgress $progress = null
    ): bool {
        if (!$progress) {
            $progress = UserSubjectPlannerProgress::where('user_id', $userId)
                ->where('subject_planner_content_id', $topic->id)
                ->first();
        }

        if (!$progress) {
            return false;
        }

        // Check if lesson review phases are completed
        $lessonPhasesComplete = $progress->understanding_completed && $progress->review_completed;

        // For content that requires exercises, check exercise phase too
        if ($topic->requires_exercise_practice) {
            return $lessonPhasesComplete &&
                   ($progress->theory_practice_completed || $progress->exercise_practice_completed);
        }

        return $lessonPhasesComplete;
    }

    /**
     * Create spaced review sessions after a topic test is completed
     */
    public function createSpacedReviewsAfterTest(
        PlannerStudySession $topicTestSession,
        Subject $subject,
        PlannerSchedule $schedule
    ): array {
        $category = $this->getSubjectCategory($subject);
        $intervals = $category === self::CATEGORY_MEMORIZATION
            ? self::REVIEW_INTERVALS_MEMORIZATION
            : self::REVIEW_INTERVALS_DEFAULT;

        $sessions = [];
        $completionDate = Carbon::parse($topicTestSession->scheduled_date);

        foreach ($intervals as $daysAfter) {
            $reviewDate = $completionDate->copy()->addDays($daysAfter);

            $session = PlannerStudySession::create([
                'user_id' => $topicTestSession->user_id,
                'schedule_id' => $schedule->id,
                'subject_id' => $subject->id,
                'subject_planner_content_id' => $topicTestSession->subject_planner_content_id,
                'has_content' => $topicTestSession->has_content,
                'content_phase' => self::PHASE_REVIEW,
                'is_spaced_review' => true,
                'original_topic_test_session_id' => $topicTestSession->id,
                'due_date' => $reviewDate,
                'scheduled_date' => $reviewDate,
                'scheduled_start_time' => '09:00:00',
                'scheduled_end_time' => '09:30:00',
                'duration_minutes' => 30,
                'content_title' => $topicTestSession->content_title,
                'session_type' => self::TYPE_SPACED_REVIEW,
                'required_energy_level' => 'medium',
                'subject_category' => $category,
                'status' => 'scheduled',
            ]);

            $sessions[] = $session;
        }

        return $sessions;
    }

    /**
     * Adapt schedule after a topic test score (from promt.md STEP 3)
     *
     * score < 60: add 2 EXERCISES + RETEST after 3 days + extra SPACED_REVIEW next day
     * score 60-79: add 1 EXERCISES + SPACED_REVIEW after 3 days
     * score >= 80: keep normal spaced reviews
     */
    public function adaptAfterScore(PlannerStudySession $session, int $score): array
    {
        $session->update(['score' => $score]);
        $additionalSessions = [];

        if ($score < 60) {
            // Add 2 EXERCISES for same topic
            $additionalSessions = array_merge(
                $additionalSessions,
                $this->createExtraExerciseSessions($session, 2)
            );
            // Add RETEST after 3 days
            $additionalSessions[] = $this->createRetestSession($session, now()->addDays(3));
            // Add extra SPACED_REVIEW next day
            $additionalSessions[] = $this->createExtraSpacedReview($session, now()->addDay());
        } elseif ($score < 80) {
            // Add 1 EXERCISES
            $additionalSessions = array_merge(
                $additionalSessions,
                $this->createExtraExerciseSessions($session, 1)
            );
            // Add SPACED_REVIEW after 3 days
            $additionalSessions[] = $this->createExtraSpacedReview($session, now()->addDays(3));
        }
        // score >= 80: normal spaced reviews already scheduled

        return $additionalSessions;
    }

    /**
     * Calculate priority score using promt.md formula
     *
     * P = (0.38U + 0.22I + 0.18D + 0.12C + 0.10Late + BonusDue) × CatW + BonusLanguageDaily
     */
    public function calculatePriority(
        int $coefficient,
        int $importance,
        int $difficulty,
        ?Carbon $examDate,
        bool $isLate,
        bool $isDueToday,
        bool $needsLanguageDaily,
        string $category
    ): float {
        // Urgency: U = 1/max(1, daysLeftToExam)
        $daysToExam = $examDate ? max(1, now()->diffInDays($examDate)) : 30;
        $urgency = 1.0 / $daysToExam;

        // Normalize values
        $normalizedImportance = $importance / 5.0;
        $normalizedDifficulty = $difficulty / 5.0;
        $normalizedCoef = $coefficient / 7.0;

        // Bonuses
        $late = $isLate ? 1.0 : 0.0;
        $bonusDue = $isDueToday ? 0.40 : 0.0;
        $bonusLang = ($needsLanguageDaily && $category === self::CATEGORY_LANGUAGE) ? 0.25 : 0.0;

        // Category weight
        $catW = match ($category) {
            self::CATEGORY_HARD_CORE => 1.10,
            self::CATEGORY_MEMORIZATION => 1.00,
            self::CATEGORY_LANGUAGE => 0.95,
            default => 1.00,
        };

        // Formula
        $priority = (0.38 * $urgency + 0.22 * $normalizedImportance + 0.18 * $normalizedDifficulty
                    + 0.12 * $normalizedCoef + 0.10 * $late + $bonusDue) * $catW + $bonusLang;

        return round($priority, 4);
    }

    /**
     * Get subject category from subject model
     */
    public function getSubjectCategory(Subject $subject): string
    {
        // Use category field if exists
        if (!empty($subject->category)) {
            return strtoupper($subject->category);
        }

        // Fallback: determine from name
        $name = strtolower($subject->name_ar ?? $subject->name ?? '');

        // HARD_CORE: Math, Physics, Sciences
        $hardCore = ['رياضيات', 'فيزياء', 'علوم', 'كيمياء', 'math', 'physics', 'science', 'chemistry'];
        foreach ($hardCore as $keyword) {
            if (str_contains($name, $keyword)) {
                return self::CATEGORY_HARD_CORE;
            }
        }

        // LANGUAGE: Arabic, French, English
        $language = ['عربية', 'فرنسية', 'إنجليزية', 'لغة', 'arabic', 'french', 'english', 'language'];
        foreach ($language as $keyword) {
            if (str_contains($name, $keyword)) {
                return self::CATEGORY_LANGUAGE;
            }
        }

        // MEMORIZATION: Islamic, History, Geography, Philosophy
        $memorization = ['إسلامية', 'تاريخ', 'جغرافيا', 'فلسفة', 'islamic', 'history', 'geography', 'philosophy'];
        foreach ($memorization as $keyword) {
            if (str_contains($name, $keyword)) {
                return self::CATEGORY_MEMORIZATION;
            }
        }

        return self::CATEGORY_OTHER;
    }

    /**
     * Get difficulty level from content (1-5 scale)
     */
    protected function getDifficultyLevel(SubjectPlannerContent $content): int
    {
        return match ($content->difficulty_level) {
            'easy' => 1,
            'medium' => 3,
            'hard' => 5,
            default => 3,
        };
    }

    /**
     * Get a language subject for the user (for daily language sessions)
     * Only returns subjects from user's ACTIVE selected subjects (user_subjects.is_active = true)
     */
    public function getLanguageSubject(User $user): ?Subject
    {
        // Only look in user's ACTIVE selected subjects - no fallback to stream subjects
        // This ensures we only schedule subjects the user explicitly selected
        return Subject::whereIn('id', function ($query) use ($user) {
                $query->select('subject_id')
                    ->from('user_subjects')
                    ->where('user_id', $user->id)
                    ->where('is_active', true);
            })
            ->where('category', Subject::CATEGORY_LANGUAGE)
            ->first();
    }

    /**
     * Create extra exercise sessions for reinforcement
     */
    protected function createExtraExerciseSessions(PlannerStudySession $originalSession, int $count): array
    {
        $sessions = [];
        $subject = $originalSession->subject;
        $category = $this->getSubjectCategory($subject);
        $baseDuration = self::BASE_DURATION[$subject->coefficient] ?? 60;

        for ($i = 0; $i < $count; $i++) {
            $date = now()->addDays($i + 1);

            $session = PlannerStudySession::create([
                'user_id' => $originalSession->user_id,
                'schedule_id' => $originalSession->schedule_id,
                'subject_id' => $subject->id,
                'subject_planner_content_id' => $originalSession->subject_planner_content_id,
                'has_content' => $originalSession->has_content,
                'content_phase' => self::PHASE_EXERCISE_PRACTICE,
                'is_late' => true,
                'scheduled_date' => $date,
                'scheduled_start_time' => '14:00:00',
                'scheduled_end_time' => Carbon::parse('14:00:00')->addMinutes($baseDuration)->format('H:i:s'),
                'duration_minutes' => $baseDuration,
                'content_title' => ($originalSession->content_title ?? '') . ' - تمارين إضافية',
                'session_type' => self::TYPE_EXERCISES,
                'required_energy_level' => 'medium',
                'subject_category' => $category,
                'status' => 'scheduled',
            ]);

            $sessions[] = $session;
        }

        return $sessions;
    }

    /**
     * Create a retest session
     */
    protected function createRetestSession(PlannerStudySession $originalSession, Carbon $date): PlannerStudySession
    {
        $subject = $originalSession->subject;
        $category = $this->getSubjectCategory($subject);

        return PlannerStudySession::create([
            'user_id' => $originalSession->user_id,
            'schedule_id' => $originalSession->schedule_id,
            'subject_id' => $subject->id,
            'subject_planner_content_id' => $originalSession->subject_planner_content_id,
            'has_content' => $originalSession->has_content,
            'content_phase' => self::PHASE_TEST,
            'is_late' => true,
            'original_topic_test_session_id' => $originalSession->id,
            'scheduled_date' => $date,
            'scheduled_start_time' => '10:00:00',
            'scheduled_end_time' => '11:00:00',
            'duration_minutes' => 60,
            'content_title' => ($originalSession->content_title ?? '') . ' - إعادة اختبار',
            'session_type' => self::TYPE_TOPIC_TEST,
            'required_energy_level' => 'high',
            'subject_category' => $category,
            'status' => 'scheduled',
        ]);
    }

    /**
     * Create an extra spaced review session
     */
    protected function createExtraSpacedReview(PlannerStudySession $originalSession, Carbon $date): PlannerStudySession
    {
        $subject = $originalSession->subject;
        $category = $this->getSubjectCategory($subject);

        return PlannerStudySession::create([
            'user_id' => $originalSession->user_id,
            'schedule_id' => $originalSession->schedule_id,
            'subject_id' => $subject->id,
            'subject_planner_content_id' => $originalSession->subject_planner_content_id,
            'has_content' => $originalSession->has_content,
            'content_phase' => self::PHASE_REVIEW,
            'is_spaced_review' => true,
            'is_late' => true,
            'original_topic_test_session_id' => $originalSession->id,
            'due_date' => $date,
            'scheduled_date' => $date,
            'scheduled_start_time' => '16:00:00',
            'scheduled_end_time' => '16:30:00',
            'duration_minutes' => 30,
            'content_title' => ($originalSession->content_title ?? '') . ' - مراجعة إضافية',
            'session_type' => self::TYPE_SPACED_REVIEW,
            'required_energy_level' => 'medium',
            'subject_category' => $category,
            'status' => 'scheduled',
        ]);
    }
}
