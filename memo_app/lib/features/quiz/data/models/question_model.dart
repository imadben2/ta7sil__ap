import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/entities/single_choice_question.dart';
import '../../domain/entities/multiple_choice_question.dart';
import '../../domain/entities/true_false_question.dart';
import '../../domain/entities/matching_question.dart';
import '../../domain/entities/ordering_question.dart';
import '../../domain/entities/fill_blank_question.dart';
import '../../domain/entities/short_answer_question.dart';
import '../../domain/entities/numeric_question.dart';

part 'question_model.g.dart';

@JsonSerializable()
class QuestionModel {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'question_type')
  final String questionType;

  @JsonKey(name: 'question_text_ar')
  final String questionTextAr;

  @JsonKey(name: 'question_image_url')
  final String? questionImageUrl;

  @JsonKey(name: 'options')
  final dynamic options;

  @JsonKey(name: 'correct_answer')
  final dynamic correctAnswer;

  @JsonKey(name: 'points', defaultValue: 1.0)
  final double points;

  @JsonKey(name: 'explanation_ar')
  final String? explanationAr;

  @JsonKey(name: 'difficulty')
  final String? difficulty;

  @JsonKey(name: 'tags')
  final List<String>? tags;

  @JsonKey(name: 'question_order', defaultValue: 0)
  final int questionOrder;

  const QuestionModel({
    required this.id,
    required this.questionType,
    required this.questionTextAr,
    this.questionImageUrl,
    this.options,
    this.correctAnswer,
    this.points = 1.0,
    this.explanationAr,
    this.difficulty,
    this.tags,
    this.questionOrder = 0,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionModelToJson(this);

  /// Convert model to appropriate entity based on question type
  QuestionEntity toEntity() {
    switch (questionType) {
      case 'single_choice':
      case 'mcq_single': // API uses mcq_single
        // Options can be List directly from API or Map with 'options' key
        final optionsList = options is List
            ? options as List
            : (options is Map ? (options['options'] ?? []) : []);
        // Extract text from option objects if needed
        final optionTexts = optionsList.map<String>((opt) {
          if (opt is Map) {
            return (opt['text'] ?? opt['text_ar'] ?? opt.toString()) as String;
          }
          return opt.toString();
        }).toList();
        return SingleChoiceQuestion(
          id: id,
          questionTextAr: questionTextAr,
          questionImageUrl: questionImageUrl,
          points: points,
          explanationAr: explanationAr,
          difficulty: difficulty,
          tags: tags,
          questionOrder: questionOrder,
          options: optionTexts,
          correctAnswerIndex: correctAnswer is int ? correctAnswer as int : 0,
        );

      case 'multiple_choice':
      case 'mcq_multiple': // API uses mcq_multiple
        // Options can be List directly from API or Map with 'options' key
        final optionsList = options is List
            ? options as List
            : (options is Map ? (options['options'] ?? []) : []);
        // Extract text from option objects if needed
        final optionTexts = optionsList.map<String>((opt) {
          if (opt is Map) {
            return (opt['text'] ?? opt['text_ar'] ?? opt.toString()) as String;
          }
          return opt.toString();
        }).toList();
        return MultipleChoiceQuestion(
          id: id,
          questionTextAr: questionTextAr,
          questionImageUrl: questionImageUrl,
          points: points,
          explanationAr: explanationAr,
          difficulty: difficulty,
          tags: tags,
          questionOrder: questionOrder,
          options: optionTexts,
          correctAnswerIndices: correctAnswer is List
              ? List<int>.from(correctAnswer as List)
              : <int>[],
        );

      case 'true_false':
        return TrueFalseQuestion(
          id: id,
          questionTextAr: questionTextAr,
          questionImageUrl: questionImageUrl,
          points: points,
          explanationAr: explanationAr,
          difficulty: difficulty,
          tags: tags,
          questionOrder: questionOrder,
          correctAnswer: correctAnswer is bool ? correctAnswer as bool : false,
        );

      case 'matching':
        final optionsMap = options is Map<String, dynamic>
            ? options as Map<String, dynamic>
            : <String, dynamic>{};
        return MatchingQuestion(
          id: id,
          questionTextAr: questionTextAr,
          questionImageUrl: questionImageUrl,
          points: points,
          explanationAr: explanationAr,
          difficulty: difficulty,
          tags: tags,
          questionOrder: questionOrder,
          leftItems: List<String>.from(optionsMap['left'] ?? []),
          rightItems: List<String>.from(optionsMap['right'] ?? []),
          correctPairs: correctAnswer is Map
              ? Map<int, int>.from(
                  (correctAnswer as Map).map(
                    (k, v) => MapEntry(int.parse(k.toString()), v as int),
                  ),
                )
              : <int, int>{},
        );

      case 'ordering':
      case 'sequence': // API uses sequence
        final orderingOptions = options is Map
            ? (options as Map)['items'] ?? []
            : (options is List ? options : []);
        return OrderingQuestion(
          id: id,
          questionTextAr: questionTextAr,
          questionImageUrl: questionImageUrl,
          points: points,
          explanationAr: explanationAr,
          difficulty: difficulty,
          tags: tags,
          questionOrder: questionOrder,
          items: List<String>.from(orderingOptions),
          correctOrder: correctAnswer is List
              ? List<int>.from(correctAnswer as List)
              : <int>[],
        );

      case 'fill_blank':
        final answersList =
            correctAnswer is List ? correctAnswer as List : <dynamic>[];
        // Get number of blanks from options (API sends this) or from correct answers length
        final optionsMap = options is Map<String, dynamic>
            ? options as Map<String, dynamic>
            : <String, dynamic>{};
        final numberOfBlanks = optionsMap['number_of_blanks'] as int?
            ?? answersList.length
            ?? 1; // Default to 1 blank if not specified
        return FillBlankQuestion(
          id: id,
          questionTextAr: questionTextAr,
          questionImageUrl: questionImageUrl,
          points: points,
          explanationAr: explanationAr,
          difficulty: difficulty,
          tags: tags,
          questionOrder: questionOrder,
          numberOfBlanks: numberOfBlanks,
          correctAnswers: answersList
              .map((item) => List<String>.from(item is List ? item : [item]))
              .toList(),
        );

      case 'short_answer':
        final answerData = options is Map<String, dynamic>
            ? options as Map<String, dynamic>
            : <String, dynamic>{};
        return ShortAnswerQuestion(
          id: id,
          questionTextAr: questionTextAr,
          questionImageUrl: questionImageUrl,
          points: points,
          explanationAr: explanationAr,
          difficulty: difficulty,
          tags: tags,
          questionOrder: questionOrder,
          keywords: List<String>.from(answerData['keywords'] ?? []),
          modelAnswer: correctAnswer?.toString() ?? '',
        );

      case 'numeric':
        final answerData = options is Map<String, dynamic>
            ? options as Map<String, dynamic>
            : <String, dynamic>{};
        return NumericQuestion(
          id: id,
          questionTextAr: questionTextAr,
          questionImageUrl: questionImageUrl,
          points: points,
          explanationAr: explanationAr,
          difficulty: difficulty,
          tags: tags,
          questionOrder: questionOrder,
          correctAnswer: correctAnswer is num
              ? (correctAnswer as num).toDouble()
              : 0.0,
          tolerance: (answerData['tolerance'] as num?)?.toDouble() ?? 0.01,
          unit: answerData['unit'] as String?,
        );

      default:
        throw Exception('Unknown question type: $questionType');
    }
  }
}
