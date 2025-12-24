import '../../domain/entities/schedule.dart';
import 'study_session_model.dart';

/// Data model for Schedule with JSON serialization
class ScheduleModel {
  final String id;
  final String userId;
  final String startDate; // "2025-11-10"
  final String endDate; // "2025-11-17"
  final List<StudySessionModel> sessions;
  final bool isActive;
  final String createdAt; // ISO 8601 format

  ScheduleModel({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.sessions,
    this.isActive = true,
    required this.createdAt,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    // Handle both 'sessions' and 'study_sessions' keys from API
    // Laravel converts studySessions relation to study_sessions in JSON
    final sessionsJson = json['sessions'] ?? json['study_sessions'] ?? [];

    return ScheduleModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      sessions: (sessionsJson as List<dynamic>)
          .map(
            (session) =>
                StudySessionModel.fromJson(session as Map<String, dynamic>),
          )
          .toList(),
      isActive: json['is_active'] as bool? ?? json['status'] == 'active',
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'start_date': startDate,
      'end_date': endDate,
      'sessions': sessions.map((session) => session.toJson()).toList(),
      'is_active': isActive,
      'created_at': createdAt,
    };
  }

  Schedule toEntity() {
    return Schedule(
      id: id,
      userId: userId,
      startDate: DateTime.parse(startDate),
      endDate: DateTime.parse(endDate),
      sessions: sessions.map((model) => model.toEntity()).toList(),
      isActive: isActive,
      createdAt: DateTime.parse(createdAt),
    );
  }

  factory ScheduleModel.fromEntity(Schedule entity) {
    return ScheduleModel(
      id: entity.id,
      userId: entity.userId,
      startDate: entity.startDate.toIso8601String().split('T')[0],
      endDate: entity.endDate.toIso8601String().split('T')[0],
      sessions: entity.sessions
          .map((session) => StudySessionModel.fromEntity(session))
          .toList(),
      isActive: entity.isActive,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }

  /// Create a schedule with only sessions for a specific date
  ScheduleModel filterByDate(DateTime date) {
    final dateString = date.toIso8601String().split('T')[0];
    final filteredSessions = sessions
        .where((session) => session.scheduledDate == dateString)
        .toList();

    return ScheduleModel(
      id: id,
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      sessions: filteredSessions,
      isActive: isActive,
      createdAt: createdAt,
    );
  }

  /// Get statistics for the schedule
  Map<String, dynamic> getStatistics() {
    final totalSessions = sessions.length;
    final completedSessions = sessions
        .where((s) => s.status == 'completed')
        .length;
    final totalMinutes = sessions.fold<int>(
      0,
      (sum, session) => sum + session.durationMinutes,
    );

    return {
      'total_sessions': totalSessions,
      'completed_sessions': completedSessions,
      'completion_rate': totalSessions > 0
          ? (completedSessions / totalSessions * 100).toStringAsFixed(1)
          : '0.0',
      'total_hours': (totalMinutes / 60).toStringAsFixed(1),
    };
  }
}
