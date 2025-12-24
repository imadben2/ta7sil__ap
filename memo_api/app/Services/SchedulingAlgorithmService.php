<?php

namespace App\Services;

use App\Models\User;
use App\Models\Subject;
use App\Models\PlannerSetting;
use App\Models\PlannerStudySession;
use App\Models\PlannerSchedule;
use App\Models\SubjectPlannerContent;
use App\Models\ExamSchedule;
use Carbon\Carbon;
use Illuminate\Support\Collection;

/**
 * SchedulingAlgorithmService
 *
 * Implements the full scheduling algorithm from promt.md
 * Handles session generation with constraints, priorities, and adaptations
 */
class SchedulingAlgorithmService
{
    // Constants from promt.md
    public const BUFFER_RATE = 0.20;
    public const MIN_SESSION_DURATION = 30;
    public const MOCK_DURATION = 100;

    // Spaced review intervals
    public const REVIEW_INTERVALS_DEFAULT = [1, 3, 7, 14, 30];
    public const REVIEW_INTERVALS_MEMO = [1, 2, 4, 7, 14];

    // Category weights for priority calculation
    public const CATEGORY_WEIGHTS = [
        'HARD_CORE' => 1.10,
        'MEMORIZATION' => 1.00,
        'LANGUAGE' => 0.95,
        'OTHER' => 1.00,
    ];

    // Base duration by coefficient
    public const BASE_DURATION = [
        7 => 90,
        6 => 80,
        5 => 75,
        4 => 60,
        3 => 50,
        2 => 40,
        1 => 30,
    ];

    // Energy preference by category
    public const ENERGY_PREFERENCE = [
        'HARD_CORE' => ['HIGH', 'MEDIUM', 'LOW'],
        'MEMORIZATION' => ['MEDIUM', 'LOW', 'HIGH'],
        'LANGUAGE' => ['LOW', 'MEDIUM', 'HIGH'],
        'OTHER' => ['MEDIUM', 'HIGH', 'LOW'],
    ];

    protected ContentAllocationService $contentService;

    public function __construct(ContentAllocationService $contentService)
    {
        $this->contentService = $contentService;
    }

    /**
     * Calculate session duration based on coefficient and energy level
     */
    public function calculateDuration(int $coefficient, string $energyLevel): int
    {
        $base = self::BASE_DURATION[$coefficient] ?? 60;

        $factor = match (strtoupper($energyLevel)) {
            'HIGH' => 1.00,
            'MEDIUM' => 0.90,
            'LOW' => ($coefficient >= 6) ? 0.70 : 0.75,
            default => 0.90,
        };

        return max(self::MIN_SESSION_DURATION, $this->roundTo5($base * $factor));
    }

    /**
     * Round to nearest 5 minutes
     */
    protected function roundTo5(float $value): int
    {
        return (int) (round($value / 5) * 5);
    }

    /**
     * Calculate full priority score using promt.md formula
     *
     * P = (0.38U + 0.22I + 0.18D + 0.12C + 0.10Late + BonusDue) × CatW + BonusLanguageDaily
     */
    public function calculatePriority(
        float $daysToExam,
        float $importance,
        float $difficulty,
        int $coefficient,
        bool $isLate,
        bool $isDueToday,
        bool $needsLanguageDaily,
        string $category
    ): float {
        // Urgency: U = 1/max(1, daysLeftToExam)
        $urgency = 1.0 / max(1.0, $daysToExam);

        // Normalize values
        $normalizedImportance = $importance / 5.0;  // I = importance/5
        $normalizedDifficulty = $difficulty / 5.0;  // D = difficulty/5
        $normalizedCoef = $coefficient / 7.0;       // C = coef/7

        // Bonuses
        $late = $isLate ? 1.0 : 0.0;
        $bonusDue = $isDueToday ? 0.40 : 0.0;
        $bonusLang = ($needsLanguageDaily && $category === 'LANGUAGE') ? 0.25 : 0.0;

        // Category weight
        $catW = self::CATEGORY_WEIGHTS[$category] ?? 1.0;

        // Formula
        $priority = (0.38 * $urgency + 0.22 * $normalizedImportance + 0.18 * $normalizedDifficulty
                    + 0.12 * $normalizedCoef + 0.10 * $late + $bonusDue) * $catW + $bonusLang;

        return round($priority, 4);
    }

