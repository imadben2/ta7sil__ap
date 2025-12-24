import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/lesson_attachment_entity.dart';

part 'lesson_attachment_model.g.dart';

@JsonSerializable()
class LessonAttachmentModel {
  final int id;
  @JsonKey(name: 'course_lesson_id')
  final int courseLessonId;
  @JsonKey(name: 'file_name_ar')
  final String fileNameAr;
  @JsonKey(name: 'file_name_en')
  final String? fileNameEn;
  @JsonKey(name: 'file_name_fr')
  final String? fileNameFr;
  @JsonKey(name: 'file_url')
  final String fileUrl;
  @JsonKey(name: 'file_type')
  final String fileType;
  @JsonKey(name: 'file_size_kb')
  final int fileSizeKb;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const LessonAttachmentModel({
    required this.id,
    required this.courseLessonId,
    required this.fileNameAr,
    this.fileNameEn,
    this.fileNameFr,
    required this.fileUrl,
    required this.fileType,
    required this.fileSizeKb,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LessonAttachmentModel.fromJson(Map<String, dynamic> json) =>
      _$LessonAttachmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$LessonAttachmentModelToJson(this);

  LessonAttachmentEntity toEntity() {
    return LessonAttachmentEntity(
      id: id,
      courseLessonId: courseLessonId,
      fileNameAr: fileNameAr,
      fileNameEn: fileNameEn,
      fileNameFr: fileNameFr,
      fileUrl: fileUrl,
      fileType: fileType,
      fileSizeKb: fileSizeKb,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory LessonAttachmentModel.fromEntity(LessonAttachmentEntity entity) {
    return LessonAttachmentModel(
      id: entity.id,
      courseLessonId: entity.courseLessonId,
      fileNameAr: entity.fileNameAr,
      fileNameEn: entity.fileNameEn,
      fileNameFr: entity.fileNameFr,
      fileUrl: entity.fileUrl,
      fileType: entity.fileType,
      fileSizeKb: entity.fileSizeKb,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
