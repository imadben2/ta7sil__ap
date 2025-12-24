import 'question_entity.dart';

/// True/False question entity (صح أم خطأ)
///
/// User selects either true (صح) or false (خطأ).
/// Example: "الأرض كروية الشكل" → True
class TrueFalseQuestion extends QuestionEntity {
  /// The correct answer (true or false)
  final bool correctAnswer;

  const TrueFalseQuestion({
    required super.id,
    required super.questionTextAr,
    super.questionImageUrl,
    required super.points,
    super.explanationAr,
    super.difficulty,
    super.tags,
    required super.questionOrder,
    required this.correctAnswer,
  }) : super(questionType: 'true_false');

  /// Validate user answer
  bool isAnswerCorrect(bool userAnswer) {
    return userAnswer == correctAnswer;
  }

  /// Get correct answer text in Arabic
  String get correctAnswerTextAr => correctAnswer ? 'صح' : 'خطأ';

  @override
  List<Object?> get props => [...super.props, correctAnswer];
}
