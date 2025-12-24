import 'package:equatable/equatable.dart';
import 'study_session.dart';

/// Type of schedule to generate
enum ScheduleType {
  /// Daily schedule - Today only
  /// Rotation simple, mode examen si < 3 jours
  daily,

  /// Weekly schedule - 7 days
  /// Offset journalier, mode examen si < 7 jours
  weekly,

  /// Full schedule - 30 days
  /// Pattern hebdomadaire, périodes de préparation
  full,
}

/// Extension for ScheduleType with helpful properties
extension ScheduleTypeExtension on ScheduleType {
  /// Get duration in days
  int get durationDays {
    switch (this) {
      case ScheduleType.daily:
        return 1;
      case ScheduleType.weekly:
        return 7;
      case ScheduleType.full:
        return 30;
    }
  }

  /// Get Arabic label
  String get arabicLabel {
    switch (this) {
      case ScheduleType.daily:
        return 'يومي';
      case ScheduleType.weekly:
        return 'أسبوعي';
      case ScheduleType.full:
        return 'شهري كامل';
    }
  }

  /// Get Arabic description
  String get arabicDescription {
    switch (this) {
      case ScheduleType.daily:
        return 'جدول لليوم فقط';
      case ScheduleType.weekly:
        return 'جدول لـ ٧ أيام';
      case ScheduleType.full:
        return 'جدول لـ ٣٠ يوماً';
    }
  }

  /// Get end date from start date
  DateTime getEndDate(DateTime startDate) {
    return startDate.add(Duration(days: durationDays - 1));
  }

  /// Threshold days for exam mode activation
  int get examModeThresholdDays {
    switch (this) {
      case ScheduleType.daily:
        return 3; // Activate exam mode if exam within 3 days
      case ScheduleType.weekly:
        return 7; // Activate exam mode if exam within 7 days
      case ScheduleType.full:
        return 14; // Activate exam mode if exam within 14 days
    }
  }
}

/// Domain entity representing a generated study schedule
class Schedule extends Equatable {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final List<StudySession> sessions;
  final bool isActive;
  final DateTime createdAt;
  final ScheduleType scheduleType;

  const Schedule({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.sessions,
    this.isActive = true,
    required this.createdAt,
    this.scheduleType = ScheduleType.weekly,
  });

  @override
  List<Object?> get props => [id, userId, startDate, endDate, isActive];

  // Get sessions for specific date
  List<StudySession> getSessionsForDate(DateTime date) {
    return sessions.where((session) {
      return session.scheduledDate.year == date.year &&
          session.scheduledDate.month == date.month &&
          session.scheduledDate.day == date.day;
    }).toList();
  }

  // Get sessions for date range
  List<StudySession> getSessionsForRange(DateTime start, DateTime end) {
    return sessions.where((session) {
      return session.scheduledDate.isAfter(
            start.subtract(const Duration(days: 1)),
          ) &&
          session.scheduledDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Statistics
  int get totalSessions => sessions.length;

  int get completedSessions =>
      sessions.where((s) => s.status == SessionStatus.completed).length;

  int get missedSessions =>
      sessions.where((s) => s.status == SessionStatus.missed).length;

  int get skippedSessions =>
      sessions.where((s) => s.status == SessionStatus.skipped).length;

  double get completionRate {
    if (totalSessions == 0) return 0;
    return (completedSessions / totalSessions) * 100;
  }

  Duration get totalScheduledTime {
    return sessions.fold(
      Duration.zero,
      (total, session) => total + session.duration,
    );
  }

  Duration get totalCompletedTime {
    return sessions
        .where((s) => s.status == SessionStatus.completed)
        .fold(
          Duration.zero,
          (total, session) => total + (session.actualDuration ?? Duration.zero),
        );
  }

  // Get study hours by subject
  Map<String, Duration> getStudyHoursBySubject() {
    final map = <String, Duration>{};
    for (var session in sessions) {
      map[session.subjectName] =
          (map[session.subjectName] ?? Duration.zero) + session.duration;
    }
    return map;
  }

  Schedule copyWith({
    bool? isActive,
    List<StudySession>? sessions,
    ScheduleType? scheduleType,
  }) {
    return Schedule(
      id: id,
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      sessions: sessions ?? this.sessions,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      scheduleType: scheduleType ?? this.scheduleType,
    );
  }
}
