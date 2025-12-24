import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/study_session.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/prioritized_subject.dart';
import '../../domain/entities/planner_settings.dart';
import '../../domain/entities/prayer_times.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/exam.dart';
import '../../domain/entities/subject_allocation.dart';
import 'priority_calculator.dart';
import 'subject_allocation_service.dart';

/// Day state tracking for promt.md algorithm constraints
///
/// Tracks constraints during daily schedule generation:
/// - coef7Count: sessions with coefficient 7 (max 1/day)
/// - hardCount: HARD_CORE sessions (max 2/day, no consecutive)
/// - hasLanguage: whether LANGUAGE subject has been scheduled (daily guarantee)
/// - lastCategory: previous session's category (for consecutive check)
/// - lastSubjects: last 2 subject IDs (for 3-consecutive check)
class DayState {
  int coef7Count;
  int hardCount;
  bool hasLanguage;
  SubjectCategory? lastCategory;
  List<String> lastSubjects;
  final int maxCoef7PerDay; // Dynamic (1 or 2) based on difficulty+exam proximity
  final int maxHardPerDay; // Dynamic (2 or 3) based on difficulty+exam proximity
  final bool noConsecutiveHard;
  final int minSameSubjectGapHours; // Dynamic (2 or 4) based on difficulty+exam proximity

  DayState({
    this.coef7Count = 0,
    this.hardCount = 0,
    this.hasLanguage = false,
    this.lastCategory,
    List<String>? lastSubjects,
    this.maxCoef7PerDay = 1, // Default: max 1 coefficient 7 subject/day
    this.maxHardPerDay = 2, // Default: max 2 HARD_CORE subjects/day
    this.noConsecutiveHard = true,
    this.minSameSubjectGapHours = 4, // Default: 4 hours between same subject
  }) : lastSubjects = lastSubjects ?? [];

  /// Check if a session can be placed given current day constraints
  ///
  /// Returns false if any constraint would be violated:
  /// - Coefficient 7: max maxCoef7PerDay sessions/day (dynamic: 1 or 2)
  /// - HARD_CORE: max maxHardPerDay sessions/day (dynamic: 2 or 3), no consecutive
  /// - Same subject: no 3 consecutive sessions
  /// - Single subject mode: require break between sessions
  bool canPlaceSession(Subject subject) {
    // coef==7: use dynamic limit
    if (subject.coefficient == 7 && coef7Count >= maxCoef7PerDay) {
      return false;
    }

    // HARD_CORE: max maxHardPerDay, no consecutive if enabled
    if (subject.category == SubjectCategory.hardCore) {
      if (hardCount >= maxHardPerDay) {
        return false;
      }
      if (noConsecutiveHard && lastCategory == SubjectCategory.hardCore) {
        return false;
      }
    }

    // No 3 consecutive same subject
    if (lastSubjects.length >= 2) {
      if (lastSubjects[0] == subject.id && lastSubjects[1] == subject.id) {
        return false;
      }
    }

    return true;
  }

  /// Update state after placing a session
  void updateAfterSession(Subject subject) {
    // Update coef7 count
    if (subject.coefficient == 7) {
      coef7Count++;
    }

    // Update hard count
    if (subject.category == SubjectCategory.hardCore) {
      hardCount++;
    }

    // Update language flag
    if (subject.category == SubjectCategory.language) {
      hasLanguage = true;
    }

    // Update last category
    lastCategory = subject.category;

    // Update last subjects (keep last 2)
    lastSubjects.add(subject.id);
    if (lastSubjects.length > 2) {
      lastSubjects.removeAt(0);
    }
  }

  /// Reset for a new day
  void reset() {
    coef7Count = 0;
    hardCount = 0;
    hasLanguage = false;
    lastCategory = null;
    lastSubjects.clear();
  }

  /// Create a copy of this state
  DayState copy() {
    return DayState(
      coef7Count: coef7Count,
      hardCount: hardCount,
      hasLanguage: hasLanguage,
      lastCategory: lastCategory,
      lastSubjects: List.from(lastSubjects),
      maxCoef7PerDay: maxCoef7PerDay,
      maxHardPerDay: maxHardPerDay,
      noConsecutiveHard: noConsecutiveHard,
      minSameSubjectGapHours: minSameSubjectGapHours,
    );
  }
}

/// Schedule Generator Service
///
/// Generates optimized study schedules based on:
/// - Subject priorities with exam boost multipliers
/// - User settings (study hours, breaks, Pomodoro, etc.)
/// - Prayer times (if enabled)
/// - Energy levels throughout the day
/// - Maximum study hours per day
/// - Daily variety through offset rotation
/// - Selected subjects filter
class ScheduleGenerator {
  final PriorityCalculator priorityCalculator;
  final SubjectAllocationService? allocationService;

  ScheduleGenerator(this.priorityCalculator, [this.allocationService]);