    /**
     * Check if a session can be placed given day constraints
     */
    public function canPlaceSession(
        array $dayState,
        Subject $subject,
        string $sessionType = 'study',
        bool $topicReady = true
    ): bool {
        // MaxCoef7PerDay = 1
        if ($subject->coefficient == 7 && $dayState['coef7Count'] >= 1) {
            return false;
        }

        // HARD_CORE: max 2, no consecutive
        if ($subject->category === Subject::CATEGORY_HARD_CORE) {
            if ($dayState['hardCount'] >= $dayState['maxHardPerDay']) {
                return false;
            }
            if ($dayState['noConsecutiveHard'] && $dayState['lastCategory'] === Subject::CATEGORY_HARD_CORE) {
                return false;
            }
        }

        // No 3 consecutive same subject
        if (count($dayState['lastSubjects']) >= 2) {
            $lastTwo = array_slice($dayState['lastSubjects'], -2);
            if ($lastTwo[0] === $subject->id && $lastTwo[1] === $subject->id) {
                return false;
            }
        }

        // TOPIC_TEST requires topic to be ready
        if ($sessionType === PlannerStudySession::TYPE_TOPIC_TEST && !$topicReady) {
            return false;
        }

        return true;
    }

    /**
     * Update day state after placing a session
     */
    public function updateDayState(array $dayState, Subject $subject): array
    {
        // Update coef7 count
        if ($subject->coefficient == 7) {
            $dayState['coef7Count']++;
        }

        // Update hard count
        if ($subject->category === Subject::CATEGORY_HARD_CORE) {
            $dayState['hardCount']++;
        }

        // Update language flag
        if ($subject->category === Subject::CATEGORY_LANGUAGE) {
            $dayState['hasLanguage'] = true;
        }

        // Update last category
        $dayState['lastCategory'] = $subject->category;

        // Update last subjects (keep last 2)
        $dayState['lastSubjects'][] = $subject->id;
        if (count($dayState['lastSubjects']) > 2) {
            array_shift($dayState['lastSubjects']);
        }

        return $dayState;
    }

    /**
     * Initialize day state for scheduling
     */
    public function initializeDayState(PlannerSetting $settings): array
    {
        return [
            'coef7Count' => 0,
            'hardCount' => 0,
            'hasLanguage' => false,
            'lastCategory' => null,
            'lastSubjects' => [],
            'maxHardPerDay' => $settings->max_hard_per_day ?? 20,
            'noConsecutiveHard' => $settings->no_consecutive_hard ?? true,
        ];
    }

    /**
     * Get preferred energy levels for a subject category
     */
    public function getPreferredEnergyOrder(string $category): array
    {
        return self::ENERGY_PREFERENCE[$category] ?? self::ENERGY_PREFERENCE['OTHER'];
    }

    /**
     * Calculate topic requirements based on difficulty
     */
    public function calculateTopicRequirements(
        SubjectPlannerContent $topic,
        Subject $subject
    ): array {
        $difficulty = $topic->difficulty_level ?? 3;
        $estimatedHours = $topic->estimated_duration_minutes ? ($topic->estimated_duration_minutes / 60) : 2;
        $baseDuration = self::BASE_DURATION[$subject->coefficient] ?? 60;

        // Lesson requirements based on difficulty
        $lessonRequired = match (true) {
            $difficulty <= 2 => 1,
            $difficulty == 3 => 2,
            default => 3,
        };

        // Calculate exercise requirements
        $totalMinutes = $estimatedHours * 60;
        $learnMinutes = $lessonRequired * $baseDuration;
        $remainingMinutes = max(0, $totalMinutes - $learnMinutes);
        $exerciseRequired = max(1, (int) ceil($remainingMinutes / $baseDuration));

        return [
            'lessonRequired' => $lessonRequired,
            'exerciseRequired' => $exerciseRequired,
            'totalSessions' => $lessonRequired + $exerciseRequired + 1, // +1 for topic test
        ];
    }

    /**
     * Get spaced review intervals based on subject category
     */
    public function getSpacedReviewIntervals(string $category): array
    {
        return $category === Subject::CATEGORY_MEMORIZATION
            ? self::REVIEW_INTERVALS_MEMO
            : self::REVIEW_INTERVALS_DEFAULT;
    }

