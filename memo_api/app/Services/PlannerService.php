<?php

namespace App\Services;

use App\Models\User;
use App\Models\Subject;
use App\Models\StudySchedule;
use App\Models\StudySession;
use App\Models\PlannerSetting;
use App\Models\PlannerStudySession;
use App\Models\PlannerSchedule;
use App\Models\PrayerTime;
use App\Models\ExamSchedule;
use App\Models\SubjectPriority;
use App\Models\SubjectPlannerContent;
use App\Models\UserSubjectPlannerProgress;
use Carbon\Carbon;
use Carbon\CarbonPeriod;
use Illuminate\Support\Collection;

class PlannerService
{
    protected PriorityCalculationService $priorityService;
    protected ContentAllocationService $contentService;
    protected SchedulingAlgorithmService $algorithmService;
    protected TopicSessionService $topicService;

    /**
     * Day state for constraint checking
     */
    protected array $dayState = [];

    /**
     * Buffer rate (20%)
     */
    const BUFFER_RATE = 0.20;

    /**
     * Mock test duration
     */
    const MOCK_DURATION = 100;

    public function __construct(
        PriorityCalculationService $priorityService,
        ContentAllocationService $contentService,
        SchedulingAlgorithmService $algorithmService,
        TopicSessionService $topicService
    ) {
        $this->priorityService = $priorityService;
        $this->contentService = $contentService;
        $this->algorithmService = $algorithmService;
        $this->topicService = $topicService;
    }

    /**
     * Generate a study schedule for a user
     */
    public function generateSchedule(
        User $user,
        Carbon $startDate,
        Carbon $endDate,
        string $scheduleType = 'auto'
    ): array {
        // Recalculate priorities first
        $this->priorityService->calculateAllPriorities($user);

        // Get user settings
        $settings = $user->plannerSetting;
        if (!$settings) {
            throw new \Exception('User planner settings not found. Please configure planner settings first.');
        }

        // Get prioritized subjects
        $prioritizedSubjects = $this->priorityService->getPrioritizedSubjects($user);

        // Get exam date for priority calculation
        $examDate = $this->getClosestExamDate($user);

        // Build Unit-based Weekly Backlog
        $unitWeeks = $this->contentService->buildUnitWeeklyBacklog($user, $prioritizedSubjects, $examDate);

        // Get existing spaced reviews that are due
        $dueSessions = $this->getExistingDueSessions($user, $startDate, $endDate);

        // IMPORTANT: Deactivate any existing active schedules for this user
        // to prevent duplicate sessions appearing in the app
        PlannerSchedule::where('user_id', $user->id)
            ->where('status', 'active')
            ->update(['status' => 'inactive']);

        // Create schedule record
        $academicProfile = $user->academicProfile;
        $schedule = PlannerSchedule::create([
            'user_id' => $user->id,
            'academic_year_id' => $academicProfile?->academic_year_id,
            'academic_stream_id' => $academicProfile?->academic_stream_id,
            'schedule_type' => $scheduleType,
            'start_date' => $startDate,
            'end_date' => $endDate,
            'status' => 'draft',
            'generation_algorithm_version' => '4.0-unified',
            'generated_at' => now(),
        ]);

        // Generate sessions using unified algorithm
        $totalStudyHours = 0;
        $subjectsCovered = [];

        $sessions = $this->generateUnitBasedSchedule(
            $user,
            $schedule,
            $startDate,
            $endDate,
            $unitWeeks,
            $settings,
            $dueSessions
        );

        foreach ($sessions as $session) {
            $totalStudyHours += $session->duration_minutes / 60;
            if (!in_array($session->subject_id, $subjectsCovered)) {
                $subjectsCovered[] = $session->subject_id;
            }
        }

        // Calculate feasibility score
        $feasibilityScore = $this->calculateFeasibilityScore($schedule, $settings);

        // Update schedule with metadata
        $schedule->update([
            'total_study_hours' => $totalStudyHours,
            'subjects_covered' => $subjectsCovered,
            'feasibility_score' => $feasibilityScore,
        ]);

        return [
            'schedule' => $schedule,
            'sessions' => $sessions,
        ];
    }

    /**
     * Generate sessions for a PlannerSchedule with specific subjects
     */
    public function generateSessionsForSchedule(
        User $user,
        PlannerSchedule $schedule,
        $subjects,
        PlannerSetting $settings
    ): \Illuminate\Support\Collection {
        $startDate = Carbon::parse($schedule->start_date);
        $endDate = Carbon::parse($schedule->end_date);

        // Build unit-based weekly backlog for the given subjects
        $unitWeeks = $this->contentService->buildUnitWeeklyBacklog($user, $subjects);

        if (empty($unitWeeks)) {
            return collect();
        }

        // Get existing spaced reviews that are due
        $dueSessions = [];

        // Use unified algorithm
        $sessions = $this->generateUnitBasedSchedule(
            $user,
            $schedule,
            $startDate,
            $endDate,
            $unitWeeks,
            $settings,
            $dueSessions
        );

        return collect($sessions);
    }