  /// Generate a schedule with daily variety
  ///
  /// Uses SubjectAllocationService for intelligent distribution:
  /// - Exam boost multipliers
  /// - Day offset rotation for variety
  /// - Spaced repetition gaps
  ///
  /// [scheduleType] - Type of schedule (daily, weekly, full)
  /// [exams] - Upcoming exams for priority boost
  /// [selectedSubjectIds] - Filter to only include these subjects
  /// [endDate] - Optional explicit end date (overrides scheduleType calculation)
  Schedule generateScheduleWithVariety({
    required List<PrioritizedSubject> prioritizedSubjects,
    required PlannerSettings settings,
    required ScheduleType scheduleType,
    List<Exam> exams = const [],
    List<String>? selectedSubjectIds,
    PrayerTimes? prayerTimes,
    DateTime? startDate,
    DateTime? endDate,
    bool startFromNow = true,
  }) {
    final sessions = <StudySession>[];
    final scheduleStartDate = startDate ?? DateTime.now();
    // Use explicit endDate if provided, otherwise calculate from scheduleType
    final scheduleEndDate = endDate ?? scheduleType.getEndDate(scheduleStartDate);
    final totalDays = scheduleEndDate.difference(scheduleStartDate).inDays + 1;

    if (kDebugMode) {
      print('[ScheduleGenerator] ========== GENERATION START ==========');
      print('[ScheduleGenerator] startDate: $scheduleStartDate');
      print('[ScheduleGenerator] endDate: $scheduleEndDate');
      print('[ScheduleGenerator] totalDays: $totalDays');
      print('[ScheduleGenerator] scheduleType: ${scheduleType.name}');
      print('[ScheduleGenerator] subjects count: ${prioritizedSubjects.length}');
      print('[ScheduleGenerator] selectedSubjectIds: $selectedSubjectIds');
    }

    // Filter subjects if selection provided
    var filteredSubjects = prioritizedSubjects;
    if (selectedSubjectIds != null && selectedSubjectIds.isNotEmpty) {
      if (kDebugMode) {
        print('[ScheduleGenerator] Filtering ${prioritizedSubjects.length} subjects');
        print('[ScheduleGenerator] Selected IDs: $selectedSubjectIds');
        print('[ScheduleGenerator] Available subjects: ${prioritizedSubjects.map((ps) => '${ps.subject.id}:${ps.subject.nameAr}').join(', ')}');
      }
      filteredSubjects = prioritizedSubjects
          .where((ps) => selectedSubjectIds.contains(ps.subject.id))
          .toList();
      if (kDebugMode) {
        print('[ScheduleGenerator] Filtered to ${filteredSubjects.length} subjects: ${filteredSubjects.map((ps) => ps.subject.nameAr).join(', ')}');
      }
    }

    if (filteredSubjects.isEmpty) {
      return Schedule(
        id: 'schedule_${scheduleStartDate.millisecondsSinceEpoch}',
        userId: settings.userId,
        startDate: scheduleStartDate,
        endDate: scheduleEndDate,
        sessions: sessions,
        createdAt: DateTime.now(),
        scheduleType: scheduleType,
      );
    }

    // Calculate total available study minutes
    final dailyStudyMinutes = _calculateDailyAvailableMinutes(settings);

    // Calculate approximate total sessions budget
    final avgSessionMinutes = settings.usePomodoroTechnique
        ? settings.pomodoroDurationMinutes
        : settings.sessionDurationMinutes;
    final sessionsPerDay = (dailyStudyMinutes / avgSessionMinutes).floor();
    final totalBudget = sessionsPerDay * totalDays;

    // Use allocation service if available
    List<SubjectAllocation>? allocations;
    if (allocationService != null) {
      allocations = allocationService!.calculateAllocations(
        prioritizedSubjects: filteredSubjects,
        exams: exams,
        totalBudget: totalBudget,
        scheduleType: scheduleType,
        startDate: scheduleStartDate,
      );
    }

    // Generate sessions for each day with offset rotation
    if (kDebugMode) {
      print('[ScheduleGenerator] Starting day loop for $totalDays days');
    }

    for (int day = 0; day < totalDays; day++) {
      final currentDate = scheduleStartDate.add(Duration(days: day));

      // Skip if it's outside study hours completely
      if (!_isStudyDay(currentDate, settings)) {
        if (kDebugMode) print('[ScheduleGenerator] Day $day: Not a study day');
        continue;
      }

      if (kDebugMode) {
        print('[ScheduleGenerator] Day $day: Generating for $currentDate');
      }

      // Generate sessions for this day with day offset
      final daySessions = _generateDayScheduleWithVariety(
        date: currentDate,
        prioritizedSubjects: filteredSubjects,
        allocations: allocations,
        settings: settings,
        prayerTimes: prayerTimes,
        availableMinutes: dailyStudyMinutes,
        startFromNow: startFromNow && day == 0,
        dayIndex: day,
      );

      sessions.addAll(daySessions);

      if (kDebugMode) {
        print('[ScheduleGenerator] Day $day: Generated ${daySessions.length} sessions, total now: ${sessions.length}');
      }

      // Update allocations for spaced repetition tracking
      if (allocations != null) {
        for (final session in daySessions) {
          if (!session.isBreak && !session.isPrayerTime) {
            final allocationIndex = allocations.indexWhere(
              (a) => a.subject.id == session.subjectId,
            );
            if (allocationIndex >= 0) {
              allocations[allocationIndex] = allocations[allocationIndex]
                  .withScheduledSession(currentDate);
            }
          }
        }
      }
    }

    if (kDebugMode) {
      print('[ScheduleGenerator] ========== GENERATION COMPLETE ==========');
      print('[ScheduleGenerator] Total sessions generated: ${sessions.length}');

      // Count session types
      int studySessions = 0;
      int breakSessions = 0;
      int prayerSessions = 0;
      for (final session in sessions) {
        if (session.isBreak) {
          breakSessions++;
        } else if (session.isPrayerTime) {
          prayerSessions++;
        } else {
          studySessions++;
        }
      }
      print('[ScheduleGenerator] Study sessions: $studySessions');
      print('[ScheduleGenerator] Break sessions: $breakSessions');
      print('[ScheduleGenerator] Prayer sessions: $prayerSessions');

      // Count sessions per day
      final sessionsPerDay = <String, int>{};
      for (final session in sessions) {
        final dayKey = '${session.scheduledDate.year}-${session.scheduledDate.month}-${session.scheduledDate.day}';
        sessionsPerDay[dayKey] = (sessionsPerDay[dayKey] ?? 0) + 1;
      }
      print('[ScheduleGenerator] Sessions per day: $sessionsPerDay');
    }

    return Schedule(
      id: 'schedule_${scheduleStartDate.millisecondsSinceEpoch}',
      userId: settings.userId,
      startDate: scheduleStartDate,
      endDate: scheduleEndDate,
      sessions: sessions,
      createdAt: DateTime.now(),
      scheduleType: scheduleType,
    );
  }

