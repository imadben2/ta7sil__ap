import '../../domain/entities/subject.dart';
import '../../domain/entities/exam.dart';
import '../../domain/entities/prioritized_subject.dart';
import '../../domain/entities/planner_settings.dart';

/// Priority Calculator Service
///
/// Calculates priority scores for subjects based on multiple factors:
/// 1. Coefficient (BAC exam weight) - default 40%
/// 2. Exam Proximity (upcoming exam urgency) - default 25%
/// 3. Difficulty Level - default 15%
/// 4. Historical Performance Gap (last year average) - default 10%
/// 5. Performance Gap (target vs current progress) - default 5%
/// 6. Inactivity (days since last study) - default 5%
class PriorityCalculator {
  /// Calculate priority scores for all subjects
  ///
  /// Returns a sorted list (highest priority first)
  List<PrioritizedSubject> calculatePriorities({
    required List<Subject> subjects,
    required List<Exam> exams,
    required PlannerSettings settings,
  }) {
    final prioritizedSubjects = <PrioritizedSubject>[];

    for (final subject in subjects) {
      // Skip inactive subjects
      if (!subject.isActive) continue;

      // Find upcoming exam for this subject
      final upcomingExam = _findUpcomingExam(subject.id, exams);

      // Calculate priority score
      final prioritized = _calculateSubjectPriority(
        subject: subject,
        upcomingExam: upcomingExam,
        settings: settings,
      );

      prioritizedSubjects.add(prioritized);
    }

    // Sort by priority score (descending)
    prioritizedSubjects.sort(
      (a, b) => b.priorityScore.compareTo(a.priorityScore),
    );

    return prioritizedSubjects;
  }

  /// Find the most urgent upcoming exam for a subject
  Exam? _findUpcomingExam(String subjectId, List<Exam> exams) {
    final upcomingExams = exams
        .where((exam) => exam.subjectId == subjectId && exam.isUpcoming)
        .toList();

    if (upcomingExams.isEmpty) return null;

    // Sort by urgency score (descending)
    upcomingExams.sort((a, b) => b.urgencyScore.compareTo(a.urgencyScore));

    return upcomingExams.first;
  }

  /// Calculate priority for a single subject
  PrioritizedSubject _calculateSubjectPriority({
    required Subject subject,
    required Exam? upcomingExam,
    required PlannerSettings settings,
  }) {
    // Extract weights from settings
    final coefficientWeight = settings.coefficientWeight;
    final examProximityWeight = settings.examProximityWeight;
    final difficultyWeight = settings.difficultyWeight;
    final inactivityWeight = settings.inactivityWeight;
    final performanceGapWeight = settings.performanceGapWeight;
    final historicalPerformanceGapWeight = settings.historicalPerformanceGapWeight;

    // Calculate individual scores (0-10 scale)
    final coefficientScore = _calculateCoefficientScore(subject);
    final examProximityScore = _calculateExamProximityScore(upcomingExam);
    final difficultyScore = _calculateDifficultyScore(subject);
    final inactivityScore = _calculateInactivityScore(subject);
    final performanceGapScore = _calculatePerformanceGapScore(subject);
    final historicalPerformanceGapScore = _calculateHistoricalPerformanceGapScore(subject);

    // Store breakdown for transparency
    final scoreBreakdown = {
      'coefficient': coefficientScore,
      'examProximity': examProximityScore,
      'difficulty': difficultyScore,
      'inactivity': inactivityScore,
      'performanceGap': performanceGapScore,
      'historicalPerformanceGap': historicalPerformanceGapScore,
    };

    // Calculate weighted total
    final totalWeight =
        coefficientWeight +
        examProximityWeight +
        difficultyWeight +
        inactivityWeight +
        performanceGapWeight +
        historicalPerformanceGapWeight;

    final weightedScore =
        (coefficientScore * coefficientWeight +
            examProximityScore * examProximityWeight +
            difficultyScore * difficultyWeight +
            inactivityScore * inactivityWeight +
            performanceGapScore * performanceGapWeight +
            historicalPerformanceGapScore * historicalPerformanceGapWeight) /
        totalWeight *
        10;

    return PrioritizedSubject(
      subject: subject,
      priorityScore: weightedScore.clamp(0, 100).toDouble(),
      upcomingExam: upcomingExam,
      scoreBreakdown: scoreBreakdown,
    );
  }

  /// Calculate coefficient score (0-10)
  ///
  /// Higher coefficient = higher priority
  /// Algerian BAC coefficients range from 1 to 7
  double _calculateCoefficientScore(Subject subject) {
    // Normalize coefficient (1-7) to score (0-10)
    return (subject.coefficient / 7.0 * 10).clamp(0, 10).toDouble();
  }

  /// Calculate exam proximity score (0-10)
  ///
  /// Closer exam = higher priority
  /// Uses exam urgency score (0-100)
  double _calculateExamProximityScore(Exam? exam) {
    if (exam == null) return 0;

    // Convert urgency (0-100) to score (0-10)
    return (exam.urgencyScore / 10.0).clamp(0, 10).toDouble();
  }

