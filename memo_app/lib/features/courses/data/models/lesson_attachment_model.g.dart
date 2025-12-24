// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_attachment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonAttachmentModel _$LessonAttachmentModelFromJson(
        Map<String, dynamic> json) =>
    LessonAttachmentModel(
      id: (json['id'] as num).toInt(),
      courseLessonId: (json['course_lesson_id'] as num).toInt(),
      fileNameAr: json['file_name_ar'] as String,
      fileNameEn: json['file_name_en'] as String?,
      fileNameFr: json['file_name_fr'] as String?,
      fileUrl: json['file_url'] as String,
      fileType: json['file_type'] as String,
      fileSizeKb: (json['file_size_kb'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$LessonAttachmentModelToJson(
        LessonAttachmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'course_lesson_id': instance.courseLessonId,
      'file_name_ar': instance.fileNameAr,
      'file_name_en': instance.fileNameEn,
      'file_name_fr': instance.fileNameFr,
      'file_url': instance.fileUrl,
      'file_type': instance.fileType,
      'file_size_kb': instance.fileSizeKb,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