    /**
     * Create spaced review sessions after a topic test
     */
    public function createSpacedReviewSessions(
        PlannerStudySession $topicTestSession,
        Subject $subject,
        PlannerSchedule $schedule
    ): array {
        $intervals = $this->getSpacedReviewIntervals($subject->category);
        $sessions = [];

        foreach ($intervals as $daysAfter) {
            $reviewDate = Carbon::parse($topicTestSession->scheduled_date)->addDays($daysAfter);

            $session = PlannerStudySession::create([
                'user_id' => $topicTestSession->user_id,
                'schedule_id' => $schedule->id,
                'subject_id' => $subject->id,
                'subject_planner_content_id' => $topicTestSession->subject_planner_content_id,
                'has_content' => $topicTestSession->has_content,
                'content_phase' => ContentAllocationService::PHASE_REVIEW,
                'is_spaced_review' => true,
                'original_topic_test_session_id' => $topicTestSession->id,
                'due_date' => $reviewDate,
                'scheduled_date' => $reviewDate,
                'scheduled_start_time' => '09:00:00', // Will be adjusted during day scheduling
                'scheduled_end_time' => '09:30:00',
                'duration_minutes' => 30,
                'content_title' => $topicTestSession->content_title,
                'session_type' => PlannerStudySession::TYPE_SPACED_REVIEW,
                'required_energy_level' => 'medium',
                'subject_category' => $subject->category,
                'status' => 'scheduled',
            ]);

            $sessions[] = $session;
        }

        return $sessions;
    }

    /**
     * Adapt scheduling after topic test based on score
     */
    public function adaptAfterTopicTest(PlannerStudySession $session, int $score): void
    {
        $session->update(['score' => $score]);

        if ($score < 60) {
            // Add 2 EXERCISES for same topic
            $this->createExtraExerciseSessions($session, 2);
            // Add RETEST after 3 days
            $this->createRetestSession($session, now()->addDays(3));
            // Add extra SPACED_REVIEW next day
            $this->createExtraSpacedReview($session, now()->addDay());
        } elseif ($score < 80) {
            // Add 1 EXERCISES + SPACED_REVIEW after 3 days
            $this->createExtraExerciseSessions($session, 1);
            $this->createExtraSpacedReview($session, now()->addDays(3));
        }
        // score >= 80: keep normal spaced reviews (already scheduled)
    }

