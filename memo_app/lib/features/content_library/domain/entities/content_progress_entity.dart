import 'package:equatable/equatable.dart';

/// Progress status enum
enum ProgressStatus { notStarted, inProgress, completed }

/// Entity representing user's progress on a specific content
class ContentProgressEntity extends Equatable {
  final int id;
  final int userId;
  final int contentId;
  final ProgressStatus status;
  final double progressPercentage; // 0.0 to 1.0
  final int timeSpentMinutes;
  final DateTime? lastAccessedAt;
  final DateTime? completedAt;

  const ContentProgressEntity({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.status,
    this.progressPercentage = 0.0,
    this.timeSpentMinutes = 0,
    this.lastAccessedAt,
    this.completedAt,
  });

  /// Get status label in Arabic
  String get statusLabel {
    switch (status) {
      case ProgressStatus.notStarted:
        return 'لم يبدأ';
      case ProgressStatus.inProgress:
        return 'جاري';
      case ProgressStatus.completed:
        return 'مكتمل';
    }
  }

  /// Format progress percentage as "XX%"
  String get progressLabel =>
      '${(progressPercentage * 100).toStringAsFixed(0)}%';

  /// Format time spent as "Xس Yد"
  String get formattedTimeSpent {
    final hours = timeSpentMinutes ~/ 60;
    final minutes = timeSpentMinutes % 60;

    if (hours > 0) {
      return '${hours}س ${minutes}د';
    }
    return '${minutes}د';
  }

  /// Check if content is completed
  bool get isCompleted => status == ProgressStatus.completed;

  /// Check if content is in progress
  bool get isInProgress => status == ProgressStatus.inProgress;

  /// Check if content is not started
  bool get isNotStarted => status == ProgressStatus.notStarted;

  /// Copy with method for updates
  ContentProgressEntity copyWith({
    int? id,
    int? userId,
    int? contentId,
    ProgressStatus? status,
    double? progressPercentage,
    int? timeSpentMinutes,
    DateTime? lastAccessedAt,
    DateTime? completedAt,
  }) {
    return ContentProgressEntity(
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

  @override
  List<Object?> get props => [
    id,
    userId,
    contentId,
    status,
    progressPercentage,
    timeSpentMinutes,
    lastAccessedAt,
    completedAt,
  ];
}