    /**
     * UNIFIED Algorithm: Generate sessions using unit-based weekly pattern
     *
     * Features:
     * - Distributes ALL subjects across ALL days (round-robin)
     * - 60-minute break logic when maxHardPerDay is reached
     * - Prayer sessions creation
     * - Energy-based duration calculation
     * - Blocked slots handling (prayer times, exercise)
     */
    protected function generateUnitBasedSchedule(
        User $user,
        PlannerSchedule $schedule,
        Carbon $startDate,
        Carbon $endDate,
        array $unitWeeks,
        PlannerSetting $settings,
        array &$dueSessions
    ): array {
        \Log::info("[generateUnitBasedSchedule] START - Units count: " . count($unitWeeks));

        $allSessions = [];
        $currentDate = $startDate->copy();

        // ============================================
        // LOAD ALL SETTINGS FROM USER CONFIGURATION
        // ============================================
        $shortBreakDuration = $settings->short_break ?? 5;
        $longBreakDuration = $settings->long_break ?? 15;
        $minBreakBetweenSessions = $settings->min_break_between_sessions ?? 10;

        $usePomodoro = $settings->use_pomodoro ?? true;
        $pomodoroDuration = $settings->pomodoro_duration ?? 25;
        $pomodorosBeforeLongBreak = $settings->pomodoros_before_long_break ?? 4;

        $maxStudyHoursPerDay = $settings->max_study_hours_per_day ?? 8;
        $maxStudyMinutesPerDay = $maxStudyHoursPerDay * 60;
        // HARD_CORE subjects should dominate study time, so allow many per day
        // Default was 2 which blocked all HARD_CORE after just 2 sessions
        $maxHardPerDay = $settings->max_hard_per_day ?? 20;

        $noConsecutiveHard = $settings->no_consecutive_hard ?? true;
        $languageDailyGuarantee = $settings->language_daily_guarantee ?? false;

        $enablePrayerTimes = $settings->enable_prayer_times ?? false;
        $prayerDuration = $settings->prayer_duration_minutes ?? 15;

        // Track which units are in progress and completed
        $unitProgress = [];
        foreach ($unitWeeks as $index => $unit) {
            $unitId = $unit['unit_id'] ?? "unit_$index";
            $rawSubjectId = $unit['subject_id'] ?? ($unit['subject']->id ?? null);
            $subjectId = $rawSubjectId !== null ? (int)$rawSubjectId : null;
            $unitProgress[$unitId] = [
                'unit_index' => $index,
                'unit' => $unit,
                'subject_id' => $subjectId,
                'current_session' => 0,
                'total_sessions' => count($unit['sessions'] ?? []),
                'completed' => false,
            ];
        }

        // Handle study_days - could be JSON string, array, or null
        $studyDays = $settings->study_days;
        if (is_string($studyDays)) {
            $studyDays = json_decode($studyDays, true);
        }
        if (!is_array($studyDays) || empty($studyDays)) {
            $studyDays = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
        }

        $studyStartTime = $settings->study_start_time ?? '08:00';
        $studyEndTime = $settings->study_end_time ?? '22:00';

        // Get prayer times for the schedule period
        $prayerTimesCache = [];
        if ($enablePrayerTimes) {
            $prayerTimesCache = $this->getPrayerTimesForPeriod($user, $startDate, $endDate);
        }

        // Track last scheduled subject to avoid consecutive same-subject
        $lastScheduledSubjectId = null;
        $lastScheduledCategory = null;

        // Get subjects for infinite placeholder sessions when units run out
        $subjectsForPlaceholders = collect($unitWeeks)->map(function($unit) {
            return [
                'subject_id' => $unit['subject_id'],
                'subject' => $unit['subject'],
                'category' => $unit['sessions'][0]['category'] ?? 'OTHER',
                'coefficient' => $unit['sessions'][0]['coefficient'] ?? 4,
            ];
        })->unique('subject_id')->values()->all();

        while ($currentDate->lte($endDate)) {
            $dayName = strtolower($currentDate->englishDayOfWeek);

            if (in_array($dayName, $studyDays)) {
                $daySessionCounts = []; // subject_id => count
                $sessionsPlacedToday = 0;
                $studyMinutesToday = 0; // Only counts STUDY sessions, not breaks
                $pomodoroCountToday = 0;
                $hardCountToday = 0;
                $languageScheduledToday = false;
                $placeholderSessionCount = 0; // Track placeholder sessions per subject per day
                $longBreakCountToday = 0; // Track 60-minute breaks per day (max 2)

                // Track current time (starts at study_start_time)
                $currentTime = Carbon::parse($currentDate->toDateString() . ' ' . $studyStartTime);
                $dayEndTime = Carbon::parse($currentDate->toDateString() . ' ' . $studyEndTime);

                // Get blocked time slots for today (prayer times)
                $blockedSlots = $this->getBlockedSlotsForDay(
                    $currentDate,
                    $prayerTimesCache,
                    $prayerDuration
                );

                // Track if last created session was a break to prevent consecutive breaks
                $lastSessionWasBreak = false;

                while (true) { // Keep filling until study time is exhausted
                    // Check if we've reached max study time for today
                    if ($studyMinutesToday >= $maxStudyMinutesPerDay) {
                        \Log::info("[generateUnitBasedSchedule] Reached max study hours for {$currentDate->toDateString()}");
                        break;
                    }

                    // Skip blocked time slots (prayer)
                    $currentTime = $this->skipBlockedSlots($currentTime, $blockedSlots, $dayEndTime);
                    if ($currentTime->gte($dayEndTime)) {
                        break; // No more time today
                    }

                    // Get current energy level based on time of day
                    $currentHour = $currentTime->hour;
                    $energyLevel = $settings->getEnergyLevelForHour($currentHour);

                    // Find next session with constraints (ROUND-ROBIN for ALL subjects)
                    $nextSession = $this->findNextSessionWithConstraints(
                        $unitProgress,
                        $daySessionCounts,
                        $lastScheduledSubjectId,
                        $lastScheduledCategory,
                        2, // max per subject per day
                        $noConsecutiveHard,
                        $hardCountToday,
                        $maxHardPerDay,
                        $energyLevel,
                        $languageDailyGuarantee && !$languageScheduledToday
                    );

                    if (!$nextSession) {
                        // First check if all units are complete - if yes, skip 60-min break logic
                        $allUnitsComplete = $this->allUnitsCompleted($unitProgress);

                        // Only add 60-minute break if there are still INCOMPLETE units with HARD_CORE
                        // AND we haven't been using this break logic too many times today
                        // AND last session was NOT a break (prevent consecutive breaks)
                        if (!$allUnitsComplete &&
                            !$lastSessionWasBreak &&
                            $this->hasRemainingHardCoreSessions($unitProgress) &&
                            ($maxStudyMinutesPerDay - $studyMinutesToday) >= 120 &&
                            $longBreakCountToday < 2) { // Max 2 long breaks per day

                            $longBreakDuration = 60;
                            \Log::info("[generateUnitBasedSchedule] Adding 60min break and resetting hardCount (break #{$longBreakCountToday})");
                            $longBreakCountToday++;

                            $breakSession = $this->createBreakSession(
                                $user,
                                $schedule,
                                $currentDate->toDateString(),
                                $currentTime->format('H:i'),
                                $longBreakDuration
                            );
                            $allSessions[] = $breakSession;
                            $currentTime->addMinutes($longBreakDuration);
                            $lastSessionWasBreak = true;
                            // DON'T count break time toward study limit

                            // Reset hard count after long break
                            $hardCountToday = 0;
                            $lastScheduledSubjectId = null;
                            $lastScheduledCategory = null;
                            continue;
                        }

                        // === FILL REMAINING TIME WITH PLACEHOLDER SESSIONS ===
                        // No more unit sessions available - create infinite placeholder sessions
                        // to fill the study time for this day
                        if (empty($subjectsForPlaceholders)) {
                            break; // No subjects to create placeholders for
                        }

                        // Find next subject for placeholder (round-robin based on session count today)
                        $placeholderSubject = $this->findNextPlaceholderSubject(
                            $subjectsForPlaceholders,
                            $daySessionCounts,
                            $lastScheduledSubjectId,
                            $lastScheduledCategory,
                            $hardCountToday,
                            $maxHardPerDay,
                            $noConsecutiveHard
                        );

                        if (!$placeholderSubject) {
                            // Can't find a valid subject - all subjects are blocked
                            // This usually means all subjects are HARD_CORE and limit reached
                            // Just end the day - don't add infinite 60-min breaks
                            break;
                        }

                        // Create a placeholder session
                        $subjectId = $placeholderSubject['subject_id'];
                        $subjectCategory = $placeholderSubject['category'];
                        $coefficient = $placeholderSubject['coefficient'];
                        $subject = $placeholderSubject['subject'];
                        $subjectName = $subject->name_ar ?? $subject->name ?? 'مادة';

                        // Increment placeholder counter for this subject
                        $placeholderSessionCount++;

                        // Calculate duration
                        $duration = $this->algorithmService->calculateAdjustedSessionDuration(
                            $coefficient,
                            $settings,
                            $currentTime->format('H:i'),
                            $subjectCategory
                        );

                        // Check time constraints
                        $sessionEndTime = $currentTime->copy()->addMinutes($duration);
                        $conflictingSlot = $this->findConflictingBlockedSlot($currentTime, $sessionEndTime, $blockedSlots);
                        if ($conflictingSlot) {
                            $sessionEndTime = Carbon::parse($currentDate->toDateString() . ' ' . $conflictingSlot['start']);
                            $duration = $currentTime->diffInMinutes($sessionEndTime);
                            if ($duration < 20) {
                                $currentTime = Carbon::parse($currentDate->toDateString() . ' ' . $conflictingSlot['end']);
                                continue;
                            }
                        }

                        if ($sessionEndTime->gt($dayEndTime)) {
                            break; // No more time today
                        }

                        // Create placeholder session
                        $session = PlannerStudySession::create([
                            'user_id' => $user->id,
                            'schedule_id' => $schedule->id,
                            'subject_id' => $subjectId,
                            'scheduled_date' => $currentDate->toDateString(),
                            'scheduled_start_time' => $currentTime->format('H:i'),
                            'scheduled_end_time' => $sessionEndTime->format('H:i'),
                            'duration_minutes' => $duration,
                            'session_type' => 'study',
                            'status' => 'scheduled',
                            'required_energy_level' => $energyLevel,
                            'priority_score' => 50,
                            'is_break' => false,
                            'content_title' => "جلسة دراسة - {$subjectName}",
                            'has_content' => false, // No content - placeholder
                        ]);

                        $allSessions[] = $session;
                        $lastSessionWasBreak = false; // Study session, not a break

                        // Update tracking variables
                        $daySessionCounts[$subjectId] = ($daySessionCounts[$subjectId] ?? 0) + 1;
                        $lastScheduledSubjectId = $subjectId;
                        $lastScheduledCategory = $subjectCategory;
                        $studyMinutesToday += $duration;
                        $sessionsPlacedToday++;

                        if ($subjectCategory === 'HARD_CORE') {
                            $hardCountToday++;
                        }

                        // Add break after session ONLY if there's time for another study session after the break
                        // This prevents the day from ending with a break
                        $currentTime = $sessionEndTime->copy();
                        $potentialBreakEnd = $currentTime->copy()->addMinutes($minBreakBetweenSessions);
                        $minNextSessionDuration = 30; // Minimum duration for a study session

                        // Only add break if: time allows, study limit not reached, AND there's time for another session after break
                        if ($currentTime->lt($dayEndTime) &&
                            ($studyMinutesToday + $minBreakBetweenSessions) < $maxStudyMinutesPerDay &&
                            $potentialBreakEnd->copy()->addMinutes($minNextSessionDuration)->lte($dayEndTime)) {

                            $breakSession = $this->createBreakSession(
                                $user,
                                $schedule,
                                $currentDate->toDateString(),
                                $currentTime->format('H:i'),
                                $minBreakBetweenSessions
                            );
                            $allSessions[] = $breakSession;
                            $currentTime->addMinutes($minBreakBetweenSessions);
                            $lastSessionWasBreak = true;
                        }

                        continue; // Continue filling the day
                    }

                    $candidate = $nextSession['session'];
                    $unitId = $nextSession['unit_id'];
                    $subjectId = $candidate['subject_id'] ?? null;
                    $subjectCategory = $candidate['category'] ?? 'OTHER';
                    $coefficient = (int) ($candidate['coefficient'] ?? 4);

                    // Get duration using the algorithm with energy adjustment
                    $duration = $this->algorithmService->calculateAdjustedSessionDuration(
                        $coefficient,
                        $settings,
                        $currentTime->format('H:i'),
                        $subjectCategory
                    );

                    // Check if we have enough time left in the day
                    $sessionEndTime = $currentTime->copy()->addMinutes($duration);

                    // Check against blocked slots
                    $conflictingSlot = $this->findConflictingBlockedSlot($currentTime, $sessionEndTime, $blockedSlots);
                    if ($conflictingSlot) {
                        // Adjust end time to not overlap with blocked slot
                        $sessionEndTime = Carbon::parse($currentDate->toDateString() . ' ' . $conflictingSlot['start']);
                        $duration = $currentTime->diffInMinutes($sessionEndTime);
                        if ($duration < 20) {
                            // Not enough time before blocked slot, skip to after it
                            $currentTime = Carbon::parse($currentDate->toDateString() . ' ' . $conflictingSlot['end']);
                            continue;
                        }
                    }

                    if ($sessionEndTime->gt($dayEndTime)) {
                        break; // No more time today
                    }

                    // Create the session
                    $session = PlannerStudySession::create([
                        'user_id' => $user->id,
                        'schedule_id' => $schedule->id,
                        'subject_id' => $subjectId,
                        'subject_planner_content_id' => $candidate['content_id'] ?? null,
                        'has_content' => $candidate['has_content'] ?? false,
                        'content_phase' => $candidate['phase'] ?? ContentAllocationService::PHASE_UNDERSTANDING,
                        'content_title' => $candidate['content_title'] ?? ContentAllocationService::NO_CONTENT_MESSAGE,
                        'topic_name' => $candidate['topic_path'] ?? $candidate['content_title'] ?? null,
                        'scheduled_date' => $currentDate->toDateString(),
                        'scheduled_start_time' => $currentTime->format('H:i'),
                        'scheduled_end_time' => $sessionEndTime->format('H:i'),
                        'duration_minutes' => $duration,
                        'session_type' => $candidate['type'] ?? ContentAllocationService::SESSION_LESSON_REVIEW,
                        'subject_category' => $subjectCategory,
                        'required_energy_level' => $energyLevel,
                        'priority_score' => (int) (($candidate['priority'] ?? 0.5) * 100),
                        'status' => 'scheduled',
                        'use_pomodoro_technique' => $usePomodoro,
                        'pomodoro_duration_minutes' => $pomodoroDuration,
                    ]);

                    $allSessions[] = $session;
                    $studyMinutesToday += $duration;
                    $lastSessionWasBreak = false; // This is a study session

                    // Track constraints
                    if ($subjectCategory === 'HARD_CORE') {
                        $hardCountToday++;
                    }
                    if ($subjectCategory === 'LANGUAGE') {
                        $languageScheduledToday = true;
                    }

                    // Move current time to end of study session
                    $currentTime = $sessionEndTime->copy();

                    // Update tracking
                    $unitProgress[$unitId]['current_session']++;
                    if ($unitProgress[$unitId]['current_session'] >= $unitProgress[$unitId]['total_sessions']) {
                        $unitProgress[$unitId]['completed'] = true;
                    }
                    $daySessionCounts[$subjectId] = ($daySessionCounts[$subjectId] ?? 0) + 1;
                    $sessionsPlacedToday++;
                    $lastScheduledSubjectId = $subjectId;
                    $lastScheduledCategory = $subjectCategory;

                    // Check if there's more work to do today
                    $hasMoreSessionsToday = false;
                    if ($studyMinutesToday < $maxStudyMinutesPerDay && $currentTime->lt($dayEndTime)) {
                        foreach ($unitProgress as $checkProgress) {
                            if (!$checkProgress['completed']) {
                                $hasMoreSessionsToday = true;
                                break;
                            }
                        }
                    }

                    // Add break if there are more sessions coming today
                    // AND there's enough time for another study session after the break
                    if ($hasMoreSessionsToday) {
                        $pomodoroCountToday++;
                        $breakDuration = ($pomodoroCountToday % $pomodorosBeforeLongBreak === 0)
                            ? $longBreakDuration
                            : $shortBreakDuration;

                        $breakDuration = max($breakDuration, $minBreakBetweenSessions);
                        $breakEndTime = $currentTime->copy()->addMinutes($breakDuration);
                        $minNextSessionDuration = 30; // Minimum duration for next study session

                        // Don't add break if it would overlap with blocked slot or exceed day
                        // ALSO don't add break if there's no time for another session after it
                        $breakConflict = $this->findConflictingBlockedSlot($currentTime, $breakEndTime, $blockedSlots);
                        $hasTimeForNextSession = $breakEndTime->copy()->addMinutes($minNextSessionDuration)->lte($dayEndTime);

                        if (!$breakConflict && $breakDuration > 0 && $breakEndTime->lte($dayEndTime) && $hasTimeForNextSession) {
                            $breakSession = $this->createBreakSession(
                                $user,
                                $schedule,
                                $currentDate->toDateString(),
                                $currentTime->format('H:i'),
                                $breakDuration
                            );
                            $allSessions[] = $breakSession;
                            $currentTime = $breakEndTime->copy();
                            $lastSessionWasBreak = true;
                        }
                    }
                }

                // Add prayer sessions for this day at the end
                $prayerSessions = $this->createPrayerSessionsForDay($user, $schedule, $currentDate, $settings);
                $allSessions = array_merge($allSessions, $prayerSessions);
            }

            $currentDate->addDay();
            // Reset at end of day
            $lastScheduledSubjectId = null;
            $lastScheduledCategory = null;
        }

        return $allSessions;
    }

