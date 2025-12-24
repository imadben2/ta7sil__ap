<?php

namespace App\Services;

use App\Models\User;
use App\Models\Subject;
use App\Models\SubjectPlannerContent;
use App\Models\UserSubjectPlannerProgress;
use App\Models\PlannerStudySession;
use Carbon\Carbon;
use Illuminate\Support\Collection;

/**
 * Service for allocating curriculum content to study sessions
 * Implements the algorithm from promt.md for content-based scheduling
 */
class ContentAllocationService
{
    /**
     * Subject category constants (from promt.md algorithm)
     */
    const CATEGORY_HARD_CORE = 'HARD_CORE';       // رياضيات/فيزياء/علوم
    const CATEGORY_LANGUAGE = 'LANGUAGE';         // العربية/الفرنسية/الإنجليزية
    const CATEGORY_MEMORIZATION = 'MEMORIZATION'; // إسلامية/تاريخ-جغرافيا/فلسفة
    const CATEGORY_OTHER = 'OTHER';

    /**
     * Content phase constants
     */
    const PHASE_UNDERSTANDING = 'understanding';
    const PHASE_REVIEW = 'review';
    const PHASE_THEORY_PRACTICE = 'theory_practice';
    const PHASE_EXERCISE_PRACTICE = 'exercise_practice';
    const PHASE_TEST = 'test';

    /**
     * Session type constants (from promt.md)
     */
    const SESSION_LESSON_REVIEW = 'lesson_review';
    const SESSION_EXERCISES = 'exercises';
    const SESSION_TOPIC_TEST = 'topic_test';
    const SESSION_UNIT_TEST = 'unit_test';
    const SESSION_SPACED_REVIEW = 'spaced_review';
    const SESSION_LANGUAGE_DAILY = 'language_daily';
    const SESSION_MOCK_TEST = 'mock_test';

    /**
     * Unit test duration for high coefficient subjects (120 minutes)
     */
    const UNIT_TEST_DURATION_HIGH_COEF = 120;
    const UNIT_TEST_DURATION_NORMAL = 60;

    /**
     * Sessions per week for unit-based scheduling
     */
    const SESSIONS_PER_UNIT_WEEK = 7;

    /**
     * Placeholder message for subjects without content
     */
    const NO_CONTENT_MESSAGE = 'سيتم اضافة المحتوى قريبا';

    /**
     * Spaced review intervals in days (from promt.md)
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
     * Check if a subject has curriculum content available for the user's academic context
     *
     * This method also checks equivalent subjects (same name, different stream) since
     * content may be linked to a different stream's subject ID.
     */
    public function subjectHasContent(int $subjectId, User $user): bool
    {
        // Get academic context from user_academic_profiles table
        $academicContext = $this->getUserAcademicContext($user);

        if (!$academicContext['phase_id'] || !$academicContext['year_id']) {
            return false;
        }

        // Find subject that has content (may be equivalent subject from another stream)
        $contentSubjectId = $this->findSubjectWithContent($subjectId, $academicContext);

        return $contentSubjectId !== null;
    }

    /**
     * Get the next content item to study for a subject based on user progress
     *
     * This method also checks equivalent subjects (same name, different stream) since
     * content may be linked to a different stream's subject ID.
     */
    public function getNextContent(
        int $subjectId,
        User $user,
        string $sessionType = 'study'
    ): ?SubjectPlannerContent {
        // Get academic context from user_academic_profiles table
        $academicContext = $this->getUserAcademicContext($user);

        if (!$academicContext['phase_id'] || !$academicContext['year_id']) {
            return null;
        }

        // Find subject that has content (may be equivalent subject from another stream)
        $contentSubjectId = $this->findSubjectWithContent($subjectId, $academicContext);
        if (!$contentSubjectId) {
            return null;
        }

        // Determine which phase to prioritize based on session type
        $phaseField = $this->getPhaseFieldForSessionType($sessionType);

        // Get all content items for this subject (use the subject that has content)
        $contentItems = SubjectPlannerContent::with(['parent.parent'])
            ->forAcademicContext(
                $academicContext['phase_id'],
                $academicContext['year_id'],
                $academicContext['stream_id']
            )
            ->forSubject($contentSubjectId)
            ->published()
            ->whereIn('level', ['topic', 'subtopic', 'learning_objective'])
            ->orderBy('order')
            ->get();

        if ($contentItems->isEmpty()) {
            return null;
        }

        // Get user progress for these items
        $progressMap = UserSubjectPlannerProgress::where('user_id', $user->id)
            ->whereIn('subject_planner_content_id', $contentItems->pluck('id'))
            ->get()
            ->keyBy('subject_planner_content_id');

        // Find first incomplete content for the phase
        foreach ($contentItems as $content) {
            $progress = $progressMap->get($content->id);

            // Check if this content requires the phase
            $requiresPhase = $this->contentRequiresPhase($content, $phaseField);
            if (!$requiresPhase) {
                continue;
            }

            // Check if phase is not completed
            $isPhaseCompleted = $progress && $progress->$phaseField;
            if (!$isPhaseCompleted) {
                return $content;
            }
        }

        // If all items are complete for this phase, return first item for review
        return $contentItems->first();
    }

