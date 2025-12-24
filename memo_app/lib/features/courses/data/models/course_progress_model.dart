import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/course_progress_entity.dart';

part 'course_progress_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CourseProgressModel {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'course_id')
  final int courseId;
  @JsonKey(name: 'completed_lessons')
  final int completedLessons;
  @JsonKey(name: 'total_lessons')
  final int totalLessons;
  @JsonKey(name: 'completed_quizzes')
  final int? completedQuizzes;
  @JsonKey(name: 'total_quizzes')
  final int? totalQuizzes;
  @JsonKey(name: 'progress_percentage')
  final double progressPercentage;
  @JsonKey(name: 'total_watch_time_minutes')
  final int? totalWatchTimeMinutes;
  @JsonKey(name: 'last_accessed_at')
  final DateTime? lastAccessedAt;
  @JsonKey(name: 'status')
  final String? status; // 'not_started', 'in_progress', 'completed'
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const CourseProgressModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.completedLessons,
    required this.totalLessons,
    this.completedQuizzes,
    this.totalQuizzes,
    required this.progressPercentage,
    this.totalWatchTimeMinutes,
    this.lastAccessedAt,
    this.status,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CourseProgressModel.fromJson(Map<String, dynamic> json) =>
      _$CourseProgressModelFromJson(json);

  Map<String, dynamic> toJson() => _$CourseProgressModelToJson(this);

  CourseProgressEntity toEntity() {
    return CourseProgressEntity(
      id: id,
      userId: userId,
      courseId: courseId,
      completedLessonsCount: completedLessons,
      totalLessonsCount: totalLessons,
      completionPercentage: progressPercentage,
      lastAccessedAt: lastAccessedAt,
      lastLessonId: null, // Not provided by backend
      lastLessonTitle: null, // Not provided by backend
      lastModuleId: null, // Not provided by backend
      isExplicitlyCompleted: status == 'completed',
      completedAt: completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory CourseProgressModel.fromEntity(CourseProgressEntity entity) {
    String statusValue = 'not_started';
    if (entity.isExplicitlyCompleted) {
      statusValue = 'completed';
    } else if (entity.completedLessonsCount > 0) {
      statusValue = 'in_progress';
    }

    return CourseProgressModel(
      id: entity.id,
      userId: entity.userId,
      courseId: entity.courseId,
      completedLessons: entity.completedLessonsCount,
      totalLessons: entity.totalLessonsCount,
      completedQuizzes: 0,
      totalQuizzes: 0,
      progressPercentage: entity.completionPercentage,
      totalWatchTimeMinutes: 0,
      lastAccessedAt: entity.lastAccessedAt,
      status: statusValue,
      completedAt: entity.completedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