    /**
     * Find next session with all constraints applied
     *
     * NEW PRIORITY LOGIC (FIXED):
     * - HARD_CORE subjects get 2 consecutive sessions, then 1 other
     * - This ensures HARD_CORE gets ~66% of high-energy time
     * - Ratio: HARD_CORE:OTHER = 2:1 during high/medium energy
     * - Sorted by coefficient within each category
     */
    protected function findNextSessionWithConstraints(
        array &$unitProgress,
        array $daySessionCounts,
        ?int $lastSubjectId,
        ?string $lastCategory,
        int $maxPerSubjectPerDay,
        bool $noConsecutiveHard,
        int $hardCountToday,
        int $maxHardPerDay,
        string $energyLevel,
        bool $preferLanguage
    ): ?array {
        static $hardCoreStreakCount = 0; // Track consecutive HARD_CORE sessions

        $hardCoreCandidates = [];
        $otherCandidates = [];

        foreach ($unitProgress as $unitId => $progress) {
            if ($progress['completed']) {
                continue;
            }

            $unit = $progress['unit'];
            $currentSessionIndex = $progress['current_session'];
            $sessions = $unit['sessions'] ?? [];

            if ($currentSessionIndex >= count($sessions)) {
                continue;
            }

            $subjectId = $progress['subject_id'];
            $session = $sessions[$currentSessionIndex];
            $category = $session['category'] ?? 'OTHER';
            $coefficient = $session['coefficient'] ?? ($unit['subject']->coefficient ?? 4);

            // Check max per subject per day
            if (($daySessionCounts[$subjectId] ?? 0) >= $maxPerSubjectPerDay) {
                continue;
            }

            // Check max hard per day
            if ($category === 'HARD_CORE' && $hardCountToday >= $maxHardPerDay) {
                continue;
            }

            // Check no consecutive hard for same subject
            if ($noConsecutiveHard && $category === 'HARD_CORE' && $lastCategory === 'HARD_CORE' && $subjectId === $lastSubjectId) {
                continue;
            }

            $candidateData = [
                'unit_id' => $unitId,
                'session' => array_merge($session, [
                    'subject' => $unit['subject'] ?? null,
                    'subject_id' => $subjectId,
                    'coefficient' => $coefficient,
                ]),
                'subject_id' => $subjectId,
                'category' => $category,
                'coefficient' => $coefficient,
                'is_language' => $category === 'LANGUAGE',
                'session_count_today' => $daySessionCounts[$subjectId] ?? 0,
            ];

            // Separate HARD_CORE from others
            if ($category === 'HARD_CORE') {
                $hardCoreCandidates[] = $candidateData;
            } else {
                $otherCandidates[] = $candidateData;
            }
        }

        // Sort HARD_CORE by coefficient descending, then by sessions today (round-robin within HARD_CORE)
        usort($hardCoreCandidates, function($a, $b) use ($lastSubjectId, $daySessionCounts) {
            // Avoid same subject consecutively
            $aIsSame = $a['subject_id'] === $lastSubjectId ? 1 : 0;
            $bIsSame = $b['subject_id'] === $lastSubjectId ? 1 : 0;
            if ($aIsSame !== $bIsSame) {
                return $aIsSame - $bIsSame;
            }

            // Round-robin within HARD_CORE: fewer sessions today = higher priority
            $aCount = $daySessionCounts[$a['subject_id']] ?? 0;
            $bCount = $daySessionCounts[$b['subject_id']] ?? 0;
            if ($aCount !== $bCount) {
                return $aCount - $bCount;
            }

            // Then by coefficient descending (higher coefficient = higher priority)
            return $b['coefficient'] <=> $a['coefficient'];
        });

        // Sort others by coefficient descending, then round-robin
        usort($otherCandidates, function($a, $b) use ($lastSubjectId, $daySessionCounts) {
            // Avoid same subject consecutively
            $aIsSame = $a['subject_id'] === $lastSubjectId ? 1 : 0;
            $bIsSame = $b['subject_id'] === $lastSubjectId ? 1 : 0;
            if ($aIsSame !== $bIsSame) {
                return $aIsSame - $bIsSame;
            }

            // Round-robin: fewer sessions today = higher priority
            $aCount = $daySessionCounts[$a['subject_id']] ?? 0;
            $bCount = $daySessionCounts[$b['subject_id']] ?? 0;
            if ($aCount !== $bCount) {
                return $aCount - $bCount;
            }

            // Then by coefficient descending
            return $b['coefficient'] <=> $a['coefficient'];
        });

        // DECISION LOGIC: HARD_CORE gets 3:1 ratio (3 HARD_CORE for every 1 other)
        // This ensures ~75% of sessions go to HARD_CORE subjects
        static $sessionCounter = 0;
        $sessionCounter++;

        // Pattern: HARD_CORE, HARD_CORE, HARD_CORE, OTHER, repeat
        // Sessions 1,2,3 = HARD_CORE, Session 4 = OTHER
        $isHardCoreSlot = ($sessionCounter % 4) != 0;

        if ($energyLevel === 'high' || $energyLevel === 'medium') {
            // High/Medium energy: enforce 3:1 ratio strictly
            if ($isHardCoreSlot && !empty($hardCoreCandidates)) {
                return $hardCoreCandidates[0];
            }
            if (!$isHardCoreSlot && !empty($otherCandidates)) {
                return $otherCandidates[0];
            }
            // Fallback: if preferred category is empty, use the other
            if (!empty($hardCoreCandidates)) {
                return $hardCoreCandidates[0];
            }
            if (!empty($otherCandidates)) {
                return $otherCandidates[0];
            }
        } else {
            // Low energy: still give HARD_CORE 2:1 ratio (2 HARD_CORE for every 1 other)
            $isHardCoreSlotLow = ($sessionCounter % 3) != 0;

            if ($isHardCoreSlotLow && !empty($hardCoreCandidates)) {
                return $hardCoreCandidates[0];
            }
            if (!empty($otherCandidates)) {
                return $otherCandidates[0];
            }
            if (!empty($hardCoreCandidates)) {
                return $hardCoreCandidates[0];
            }
        }

        return null;
    }

