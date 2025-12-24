import 'package:equatable/equatable.dart';

/// Lesson Progress Entity - يمثل تقدم الطالب في درس معين
class LessonProgressEntity extends Equatable {
  final int id;
  final int userId;
  final int courseLessonId;
  final int watchTimeSeconds;
  final int totalDurationSeconds;
  final double progressPercentage; // 0.0 - 100.0
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LessonProgressEntity({
    required this.id,
    required this.userId,
    required this.courseLessonId,
    required this.watchTimeSeconds,
    required this.totalDurationSeconds,
    required this.progressPercentage,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// هل الدرس بدأ؟
  bool get hasStarted => watchTimeSeconds > 0;

  /// النسبة المنسقة (مثال: "75%")
  String get formattedPercentage => '${progressPercentage.toStringAsFixed(0)}%';

  /// الوقت المشاهد المنسق (مثال: "15:30")
  String get formattedWatchTime {
    final minutes = watchTimeSeconds ~/ 60;
    final seconds = watchTimeSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// المدة الكاملة المنسقة (مثال: "30:00")
  String get formattedTotalDuration {
    final minutes = totalDurationSeconds ~/ 60;
    final seconds = totalDurationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// نص التقدم (مثال: "15:30 / 30:00")
  String get progressText => '$formattedWatchTime / $formattedTotalDuration';

  /// الوقت المتبقي بالثواني
  int get remainingSeconds => totalDurationSeconds - watchTimeSeconds;

  /// الوقت المتبقي المنسق
  String get formattedRemainingTime {
    if (remainingSeconds <= 0) return '0:00';
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// هل تم مشاهدة 90% من الدرس؟ (عتبة الإكمال)
  bool get isAlmostCompleted => progressPercentage >= 90.0;

  LessonProgressEntity copyWith({
    int? id,
    int? userId,
    int? courseLessonId,
    int? watchTimeSeconds,
    int? totalDurationSeconds,
    double? progressPercentage,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LessonProgressEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseLessonId: courseLessonId ?? this.courseLessonId,
      watchTimeSeconds: watchTimeSeconds ?? this.watchTimeSeconds,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    courseLessonId,
    watchTimeSeconds,
    totalDurationSeconds,
    progressPercentage,
    isCompleted,
    completedAt,
    createdAt,
    updatedAt,
  ];
}
