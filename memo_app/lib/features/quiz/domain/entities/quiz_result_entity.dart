import 'package:equatable/equatable.dart';
import 'question_entity.dart';

/// Quiz result entity containing detailed results after quiz submission
///
/// Includes:
/// - Overall score and statistics
/// - Question-by-question breakdown
/// - Weak areas identification
/// - Recommendations
class QuizResultEntity extends Equatable {
  /// Attempt ID
  final int attemptId;

  /// Quiz ID
  final int quizId;

  /// Quiz title
  final String quizTitleAr;

  /// Subject ID for navigation
  final int? subjectId;

  /// Subject name in Arabic
  final String? subjectNameAr;

  /// Final percentage score
  final double percentage;

  /// Total points possible
  final double totalPoints;

  /// Points earned
  final double earnedPoints;

  /// Whether user passed
  final bool passed;

  /// Passing score threshold
  final double passingScore;

  /// Number of correct answers
  final int correctAnswers;

  /// Number of incorrect answers
  final int incorrectAnswers;

  /// Number of skipped answers
  final int skippedAnswers;

  /// Total questions
  final int totalQuestions;

  /// Time spent (seconds)
  final int timeSpentSeconds;

  /// Question-by-question results
  final List<QuestionWithFeedback> questionResults;

  /// Weak concepts identified
  final List<String> weakConcepts;

  /// Whether review is allowed
  final bool allowReview;

  /// Completed date
  final DateTime completedAt;

  const QuizResultEntity({
    required this.attemptId,
    required this.quizId,
    required this.quizTitleAr,
    this.subjectId,
    this.subjectNameAr,
    required this.percentage,
    required this.totalPoints,
    required this.earnedPoints,
    required this.passed,
    required this.passingScore,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.skippedAnswers,
    required this.totalQuestions,
    required this.timeSpentSeconds,
    required this.questionResults,
    required this.weakConcepts,
    required this.allowReview,
    required this.completedAt,
  });

  /// Get accuracy percentage
  double get accuracy {
    if (totalQuestions == 0) return 0.0;
    return (correctAnswers / totalQuestions) * 100;
  }

  /// Get time spent in minutes
  double get timeSpentMinutes => timeSpentSeconds / 60;

  /// Get formatted time spent (MM:SS)
  String get formattedTimeSpent {
    final minutes = timeSpentSeconds ~/ 60;
    final seconds = timeSpentSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get score color based on percentage
  String get scoreColor {
    if (percentage >= 90) return '#4CAF50'; // Excellent (Green)
    if (percentage >= 75) return '#66BB6A'; // Good (Light Green)
    if (percentage >= 60) return '#FFA726'; // Fair (Orange)
    return '#EF5350'; // Poor (Red)
  }

  /// Get performance level in Arabic
  String get performanceLevelAr {
    if (percentage >= 90) return 'ممتاز';
    if (percentage >= 75) return 'جيد جداً';
    if (percentage >= 60) return 'جيد';
    if (percentage >= 50) return 'مقبول';
    return 'ضعيف';
  }

  /// Get incorrect questions
  List<QuestionWithFeedback> get incorrectQuestions {
    return questionResults.where((q) => !q.isCorrect).toList();
  }

  /// Get correct questions
  List<QuestionWithFeedback> get correctQuestions {
    return questionResults.where((q) => q.isCorrect).toList();
  }

  @override
  List<Object?> get props => [
    attemptId,
    quizId,
    quizTitleAr,
    subjectId,
    subjectNameAr,
    percentage,
    totalPoints,
    earnedPoints,
    passed,
    passingScore,
    correctAnswers,
    incorrectAnswers,
    skippedAnswers,
    totalQuestions,
    timeSpentSeconds,
    questionResults,
    weakConcepts,
    allowReview,
    completedAt,
  ];
}
