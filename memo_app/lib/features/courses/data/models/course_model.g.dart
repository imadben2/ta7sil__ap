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
      thumbnailFullUrl: json['thumbnail_full_url'] as String?,
      promoVideoUrl: json['promo_video_url'] as String?,
      shortDescriptionAr: json['short_description_ar'] as String?,
      whatYouWillLearn: (json['what_you_will_learn'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      requirements: (json['requirements'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      targetAudience: (json['target_audience'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      priceDzd: (json['price_dzd'] as num).toInt(),
      originalPriceDzd: (json['original_price_dzd'] as num?)?.toInt(),
      discountPercentage: (json['discount_percentage'] as num?)?.toDouble(),
      level: json['level'] as String?,
      language: json['language'] as String?,
      isFreeAccess: json['is_free_access'] as bool? ?? false,
      isPublished: json['is_published'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      certificateAvailable: json['certificate_available'] as bool? ?? true,
      totalDurationMinutes: (json['duration_minutes'] as num?)?.toInt(),
      totalModules: (json['modules_count'] as num?)?.toInt(),
      totalLessons: (json['lessons_count'] as num?)?.toInt(),
      averageRating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['reviews_count'] as num?)?.toInt() ?? 0,
      totalStudents: (json['students_enrolled'] as num?)?.toInt() ?? 0,
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
      instructorName: json['instructor_name'] as String?,
      instructorBio: json['instructor_bio'] as String?,
      instructorAvatar: json['instructor_avatar'] as String?,
      subjectNameAr: json['subject_name'] as String?,
      subjectNameEn: json['subjectNameEn'] as String?,
      subjectNameFr: json['subjectNameFr'] as String?,
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
      'thumbnail_full_url': instance.thumbnailFullUrl,
      'promo_video_url': instance.promoVideoUrl,
      'short_description_ar': instance.shortDescriptionAr,
      'what_you_will_learn': instance.whatYouWillLearn,
      'requirements': instance.requirements,
      'target_audience': instance.targetAudience,
      'price_dzd': instance.priceDzd,
      'original_price_dzd': instance.originalPriceDzd,
      'discount_percentage': instance.discountPercentage,
      'level': instance.level,
      'language': instance.language,
      'is_free_access': instance.isFreeAccess,
      'is_published': instance.isPublished,
      'is_featured': instance.isFeatured,
      'certificate_available': instance.certificateAvailable,
      'duration_minutes': instance.totalDurationMinutes,
      'modules_count': instance.totalModules,
      'lessons_count': instance.totalLessons,
      'rating': instance.averageRating,
      'reviews_count': instance.totalReviews,
      'students_enrolled': instance.totalStudents,
      'view_count': instance.viewCount,
      'instructor_name': instance.instructorName,
      'instructor_bio': instance.instructorBio,
      'instructor_avatar': instance.instructorAvatar,
      'subject_name': instance.subjectNameAr,
      'subjectNameEn': instance.subjectNameEn,
      'subjectNameFr': instance.subjectNameFr,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'published_at': instance.publishedAt?.toIso8601String(),
      'modules': instance.modules?.map((e) => e.toJson()).toList(),
      'has_access': instance.hasAccess,
    };
