import 'package:equatable/equatable.dart';

/// Session History Entity
/// Contains historical session data with aggregations and filters
class SessionHistory extends Equatable {
  /// Date range for the history
  final DateTime startDate;
  final DateTime endDate;

  /// List of historical sessions
  final List<HistoricalSession> sessions;

  /// Intensity map for heatmap (date -> intensity 0-4)
  final Map<String, int> intensityMap;

  /// Summary statistics
  final HistoryStatistics statistics;

  /// Applied filters
  final Map<String, dynamic> filters;

  const SessionHistory({
    required this.startDate,
    required this.endDate,
    required this.sessions,
    required this.intensityMap,
    required this.statistics,
    this.filters = const {},
  });

  @override
  List<Object?> get props => [
    startDate,
    endDate,
    sessions,
    intensityMap,
    statistics,
    filters,
  ];
}

/// Historical session data
class HistoricalSession extends Equatable {
  final String id;
  final String subjectId;
  final String subjectName;
  final String subjectColor;
  final DateTime scheduledDate;
  final String scheduledStartTime;
  final String scheduledEndTime;
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;
  final int durationMinutes;
  final int pointsEarned;
  final String? mood;
  final int completionPercentage;
  final String? userNotes;
  final String sessionType;
  final String? contentTitle;
  final String status;

  const HistoricalSession({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.subjectColor,
    required this.scheduledDate,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    this.actualStartTime,
    this.actualEndTime,
    required this.durationMinutes,
    this.pointsEarned = 0,
    this.mood,
    this.completionPercentage = 100,
    this.userNotes,
    required this.sessionType,
    this.contentTitle,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    subjectId,
    subjectName,
    subjectColor,
    scheduledDate,
    scheduledStartTime,
    scheduledEndTime,
    actualStartTime,
    actualEndTime,
    durationMinutes,
    pointsEarned,
    mood,
    completionPercentage,
    userNotes,
    sessionType,
    contentTitle,
    status,
  ];
}

/// History statistics summary
class HistoryStatistics extends Equatable {
  final int totalSessions;
  final int totalMinutes;
  final double totalHours;
  final int totalPoints;
  final int averageSessionDuration;
  final Map<String, int> moodDistribution;
  final Map<String, SubjectStats> subjectBreakdown;

  const HistoryStatistics({
    required this.totalSessions,
    required this.totalMinutes,
    required this.totalHours,
    required this.totalPoints,
    required this.averageSessionDuration,
    required this.moodDistribution,
    required this.subjectBreakdown,
  });

  @override
  List<Object?> get props => [
    totalSessions,
    totalMinutes,
    totalHours,
    totalPoints,
    averageSessionDuration,
    moodDistribution,
    subjectBreakdown,
  ];
}

/// Subject statistics in history
class SubjectStats extends Equatable {
  final String subjectId;
  final String subjectName;
  final String subjectColor;
  final int sessionCount;
  final int totalMinutes;
  final int totalPoints;

  const SubjectStats({
    required this.subjectId,
    required this.subjectName,
    required this.subjectColor,
    required this.sessionCount,
    required this.totalMinutes,
    required this.totalPoints,
  });

  @override
  List<Object?> get props => [
    subjectId,
    subjectName,
    subjectColor,
    sessionCount,
    totalMinutes,
    totalPoints,
  ];
}