    /**
     * Get content backlog for schedule generation (STEP 1 from promt.md)
     * Returns array of content items with their required sessions
     *
     * For each Topic T:
     *   - Add lessonRequired sessions (LESSON_REVIEW)
     *   - Add exerciseRequired sessions (EXERCISES)
     *   - Add 1 session (TOPIC_TEST)
     *
     * For language subjects, also add LANGUAGE_DAILY pool
     */
    public function buildContentBacklog(
        User $user,
        Collection $subjects,
        ?\Carbon\Carbon $examDate = null
    ): array {
        $backlog = [];
        $languageSubjects = [];

        foreach ($subjects as $subjectPriority) {
            $subject = $subjectPriority->subject ?? $subjectPriority;
            $subjectId = is_object($subject) ? $subject->id : $subject;

            // Get subject model for category
            $subjectModel = is_object($subject) && $subject instanceof Subject
                ? $subject
                : Subject::find($subjectId);

            if (!$subjectModel) {
                continue;
            }

            $category = $this->getSubjectCategory($subjectModel);
            $coefficient = $this->getSubjectCoefficientForUser($subjectModel, $user);

            // Track language subjects for daily sessions
            if ($category === self::CATEGORY_LANGUAGE) {
                $languageSubjects[] = $subjectModel;
            }

            if (!$this->subjectHasContent($subjectId, $user)) {
                // Subject has no content - mark for "coming soon" message
                $backlog[] = [
                    'subject_id' => $subjectId,
                    'subject' => $subjectModel,
                    'has_content' => false,
                    'content' => null,
                    'content_id' => null,
                    'sessions_needed' => 1,
                    'type' => self::SESSION_LESSON_REVIEW,
                    'phase' => self::PHASE_UNDERSTANDING,
                    'priority' => $this->calculatePriorityForSubject(
                        $subjectModel,
                        $examDate,
                        false,
                        false,
                        $category === self::CATEGORY_LANGUAGE,
                        $user
                    ),
                    'category' => $category,
                    'base_duration' => self::BASE_DURATION[$coefficient] ?? 60,
                    'content_title' => self::NO_CONTENT_MESSAGE,
                ];
                continue;
            }

            // Get content items with their required sessions
            $contentItems = $this->getSubjectContentWithRequirements($subjectId, $user, $examDate);

            foreach ($contentItems as $item) {
                $backlog = array_merge($backlog, $item['sessions']);
            }
        }

        // Add LANGUAGE_DAILY pool for language subjects (from promt.md)
        foreach ($languageSubjects as $langSubject) {
            // Create multiple language daily sessions (will be used as needed)
            for ($i = 0; $i < 30; $i++) { // Pool of 30 daily sessions
                $backlog[] = [
                    'subject_id' => $langSubject->id,
                    'subject' => $langSubject,
                    'has_content' => true,
                    'content' => null,
                    'content_id' => null,
                    'type' => self::SESSION_LANGUAGE_DAILY,
                    'phase' => self::PHASE_UNDERSTANDING,
                    'priority' => 0.25, // Low priority, will get bonus when needed
                    'category' => self::CATEGORY_LANGUAGE,
                    'base_duration' => self::BASE_DURATION[$langSubject->coefficient ?? 3] ?? 50,
                    'content_title' => 'جلسة لغة يومية - ' . ($langSubject->name_ar ?? $langSubject->name),
                    'is_language_daily' => true,
                ];
            }
        }

        // Sort backlog by priority (descending)
        usort($backlog, fn($a, $b) => ($b['priority'] ?? 0) <=> ($a['priority'] ?? 0));

        return $backlog;
    }

    /**
     * Build unit-based weekly backlog
     *
     * كل عنوان وحدة اعمل عليه جلسات اسبوع كامل:
     * - جلسة أولى: درس (understanding)
     * - جلسات وسطى: حل تمارين (exercises) - 5 sessions
     * - جلسة أخيرة: اختبار الوحدة (unit test) - 120 دقيقة للمواد ذات المعامل الأكبر
     *
     * SORTING LOGIC (UPDATED):
     * 1. HARD_CORE subjects ALWAYS come first (sorted by coefficient descending)
     * 2. Other subjects sorted by coefficient descending (excluding HARD_CORE)
     *
     * UNIT COUNT LOGIC (UPDATED):
     * - HARD_CORE subjects get MORE units (proportional to coefficient)
     * - Other subjects get FEWER units (based on coefficient)
     *
     * @param User $user
     * @param Collection $subjects
     * @param Carbon|null $examDate
     * @return array Array of unit-week sessions grouped by unit
     */
    public function buildUnitWeeklyBacklog(
        User $user,
        Collection $subjects,
        ?\Carbon\Carbon $examDate = null
    ): array {
        $unitWeeks = [];

        // STEP 1: Separate subjects into HARD_CORE and others, then sort
        $hardCoreSubjects = [];
        $otherSubjects = [];

        foreach ($subjects as $subjectPriority) {
            $subject = $subjectPriority->subject ?? $subjectPriority;
            $subjectId = is_object($subject) ? $subject->id : $subject;

            $subjectModel = is_object($subject) && $subject instanceof Subject
                ? $subject
                : Subject::find($subjectId);

            if (!$subjectModel) {
                continue;
            }

            $coefficient = $this->getSubjectCoefficientForUser($subjectModel, $user);
            $category = $this->getSubjectCategory($subjectModel);

            $subjectData = [
                'subject' => $subjectModel,
                'subjectId' => $subjectId,
                'coefficient' => $coefficient,
                'category' => $category,
            ];

            if ($category === self::CATEGORY_HARD_CORE) {
                $hardCoreSubjects[] = $subjectData;
            } else {
                $otherSubjects[] = $subjectData;
            }
        }

        // Sort HARD_CORE by coefficient descending
        usort($hardCoreSubjects, fn($a, $b) => $b['coefficient'] <=> $a['coefficient']);

        // Sort others by coefficient descending (excluding HARD_CORE)
        usort($otherSubjects, fn($a, $b) => $b['coefficient'] <=> $a['coefficient']);

        // Merge: HARD_CORE first, then others
        $sortedSubjects = array_merge($hardCoreSubjects, $otherSubjects);

        // STEP 2: Process each subject with appropriate unit count
        foreach ($sortedSubjects as $subjectData) {
            $subjectModel = $subjectData['subject'];
            $subjectId = $subjectData['subjectId'];
            $coefficient = $subjectData['coefficient'];
            $category = $subjectData['category'];
            $isHighCoefficient = $coefficient >= 6;

            // Calculate number of units based on category and coefficient
            // HARD_CORE gets MORE units, others get FEWER
            $numUnits = $this->calculateUnitsForSubject($category, $coefficient);

            if (!$this->subjectHasContent($subjectId, $user)) {
                // Subject has no content - create placeholder sessions
                // numUnits is already calculated by calculateUnitsForSubject()

                if ($category === self::CATEGORY_HARD_CORE) {
                    // HARD_CORE without content: 7 sessions per unit (1 lesson + 5 exercises + 1 test)
                    for ($unitNum = 1; $unitNum <= $numUnits; $unitNum++) {
                        $placeholderSessions = $this->buildNoContentHardCoreSessions(
                            $subjectId,
                            $subjectModel,
                            $coefficient,
                            $category,
                            $examDate,
                            $user
                        );
                        // Adjust session labels for each unit
                        foreach ($placeholderSessions as &$sess) {
                            if ($unitNum > 1) {
                                $sess['content_title'] = str_replace(
                                    [' - درس', ' - تمارين ', ' - اختبار'],
                                    [" - درس {$unitNum}", " - تمارين {$unitNum}.", " - اختبار {$unitNum}"],
                                    $sess['content_title']
                                );
                            }
                        }
                        unset($sess);

                        $priority = $this->calculatePriorityForSubject($subjectModel, $examDate, false, false, false, $user);
                        // Decrease priority slightly for later units
                        $priority = $priority - ($unitNum - 1) * 0.1;

                        $unitWeeks[] = [
                            'unit_id' => 'placeholder_' . $subjectId . '_unit' . $unitNum,
                            'unit_title' => ($subjectModel->name_ar ?? $subjectModel->name) . ' - الوحدة ' . $unitNum,
                            'subject_id' => $subjectId,
                            'subject' => $subjectModel,
                            'has_content' => false,
                            'priority' => $priority,
                            'sessions' => $placeholderSessions,
                        ];
                    }
                } else {
                    // Non-HARD_CORE without content: create multiple units with generic sessions
                    for ($unitNum = 1; $unitNum <= $numUnits; $unitNum++) {
                        $genericSessions = $this->buildNoContentGenericSessions(
                            $subjectId,
                            $subjectModel,
                            $coefficient,
                            $category,
                            $examDate,
                            $user
                        );
                        // Adjust session labels for each unit
                        foreach ($genericSessions as &$sess) {
                            if ($unitNum > 1) {
                                $sess['content_title'] = str_replace(
                                    'جلسة دراسة',
                                    "جلسة دراسة {$unitNum}",
                                    $sess['content_title']
                                );
                            }
                        }
                        unset($sess);

                        $priority = $this->calculatePriorityForSubject($subjectModel, $examDate, false, false, false, $user);
                        $priority = $priority - ($unitNum - 1) * 0.1;

                        $unitWeeks[] = [
                            'unit_id' => 'generic_' . $subjectId . '_unit' . $unitNum,
                            'unit_title' => ($subjectModel->name_ar ?? $subjectModel->name) . ' - الوحدة ' . $unitNum,
                            'subject_id' => $subjectId,
                            'subject' => $subjectModel,
                            'has_content' => false,
                            'priority' => $priority,
                            'sessions' => $genericSessions,
                        ];
                    }
                }
                continue;
            }

            // Subject HAS content - different handling based on category
            if ($category === self::CATEGORY_HARD_CORE) {
                // HARD_CORE with content: Use 7-session unit pattern
                $units = $this->getUnitsForSubject($subjectId, $user);

                foreach ($units as $unit) {
                    $unitSessions = $this->buildUnitWeekSessions(
                        $unit,
                        $subjectModel,
                        $user,
                        $examDate,
                        $isHighCoefficient,
                        $category
                    );

                    $unitWeeks[] = [
                        'unit_id' => $unit->id,
                        'unit_title' => $unit->title_ar,
                        'subject_id' => $subjectId,
                        'subject' => $subjectModel,
                        'has_content' => true,
                        'priority' => $this->calculateSessionPriority($unit, $subjectModel, self::PHASE_UNDERSTANDING, $examDate),
                        'sessions' => $unitSessions,
                    ];
                }
            } else {
                // Non-HARD_CORE with content: Use simple topic-based sessions
                $topicSessions = $this->buildTopicBasedSessions(
                    $subjectId,
                    $subjectModel,
                    $user,
                    $examDate,
                    $category
                );
                $unitWeeks = array_merge($unitWeeks, $topicSessions);
            }
        }

        // Sort unit weeks by priority (descending)
        usort($unitWeeks, fn($a, $b) => ($b['priority'] ?? 0) <=> ($a['priority'] ?? 0));

        return $unitWeeks;
    }