    /**
     * Create extra exercise sessions for reinforcement
     */
    protected function createExtraExerciseSessions(PlannerStudySession $originalSession, int $count): array
    {
        $sessions = [];
        $subject = $originalSession->subject;

        for ($i = 0; $i < $count; $i++) {
            $date = now()->addDays($i + 1);

            $session = PlannerStudySession::create([
                'user_id' => $originalSession->user_id,
                'schedule_id' => $originalSession->schedule_id,
                'subject_id' => $subject->id,
                'subject_planner_content_id' => $originalSession->subject_planner_content_id,
                'has_content' => $originalSession->has_content,
                'content_phase' => ContentAllocationService::PHASE_EXERCISE_PRACTICE,
                'is_late' => true, // Mark as late/remedial
                'scheduled_date' => $date,
                'scheduled_start_time' => '14:00:00',
                'scheduled_end_time' => '15:00:00',
                'duration_minutes' => $this->calculateDuration($subject->coefficient, 'MEDIUM'),
                'content_title' => $originalSession->content_title . ' - تمارين إضافية',
                'session_type' => PlannerStudySession::TYPE_EXERCISES,
                'required_energy_level' => 'medium',
                'subject_category' => $subject->category,
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

        return PlannerStudySession::create([
            'user_id' => $originalSession->user_id,
            'schedule_id' => $originalSession->schedule_id,
            'subject_id' => $subject->id,
            'subject_planner_content_id' => $originalSession->subject_planner_content_id,
            'has_content' => $originalSession->has_content,
            'content_phase' => ContentAllocationService::PHASE_TEST,
            'is_late' => true,
            'original_topic_test_session_id' => $originalSession->id,
            'scheduled_date' => $date,
            'scheduled_start_time' => '10:00:00',
            'scheduled_end_time' => '11:00:00',
            'duration_minutes' => 60,
            'content_title' => $originalSession->content_title . ' - إعادة اختبار',
            'session_type' => PlannerStudySession::TYPE_TOPIC_TEST,
            'required_energy_level' => 'high',
            'subject_category' => $subject->category,
            'status' => 'scheduled',
        ]);
    }

    /**
     * Create an extra spaced review session
     */
    protected function createExtraSpacedReview(PlannerStudySession $originalSession, Carbon $date): PlannerStudySession
    {
        $subject = $originalSession->subject;

        return PlannerStudySession::create([
            'user_id' => $originalSession->user_id,
            'schedule_id' => $originalSession->schedule_id,
            'subject_id' => $subject->id,
            'subject_planner_content_id' => $originalSession->subject_planner_content_id,
            'has_content' => $originalSession->has_content,
            'content_phase' => ContentAllocationService::PHASE_REVIEW,
            'is_spaced_review' => true,
            'is_late' => true,
            'original_topic_test_session_id' => $originalSession->id,
            'due_date' => $date,
            'scheduled_date' => $date,
            'scheduled_start_time' => '16:00:00',
            'scheduled_end_time' => '16:30:00',
            'duration_minutes' => 30,
            'content_title' => $originalSession->content_title . ' - مراجعة إضافية',
            'session_type' => PlannerStudySession::TYPE_SPACED_REVIEW,
            'required_energy_level' => 'medium',
            'subject_category' => $subject->category,
            'status' => 'scheduled',
        ]);
    }

    /**
     * Create a mock test session
     */
    public function createMockTestSession(
        User $user,
        Subject $subject,
        Carbon $date,
        PlannerSchedule $schedule
    ): PlannerStudySession {
        return PlannerStudySession::create([
            'user_id' => $user->id,
            'schedule_id' => $schedule->id,
            'subject_id' => $subject->id,
            'is_mock_test' => true,
            'scheduled_date' => $date,
            'scheduled_start_time' => '09:00:00',
            'scheduled_end_time' => '10:40:00',
            'duration_minutes' => self::MOCK_DURATION,
            'content_title' => 'اختبار أسبوعي - ' . $subject->name_ar,
            'session_type' => PlannerStudySession::TYPE_MOCK_TEST,
            'required_energy_level' => 'high',
            'subject_category' => $subject->category,
            'status' => 'scheduled',
        ]);
    }

    /**
     * Create a language daily session
     */
    public function createLanguageDailySession(
        User $user,
        Subject $languageSubject,
        Carbon $date,
        PlannerSchedule $schedule,
        string $energyLevel = 'low'
    ): PlannerStudySession {
        $duration = $this->calculateDuration($languageSubject->coefficient, $energyLevel);

        return PlannerStudySession::create([
            'user_id' => $user->id,
            'schedule_id' => $schedule->id,
            'subject_id' => $languageSubject->id,
            'is_language_daily' => true,
            'scheduled_date' => $date,
            'scheduled_start_time' => '17:00:00',
            'scheduled_end_time' => Carbon::parse('17:00:00')->addMinutes($duration)->format('H:i:s'),
            'duration_minutes' => $duration,
            'content_title' => 'جلسة لغة يومية - ' . $languageSubject->name_ar,
            'session_type' => PlannerStudySession::TYPE_LANGUAGE_DAILY,
            'required_energy_level' => strtolower($energyLevel),
            'subject_category' => $languageSubject->category,
            'status' => 'scheduled',
        ]);
    }

    /**
     * Get the subject with most need for a mock test
     */
    public function getMostNeededSubjectForMock(User $user): ?Subject
    {
        // Get user's subjects ordered by coefficient and study need
        return Subject::whereIn('id', function ($query) use ($user) {
            $query->select('subject_id')
                  ->from('user_subjects')
                  ->where('user_id', $user->id);
        })
        ->where('category', Subject::CATEGORY_HARD_CORE)
        ->orderByDesc('coefficient')
        ->first();
    }

    /**
     * Get a language subject for the user
     * Only returns subjects from user's ACTIVE selected subjects (user_subjects.is_active = true)
     */
    public function getLanguageSubject(User $user): ?Subject
    {
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
     * Check if today is the mock test day
     */
    public function isMockTestDay(Carbon $date, PlannerSetting $settings): bool
    {
        $mockDay = $settings->mock_day_of_week ?? 'saturday';
        return strtolower($date->format('l')) === strtolower($mockDay);
    }

    /**
     * Get days until exam for a subject
     */
    public function getDaysUntilExam(User $user, Subject $subject): float
    {
        $exam = ExamSchedule::where('user_id', $user->id)
            ->where('subject_id', $subject->id)
            ->where('is_completed', false)
            ->where('exam_date', '>=', now()->startOfDay())
            ->orderBy('exam_date')
            ->first();

        if (!$exam) {
            // Default to 30 days if no exam scheduled
            return 30.0;
        }

        return max(1.0, now()->diffInDays($exam->exam_date));
    }

    /**
     * Calculate session duration with all adjustment factors
     *
     * Factors considered:
     * 1. Base duration from coefficient_durations (planner_settings)
     * 2. Daily goal ratio (compression/extension based on objectif_quotidien)
     * 3. Energy level for the time period
     *
     * @param int $coefficient Subject coefficient (1-7)
     * @param PlannerSetting|array $settings User's planner settings
     * @param string $currentTime Current time (H:i format) for energy level
     * @param string $category Subject category (HARD_CORE, LANGUAGE, etc.)
     * @return int Duration in minutes
     */
    public function calculateAdjustedSessionDuration(
        int $coefficient,
        PlannerSetting|array $settings,
        string $currentTime,
        string $category
    ): int {
        // Convert to array if PlannerSetting object
        if ($settings instanceof PlannerSetting) {
            $settingsArray = $settings->toArray();
        } else {
            $settingsArray = $settings;
        }

        // 1. Base duration from coefficient_durations (user settings) or default
        $coefficientDurations = $settingsArray['coefficient_durations'] ?? [];
        if (is_string($coefficientDurations)) {
            $coefficientDurations = json_decode($coefficientDurations, true) ?? [];
        }
        $baseDuration = $coefficientDurations[$coefficient] ?? self::BASE_DURATION[$coefficient] ?? 60;

        // 2. Adjust for daily goal ratio
        $availableHours = $this->calculateAvailableStudyHours($settingsArray);
        $goalHours = $settingsArray['max_study_hours_per_day'] ?? 8;
        $ratio = $goalHours / max(1, $availableHours);

        if ($ratio < 0.5) {
            // Low goal → compress sessions by 20%
            $baseDuration = (int) ($baseDuration * 0.8);
        } elseif ($ratio > 0.8) {
            // High goal → extend sessions by 10%
            $baseDuration = (int) ($baseDuration * 1.1);
        }

        // 3. Adjust for energy level
        $energyLevel = $this->getEnergyLevelForTime($currentTime, $settingsArray);

        $energyFactor = match ($energyLevel) {
            'high' => ($category === 'HARD_CORE') ? 1.1 : 1.0,
            'medium' => 1.0,
            'low' => ($category === 'HARD_CORE') ? 0.75 : 0.9,
            'veryLow' => 0.7,
            default => 1.0,
        };

        $duration = (int) ($baseDuration * $energyFactor);

        // 4. Round to nearest 5 minutes and clamp to valid range (15-180 min)
        $duration = $this->roundTo5($duration);
        return max(15, min(180, $duration));
    }

    /**
     * Get energy level for a given time based on user settings
     *
     * Time periods:
     * - Morning: 06:00-12:00
     * - Afternoon: 12:00-18:00
     * - Evening: 18:00-22:00
     * - Night: 22:00-06:00
     *
     * @param string $time Time in H:i format
     * @param array $settings User's planner settings
     * @return string Energy level (high, medium, low, veryLow)
     */
    public function getEnergyLevelForTime(string $time, array $settings): string
    {
        $hour = (int) explode(':', $time)[0];

        // Energy level by time period (aligned with PLANNER_ALGORITHM_DOCUMENTATION.html)
        // Morning: 05:00-12:00, Afternoon: 12:00-17:00, Evening: 17:00-22:00, Night: 22:00-05:00
        if ($hour >= 5 && $hour < 12) {
            $level = $settings['morning_energy_level'] ?? 7;
        } elseif ($hour >= 12 && $hour < 17) {
            $level = $settings['afternoon_energy_level'] ?? 6;
        } elseif ($hour >= 17 && $hour < 22) {
            $level = $settings['evening_energy_level'] ?? 8;
        } else {
            // Night: 22:00-04:59
            $level = $settings['night_energy_level'] ?? 4;
        }

        // Convert numeric level (1-10) to category
        if ($level >= 7) return 'high';
        if ($level >= 4) return 'medium';
        if ($level >= 2) return 'low';
        return 'veryLow';
    }

    /**
     * Calculate available study hours based on settings
     *
     * Takes into account:
     * - Study time window (start_time to end_time)
     * - Prayer times (if enabled)
     * - Exercise time (if enabled)
     * - Buffer rate
     *
     * @param array $settings User's planner settings
     * @return float Available hours for study
     */
    public function calculateAvailableStudyHours(array $settings): float
    {
        // Parse study times
        $startTime = $settings['study_start_time'] ?? '08:00';
        $endTime = $settings['study_end_time'] ?? '22:00';

        $start = Carbon::parse($startTime);
        $end = Carbon::parse($endTime);

        // Handle case where end time is before start (crosses midnight)
        if ($end->lt($start)) {
            $end->addDay();
        }

        $totalMinutes = $start->diffInMinutes($end);

        // Subtract prayer times if enabled
        if ($settings['enable_prayer_times'] ?? false) {
            $prayerDuration = $settings['prayer_duration_minutes'] ?? 15;
            $numberOfPrayers = 5; // 5 daily prayers
            $totalMinutes -= ($prayerDuration * $numberOfPrayers);
        }

        // Subtract exercise time if enabled
        if ($settings['exercise_enabled'] ?? false) {
            $exerciseDuration = $settings['exercise_duration_minutes'] ?? 60;
            $totalMinutes -= $exerciseDuration;
        }

        // Apply buffer rate
        $effectiveMinutes = $totalMinutes * (1 - self::BUFFER_RATE);

        return max(1, $effectiveMinutes / 60);
    }

    /**
     * Select the best session for the current time slot based on energy level
     *
     * NEW PRIORITY LOGIC (FIXED):
     * - HARD_CORE gets 2:1 ratio during high/medium energy
     * - Round-robin within each category for balance
     * - Low energy allows HARD_CORE but prefers others
     *
     * @param array $availableSessions Sessions available for scheduling
     * @param string $energyLevel Current energy level
     * @param array $dayState Current day constraints
     * @param bool $needsLanguageDaily If language daily guarantee is needed
     * @return array|null Best session or null if none available
     */
    public function selectBestSessionForEnergy(
        array $availableSessions,
        string $energyLevel,
        array $dayState,
        bool $needsLanguageDaily = false
    ): ?array {
        // Use a simple counter for 3:1 ratio (3 HARD_CORE for every 1 other)
        static $energySessionCounter = 0;
        $energySessionCounter++;

        if (empty($availableSessions)) {
            return null;
        }

        // Separate HARD_CORE from others
        $hardCoreSessions = [];
        $otherSessions = [];

        foreach ($availableSessions as $session) {
            $category = $session['category'] ?? 'OTHER';
            if ($category === 'HARD_CORE') {
                $hardCoreSessions[] = $session;
            } else {
                $otherSessions[] = $session;
            }
        }

        // Sort HARD_CORE: round-robin first, then by coefficient
        usort($hardCoreSessions, function($a, $b) {
            $aPriority = $a['priority'] ?? 0;
            $bPriority = $b['priority'] ?? 0;
            if ($aPriority !== $bPriority) {
                return $bPriority <=> $aPriority;
            }
            return ($b['coefficient'] ?? 4) <=> ($a['coefficient'] ?? 4);
        });

        // Sort others: round-robin, then by coefficient
        usort($otherSessions, function($a, $b) {
            $aPriority = $a['priority'] ?? 0;
            $bPriority = $b['priority'] ?? 0;
            if ($aPriority !== $bPriority) {
                return $bPriority <=> $aPriority;
            }
            return ($b['coefficient'] ?? 4) <=> ($a['coefficient'] ?? 4);
        });

        // Pattern: HARD_CORE, HARD_CORE, HARD_CORE, OTHER, repeat (3:1 ratio)
        $isHardCoreSlot = ($energySessionCounter % 4) != 0;

        // Selection based on energy level with 3:1 ratio for HARD_CORE
        if ($energyLevel === 'high' || $energyLevel === 'medium') {
            // High/Medium energy: enforce 3:1 ratio strictly
            if ($isHardCoreSlot && !empty($hardCoreSessions)) {
                return $hardCoreSessions[0];
            }
            if (!$isHardCoreSlot && !empty($otherSessions)) {
                return $otherSessions[0];
            }
            // Fallback: if preferred category is empty, use the other
            if (!empty($hardCoreSessions)) {
                return $hardCoreSessions[0];
            }
            if (!empty($otherSessions)) {
                return $otherSessions[0];
            }
        } else {
            // Low energy: still give HARD_CORE 2:1 ratio (2 HARD_CORE for every 1 other)
            $isHardCoreSlotLow = ($energySessionCounter % 3) != 0;

            if ($needsLanguageDaily) {
                foreach ($otherSessions as $session) {
                    if (($session['category'] ?? '') === 'LANGUAGE') {
                        return $session;
                    }
                }
            }
            if ($isHardCoreSlotLow && !empty($hardCoreSessions)) {
                return $hardCoreSessions[0];
            }
            if (!empty($otherSessions)) {
                return $otherSessions[0];
            }
            if (!empty($hardCoreSessions)) {
                return $hardCoreSessions[0];
            }
        }

        return null;
    }
}
