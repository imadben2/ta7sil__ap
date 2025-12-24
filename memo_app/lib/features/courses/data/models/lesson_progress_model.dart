import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/lesson_progress_entity.dart';

part 'lesson_progress_model.g.dart';

@JsonSerializable(explicitToJson: true)
class LessonProgressModel {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'course_lesson_id')
  final int courseLessonId;
  @JsonKey(name: 'watch_time_seconds')
  final int watchTimeSeconds;
  @JsonKey(name: 'video_duration_seconds')
  final int videoDurationSeconds;
  @JsonKey(name: 'is_completed')
  final bool isCompleted;
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  @JsonKey(name: 'last_position_seconds')
  final int lastPositionSeconds;
  @JsonKey(name: 'last_watched_at')
  final DateTime? lastWatchedAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const LessonProgressModel({
    required this.id,
    required this.userId,
    required this.courseLessonId,
    required this.watchTimeSeconds,
    required this.videoDurationSeconds,
    this.isCompleted = false,
    this.completedAt,
    required this.lastPositionSeconds,
    this.lastWatchedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LessonProgressModel.fromJson(Map<String, dynamic> json) =>
      _$LessonProgressModelFromJson(json);

  Map<String, dynamic> toJson() => _$LessonProgressModelToJson(this);

  // Calculate progress percentage
  double get progressPercentage {
    if (videoDurationSeconds == 0) return 0.0;
    return (watchTimeSeconds / videoDurationSeconds * 100).clamp(0.0, 100.0);
  }

  LessonProgressEntity toEntity() {
    return LessonProgressEntity(
      id: id,
      userId: userId,
      courseLessonId: courseLessonId,
      watchTimeSeconds: watchTimeSeconds,
      totalDurationSeconds: videoDurationSeconds,
      progressPercentage: progressPercentage,
      isCompleted: isCompleted,
      completedAt: completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory LessonProgressModel.fromEntity(LessonProgressEntity entity) {
    return LessonProgressModel(
      id: entity.id,
      userId: entity.userId,
      courseLessonId: entity.courseLessonId,
      watchTimeSeconds: entity.watchTimeSeconds,
      videoDurationSeconds: entity.totalDurationSeconds,
      isCompleted: entity.isCompleted,
      completedAt: entity.completedAt,
      lastPositionSeconds: entity.watchTimeSeconds,
      lastWatchedAt: entity.updatedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
