// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizResultModel _$QuizResultModelFromJson(Map<String, dynamic> json) =>
    QuizResultModel(
      modelAttemptId: _parseInt(json['attempt_id']),
      modelQuizId: _parseInt(json['quiz_id']),
      modelQuizTitleAr: json['quiz_title_ar'] as String,
      modelSubjectId: _parseIntNullable(json['subject_id']),
      modelSubjectNameAr: json['subject_name_ar'] as String?,
      modelPercentage: _parseDouble(json['percentage']),
      modelTotalPoints: _parseDouble(json['total_points']),
      modelEarnedPoints: _parseDouble(json['earned_points']),
      modelPassed: json['passed'] as bool,
      modelPassingScore: _parseDouble(json['passing_score']),
      modelCorrectAnswers: _parseInt(json['correct_answers']),
      modelIncorrectAnswers: _parseInt(json['incorrect_answers']),
      modelSkippedAnswers: _parseInt(json['skipped_answers']),
      modelTotalQuestions: _parseInt(json['total_questions']),
      modelTimeSpentSeconds: json['time_spent_seconds'] == null
          ? 0
          : _parseInt(json['time_spent_seconds']),
      modelQuestionResults: (json['questions'] as List<dynamic>?)
              ?.map((e) =>
                  QuestionFeedbackModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      modelWeakConcepts: (json['weak_concepts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      modelAllowReview: json['allow_review'] as bool? ?? true,
      modelCompletedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
    );

Map<String, dynamic> _$QuizResultModelToJson(QuizResultModel instance) =>
    <String, dynamic>{
      'attempt_id': instance.modelAttemptId,
      'quiz_id': instance.modelQuizId,
      'quiz_title_ar': instance.modelQuizTitleAr,
      'subject_id': instance.modelSubjectId,
      'subject_name_ar': instance.modelSubjectNameAr,
      'percentage': instance.modelPercentage,
      'total_points': instance.modelTotalPoints,
      'earned_points': instance.modelEarnedPoints,
      'passed': instance.modelPassed,
      'passing_score': instance.modelPassingScore,
      'correct_answers': instance.modelCorrectAnswers,
      'incorrect_answers': instance.modelIncorrectAnswers,
      'skipped_answers': instance.modelSkippedAnswers,
      'total_questions': instance.modelTotalQuestions,
      'time_spent_seconds': instance.modelTimeSpentSeconds,
      'questions': instance.modelQuestionResults,
      'weak_concepts': instance.modelWeakConcepts,
      'allow_review': instance.modelAllowReview,
      'completed_at': instance.modelCompletedAt?.toIso8601String(),
    };

QuestionFeedbackModel _$QuestionFeedbackModelFromJson(
        Map<String, dynamic> json) =>
    QuestionFeedbackModel(
      modelQuestion:
          QuestionModel.fromJson(json['question'] as Map<String, dynamic>),
      modelUserAnswer: json['user_answer'],
      modelCorrectAnswer: json['correct_answer'],
      modelIsCorrect: json['is_correct'] as bool,
      modelPointsEarned: _parseDouble(json['points_earned']),
      modelTimeSpentSeconds: _parseIntNullable(json['time_spent_seconds']),
    );

Map<String, dynamic> _$QuestionFeedbackModelToJson(
        QuestionFeedbackModel instance) =>
    <String, dynamic>{
      'question': instance.modelQuestion,
      'user_answer': instance.modelUserAnswer,
      'correct_answer': instance.modelCorrectAnswer,
      'is_correct': instance.modelIsCorrect,
      'points_earned': instance.modelPointsEarned,
      'time_spent_seconds': instance.modelTimeSpentSeconds,
    };