  /// Calculate difficulty score (0-10)
  ///
  /// Higher difficulty = higher priority
  /// Difficulty range is 1-10
  double _calculateDifficultyScore(Subject subject) {
    return subject.difficultyLevel.toDouble().clamp(0, 10);
  }

  /// Calculate inactivity score (0-10)
  ///
  /// More days without study = higher priority
  /// Score increases with days since last study
  double _calculateInactivityScore(Subject subject) {
    final daysSinceStudy = subject.daysSinceLastStudy ?? 30;

    // Linear scale: 0 days = 0, 30+ days = 10
    return (daysSinceStudy / 30.0 * 10).clamp(0, 10).toDouble();
  }

  /// Calculate performance gap score (0-10)
  ///
  /// Larger gap between target and current progress = higher priority
  /// Gap range is 0.0-1.0
  double _calculatePerformanceGapScore(Subject subject) {
    final gap = subject.performanceGap;

    // Convert gap (0-1) to score (0-10)
    return (gap * 10).clamp(0, 10).toDouble();
  }

  /// Calculate historical performance gap score (0-10)
  ///
  /// Larger gap between target (14/20) and lastYearAverage = higher priority
  /// Subjects with poor past performance get boosted priority
  /// Null lastYearAverage = 0.0 (neutral)
  double _calculateHistoricalPerformanceGapScore(Subject subject) {
    const targetAverage = 14.0; // BAC target (14/20 = 70%)

    if (subject.lastYearAverage == null) return 0.0;

    final gap = targetAverage - subject.lastYearAverage!;

    // Convert gap to score (0-10)
    // Example: gap = 6 (target 14, lastYear 8) → score = 6.0
    // Example: gap = 10 (target 14, lastYear 4) → score = 10.0
    // Example: gap = -2 (target 14, lastYear 16) → score = 0.0 (no negative)
    return (gap / 10.0 * 10).clamp(0, 10).toDouble();
  }

  /// Get recommended study hours per week for a subject
  ///
  /// Based on priority score and total available hours
  double getRecommendedStudyHours({
    required PrioritizedSubject prioritizedSubject,
    required int totalAvailableHours,
    required int numberOfSubjects,
  }) {
    if (numberOfSubjects == 0) return 0;

    // Base allocation (equal distribution)
    final baseHours = totalAvailableHours / numberOfSubjects;

    // Priority multiplier (0.5x to 2.0x)
    // Low priority (0-25): 0.5x
    // Medium priority (25-50): 0.75x
    // Normal priority (50-75): 1.0x
    // High priority (75-100): 1.5x-2.0x
    final priorityScore = prioritizedSubject.priorityScore;
    final multiplier = _getPriorityMultiplier(priorityScore);

    return (baseHours * multiplier).clamp(0, totalAvailableHours.toDouble());
  }

  /// Get priority multiplier based on score
  double _getPriorityMultiplier(double priorityScore) {
    if (priorityScore >= 90) return 2.0; // Critical
    if (priorityScore >= 75) return 1.5; // High
    if (priorityScore >= 50) return 1.0; // Normal
    if (priorityScore >= 25) return 0.75; // Medium
    return 0.5; // Low
  }

  /// Analyze priority distribution across all subjects
  ///
  /// Returns insights about the priority distribution
  Map<String, dynamic> analyzePriorityDistribution(
    List<PrioritizedSubject> prioritizedSubjects,
  ) {
    if (prioritizedSubjects.isEmpty) {
      return {
        'total': 0,
        'critical': 0,
        'high': 0,
        'medium': 0,
        'low': 0,
        'averageScore': 0.0,
      };
    }

    int critical = 0;
    int high = 0;
    int medium = 0;
    int low = 0;
    double totalScore = 0;

    for (final subject in prioritizedSubjects) {
      final score = subject.priorityScore;
      totalScore += score;

      if (score >= 80) {
        critical++;
      } else if (score >= 60) {
        high++;
      } else if (score >= 40) {
        medium++;
      } else {
        low++;
      }
    }

    return {
      'total': prioritizedSubjects.length,
      'critical': critical,
      'high': high,
      'medium': medium,
      'low': low,
      'averageScore': totalScore / prioritizedSubjects.length,
      'highestScore': prioritizedSubjects.first.priorityScore,
      'lowestScore': prioritizedSubjects.last.priorityScore,
    };
  }

  /// Get subjects that need immediate attention (priority >= 75)
  List<PrioritizedSubject> getUrgentSubjects(
    List<PrioritizedSubject> prioritizedSubjects,
  ) {
    return prioritizedSubjects
        .where((subject) => subject.priorityScore >= 75)
        .toList();
  }

  /// Get subjects that can be deprioritized (priority < 40)
  List<PrioritizedSubject> getLowPrioritySubjects(
    List<PrioritizedSubject> prioritizedSubjects,
  ) {
    return prioritizedSubjects
        .where((subject) => subject.priorityScore < 40)
        .toList();
  }
}
