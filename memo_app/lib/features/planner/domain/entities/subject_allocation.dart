import 'package:equatable/equatable.dart';
import 'subject.dart';
import 'exam.dart';

/// Represents the allocation of study sessions for a subject
///
/// Used by SubjectAllocationService to track how many sessions
/// should be allocated to each subject and when the last session was.
class SubjectAllocation extends Equatable {
  /// The subject being allocated
  final Subject subject;

  /// Base priority score (from PriorityCalculator)
  final double basePriority;

  /// Adjusted priority with exam boost
  final double adjustedPriority;

  /// Exam boost multiplier (1.0 = no boost, 2.5 = maximum)
  final double examBoostMultiplier;

  /// Difficulty multiplier based on subject difficulty level (0.6 to 1.5)
  final double difficultyMultiplier;

  /// Combined multiplier (exam × difficulty)
  final double combinedMultiplier;

  /// Number of sessions allocated for this subject
  final int allocatedSessions;

  /// Number of sessions already scheduled
  final int scheduledSessions;

  /// Remaining sessions to schedule
  int get remainingSessions => allocatedSessions - scheduledSessions;

  /// Date of last scheduled session (for spaced repetition)
  final DateTime? lastSessionDate;

  /// Upcoming exam for this subject (if any)
  final Exam? upcomingExam;

  /// Days until next exam (null if no exam)
  final int? daysUntilExam;

  /// Whether this subject is in "exam mode" (intensive preparation)
  final bool isExamMode;

  const SubjectAllocation({
    required this.subject,
    required this.basePriority,
    required this.adjustedPriority,
    this.examBoostMultiplier = 1.0,
    this.difficultyMultiplier = 1.0,
    this.combinedMultiplier = 1.0,
    this.allocatedSessions = 0,
    this.scheduledSessions = 0,
    this.lastSessionDate,
    this.upcomingExam,
    this.daysUntilExam,
    this.isExamMode = false,
  });

  @override
  List<Object?> get props => [
        subject.id,
        basePriority,
        adjustedPriority,
        allocatedSessions,
        scheduledSessions,
      ];

  /// Create a copy with updated scheduled count
  SubjectAllocation withScheduledSession(DateTime sessionDate) {
    return SubjectAllocation(
      subject: subject,
      basePriority: basePriority,
      adjustedPriority: adjustedPriority,
      examBoostMultiplier: examBoostMultiplier,
      difficultyMultiplier: difficultyMultiplier,
      combinedMultiplier: combinedMultiplier,
      allocatedSessions: allocatedSessions,
      scheduledSessions: scheduledSessions + 1,
      lastSessionDate: sessionDate,
      upcomingExam: upcomingExam,
      daysUntilExam: daysUntilExam,
      isExamMode: isExamMode,
    );
  }

  /// Create a copy with new allocation count
  SubjectAllocation withAllocation(int sessions) {
    return SubjectAllocation(
      subject: subject,
      basePriority: basePriority,
      adjustedPriority: adjustedPriority,
      examBoostMultiplier: examBoostMultiplier,
      difficultyMultiplier: difficultyMultiplier,
      combinedMultiplier: combinedMultiplier,
      allocatedSessions: sessions,
      scheduledSessions: scheduledSessions,
      lastSessionDate: lastSessionDate,
      upcomingExam: upcomingExam,
      daysUntilExam: daysUntilExam,
      isExamMode: isExamMode,
    );
  }

  /// Check if enough gap since last session (for spaced repetition)
  bool hasEnoughGap(DateTime targetDate, int minGapHours) {
    if (lastSessionDate == null) return true;
    return targetDate.difference(lastSessionDate!).inHours >= minGapHours;
  }

  /// Get share of total sessions based on priority
  double getSessionShare(double totalPriority) {
    if (totalPriority == 0) return 0;
    return adjustedPriority / totalPriority;
  }
}

/// Exam boost multiplier levels
class ExamBoostMultipliers {
  /// 0-1 days before exam: Critical mode
  static const double critical = 2.5;

  /// 2-3 days before exam: Very close
  static const double veryClose = 2.0;

  /// 4-7 days before exam: Preparation
  static const double preparation = 1.5;

  /// 8-14 days before exam: Early preparation
  static const double earlyPreparation = 1.2;

  /// 14+ days before exam: Normal
  static const double normal = 1.0;

  /// Get multiplier based on days until exam
  static double getMultiplier(int daysUntilExam) {
    if (daysUntilExam <= 1) return critical;
    if (daysUntilExam <= 3) return veryClose;
    if (daysUntilExam <= 7) return preparation;
    if (daysUntilExam <= 14) return earlyPreparation;
    return normal;
  }

  /// Get Arabic description for boost level
  static String getArabicDescription(double multiplier) {
    if (multiplier >= critical) return 'وضع حرج - اختبار قريب جداً';
    if (multiplier >= veryClose) return 'اختبار خلال ٢-٣ أيام';
    if (multiplier >= preparation) return 'فترة تحضير للاختبار';
    if (multiplier >= earlyPreparation) return 'تحضير مبكر للاختبار';
    return 'وضع عادي';
  }
}
