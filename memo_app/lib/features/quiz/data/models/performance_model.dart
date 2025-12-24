import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/quiz_performance_entity.dart';

part 'performance_model.g.dart';

@JsonSerializable()
class QuizPerformanceModel extends QuizPerformanceEntity {
  @JsonKey(name: 'overall')
  final OverallStatsModel modelOverall;

  @JsonKey(name: 'by_subject')
  final List<SubjectPerformanceModel> modelBySubject;

  @JsonKey(name: 'by_question_type')
  final Map<String, QuestionTypeStatsModel> modelByQuestionType;

  const QuizPerformanceModel({
    required this.modelOverall,
    required this.modelBySubject,
    required this.modelByQuestionType,
  }) : super(
         overall: modelOverall,
         bySubject: modelBySubject,
         byQuestionType: modelByQuestionType,
       );

  factory QuizPerformanceModel.fromJson(Map<String, dynamic> json) =>
      _$QuizPerformanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuizPerformanceModelToJson(this);
}

@JsonSerializable()
class OverallStatsModel extends OverallStats {
  @JsonKey(name: 'total_attempts')
  final int modelTotalAttempts;

  @JsonKey(name: 'total_quizzes')
  final int modelTotalQuizzes;

  @JsonKey(name: 'average_score')
  final double modelAverageScore;

  @JsonKey(name: 'best_score')
  final double modelBestScore;

  @JsonKey(name: 'pass_rate')
  final double modelPassRate;

  @JsonKey(name: 'total_time_spent_hours')
  final double modelTotalTimeSpentHours;

  const OverallStatsModel({
    required this.modelTotalAttempts,
    required this.modelTotalQuizzes,
    required this.modelAverageScore,
    required this.modelBestScore,
    required this.modelPassRate,
    required this.modelTotalTimeSpentHours,
  }) : super(
         totalAttempts: modelTotalAttempts,
         totalQuizzes: modelTotalQuizzes,
         averageScore: modelAverageScore,
         bestScore: modelBestScore,
         passRate: modelPassRate,
         totalTimeSpentHours: modelTotalTimeSpentHours,
       );

  factory OverallStatsModel.fromJson(Map<String, dynamic> json) =>
      _$OverallStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$OverallStatsModelToJson(this);
}

@JsonSerializable()
class SubjectPerformanceModel extends SubjectPerformance {
  @JsonKey(name: 'subject_id')
  final int modelSubjectId;

  @JsonKey(name: 'subject_name_ar')
  final String modelSubjectNameAr;

  @JsonKey(name: 'attempts')
  final int modelAttempts;

  @JsonKey(name: 'average_score')
  final double modelAverageScore;

  @JsonKey(name: 'best_score')
  final double modelBestScore;

  @JsonKey(name: 'weak_concepts')
  final List<WeakConceptModel> modelWeakConcepts;

  const SubjectPerformanceModel({
    required this.modelSubjectId,
    required this.modelSubjectNameAr,
    required this.modelAttempts,
    required this.modelAverageScore,
    required this.modelBestScore,
    required this.modelWeakConcepts,
  }) : super(
         subjectId: modelSubjectId,
         subjectNameAr: modelSubjectNameAr,
         attempts: modelAttempts,
         averageScore: modelAverageScore,
         bestScore: modelBestScore,
         weakConcepts: modelWeakConcepts,
       );

  factory SubjectPerformanceModel.fromJson(Map<String, dynamic> json) =>
      _$SubjectPerformanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectPerformanceModelToJson(this);
}

@JsonSerializable()
class WeakConceptModel extends WeakConcept {
  @JsonKey(name: 'concept')
  final String modelConcept;

  @JsonKey(name: 'error_rate')
  final double modelErrorRate;

  const WeakConceptModel({
    required this.modelConcept,
    required this.modelErrorRate,
  }) : super(concept: modelConcept, errorRate: modelErrorRate);

  factory WeakConceptModel.fromJson(Map<String, dynamic> json) =>
      _$WeakConceptModelFromJson(json);

  Map<String, dynamic> toJson() => _$WeakConceptModelToJson(this);
}

@JsonSerializable()
class QuestionTypeStatsModel extends QuestionTypeStats {
  @JsonKey(name: 'question_type')
  final String modelQuestionType;

  @JsonKey(name: 'total')
  final int modelTotal;

  @JsonKey(name: 'correct')
  final int modelCorrect;

  @JsonKey(name: 'accuracy')
  final double modelAccuracy;

  const QuestionTypeStatsModel({
    required this.modelQuestionType,
    required this.modelTotal,
    required this.modelCorrect,
    required this.modelAccuracy,
  }) : super(
         questionType: modelQuestionType,
         total: modelTotal,
         correct: modelCorrect,
         accuracy: modelAccuracy,
       );

  factory QuestionTypeStatsModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionTypeStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionTypeStatsModelToJson(this);
}
