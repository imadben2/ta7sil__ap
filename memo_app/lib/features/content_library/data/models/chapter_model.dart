import '../../domain/entities/chapter_entity.dart';

/// Data model for Chapter that extends ChapterEntity
class ChapterModel extends ChapterEntity {
  const ChapterModel({
    required super.id,
    required super.subjectId,
    super.academicStreamId,
    required super.titleAr,
    super.titleEn,
    super.titleFr,
    required super.slug,
    super.descriptionAr,
    required super.order,
    super.isActive = true,
    super.lessonsCount,
    super.summariesCount,
    super.exercisesCount,
    super.testsCount,
    super.completedContents,
    super.totalContents,
    super.completionPercentage,
  });

  /// Create ChapterModel from JSON
  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    // Handle content counts if available
    final contentCounts = json['content_counts'] as Map<String, dynamic>?;

    return ChapterModel(
      id: json['id'] as int,
      subjectId: json['subject_id'] as int,
      academicStreamId: json['academic_stream_id'] as int?,
      titleAr: json['title_ar'] as String,
      titleEn: json['title_en'] as String?,
      titleFr: json['title_fr'] as String?,
      slug: json['slug'] as String,
      descriptionAr: json['description_ar'] as String?,
      order: json['order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      lessonsCount: contentCounts?['lessons'] as int? ?? 0,
      summariesCount: contentCounts?['summaries'] as int? ?? 0,
      exercisesCount: contentCounts?['exercises'] as int? ?? 0,
      testsCount: contentCounts?['tests'] as int? ?? 0,
      completedContents: json['completed_count'] as int? ?? 0,
      totalContents: json['total_count'] as int? ?? 0,
      completionPercentage: _parseDouble(json['completion_percentage']) ?? 0.0,
    );
  }

  /// Convert ChapterModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'academic_stream_id': academicStreamId,
      'title_ar': titleAr,
      'title_en': titleEn,
      'title_fr': titleFr,
      'slug': slug,
      'description_ar': descriptionAr,
      'order': order,
      'is_active': isActive,
      'content_counts': {
        'lessons': lessonsCount,
        'summaries': summariesCount,
        'exercises': exercisesCount,
        'tests': testsCount,
      },
      'completed_count': completedContents,
      'total_count': totalContents,
      'completion_percentage': completionPercentage,
    };
  }

  /// Create ChapterModel from ChapterEntity
  factory ChapterModel.fromEntity(ChapterEntity entity) {
    return ChapterModel(
      id: entity.id,
      subjectId: entity.subjectId,
      academicStreamId: entity.academicStreamId,
      titleAr: entity.titleAr,
      titleEn: entity.titleEn,
      titleFr: entity.titleFr,
      slug: entity.slug,
      descriptionAr: entity.descriptionAr,
      order: entity.order,
      isActive: entity.isActive,
      lessonsCount: entity.lessonsCount,
      summariesCount: entity.summariesCount,
      exercisesCount: entity.exercisesCount,
      testsCount: entity.testsCount,
      completedContents: entity.completedContents,
      totalContents: entity.totalContents,
      completionPercentage: entity.completionPercentage,
    );
  }

  /// Helper method to safely parse double values
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Create ChapterModel from V1 API /v1/contents/chapters response
  /// This is an alias for fromJson since the format matches
  factory ChapterModel.fromApiJson(Map<String, dynamic> json) {
    return ChapterModel.fromJson(json);
  }

  /// Create ChapterModel from subject detail response
  /// Used when extracting chapters from GET /v1/academic/subjects/{id}
  factory ChapterModel.fromSubjectDetailJson(
    Map<String, dynamic> json,
    int subjectId,
  ) {
    return ChapterModel(
      id: json['id'] as int,
      subjectId: subjectId,
      academicStreamId: json['academic_stream_id'] as int?,
      titleAr: json['title_ar'] as String,
      titleEn: json['title_en'] as String?,
      titleFr: json['title_fr'] as String?,
      slug: json['slug'] as String? ?? '',
      descriptionAr: json['description_ar'] as String?,
      order: json['order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      lessonsCount: 0,
      summariesCount: 0,
      exercisesCount: 0,
      testsCount: 0,
      completedContents: 0,
      totalContents: json['contents_count'] as int? ?? 0,
      completionPercentage: 0.0,
    );
  }

  /// Copy with method
  ChapterModel copyWith({
    int? id,
    int? subjectId,
    int? academicStreamId,
    String? titleAr,
    String? titleEn,
    String? titleFr,
    String? slug,
    String? descriptionAr,
    int? order,
    bool? isActive,
    int? lessonsCount,
    int? summariesCount,
    int? exercisesCount,
    int? testsCount,
    int? completedContents,
    int? totalContents,
    double? completionPercentage,
  }) {
    return ChapterModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      academicStreamId: academicStreamId ?? this.academicStreamId,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      titleFr: titleFr ?? this.titleFr,
      slug: slug ?? this.slug,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      lessonsCount: lessonsCount ?? this.lessonsCount,
      summariesCount: summariesCount ?? this.summariesCount,
      exercisesCount: exercisesCount ?? this.exercisesCount,
      testsCount: testsCount ?? this.testsCount,
      completedContents: completedContents ?? this.completedContents,
      totalContents: totalContents ?? this.totalContents,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }
}