    /**
     * Get units for a subject within user's academic context
     */
    protected function getUnitsForSubject(int $subjectId, User $user): Collection
    {
        // Get academic context from user_academic_profiles table
        $academicContext = $this->getUserAcademicContext($user);

        if (!$academicContext['phase_id'] || !$academicContext['year_id']) {
            // User has no academic profile - return empty collection
            return collect();
        }

        return SubjectPlannerContent::with(['children.children']) // children are topics
            ->forAcademicContext(
                $academicContext['phase_id'],
                $academicContext['year_id'],
                $academicContext['stream_id']
            )
            ->forSubject($subjectId)
            ->published()
            ->where('level', 'unit')
            ->orderBy('order')
            ->get();
    }

    /**
     * Find equivalent subject ID that has content
     *
     * Since subjects are duplicated per stream (e.g., Physics exists as ID=2 for stream 1
     * and ID=20 for stream 3), but content may only be linked to stream 1 subject IDs,
     * this method finds the content subject by matching subject names.
     *
     * Uses Subject model only to get the name, then queries subject_planner_content
     * with that name's equivalent subject_id based on academic_stream_ids.
     *
     * @param int $subjectId The user's subject ID
     * @param array $academicContext User's academic context
     * @return int|null Subject ID that has content, or null if none found
     */
    protected function findSubjectWithContent(int $subjectId, array $academicContext): ?int
    {
        // First check if the given subject has content directly
        $hasDirectContent = SubjectPlannerContent::forAcademicContext(
                $academicContext['phase_id'],
                $academicContext['year_id'],
                $academicContext['stream_id']
            )
            ->forSubject($subjectId)
            ->published()
            ->exists();

        if ($hasDirectContent) {
            return $subjectId;
        }

        // Get user's subject name
        $subject = Subject::find($subjectId);
        if (!$subject) {
            return null;
        }
        $subjectName = $subject->name_ar;

        // Find all subjects with the same name across all streams
        $equivalentSubjectIds = Subject::where('name_ar', $subjectName)
            ->pluck('id')
            ->toArray();

        if (empty($equivalentSubjectIds)) {
            return null;
        }

        // Find content that matches any of these subject IDs and user's academic context
        $contentSubjectId = SubjectPlannerContent::forAcademicContext(
                $academicContext['phase_id'],
                $academicContext['year_id'],
                $academicContext['stream_id']
            )
            ->whereIn('subject_id', $equivalentSubjectIds)
            ->published()
            ->value('subject_id');

        return $contentSubjectId;
    }

