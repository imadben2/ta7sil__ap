import 'package:equatable/equatable.dart';

/// Entity representing a subject in the content library
class SubjectEntity extends Equatable {
  final int id;
  final String nameAr;
  final String? nameEn;
  final String? nameFr;
  final String slug;
  final String? descriptionAr;
  final String color;
  final String? icon;
  final int coefficient;
  final List<int> academicStreamIds;
  final int academicYearId;
  final int order;
  final bool isActive;

  // Stats from API
  final int totalContents;
  final int completedContents;
  final int totalQuizzes;
  final int completedQuizzes;
  final double? averageScore;
  final double completionPercentage;

  const SubjectEntity({
    required this.id,
    required this.nameAr,
    this.nameEn,
    this.nameFr,
    required this.slug,
    this.descriptionAr,
    required this.color,
    this.icon,
    required this.coefficient,
    required this.academicStreamIds,
    required this.academicYearId,
    required this.order,
    required this.isActive,
    this.totalContents = 0,
    this.completedContents = 0,
    this.totalQuizzes = 0,
    this.completedQuizzes = 0,
    this.averageScore,
    this.completionPercentage = 0.0,
  });

  /// Check if subject belongs to a specific stream
  bool belongsToStream(int streamId) => academicStreamIds.contains(streamId);

  /// Formatted completion label "5 / 20"
  String get completionLabel => '$completedContents / $totalContents';

  /// Check if subject has exams soon (placeholder - needs actual exam date)
  bool get hasExamSoon => false;

  /// Coefficient label with star "معامل 7"
  String get coefficientLabel => 'معامل $coefficient';

  /// Create SubjectEntity from JSON
  factory SubjectEntity.fromJson(Map<String, dynamic> json) {
    return SubjectEntity(
      id: json['id'] as int,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String?,
      nameFr: json['name_fr'] as String?,
      slug: json['slug'] as String,
      descriptionAr: json['description_ar'] as String?,
      color: json['color'] as String? ?? '#6366F1',
      icon: json['icon'] as String?,
      coefficient: json['coefficient'] as int? ?? 1,
      academicStreamIds: (json['academic_stream_ids'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      academicYearId: json['academic_year_id'] as int? ?? 0,
      order: json['order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      totalContents: json['total_contents'] as int? ?? 0,
      completedContents: json['completed_contents'] as int? ?? 0,
      totalQuizzes: json['total_quizzes'] as int? ?? 0,
      completedQuizzes: json['completed_quizzes'] as int? ?? 0,
      averageScore: json['average_score'] != null
          ? (json['average_score'] as num).toDouble()
          : null,
      completionPercentage: json['completion_percentage'] != null
          ? (json['completion_percentage'] as num).toDouble()
          : 0.0,
    );
  }

  /// Convert SubjectEntity to JSON
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
      'total_contents': totalContents,
      'completed_contents': completedContents,
      'total_quizzes': totalQuizzes,
      'completed_quizzes': completedQuizzes,
      'average_score': averageScore,
      'completion_percentage': completionPercentage,
    };
  }

  @override
  List<Object?> get props => [
    id,
    nameAr,
    nameEn,
    nameFr,
    slug,
    descriptionAr,
    color,
    icon,
    coefficient,
    academicStreamIds,
    academicYearId,
    order,
    isActive,
    totalContents,
    completedContents,
    totalQuizzes,
    completedQuizzes,
    averageScore,
    completionPercentage,
  ];
}
