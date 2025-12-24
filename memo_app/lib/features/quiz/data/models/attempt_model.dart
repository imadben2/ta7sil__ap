import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/quiz_attempt_entity.dart';
import 'question_model.dart';

part 'attempt_model.g.dart';

@JsonSerializable(explicitToJson: true)
class QuizAttemptModel extends QuizAttemptEntity {
  @JsonKey(name: 'id')
  final int modelId;

  @JsonKey(name: 'quiz_id')
  final int modelQuizId;

  @JsonKey(name: 'user_id')
  final int modelUserId;

  @JsonKey(name: 'started_at')
  final DateTime modelStartedAt;

  @JsonKey(name: 'completed_at')
  final DateTime? modelCompletedAt;

  @JsonKey(name: 'status')
  final String modelStatus;

  @JsonKey(name: 'time_limit_seconds')
  final int? modelTimeLimitSeconds;

  @JsonKey(name: 'expires_at')
  final DateTime? modelExpiresAt;

  @JsonKey(name: 'time_spent_seconds', defaultValue: 0)
  final int modelTimeSpentSeconds;

  @JsonKey(name: 'questions', defaultValue: [])
  final List<QuestionModel> modelQuestions;

  @JsonKey(name: 'answers', defaultValue: {})
  final Map<String, dynamic> modelAnswers;

  @JsonKey(name: 'score')
  final QuizScoreModel? modelScore;

  QuizAttemptModel({
    required this.modelId,
    required this.modelQuizId,
    required this.modelUserId,
    required this.modelStartedAt,
    this.modelCompletedAt,
    required this.modelStatus,
    this.modelTimeLimitSeconds,
    this.modelExpiresAt,
    required this.modelTimeSpentSeconds,
    required this.modelQuestions,
    required this.modelAnswers,
    this.modelScore,
  }) : super(
         id: modelId,
         quizId: modelQuizId,
         userId: modelUserId,
         startedAt: modelStartedAt,
         completedAt: modelCompletedAt,
         status: _statusFromString(modelStatus),
         timeLimitSeconds: modelTimeLimitSeconds,
         expiresAt: modelExpiresAt,
         timeSpentSeconds: modelTimeSpentSeconds,
         questions: const [],
         answers: const {},
         score: modelScore,
       );

  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) =>
      _$QuizAttemptModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuizAttemptModelToJson(this);

  QuizAttemptEntity toEntity() {
    return QuizAttemptEntity(
      id: modelId,
      quizId: modelQuizId,
      userId: modelUserId,
      startedAt: modelStartedAt,
      completedAt: modelCompletedAt,
      status: _statusFromString(modelStatus),
      timeLimitSeconds: modelTimeLimitSeconds,
      expiresAt: modelExpiresAt,
      timeSpentSeconds: modelTimeSpentSeconds,
      questions: modelQuestions.map((q) => q.toEntity()).toList(),
      answers: Map<int, dynamic>.from(
        modelAnswers.map((k, v) => MapEntry(int.parse(k), v)),
      ),
      score: modelScore,
    );
  }

  static QuizAttemptStatus _statusFromString(String status) {
    switch (status) {
      case 'in_progress':
        return QuizAttemptStatus.inProgress;
      case 'completed':
        return QuizAttemptStatus.completed;
      case 'abandoned':
        return QuizAttemptStatus.abandoned;
      default:
        return QuizAttemptStatus.inProgress;
    }
  }
}

@JsonSerializable()
class QuizScoreModel extends QuizScore {
  @JsonKey(name: 'percentage')
  final double modelPercentage;

  @JsonKey(name: 'total_points')
  final double modelTotalPoints;

  @JsonKey(name: 'earned_points')
  final double modelEarnedPoints;

  @JsonKey(name: 'passed')
  final bool modelPassed;

  @JsonKey(name: 'correct_answers')
  final int modelCorrectAnswers;

  @JsonKey(name: 'incorrect_answers')
  final int modelIncorrectAnswers;

  @JsonKey(name: 'skipped_answers')
  final int modelSkippedAnswers;

  const QuizScoreModel({
    required this.modelPercentage,
    required this.modelTotalPoints,
    required this.modelEarnedPoints,
    required this.modelPassed,
    required this.modelCorrectAnswers,
    required this.modelIncorrectAnswers,
    required this.modelSkippedAnswers,
  }) : super(
         percentage: modelPercentage,
         totalPoints: modelTotalPoints,
         earnedPoints: modelEarnedPoints,
         passed: modelPassed,
         correctAnswers: modelCorrectAnswers,
         incorrectAnswers: modelIncorrectAnswers,
         skippedAnswers: modelSkippedAnswers,
       );

  factory QuizScoreModel.fromJson(Map<String, dynamic> json) =>
      _$QuizScoreModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuizScoreModelToJson(this);
}
