// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizPerformanceModel _$QuizPerformanceModelFromJson(
        Map<String, dynamic> json) =>
    QuizPerformanceModel(
      modelOverall:
          OverallStatsModel.fromJson(json['overall'] as Map<String, dynamic>),
      modelBySubject: (json['by_subject'] as List<dynamic>)
          .map((e) =>
              SubjectPerformanceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      modelByQuestionType:
          (json['by_question_type'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, QuestionTypeStatsModel.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$QuizPerformanceModelToJson(
        QuizPerformanceModel instance) =>
    <String, dynamic>{
      'overall': instance.modelOverall,
      'by_subject': instance.modelBySubject,
      'by_question_type': instance.modelByQuestionType,
    };

OverallStatsModel _$OverallStatsModelFromJson(Map<String, dynamic> json) =>
    OverallStatsModel(
      modelTotalAttempts: (json['total_attempts'] as num).toInt(),
      modelTotalQuizzes: (json['total_quizzes'] as num).toInt(),
      modelAverageScore: (json['average_score'] as num).toDouble(),
      modelBestScore: (json['best_score'] as num).toDouble(),
      modelPassRate: (json['pass_rate'] as num).toDouble(),
      modelTotalTimeSpentHours:
          (json['total_time_spent_hours'] as num).toDouble(),
    );

Map<String, dynamic> _$OverallStatsModelToJson(OverallStatsModel instance) =>
    <String, dynamic>{
      'total_attempts': instance.modelTotalAttempts,
      'total_quizzes': instance.modelTotalQuizzes,
      'average_score': instance.modelAverageScore,
      'best_score': instance.modelBestScore,
      'pass_rate': instance.modelPassRate,
      'total_time_spent_hours': instance.modelTotalTimeSpentHours,
    };

SubjectPerformanceModel _$SubjectPerformanceModelFromJson(
        Map<String, dynamic> json) =>
    SubjectPerformanceModel(
      modelSubjectId: (json['subject_id'] as num).toInt(),
      modelSubjectNameAr: json['subject_name_ar'] as String,
      modelAttempts: (json['attempts'] as num).toInt(),
      modelAverageScore: (json['average_score'] as num).toDouble(),
      modelBestScore: (json['best_score'] as num).toDouble(),
      modelWeakConcepts: (json['weak_concepts'] as List<dynamic>)
          .map((e) => WeakConceptModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubjectPerformanceModelToJson(
        SubjectPerformanceModel instance) =>
    <String, dynamic>{
      'subject_id': instance.modelSubjectId,
      'subject_name_ar': instance.modelSubjectNameAr,
      'attempts': instance.modelAttempts,
      'average_score': instance.modelAverageScore,
      'best_score': instance.modelBestScore,
      'weak_concepts': instance.modelWeakConcepts,
    };

WeakConceptModel _$WeakConceptModelFromJson(Map<String, dynamic> json) =>
    WeakConceptModel(
      modelConcept: json['concept'] as String,
      modelErrorRate: (json['error_rate'] as num).toDouble(),
    );

Map<String, dynamic> _$WeakConceptModelToJson(WeakConceptModel instance) =>
    <String, dynamic>{
      'concept': instance.modelConcept,
      'error_rate': instance.modelErrorRate,
    };

QuestionTypeStatsModel _$QuestionTypeStatsModelFromJson(
        Map<String, dynamic> json) =>
    QuestionTypeStatsModel(
      modelQuestionType: json['question_type'] as String,
      modelTotal: (json['total'] as num).toInt(),
      modelCorrect: (json['correct'] as num).toInt(),
      modelAccuracy: (json['accuracy'] as num).toDouble(),
    );

Map<String, dynamic> _$QuestionTypeStatsModelToJson(
        QuestionTypeStatsModel instance) =>
    <String, dynamic>{
      'question_type': instance.modelQuestionType,
      'total': instance.modelTotal,
      'correct': instance.modelCorrect,
      'accuracy': instance.modelAccuracy,
    };
