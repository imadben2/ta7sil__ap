import 'package:equatable/equatable.dart';

/// Base class for all question types
///
/// Question types supported:
/// - single_choice: Single selection (اختيار واحد)
/// - multiple_choice: Multiple selections (اختيار متعدد)
/// - true_false: Binary choice (صح أم خطأ)
/// - matching: Pair matching (المطابقة)
/// - ordering: Sequence ordering (الترتيب)
/// - fill_blank: Fill in the blank (املأ الفراغ)
/// - short_answer: Open-ended text (إجابة قصيرة)
/// - numeric: Numerical answer (رقمية)
abstract class QuestionEntity extends Equatable {
  /// Unique identifier
  final int id;

  /// Question type enum
  final String questionType;

  /// Question text in Arabic
  final String questionTextAr;

  /// Optional question image URL
  final String? questionImageUrl;

  /// Points awarded for correct answer
  final double points;

  /// Explanation shown after answer (Arabic)
  final String? explanationAr;

  /// Difficulty level
  final String? difficulty;

  /// Tags for categorization
  final List<String>? tags;

  /// Order/position in quiz
  final int questionOrder;

  const QuestionEntity({
    required this.id,
    required this.questionType,
    required this.questionTextAr,
    this.questionImageUrl,
    required this.points,
    this.explanationAr,
    this.difficulty,
    this.tags,
    required this.questionOrder,
  });

  /// Get question type display name in Arabic
  String get questionTypeAr {
    switch (questionType) {
      case 'single_choice':
        return 'اختيار واحد';
      case 'multiple_choice':
        return 'اختيار متعدد';
      case 'true_false':
        return 'صح أم خطأ';
      case 'matching':
        return 'المطابقة';
      case 'ordering':
        return 'الترتيب';
      case 'fill_blank':
        return 'املأ الفراغ';
      case 'short_answer':
        return 'إجابة قصيرة';
      case 'numeric':
        return 'رقمية';
      default:
        return questionType;
    }
  }

  @override
  List<Object?> get props => [
    id,
    questionType,
    questionTextAr,
    questionImageUrl,
    points,
    explanationAr,
    difficulty,
    tags,
    questionOrder,
  ];
}

/// User's answer to a question
class QuestionAnswer extends Equatable {
  /// Question ID
  final int questionId;

  /// User's answer (format varies by question type)
  final dynamic userAnswer;

  /// Time spent on this question in seconds
  final int? timeSpentSeconds;

  /// When the answer was given
  final DateTime answeredAt;

  const QuestionAnswer({
    required this.questionId,
    required this.userAnswer,
    this.timeSpentSeconds,
    required this.answeredAt,
  });

  @override
  List<Object?> get props => [
    questionId,
    userAnswer,
    timeSpentSeconds,
    answeredAt,
  ];
}

/// Question with answer feedback (for review)
class QuestionWithFeedback extends Equatable {
  /// The question
  final QuestionEntity question;

  /// User's answer
  final dynamic userAnswer;

  /// Correct answer
  final dynamic correctAnswer;

  /// Whether answer was correct
  final bool isCorrect;

  /// Points earned
  final double pointsEarned;

  /// Time spent on question
  final int? timeSpentSeconds;

  const QuestionWithFeedback({
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.pointsEarned,
    this.timeSpentSeconds,
  });

  @override
  List<Object?> get props => [
    question,
    userAnswer,
    correctAnswer,
    isCorrect,
    pointsEarned,
    timeSpentSeconds,
  ];
}
