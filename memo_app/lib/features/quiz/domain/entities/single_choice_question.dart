import 'question_entity.dart';

/// Single choice question entity (اختيار واحد)
///
/// User selects exactly one option from multiple choices.
/// Example: "What is 2+2?" with options ["3", "4", "5", "6"]
class SingleChoiceQuestion extends QuestionEntity {
  /// List of options to choose from
  final List<String> options;

  /// Index of the correct option (0-based)
  final int correctAnswerIndex;

  const SingleChoiceQuestion({
    required super.id,
    required super.questionTextAr,
    super.questionImageUrl,
    required super.points,
    super.explanationAr,
    super.difficulty,
    super.tags,
    required super.questionOrder,
    required this.options,
    required this.correctAnswerIndex,
  }) : super(questionType: 'single_choice');

  /// Validate user answer
  bool isAnswerCorrect(int userAnswerIndex) {
    return userAnswerIndex == correctAnswerIndex;
  }

  /// Get correct option text
  String get correctOptionText {
    if (correctAnswerIndex >= 0 && correctAnswerIndex < options.length) {
      return options[correctAnswerIndex];
    }
    return '';
  }

  @override
  List<Object?> get props => [...super.props, options, correctAnswerIndex];
}