  /// Generate schedule for a single day with variety offset
  List<StudySession> _generateDayScheduleWithVariety({
    required DateTime date,
    required List<PrioritizedSubject> prioritizedSubjects,
    List<SubjectAllocation>? allocations,
    required PlannerSettings settings,
    PrayerTimes? prayerTimes,
    required int availableMinutes,
    bool startFromNow = true,
    int dayIndex = 0,
  }) {
    final sessions = <StudySession>[];

    if (prioritizedSubjects.isEmpty) {
      return sessions;
    }

    // Get study window
    final studyStart = settings.studyStartTime;
    final studyEnd = settings.studyEndTime;

    // Determine starting time
    final now = TimeOfDay.now();
    final today = DateTime.now();
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    TimeOfDay currentTime;
    if (startFromNow &&
        isToday &&
        _isTimeBefore(studyStart, now) &&
        _isTimeBefore(now, studyEnd)) {
      currentTime = now;
    } else {
      currentTime = studyStart;
    }

    if (kDebugMode) {
      print('[DaySchedule] Date: $date, isToday: $isToday, startFromNow: $startFromNow');
      print('[DaySchedule] studyStart: $studyStart, studyEnd: $studyEnd, currentTime: $currentTime');
      print('[DaySchedule] availableMinutes: $availableMinutes, maxStudyHours: ${settings.maxStudyHoursPerDay}');
      print('[DaySchedule] subjects count: ${prioritizedSubjects.length}');
    }

    int usedStudyMinutes = 0; // Only study time (not breaks)
    int totalElapsedMinutes = 0; // Total time including breaks
    int pomodoroCount = 0;

    // Detect difficult+urgent subjects for dynamic constraint relaxation
    // Condition: difficulty >= 7 AND exam within 7 days
    final hasDifficultUrgent = allocations?.any((a) =>
      a.subject.difficultyLevel >= 7 &&
      a.daysUntilExam != null &&
      a.daysUntilExam! <= 7
    ) ?? false;

    // Initialize DayState with dynamic constraints
    // If difficult+urgent subjects exist, relax constraints for intensive exam prep
    final dayState = DayState(
      maxCoef7PerDay: hasDifficultUrgent ? 2 : 1, // Relaxed: 2 coefficient 7 subjects/day
      maxHardPerDay: hasDifficultUrgent ? 3 : 2,  // Relaxed: 3 HARD_CORE subjects/day
      minSameSubjectGapHours: hasDifficultUrgent ? 2 : 4, // Reduced gap: 2 hours
      noConsecutiveHard: true, // Keep no-consecutive rule
    );

    // Calculate day offset for variety
    final dayOffset = _calculateDayOffset(date, prioritizedSubjects.length);

    // Create rotated subject list based on day offset
    final rotatedSubjects = _rotateSubjects(prioritizedSubjects, dayOffset);

    int subjectIndex = 0;

    if (kDebugMode) {
      print('[DaySchedule] Rotated subjects (${rotatedSubjects.length}): ${rotatedSubjects.map((ps) => '${ps.subject.id}:${ps.subject.nameAr}').join(', ')}');
      final canContinue = _isTimeBefore(currentTime, studyEnd);
      print('[DaySchedule] Loop entry check: timeBefore=$canContinue, studyMin=0 < maxStudyMin=${settings.maxStudyHoursPerDay * 60}');
    }

    while (_isTimeBefore(currentTime, studyEnd) &&
        usedStudyMinutes < settings.maxStudyHoursPerDay * 60) {
      // Check for prayer time
      if (settings.enablePrayerTimes && prayerTimes != null) {
        final prayer = _findPrayerAtTime(currentTime, prayerTimes, date);
        if (prayer != null) {
          sessions.add(
            _createPrayerSession(
              date: date,
              startTime: currentTime,
              duration: Duration(minutes: settings.prayerDurationMinutes),
              prayerName: prayer.name,
              userId: settings.userId,
            ),
          );
          currentTime = _addMinutesToTime(
            currentTime,
            settings.prayerDurationMinutes,
          );
          continue;
        }
      }

      // Check for exercise time
      if (settings.exerciseEnabled &&
          settings.exerciseTime != null &&
          _isSameTime(currentTime, settings.exerciseTime!) &&
          settings.exerciseDays.contains(date.weekday)) {
        sessions.add(
          _createExerciseSession(
            date: date,
            startTime: currentTime,
            duration: Duration(minutes: settings.exerciseDurationMinutes),
            userId: settings.userId,
          ),
        );
        currentTime = _addMinutesToTime(
          currentTime,
          settings.exerciseDurationMinutes,
        );
        continue;
      }

      // Select next subject based on allocation or rotation with DayState constraints
      PrioritizedSubject selectedSubject;
      if (allocations != null && allocationService != null) {
        // Get session count for this day so far
        final daySubjectSessions = sessions
            .where((s) => !s.isBreak && !s.isPrayerTime)
            .map((s) => s.subjectId)
            .fold<Map<String, int>>({}, (map, id) {
          map[id] = (map[id] ?? 0) + 1;
          return map;
        });

        // Get minutes used per subject for coefficient-based distribution
        final daySubjectMinutes = sessions
            .where((s) => !s.isBreak && !s.isPrayerTime)
            .fold<Map<String, int>>({}, (map, s) {
          map[s.subjectId] = (map[s.subjectId] ?? 0) + s.duration.inMinutes;
          return map;
        });

        // Find best subject considering allocations and DayState constraints
        selectedSubject = _selectSubjectWithAllocation(
          rotatedSubjects,
          allocations,
          daySubjectSessions,
          currentTime,
          settings,
          dayState: dayState,
          daySubjectMinutes: daySubjectMinutes,
        );
      } else {
        // Simple rotation with DayState constraint checking
        if (subjectIndex >= rotatedSubjects.length) {
          subjectIndex = 0;
        }

        // Default to current subject (will be overwritten if constraints pass)
        selectedSubject = rotatedSubjects[subjectIndex];

        // Find next subject that passes DayState constraints
        int attempts = 0;
        while (attempts < rotatedSubjects.length) {
          final candidate = rotatedSubjects[subjectIndex];
          if (dayState.canPlaceSession(candidate.subject)) {
            selectedSubject = candidate;
            subjectIndex++;
            break;
          }
          subjectIndex = (subjectIndex + 1) % rotatedSubjects.length;
          attempts++;
        }
        // If loop completed without finding valid subject, use current index
        if (attempts >= rotatedSubjects.length) {
          subjectIndex++;
        }
      }

      final subject = selectedSubject.subject;

      // Determine session duration with energy matching AND coefficient
      final energyLevel = _getEnergyLevelForTime(currentTime, settings);
      final sessionDuration = _calculateSessionDuration(
        settings: settings,
        energyLevel: energyLevel,
        coefficient: subject.coefficient,
      );

      // Create study session
      final session = _createStudySession(
        date: date,
        subject: subject,
        startTime: currentTime,
        duration: sessionDuration,
        settings: settings,
        priorityScore: selectedSubject.priorityScore,
      );

      if (kDebugMode) {
        print('[DaySchedule] Created STUDY session: ${subject.nameAr}, time=$currentTime, duration=${sessionDuration.inMinutes}min, totalStudy=${usedStudyMinutes + sessionDuration.inMinutes}min');
        print('[DaySchedule] DayState: coef7=${dayState.coef7Count}, hard=${dayState.hardCount}, hasLang=${dayState.hasLanguage}');
      }

      sessions.add(session);
      usedStudyMinutes += sessionDuration.inMinutes;
      totalElapsedMinutes += sessionDuration.inMinutes;
      pomodoroCount++;

      // Update DayState after placing session (promt.md constraint tracking)
      dayState.updateAfterSession(subject);

      currentTime = _addMinutesToTime(currentTime, sessionDuration.inMinutes);

      // Add break after session (ALWAYS add breaks between study sessions)
      // Use Pomodoro timing if enabled, otherwise use default short break
      final breakDuration = settings.usePomodoroTechnique
          ? _getPomodoroBrak(
              sessionCount: pomodoroCount,
              settings: settings,
            )
          : settings.shortBreakMinutes; // Default break between sessions

      if (breakDuration > 0) {
        // Only add break if we have time remaining and haven't reached study limit
        final wouldExceedTime = !_isTimeBefore(
          _addMinutesToTime(currentTime, breakDuration),
          studyEnd,
        );

        if (!wouldExceedTime && usedStudyMinutes < settings.maxStudyHoursPerDay * 60) {
          sessions.add(
            _createBreakSession(
              date: date,
              startTime: currentTime,
              duration: Duration(minutes: breakDuration),
              userId: settings.userId,
            ),
          );
          currentTime = _addMinutesToTime(currentTime, breakDuration);
          totalElapsedMinutes += breakDuration;
          // Note: breaks do NOT count toward usedStudyMinutes (study time limit)
          // Only actual study sessions count toward maxStudyHoursPerDay
        }
      }
    }

    // LANGUAGE daily guarantee (from promt.md Step 2.D)
    // If no language session was scheduled and we have time, add one
    if (!dayState.hasLanguage && usedStudyMinutes < settings.maxStudyHoursPerDay * 60 - 30) {
      final languageSubject = prioritizedSubjects
          .where((ps) => ps.subject.category == SubjectCategory.language)
          .firstOrNull;

      if (languageSubject != null && _isTimeBefore(currentTime, studyEnd)) {
        final energyLevel = _getEnergyLevelForTime(currentTime, settings);
        final sessionDuration = _calculateSessionDuration(
          settings: settings,
          energyLevel: energyLevel,
          coefficient: languageSubject.subject.coefficient,
        );

        final session = _createStudySession(
          date: date,
          subject: languageSubject.subject,
          startTime: currentTime,
          duration: sessionDuration,
          settings: settings,
          priorityScore: languageSubject.priorityScore,
        );

        if (kDebugMode) {
          print('[DaySchedule] Added LANGUAGE DAILY guarantee: ${languageSubject.subject.nameAr}');
        }

        sessions.add(session);
        dayState.updateAfterSession(languageSubject.subject);
      }
    }

    return sessions;
  }

