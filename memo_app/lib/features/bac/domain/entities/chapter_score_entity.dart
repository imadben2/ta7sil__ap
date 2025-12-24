import 'package:equatable/equatable.dart';

/// Entity representing score breakdown by chapter in a simulation
class ChapterScoreEntity extends Equatable {
  final int chapterId;
  final String chapterTitleAr;
  final int totalQuestions;
  final int answeredQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int skippedQuestions;
  final double percentage;
  final double? score;

  const ChapterScoreEntity({
    required this.chapterId,
    required this.chapterTitleAr,
    required this.totalQuestions,
    this.answeredQuestions = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.skippedQuestions = 0,
    this.percentage = 0.0,
    this.score,
  });

  /// Check if all questions in this chapter were answered
  bool get isComplete => answeredQuestions >= totalQuestions;

  /// Get performance level
  String get performanceLevel {
    if (percentage >= 80) return 'ممتاز';
    if (percentage >= 60) return 'جيد';
    if (percentage >= 40) return 'مقبول';
    return 'ضعيف';
  }

  @override
  List<Object?> get props => [
    chapterId,
    chapterTitleAr,
    totalQuestions,
    answeredQuestions,
    correctAnswers,
    wrongAnswers,
    skippedQuestions,
    percentage,
    score,
  ];
}
