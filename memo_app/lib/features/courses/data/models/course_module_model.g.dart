// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_module_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseModuleModel _$CourseModuleModelFromJson(Map<String, dynamic> json) =>
    CourseModuleModel(
      id: (json['id'] as num).toInt(),
      courseId: (json['course_id'] as num).toInt(),
      titleAr: json['title_ar'] as String,
      titleEn: json['title_en'] as String?,
      titleFr: json['title_fr'] as String?,
      descriptionAr: json['description_ar'] as String?,
      descriptionEn: json['description_en'] as String?,
      descriptionFr: json['description_fr'] as String?,
      order: (json['order'] as num).toInt(),
      totalLessons: (json['total_lessons'] as num?)?.toInt(),
      isPublished: json['is_published'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lessons: (json['lessons'] as List<dynamic>?)
          ?.map((e) => CourseLessonModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CourseModuleModelToJson(CourseModuleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'course_id': instance.courseId,
      'title_ar': instance.titleAr,
      'title_en': instance.titleEn,
      'title_fr': instance.titleFr,
      'description_ar': instance.descriptionAr,
      'description_en': instance.descriptionEn,
      'description_fr': instance.descriptionFr,
      'order': instance.order,
      'total_lessons': instance.totalLessons,
      'is_published': instance.isPublished,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'lessons': instance.lessons?.map((e) => e.toJson()).toList(),
    };
