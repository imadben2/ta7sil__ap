import '../../domain/entities/session_history.dart';

/// Session History Model for JSON serialization
class SessionHistoryModel extends SessionHistory {
  const SessionHistoryModel({
    required super.startDate,
    required super.endDate,
    required super.sessions,
    required super.intensityMap,
    required super.statistics,
    super.filters,
  });

  factory SessionHistoryModel.fromJson(Map<String, dynamic> json) {
    return SessionHistoryModel(
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      sessions: (json['sessions'] as List<dynamic>)
          .map(
            (item) =>
                HistoricalSessionModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      intensityMap: (json['intensity_map'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value as int),
      ),
      statistics: HistoryStatisticsModel.fromJson(
        json['statistics'] as Map<String, dynamic>,
      ),
      filters: json['filters'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'sessions': sessions
          .map(
            (s) => HistoricalSessionModel.fromEntity(
              s as HistoricalSession,
            ).toJson(),
          )
          .toList(),
      'intensity_map': intensityMap,
      'statistics': HistoryStatisticsModel.fromEntity(
        statistics as HistoryStatistics,
      ).toJson(),
      'filters': filters,
    };
  }
}

/// Historical Session Model
class HistoricalSessionModel extends HistoricalSession {
  const HistoricalSessionModel({
    required super.id,
    required super.subjectId,
    required super.subjectName,
    required super.subjectColor,
    required super.scheduledDate,
    required super.scheduledStartTime,
    required super.scheduledEndTime,
    super.actualStartTime,
    super.actualEndTime,
    required super.durationMinutes,
    super.pointsEarned,
    super.mood,
    super.completionPercentage,
    super.userNotes,
    required super.sessionType,
    super.contentTitle,
    required super.status,
  });

  factory HistoricalSessionModel.fromJson(Map<String, dynamic> json) {
    return HistoricalSessionModel(
      id: json['id'] as String,
      subjectId: json['subject_id'] as String,
      subjectName: json['subject_name'] as String,
      subjectColor: json['subject_color'] as String,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      scheduledStartTime: json['scheduled_start_time'] as String,
      scheduledEndTime: json['scheduled_end_time'] as String,
      actualStartTime: json['actual_start_time'] != null
          ? DateTime.parse(json['actual_start_time'] as String)
          : null,
      actualEndTime: json['actual_end_time'] != null
          ? DateTime.parse(json['actual_end_time'] as String)
          : null,
      durationMinutes: json['duration_minutes'] as int,
      pointsEarned: json['points_earned'] as int? ?? 0,
      mood: json['mood'] as String?,
      completionPercentage: json['completion_percentage'] as int? ?? 100,
      userNotes: json['user_notes'] as String?,
      sessionType: json['session_type'] as String,
      contentTitle: json['content_title'] as String?,
      status: json['status'] as String,
    );
  }

  factory HistoricalSessionModel.fromEntity(HistoricalSession entity) {
    return HistoricalSessionModel(
      id: entity.id,
      subjectId: entity.subjectId,
      subjectName: entity.subjectName,
      subjectColor: entity.subjectColor,
      scheduledDate: entity.scheduledDate,
      scheduledStartTime: entity.scheduledStartTime,
      scheduledEndTime: entity.scheduledEndTime,
      actualStartTime: entity.actualStartTime,
      actualEndTime: entity.actualEndTime,
      durationMinutes: entity.durationMinutes,
      pointsEarned: entity.pointsEarned,
      mood: entity.mood,
      completionPercentage: entity.completionPercentage,
      userNotes: entity.userNotes,
      sessionType: entity.sessionType,
      contentTitle: entity.contentTitle,
      status: entity.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'subject_name': subjectName,
      'subject_color': subjectColor,
      'scheduled_date': scheduledDate.toIso8601String(),
      'scheduled_start_time': scheduledStartTime,
      'scheduled_end_time': scheduledEndTime,
      if (actualStartTime != null)
        'actual_start_time': actualStartTime!.toIso8601String(),
      if (actualEndTime != null)
        'actual_end_time': actualEndTime!.toIso8601String(),
      'duration_minutes': durationMinutes,
      'points_earned': pointsEarned,
      if (mood != null) 'mood': mood,
      'completion_percentage': completionPercentage,
      if (userNotes != null) 'user_notes': userNotes,
      'session_type': sessionType,
      if (contentTitle != null) 'content_title': contentTitle,
      'status': status,
    };
  }
}

/// History Statistics Model
class HistoryStatisticsModel extends HistoryStatistics {
  const HistoryStatisticsModel({
    required super.totalSessions,
    required super.totalMinutes,
    required super.totalHours,
    required super.totalPoints,
    required super.averageSessionDuration,
    required super.moodDistribution,
    required super.subjectBreakdown,
  });

  factory HistoryStatisticsModel.fromJson(Map<String, dynamic> json) {
    return HistoryStatisticsModel(
      totalSessions: json['total_sessions'] as int,
      totalMinutes: json['total_minutes'] as int,
      totalHours: (json['total_hours'] as num).toDouble(),
      totalPoints: json['total_points'] as int? ?? 0,
      averageSessionDuration: json['average_session_duration'] as int,
      moodDistribution: (json['mood_distribution'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value as int),
      ),
      subjectBreakdown: (json['subject_breakdown'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          SubjectStatsModel.fromJson(value as Map<String, dynamic>),
        ),
      ),
    );
  }

  factory HistoryStatisticsModel.fromEntity(HistoryStatistics entity) {
    return HistoryStatisticsModel(
      totalSessions: entity.totalSessions,
      totalMinutes: entity.totalMinutes,
      totalHours: entity.totalHours,
      totalPoints: entity.totalPoints,
      averageSessionDuration: entity.averageSessionDuration,
      moodDistribution: entity.moodDistribution,
      subjectBreakdown: entity.subjectBreakdown,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_sessions': totalSessions,
      'total_minutes': totalMinutes,
      'total_hours': totalHours,
      'total_points': totalPoints,
      'average_session_duration': averageSessionDuration,
      'mood_distribution': moodDistribution,
      'subject_breakdown': subjectBreakdown.map(
        (key, value) =>
            MapEntry(key, SubjectStatsModel.fromEntity(value).toJson()),
      ),
    };
  }
}

/// Subject Stats Model
class SubjectStatsModel extends SubjectStats {
  const SubjectStatsModel({
    required super.subjectId,
    required super.subjectName,
    required super.subjectColor,
    required super.sessionCount,
    required super.totalMinutes,
    required super.totalPoints,
  });

  factory SubjectStatsModel.fromJson(Map<String, dynamic> json) {
    return SubjectStatsModel(
      subjectId: json['subject_id'] as String,
      subjectName: json['subject_name'] as String,
      subjectColor: json['subject_color'] as String,
      sessionCount: json['session_count'] as int,
      totalMinutes: json['total_minutes'] as int,
      totalPoints: json['total_points'] as int? ?? 0,
    );
  }

  factory SubjectStatsModel.fromEntity(SubjectStats entity) {
    return SubjectStatsModel(
      subjectId: entity.subjectId,
      subjectName: entity.subjectName,
      subjectColor: entity.subjectColor,
      sessionCount: entity.sessionCount,
      totalMinutes: entity.totalMinutes,
      totalPoints: entity.totalPoints,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject_id': subjectId,
      'subject_name': subjectName,
      'subject_color': subjectColor,
      'session_count': sessionCount,
      'total_minutes': totalMinutes,
      'total_points': totalPoints,
    };
  }
}
