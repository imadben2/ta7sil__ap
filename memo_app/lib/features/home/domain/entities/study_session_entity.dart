import 'package:equatable/equatable.dart';

/// Types of study sessions
enum SessionType {
  lesson, // درس
  review, // مراجعة
  quiz, // اختبار
  homework, // واجب
}

/// Status of study sessions
enum SessionStatus {
  pending, // قادم
  inProgress, // جاري
  completed, // مكتمل
  missed, // فائت
}

/// Entity representing a study session in the planner
class StudySessionEntity extends Equatable {
  final int id;
  final int subjectId;
  final String subjectName;
  final String subjectColor;
  final SessionType type;
  final SessionStatus status;
  final DateTime startTime;
  final DateTime endTime;
  final String? topic; // Chapter or topic name
  final String? notes;

  const StudySessionEntity({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.subjectColor,
    required this.type,
    required this.status,
    required this.startTime,
    required this.endTime,
    this.topic,
    this.notes,
  });

  /// Duration in minutes
  int get durationMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  /// Formatted duration "Xس Yد"
  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0) {
      return '${hours}س ${minutes}د';
    }
    return '${minutes}د';
  }

  /// Time until session starts (negative if already started/passed)
  Duration get timeUntilStart {
    return startTime.difference(DateTime.now());
  }

  /// Check if session is today
  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
        startTime.month == now.month &&
        startTime.day == now.day;
  }

  /// Check if session is happening now
  bool get isNow {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// Check if session has passed
  bool get hasPassed {
    return DateTime.now().isAfter(endTime);
  }

  /// Get type label in Arabic
  String get typeLabel {
    switch (type) {
      case SessionType.lesson:
        return 'درس';
      case SessionType.review:
        return 'مراجعة';
      case SessionType.quiz:
        return 'اختبار';
      case SessionType.homework:
        return 'واجب';
    }
  }

  @override
  List<Object?> get props => [
    id,
    subjectId,
    subjectName,
    subjectColor,
    type,
    status,
    startTime,
    endTime,
    topic,
    notes,
  ];
}
