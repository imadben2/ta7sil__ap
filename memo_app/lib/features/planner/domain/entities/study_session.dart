import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Domain entity representing a study session
class StudySession extends Equatable {
  final String id;
  final String userId;
  final String subjectId;
  final String subjectName;
  final String? chapterId;
  final String? chapterName;

  // Scheduling
  final DateTime scheduledDate;
  final TimeOfDay scheduledStartTime;
  final TimeOfDay scheduledEndTime;
  final Duration duration;

  // Content Suggestion
  final String? suggestedContentId;
  final ContentType? suggestedContentType;
  final String? contentTitle;
  final String? contentSuggestion; // AI-generated content suggestion text
  final String? topicName; // Specific topic within chapter

  // Content Allocation (from subject_planner_content)
  final String? subjectPlannerContentId; // FK to subject_planner_content
  final bool hasContent; // true if content exists, false shows placeholder
  final String? contentPhase; // understanding, review, theory_practice, exercise_practice, test

  // Session Properties
  final SessionType sessionType;
  final String? rawSessionType; // Original API session_type value (lesson_review, exercises, etc.)
  final EnergyLevel requiredEnergyLevel;
  final EnergyLevel? estimatedEnergyLevel; // Estimated energy needed
  final int priorityScore;
  final bool isPinned;
  final bool isBreak; // Is this a break session?
  final bool isPrayerTime; // Is this a prayer time slot?

  // UI Properties
  final Color? subjectColor; // Color for visual identification

  // Pomodoro Settings
  final bool usePomodoroTechnique; // Whether to use Pomodoro
  final int? pomodoroDurationMinutes; // Custom Pomodoro duration

  // Status Tracking
  final SessionStatus status;
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;
  final Duration? actualDuration;

  // User Interaction
  final String? userNotes;
  final String? skipReason;
  final int? completionPercentage;

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;

  // Caching & Sync Metadata
  final DateTime? cachedAt;        // When locally cached
  final DateTime? lastSyncedAt;    // Last API sync
  final bool isDirty;              // Has unsaved local changes

  const StudySession({
    required this.id,
    required this.userId,
    required this.subjectId,
    required this.subjectName,
    this.chapterId,
    this.chapterName,
    required this.scheduledDate,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    required this.duration,
    this.suggestedContentId,
    this.suggestedContentType,
    this.contentTitle,
    this.contentSuggestion,
    this.topicName,
    this.subjectPlannerContentId,
    this.hasContent = true,
    this.contentPhase,
    required this.sessionType,
    this.rawSessionType,
    required this.requiredEnergyLevel,
    this.estimatedEnergyLevel,
    required this.priorityScore,
    this.isPinned = false,
    this.isBreak = false,
    this.isPrayerTime = false,
    this.subjectColor,
    this.usePomodoroTechnique = true,
    this.pomodoroDurationMinutes,
    required this.status,
    this.actualStartTime,
    this.actualEndTime,
    this.actualDuration,
    this.userNotes,
    this.skipReason,
    this.completionPercentage,
    required this.createdAt,
    required this.updatedAt,
    this.cachedAt,
    this.lastSyncedAt,
    this.isDirty = false,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    subjectId,
    scheduledDate,
    scheduledStartTime,
    status,
    actualStartTime,
    isPinned,
  ];

  // Helper methods
  bool get isScheduled => status == SessionStatus.scheduled;
  bool get isInProgress => status == SessionStatus.inProgress;
  bool get isCompleted => status == SessionStatus.completed;
  bool get isMissed => status == SessionStatus.missed;
  bool get isSkipped => status == SessionStatus.skipped;

  // Duration helpers (in minutes)
  int? get actualDurationMinutes => actualDuration?.inMinutes;
  int get estimatedDurationMinutes => duration.inMinutes;

  DateTime get scheduledDateTime {
    return DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      scheduledStartTime.hour,
      scheduledStartTime.minute,
    );
  }

