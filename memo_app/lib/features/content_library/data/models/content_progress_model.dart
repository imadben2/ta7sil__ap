import '../../domain/entities/content_progress_entity.dart';

/// Data model for ContentProgress that extends ContentProgressEntity
class ContentProgressModel extends ContentProgressEntity {
  const ContentProgressModel({
    required super.id,
    required super.userId,
    required super.contentId,
    required super.status,
    super.progressPercentage = 0.0,
    super.timeSpentMinutes = 0,
    super.lastAccessedAt,
    super.completedAt,
  });

  /// Create ContentProgressModel from JSON
  factory ContentProgressModel.fromJson(Map<String, dynamic> json) {
    return ContentProgressModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      contentId: json['content_id'] as int,
      status: _parseProgressStatus(json['status'] as String?),
      progressPercentage: _parseDouble(json['progress_percentage']) ?? 0.0,
      timeSpentMinutes: json['time_spent_minutes'] as int? ?? 0,
      lastAccessedAt: _parseDateTime(json['last_accessed_at']),
      completedAt: _parseDateTime(json['completed_at']),
    );
  }

  /// Convert ContentProgressModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content_id': contentId,
      'status': _progressStatusToString(status),
      'progress_percentage': progressPercentage,
      'time_spent_minutes': timeSpentMinutes,
      'last_accessed_at': lastAccessedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  /// Create ContentProgressModel from ContentProgressEntity
  factory ContentProgressModel.fromEntity(ContentProgressEntity entity) {
    return ContentProgressModel(
      id: entity.id,
      userId: entity.userId,
      contentId: entity.contentId,
      status: entity.status,
      progressPercentage: entity.progressPercentage,
      timeSpentMinutes: entity.timeSpentMinutes,
      lastAccessedAt: entity.lastAccessedAt,
      completedAt: entity.completedAt,
    );
  }

  /// Parse progress status from string
  static ProgressStatus _parseProgressStatus(String? status) {
    if (status == null) return ProgressStatus.notStarted;
    switch (status.toLowerCase()) {
      case 'not_started':
      case 'notstarted':
        return ProgressStatus.notStarted;
      case 'in_progress':
      case 'inprogress':
        return ProgressStatus.inProgress;
      case 'completed':
        return ProgressStatus.completed;
      default:
        return ProgressStatus.notStarted;
    }
  }

  /// Convert progress status to string
  static String _progressStatusToString(ProgressStatus status) {
    switch (status) {
      case ProgressStatus.notStarted:
        return 'not_started';
      case ProgressStatus.inProgress:
        return 'in_progress';
      case ProgressStatus.completed:
        return 'completed';
    }
  }

  /// Helper method to safely parse double values
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Helper method to parse DateTime from string
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Create ContentProgressModel from V1 API /v1/progress/content/{id} response
  /// Note: API returns time_spent_seconds, we convert to minutes
  factory ContentProgressModel.fromApiJson(
    Map<String, dynamic> json,
    int contentId,
  ) {
    final progress = json['progress'] as int? ?? 0;
    final isCompleted = json['is_completed'] as bool? ?? false;
    final timeSpentSeconds = json['time_spent_seconds'] as int? ?? 0;

    return ContentProgressModel(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      contentId: contentId,
      status: isCompleted
          ? ProgressStatus.completed
          : progress > 0
              ? ProgressStatus.inProgress
              : ProgressStatus.notStarted,
      progressPercentage: progress.toDouble(),
      timeSpentMinutes: (timeSpentSeconds / 60).round(),
      lastAccessedAt: _parseDateTime(json['last_accessed_at']),
      completedAt: _parseDateTime(json['completed_at']),
    );
  }

  /// Create empty/default progress for content that hasn't been started
  factory ContentProgressModel.empty(int contentId) {
    return ContentProgressModel(
      id: 0,
      userId: 0,
      contentId: contentId,
      status: ProgressStatus.notStarted,
      progressPercentage: 0.0,
      timeSpentMinutes: 0,
    );
  }

  /// Copy with method
  ContentProgressModel copyWith({
    int? id,
    int? userId,
    int? contentId,
    ProgressStatus? status,
    double? progressPercentage,
    int? timeSpentMinutes,
    DateTime? lastAccessedAt,
    DateTime? completedAt,
  }) {
    return ContentProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contentId: contentId ?? this.contentId,
      status: status ?? this.status,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      timeSpentMinutes: timeSpentMinutes ?? this.timeSpentMinutes,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
