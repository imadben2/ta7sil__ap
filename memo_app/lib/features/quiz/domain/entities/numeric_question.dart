import 'question_entity.dart';

/// Numeric question entity (رقمية)
///
/// User provides a numerical answer.
/// Supports tolerance for accepting answers within a range.
/// Example: "احسب مساحة دائرة نصف قطرها 5 سم (π = 3.14)"
class NumericQuestion extends QuestionEntity {
  /// The correct numerical answer
  final double correctAnswer;

  /// Tolerance for accepting answers (percentage)
  /// Example: 0.01 means ±1% of correct answer is acceptable
  final double tolerance;

  /// Unit of measurement (optional)
  /// Example: "سم²", "متر", "كيلوغرام"
  final String? unit;

  /// Number of decimal places expected
  final int? decimalPlaces;

  const NumericQuestion({
    required super.id,
    required super.questionTextAr,
    super.questionImageUrl,
    required super.points,
    super.explanationAr,
    super.difficulty,
    super.tags,
    required super.questionOrder,
    required this.correctAnswer,
    this.tolerance = 0.01, // Default: 1% tolerance
    this.unit,
    this.decimalPlaces,
  }) : super(questionType: 'numeric');

  /// Check if user's answer is within acceptable range
  bool isAnswerCorrect(double userAnswer) {
    final maxDifference = correctAnswer.abs() * tolerance;
    final difference = (userAnswer - correctAnswer).abs();

    return difference <= maxDifference;
  }

  /// Get acceptable answer range
  ({double min, double max}) get acceptableRange {
    final maxDifference = correctAnswer.abs() * tolerance;
    return (
      min: correctAnswer - maxDifference,
      max: correctAnswer + maxDifference,
    );
  }

  /// Format correct answer with unit
  String get formattedCorrectAnswer {
    String formatted = decimalPlaces != null
        ? correctAnswer.toStringAsFixed(decimalPlaces!)
        : correctAnswer.toString();

    if (unit != null && unit!.isNotEmpty) {
      formatted += ' $unit';
    }

    return formatted;
  }

  @override
  List<Object?> get props => [
    ...super.props,
    correctAnswer,
    tolerance,
    unit,
    decimalPlaces,
  ];
}