  bool get isToday {
    final now = DateTime.now();
    return scheduledDate.year == now.year &&
        scheduledDate.month == now.month &&
        scheduledDate.day == now.day;
  }

  bool get isPast {
    return scheduledDateTime.isBefore(DateTime.now());
  }

  bool get isUpcoming {
    return scheduledDateTime.isAfter(DateTime.now());
  }

  /// Check if the session is from a previous day (not today)
  bool get isPreviousDay {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDay = DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day);
    return sessionDay.isBefore(today);
  }

  /// Check if actions should be disabled (past day sessions that are still scheduled)
  bool get isActionDisabled {
    return isPreviousDay && status == SessionStatus.scheduled;
  }

  StudySession copyWith({
    DateTime? scheduledDate,
    TimeOfDay? scheduledStartTime,
    TimeOfDay? scheduledEndTime,
    SessionStatus? status,
    DateTime? actualStartTime,
    DateTime? actualEndTime,
    Duration? actualDuration,
    String? userNotes,
    String? skipReason,
    bool? isPinned,
    int? completionPercentage,
    Color? subjectColor,
    String? contentSuggestion,
    String? topicName,
    String? subjectPlannerContentId,
    bool? hasContent,
    String? contentPhase,
    EnergyLevel? estimatedEnergyLevel,
    bool? usePomodoroTechnique,
    int? pomodoroDurationMinutes,
    DateTime? cachedAt,
    DateTime? lastSyncedAt,
    bool? isDirty,
    DateTime? updatedAt,
  }) {
    return StudySession(
      id: id,
      userId: userId,
      subjectId: subjectId,
      subjectName: subjectName,
      chapterId: chapterId,
      chapterName: chapterName,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledStartTime: scheduledStartTime ?? this.scheduledStartTime,
      scheduledEndTime: scheduledEndTime ?? this.scheduledEndTime,
      duration: duration,
      suggestedContentId: suggestedContentId,
      suggestedContentType: suggestedContentType,
      contentTitle: contentTitle,
      contentSuggestion: contentSuggestion ?? this.contentSuggestion,
      topicName: topicName ?? this.topicName,
      subjectPlannerContentId: subjectPlannerContentId ?? this.subjectPlannerContentId,
      hasContent: hasContent ?? this.hasContent,
      contentPhase: contentPhase ?? this.contentPhase,
      sessionType: sessionType,
      rawSessionType: rawSessionType,
      requiredEnergyLevel: requiredEnergyLevel,
      estimatedEnergyLevel: estimatedEnergyLevel ?? this.estimatedEnergyLevel,
      priorityScore: priorityScore,
      isPinned: isPinned ?? this.isPinned,
      isBreak: isBreak,
      isPrayerTime: isPrayerTime,
      subjectColor: subjectColor ?? this.subjectColor,
      usePomodoroTechnique: usePomodoroTechnique ?? this.usePomodoroTechnique,
      pomodoroDurationMinutes:
          pomodoroDurationMinutes ?? this.pomodoroDurationMinutes,
      status: status ?? this.status,
      actualStartTime: actualStartTime ?? this.actualStartTime,
      actualEndTime: actualEndTime ?? this.actualEndTime,
      actualDuration: actualDuration ?? this.actualDuration,
      userNotes: userNotes ?? this.userNotes,
      skipReason: skipReason ?? this.skipReason,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      cachedAt: cachedAt ?? this.cachedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isDirty: isDirty ?? this.isDirty,
    );
  }
}

// Enums
enum SessionStatus { scheduled, inProgress, paused, completed, missed, skipped }

enum SessionType {
  study, // Regular content review
  regular, // Regular session (alternative to study)
  revision, // Quick recap
  practice, // Exercises/quizzes
  exam, // Exam preparation
  longRevision, // Deep dive
}

