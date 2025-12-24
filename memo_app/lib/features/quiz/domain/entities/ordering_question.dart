import 'question_entity.dart';

/// Ordering question entity (الترتيب)
///
/// User arranges items in the correct sequence/order.
/// Example: "ترتيب الأحداث التاريخية حسب تاريخ حدوثها"
class OrderingQuestion extends QuestionEntity {
  /// Items to be ordered (displayed in random/initial order)
  final List<String> items;

  /// Correct order (indices of items in correct sequence)
  /// Example: [2, 0, 3, 1] means items[2], items[0], items[3], items[1]
  final List<int> correctOrder;

  const OrderingQuestion({
    required super.id,
    required super.questionTextAr,
    super.questionImageUrl,
    required super.points,
    super.explanationAr,
    super.difficulty,
    super.tags,
    required super.questionOrder,
    required this.items,
    required this.correctOrder,
  }) : super(questionType: 'ordering');

  /// Check if user's order is correct
  ///
  /// Must match exactly - no partial credit
  bool isAnswerCorrect(List<int> userOrder) {
    if (userOrder.length != correctOrder.length) return false;

    for (int i = 0; i < userOrder.length; i++) {
      if (userOrder[i] != correctOrder[i]) return false;
    }

    return true;
  }

  /// Get items in correct order
  List<String> get itemsInCorrectOrder {
    return correctOrder.map((index) => items[index]).toList();
  }

  @override
  List<Object?> get props => [...super.props, items, correctOrder];
}
