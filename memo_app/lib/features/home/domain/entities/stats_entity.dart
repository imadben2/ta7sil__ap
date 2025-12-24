import 'package:equatable/equatable.dart';

/// Entity representing user statistics for dashboard
class StatsEntity extends Equatable {
  final int streak; // Consecutive days of study
  final int totalPoints; // Total gamification points
  final int level; // Current user level
  final int pointsToNextLevel; // Points needed for next level
  final int studyTimeToday; // Minutes studied today
  final int dailyGoal; // Daily goal in minutes

  const StatsEntity({
    required this.streak,
    required this.totalPoints,
    required this.level,
    required this.pointsToNextLevel,
    required this.studyTimeToday,
    required this.dailyGoal,
  });

  /// Calculate progress percentage towards next level
  double get levelProgress {
    if (pointsToNextLevel == 0) return 1.0;
    final currentLevelPoints = totalPoints % pointsToNextLevel;
    return currentLevelPoints / pointsToNextLevel;
  }

  /// Calculate daily goal progress percentage
  double get dailyGoalProgress {
    if (dailyGoal == 0) return 0.0;
    return (studyTimeToday / dailyGoal).clamp(0.0, 1.0);
  }

  /// Format study time as "Xس Yد"
  String get formattedStudyTime {
    final hours = studyTimeToday ~/ 60;
    final minutes = studyTimeToday % 60;
    if (hours > 0) {
      return '${hours}س ${minutes}د';
    }
    return '${minutes}د';
  }

  @override
  List<Object?> get props => [
    streak,
    totalPoints,
    level,
    pointsToNextLevel,
    studyTimeToday,
    dailyGoal,
  ];
}
