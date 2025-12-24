import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/course_lesson_entity.dart';
import 'lesson_attachment_model.dart';

part 'course_lesson_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CourseLessonModel {
  final int id;
  @JsonKey(name: 'course_module_id')
  final int courseModuleId;
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
  @JsonKey(name: 'video_url')
  final String? videoUrl;
  @JsonKey(name: 'video_type')
  final String? videoType;
  @JsonKey(name: 'video_duration_seconds')
  final int videoDurationSeconds;
  final int order;
  @JsonKey(name: 'is_published')
  final bool isPublished;
  @JsonKey(name: 'is_free_preview')
  final bool isFreePreview;
  @JsonKey(name: 'has_quiz')
  final bool hasQuiz;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  final List<LessonAttachmentModel>? attachments;

  const CourseLessonModel({
    required this.id,
    required this.courseModuleId,
    required this.titleAr,
    this.titleEn,
    this.titleFr,
    this.descriptionAr,
    this.descriptionEn,
    this.descriptionFr,
    this.videoUrl,
    this.videoType,
    required this.videoDurationSeconds,
    required this.order,
    this.isPublished = true,
    this.isFreePreview = false,
    this.hasQuiz = false,
    required this.createdAt,
    required this.updatedAt,
    this.attachments,
  });

  factory CourseLessonModel.fromJson(Map<String, dynamic> json) =>
      _$CourseLessonModelFromJson(json);

  Map<String, dynamic> toJson() => _$CourseLessonModelToJson(this);

  CourseLessonEntity toEntity() {
    return CourseLessonEntity(
      id: id,
      courseModuleId: courseModuleId,
      titleAr: titleAr,
      titleEn: titleEn,
      titleFr: titleFr,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
      descriptionFr: descriptionFr,
      videoUrl: videoUrl,
      videoType: videoType,
      videoDurationSeconds: videoDurationSeconds,
      order: order,
      isPublished: isPublished,
      isFreePreview: isFreePreview,
      hasQuiz: hasQuiz,
      createdAt: createdAt,
      updatedAt: updatedAt,
      attachments: attachments?.map((a) => a.toEntity()).toList(),
    );
  }

  factory CourseLessonModel.fromEntity(CourseLessonEntity entity) {
    return CourseLessonModel(
      id: entity.id,
      courseModuleId: entity.courseModuleId,
      titleAr: entity.titleAr,
      titleEn: entity.titleEn,
      titleFr: entity.titleFr,
      descriptionAr: entity.descriptionAr,
      descriptionEn: entity.descriptionEn,
      descriptionFr: entity.descriptionFr,
      videoUrl: entity.videoUrl,
      videoType: entity.videoType,
      videoDurationSeconds: entity.videoDurationSeconds,
      order: entity.order,
      isPublished: entity.isPublished,
      isFreePreview: entity.isFreePreview,
      hasQuiz: entity.hasQuiz,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      attachments: entity.attachments
          ?.map((a) => LessonAttachmentModel.fromEntity(a))
          .toList(),
    );
  }
}