  /// Calculate day offset for rotation variety
  /// Same date produces same offset (reproducible)
  /// Different dates produce different offsets (variety)
  int _calculateDayOffset(DateTime date, int totalSubjects) {
    if (totalSubjects == 0) return 0;
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return (dayOfYear + date.month * 31) % totalSubjects;
  }

  /// Rotate subjects list by offset
  List<PrioritizedSubject> _rotateSubjects(
    List<PrioritizedSubject> subjects,
    int offset,
  ) {
    if (subjects.isEmpty || offset == 0) return subjects;
    final actualOffset = offset % subjects.length;
    return [
      ...subjects.skip(actualOffset),
      ...subjects.take(actualOffset),
    ];
  }

  /// Select subject considering allocations, spaced repetition, and DayState constraints
  ///
  /// Uses allocations for priority ordering and exam boost, with DayState
  /// enforcing promt.md constraints (coef7, HARD_CORE, consecutive checks).
  ///
  /// IMPORTANT: Distribution is based on coefficient ratio:
  /// - Higher coefficient subjects get proportionally more time
  /// - Example: coef 6 gets 3x more time than coef 2
  PrioritizedSubject _selectSubjectWithAllocation(
    List<PrioritizedSubject> subjects,
    List<SubjectAllocation> allocations,
    Map<String, int> daySubjectSessions,
    TimeOfDay currentTime,
    PlannerSettings settings, {
    DayState? dayState,
    Map<String, int>? daySubjectMinutes, // Track minutes used per subject
  }) {
    // Get current energy level for smart matching
    final currentEnergyLevel = settings.getEnergyLevelForTime(currentTime);

    // Calculate total coefficient for ratio-based distribution
    final totalCoefficient = subjects.fold<int>(
      0, (sum, ps) => sum + ps.subject.coefficient,
    );

    // Calculate target minutes per subject based on coefficient ratio
    // maxStudyHoursPerDay determines the total study time
    final totalDailyMinutes = settings.maxStudyHoursPerDay * 60;

    Map<String, int> targetMinutesPerSubject = {};
    for (final ps in subjects) {
      final ratio = ps.subject.coefficient / totalCoefficient;
      targetMinutesPerSubject[ps.subject.id] = (ratio * totalDailyMinutes).round();
    }

    // Find subjects that haven't reached their target time AND pass DayState constraints
    final availableSubjects = subjects.where((ps) {
      // Check coefficient-based time limit
      final usedMinutes = daySubjectMinutes?[ps.subject.id] ?? 0;
      final targetMinutes = targetMinutesPerSubject[ps.subject.id] ?? totalDailyMinutes;
      if (usedMinutes >= targetMinutes) return false;

      // Check DayState constraints (promt.md algorithm)
      if (dayState != null && !dayState.canPlaceSession(ps.subject)) {
        return false;
      }

      return true;
    }).toList();

    if (availableSubjects.isEmpty) {
      // All subjects have reached limit or constraints
      // Find the one with most remaining quota that can pass constraints
      final subjectsByRemaining = subjects.map((ps) {
        final used = daySubjectMinutes?[ps.subject.id] ?? 0;
        final target = targetMinutesPerSubject[ps.subject.id] ?? totalDailyMinutes;
        return MapEntry(ps, target - used);
      }).toList();

      subjectsByRemaining.sort((a, b) => b.value.compareTo(a.value));

      // Return the one with most remaining quota
      return subjectsByRemaining.first.key;
    }

    // Sort by: remaining quota (descending), then energy match, then priority
    availableSubjects.sort((a, b) {
      // LANGUAGE daily guarantee bonus (from promt.md Step 2.D)
      if (dayState != null && !dayState.hasLanguage) {
        if (a.subject.category == SubjectCategory.language &&
            b.subject.category != SubjectCategory.language) {
          return -1;
        }
        if (b.subject.category == SubjectCategory.language &&
            a.subject.category != SubjectCategory.language) {
          return 1;
        }
      }

      // Priority 1: Remaining time quota (subjects with more remaining quota first)
      final usedA = daySubjectMinutes?[a.subject.id] ?? 0;
      final usedB = daySubjectMinutes?[b.subject.id] ?? 0;
      final targetA = targetMinutesPerSubject[a.subject.id] ?? totalDailyMinutes;
      final targetB = targetMinutesPerSubject[b.subject.id] ?? totalDailyMinutes;
      final remainingA = targetA - usedA;
      final remainingB = targetB - usedB;

      // Significant remaining difference (>20 min)
      if ((remainingB - remainingA).abs() > 20) {
        return remainingB.compareTo(remainingA);
      }

      // Get allocations for both subjects
      final allocA = allocations.firstWhere(
        (al) => al.subject.id == a.subject.id,
        orElse: () => SubjectAllocation(
          subject: a.subject,
          basePriority: a.priorityScore,
          adjustedPriority: a.priorityScore,
        ),
      );
      final allocB = allocations.firstWhere(
        (al) => al.subject.id == b.subject.id,
        orElse: () => SubjectAllocation(
          subject: b.subject,
          basePriority: b.priorityScore,
          adjustedPriority: b.priorityScore,
        ),
      );

      // Exam mode subjects first (higher priority)
      if (allocA.isExamMode && !allocB.isExamMode) return -1;
      if (!allocA.isExamMode && allocB.isExamMode) return 1;

      // Calculate energy-category match scores
      final matchScoreA = _calculateEnergyCategoryMatchScore(
        subject: a.subject,
        energyLevel: currentEnergyLevel,
      );
      final matchScoreB = _calculateEnergyCategoryMatchScore(
        subject: b.subject,
        energyLevel: currentEnergyLevel,
      );

      // Prefer better energy matches
      if ((matchScoreB - matchScoreA).abs() > 0.1) {
        return matchScoreB.compareTo(matchScoreA);
      }

      // Final tiebreaker: adjusted priority
      return allocB.adjustedPriority.compareTo(allocA.adjustedPriority);
    });

    return availableSubjects.first;
  }

