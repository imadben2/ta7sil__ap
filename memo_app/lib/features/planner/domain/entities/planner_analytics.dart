import 'package:equatable/equatable.dart';

/// Planner Analytics Entity
/// Contains comprehensive analytics data for the intelligent planner feature
class PlannerAnalytics extends Equatable {
  /// Period identifier (e.g., 'last_7_days', 'last_30_days', 'last_3_months', 'all_time')
  final String period;

  /// Date range
  final DateTime startDate;
  final DateTime endDate;

  // Study Metrics
  final double totalHours;
  final int sessionsCompleted;
  final int sessionsMissed;
  final int sessionsSkipped;
  final double completionRate; // percentage 0-100
  final int averageSessionDuration; // in minutes

  // Streak & Progress
  final int currentStreak; // consecutive days with completed sessions
  final int longestStreak;
  final int totalPoints;
  final int currentLevel;

  // Subject Breakdown
  /// Map of subject name to hours spent
  final Map<String, double> subjectTimeBreakdown;

  /// Map of subject name to session count
  final Map<String, int> subjectSessionCount;

  // Weekly Productivity Data (for bar chart)
  /// Map of day index (0=Saturday, 6=Friday) to hours
  final Map<int, double> weeklyProductivityHours;

  // Daily Study Time Trend (for line chart)
  /// List of daily study hours for the period
  final List<DailyStudyData> dailyStudyTrend;

  // Productivity Patterns
  final ProductivityPatterns? patterns;

  // AI Recommendations
  final List<String> recommendations;

  const PlannerAnalytics({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.totalHours,
    required this.sessionsCompleted,
    required this.sessionsMissed,
    required this.sessionsSkipped,
    required this.completionRate,
    required this.averageSessionDuration,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalPoints,
    required this.currentLevel,
    required this.subjectTimeBreakdown,
    required this.subjectSessionCount,
    required this.weeklyProductivityHours,
    required this.dailyStudyTrend,
    this.patterns,
    this.recommendations = const [],
  });

  @override
  List<Object?> get props => [
    period,
    startDate,
    endDate,
    totalHours,
    sessionsCompleted,
    sessionsMissed,
    sessionsSkipped,
    completionRate,
    averageSessionDuration,
    currentStreak,
    longestStreak,
    totalPoints,
    currentLevel,
    subjectTimeBreakdown,
    subjectSessionCount,
    weeklyProductivityHours,
    dailyStudyTrend,
    patterns,
    recommendations,
  ];
}

/// Daily study data for trend charts
class DailyStudyData extends Equatable {
  final DateTime date;
  final double hours;
  final int sessionCount;

  const DailyStudyData({
    required this.date,
    required this.hours,
    required this.sessionCount,
  });

  @override
  List<Object?> get props => [date, hours, sessionCount];
}

/// Productivity patterns identified from study data
class ProductivityPatterns extends Equatable {
  /// Best time of day (e.g., "morning", "afternoon", "evening", "night")
  final String bestTimeOfDay;

  /// Best day of week (e.g., "Tuesday")
  final String bestDayOfWeek;

  /// Optimal session duration in minutes
  final int optimalSessionDuration;

  /// Average productivity score (0-100)
  final double productivityScore;

  /// Peak study hour (0-23)
  final int peakStudyHour;

  const ProductivityPatterns({
    required this.bestTimeOfDay,
    required this.bestDayOfWeek,
    required this.optimalSessionDuration,
    required this.productivityScore,
    required this.peakStudyHour,
  });

  @override
  List<Object?> get props => [
    bestTimeOfDay,
    bestDayOfWeek,
    optimalSessionDuration,
    productivityScore,
    peakStudyHour,
  ];
}