/// Session types from promt.md algorithm
/// Maps directly to API session_type values
enum PlannerSessionType {
  lessonReview, // LESSON_REVIEW - مراجعة/فهم الدرس
  exercises, // EXERCISES - حل تمارين
  topicTest, // TOPIC_TEST - اختبار نهاية Topic
  unitTest, // UNIT_TEST - اختبار الوحدة (120 دقيقة للمواد ذات المعامل الأكبر)
  spacedReview, // SPACED_REVIEW - مراجعة متباعدة (spaced repetition)
  languageDaily, // LANGUAGE_DAILY - جلسة لغة يومية (guaranteed daily)
  mockTest, // MOCK_TEST - اختبار أسبوعي شامل
}

/// Extension for PlannerSessionType utility methods
extension PlannerSessionTypeExtension on PlannerSessionType {
  /// Get API string value (snake_case)
  String get apiValue {
    switch (this) {
      case PlannerSessionType.lessonReview:
        return 'lesson_review';
      case PlannerSessionType.exercises:
        return 'exercises';
      case PlannerSessionType.topicTest:
        return 'topic_test';
      case PlannerSessionType.unitTest:
        return 'unit_test';
      case PlannerSessionType.spacedReview:
        return 'spaced_review';
      case PlannerSessionType.languageDaily:
        return 'language_daily';
      case PlannerSessionType.mockTest:
        return 'mock_test';
    }
  }

  /// Get Arabic display label
  String get labelAr {
    switch (this) {
      case PlannerSessionType.lessonReview:
        return 'درس';
      case PlannerSessionType.exercises:
        return 'تمارين';
      case PlannerSessionType.topicTest:
        return 'اختبار';
      case PlannerSessionType.unitTest:
        return 'اختبار الوحدة';
      case PlannerSessionType.spacedReview:
        return 'تثبيت';
      case PlannerSessionType.languageDaily:
        return 'لغة';
      case PlannerSessionType.mockTest:
        return 'اختبار شامل';
    }
  }

  /// Parse from API string
  static PlannerSessionType fromApiValue(String value) {
    switch (value) {
      case 'lesson_review':
        return PlannerSessionType.lessonReview;
      case 'exercises':
        return PlannerSessionType.exercises;
      case 'topic_test':
        return PlannerSessionType.topicTest;
      case 'unit_test':
        return PlannerSessionType.unitTest;
      case 'spaced_review':
        return PlannerSessionType.spacedReview;
      case 'language_daily':
        return PlannerSessionType.languageDaily;
      case 'mock_test':
        return PlannerSessionType.mockTest;
      default:
        return PlannerSessionType.lessonReview;
    }
  }

  /// Check if this session type requires a score submission
  bool get requiresScore {
    return this == PlannerSessionType.topicTest ||
        this == PlannerSessionType.unitTest ||
        this == PlannerSessionType.mockTest;
  }

  /// Check if this is a test-type session
  bool get isTest {
    return this == PlannerSessionType.topicTest ||
        this == PlannerSessionType.unitTest ||
        this == PlannerSessionType.mockTest;
  }
}

enum ContentType {
  video,
  pdf,
  html,
  quiz,
  exercise,
  mixed, // Mixed content types
}

enum EnergyLevel {
  veryLow, // 0-2 - minimal energy
  low, // 1-3
  medium, // 4-6
  high, // 7-10
}

/// Extension to add comparison operators to EnergyLevel
extension EnergyLevelComparison on EnergyLevel {
  int get value {
    switch (this) {
      case EnergyLevel.veryLow:
        return 0;
      case EnergyLevel.low:
        return 1;
      case EnergyLevel.medium:
        return 2;
      case EnergyLevel.high:
        return 3;
    }
  }

  bool operator >=(EnergyLevel other) => value >= other.value;
  bool operator <=(EnergyLevel other) => value <= other.value;
  bool operator >(EnergyLevel other) => value > other.value;
  bool operator <(EnergyLevel other) => value < other.value;
}
