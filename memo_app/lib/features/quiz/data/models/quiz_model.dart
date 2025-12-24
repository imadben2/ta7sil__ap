import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/quiz_entity.dart';

part 'quiz_model.g.dart';

@JsonSerializable(explicitToJson: true)
class QuizModel extends QuizEntity {
  @JsonKey(name: 'id')
  final int modelId;

  @JsonKey(name: 'title_ar')
  final String modelTitleAr;

  @JsonKey(name: 'description_ar')
  final String? modelDescriptionAr;

  @JsonKey(name: 'academic_stream_id')
  final int? modelAcademicStreamId;

  @JsonKey(name: 'academic_stream')
  final AcademicStreamInfoModel? modelAcademicStream;

  @JsonKey(name: 'quiz_type')
  final String modelQuizType;

  @JsonKey(name: 'time_limit_minutes')
  final int? modelTimeLimitMinutes;

  @JsonKey(name: 'passing_score')
  final double modelPassingScore;

  @JsonKey(name: 'difficulty_level')
  final String modelDifficultyLevel;

  @JsonKey(name: 'estimated_duration_minutes')
  final int modelEstimatedDurationMinutes;

  @JsonKey(name: 'total_questions')
  final int modelTotalQuestions;

  @JsonKey(name: 'average_score')
  final double? modelAverageScore;

  @JsonKey(name: 'total_attempts')
  final int modelTotalAttempts;

  @JsonKey(name: 'is_premium')
  final bool modelIsPremium;

  @JsonKey(name: 'tags')
  final List<String>? modelTags;

  @JsonKey(name: 'subject')
  final SubjectInfoModel? modelSubject;

  @JsonKey(name: 'chapter')
  final ChapterInfoModel? modelChapter;

  @JsonKey(name: 'user_stats')
  final UserQuizStatsModel? modelUserStats;

  const QuizModel({
    required this.modelId,
    required this.modelTitleAr,
    this.modelDescriptionAr,
    this.modelAcademicStreamId,
    this.modelAcademicStream,
    required this.modelQuizType,
    this.modelTimeLimitMinutes,
    required this.modelPassingScore,
    required this.modelDifficultyLevel,
    required this.modelEstimatedDurationMinutes,
    required this.modelTotalQuestions,
    this.modelAverageScore,
    required this.modelTotalAttempts,
    required this.modelIsPremium,
    this.modelTags,
    this.modelSubject,
    this.modelChapter,
    this.modelUserStats,
  }) : super(
         id: modelId,
         titleAr: modelTitleAr,
         descriptionAr: modelDescriptionAr,
         academicStreamId: modelAcademicStreamId,
         academicStream: modelAcademicStream,
         quizType: modelQuizType,
         timeLimitMinutes: modelTimeLimitMinutes,
         passingScore: modelPassingScore,
         difficultyLevel: modelDifficultyLevel,
         estimatedDurationMinutes: modelEstimatedDurationMinutes,
         totalQuestions: modelTotalQuestions,
         averageScore: modelAverageScore,
         totalAttempts: modelTotalAttempts,
         isPremium: modelIsPremium,
         tags: modelTags,
         subject: modelSubject,
         chapter: modelChapter,
         userStats: modelUserStats,
       );

  factory QuizModel.fromJson(Map<String, dynamic> json) =>
      _$QuizModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuizModelToJson(this);
}

@JsonSerializable()
class SubjectInfoModel extends SubjectInfo {
  @JsonKey(name: 'id')
  final int modelId;

  @JsonKey(name: 'name_ar')
  final String modelNameAr;

  @JsonKey(name: 'color')
  final String? modelColor;

  @JsonKey(name: 'icon')
  final String? modelIcon;

  const SubjectInfoModel({
    required this.modelId,
    required this.modelNameAr,
    this.modelColor,
    this.modelIcon,
  }) : super(
         id: modelId,
         nameAr: modelNameAr,
         color: modelColor,
         icon: modelIcon,
       );

  factory SubjectInfoModel.fromJson(Map<String, dynamic> json) =>
      _$SubjectInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectInfoModelToJson(this);
}

@JsonSerializable()
class ChapterInfoModel extends ChapterInfo {
  @JsonKey(name: 'id')
  final int modelId;

  @JsonKey(name: 'name_ar')
  final String modelNameAr;

  const ChapterInfoModel({required this.modelId, required this.modelNameAr})
    : super(id: modelId, nameAr: modelNameAr);

  factory ChapterInfoModel.fromJson(Map<String, dynamic> json) =>
      _$ChapterInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChapterInfoModelToJson(this);
}

@JsonSerializable()
class UserQuizStatsModel extends UserQuizStats {
  @JsonKey(name: 'attempts_count')
  final int modelAttemptsCount;

  @JsonKey(name: 'best_score')
  final double? modelBestScore;

  @JsonKey(name: 'last_attempt_at')
  final DateTime? modelLastAttemptAt;

  @JsonKey(name: 'last_attempt_id')
  final int? modelLastAttemptId;

  @JsonKey(name: 'has_in_progress')
  final bool modelHasInProgress;

  const UserQuizStatsModel({
    required this.modelAttemptsCount,
    this.modelBestScore,
    this.modelLastAttemptAt,
    this.modelLastAttemptId,
    required this.modelHasInProgress,
  }) : super(
         attemptsCount: modelAttemptsCount,
         bestScore: modelBestScore,
         lastAttemptAt: modelLastAttemptAt,
         lastAttemptId: modelLastAttemptId,
         hasInProgress: modelHasInProgress,
       );

  factory UserQuizStatsModel.fromJson(Map<String, dynamic> json) =>
      _$UserQuizStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserQuizStatsModelToJson(this);
}

@JsonSerializable()
class AcademicStreamInfoModel extends AcademicStreamInfo {
  @JsonKey(name: 'id')
  final int modelId;

  @JsonKey(name: 'name_ar')
  final String modelNameAr;

  @JsonKey(name: 'slug')
  final String? modelSlug;

  const AcademicStreamInfoModel({
    required this.modelId,
    required this.modelNameAr,
    this.modelSlug,
  }) : super(
         id: modelId,
         nameAr: modelNameAr,
         slug: modelSlug,
       );

  factory AcademicStreamInfoModel.fromJson(Map<String, dynamic> json) =>
      _$AcademicStreamInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$AcademicStreamInfoModelToJson(this);
}
