import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/quiz_result_entity.dart';
import '../../domain/entities/question_entity.dart';
import 'question_model.dart';

part 'result_model.g.dart';

// Helper functions to safely parse numbers from JSON (handles String or num)
double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

int? _parseIntNullable(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

@JsonSerializable()
class QuizResultModel extends QuizResultEntity {
  @JsonKey(name: 'attempt_id', fromJson: _parseInt)
  final int modelAttemptId;

  @JsonKey(name: 'quiz_id', fromJson: _parseInt)
  final int modelQuizId;

  @JsonKey(name: 'quiz_title_ar')
  final String modelQuizTitleAr;

  @JsonKey(name: 'subject_id', fromJson: _parseIntNullable)
  final int? modelSubjectId;

  @JsonKey(name: 'subject_name_ar')
  final String? modelSubjectNameAr;

  @JsonKey(name: 'percentage', fromJson: _parseDouble)
  final double modelPercentage;

  @JsonKey(name: 'total_points', fromJson: _parseDouble)
  final double modelTotalPoints;

  @JsonKey(name: 'earned_points', fromJson: _parseDouble)
  final double modelEarnedPoints;

  @JsonKey(name: 'passed')
  final bool modelPassed;

  @JsonKey(name: 'passing_score', fromJson: _parseDouble)
  final double modelPassingScore;

  @JsonKey(name: 'correct_answers', fromJson: _parseInt)
  final int modelCorrectAnswers;

  @JsonKey(name: 'incorrect_answers', fromJson: _parseInt)
  final int modelIncorrectAnswers;

  @JsonKey(name: 'skipped_answers', fromJson: _parseInt)
  final int modelSkippedAnswers;

  @JsonKey(name: 'total_questions', fromJson: _parseInt)
  final int modelTotalQuestions;

  @JsonKey(name: 'time_spent_seconds', fromJson: _parseInt)
  final int modelTimeSpentSeconds;

  @JsonKey(name: 'questions', defaultValue: [])
  final List<QuestionFeedbackModel> modelQuestionResults;

  @JsonKey(name: 'weak_concepts', defaultValue: [])
  final List<String> modelWeakConcepts;

  @JsonKey(name: 'allow_review', defaultValue: true)
  final bool modelAllowReview;

  @JsonKey(name: 'completed_at')
  final DateTime? modelCompletedAt;

  QuizResultModel({
    required this.modelAttemptId,
    required this.modelQuizId,
    required this.modelQuizTitleAr,
    this.modelSubjectId,
    this.modelSubjectNameAr,
    required this.modelPercentage,
    required this.modelTotalPoints,
    required this.modelEarnedPoints,
    required this.modelPassed,
    required this.modelPassingScore,
    required this.modelCorrectAnswers,
    required this.modelIncorrectAnswers,
    required this.modelSkippedAnswers,
    required this.modelTotalQuestions,
    this.modelTimeSpentSeconds = 0,
    this.modelQuestionResults = const [],
    this.modelWeakConcepts = const [],
    this.modelAllowReview = true,
    this.modelCompletedAt,
  }) : super(
         attemptId: modelAttemptId,
         quizId: modelQuizId,
         quizTitleAr: modelQuizTitleAr,
         subjectId: modelSubjectId,
         subjectNameAr: modelSubjectNameAr,
         percentage: modelPercentage,
         totalPoints: modelTotalPoints,
         earnedPoints: modelEarnedPoints,
         passed: modelPassed,
         passingScore: modelPassingScore,
         correctAnswers: modelCorrectAnswers,
         incorrectAnswers: modelIncorrectAnswers,
         skippedAnswers: modelSkippedAnswers,
         totalQuestions: modelTotalQuestions,
         timeSpentSeconds: modelTimeSpentSeconds,
         questionResults: modelQuestionResults,
         weakConcepts: modelWeakConcepts,
         allowReview: modelAllowReview,
         completedAt: modelCompletedAt ?? DateTime.now(),
       );

  factory QuizResultModel.fromJson(Map<String, dynamic> json) =>
      _$QuizResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuizResultModelToJson(this);
}

@JsonSerializable()
class QuestionFeedbackModel extends QuestionWithFeedback {
  @JsonKey(name: 'question')
  final QuestionModel modelQuestion;

  @JsonKey(name: 'user_answer')
  final dynamic modelUserAnswer;

  @JsonKey(name: 'correct_answer')
  final dynamic modelCorrectAnswer;

  @JsonKey(name: 'is_correct')
  final bool modelIsCorrect;

  @JsonKey(name: 'points_earned', fromJson: _parseDouble)
  final double modelPointsEarned;

  @JsonKey(name: 'time_spent_seconds', fromJson: _parseIntNullable)
  final int? modelTimeSpentSeconds;

  QuestionFeedbackModel({
    required this.modelQuestion,
    required this.modelUserAnswer,
    required this.modelCorrectAnswer,
    required this.modelIsCorrect,
    required this.modelPointsEarned,
    this.modelTimeSpentSeconds,
  }) : super(
         question: modelQuestion.toEntity(),
         userAnswer: modelUserAnswer,
         correctAnswer: modelCorrectAnswer,
         isCorrect: modelIsCorrect,
         pointsEarned: modelPointsEarned,
         timeSpentSeconds: modelTimeSpentSeconds,
       );

  factory QuestionFeedbackModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionFeedbackModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionFeedbackModelToJson(this);
}
