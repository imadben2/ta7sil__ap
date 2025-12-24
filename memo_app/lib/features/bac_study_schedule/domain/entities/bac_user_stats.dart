import 'package:equatable/equatable.dart';

/// Entity representing user's progress statistics
class BacUserStats extends Equatable {
  final int totalDays;
  final int completedDays;
  final int totalTopics;
  final int completedTopics;
  final double progressPercentage;
  final int currentDay;

  const BacUserStats({
    required this.totalDays,
    required this.completedDays,
    required this.totalTopics,
    required this.completedTopics,
    required this.progressPercentage,
    required this.currentDay,
  });

  /// Get remaining days
  int get remainingDays => totalDays - completedDays;

  /// Get remaining topics
  int get remainingTopics => totalTopics - completedTopics;

  /// Get current week number
  int get currentWeek => ((currentDay - 1) ~/ 7) + 1;

  /// Check if schedule is completed
  bool get isScheduleCompleted => completedDays >= totalDays && totalDays > 0;

  /// Check if schedule is available for the user's stream
  bool get isScheduleAvailable => totalTopics > 0;

  /// Get formatted progress string (e.g., "45.5%")
  String get progressPercentageFormatted => '${progressPercentage.toStringAsFixed(1)}%';

  const BacUserStats.empty()
      : totalDays = 98,
        completedDays = 0,
        totalTopics = 0,
        completedTopics = 0,
        progressPercentage = 0.0,
        currentDay = 1;

  BacUserStats copyWith({
    int? totalDays,
    int? completedDays,
    int? totalTopics,
    int? completedTopics,
    double? progressPercentage,
    int? currentDay,
  }) {
    return BacUserStats(
      totalDays: totalDays ?? this.totalDays,
      completedDays: completedDays ?? this.completedDays,
      totalTopics: totalTopics ?? this.totalTopics,
      completedTopics: completedTopics ?? this.completedTopics,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      currentDay: currentDay ?? this.currentDay,
    );
  }

  @override
  List<Object?> get props => [totalDays, completedDays, totalTopics, completedTopics, progressPercentage, currentDay];
}