  /// Calculate energy-category match score based on promt.md ENERGY_PREFERENCE
  ///
  /// HARD_CORE → prefers [HIGH, MEDIUM, LOW]
  /// MEMORIZATION → prefers [MEDIUM, LOW, HIGH]
  /// LANGUAGE → prefers [LOW, MEDIUM, HIGH]
  /// OTHER → prefers [MEDIUM, HIGH, LOW]
  double _calculateEnergyCategoryMatchScore({
    required Subject subject,
    required EnergyLevel energyLevel,
  }) {
    final preferredOrder = subject.category.preferredEnergyOrder;
    final energyString = energyLevel == EnergyLevel.high
        ? 'HIGH'
        : energyLevel == EnergyLevel.medium
            ? 'MEDIUM'
            : 'LOW';

    // Index in preferred order (0 = best match, 2 = worst)
    final index = preferredOrder.indexOf(energyString);
    if (index == -1) return 0.5; // Default if not found

    // Convert to score (1.0 = best, 0.0 = worst)
    return 1.0 - (index / 2.0);
  }

  /// Generate a weekly schedule (legacy method - kept for compatibility)
  ///
  /// Returns a Schedule with sessions for the specified date range
  Schedule generateWeeklySchedule({
    required List<PrioritizedSubject> prioritizedSubjects,
    required PlannerSettings settings,
    PrayerTimes? prayerTimes,
    DateTime? startDate,
    DateTime? endDate,
    bool startFromNow = true,
  }) {
    final sessions = <StudySession>[];
    final scheduleStartDate = startDate ?? DateTime.now();
    final scheduleEndDate =
        endDate ?? scheduleStartDate.add(const Duration(days: 7));
    final totalDays = scheduleEndDate.difference(scheduleStartDate).inDays;

    // Calculate total available study hours per day
    final dailyStudyMinutes = _calculateDailyAvailableMinutes(settings);

    // Generate sessions for each day
    for (int day = 0; day <= totalDays; day++) {
      final currentDate = scheduleStartDate.add(Duration(days: day));

      // Skip if it's outside study hours completely
      if (!_isStudyDay(currentDate, settings)) continue;

      // startFromNow should only apply to the first day (day == 0)
      final shouldStartFromNow = startFromNow && day == 0;

      // Generate sessions for this day
      final daySessions = _generateDaySchedule(
        date: currentDate,
        prioritizedSubjects: prioritizedSubjects,
        settings: settings,
        prayerTimes: prayerTimes,
        availableMinutes: dailyStudyMinutes,
        startFromNow: shouldStartFromNow,
      );

      sessions.addAll(daySessions);
    }

    return Schedule(
      id: 'schedule_${scheduleStartDate.millisecondsSinceEpoch}',
      userId: settings.userId,
      startDate: scheduleStartDate,
      endDate: scheduleEndDate,
      sessions: sessions,
      createdAt: DateTime.now(),
    );
  }

