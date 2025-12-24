import '../../domain/entities/subject_entity.dart';

/// Data model for Subject that extends SubjectEntity
class SubjectModel extends SubjectEntity {
  const SubjectModel({
    required super.id,
    required super.nameAr,
    super.nameEn,
    super.nameFr,
    required super.slug,
    super.descriptionAr,
    required super.color,
    super.icon,
    required super.coefficient,
    required super.academicStreamIds,
    required super.academicYearId,
    required super.order,
    required super.isActive,
    super.totalContents,
    super.completedContents,
    super.totalQuizzes,
    super.completedQuizzes,
    super.averageScore,
    super.completionPercentage,
  });

  /// Create SubjectModel from JSON
  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    // Handle progress data if available
    final progress = json['progress'] as Map<String, dynamic>?;

    // totalContents can come from multiple sources:
    // 1. progress.total_contents (if progress data is included)
    // 2. contents_count (direct field from API)
    // 3. total_contents (direct field from API)
    int totalContents = 0;
    if (progress != null && progress['total_contents'] != null) {
      totalContents = progress['total_contents'] as int;
    } else if (json['contents_count'] != null) {
      totalContents = json['contents_count'] as int;
    } else if (json['total_contents'] != null) {
      totalContents = json['total_contents'] as int;
    }

    return SubjectModel(
      id: json['id'] as int? ?? 0,
      nameAr: json['name_ar'] as String? ?? '',
      nameEn: json['name_en'] as String?,
      nameFr: json['name_fr'] as String?,
      slug: json['slug'] as String? ?? '',
      descriptionAr: json['description_ar'] as String?,
      color: json['color'] as String? ?? '#4CAF50',
      icon: json['icon'] as String?,
      coefficient: json['coefficient'] as int? ?? 1,
      academicStreamIds: (json['academic_stream_ids'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      academicYearId: json['academic_year_id'] as int? ?? 0,
      order: json['order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      totalContents: totalContents,
      completedContents: progress?['completed_contents'] as int? ?? 0,
      totalQuizzes: progress?['total_quizzes'] as int? ?? 0,
      completedQuizzes: progress?['completed_quizzes'] as int? ?? 0,
      averageScore: _parseDouble(progress?['average_score']),
      completionPercentage:
          _parseDouble(progress?['completion_percentage']) ?? 0.0,
    );
  }

  /// Convert SubjectModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'name_fr': nameFr,
      'slug': slug,
      'description_ar': descriptionAr,
      'color': color,
      'icon': icon,
      'coefficient': coefficient,
      'academic_stream_ids': academicStreamIds,
      'academic_year_id': academicYearId,
      'order': order,
      'is_active': isActive,
      'progress': {
        'total_contents': totalContents,
        'completed_contents': completedContents,
        'total_quizzes': totalQuizzes,
        'completed_quizzes': completedQuizzes,
        'average_score': averageScore,
        'completion_percentage': completionPercentage,
      },
    };
  }

  /// Create SubjectModel from SubjectEntity
  factory SubjectModel.fromEntity(SubjectEntity entity) {
    return SubjectModel(
      id: entity.id,
      nameAr: entity.nameAr,
      nameEn: entity.nameEn,
      nameFr: entity.nameFr,
      slug: entity.slug,
      descriptionAr: entity.descriptionAr,
      color: entity.color,
      icon: entity.icon,
      coefficient: entity.coefficient,
      academicStreamIds: entity.academicStreamIds,
      academicYearId: entity.academicYearId,
      order: entity.order,
      isActive: entity.isActive,
      totalContents: entity.totalContents,
      completedContents: entity.completedContents,
      totalQuizzes: entity.totalQuizzes,
      completedQuizzes: entity.completedQuizzes,
      averageScore: entity.averageScore,
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

  /// Copy with method
  SubjectModel copyWith({
    int? id,
    String? nameAr,
    String? nameEn,
    String? nameFr,
    String? slug,
    String? descriptionAr,
    String? color,
    String? icon,
    int? coefficient,
    List<int>? academicStreamIds,
    int? academicYearId,
    int? order,
    bool? isActive,
    int? totalContents,
    int? completedContents,
    int? totalQuizzes,
    int? completedQuizzes,
    double? averageScore,
    double? completionPercentage,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      nameFr: nameFr ?? this.nameFr,
      slug: slug ?? this.slug,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      coefficient: coefficient ?? this.coefficient,
      academicStreamIds: academicStreamIds ?? this.academicStreamIds,
      academicYearId: academicYearId ?? this.academicYearId,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      totalContents: totalContents ?? this.totalContents,
      completedContents: completedContents ?? this.completedContents,
      totalQuizzes: totalQuizzes ?? this.totalQuizzes,
      completedQuizzes: completedQuizzes ?? this.completedQuizzes,
      averageScore: averageScore ?? this.averageScore,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }
}