    /**
     * Find next subject for placeholder session
     *
     * NEW PRIORITY LOGIC (FIXED):
     * - HARD_CORE gets 2:1 ratio (2 HARD_CORE, then 1 other)
     * - Round-robin within each category for balance
     */
    protected function findNextPlaceholderSubject(
        array $subjects,
        array $daySessionCounts,
        ?int $lastSubjectId,
        ?string $lastCategory,
        int $hardCountToday,
        int $maxHardPerDay,
        bool $noConsecutiveHard
    ): ?array {
        static $placeholderHardCoreStreak = 0;

        if (empty($subjects)) {
            return null;
        }

        $hardCoreCandidates = [];
        $otherCandidates = [];
        $fallbackCandidate = null;

        foreach ($subjects as $subject) {
            $subjectId = $subject['subject_id'];
            $category = $subject['category'] ?? 'OTHER';
            $coefficient = $subject['coefficient'] ?? 4;

            // Skip HARD_CORE if limit reached
            if ($category === 'HARD_CORE' && $hardCountToday >= $maxHardPerDay) {
                continue;
            }

            // Skip consecutive HARD_CORE if not allowed
            if ($noConsecutiveHard && $category === 'HARD_CORE' && $lastCategory === 'HARD_CORE') {
                continue;
            }

            // Track as fallback if same as last subject
            if ($subjectId === $lastSubjectId) {
                $fallbackCandidate = $subject;
                if (count($subjects) > 1) {
                    continue;
                }
            }

            // Separate HARD_CORE from others
            if ($category === 'HARD_CORE') {
                $hardCoreCandidates[] = $subject;
            } else {
                $otherCandidates[] = $subject;
            }
        }

        // Sort HARD_CORE: round-robin first, then by coefficient
        usort($hardCoreCandidates, function($a, $b) use ($daySessionCounts) {
            // Round-robin: fewer sessions = higher priority
            $aCount = $daySessionCounts[$a['subject_id']] ?? 0;
            $bCount = $daySessionCounts[$b['subject_id']] ?? 0;
            if ($aCount !== $bCount) {
                return $aCount - $bCount;
            }
            return $b['coefficient'] <=> $a['coefficient'];
        });

        // Sort others: round-robin first, then by coefficient
        usort($otherCandidates, function($a, $b) use ($daySessionCounts) {
            $aCount = $daySessionCounts[$a['subject_id']] ?? 0;
            $bCount = $daySessionCounts[$b['subject_id']] ?? 0;
            if ($aCount !== $bCount) {
                return $aCount - $bCount;
            }
            return $b['coefficient'] <=> $a['coefficient'];
        });

        // Track streak
        if ($lastCategory === 'HARD_CORE') {
            $placeholderHardCoreStreak++;
        } else {
            $placeholderHardCoreStreak = 0;
        }

        // HARD_CORE gets 2:1 ratio
        if ($placeholderHardCoreStreak >= 2 && !empty($otherCandidates)) {
            $placeholderHardCoreStreak = 0;
            return $otherCandidates[0];
        }

        if (!empty($hardCoreCandidates)) {
            return $hardCoreCandidates[0];
        }
        if (!empty($otherCandidates)) {
            return $otherCandidates[0];
        }

        // Fallback to same subject if nothing else available
        return $fallbackCandidate;
    }