    /**
     * Get academic context from user's academic profile (user_academic_profiles table)
     * Returns array with phase_id, year_id, stream_id (can be null if user has no profile)
     */
    protected function getUserAcademicContext(User $user): array
    {
        // Load academic profile if not loaded
        if (!$user->relationLoaded('academicProfile')) {
            $user->load('academicProfile.academicPhase', 'academicProfile.academicYear', 'academicProfile.academicStream');
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
     * Build 7 sessions for a unit week
     *
     * Day 1: درس (lesson/understanding)
     * Days 2-6: حل تمارين (exercises)
     * Day 7: اختبار الوحدة (unit test)
     */
    protected function buildUnitWeekSessions(
        SubjectPlannerContent $unit,
        Subject $subject,
        User $user,
        ?\Carbon\Carbon $examDate,
        bool $isHighCoefficient,
        string $category
    ): array {
        $sessions = [];
        // Get coefficient from subject_stream pivot table based on user's stream
        $coefficient = $this->getSubjectCoefficientForUser($subject, $user);
        $baseDuration = self::BASE_DURATION[$coefficient] ?? 60;

        // Get topics under this unit for detailed content
        $topics = $unit->children ?? collect();
        $topicsArray = $topics->values()->all();
        $topicCount = count($topicsArray);

        // Get user progress for this unit
        $progress = UserSubjectPlannerProgress::where('user_id', $user->id)
            ->where('subject_planner_content_id', $unit->id)
            ->first();

        $unitPath = $unit->full_path ?? $unit->title_ar;
        $importance = $unit->is_bac_priority ? 5 : 3;
        $difficulty = $this->getDifficultyLevel($unit);

        // Day 1: Lesson (understanding/درس)
        $sessions[] = [
            'day_in_week' => 1,
            'subject_id' => $subject->id,
            'subject' => $subject,
            'has_content' => true,
            'content' => $unit,
            'content_id' => $unit->id,
            'type' => self::SESSION_LESSON_REVIEW,
            'phase' => self::PHASE_UNDERSTANDING,
            'priority' => $this->calculateSessionPriority($unit, $subject, self::PHASE_UNDERSTANDING, $examDate) + 0.3,
            'category' => $category,
            'coefficient' => $coefficient,
            'base_duration' => $baseDuration,
            'content_title' => $unit->title_ar . ' - درس',
            'topic_path' => $unitPath,
            'importance' => $importance,
            'difficulty' => $difficulty,
            'session_label' => 'درس الوحدة',
        ];

        // Days 2-6: Exercises (حل تمارين)
        for ($day = 2; $day <= 6; $day++) {
            // Cycle through topics for exercise sessions
            $topicIndex = ($day - 2) % max(1, $topicCount);
            $topic = $topicCount > 0 ? $topicsArray[$topicIndex] : null;

            $exerciseTitle = $unit->title_ar . ' - تمارين';
            if ($topic) {
                $exerciseTitle = $topic->title_ar . ' - تمارين';
            }

            $sessions[] = [
                'day_in_week' => $day,
                'subject_id' => $subject->id,
                'subject' => $subject,
                'has_content' => true,
                'content' => $topic ?? $unit,
                'content_id' => $topic?->id ?? $unit->id,
                'type' => self::SESSION_EXERCISES,
                'phase' => self::PHASE_EXERCISE_PRACTICE,
                'priority' => $this->calculateSessionPriority($unit, $subject, self::PHASE_EXERCISE_PRACTICE, $examDate),
                'category' => $category,
                'base_duration' => $baseDuration,
                'content_title' => $exerciseTitle,
                'topic_path' => $topic?->full_path ?? $unitPath,
                'importance' => $importance,
                'difficulty' => $difficulty,
                'session_label' => 'تمارين ' . ($day - 1),
                'coefficient' => $coefficient,
            ];
        }

        // Day 7: Unit Test (اختبار الوحدة)
        // 120 minutes for high coefficient subjects, 60 for others
        $testDuration = $isHighCoefficient ? self::UNIT_TEST_DURATION_HIGH_COEF : self::UNIT_TEST_DURATION_NORMAL;

        $sessions[] = [
            'day_in_week' => 7,
            'subject_id' => $subject->id,
            'subject' => $subject,
            'has_content' => true,
            'content' => $unit,
            'content_id' => $unit->id,
            'type' => self::SESSION_UNIT_TEST,
            'phase' => self::PHASE_TEST,
            'priority' => $this->calculateSessionPriority($unit, $subject, self::PHASE_TEST, $examDate) + 0.4,
            'category' => $category,
            'base_duration' => $testDuration,
            'content_title' => $unit->title_ar . ' - اختبار الوحدة',
            'topic_path' => $unitPath,
            'importance' => $importance,
            'difficulty' => $difficulty,
            'session_label' => 'اختبار الوحدة',
            'is_unit_test' => true,
            'is_high_coefficient' => $isHighCoefficient,
            'coefficient' => $coefficient,
        ];

        return $sessions;
    }

    /**
     * Check if a subject is a high coefficient subject for the user's stream
     *
     * High coefficient subjects based on stream (شعبة):
     * - علوم تجريبية: رياضيات (7), فيزياء (6), علوم طبيعية (6)
     * - رياضيات: رياضيات (7), فيزياء (6), رياضيات تطبيقية (6)
     * - آداب وفلسفة: فلسفة (6), أدب عربي (5), لغات (5)
     * - تقني رياضي: رياضيات (6), هندسة (6), فيزياء (5)
     * - تسيير واقتصاد: اقتصاد (6), رياضيات (5), تسيير (5)
     * - لغات أجنبية: لغة أجنبية أولى (5), لغة أجنبية ثانية (5), أدب (4)
     */
    public function isHighCoefficientForStream(Subject $subject, User $user): bool
    {
        // Get coefficient from subject_stream pivot table based on user's stream
        $coefficient = $this->getSubjectCoefficientForUser($subject, $user);

        // Coefficient 6 or 7 is considered high for most streams
        if ($coefficient >= 6) {
            return true;
        }

        // Get user's stream
        $stream = $user->academicStream;
        if (!$stream) {
            // Default: coefficient >= 5 is high
            return $coefficient >= 5;
        }

        $streamName = strtolower($stream->name_ar ?? $stream->name ?? '');
        $subjectName = strtolower($subject->name_ar ?? $subject->name ?? '');

        // Stream-specific high coefficient rules
        $highCoefByStream = [
            'علوم' => ['رياضيات', 'فيزياء', 'علوم', 'كيمياء'],
            'رياضيات' => ['رياضيات', 'فيزياء', 'هندسة'],
            'آداب' => ['فلسفة', 'أدب', 'عربية', 'تاريخ', 'جغرافيا'],
            'فلسفة' => ['فلسفة', 'أدب', 'عربية', 'تاريخ', 'جغرافيا'],
            'تقني' => ['رياضيات', 'هندسة', 'فيزياء', 'تكنولوجيا'],
            'تسيير' => ['اقتصاد', 'رياضيات', 'تسيير', 'محاسبة'],
            'لغات' => ['فرنسية', 'إنجليزية', 'ألمانية', 'إسبانية', 'أدب'],
        ];

        foreach ($highCoefByStream as $streamKey => $highSubjects) {
            if (str_contains($streamName, $streamKey)) {
                foreach ($highSubjects as $highSubject) {
                    if (str_contains($subjectName, $highSubject)) {
                        return $coefficient >= 5;
                    }
                }
                break;
            }
        }

        // Default: coefficient >= 6 is high
        return $coefficient >= 6;
    }

    /**
     * Get the coefficient for a subject based on user's academic stream
     *
     * The coefficient is stored in subject_stream pivot table, not in subjects table.
     * This method retrieves the correct coefficient for the user's stream.
     *
     * @param Subject $subject
     * @param User $user
     * @return int Coefficient (1-7), defaults to 4 if not found
     */
    public function getSubjectCoefficientForUser(Subject $subject, User $user): int
    {
        // First, check if subject has a direct coefficient
        if ($subject->coefficient !== null) {
            return (int) $subject->coefficient;
        }

        // Get user's stream from academic profile
        $streamId = $user->academicProfile?->academic_stream_id;
        if (!$streamId) {
            return 4; // Default coefficient
        }

        // Look up coefficient in subject_stream pivot table
        $subjectStream = \DB::table('subject_stream')
            ->where('subject_id', $subject->id)
            ->where('academic_stream_id', $streamId)
            ->where('is_active', true)
            ->first();

        if ($subjectStream && $subjectStream->coefficient !== null) {
            return (int) $subjectStream->coefficient;
        }

        // Fallback: try to get from streams relationship
        $stream = $subject->streams()
            ->where('academic_stream_id', $streamId)
            ->first();

        if ($stream && $stream->pivot->coefficient !== null) {
            return (int) $stream->pivot->coefficient;
        }

        return 4; // Default coefficient
    }

    /**
     * Calculate priority for a subject without specific content
     */
    protected function calculatePriorityForSubject(
        Subject $subject,
        ?\Carbon\Carbon $examDate,
        bool $isLate,
        bool $isDue,
        bool $needsLanguageToday,
        ?User $user = null
    ): float {
        // Get coefficient from subject_stream if user is provided
        $coefficient = $user
            ? $this->getSubjectCoefficientForUser($subject, $user)
            : ($subject->coefficient ?? 4);
        $category = $this->getSubjectCategory($subject);

        // Use default importance/difficulty for subjects without content
        $importance = 3;
        $difficulty = 3;

        // U = urgency (1 / daysLeftToExam)
        $urgency = 0.1;
        if ($examDate) {
            $daysLeft = max(1, \Carbon\Carbon::now()->diffInDays($examDate, false));
            $urgency = 1 / $daysLeft;
        }

        // Normalize values
        $i = $importance / 5;
        $d = $difficulty / 5;
        $c = $coefficient / 7;
        $late = $isLate ? 1 : 0;
        $bonusDue = $isDue ? 0.40 : 0;

        // Category weight
        $catWeight = match ($category) {
            self::CATEGORY_HARD_CORE => 1.10,
            self::CATEGORY_LANGUAGE => 0.95,
            self::CATEGORY_MEMORIZATION => 1.00,
            default => 1.00,
        };

        // Language daily bonus
        $bonusLanguageDaily = ($needsLanguageToday && $category === self::CATEGORY_LANGUAGE) ? 0.25 : 0;

        // Calculate priority
        $priority = (0.38 * $urgency + 0.22 * $i + 0.18 * $d + 0.12 * $c + 0.10 * $late + $bonusDue)
                    * $catWeight
                    + $bonusLanguageDaily;

        return round($priority, 3);
    }

    /**
     * Get all content items for a subject with their session requirements
     * Implements promt.md backlog building per topic
     */
    protected function getSubjectContentWithRequirements(
        int $subjectId,
        User $user,
        ?\Carbon\Carbon $examDate = null
    ): array {
        $result = [];

        // Get academic context from user_academic_profiles table
        $academicContext = $this->getUserAcademicContext($user);

        if (!$academicContext['phase_id'] || !$academicContext['year_id']) {
            return $result; // Return empty if no academic profile
        }

        // Get topic-level content items
        $topics = SubjectPlannerContent::with(['parent.parent'])
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

        // Get subject for calculating requirements
        $subject = Subject::find($subjectId);
        // Get coefficient from subject_stream pivot table based on user's stream
        $coefficient = $subject ? $this->getSubjectCoefficientForUser($subject, $user) : 4;
        $category = $subject ? $this->getSubjectCategory($subject) : self::CATEGORY_OTHER;

        // Get user progress
        $progressMap = UserSubjectPlannerProgress::where('user_id', $user->id)
            ->whereIn('subject_planner_content_id', $topics->pluck('id'))
            ->get()
            ->keyBy('subject_planner_content_id');

        foreach ($topics as $topic) {
            $requirements = $this->calculateTopicRequirements($topic, $coefficient);
            $progress = $progressMap->get($topic->id);
            $sessions = [];

            // Get topic metadata
            $importance = $topic->is_bac_priority ? 5 : 3;
            $difficulty = $this->getDifficultyLevel($topic);

            // Add lesson review sessions
            $lessonsDone = $progress ? ($progress->understanding_completed ? 1 : 0) + ($progress->review_completed ? 1 : 0) : 0;
            $lessonsNeeded = max(0, $requirements['lesson_required'] - $lessonsDone);

            for ($i = 0; $i < $lessonsNeeded; $i++) {
                $phase = $i == 0 && !($progress && $progress->understanding_completed)
                    ? self::PHASE_UNDERSTANDING
                    : self::PHASE_REVIEW;

                $sessions[] = [
                    'subject_id' => $subjectId,
                    'subject' => $subject,
                    'has_content' => true,
                    'content' => $topic,
                    'content_id' => $topic->id,
                    'type' => self::SESSION_LESSON_REVIEW,
                    'phase' => $phase,
                    'priority' => $this->calculateSessionPriority($topic, $subject, $phase, $examDate),
                    'category' => $category,
                    'base_duration' => $requirements['base_duration'],
                    'content_title' => $topic->title_ar,
                    'topic_path' => $topic->full_path ?? $topic->title_ar,
                    'importance' => $importance,
                    'difficulty' => $difficulty,
                ];
            }

            // Add exercise sessions
            $exercisesDone = $progress && $progress->exercise_practice_completed ? $requirements['exercise_required'] : 0;
            $exercisesNeeded = max(0, $requirements['exercise_required'] - $exercisesDone);

            for ($i = 0; $i < $exercisesNeeded; $i++) {
                $sessions[] = [
                    'subject_id' => $subjectId,
                    'subject' => $subject,
                    'has_content' => true,
                    'content' => $topic,
                    'content_id' => $topic->id,
                    'type' => self::SESSION_EXERCISES,
                    'phase' => self::PHASE_EXERCISE_PRACTICE,
                    'priority' => $this->calculateSessionPriority($topic, $subject, self::PHASE_EXERCISE_PRACTICE, $examDate),
                    'category' => $category,
                    'base_duration' => $requirements['base_duration'],
                    'content_title' => $topic->title_ar . ' - تمارين',
                    'topic_path' => $topic->full_path ?? $topic->title_ar,
                    'importance' => $importance,
                    'difficulty' => $difficulty,
                ];
            }

            // Add topic test if ready (from promt.md: TOPIC_TEST only after lesson + exercises)
            $topicReady = $this->isTopicReadyForTest($topic, $user->id);
            $testDone = $progress && $progress->status === 'mastered';

            if (!$testDone) {
                $sessions[] = [
                    'subject_id' => $subjectId,
                    'subject' => $subject,
                    'has_content' => true,
                    'content' => $topic,
                    'content_id' => $topic->id,
                    'type' => self::SESSION_TOPIC_TEST,
                    'phase' => self::PHASE_TEST,
                    'priority' => $this->calculateSessionPriority($topic, $subject, self::PHASE_TEST, $examDate) + 0.2,
                    'category' => $category,
                    'base_duration' => 60, // Tests are fixed at 60 minutes
                    'content_title' => $topic->title_ar . ' - اختبار',
                    'topic_path' => $topic->full_path ?? $topic->title_ar,
                    'importance' => $importance,
                    'difficulty' => $difficulty,
                    'is_topic_ready' => $topicReady, // Used by scheduler to check readiness
                ];
            }

            if (!empty($sessions)) {
                $result[] = [
                    'topic' => $topic,
                    'requirements' => $requirements,
                    'sessions' => $sessions,
                ];
            }
        }

        return $result;
    }

    /**
     * Calculate content requirements based on difficulty (from promt.md algorithm)
     *
     * lessonRequired:
     *   difficulty 1-2: 1 session
     *   difficulty 3: 2 sessions
     *   difficulty 4-5: 3 sessions
     *
     * exerciseRequired:
     *   ceil((estimatedHours*60 - lessonMin) / BaseDuration)
     */
    public function calculateTopicRequirements(SubjectPlannerContent $topic, int $coefficient): array
    {
        $difficulty = $this->getDifficultyLevel($topic);
        $estimatedMinutes = $topic->estimated_duration_minutes ?? 60;
        $baseDuration = self::BASE_DURATION[$coefficient] ?? 60;

        // Calculate lesson required based on difficulty
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
        $exerciseRequired = max(1, ceil($remainingMinutes / $baseDuration));

        return [
            'lesson_required' => $lessonRequired,
            'exercise_required' => $exerciseRequired,
            'base_duration' => $baseDuration,
            'total_sessions' => $lessonRequired + $exerciseRequired + 1, // +1 for test
        ];
    }

    /**
     * Check if a topic is ready for its final test
     */
    public function isTopicReadyForTest(SubjectPlannerContent $topic, int $userId): bool
    {
        $progress = UserSubjectPlannerProgress::where('user_id', $userId)
            ->where('subject_planner_content_id', $topic->id)
            ->first();

        if (!$progress) {
            return false;
        }

        // Check if lesson review phases are completed
        $lessonPhasesComplete = $progress->understanding_completed && $progress->review_completed;

        // For content that requires exercises, check exercise phase too
        if ($topic->requires_exercise_practice) {
            return $lessonPhasesComplete && ($progress->theory_practice_completed || $progress->exercise_practice_completed);
        }

        return $lessonPhasesComplete;
    }

    /**
     * Get spaced review dates after a topic test is completed
     */
    public function getSpacedReviewDates(Carbon $completionDate, string $subjectCategory): array
    {
        $intervals = $subjectCategory === self::CATEGORY_MEMORIZATION
            ? self::REVIEW_INTERVALS_MEMORIZATION
            : self::REVIEW_INTERVALS_DEFAULT;

        return array_map(function ($days) use ($completionDate) {
            return $completionDate->copy()->addDays($days);
        }, $intervals);
    }

    /**
     * Create spaced review sessions after a topic test
     */
    public function createSpacedReviewSessions(
        PlannerStudySession $topicTestSession,
        Subject $subject,
        Carbon $completionDate
    ): array {
        $category = $this->getSubjectCategory($subject);
        $reviewDates = $this->getSpacedReviewDates($completionDate, $category);

        $sessions = [];

        foreach ($reviewDates as $reviewDate) {
            $sessions[] = [
                'user_id' => $topicTestSession->user_id,
                'schedule_id' => $topicTestSession->schedule_id,
                'subject_id' => $topicTestSession->subject_id,
                'subject_planner_content_id' => $topicTestSession->subject_planner_content_id,
                'has_content' => true,
                'content_phase' => self::PHASE_REVIEW,
                'is_spaced_review' => true,
                'original_topic_test_session_id' => $topicTestSession->id,
                'scheduled_date' => $reviewDate,
                'duration_minutes' => 30,
                'session_type' => self::SESSION_SPACED_REVIEW,
                'status' => 'scheduled',
            ];
        }

        return $sessions;
    }

    /**
     * Calculate priority score for a session (from promt.md)
     * P = (0.38U + 0.22I + 0.18D + 0.12C + 0.10Late + BonusDue) × CatW + BonusLanguageDaily
     */
    public function calculateSessionPriority(
        SubjectPlannerContent $content,
        ?Subject $subject,
        string $phase,
        ?Carbon $examDate = null,
        bool $isLate = false,
        bool $isDue = false,
        bool $needsLanguageToday = false,
        ?User $user = null
    ): float {
        // Get coefficient from subject_stream if user is provided
        $coefficient = ($subject && $user)
            ? $this->getSubjectCoefficientForUser($subject, $user)
            : ($subject->coefficient ?? 4);
        $difficulty = $this->getDifficultyLevel($content);
        $importance = $content->is_bac_priority ? 5 : 3;
        $category = $subject ? $this->getSubjectCategory($subject) : self::CATEGORY_OTHER;

        // U = urgency (1 / daysLeftToExam)
        $urgency = 0.1;
        if ($examDate) {
            $daysLeft = max(1, Carbon::now()->diffInDays($examDate, false));
            $urgency = 1 / $daysLeft;
        }

        // Normalize values
        $i = $importance / 5;
        $d = $difficulty / 5;
        $c = $coefficient / 7;
        $late = $isLate ? 1 : 0;
        $bonusDue = $isDue ? 0.40 : 0;

        // Category weight
        $catWeight = match ($category) {
            self::CATEGORY_HARD_CORE => 1.10,
            self::CATEGORY_LANGUAGE => 0.95,
            self::CATEGORY_MEMORIZATION => 1.00,
            default => 1.00,
        };

        // Language daily bonus
        $bonusLanguageDaily = ($needsLanguageToday && $category === self::CATEGORY_LANGUAGE) ? 0.25 : 0;

        // Calculate priority
        $priority = (0.38 * $urgency + 0.22 * $i + 0.18 * $d + 0.12 * $c + 0.10 * $late + $bonusDue)
                    * $catWeight
                    + $bonusLanguageDaily;

        return round($priority, 3);
    }

    /**
     * Get the phase field name for a session type
     */
    protected function getPhaseFieldForSessionType(string $sessionType): string
    {
        return match ($sessionType) {
            'study', self::SESSION_LESSON_REVIEW => 'understanding_completed',
            'revision', self::SESSION_SPACED_REVIEW => 'review_completed',
            'practice' => 'theory_practice_completed',
            'exam', self::SESSION_EXERCISES => 'exercise_practice_completed',
            default => 'understanding_completed',
        };
    }

    /**
     * Check if content requires a specific phase
     */
    protected function contentRequiresPhase(SubjectPlannerContent $content, string $phaseField): bool
    {
        return match ($phaseField) {
            'understanding_completed' => $content->requires_understanding ?? true,
            'review_completed' => $content->requires_review ?? true,
            'theory_practice_completed' => $content->requires_theory_practice ?? false,
            'exercise_practice_completed' => $content->requires_exercise_practice ?? false,
            default => true,
        };
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
     * Determine subject category based on subject name/type
     */
    public function getSubjectCategory(Subject $subject): string
    {
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
     * Get session duration based on coefficient and energy level (from promt.md)
     */
    public function calculateSessionDuration(int $coefficient, string $energyLevel): int
    {
        $baseDuration = self::BASE_DURATION[$coefficient] ?? 60;

        $energyFactor = match ($energyLevel) {
            'high' => 1.00,
            'medium' => 0.90,
            'low' => ($coefficient >= 6) ? 0.70 : 0.75,
            'veryLow' => 0.60,
            default => 0.90,
        };

        $duration = round($baseDuration * $energyFactor / 5) * 5; // Round to nearest 5
        return max(30, $duration); // Minimum 30 minutes
    }

    /**
     * Build sessions for HARD_CORE subjects without content (7-session pattern)
     *
     * Pattern: 1 lesson + 5 exercises + 1 unit test
     * This maintains the weekly structure for high-priority subjects even without curriculum content
     *
     * @param int $subjectId
     * @param Subject $subject
     * @param int $coefficient
     * @param string $category
     * @param Carbon|null $examDate
     * @return array
     */
    protected function buildNoContentHardCoreSessions(
        int $subjectId,
        Subject $subject,
        int $coefficient,
        string $category,
        ?\Carbon\Carbon $examDate,
        ?User $user = null
    ): array {
        $sessions = [];
        $baseDuration = self::BASE_DURATION[$coefficient] ?? 60;
        $priority = $this->calculatePriorityForSubject($subject, $examDate, false, false, false, $user);
        $subjectName = $subject->name_ar ?? $subject->name;

        // Day 1: Lesson (understanding/درس)
        $sessions[] = [
            'day_in_week' => 1,
            'subject_id' => $subjectId,
            'subject' => $subject,
            'has_content' => false,
            'content' => null,
            'content_id' => null,
            'type' => self::SESSION_LESSON_REVIEW,
            'phase' => self::PHASE_UNDERSTANDING,
            'priority' => $priority + 0.3, // Lesson has higher priority
            'category' => $category,
            'coefficient' => $coefficient,
            'base_duration' => $baseDuration,
            'content_title' => $subjectName . ' - درس',
            'session_label' => 'درس',
        ];

        // Days 2-6: Exercises (حل تمارين)
        for ($day = 2; $day <= 6; $day++) {
            $sessions[] = [
                'day_in_week' => $day,
                'subject_id' => $subjectId,
                'subject' => $subject,
                'has_content' => false,
                'content' => null,
                'content_id' => null,
                'type' => self::SESSION_EXERCISES,
                'phase' => self::PHASE_EXERCISE_PRACTICE,
                'priority' => $priority,
                'category' => $category,
                'coefficient' => $coefficient,
                'base_duration' => $baseDuration,
                'content_title' => $subjectName . ' - تمارين ' . ($day - 1),
                'session_label' => 'تمارين ' . ($day - 1),
            ];
        }

        // Day 7: Unit Test (اختبار الوحدة)
        // 120 minutes for high coefficient subjects (>=6), 60 for others
        $testDuration = $coefficient >= 6 ? self::UNIT_TEST_DURATION_HIGH_COEF : self::UNIT_TEST_DURATION_NORMAL;

        $sessions[] = [
            'day_in_week' => 7,
            'subject_id' => $subjectId,
            'subject' => $subject,
            'has_content' => false,
            'content' => null,
            'content_id' => null,
            'type' => self::SESSION_UNIT_TEST,
            'phase' => self::PHASE_TEST,
            'priority' => $priority + 0.4, // Test has highest priority
            'category' => $category,
            'coefficient' => $coefficient,
            'base_duration' => $testDuration,
            'content_title' => $subjectName . ' - اختبار',
            'session_label' => 'اختبار',
            'is_unit_test' => true,
            'is_high_coefficient' => $coefficient >= 6,
        ];

        return $sessions;
    }

    /**
     * Build generic sessions for non-HARD_CORE subjects without content
     *
     * Creates simple study sessions to reserve time in the schedule
     * Number of sessions based on coefficient (higher coefficient = more sessions)
     *
     * @param int $subjectId
     * @param Subject $subject
     * @param int $coefficient
     * @param string $category
     * @param Carbon|null $examDate
     * @return array
     */
    protected function buildNoContentGenericSessions(
        int $subjectId,
        Subject $subject,
        int $coefficient,
        string $category,
        ?\Carbon\Carbon $examDate,
        ?User $user = null
    ): array {
        $sessions = [];
        $baseDuration = self::BASE_DURATION[$coefficient] ?? 60;
        $priority = $this->calculatePriorityForSubject($subject, $examDate, false, false, false, $user);
        $subjectName = $subject->name_ar ?? $subject->name;

        // Get sessions count from centralized function
        $sessionsCount = $this->getSessionsPerUnit($category, $coefficient);

        for ($i = 1; $i <= $sessionsCount; $i++) {
            $sessions[] = [
                'day_in_week' => $i,
                'subject_id' => $subjectId,
                'subject' => $subject,
                'has_content' => false,
                'content' => null,
                'content_id' => null,
                'type' => 'study', // Using 'study' as it's a valid enum value for generic sessions
                'phase' => self::PHASE_UNDERSTANDING,
                'priority' => $priority,
                'category' => $category,
                'coefficient' => $coefficient,
                'base_duration' => $baseDuration,
                'content_title' => 'جلسة دراسة - ' . $subjectName,
                'session_label' => 'جلسة ' . $i,
            ];
        }

        return $sessions;
    }

    /**
     * Build topic-based sessions for non-HARD_CORE subjects WITH content
     *
     * Creates individual sessions per topic (not 7-session weekly pattern)
     * Suitable for LANGUAGE, MEMORIZATION, and OTHER categories
     *
     * @param int $subjectId
     * @param Subject $subject
     * @param User $user
     * @param Carbon|null $examDate
     * @param string $category
     * @return array
     */
    protected function buildTopicBasedSessions(
        int $subjectId,
        Subject $subject,
        User $user,
        ?\Carbon\Carbon $examDate,
        string $category
    ): array {
        $result = [];
        // Get coefficient from subject_stream pivot table based on user's stream
        $coefficient = $this->getSubjectCoefficientForUser($subject, $user);
        $baseDuration = self::BASE_DURATION[$coefficient] ?? 60;

        // Get topics for this subject
        $topics = $this->getTopicsForSubject($subjectId, $user);

        foreach ($topics as $topic) {
            $priority = $this->calculateSessionPriority($topic, $subject, self::PHASE_UNDERSTANDING, $examDate, false, false, false, $user);
            $importance = $topic->is_bac_priority ? 5 : 3;
            $difficulty = $this->getDifficultyLevel($topic);

            // Create lesson session for the topic
            $lessonSession = [
                'day_in_week' => 1,
                'subject_id' => $subjectId,
                'subject' => $subject,
                'has_content' => true,
                'content' => $topic,
                'content_id' => $topic->id,
                'type' => self::SESSION_LESSON_REVIEW,
                'phase' => self::PHASE_UNDERSTANDING,
                'priority' => $priority,
                'category' => $category,
                'coefficient' => $coefficient,
                'base_duration' => $baseDuration,
                'content_title' => $topic->title_ar . ' - درس',
                'topic_path' => $topic->full_path ?? $topic->title_ar,
                'importance' => $importance,
                'difficulty' => $difficulty,
                'session_label' => 'درس',
            ];

            // For MEMORIZATION category, add a review session
            $sessions = [$lessonSession];

            if ($category === self::CATEGORY_MEMORIZATION) {
                $reviewSession = $lessonSession;
                $reviewSession['day_in_week'] = 2;
                $reviewSession['type'] = self::SESSION_SPACED_REVIEW;
                $reviewSession['phase'] = self::PHASE_REVIEW;
                $reviewSession['content_title'] = $topic->title_ar . ' - مراجعة';
                $reviewSession['session_label'] = 'مراجعة';
                $reviewSession['priority'] = $priority - 0.1; // Slightly lower priority
                $sessions[] = $reviewSession;
            }

            // For LANGUAGE category, add exercise session
            if ($category === self::CATEGORY_LANGUAGE) {
                $exerciseSession = $lessonSession;
                $exerciseSession['day_in_week'] = 2;
                $exerciseSession['type'] = self::SESSION_EXERCISES;
                $exerciseSession['phase'] = self::PHASE_EXERCISE_PRACTICE;
                $exerciseSession['content_title'] = $topic->title_ar . ' - تمارين';
                $exerciseSession['session_label'] = 'تمارين';
                $exerciseSession['base_duration'] = (int) ($baseDuration * 0.75); // Shorter exercises
                $sessions[] = $exerciseSession;
            }

            $result[] = [
                'unit_id' => 'topic_' . $topic->id,
                'unit_title' => $topic->title_ar,
                'subject_id' => $subjectId,
                'subject' => $subject,
                'has_content' => true,
                'priority' => $priority,
                'sessions' => $sessions,
            ];
        }

        return $result;
    }

    /**
     * Get topics for a subject within user's academic context
     *
     * @param int $subjectId
     * @param User $user
     * @return Collection
     */
    protected function getTopicsForSubject(int $subjectId, User $user): Collection
    {
        $academicContext = $this->getUserAcademicContext($user);

        if (!$academicContext['phase_id'] || !$academicContext['year_id']) {
            return collect();
        }

        // Find subject that has content (may be equivalent subject from another stream)
        $contentSubjectId = $this->findSubjectWithContent($subjectId, $academicContext);
        if (!$contentSubjectId) {
            return collect();
        }

        return SubjectPlannerContent::with(['parent'])
            ->forAcademicContext(
                $academicContext['phase_id'],
                $academicContext['year_id'],
                $academicContext['stream_id']
            )
            ->forSubject($contentSubjectId)
            ->published()
            ->where('level', 'topic')
            ->orderBy('order')
            ->get();
    }

    /**
     * Calculate the number of units for a subject based on category and coefficient
     *
     * TARGET HOURS (for 31-day schedule):
     * - علوم الطبيعة والحياة (HARD_CORE, coef 6): ~50h → 8 units × 7 sessions × 80min = 37h (will get more via round-robin)
     * - الرياضيات (HARD_CORE, coef 5): ~40h → 7 units × 7 sessions × 75min = 61h
     * - العلوم الفيزيائية (HARD_CORE, coef 5): ~40h → 7 units × 7 sessions × 75min = 61h
     * - اللغة العربية (LANGUAGE, coef 5): ~25h → 4 units × 5 sessions × 75min = 25h
     * - اللغة الفرنسية (LANGUAGE, coef 3): ~10h → 3 units × 4 sessions × 50min = 10h
     * - اللغة الإنجليزية (LANGUAGE, coef 2): ~10h → 3 units × 4 sessions × 40min = 8h
     * - التربية الإسلامية (MEMORIZATION, coef 2): ~15h → 5 units × 5 sessions × 40min = 17h
     * - التاريخ والجغرافيا (MEMORIZATION, coef 2): ~15h → 5 units × 5 sessions × 40min = 17h
     * - الفلسفة (MEMORIZATION, coef 2): ~8h → 3 units × 4 sessions × 40min = 8h
     *
     * @param string $category Subject category (HARD_CORE, LANGUAGE, MEMORIZATION, OTHER)
     * @param int $coefficient Subject coefficient (1-7)
     * @return int Number of units to create for this subject
     */
    protected function calculateUnitsForSubject(string $category, int $coefficient): int
    {
        // HARD_CORE subjects ALWAYS get MORE units (highest priority)
        if ($category === self::CATEGORY_HARD_CORE) {
            return match(true) {
                $coefficient >= 6 => 8,  // SVT (coef 6): 8 units × 7 sessions = 56 sessions → ~50h
                $coefficient >= 5 => 7,  // Maths/Physics (coef 5): 7 units × 7 sessions = 49 sessions → ~40h
                default => 6,            // Other HARD_CORE: 6 units × 7 sessions = 42 sessions
            };
        }

        // LANGUAGE subjects - moderate units
        if ($category === self::CATEGORY_LANGUAGE) {
            return match(true) {
                $coefficient >= 5 => 4,  // Arabic (coef 5): 4 units × 5 sessions = 20 sessions → ~25h
                $coefficient >= 3 => 3,  // French (coef 3): 3 units × 4 sessions = 12 sessions → ~10h
                default => 3,            // English (coef 2): 3 units × 4 sessions = 12 sessions → ~10h
            };
        }

        // MEMORIZATION subjects (Islamic, History, Philosophy)
        // Note: Philosophy gets fewer units (~8h) vs Islamic/History (~15h)
        if ($category === self::CATEGORY_MEMORIZATION) {
            return 5;  // 5 units × 5 sessions = 25 sessions → ~15h for all MEMORIZATION
        }

        // OTHER subjects - minimal units
        return match(true) {
            $coefficient >= 5 => 3,
            $coefficient >= 3 => 2,
            default => 1,
        };
    }

    /**
     * Get sessions per unit based on category and coefficient
     *
     * @param string $category Subject category
     * @param int $coefficient Subject coefficient
     * @return int Number of sessions per unit
     */
    protected function getSessionsPerUnit(string $category, int $coefficient): int
    {
        // HARD_CORE always has 7 sessions per unit (1 lesson + 5 exercises + 1 test)
        if ($category === self::CATEGORY_HARD_CORE) {
            return 7;
        }

        // LANGUAGE subjects
        if ($category === self::CATEGORY_LANGUAGE) {
            return match(true) {
                $coefficient >= 5 => 5,  // Arabic: 5 sessions/unit
                default => 4,            // French/English: 4 sessions/unit
            };
        }

        // MEMORIZATION subjects
        if ($category === self::CATEGORY_MEMORIZATION) {
            return 5;  // All memorization: 5 sessions/unit for better retention
        }

        // OTHER
        return match(true) {
            $coefficient >= 4 => 4,
            default => 3,
        };
    }
}
