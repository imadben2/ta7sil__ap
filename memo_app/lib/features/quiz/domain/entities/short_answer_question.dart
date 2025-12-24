import 'question_entity.dart';

/// Short answer question entity (إجابة قصيرة)
///
/// User provides an open-ended text answer.
/// Uses keyword matching for auto-correction with manual review fallback.
/// Example: "اشرح قانون نيوتن الثاني للحركة"
class ShortAnswerQuestion extends QuestionEntity {
  /// Keywords that should appear in the answer
  final List<String> keywords;

  /// Model answer text
  final String modelAnswer;

  /// Minimum keyword match rate for auto-correct (0.0 - 1.0)
  final double autoCorrectThreshold;

  /// Minimum character length required
  final int minCharacters;

  const ShortAnswerQuestion({
    required super.id,
    required super.questionTextAr,
    super.questionImageUrl,
    required super.points,
    super.explanationAr,
    super.difficulty,
    super.tags,
    required super.questionOrder,
    required this.keywords,
    required this.modelAnswer,
    this.autoCorrectThreshold = 0.8,
    this.minCharacters = 50,
  }) : super(questionType: 'short_answer');

  /// Calculate keyword match rate
  ///
  /// Returns a score between 0.0 and 1.0 based on how many keywords
  /// are present in the user's answer
  double calculateKeywordMatchRate(String userAnswer) {
    if (keywords.isEmpty) return 0.0;

    final normalizedAnswer = _normalizeText(userAnswer);
    int matchedKeywords = 0;

    for (final keyword in keywords) {
      final normalizedKeyword = _normalizeText(keyword);
      if (normalizedAnswer.contains(normalizedKeyword)) {
        matchedKeywords++;
      }
    }

    return matchedKeywords / keywords.length;
  }

  /// Determine if answer can be auto-corrected or needs manual review
  ///
  /// Returns:
  /// - AutoCorrectResult.correct: High keyword match (≥ threshold)
  /// - AutoCorrectResult.needsReview: Medium keyword match
  /// - AutoCorrectResult.incorrect: Low keyword match or too short
  AutoCorrectResult evaluateAnswer(String userAnswer) {
    // Check minimum length
    if (userAnswer.trim().length < minCharacters) {
      return AutoCorrectResult.incorrect;
    }

    final matchRate = calculateKeywordMatchRate(userAnswer);

    if (matchRate >= autoCorrectThreshold) {
      return AutoCorrectResult.correct;
    } else if (matchRate >= 0.4) {
      return AutoCorrectResult.needsReview;
    } else {
      return AutoCorrectResult.incorrect;
    }
  }

  /// Normalize Arabic text for comparison
  String _normalizeText(String text) {
    String normalized = text.trim().toLowerCase();

    // Remove Arabic diacritics
    normalized = normalized.replaceAll(RegExp(r'[\u064B-\u065F]'), '');

    // Normalize alef variants
    normalized = normalized
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا');

    // Normalize taa marbuta
    normalized = normalized.replaceAll('ة', 'ه');

    // Normalize alef maqsura
    normalized = normalized.replaceAll('ى', 'ي');

    // Remove extra whitespace
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');

    return normalized;
  }

  @override
  List<Object?> get props => [
    ...super.props,
    keywords,
    modelAnswer,
    autoCorrectThreshold,
    minCharacters,
  ];
}

/// Result of auto-correction evaluation
enum AutoCorrectResult {
  /// Answer is correct (high keyword match)
  correct,

  /// Answer needs manual review (medium keyword match)
  needsReview,

  /// Answer is incorrect (low keyword match or too short)
  incorrect,
}