  /// Generate schedule for a single day
  List<StudySession> _generateDaySchedule({
    required DateTime date,
    required List<PrioritizedSubject> prioritizedSubjects,
    required PlannerSettings settings,
    PrayerTimes? prayerTimes,
    required int availableMinutes,
    bool startFromNow = true,
  }) {
    final sessions = <StudySession>[];

    // If no subjects available, return empty schedule
    if (prioritizedSubjects.isEmpty) {
      return sessions;
    }

    // Get study window for the day
    final studyStart = settings.studyStartTime;
    final studyEnd = settings.studyEndTime;

    // Determine starting time based on startFromNow flag
    final now = TimeOfDay.now();
    final today = DateTime.now();
    final isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    // Track current time dynamically
    TimeOfDay currentTime;
    if (startFromNow &&
        isToday &&
        _isTimeBefore(studyStart, now) &&
        _isTimeBefore(now, studyEnd)) {
      // Start from current time if:
      // 1. startFromNow is enabled
      // 2. It's today
      // 3. Current time is within study hours
      currentTime = now;
    } else {
      // Otherwise start from study start time
      currentTime = studyStart;
    }
    int usedStudyMinutes = 0; // Only study time (not breaks)
    int totalElapsedMinutes = 0; // Total time including breaks
    int subjectIndex = 0;
    int pomodoroCount = 0;

    while (_isTimeBefore(currentTime, studyEnd) &&
        usedStudyMinutes < settings.maxStudyHoursPerDay * 60) {
      // Check for prayer time
      if (settings.enablePrayerTimes && prayerTimes != null) {
        final prayer = _findPrayerAtTime(currentTime, prayerTimes, date);
        if (prayer != null) {
          sessions.add(
            _createPrayerSession(
              date: date,
              startTime: currentTime,
              duration: Duration(minutes: settings.prayerDurationMinutes),
              prayerName: prayer.name,
              userId: settings.userId,
            ),
          );
          currentTime = _addMinutesToTime(
            currentTime,
            settings.prayerDurationMinutes,
          );
          continue;
        }
      }

      // Check for exercise time
      if (settings.exerciseEnabled &&
          settings.exerciseTime != null &&
          _isSameTime(currentTime, settings.exerciseTime!) &&
          settings.exerciseDays.contains(date.weekday)) {
        sessions.add(
          _createExerciseSession(
            date: date,
            startTime: currentTime,
            duration: Duration(minutes: settings.exerciseDurationMinutes),
            userId: settings.userId,
          ),
        );
        currentTime = _addMinutesToTime(
          currentTime,
          settings.exerciseDurationMinutes,
        );
        continue;
      }

      // Cycle through subjects based on priority
      if (subjectIndex >= prioritizedSubjects.length) {
        subjectIndex = 0; // Restart from highest priority
      }

      final prioritizedSubject = prioritizedSubjects[subjectIndex];
      final subject = prioritizedSubject.subject;

      // Determine session duration
      final sessionDuration = _calculateSessionDuration(
        settings: settings,
        energyLevel: _getEnergyLevelForTime(currentTime, settings),
      );

      // Create study session
      final session = _createStudySession(
        date: date,
        subject: subject,
        startTime: currentTime,
        duration: sessionDuration,
        settings: settings,
      );

      sessions.add(session);
      usedStudyMinutes += sessionDuration.inMinutes;
      totalElapsedMinutes += sessionDuration.inMinutes;
      pomodoroCount++;
      subjectIndex++;

      // Move current time forward by session duration
      currentTime = _addMinutesToTime(currentTime, sessionDuration.inMinutes);

      // Add break after session (ALWAYS add breaks between study sessions)
      // Use Pomodoro timing if enabled, otherwise use default short break
      final breakDuration = settings.usePomodoroTechnique
          ? _getPomodoroBrak(
              sessionCount: pomodoroCount,
              settings: settings,
            )
          : settings.shortBreakMinutes; // Default break between sessions

      if (breakDuration > 0) {
        // Only add break if we have time remaining and haven't reached study limit
        final wouldExceedTime = !_isTimeBefore(
          _addMinutesToTime(currentTime, breakDuration),
          studyEnd,
        );

        if (!wouldExceedTime && usedStudyMinutes < settings.maxStudyHoursPerDay * 60) {
          sessions.add(
            _createBreakSession(
              date: date,
              startTime: currentTime,
              duration: Duration(minutes: breakDuration),
              userId: settings.userId,
            ),
          );

          // Move current time forward by break duration
          currentTime = _addMinutesToTime(currentTime, breakDuration);
          totalElapsedMinutes += breakDuration;
          // Note: breaks do NOT count toward usedStudyMinutes (study time limit)
        }
      }
    }

    return sessions;
  }

