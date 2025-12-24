import 'package:equatable/equatable.dart';
import 'package:memo_app/features/focus_mode/domain/entities/focus_mode_settings.dart';

/// Focus Mode Type
///
/// Categorizes the reason for activating focus mode.
enum FocusModeType {
  /// Manually activated by user
  manual,

  /// Auto-activated during a study session
  studySession,

  /// Auto-activated during quiet hours
  quietHours,

  /// Auto-activated during exam preparation
  examPreparation,
}

extension FocusModeTypeExtension on FocusModeType {
  /// Get Arabic name
  String get arabicName {
    switch (this) {
      case FocusModeType.manual:
        return 'يدوي';
      case FocusModeType.studySession:
        return 'جلسة دراسة';
      case FocusModeType.quietHours:
        return 'ساعات الهدوء';
      case FocusModeType.examPreparation:
        return 'تحضير للامتحان';
    }
  }

  /// Get English name
  String get englishName {
    switch (this) {
      case FocusModeType.manual:
        return 'Manual';
      case FocusModeType.studySession:
        return 'Study Session';
      case FocusModeType.quietHours:
        return 'Quiet Hours';
      case FocusModeType.examPreparation:
        return 'Exam Preparation';
    }
  }
}

/// Focus Session Entity
///
/// Represents an active or past focus mode session.
/// Tracks when focus mode was activated, its type, and associated settings.
class FocusSessionEntity extends Equatable {
  /// Unique identifier
  final String id;

  /// Session start time
  final DateTime startTime;

  /// Session end time (null if still active)
  final DateTime? endTime;

  /// Focus mode type
  final FocusModeType type;

  /// Settings active during this session
  final FocusModeSettings settings;

  /// Optional study session ID (if type is studySession)
  final String? studySessionId;

  /// Optional notes
  final String? notes;

  /// Whether system DND was actually enabled
  final bool systemDndEnabled;

  const FocusSessionEntity({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.type,
    required this.settings,
    this.studySessionId,
    this.notes,
    this.systemDndEnabled = false,
  });

  /// Check if session is still active
  bool get isActive => endTime == null;

  /// Get session duration
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Get formatted duration
  String get formattedDuration {
    final d = duration;
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}س ${minutes}د';
    } else {
      return '${minutes}د';
    }
  }

  /// Copy with
  FocusSessionEntity copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    FocusModeType? type,
    FocusModeSettings? settings,
    String? studySessionId,
    String? notes,
    bool? systemDndEnabled,
  }) {
    return FocusSessionEntity(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      settings: settings ?? this.settings,
      studySessionId: studySessionId ?? this.studySessionId,
      notes: notes ?? this.notes,
      systemDndEnabled: systemDndEnabled ?? this.systemDndEnabled,
    );
  }

  @override
  List<Object?> get props => [
        id,
        startTime,
        endTime,
        type,
        settings,
        studySessionId,
        notes,
        systemDndEnabled,
      ];
}
