import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/course_module_entity.dart';
import 'course_lesson_model.dart';

part 'course_module_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CourseModuleModel {
  final int id;
  @JsonKey(name: 'course_id')
  final int courseId;
  @JsonKey(name: 'title_ar')
  final String titleAr;
  @JsonKey(name: 'title_en')
  final String? titleEn;
  @JsonKey(name: 'title_fr')
  final String? titleFr;
  @JsonKey(name: 'description_ar')
  final String? descriptionAr;
  @JsonKey(name: 'description_en')
  final String? descriptionEn;
  @JsonKey(name: 'description_fr')
  final String? descriptionFr;
  final int order;
  @JsonKey(name: 'total_lessons')
  final int? totalLessons;
  @JsonKey(name: 'is_published')
  final bool isPublished;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  final List<CourseLessonModel>? lessons;

  const CourseModuleModel({
    required this.id,
    required this.courseId,
    required this.titleAr,
    this.titleEn,
    this.titleFr,
    this.descriptionAr,
    this.descriptionEn,
    this.descriptionFr,
    required this.order,
    required this.totalLessons,
    this.isPublished = true,
    required this.createdAt,
    required this.updatedAt,
    this.lessons,
  });

  factory CourseModuleModel.fromJson(Map<String, dynamic> json) =>
      _$CourseModuleModelFromJson(json);

  Map<String, dynamic> toJson() => _$CourseModuleModelToJson(this);

  CourseModuleEntity toEntity() {
    return CourseModuleEntity(
      id: id,
      courseId: courseId,
      titleAr: titleAr,
      titleEn: titleEn,
      titleFr: titleFr,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
      descriptionFr: descriptionFr,
      order: order,
      totalLessons: totalLessons,
      isPublished: isPublished,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lessons: lessons?.map((l) => l.toEntity()).toList(),
    );
  }

  factory CourseModuleModel.fromEntity(CourseModuleEntity entity) {
    return CourseModuleModel(
      id: entity.id,
      courseId: entity.courseId,
      titleAr: entity.titleAr,
      titleEn: entity.titleEn,
      titleFr: entity.titleFr,
      descriptionAr: entity.descriptionAr,
      descriptionEn: entity.descriptionEn,
      descriptionFr: entity.descriptionFr,
      order: entity.order,
      totalLessons: entity.totalLessons,
      isPublished: entity.isPublished,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lessons: entity.lessons
          ?.map((l) => CourseLessonModel.fromEntity(l))
          .toList(),
    );
  }
}