    /**
     * Get blocked time slots for a day (prayer times)
     */
    protected function getBlockedSlotsForDay(
        Carbon $date,
        array $prayerTimesCache,
        int $prayerDuration
    ): array {
        $blockedSlots = [];
        $dateKey = $date->toDateString();

        // Add prayer times as blocked slots
        if (isset($prayerTimesCache[$dateKey])) {
            foreach ($prayerTimesCache[$dateKey] as $prayer => $time) {
                if ($time) {
                    $start = Carbon::parse($dateKey . ' ' . $time);
                    $end = $start->copy()->addMinutes($prayerDuration);
                    $blockedSlots[] = [
                        'type' => 'prayer',
                        'name' => $prayer,
                        'start' => $start->format('H:i'),
                        'end' => $end->format('H:i'),
                    ];
                }
            }
        }

        // Sort blocked slots by start time
        usort($blockedSlots, fn($a, $b) => strcmp($a['start'], $b['start']));

        return $blockedSlots;
    }

    /**
     * Skip past any blocked time slots
     */
    protected function skipBlockedSlots(Carbon $currentTime, array $blockedSlots, Carbon $dayEndTime): Carbon
    {
        $dateStr = $currentTime->toDateString();

        foreach ($blockedSlots as $slot) {
            $slotStart = Carbon::parse($dateStr . ' ' . $slot['start']);
            $slotEnd = Carbon::parse($dateStr . ' ' . $slot['end']);

            if ($currentTime->gte($slotStart) && $currentTime->lt($slotEnd)) {
                $currentTime = $slotEnd->copy();
            }
        }

        return $currentTime;
    }

