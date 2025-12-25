import 'package:equatable/equatable.dart';

/// Course Entity - يمثل دورة تعليمية
class CourseEntity extends Equatable {
  final int id;
  final String titleAr;
  final String? titleEn;
  final String? titleFr;
  final String slug;
  final String descriptionAr;
  final String? descriptionEn;
  final String? descriptionFr;

  // Media
  final String? thumbnailUrl;
  final String? trailerVideoUrl;

  // Short Description
  final String? shortDescriptionAr;

  // Learning Content
  final List<String>? whatYouWillLearn;
  final List<String>? requirements;
  final List<String>? targetAudience;

  // Pricing
  final int priceDzd;
  final int? originalPriceDzd; // السعر الأصلي قبل الخصم
  final double? discountPercentage; // نسبة الخصم (0-100)
  final bool isFree;
  final bool requiresSubscription;

  // Instructor
  final String instructorName;
  final String? instructorBioAr;
  final String? instructorPhotoUrl;

  // Course Stats
  final int totalModules;
  final int totalLessons;
  final int totalDurationMinutes;

  // Status
  final bool isPublished;
  final bool isFeatured;
  final bool certificateAvailable;

  // Engagement
  final int viewCount;
  final int enrollmentCount;
  final double averageRating;
  final int totalReviews;

  // Academic Info
  final int? subjectId;
  final String? subjectName;
  final int? academicYearId;
  final String? level;

