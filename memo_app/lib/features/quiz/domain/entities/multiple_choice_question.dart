import 'question_entity.dart';

/// Multiple choice question entity (اختيار متعدد)
///
/// User selects one or more options from multiple choices.
/// Supports partial credit for partially correct answers.
/// Example: "Select all prime numbers" with options ["2", "3", "4", "5"]
class MultipleChoiceQuestion extends QuestionEntity {
  /// List of options to choose from
  final List<String> options;

  /// Indices of all correct options (0-based)
  final List<int> correctAnswerIndices;

  /// Whether partial credit is awarded
  final bool allowPartialCredit;

  const MultipleChoiceQuestion({
    required super.id,
    required super.questionTextAr,
    super.questionImageUrl,
    required super.points,
    super.explanationAr,
    super.difficulty,
    super.tags,
    required super.questionOrder,
    required this.options,
    required this.correctAnswerIndices,
    this.allowPartialCredit = true,
  }) : super(questionType: 'multiple_choice');

  /// Calculate points earned based on user's answer
  ///
  /// Partial credit formula:
  /// points_earned = (correct_selections - incorrect_selections) / total_correct * points
  /// Minimum: 0 (never negative)
  double calculatePointsEarned(List<int> userAnswerIndices) {
    if (userAnswerIndices.isEmpty) return 0.0;

    final correctSelections = userAnswerIndices
        .where((index) => correctAnswerIndices.contains(index))
        .length;

    final incorrectSelections = userAnswerIndices
        .where((index) => !correctAnswerIndices.contains(index))
        .length;

    if (correctSelections == correctAnswerIndices.length &&
        incorrectSelections == 0) {
      return points; // Perfect answer
    }

    if (!allowPartialCredit) return 0.0;

    // Partial credit calculation
    final credit =
        (correctSelections - incorrectSelections) / correctAnswerIndices.length;

    return (credit * points).clamp(0.0, points);
  }

  /// Check if answer is completely correct
  bool isAnswerCorrect(List<int> userAnswerIndices) {
    if (userAnswerIndices.length != correctAnswerIndices.length) {
      return false;
    }

    final sortedUser = List<int>.from(userAnswerIndices)..sort();
    final sortedCorrect = List<int>.from(correctAnswerIndices)..sort();

    for (int i = 0; i < sortedUser.length; i++) {
      if (sortedUser[i] != sortedCorrect[i]) return false;
    }

    return true;
  }

  /// Get correct option texts
  List<String> get correctOptionTexts {
    return correctAnswerIndices
        .where((index) => index >= 0 && index < options.length)
        .map((index) => options[index])
        .toList();
  }

  @override
  List<Object?> get props => [
    ...super.props,
    options,
    correctAnswerIndices,
    allowPartialCredit,
  ];
}
