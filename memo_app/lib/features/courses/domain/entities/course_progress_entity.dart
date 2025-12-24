import 'package:equatable/equatable.dart';

/// Course Progress Entity - يمثل تقدم الطالب في دورة
class CourseProgressEntity extends Equatable {
  final int id;
  final int userId;
  final int courseId;
  final int completedLessonsCount;
  final int totalLessonsCount;
  final double completionPercentage; // 0.0 - 100.0
  final DateTime? lastAccessedAt;

  // Last Lesson Tracking - تتبع آخر درس تمت مشاهدته
  final int? lastLessonId;
  final String? lastLessonTitle;
  final int? lastModuleId;

  // Explicit Completion Tracking - تتبع الإكمال الصريح
  final bool isExplicitlyCompleted;
  final DateTime? completedAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  const CourseProgressEntity({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.completedLessonsCount,
    required this.totalLessonsCount,
    required this.completionPercentage,
    this.lastAccessedAt,
    this.lastLessonId,
    this.lastLessonTitle,
    this.lastModuleId,
    this.isExplicitlyCompleted = false,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// هل الدورة مكتملة؟ (يفضل الإكمال الصريح، أو 90% threshold)
  bool get isCompleted => isExplicitlyCompleted || completionPercentage >= 90.0;

  /// هل بدأ الطالب الدورة؟
  bool get hasStarted => completedLessonsCount > 0;

  /// هل يوجد درس أخير لمواصلة المشاهدة؟
  bool get hasLastLesson => lastLessonId != null;

  /// نص "واصل المشاهدة"
  String get continueWatchingText {
    if (lastLessonTitle != null) {
      return 'واصل: $lastLessonTitle';
    }
    return 'واصل المشاهدة';
  }

  /// نص تاريخ الإكمال المنسق
  String? get formattedCompletionDate {
    if (completedAt == null) return null;

    final date = completedAt!;
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// النسبة المنسقة (مثال: "75%")
  String get formattedPercentage =>
      '${completionPercentage.toStringAsFixed(0)}%';

  /// نص التقدم (مثال: "5 من 10 دروس")
  String get progressText =>
      '$completedLessonsCount من $totalLessonsCount دروس';

  /// عدد الدروس المتبقية
  int get remainingLessons => totalLessonsCount - completedLessonsCount;

  /// نص آخر وصول
  String get lastAccessedText {
    if (lastAccessedAt == null) return 'لم يتم الوصول';

    final now = DateTime.now();
    final difference = now.difference(lastAccessedAt!);

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inDays < 30) {
      return 'منذ ${(difference.inDays / 7).floor()} أسبوع';
    } else {
      return 'منذ ${(difference.inDays / 30).floor()} شهر';
    }
  }

  CourseProgressEntity copyWith({
    int? id,
    int? userId,
    int? courseId,
    int? completedLessonsCount,
    int? totalLessonsCount,
    double? completionPercentage,
    DateTime? lastAccessedAt,
    int? lastLessonId,
    String? lastLessonTitle,
    int? lastModuleId,
    bool? isExplicitlyCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseProgressEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      completedLessonsCount:
          completedLessonsCount ?? this.completedLessonsCount,
      totalLessonsCount: totalLessonsCount ?? this.totalLessonsCount,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      lastLessonId: lastLessonId ?? this.lastLessonId,
      lastLessonTitle: lastLessonTitle ?? this.lastLessonTitle,
      lastModuleId: lastModuleId ?? this.lastModuleId,
      isExplicitlyCompleted:
          isExplicitlyCompleted ?? this.isExplicitlyCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    courseId,
    completedLessonsCount,
    totalLessonsCount,
    completionPercentage,
    lastAccessedAt,
    lastLessonId,
    lastLessonTitle,
    lastModuleId,
    isExplicitlyCompleted,
    completedAt,
    createdAt,
    updatedAt,
  ];
}
