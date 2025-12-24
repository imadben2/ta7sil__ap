import '../../domain/entities/exam.dart';
import '../../domain/entities/subject_allocation.dart';
import '../../domain/entities/prioritized_subject.dart';
import '../../domain/entities/planner_settings.dart';
import '../../domain/entities/schedule.dart';

/// Service responsible for allocating study sessions to subjects
///
/// Key responsibilities:
/// - Calculate session quotas per subject based on priority
/// - Apply exam boost multipliers
/// - Enforce spaced repetition gaps
/// - Provide daily variety through offset rotation
class SubjectAllocationService {
  /// Minimum hours between sessions of the same subject (spaced repetition)
  static const int minGapBetweenSameSubjectHours = 4;

  /// Calculate allocations for all subjects
  ///
  /// [prioritizedSubjects] - Subjects with calculated priorities
  /// [exams] - Upcoming exams for boost calculation
  /// [totalBudget] - Total number of sessions to allocate
  /// [scheduleType] - Type of schedule being generated
  /// [startDate] - Schedule start date
  List<SubjectAllocation> calculateAllocations({
    required List<PrioritizedSubject> prioritizedSubjects,
    required List<Exam> exams,
    required int totalBudget,
    required ScheduleType scheduleType,
    required DateTime startDate,
  }) {
    if (prioritizedSubjects.isEmpty || totalBudget <= 0) {
      return [];
    }

    final allocations = <SubjectAllocation>[];

    // Calculate exam boosts and create initial allocations
    for (final ps in prioritizedSubjects) {
      final exam = _findNearestExam(ps.subject.id, exams, startDate);
      int? daysUntilExam;
      double examMultiplier = 1.0;
      bool isExamMode = false;

      if (exam != null) {
        daysUntilExam = exam.examDate.difference(startDate).inDays;
        examMultiplier = ExamBoostMultipliers.getMultiplier(daysUntilExam);
        isExamMode = daysUntilExam <= scheduleType.examModeThresholdDays;
      }

      // Calculate difficulty multiplier
      final difficultyFactor = _calculateDifficultyFactor(ps.subject.difficultyLevel);

      // Combined multiplier (exam × difficulty)
      final combinedMultiplier = examMultiplier * difficultyFactor;

      // Apply combined multiplier to priority
      final adjustedPriority = ps.priorityScore * combinedMultiplier;

      allocations.add(SubjectAllocation(
        subject: ps.subject,
        basePriority: ps.priorityScore,
        adjustedPriority: adjustedPriority,
        examBoostMultiplier: examMultiplier,
        difficultyMultiplier: difficultyFactor,
        combinedMultiplier: combinedMultiplier,
        upcomingExam: exam,
        daysUntilExam: daysUntilExam,
        isExamMode: isExamMode,
      ));
    }

    // Calculate total adjusted priority
    final totalPriority = allocations.fold<double>(
      0,
      (sum, a) => sum + a.adjustedPriority,
    );

    // Allocate sessions based on priority share
    int allocatedTotal = 0;
    final updatedAllocations = <SubjectAllocation>[];

    // First pass: Calculate initial allocations
    for (int i = 0; i < allocations.length; i++) {
      final allocation = allocations[i];
      final share = allocation.getSessionShare(totalPriority);

      int sessions;
      if (i == allocations.length - 1) {
        // Last subject gets remaining budget to ensure total matches
        sessions = totalBudget - allocatedTotal;
      } else {
        sessions = (totalBudget * share).round();
        // Ensure at least 1 session per subject
        sessions = sessions.clamp(1, totalBudget - allocatedTotal);
      }

      allocatedTotal += sessions;
      updatedAllocations.add(allocation.withAllocation(sessions));
    }

    // Second pass: Ensure minimum guarantee for weekly/full schedules
    // For weekly schedules (7 days), ensure each subject gets at least 1 session
    // For full schedules (30 days), ensure each subject gets at least 2 sessions
    if (scheduleType == ScheduleType.weekly || scheduleType == ScheduleType.full) {
      final minimumSessions = scheduleType == ScheduleType.weekly ? 1 : 2;
      final finalAllocations = <SubjectAllocation>[];
      int redistributeTotal = 0;

      // Identify subjects below minimum and calculate redistribution
      for (final allocation in updatedAllocations) {
        if (allocation.allocatedSessions < minimumSessions) {
          redistributeTotal += (minimumSessions - allocation.allocatedSessions);
          finalAllocations.add(allocation.withAllocation(minimumSessions));
        } else {
          finalAllocations.add(allocation);
        }
      }

      // Redistribute by reducing from high-allocation subjects
      if (redistributeTotal > 0) {
        // Sort by allocated sessions (descending) to take from richest
        finalAllocations.sort((a, b) =>
          b.allocatedSessions.compareTo(a.allocatedSessions));

        int remaining = redistributeTotal;
        for (int i = 0; i < finalAllocations.length && remaining > 0; i++) {
          final allocation = finalAllocations[i];
          if (allocation.allocatedSessions > minimumSessions) {
            final canTake = allocation.allocatedSessions - minimumSessions;
            final toTake = canTake.clamp(0, remaining);
            finalAllocations[i] = allocation.withAllocation(
              allocation.allocatedSessions - toTake
            );
            remaining -= toTake;
          }
        }
      }

      return finalAllocations;
    }

    return updatedAllocations;
  }