    /**
     * Find if a time range conflicts with any blocked slot
     */
    protected function findConflictingBlockedSlot(Carbon $start, Carbon $end, array $blockedSlots): ?array
    {
        $dateStr = $start->toDateString();

        foreach ($blockedSlots as $slot) {
            $slotStart = Carbon::parse($dateStr . ' ' . $slot['start']);
            $slotEnd = Carbon::parse($dateStr . ' ' . $slot['end']);

            if ($start->lt($slotEnd) && $end->gt($slotStart)) {
                return $slot;
            }
        }

        return null;
    }

    /**
     * Get prayer times for a date range
     */
    protected function getPrayerTimesForPeriod(User $user, Carbon $startDate, Carbon $endDate): array
    {
        $prayerTimes = [];

        try {
            $prayers = PrayerTime::where('user_id', $user->id)
                ->whereBetween('date', [$startDate->toDateString(), $endDate->toDateString()])
                ->get();

            foreach ($prayers as $prayer) {
                $dateKey = $prayer->date instanceof Carbon
                    ? $prayer->date->toDateString()
                    : $prayer->date;
                $prayerTimes[$dateKey] = [
                    'fajr' => $prayer->fajr_time,
                    'dhuhr' => $prayer->dhuhr_time,
                    'asr' => $prayer->asr_time,
                    'maghrib' => $prayer->maghrib_time,
                    'isha' => $prayer->isha_time,
                ];
            }
        } catch (\Exception $e) {
            \Log::warning("[getPrayerTimesForPeriod] Could not load prayer times: " . $e->getMessage());
        }

        return $prayerTimes;
    }

