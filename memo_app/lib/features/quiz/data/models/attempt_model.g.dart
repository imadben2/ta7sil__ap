// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attempt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizAttemptModel _$QuizAttemptModelFromJson(Map<String, dynamic> json) =>
    QuizAttemptModel(
      modelId: (json['id'] as num).toInt(),
      modelQuizId: (json['quiz_id'] as num).toInt(),
      modelUserId: (json['user_id'] as num).toInt(),
      modelStartedAt: DateTime.parse(json['started_at'] as String),
      modelCompletedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      modelStatus: json['status'] as String,
      modelTimeLimitSeconds: (json['time_limit_seconds'] as num?)?.toInt(),
      modelExpiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      modelTimeSpentSeconds: (json['time_spent_seconds'] as num?)?.toInt() ?? 0,
      modelQuestions: (json['questions'] as List<dynamic>?)
              ?.map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      modelAnswers: json['answers'] as Map<String, dynamic>? ?? {},
      modelScore: json['score'] == null
          ? null
          : QuizScoreModel.fromJson(json['score'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QuizAttemptModelToJson(QuizAttemptModel instance) =>
    <String, dynamic>{
      'id': instance.modelId,
      'quiz_id': instance.modelQuizId,
      'user_id': instance.modelUserId,
      'started_at': instance.modelStartedAt.toIso8601String(),
      'completed_at': instance.modelCompletedAt?.toIso8601String(),
      'status': instance.modelStatus,
      'time_limit_seconds': instance.modelTimeLimitSeconds,
      'expires_at': instance.modelExpiresAt?.toIso8601String(),
      'time_spent_seconds': instance.modelTimeSpentSeconds,
      'questions': instance.modelQuestions.map((e) => e.toJson()).toList(),
      'answers': instance.modelAnswers,
      'score': instance.modelScore?.toJson(),
    };

QuizScoreModel _$QuizScoreModelFromJson(Map<String, dynamic> json) =>
    QuizScoreModel(
      modelPercentage: (json['percentage'] as num).toDouble(),
      modelTotalPoints: (json['total_points'] as num).toDouble(),
      modelEarnedPoints: (json['earned_points'] as num).toDouble(),
      modelPassed: json['passed'] as bool,
      modelCorrectAnswers: (json['correct_answers'] as num).toInt(),
      modelIncorrectAnswers: (json['incorrect_answers'] as num).toInt(),
      modelSkippedAnswers: (json['skipped_answers'] as num).toInt(),
    );

Map<String, dynamic> _$QuizScoreModelToJson(QuizScoreModel instance) =>
    <String, dynamic>{
      'percentage': instance.modelPercentage,
      'total_points': instance.modelTotalPoints,
      'earned_points': instance.modelEarnedPoints,
      'passed': instance.modelPassed,
      'correct_answers': instance.modelCorrectAnswers,
      'incorrect_answers': instance.modelIncorrectAnswers,
      'skipped_answers': instance.modelSkippedAnswers,
    };
