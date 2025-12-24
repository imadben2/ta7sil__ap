import 'package:equatable/equatable.dart';
import 'course_lesson_entity.dart';

/// Course Module Entity - يمثل فصل/وحدة في الدورة
class CourseModuleEntity extends Equatable {
  final int id;
  final int courseId;
  final String titleAr;
  final String? titleEn;
  final String? titleFr;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? descriptionFr;
  final int order;
  final int? totalLessons;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Lessons in this module
  final List<CourseLessonEntity>? lessons;

  const CourseModuleEntity({
    required this.id,
    required this.courseId,
    required this.titleAr,
    this.titleEn,
    this.titleFr,
    this.descriptionAr,
    this.descriptionEn,
    this.descriptionFr,
    required this.order,
    this.totalLessons,
    this.isPublished = true,
    required this.createdAt,
    required this.updatedAt,
    this.lessons,
  });

  /// عنوان الوحدة مع رقمها
  String get titleWithNumber => 'الوحدة $order: $titleAr';

  /// هل الوحدة فارغة؟
  bool get isEmpty => totalLessons == null || totalLessons == 0;

  /// هل الوحدة تحتوي على دروس؟
  bool get hasLessons => lessons != null && lessons!.isNotEmpty;

  CourseModuleEntity copyWith({
    int? id,
    int? courseId,
    String? titleAr,
    String? titleEn,
    String? titleFr,
    String? descriptionAr,
    String? descriptionEn,
    String? descriptionFr,
    int? order,
    int? totalLessons,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<CourseLessonEntity>? lessons,
  }) {
    return CourseModuleEntity(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      titleFr: titleFr ?? this.titleFr,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionFr: descriptionFr ?? this.descriptionFr,
      order: order ?? this.order,
      totalLessons: totalLessons ?? this.totalLessons,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lessons: lessons ?? this.lessons,
    );
  }

  @override
  List<Object?> get props => [
    id,
    courseId,
    titleAr,
    titleEn,
    titleFr,
    descriptionAr,
    descriptionEn,
    descriptionFr,
    order,
    totalLessons,
    isPublished,
    createdAt,
    updatedAt,
    lessons,
  ];
}
