import 'package:equatable/equatable.dart';

/// Entity representing a content chapter within a subject
class ChapterEntity extends Equatable {
  final int id;
  final int subjectId;
  final int? academicStreamId; // Stream-specific chapter, null = shared
  final String titleAr;
  final String? titleEn;
  final String? titleFr;
  final String slug;
  final String? descriptionAr;
  final int order;
  final bool isActive;

  // Content counts by type
  final int lessonsCount;
  final int summariesCount;
  final int exercisesCount;
  final int testsCount;
  final int totalContents;

  // Progress stats
  final int completedContents;
  final double completionPercentage;

  const ChapterEntity({
    required this.id,
    required this.subjectId,
    this.academicStreamId,
    required this.titleAr,
    this.titleEn,
    this.titleFr,
    required this.slug,
    this.descriptionAr,
    required this.order,
    required this.isActive,
    this.lessonsCount = 0,
    this.summariesCount = 0,
    this.exercisesCount = 0,
    this.testsCount = 0,
    this.totalContents = 0,
    this.completedContents = 0,
    this.completionPercentage = 0.0,
  });

  /// Formatted count label for display
  String get contentCountLabel => '$completedContents / $totalContents';

  /// Check if chapter is completed
  bool get isCompleted =>
      totalContents > 0 && completedContents >= totalContents;

  /// Get count for a specific content type
  int getCountForType(String type) {
    switch (type) {
      case 'lesson':
        return lessonsCount;
      case 'summary':
        return summariesCount;
      case 'exercise':
        return exercisesCount;
      case 'test':
        return testsCount;
      default:
        return 0;
    }
  }

  @override
  List<Object?> get props => [
    id,
    subjectId,
    academicStreamId,
    titleAr,
    titleEn,
    titleFr,
    slug,
    descriptionAr,
    order,
    isActive,
    lessonsCount,
    summariesCount,
    exercisesCount,
    testsCount,
    totalContents,
    completedContents,
    completionPercentage,
  ];
}
