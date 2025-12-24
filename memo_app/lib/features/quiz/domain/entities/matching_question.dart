import 'question_entity.dart';

/// Matching question entity (المطابقة)
///
/// User matches items from left column to items in right column.
/// Supports partial credit for correct pairs.
/// Example: Match scientists with their inventions
class MatchingQuestion extends QuestionEntity {
  /// Left side items to match
  final List<String> leftItems;

  /// Right side items to match with
  final List<String> rightItems;

  /// Correct pairs: Map of left index to right index
  /// Example: {0: 2, 1: 0, 2: 1} means leftItem[0] → rightItem[2]
  final Map<int, int> correctPairs;

  /// Whether partial credit is awarded
  final bool allowPartialCredit;

  const MatchingQuestion({
    required super.id,
    required super.questionTextAr,
    super.questionImageUrl,
    required super.points,
    super.explanationAr,
    super.difficulty,
    super.tags,
    required super.questionOrder,
    required this.leftItems,
    required this.rightItems,
    required this.correctPairs,
    this.allowPartialCredit = true,
  }) : super(questionType: 'matching');

  /// Calculate points earned based on user's matches
  ///
  /// Partial credit formula:
  /// points_earned = (correct_pairs / total_pairs) * points
  double calculatePointsEarned(Map<int, int> userPairs) {
    if (userPairs.isEmpty) return 0.0;

    int correctCount = 0;
    userPairs.forEach((leftIndex, rightIndex) {
      if (correctPairs[leftIndex] == rightIndex) {
        correctCount++;
      }
    });

    if (correctCount == correctPairs.length &&
        userPairs.length == correctPairs.length) {
      return points; // Perfect answer
    }

    if (!allowPartialCredit) return 0.0;

    // Partial credit
    final credit = correctCount / correctPairs.length;
    return credit * points;
  }

  /// Check if answer is completely correct
  bool isAnswerCorrect(Map<int, int> userPairs) {
    if (userPairs.length != correctPairs.length) return false;

    return correctPairs.entries.every((entry) {
      return userPairs[entry.key] == entry.value;
    });
  }

  /// Alias for leftItems (for backward compatibility)
  List<String> get leftColumn => leftItems;

  /// Alias for rightItems (for backward compatibility)
  List<String> get rightColumn => rightItems;

  @override
  List<Object?> get props => [
    ...super.props,
    leftItems,
    rightItems,
    correctPairs,
    allowPartialCredit,
  ];
}