  /// Create time slots for a day
  List<Map<String, dynamic>> _createTimeSlots({
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required PlannerSettings settings,
    PrayerTimes? prayerTimes,
  }) {
    final slots = <Map<String, dynamic>>[];

    TimeOfDay currentTime = startTime;

    while (_isTimeBefore(currentTime, endTime)) {
      // Check for prayer time
      if (settings.enablePrayerTimes && prayerTimes != null) {
        final prayer = _getPrayerAtTime(currentTime, prayerTimes);
        if (prayer != null) {
          slots.add({
            'type': 'prayer',
            'startTime': currentTime,
            'duration': settings.prayerDurationMinutes,
            'name': prayer.name,
          });
          currentTime = _addMinutesToTime(
            currentTime,
            settings.prayerDurationMinutes,
          );
          continue;
        }
      }

      // Check for exercise time
      if (settings.exerciseEnabled &&
          settings.exerciseTime != null &&
          _isSameTime(currentTime, settings.exerciseTime!) &&
          settings.exerciseDays.contains(date.weekday)) {
        slots.add({
          'type': 'exercise',
          'startTime': currentTime,
          'duration': settings.exerciseDurationMinutes,
        });
        currentTime = _addMinutesToTime(
          currentTime,
          settings.exerciseDurationMinutes,
        );
        continue;
      }

      // Regular study slot
      slots.add({'type': 'study', 'startTime': currentTime});

      // Move to next slot (default 30 min intervals)
      currentTime = _addMinutesToTime(currentTime, 30);
    }

    return slots;
  }

  /// Calculate energy-difficulty match score for smart subject selection
  ///
  /// Returns a score from 0.0 to 1.0 where:
  /// - 1.0 = Perfect match (high difficulty + high energy OR low difficulty + low energy)
  /// - 0.0 = Poor match (high difficulty + low energy OR low difficulty + high energy)
  ///
  /// This helps schedule:
  /// - Difficult subjects during high-energy periods (morning/evening)
  /// - Easy subjects during low-energy periods (afternoon/night)
  double _calculateEnergyMatchScore({
    required Subject subject,
    required EnergyLevel energyLevel,
  }) {
    // Normalize difficulty (1-10 scale) to 0.0-1.0
    final difficultyNormalized = subject.difficultyLevel / 10.0;

    // Normalize energy level to 0.0-1.0
    final energyNormalized = energyLevel == EnergyLevel.high ? 1.0 :
                             energyLevel == EnergyLevel.medium ? 0.5 :
                             energyLevel == EnergyLevel.low ? 0.25 : 0.0;

    // Calculate match score (inverse of absolute difference)
    // When difficulty and energy are close, score is high
    final difference = (difficultyNormalized - energyNormalized).abs();
    final matchScore = 1.0 - difference;

    // Boost score for perfect alignments
    if (difficultyNormalized >= 0.7 && energyNormalized >= 0.8) {
      return matchScore * 1.2; // High difficulty + high energy: bonus
    } else if (difficultyNormalized <= 0.3 && energyNormalized <= 0.3) {
      return matchScore * 1.1; // Low difficulty + low energy: small bonus
    }

    return matchScore.clamp(0.0, 1.0);
  }

  /// Calculate session duration based on settings, energy level, and coefficient
  Duration _calculateSessionDuration({
    required PlannerSettings settings,
    required EnergyLevel energyLevel,
    int? coefficient,
  }) {
    // Get base duration from coefficient settings (if available)
    int baseMinutes;
    if (coefficient != null && settings.coefficientDurations.containsKey(coefficient)) {
      // Prioritize coefficient-based duration
      baseMinutes = settings.coefficientDurations[coefficient]!;
    } else if (settings.usePomodoroTechnique) {
      // Use Pomodoro duration only if no coefficient mapping exists
      baseMinutes = settings.pomodoroDurationMinutes;
    } else {
      // Fallback to default session duration
      baseMinutes = settings.sessionDurationMinutes;
    }

    // Adjust duration based on energy level (±15% max)
    // Smaller adjustment because coefficient already determines base duration
    switch (energyLevel) {
      case EnergyLevel.high:
        baseMinutes = (baseMinutes * 1.15).clamp(20, 120).toInt();
        break;
      case EnergyLevel.medium:
        // Keep base duration from coefficient
        break;
      case EnergyLevel.low:
        baseMinutes = (baseMinutes * 0.90).clamp(20, 120).toInt();
        break;
      case EnergyLevel.veryLow:
        baseMinutes = (baseMinutes * 0.75).clamp(20, 120).toInt();
        break;
    }

    return Duration(minutes: baseMinutes);
  }

  /// Get Pomodoro break duration
  int _getPomodoroBrak({
    required int sessionCount,
    required PlannerSettings settings,
  }) {
    if (sessionCount % settings.pomodorosBeforeLongBreak == 0) {
      return settings.longBreakMinutes;
    }
    return settings.shortBreakMinutes;
  }

