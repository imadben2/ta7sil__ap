import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/course_entity.dart';
import 'course_module_model.dart';

part 'course_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CourseModel {
  final int id;
  @JsonKey(name: 'subject_id')
  final int subjectId;
  @JsonKey(name: 'teacher_id')
  final int? teacherId;
  @JsonKey(name: 'title_ar')
  final String titleAr;
  @JsonKey(name: 'title_en')
  final String? titleEn;
  @JsonKey(name: 'title_fr')
  final String? titleFr;
  final String? slug;
  @JsonKey(name: 'description_ar')
  final String? descriptionAr;
  @JsonKey(name: 'description_en')
  final String? descriptionEn;
  @JsonKey(name: 'description_fr')
  final String? descriptionFr;
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @JsonKey(name: 'promo_video_url')
  final String? promoVideoUrl;
  @JsonKey(name: 'price_dzd')
  final int priceDzd;
  @JsonKey(name: 'original_price_dzd')
  final int? originalPriceDzd;
  @JsonKey(name: 'discount_percentage')
  final double? discountPercentage;
  final String? level;
  final String? language;
  @JsonKey(name: 'is_free_access')
  final bool isFreeAccess;
  @JsonKey(name: 'is_published')
  final bool isPublished;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @JsonKey(name: 'total_duration_minutes')
  final int? totalDurationMinutes;
  @JsonKey(name: 'total_modules')
  final int? totalModules;
  @JsonKey(name: 'total_lessons')
  final int? totalLessons;
  @JsonKey(name: 'average_rating')
  final double averageRating;
  @JsonKey(name: 'total_reviews')
  final int totalReviews;
  @JsonKey(name: 'total_students')
  final int totalStudents;
  @JsonKey(name: 'instructor_name')
  final String? instructorName;
  @JsonKey(name: 'instructor_bio')
  final String? instructorBio;
  @JsonKey(name: 'instructor_avatar')
  final String? instructorAvatar;
  @JsonKey(name: 'subject_name_ar')
  final String? subjectNameAr;
  @JsonKey(name: 'subject_name_en')
  final String? subjectNameEn;
  @JsonKey(name: 'subject_name_fr')
  final String? subjectNameFr;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'published_at')
  final DateTime? publishedAt;
  final List<CourseModuleModel>? modules;
  @JsonKey(name: 'has_access')
  final bool? hasAccess;

  const CourseModel({
    required this.id,
    required this.subjectId,
    this.teacherId,
    required this.titleAr,
    this.titleEn,
    this.titleFr,
    this.slug,
    this.descriptionAr,
    this.descriptionEn,
    this.descriptionFr,
    this.thumbnailUrl,
    this.promoVideoUrl,
    required this.priceDzd,
    this.originalPriceDzd,
    this.discountPercentage,
    this.level,
    this.language,
    this.isFreeAccess = false,
    this.isPublished = false,
    this.isFeatured = false,
    this.totalDurationMinutes,
    this.totalModules,
    this.totalLessons,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.totalStudents = 0,
    this.instructorName,
    this.instructorBio,
    this.instructorAvatar,
    this.subjectNameAr,
    this.subjectNameEn,
    this.subjectNameFr,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
    this.modules,
    this.hasAccess,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) =>
      _$CourseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CourseModelToJson(this);

  CourseEntity toEntity() {
    return CourseEntity(
      id: id,
      titleAr: titleAr,
      titleEn: titleEn,
      titleFr: titleFr,
      slug: slug ?? '',
      descriptionAr: descriptionAr ?? '',
      descriptionEn: descriptionEn,
      descriptionFr: descriptionFr,
      thumbnailUrl: thumbnailUrl,
      trailerVideoUrl: promoVideoUrl,
      priceDzd: priceDzd,
      originalPriceDzd: originalPriceDzd,
      discountPercentage: discountPercentage,
      isFree: isFreeAccess,
      requiresSubscription: !isFreeAccess,
      instructorName: instructorName ?? '',
      instructorBioAr: instructorBio,
      instructorPhotoUrl: instructorAvatar,
      totalModules: totalModules ?? 0,
      totalLessons: totalLessons ?? 0,
      totalDurationMinutes: totalDurationMinutes ?? 0,
      isPublished: isPublished,
      isFeatured: isFeatured,
      viewCount: 0,
      enrollmentCount: totalStudents,
      averageRating: averageRating,
      totalReviews: totalReviews,
      subjectId: subjectId,
      subjectName: subjectNameAr ?? '',
      academicYearId: null,
      level: level,
      tags: null,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory CourseModel.fromEntity(CourseEntity entity) {
    return CourseModel(
      id: entity.id,
      subjectId: entity.subjectId ?? 0,
      teacherId: 0,
      titleAr: entity.titleAr,
      titleEn: entity.titleEn,
      titleFr: entity.titleFr,
      slug: entity.slug.isNotEmpty ? entity.slug : null,
      descriptionAr: entity.descriptionAr.isNotEmpty
          ? entity.descriptionAr
          : null,
      descriptionEn: entity.descriptionEn,
      descriptionFr: entity.descriptionFr,
      thumbnailUrl: entity.thumbnailUrl,
      promoVideoUrl: entity.trailerVideoUrl,
      priceDzd: entity.priceDzd,
      originalPriceDzd: entity.originalPriceDzd,
      discountPercentage: entity.discountPercentage,
      level: entity.level,
      language: 'ar',
      isFreeAccess: entity.isFree,
      isPublished: entity.isPublished,
      isFeatured: entity.isFeatured,
      totalDurationMinutes: entity.totalDurationMinutes,
      totalModules: entity.totalModules,
      totalLessons: entity.totalLessons,
      averageRating: entity.averageRating,
      totalReviews: entity.totalReviews,
      totalStudents: entity.enrollmentCount,
      instructorName: entity.instructorName.isNotEmpty
          ? entity.instructorName
          : null,
      instructorBio: entity.instructorBioAr,
      instructorAvatar: entity.instructorPhotoUrl,
      subjectNameAr: entity.subjectName,
      subjectNameEn: null,
      subjectNameFr: null,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      publishedAt: null,
      modules: null,
      hasAccess: null,
    );
  }
}
