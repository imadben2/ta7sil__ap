// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_lesson_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseLessonModel _$CourseLessonModelFromJson(Map<String, dynamic> json) =>
    CourseLessonModel(
      id: (json['id'] as num).toInt(),
      courseModuleId: (json['course_module_id'] as num).toInt(),
      titleAr: json['title_ar'] as String,
      titleEn: json['title_en'] as String?,
      titleFr: json['title_fr'] as String?,
      descriptionAr: json['description_ar'] as String?,
      descriptionEn: json['description_en'] as String?,
      descriptionFr: json['description_fr'] as String?,
      videoUrl: json['video_url'] as String?,
      videoType: json['video_type'] as String?,
      videoDurationSeconds: (json['video_duration_seconds'] as num).toInt(),
      order: (json['order'] as num).toInt(),
      isPublished: json['is_published'] as bool? ?? true,
      isFreePreview: json['is_free_preview'] as bool? ?? false,
      hasQuiz: json['has_quiz'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map(
              (e) => LessonAttachmentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CourseLessonModelToJson(CourseLessonModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'course_module_id': instance.courseModuleId,
      'title_ar': instance.titleAr,
      'title_en': instance.titleEn,
      'title_fr': instance.titleFr,
      'description_ar': instance.descriptionAr,
      'description_en': instance.descriptionEn,
      'description_fr': instance.descriptionFr,
      'video_url': instance.videoUrl,
      'video_type': instance.videoType,
      'video_duration_seconds': instance.videoDurationSeconds,
      'order': instance.order,
      'is_published': instance.isPublished,
      'is_free_preview': instance.isFreePreview,
      'has_quiz': instance.hasQuiz,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'attachments': instance.attachments?.map((e) => e.toJson()).toList(),
    };
