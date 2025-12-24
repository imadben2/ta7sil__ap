// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseModel _$CourseModelFromJson(Map<String, dynamic> json) => CourseModel(
      id: (json['id'] as num).toInt(),
      subjectId: (json['subject_id'] as num).toInt(),
      teacherId: (json['teacher_id'] as num?)?.toInt(),
      titleAr: json['title_ar'] as String,
      titleEn: json['title_en'] as String?,
      titleFr: json['title_fr'] as String?,
      slug: json['slug'] as String?,
      descriptionAr: json['description_ar'] as String?,
      descriptionEn: json['description_en'] as String?,
      descriptionFr: json['description_fr'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      promoVideoUrl: json['promo_video_url'] as String?,
      priceDzd: (json['price_dzd'] as num).toInt(),
      originalPriceDzd: (json['original_price_dzd'] as num?)?.toInt(),
      discountPercentage: (json['discount_percentage'] as num?)?.toDouble(),
      level: json['level'] as String?,
      language: json['language'] as String?,
      isFreeAccess: json['is_free_access'] as bool? ?? false,
      isPublished: json['is_published'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      totalDurationMinutes: (json['total_duration_minutes'] as num?)?.toInt(),
      totalModules: (json['total_modules'] as num?)?.toInt(),
      totalLessons: (json['total_lessons'] as num?)?.toInt(),
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      totalStudents: (json['total_students'] as num?)?.toInt() ?? 0,
      instructorName: json['instructor_name'] as String?,
      instructorBio: json['instructor_bio'] as String?,
      instructorAvatar: json['instructor_avatar'] as String?,
      subjectNameAr: json['subject_name_ar'] as String?,
      subjectNameEn: json['subject_name_en'] as String?,
      subjectNameFr: json['subject_name_fr'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      publishedAt: json['published_at'] == null
          ? null
          : DateTime.parse(json['published_at'] as String),
      modules: (json['modules'] as List<dynamic>?)
          ?.map((e) => CourseModuleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasAccess: json['has_access'] as bool?,
    );

Map<String, dynamic> _$CourseModelToJson(CourseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subject_id': instance.subjectId,
      'teacher_id': instance.teacherId,
      'title_ar': instance.titleAr,
      'title_en': instance.titleEn,
      'title_fr': instance.titleFr,
      'slug': instance.slug,
      'description_ar': instance.descriptionAr,
      'description_en': instance.descriptionEn,
      'description_fr': instance.descriptionFr,
      'thumbnail_url': instance.thumbnailUrl,
      'promo_video_url': instance.promoVideoUrl,
      'price_dzd': instance.priceDzd,
      'original_price_dzd': instance.originalPriceDzd,
      'discount_percentage': instance.discountPercentage,
      'level': instance.level,
      'language': instance.language,
      'is_free_access': instance.isFreeAccess,
      'is_published': instance.isPublished,
      'is_featured': instance.isFeatured,
      'total_duration_minutes': instance.totalDurationMinutes,
      'total_modules': instance.totalModules,
      'total_lessons': instance.totalLessons,
      'average_rating': instance.averageRating,
      'total_reviews': instance.totalReviews,
      'total_students': instance.totalStudents,
      'instructor_name': instance.instructorName,
      'instructor_bio': instance.instructorBio,
      'instructor_avatar': instance.instructorAvatar,
      'subject_name_ar': instance.subjectNameAr,
      'subject_name_en': instance.subjectNameEn,
      'subject_name_fr': instance.subjectNameFr,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'published_at': instance.publishedAt?.toIso8601String(),
      'modules': instance.modules?.map((e) => e.toJson()).toList(),
      'has_access': instance.hasAccess,
    };
