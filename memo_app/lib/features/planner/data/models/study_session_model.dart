import 'package:flutter/material.dart';
import '../../domain/entities/study_session.dart';

/// Data model for StudySession with JSON serialization
class StudySessionModel {
  final String id;
  final String userId;
  final String subjectId;
  final String subjectName;
  final String? chapterId;
  final String? chapterName;
  final String scheduledDate; // ISO format: "2025-11-15"
  final String scheduledStartTime; // "09:00"
  final String scheduledEndTime; // "10:30"
  final int durationMinutes;
  final String? suggestedContentId;
  final String? suggestedContentType;
  final String? contentTitle;
  final String? subjectPlannerContentId;
  final bool hasContent;
  final String? contentPhase;
  final String sessionType;
  final String requiredEnergyLevel;
  final int priorityScore;
  final bool isPinned;
  final String status;
  final String? actualStartTime; // ISO 8601
  final String? actualEndTime;
  final int? actualDurationMinutes;
  final String? userNotes;
  final String? skipReason;
  final int? completionPercentage;
  final String createdAt;
  final String updatedAt;
  final String? cachedAt;        // When locally cached
  final String? lastSyncedAt;    // Last API sync
  final bool isDirty;            // Has unsaved local changes
  final bool isBreak;            // Is this a break session?
  final bool isPrayerTime;       // Is this a prayer time slot?
  final String? topicName;       // Topic name for display

  StudySessionModel({
    required this.id,
    required this.userId,
    required this.subjectId,
    required this.subjectName,
    this.chapterId,
    this.chapterName,
    required this.scheduledDate,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    required this.durationMinutes,
    this.suggestedContentId,
    this.suggestedContentType,
    this.contentTitle,
    this.subjectPlannerContentId,
    this.hasContent = true,
    this.contentPhase,
    required this.sessionType,
    required this.requiredEnergyLevel,
    required this.priorityScore,
    this.isPinned = false,
    required this.status,
    this.actualStartTime,
    this.actualEndTime,
    this.actualDurationMinutes,
    this.userNotes,
    this.skipReason,
    this.completionPercentage,
    required this.createdAt,
    required this.updatedAt,
    this.cachedAt,
    this.lastSyncedAt,
    this.isDirty = false,
    this.isBreak = false,
    this.isPrayerTime = false,
    this.topicName,
  });

  // JSON Serialization
  factory StudySessionModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely convert to string (handles int/String from API)
    String? safeString(dynamic value) => value?.toString();
    String safeStringRequired(dynamic value) => value?.toString() ?? '';

    // Check if this is a break session
    final isBreakSession = json['is_break'] as bool? ?? false;

    // Check if this is a prayer time by looking at content_title
    final contentTitle = json['content_title'] as String?;
    final isPrayer = contentTitle != null &&
        (contentTitle.contains('صلاة') || contentTitle.contains('🕌'));

    // Extract subject info from nested 'subject' object if available
    final subjectData = json['subject'] as Map<String, dynamic>?;

    // For prayer sessions, use the prayer title (e.g., "🕌 صلاة الظهر")
    // For regular breaks, use "استراحة"
    // For study sessions, use subject name
    final String subjectName;
    if (isPrayer) {
      subjectName = contentTitle!; // Use prayer title with emoji (we know it's not null because isPrayer check requires it)
    } else if (isBreakSession) {
      subjectName = 'استراحة';
    } else {
      subjectName = json['subject_name'] as String? ??
          subjectData?['name_ar'] as String? ??
          subjectData?['name'] as String? ??
          'مادة غير معروفة';
    }