    /**
     * Check if all units are completed
     */
    protected function allUnitsCompleted(array $unitProgress): bool
    {
        foreach ($unitProgress as $progress) {
            if (!$progress['completed']) {
                return false;
            }
        }
        return true;
    }

    /**
     * Check if there are remaining HARD_CORE sessions in any uncompleted unit
     */
    protected function hasRemainingHardCoreSessions(array $unitProgress): bool
    {
        foreach ($unitProgress as $progress) {
            if ($progress['completed']) {
                continue;
            }

            $unit = $progress['unit'];
            $currentSessionIndex = $progress['current_session'];
            $sessions = $unit['sessions'] ?? [];

            for ($i = $currentSessionIndex; $i < count($sessions); $i++) {
                $session = $sessions[$i];
                $category = $session['category'] ?? 'OTHER';
                if ($category === 'HARD_CORE') {
                    return true;
                }
            }
        }

        return false;
    }

    /**
     * Create a break session
     */
    protected function createBreakSession(
        User $user,
        PlannerSchedule $schedule,
        string $date,
        string $startTime,
        int $duration
    ): PlannerStudySession {
        $start = Carbon::parse($startTime);
        $endTime = $start->copy()->addMinutes($duration);

        return PlannerStudySession::create([
            'user_id' => $user->id,
            'schedule_id' => $schedule->id,
            'subject_id' => null,
            'scheduled_date' => $date,
            'scheduled_start_time' => $start->format('H:i'),
            'scheduled_end_time' => $endTime->format('H:i'),
            'duration_minutes' => $duration,
            'is_break' => true,
            'content_title' => 'استراحة',
            'topic_name' => 'استراحة',
            'session_type' => 'break',
            'status' => 'scheduled',
            'priority_score' => 0,
            'has_content' => false,
        ]);
    }