  /// Create a study session
  StudySession _createStudySession({
    required DateTime date,
    required Subject subject,
    required TimeOfDay startTime,
    required Duration duration,
    required PlannerSettings settings,
    double? priorityScore,
  }) {
    final totalMinutes = startTime.hour * 60 + startTime.minute + duration.inMinutes;
    final endTime = TimeOfDay(
      hour: (totalMinutes ~/ 60) % 24,
      minute: totalMinutes % 60,
    );

    // Content placeholder message when no content available
    const noContentMessage = 'سيتم اضافة المحتوى قريبا';

    return StudySession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}_${subject.id}',
      userId: settings.userId,
      subjectId: subject.id,
      subjectName: subject.name,
      subjectColor: subject.color,
      scheduledDate: date,
      scheduledStartTime: startTime,
      scheduledEndTime: endTime,
      duration: duration,
      suggestedContentType: ContentType.mixed,
      chapterName: noContentMessage,
      topicName: noContentMessage,
      contentTitle: noContentMessage,
      hasContent: false, // Local generation doesn't have curriculum content
      sessionType: SessionType.study,
      requiredEnergyLevel: _getEnergyLevelForTime(startTime, settings),
      estimatedEnergyLevel: _getEnergyLevelForTime(startTime, settings),
      priorityScore: priorityScore?.toInt() ?? (subject.coefficient * 10).toInt(),
      usePomodoroTechnique: settings.usePomodoroTechnique,
      pomodoroDurationMinutes: settings.pomodoroDurationMinutes,
      isBreak: false, // Explicitly mark as NOT a break
      isPrayerTime: false, // Explicitly mark as NOT prayer time
      status: SessionStatus.scheduled,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create a prayer session
  StudySession _createPrayerSession({
    required DateTime date,
    required TimeOfDay startTime,
    required Duration duration,
    required String prayerName,
    required String userId,
  }) {
    final endTime = TimeOfDay(
      hour: (startTime.hour + duration.inHours) % 24,
      minute: (startTime.minute + duration.inMinutes % 60) % 60,
    );

    return StudySession(
      id: 'prayer_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      subjectId: 'prayer',
      subjectName: prayerName,
      chapterName: 'صلاة',
      topicName: prayerName,
      subjectColor: Colors.green,
      scheduledDate: date,
      scheduledStartTime: startTime,
      scheduledEndTime: endTime,
      duration: duration,
      sessionType: SessionType.study,
      requiredEnergyLevel: EnergyLevel.medium,
      priorityScore: 100, // Highest priority
      isBreak: false,
      isPrayerTime: true,
      usePomodoroTechnique: false,
      status: SessionStatus.scheduled,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create an exercise session
  StudySession _createExerciseSession({
    required DateTime date,
    required TimeOfDay startTime,
    required Duration duration,
    required String userId,
  }) {
    final endTime = TimeOfDay(
      hour: (startTime.hour + duration.inHours) % 24,
      minute: (startTime.minute + duration.inMinutes % 60) % 60,
    );

    return StudySession(
      id: 'exercise_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      subjectId: 'exercise',
      subjectName: 'تمارين رياضية',
      chapterName: 'تمارين',
      topicName: 'نشاط بدني',
      subjectColor: Colors.orange,
      scheduledDate: date,
      scheduledStartTime: startTime,
      scheduledEndTime: endTime,
      duration: duration,
      sessionType: SessionType.study,
      requiredEnergyLevel: EnergyLevel.high,
      priorityScore: 80,
      isBreak: true,
      isPrayerTime: false,
      usePomodoroTechnique: false,
      status: SessionStatus.scheduled,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create a break session
  StudySession _createBreakSession({
    required DateTime date,
    required TimeOfDay startTime,
    required Duration duration,
    required String userId,
  }) {
    final endTime = TimeOfDay(
      hour: (startTime.hour + duration.inHours) % 24,
      minute: (startTime.minute + duration.inMinutes % 60) % 60,
    );

    return StudySession(
      id: 'break_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      subjectId: 'break',
      subjectName: 'استراحة',
      chapterName: 'استراحة',
      topicName: 'وقت راحة',
      subjectColor: Colors.blue,
      scheduledDate: date,
      scheduledStartTime: startTime,
      scheduledEndTime: endTime,
      duration: duration,
      sessionType: SessionType.study,
      requiredEnergyLevel: EnergyLevel.medium,
      priorityScore: 50,
      isBreak: true,
      isPrayerTime: false,
      usePomodoroTechnique: false,
      status: SessionStatus.scheduled,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Calculate daily available study minutes
  int _calculateDailyAvailableMinutes(PlannerSettings settings) {
    return settings.dailyStudyWindow.inMinutes;
  }

  /// Check if date is a valid study day
  bool _isStudyDay(DateTime date, PlannerSettings settings) {
    // For now, all days are study days
    // Can be extended to exclude specific days
    return true;
  }

  /// Get energy level for a specific time
  EnergyLevel _getEnergyLevelForTime(TimeOfDay time, PlannerSettings settings) {
    return settings.getEnergyLevelForTime(time);
  }

  /// Get prayer at specific time
  Prayer? _getPrayerAtTime(TimeOfDay time, PrayerTimes prayerTimes) {
    for (final prayer in prayerTimes.allPrayers) {
      if (_isSameTime(time, prayer.time)) {
        return prayer;
      }
    }
    return null;
  }

  /// Check if time1 is before time2
  bool _isTimeBefore(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour < time2.hour) return true;
    if (time1.hour == time2.hour && time1.minute < time2.minute) return true;
    return false;
  }

  /// Check if two times are the same (within 15 min)
  bool _isSameTime(TimeOfDay time1, TimeOfDay time2) {
    return (time1.hour == time2.hour &&
        (time1.minute - time2.minute).abs() < 15);
  }

  /// Find prayer at current time
  Prayer? _findPrayerAtTime(
    TimeOfDay currentTime,
    PrayerTimes prayerTimes,
    DateTime date,
  ) {
    for (final prayer in prayerTimes.allPrayers) {
      if (_isSameTime(currentTime, prayer.time)) {
        return prayer;
      }
    }
    return null;
  }

  /// Add minutes to a TimeOfDay
  TimeOfDay _addMinutesToTime(TimeOfDay time, int minutes) {
    int totalMinutes = time.hour * 60 + time.minute + minutes;
    return TimeOfDay(
      hour: (totalMinutes ~/ 60) % 24,
      minute: totalMinutes % 60,
    );
  }
}
