// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_progress_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseProgressModel _$CourseProgressModelFromJson(Map<String, dynamic> json) =>
    CourseProgressModel(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      courseId: (json['course_id'] as num).toInt(),
      completedLessons: (json['completed_lessons'] as num).toInt(),
      totalLessons: (json['total_lessons'] as num).toInt(),
      completedQuizzes: (json['completed_quizzes'] as num?)?.toInt(),
      totalQuizzes: (json['total_quizzes'] as num?)?.toInt(),
      progressPercentage: (json['progress_percentage'] as num).toDouble(),
      totalWatchTimeMinutes:
          (json['total_watch_time_minutes'] as num?)?.toInt(),
      lastAccessedAt: json['last_accessed_at'] == null
          ? null
          : DateTime.parse(json['last_accessed_at'] as String),
      status: json['status'] as String?,
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$CourseProgressModelToJson(
        CourseProgressModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'course_id': instance.courseId,
      'completed_lessons': instance.completedLessons,
      'total_lessons': instance.totalLessons,
      'completed_quizzes': instance.completedQuizzes,
      'total_quizzes': instance.totalQuizzes,
      'progress_percentage': instance.progressPercentage,
      'total_watch_time_minutes': instance.totalWatchTimeMinutes,
      'last_accessed_at': instance.lastAccessedAt?.toIso8601String(),
      'status': instance.status,
      'completed_at': instance.completedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
