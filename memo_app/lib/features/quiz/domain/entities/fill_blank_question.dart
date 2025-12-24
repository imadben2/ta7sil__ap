import 'question_entity.dart';

/// Fill in the blank question entity (املأ الفراغ)
///
/// User fills in one or more blanks in the question text.
/// Supports multiple correct answers per blank (synonyms).
/// Example: "العاصمة الجزائر وعاصمة مصر هي ____."
class FillBlankQuestion extends QuestionEntity {
  /// Number of blanks in the question
  final int numberOfBlanks;

  /// Correct answers for each blank
  /// Each blank can have multiple accepted answers (synonyms)
  /// Example: [["القاهرة", "cairo"], ["الجزائر"]]
  final List<List<String>> correctAnswers;

  /// Whether answer comparison is case-sensitive
  final bool caseSensitive;

  const FillBlankQuestion({
    required super.id,
    required super.questionTextAr,
    super.questionImageUrl,
    required super.points,
    super.explanationAr,
    super.difficulty,
    super.tags,
    required super.questionOrder,
    required this.numberOfBlanks,
    required this.correctAnswers,
    this.caseSensitive = false,
  }) : super(questionType: 'fill_blank');

  /// Check if user's answer is correct for a specific blank
  bool isBlankCorrect(int blankIndex, String userAnswer) {
    if (blankIndex < 0 || blankIndex >= correctAnswers.length) {
      return false;
    }

    final normalizedUserAnswer = _normalizeAnswer(userAnswer);

    return correctAnswers[blankIndex].any((correctAnswer) {
      final normalizedCorrect = _normalizeAnswer(correctAnswer);
      return normalizedUserAnswer == normalizedCorrect;
    });
  }

  /// Calculate points earned based on user's answers
  double calculatePointsEarned(List<String> userAnswers) {
    if (userAnswers.length != numberOfBlanks) return 0.0;

    int correctCount = 0;
    for (int i = 0; i < numberOfBlanks; i++) {
      if (isBlankCorrect(i, userAnswers[i])) {
        correctCount++;
      }
    }

    // All blanks must be correct for full points
    if (correctCount == numberOfBlanks) {
      return points;
    }

    // No partial credit for fill blank
    return 0.0;
  }

  /// Check if all blanks are correctly filled
  bool isAnswerCorrect(List<String> userAnswers) {
    return calculatePointsEarned(userAnswers) == points;
  }

  /// Alias for numberOfBlanks (for backward compatibility)
  int get blanksCount => numberOfBlanks;

  /// Normalize answer text for comparison
  ///
  /// Removes diacritics, normalizes Arabic characters, trims whitespace
  String _normalizeAnswer(String answer) {
    String normalized = answer.trim();

    if (!caseSensitive) {
      normalized = normalized.toLowerCase();
    }

    // Remove Arabic diacritics (تشكيل)
    normalized = normalized.replaceAll(RegExp(r'[\u064B-\u065F]'), '');

    // Normalize alef variants: أ, إ, آ → ا
    normalized = normalized
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا');

    // Normalize taa marbuta: ة → ه
    normalized = normalized.replaceAll('ة', 'ه');

    // Normalize alef maqsura: ى → ي
    normalized = normalized.replaceAll('ى', 'ي');

    // Remove extra whitespace
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');

    return normalized;
  }

  @override
  List<Object?> get props => [
    ...super.props,
    numberOfBlanks,
    correctAnswers,
    caseSensitive,
  ];
}
