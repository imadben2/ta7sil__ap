import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/course_entity.dart';
import 'course_module_model.dart';
import '../../../../core/constants/api_constants.dart';

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
  @JsonKey(name: 'thumbnail_full_url')
  final String? thumbnailFullUrl;
  @JsonKey(name: 'promo_video_url')
  final String? promoVideoUrl;
  @JsonKey(name: 'short_description_ar')
  final String? shortDescriptionAr;
  @JsonKey(name: 'what_you_will_learn')
  final List<String>? whatYouWillLearn;
  final List<String>? requirements;
  @JsonKey(name: 'target_audience')
  final List<String>? targetAudience;
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
  @JsonKey(name: 'certificate_available')
  final bool certificateAvailable;
  @JsonKey(name: 'duration_minutes')
  final int? totalDurationMinutes;
  @JsonKey(name: 'modules_count')
  final int? totalModules;
  @JsonKey(name: 'lessons_count')
  final int? totalLessons;
  @JsonKey(name: 'rating')
  final double averageRating;
  @JsonKey(name: 'reviews_count')
  final int totalReviews;
  @JsonKey(name: 'students_enrolled')
  final int totalStudents;
  @JsonKey(name: 'view_count')
  final int viewCount;
  @JsonKey(name: 'instructor_name')
  final String? instructorName;
  @JsonKey(name: 'instructor_bio')
  final String? instructorBio;
  @JsonKey(name: 'instructor_avatar')
  final String? instructorAvatar;
  @JsonKey(name: 'subject_name')
  final String? subjectNameAr;
  final String? subjectNameEn;
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
    this.thumbnailFullUrl,
    this.promoVideoUrl,
    this.shortDescriptionAr,
    this.whatYouWillLearn,
    this.requirements,
    this.targetAudience,
    required this.priceDzd,
    this.originalPriceDzd,
    this.discountPercentage,
    this.level,
    this.language,
    this.isFreeAccess = false,
    this.isPublished = false,
    this.isFeatured = false,
    this.certificateAvailable = true,
    this.totalDurationMinutes,
    this.totalModules,
    this.totalLessons,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.totalStudents = 0,
    this.viewCount = 0,
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

  /// Construct full storage URL from relative path
  String? _getFullStorageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return null;
    // If already a full URL, return as-is
    if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) {
      return relativePath;
    }
    // Construct full URL using the app's base URL (remove /api suffix and add /storage/)
    String storageBaseUrl = ApiConstants.baseUrl;
    if (storageBaseUrl.endsWith('/api')) {
      storageBaseUrl = storageBaseUrl.substring(0, storageBaseUrl.length - 4);
    }
    // Remove leading slash from relative path if present
    final cleanPath = relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;
    return '$storageBaseUrl/storage/$cleanPath';
  }

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
      // Always use mobile's URL construction to handle emulator localhost correctly
      thumbnailUrl: _getFullStorageUrl(thumbnailUrl) ?? thumbnailFullUrl,
      trailerVideoUrl: promoVideoUrl,
      shortDescriptionAr: shortDescriptionAr,
      whatYouWillLearn: whatYouWillLearn,
      requirements: requirements,
      targetAudience: targetAudience,
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
      certificateAvailable: certificateAvailable,
      viewCount: viewCount,
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
      thumbnailFullUrl: entity.thumbnailUrl,
      promoVideoUrl: entity.trailerVideoUrl,
      shortDescriptionAr: entity.shortDescriptionAr,
      whatYouWillLearn: entity.whatYouWillLearn,
      requirements: entity.requirements,
      targetAudience: entity.targetAudience,
      priceDzd: entity.priceDzd,
      originalPriceDzd: entity.originalPriceDzd,
      discountPercentage: entity.discountPercentage,
      level: entity.level,
      language: 'ar',
      isFreeAccess: entity.isFree,
      isPublished: entity.isPublished,
      isFeatured: entity.isFeatured,
      certificateAvailable: entity.certificateAvailable,
      totalDurationMinutes: entity.totalDurationMinutes,
      totalModules: entity.totalModules,
      totalLessons: entity.totalLessons,
      averageRating: entity.averageRating,
      totalReviews: entity.totalReviews,
      totalStudents: entity.enrollmentCount,
      viewCount: entity.viewCount,
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
