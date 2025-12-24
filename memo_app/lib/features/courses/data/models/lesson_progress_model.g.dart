// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_progress_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonProgressModel _$LessonProgressModelFromJson(Map<String, dynamic> json) =>
    LessonProgressModel(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      courseLessonId: (json['course_lesson_id'] as num).toInt(),
      watchTimeSeconds: (json['watch_time_seconds'] as num).toInt(),
      videoDurationSeconds: (json['video_duration_seconds'] as num).toInt(),
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      lastPositionSeconds: (json['last_position_seconds'] as num).toInt(),
      lastWatchedAt: json['last_watched_at'] == null
          ? null
          : DateTime.parse(json['last_watched_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$LessonProgressModelToJson(
        LessonProgressModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'course_lesson_id': instance.courseLessonId,
      'watch_time_seconds': instance.watchTimeSeconds,
      'video_duration_seconds': instance.videoDurationSeconds,
      'is_completed': instance.isCompleted,
      'completed_at': instance.completedAt?.toIso8601String(),
      'last_position_seconds': instance.lastPositionSeconds,
      'last_watched_at': instance.lastWatchedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