    return StudySessionModel(
      id: safeStringRequired(json['id']),
      userId: safeStringRequired(json['user_id']),
      subjectId: safeStringRequired(json['subject_id']),
      subjectName: subjectName,
      chapterId: safeString(json['chapter_id']),
      chapterName: json['chapter_name'] as String?,
      scheduledDate: json['scheduled_date'] as String,
      scheduledStartTime: json['scheduled_start_time'] as String,
      scheduledEndTime: json['scheduled_end_time'] as String,
      durationMinutes: json['duration_minutes'] as int,
      suggestedContentId: safeString(json['suggested_content_id']),
      suggestedContentType: json['suggested_content_type'] as String?,
      contentTitle: json['content_title'] as String?,
      subjectPlannerContentId: safeString(json['subject_planner_content_id']),
      hasContent: json['has_content'] as bool? ?? (json['content_title'] != null),
      contentPhase: json['content_phase'] as String?,
      sessionType: json['session_type'] as String? ?? 'study',
      requiredEnergyLevel: json['required_energy_level'] as String? ?? 'medium',
      priorityScore: json['priority_score'] as int? ?? 50,
      isPinned: json['is_pinned'] as bool? ?? false,
      status: json['status'] as String? ?? 'scheduled',
      actualStartTime: json['actual_start_time'] as String?,
      actualEndTime: json['actual_end_time'] as String?,
      actualDurationMinutes: json['actual_duration_minutes'] as int?,
      userNotes: json['user_notes'] as String?,
      skipReason: json['skip_reason'] as String?,
      completionPercentage: json['completion_percentage'] as int?,
      createdAt: json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      cachedAt: json['cached_at'] as String?,
      lastSyncedAt: json['last_synced_at'] as String?,
      isDirty: json['is_dirty'] as bool? ?? false,
      isBreak: json['is_break'] as bool? ?? false,
      isPrayerTime: isPrayer || (json['is_prayer_time'] as bool? ?? false),
      topicName: json['topic_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'subject_id': subjectId,
      'subject_name': subjectName,
      'chapter_id': chapterId,
      'chapter_name': chapterName,
      'scheduled_date': scheduledDate,
      'scheduled_start_time': scheduledStartTime,
      'scheduled_end_time': scheduledEndTime,
      'duration_minutes': durationMinutes,
      'suggested_content_id': suggestedContentId,
      'suggested_content_type': suggestedContentType,
      'content_title': contentTitle,
      'subject_planner_content_id': subjectPlannerContentId,
      'has_content': hasContent,
      'content_phase': contentPhase,
      'session_type': sessionType,
      'required_energy_level': requiredEnergyLevel,
      'priority_score': priorityScore,
      'is_pinned': isPinned,
      'status': status,
      'actual_start_time': actualStartTime,
      'actual_end_time': actualEndTime,
      'actual_duration_minutes': actualDurationMinutes,
      'user_notes': userNotes,
      'skip_reason': skipReason,
      'completion_percentage': completionPercentage,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'cached_at': cachedAt,
      'last_synced_at': lastSyncedAt,
      'is_dirty': isDirty,
      'is_break': isBreak,
      'is_prayer_time': isPrayerTime,
      'topic_name': topicName,
    };
  }

  // Convert to Domain Entity
  StudySession toEntity() {
    return StudySession(
      id: id,
      userId: userId,
      subjectId: subjectId,
      subjectName: subjectName,
      chapterId: chapterId,
      chapterName: chapterName,
      scheduledDate: DateTime.parse(scheduledDate),
      scheduledStartTime: _parseTimeOfDay(scheduledStartTime),
      scheduledEndTime: _parseTimeOfDay(scheduledEndTime),
      duration: Duration(minutes: durationMinutes),
      suggestedContentId: suggestedContentId,
      suggestedContentType: _parseContentType(suggestedContentType),
      contentTitle: contentTitle,
      subjectPlannerContentId: subjectPlannerContentId,
      hasContent: hasContent,
      contentPhase: contentPhase,
      sessionType: _parseSessionType(sessionType),
      rawSessionType: sessionType, // Pass the raw API value for PDF/display use
      requiredEnergyLevel: _parseEnergyLevel(requiredEnergyLevel),
      priorityScore: priorityScore,
      isPinned: isPinned,
      status: _parseSessionStatus(status),
      actualStartTime: actualStartTime != null
          ? DateTime.parse(actualStartTime!)
          : null,
      actualEndTime: actualEndTime != null
          ? DateTime.parse(actualEndTime!)
          : null,
      actualDuration: actualDurationMinutes != null
          ? Duration(minutes: actualDurationMinutes!)
          : null,
      userNotes: userNotes,
      skipReason: skipReason,
      completionPercentage: completionPercentage,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      cachedAt: cachedAt != null ? DateTime.parse(cachedAt!) : null,
      lastSyncedAt: lastSyncedAt != null ? DateTime.parse(lastSyncedAt!) : null,
      isDirty: isDirty,
      isBreak: isBreak,
      isPrayerTime: isPrayerTime,
      topicName: topicName,
    );
  }

