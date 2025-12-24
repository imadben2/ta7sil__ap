import 'package:equatable/equatable.dart';
import 'bac_day_subject.dart';

/// Entity representing a single study day in the 98-day schedule
class BacStudyDay extends Equatable {
  final int id;
  final int dayNumber;
  final String dayType; // study, review, reward
  final String? titleAr;
  final int weekNumber;
  final List<BacDaySubject> subjects;

  const BacStudyDay({
    required this.id,
    required this.dayNumber,
    required this.dayType,
    this.titleAr,
    required this.weekNumber,
    this.subjects = const [],
  });

  /// Get day type display name in Arabic
  String get dayTypeDisplayAr {
    switch (dayType) {
      case 'study':
        return 'يوم دراسة';
      case 'review':
        return 'يوم مراجعة';
      case 'reward':
        return 'يوم مكافأة';
      default:
        return dayType;
    }
  }

  /// Get total topics count across all subjects
  int get totalTopicsCount =>
      subjects.fold(0, (sum, subject) => sum + subject.totalTopicsCount);

  /// Get completed topics count across all subjects
  int get completedTopicsCount =>
      subjects.fold(0, (sum, subject) => sum + subject.completedTopicsCount);

  /// Check if all topics are completed
  bool get isFullyCompleted =>
      totalTopicsCount > 0 && completedTopicsCount == totalTopicsCount;

  /// Get progress percentage (0.0 to 1.0)
  double get progressPercentage =>
      totalTopicsCount > 0 ? completedTopicsCount / totalTopicsCount : 0.0;

  /// Get display title (day number or custom title)
  String get displayTitle => titleAr ?? 'اليوم $dayNumber';

  BacStudyDay copyWith({
    int? id,
    int? dayNumber,
    String? dayType,
    String? titleAr,
    int? weekNumber,
    List<BacDaySubject>? subjects,
  }) {
    return BacStudyDay(
      id: id ?? this.id,
      dayNumber: dayNumber ?? this.dayNumber,
      dayType: dayType ?? this.dayType,
      titleAr: titleAr ?? this.titleAr,
      weekNumber: weekNumber ?? this.weekNumber,
      subjects: subjects ?? this.subjects,
    );
  }

  @override
  List<Object?> get props => [id, dayNumber, dayType, titleAr, weekNumber, subjects];
}