  // Tags
  final List<String>? tags;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const CourseEntity({
    required this.id,
    required this.titleAr,
    this.titleEn,
    this.titleFr,
    required this.slug,
    required this.descriptionAr,
    this.descriptionEn,
    this.descriptionFr,
    this.thumbnailUrl,
    this.trailerVideoUrl,
    this.shortDescriptionAr,
    this.whatYouWillLearn,
    this.requirements,
    this.targetAudience,
    required this.priceDzd,
    this.originalPriceDzd,
    this.discountPercentage,
    this.isFree = false,
    this.requiresSubscription = false,
    required this.instructorName,
    this.instructorBioAr,
    this.instructorPhotoUrl,
    required this.totalModules,
    required this.totalLessons,
    required this.totalDurationMinutes,
    this.isPublished = true,
    this.isFeatured = false,
    this.certificateAvailable = true,
    this.viewCount = 0,
    this.enrollmentCount = 0,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.subjectId,
    this.subjectName,
    this.academicYearId,
    this.level,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  /// هل الدورة مجانية؟
  bool get isFreeAccess => isFree || priceDzd == 0;

  /// هل الدورة لها تقييمات؟
  bool get hasReviews => totalReviews > 0;

  /// هل الدورة عليها خصم؟
  bool get hasDiscount => discountPercentage != null && discountPercentage! > 0;

  /// السعر الفعلي (بعد الخصم)
  int get effectivePrice => priceDzd;

  /// مبلغ التوفير بالدينار
  int get savingsAmount {
    if (!hasDiscount || originalPriceDzd == null) return 0;
    return originalPriceDzd! - priceDzd;
  }

  /// نص الخصم المنسق
  String get formattedDiscount {
    if (!hasDiscount) return '';
    return '-${discountPercentage!.toStringAsFixed(0)}%';
  }

  /// المدة بالساعات
  double get durationHours => totalDurationMinutes / 60.0;

  /// المدة المنسقة (مثال: "12 ساعة و 30 دقيقة")
  String get formattedDuration {
    final hours = totalDurationMinutes ~/ 60;
    final minutes = totalDurationMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '$hours ساعة و $minutes دقيقة';
    } else if (hours > 0) {
      return '$hours ساعة';
    } else {
      return '$minutes دقيقة';
    }
  }

  /// السعر المنسق
  String get formattedPrice {
    if (isFreeAccess) {
      return 'مجاني';
    }
    return '$priceDzd دج';
  }

  /// السعر الأصلي المنسق (قبل الخصم)
  String? get formattedOriginalPrice {
    if (!hasDiscount || originalPriceDzd == null) return null;
    return '$originalPriceDzd دج';
  }

  /// التقييم المنسق
  String get formattedRating {
    return averageRating.toStringAsFixed(1);
  }

  /// نص عدد الطلاب
  String get enrollmentText {
    if (enrollmentCount >= 1000) {
      return '${(enrollmentCount / 1000).toStringAsFixed(1)}k طالب';
    }
    return '$enrollmentCount طالب';
  }

  /// اسم المادة بالعربية (getter للتوافق)
  String get subjectNameAr => subjectName ?? 'مادة عامة';

  /// عدد الطلاب المسجلين (getter للتوافق)
  int get totalStudents => enrollmentCount;

  /// نص المستوى (getter للتوافق)
  String get levelText {
    if (level == null) return '';
    switch (level!.toLowerCase()) {
      case 'secondary':
        return 'ثانوي';
      case 'bac':
      case 'baccalaureate':
        return 'بكالوريا';
      case 'middle':
        return 'متوسط';
      case 'primary':
        return 'ابتدائي';
      default:
        return level!;
    }
  }

  /// صورة المعلم (getter للتوافق)
  String? get instructorAvatar => instructorPhotoUrl;

  /// السيرة الذاتية للمعلم (getter للتوافق)
  String? get instructorBio => instructorBioAr;

  CourseEntity copyWith({
    int? id,
    String? titleAr,
    String? titleEn,
    String? titleFr,
    String? slug,
    String? descriptionAr,
    String? descriptionEn,
    String? descriptionFr,
    String? thumbnailUrl,
    String? trailerVideoUrl,
    String? shortDescriptionAr,
    List<String>? whatYouWillLearn,
    List<String>? requirements,
    List<String>? targetAudience,
    int? priceDzd,
    int? originalPriceDzd,
    double? discountPercentage,
    bool? isFree,
    bool? requiresSubscription,
    String? instructorName,
    String? instructorBioAr,
    String? instructorPhotoUrl,
    int? totalModules,
    int? totalLessons,
    int? totalDurationMinutes,
    bool? isPublished,
    bool? isFeatured,
    bool? certificateAvailable,
    int? viewCount,
    int? enrollmentCount,
    double? averageRating,
    int? totalReviews,
    int? subjectId,
    String? subjectName,
    int? academicYearId,
    String? level,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseEntity(
      id: id ?? this.id,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      titleFr: titleFr ?? this.titleFr,
      slug: slug ?? this.slug,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionFr: descriptionFr ?? this.descriptionFr,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      trailerVideoUrl: trailerVideoUrl ?? this.trailerVideoUrl,
      shortDescriptionAr: shortDescriptionAr ?? this.shortDescriptionAr,
      whatYouWillLearn: whatYouWillLearn ?? this.whatYouWillLearn,
      requirements: requirements ?? this.requirements,
      targetAudience: targetAudience ?? this.targetAudience,
      priceDzd: priceDzd ?? this.priceDzd,
      originalPriceDzd: originalPriceDzd ?? this.originalPriceDzd,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      isFree: isFree ?? this.isFree,
      requiresSubscription: requiresSubscription ?? this.requiresSubscription,
      instructorName: instructorName ?? this.instructorName,
      instructorBioAr: instructorBioAr ?? this.instructorBioAr,
      instructorPhotoUrl: instructorPhotoUrl ?? this.instructorPhotoUrl,
      totalModules: totalModules ?? this.totalModules,
      totalLessons: totalLessons ?? this.totalLessons,
      totalDurationMinutes: totalDurationMinutes ?? this.totalDurationMinutes,
      isPublished: isPublished ?? this.isPublished,
      isFeatured: isFeatured ?? this.isFeatured,
      certificateAvailable: certificateAvailable ?? this.certificateAvailable,
      viewCount: viewCount ?? this.viewCount,
      enrollmentCount: enrollmentCount ?? this.enrollmentCount,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      academicYearId: academicYearId ?? this.academicYearId,
      level: level ?? this.level,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    titleAr,
    titleEn,
    titleFr,
    slug,
    descriptionAr,
    descriptionEn,
    descriptionFr,
    thumbnailUrl,
    trailerVideoUrl,
    shortDescriptionAr,
    whatYouWillLearn,
    requirements,
    targetAudience,
    priceDzd,
    originalPriceDzd,
    discountPercentage,
    isFree,
    requiresSubscription,
    instructorName,
    instructorBioAr,
    instructorPhotoUrl,
    totalModules,
    totalLessons,
    totalDurationMinutes,
    isPublished,
    isFeatured,
    certificateAvailable,
    viewCount,
    enrollmentCount,
    averageRating,
    totalReviews,
    subjectId,
    subjectName,
    academicYearId,
    level,
    tags,
    createdAt,
    updatedAt,
  ];
}