  // Create from Domain Entity
  factory StudySessionModel.fromEntity(StudySession entity) {
    return StudySessionModel(
      id: entity.id,
      userId: entity.userId,
      subjectId: entity.subjectId,
      subjectName: entity.subjectName,
      chapterId: entity.chapterId,
      chapterName: entity.chapterName,
      scheduledDate: entity.scheduledDate.toIso8601String().split('T')[0],
      scheduledStartTime: _formatTimeOfDay(entity.scheduledStartTime),
      scheduledEndTime: _formatTimeOfDay(entity.scheduledEndTime),
      durationMinutes: entity.duration.inMinutes,
      suggestedContentId: entity.suggestedContentId,
      suggestedContentType: entity.suggestedContentType?.name,
      contentTitle: entity.contentTitle,
      subjectPlannerContentId: entity.subjectPlannerContentId,
      hasContent: entity.hasContent,
      contentPhase: entity.contentPhase,
      sessionType: entity.sessionType.name,
      requiredEnergyLevel: entity.requiredEnergyLevel.name,
      priorityScore: entity.priorityScore,
      isPinned: entity.isPinned,
      status: entity.status.name,
      actualStartTime: entity.actualStartTime?.toIso8601String(),
      actualEndTime: entity.actualEndTime?.toIso8601String(),
      actualDurationMinutes: entity.actualDuration?.inMinutes,
      userNotes: entity.userNotes,
      skipReason: entity.skipReason,
      completionPercentage: entity.completionPercentage,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
      cachedAt: entity.cachedAt?.toIso8601String(),
      lastSyncedAt: entity.lastSyncedAt?.toIso8601String(),
      isDirty: entity.isDirty,
      isBreak: entity.isBreak,
      isPrayerTime: entity.isPrayerTime,
      topicName: entity.topicName,
    );
  }

  // Helper parsers
  static TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static SessionStatus _parseSessionStatus(String status) {
    return SessionStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => SessionStatus.scheduled,
    );
  }

  static SessionType _parseSessionType(String type) {
    // First check if it's a standard SessionType value
    final standardType = SessionType.values.cast<SessionType?>().firstWhere(
      (e) => e?.name == type,
      orElse: () => null,
    );
    if (standardType != null) return standardType;

    // Map PlannerSessionType API values (snake_case) to SessionType
    // This handles the algorithm-generated session types from the API
    switch (type) {
      case 'lesson_review':
        return SessionType.study; // درس → Étude/Leçon
      case 'exercises':
        return SessionType.practice; // تمارين → Exercices
      case 'topic_test':
      case 'unit_test':
        return SessionType.exam; // اختبار → Examen
      case 'spaced_review':
        return SessionType.revision; // مراجعة متباعدة → Révision
      case 'language_daily':
        return SessionType.study; // جلسة لغة → Étude
      case 'mock_test':
        return SessionType.exam; // اختبار شامل → Examen
      case 'break':
        return SessionType.study; // استراحة - handled separately by isBreak flag
      default:
        return SessionType.study;
    }
  }

  static ContentType? _parseContentType(String? type) {
    if (type == null) return null;
    return ContentType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => ContentType.pdf,
    );
  }

  static EnergyLevel _parseEnergyLevel(String level) {
    return EnergyLevel.values.firstWhere(
      (e) => e.name == level,
      orElse: () => EnergyLevel.medium,
    );
  }

  StudySessionModel copyWith({
    String? status,
    String? actualStartTime,
    String? actualEndTime,
    int? actualDurationMinutes,
    String? userNotes,
    String? skipReason,
    bool? isPinned,
    int? completionPercentage,
    String? subjectPlannerContentId,
    bool? hasContent,
    String? contentPhase,
    String? cachedAt,
    String? lastSyncedAt,
    bool? isDirty,
  }) {
    return StudySessionModel(
      id: id,
      userId: userId,
      subjectId: subjectId,
      subjectName: subjectName,
      chapterId: chapterId,
      chapterName: chapterName,
      scheduledDate: scheduledDate,
      scheduledStartTime: scheduledStartTime,
      scheduledEndTime: scheduledEndTime,
      durationMinutes: durationMinutes,
      suggestedContentId: suggestedContentId,
      suggestedContentType: suggestedContentType,
      contentTitle: contentTitle,
      subjectPlannerContentId: subjectPlannerContentId ?? this.subjectPlannerContentId,
      hasContent: hasContent ?? this.hasContent,
      contentPhase: contentPhase ?? this.contentPhase,
      sessionType: sessionType,
      requiredEnergyLevel: requiredEnergyLevel,
      priorityScore: priorityScore,
      isPinned: isPinned ?? this.isPinned,
      status: status ?? this.status,
      actualStartTime: actualStartTime ?? this.actualStartTime,
      actualEndTime: actualEndTime ?? this.actualEndTime,
      actualDurationMinutes:
          actualDurationMinutes ?? this.actualDurationMinutes,
      userNotes: userNotes ?? this.userNotes,
      skipReason: skipReason ?? this.skipReason,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      createdAt: createdAt,
      updatedAt: DateTime.now().toIso8601String(),
      cachedAt: cachedAt ?? this.cachedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isDirty: isDirty ?? this.isDirty,
      isBreak: isBreak,
      isPrayerTime: isPrayerTime,
      topicName: topicName,
    );
  }
}
