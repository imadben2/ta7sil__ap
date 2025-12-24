import 'package:equatable/equatable.dart';

/// Entity representing chapter information within a BAC subject
/// Note: This is different from content_library ChapterEntity
/// This focuses on BAC exam coverage and practice status
class BacChapterInfoEntity extends Equatable {
  final int id;
  final int bacSubjectId;
  final String titleAr;
  final String? titleEn;
  final String? titleFr;
  final String slug;
  final String? descriptionAr;
  final int order;
  final bool isActive;

  // BAC-specific stats
  final int totalExamsWithThis; // Number of BAC exams that include this chapter
  final double importanceWeight; // 0-100 based on frequency in exams
  final int totalQuestions; // Total questions available for practice

  // User progress
  final int practiceAttempts;
  final int correctAnswers;
  final double? averageScore;
  final bool isPracticed;

  const BacChapterInfoEntity({
    required this.id,
    required this.bacSubjectId,
    required this.titleAr,
    this.titleEn,
    this.titleFr,
    required this.slug,
    this.descriptionAr,
    required this.order,
    required this.isActive,
    this.totalExamsWithThis = 0,
    this.importanceWeight = 0.0,
    this.totalQuestions = 0,
    this.practiceAttempts = 0,
    this.correctAnswers = 0,
    this.averageScore,
    this.isPracticed = false,
  });

  /// Get importance level based on weight
  String get importanceLevel {
    if (importanceWeight >= 80) return 'مهم جداً';
    if (importanceWeight >= 60) return 'مهم';
    if (importanceWeight >= 40) return 'متوسط';
    return 'منخفض';
  }

  /// Success rate percentage
  double get successRate {
    if (practiceAttempts == 0) return 0.0;
    return (correctAnswers / totalQuestions) * 100;
  }

  @override
  List<Object?> get props => [
    id,
    bacSubjectId,
    titleAr,
    titleEn,
    titleFr,
    slug,
    descriptionAr,
    order,
    isActive,
    totalExamsWithThis,
    importanceWeight,
    totalQuestions,
    practiceAttempts,
    correctAnswers,
    averageScore,
    isPracticed,
  ];
}