    /**
     * Create prayer sessions for a specific day
     */
    protected function createPrayerSessionsForDay(
        User $user,
        PlannerSchedule $schedule,
        Carbon $date,
        PlannerSetting $settings
    ): array {
        $sessions = [];

        if (!($settings->enable_prayer_times ?? false)) {
            return $sessions;
        }

        $prayerTimes = PrayerTime::where('user_id', $user->id)
            ->where('date', $date->format('Y-m-d'))
            ->first();

        if (!$prayerTimes) {
            return $sessions;
        }

        $studyStartTime = $settings->study_start_time ?? '08:00';
        $studyEndTime = $settings->study_end_time ?? '22:00';
        $prayerDuration = $prayerTimes->prayer_duration_minutes ?? 15;

        $studyStart = Carbon::parse($date->format('Y-m-d') . ' ' . $studyStartTime);
        $studyEnd = Carbon::parse($date->format('Y-m-d') . ' ' . $studyEndTime);

        $prayers = [
            'الفجر' => $prayerTimes->fajr_time,
            'الظهر' => $prayerTimes->dhuhr_time,
            'العصر' => $prayerTimes->asr_time,
            'المغرب' => $prayerTimes->maghrib_time,
            'العشاء' => $prayerTimes->isha_time,
        ];

        foreach ($prayers as $name => $time) {
            if (!$time) continue;

            $prayerTime = Carbon::parse($date->format('Y-m-d') . ' ' . $time);

            // Only add prayers within study window
            if ($prayerTime->lt($studyStart) || $prayerTime->gt($studyEnd)) {
                continue;
            }

            $prayerEndTime = $prayerTime->copy()->addMinutes($prayerDuration);

            $session = PlannerStudySession::create([
                'user_id' => $user->id,
                'schedule_id' => $schedule->id,
                'subject_id' => null,
                'scheduled_date' => $date->format('Y-m-d'),
                'scheduled_start_time' => $prayerTime->format('H:i'),
                'scheduled_end_time' => $prayerEndTime->format('H:i'),
                'duration_minutes' => $prayerDuration,
                'is_break' => true,
                'content_title' => '🕌 صلاة ' . $name,
                'topic_name' => 'صلاة ' . $name,
                'session_type' => 'break',
                'status' => 'scheduled',
                'priority_score' => 100,
                'has_content' => false,
            ]);

            $sessions[] = $session;
        }

        return $sessions;
    }

    /**
     * Get closest exam date for the user
     */
    protected function getClosestExamDate(User $user): ?Carbon
    {
        $exam = ExamSchedule::where('user_id', $user->id)
            ->where('exam_date', '>=', now())
            ->orderBy('exam_date')
            ->first();

        return $exam ? Carbon::parse($exam->exam_date) : null;
    }

    /**
     * Get existing due sessions (spaced reviews)
     */
    protected function getExistingDueSessions(User $user, Carbon $startDate, Carbon $endDate): array
    {
        return [];
    }

    /**
     * Calculate feasibility score
     */
    protected function calculateFeasibilityScore(PlannerSchedule $schedule, PlannerSetting $settings): float
    {
        $sessions = PlannerStudySession::where('schedule_id', $schedule->id)
            ->whereNull('deleted_at')
            ->where('is_break', false)
            ->get();

        if ($sessions->isEmpty()) {
            return 0.0;
        }

        $totalStudyMinutes = $sessions->sum('duration_minutes');
        $dailyGoalMinutes = ($settings->max_study_hours_per_day ?? 8) * 60;

        $startDate = Carbon::parse($schedule->start_date);
        $endDate = Carbon::parse($schedule->end_date);
        $totalDays = max(1, $startDate->diffInDays($endDate) + 1);

        $targetMinutes = $dailyGoalMinutes * $totalDays;

        if ($targetMinutes == 0) {
            return 1.0;
        }

        $ratio = $totalStudyMinutes / $targetMinutes;

        // Score between 0.5 (half of goal) and 1.0 (at or above goal)
        return min(1.0, max(0.0, $ratio));
    }

    /**
     * Activate a schedule
     */
    public function activateSchedule(PlannerSchedule $schedule): void
    {
        // Deactivate other schedules for this user
        PlannerSchedule::where('user_id', $schedule->user_id)
            ->where('id', '!=', $schedule->id)
            ->where('status', 'active')
            ->update(['status' => 'inactive']);

        // Activate this schedule
        $schedule->update(['status' => 'active']);
    }
}