  /// Get the next subject to schedule for a given day
  ///
  /// Uses day offset rotation to ensure variety across days
  /// [allocations] - Current allocation state
  /// [targetDate] - Day to schedule for
  /// [currentDaySessions] - Sessions already scheduled for this day
  /// [settings] - Planner settings for energy matching
  SubjectAllocation? getNextSubjectForDay({
    required List<SubjectAllocation> allocations,
    required DateTime targetDate,
    required List<SubjectAllocation> currentDaySessions,
    required PlannerSettings settings,
  }) {
    // Filter subjects with remaining sessions
    final available = allocations
        .where((a) => a.remainingSessions > 0)
        .toList();

    if (available.isEmpty) return null;

    // Apply day offset for variety
    final dayOffset = _calculateDayOffset(targetDate, available.length);

    // Sort by adjusted priority (descending) with offset rotation
    available.sort((a, b) {
      final aIndex = allocations.indexOf(a);
      final bIndex = allocations.indexOf(b);
      final aRotated = (aIndex - dayOffset) % available.length;
      final bRotated = (bIndex - dayOffset) % available.length;

      // First by exam mode (exam subjects first)
      if (a.isExamMode && !b.isExamMode) return -1;
      if (!a.isExamMode && b.isExamMode) return 1;

      // Then by rotated position
      return aRotated.compareTo(bRotated);
    });

    // Find first subject that has enough gap
    for (final allocation in available) {
      // Check if this subject was already scheduled today
      final scheduledToday = currentDaySessions
          .where((s) => s.subject.id == allocation.subject.id)
          .length;

      // Limit sessions per day based on priority
      final maxDailySessions = _getMaxDailySessionsForPriority(
        allocation.adjustedPriority,
        allocation.isExamMode,
      );
      if (scheduledToday >= maxDailySessions) continue;

      // Check spaced repetition gap
      if (allocation.hasEnoughGap(
        targetDate,
        minGapBetweenSameSubjectHours,
      )) {
        return allocation;
      }
    }

    // If no subject with enough gap, return first available
    return available.first;
  }

  /// Calculate day offset for rotation variety
  ///
  /// Same date always produces same offset (reproducible)
  /// Different dates produce different offsets (variety)
  int _calculateDayOffset(DateTime date, int totalSubjects) {
    if (totalSubjects == 0) return 0;
    // Use day of year + some variation from month
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return (dayOfYear + date.month * 31) % totalSubjects;
  }

  /// Find the nearest upcoming exam for a subject
  Exam? _findNearestExam(
    String subjectId,
    List<Exam> exams,
    DateTime fromDate,
  ) {
    final subjectExams = exams
        .where((e) => e.subjectId == subjectId && e.examDate.isAfter(fromDate))
        .toList();

    if (subjectExams.isEmpty) return null;

    subjectExams.sort((a, b) => a.examDate.compareTo(b.examDate));
    return subjectExams.first;
  }

  /// Get subjects sorted by exam urgency
  List<SubjectAllocation> getExamUrgentSubjects(
    List<SubjectAllocation> allocations,
  ) {
    return allocations
        .where((a) => a.isExamMode)
        .toList()
      ..sort((a, b) {
        final aDays = a.daysUntilExam ?? 999;
        final bDays = b.daysUntilExam ?? 999;
        return aDays.compareTo(bDays);
      });
  }

  /// Calculate total priority for a list of allocations
  double getTotalPriority(List<SubjectAllocation> allocations) {
    return allocations.fold<double>(
      0,
      (sum, a) => sum + a.adjustedPriority,
    );
  }

  /// Get allocation statistics
  Map<String, dynamic> getAllocationStats(List<SubjectAllocation> allocations) {
    final total = allocations.fold<int>(0, (s, a) => s + a.allocatedSessions);
    final scheduled = allocations.fold<int>(0, (s, a) => s + a.scheduledSessions);
    final examMode = allocations.where((a) => a.isExamMode).length;

    return {
      'totalAllocated': total,
      'totalScheduled': scheduled,
      'remainingToSchedule': total - scheduled,
      'subjectsInExamMode': examMode,
      'averageSessionsPerSubject': allocations.isNotEmpty
          ? (total / allocations.length).toStringAsFixed(1)
          : '0',
    };
  }

  /// Calculate difficulty multiplier based on subject difficulty level
  ///
  /// Linear scale: difficulty 5 = 1.0x (baseline)
  /// Each level above/below 5 adds/subtracts 0.1x
  /// Range: 0.6x (very easy) to 1.5x (very hard)
  ///
  /// Examples:
  /// - difficulty 1 → 0.6x (easy subjects get fewer sessions)
  /// - difficulty 5 → 1.0x (baseline)
  /// - difficulty 9 → 1.4x (hard subjects get 40% more sessions)
  /// - difficulty 10 → 1.5x (very hard subjects get 50% more sessions)
  double _calculateDifficultyFactor(int difficultyLevel) {
    return (1.0 + (difficultyLevel - 5) * 0.1).clamp(0.6, 1.5);
  }

  /// Get maximum daily sessions based on subject priority
  ///
  /// High priority subjects get more sessions per day,
  /// low priority subjects get fewer to avoid over-representation.
  int _getMaxDailySessionsForPriority(double priority, bool isExamMode) {
    // Exam mode subjects can have up to 4 sessions per day
    if (isExamMode) return 4;

    // Priority-based limits (priority is typically 0-100 scale)
    if (priority >= 80) return 3;  // High priority: up to 3/day
    if (priority >= 60) return 2;  // Medium-high: 2/day
    if (priority >= 40) return 1;  // Medium: 1/day
    return 1;                       // Low priority: max 1/day
  }
}
