// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizModel _$QuizModelFromJson(Map<String, dynamic> json) => QuizModel(
      modelId: (json['id'] as num).toInt(),
      modelTitleAr: json['title_ar'] as String,
      modelDescriptionAr: json['description_ar'] as String?,
      modelAcademicStreamId: (json['academic_stream_id'] as num?)?.toInt(),
      modelAcademicStream: json['academic_stream'] == null
          ? null
          : AcademicStreamInfoModel.fromJson(
              json['academic_stream'] as Map<String, dynamic>),
      modelQuizType: json['quiz_type'] as String,
      modelTimeLimitMinutes: (json['time_limit_minutes'] as num?)?.toInt(),
      modelPassingScore: (json['passing_score'] as num).toDouble(),
      modelDifficultyLevel: json['difficulty_level'] as String,
      modelEstimatedDurationMinutes:
          (json['estimated_duration_minutes'] as num).toInt(),
      modelTotalQuestions: (json['total_questions'] as num).toInt(),
      modelAverageScore: (json['average_score'] as num?)?.toDouble(),
      modelTotalAttempts: (json['total_attempts'] as num).toInt(),
      modelIsPremium: json['is_premium'] as bool,
      modelTags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      modelSubject: json['subject'] == null
          ? null
          : SubjectInfoModel.fromJson(json['subject'] as Map<String, dynamic>),
      modelChapter: json['chapter'] == null
          ? null
          : ChapterInfoModel.fromJson(json['chapter'] as Map<String, dynamic>),
      modelUserStats: json['user_stats'] == null
          ? null
          : UserQuizStatsModel.fromJson(
              json['user_stats'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QuizModelToJson(QuizModel instance) => <String, dynamic>{
      'id': instance.modelId,
      'title_ar': instance.modelTitleAr,
      'description_ar': instance.modelDescriptionAr,
      'academic_stream_id': instance.modelAcademicStreamId,
      'academic_stream': instance.modelAcademicStream?.toJson(),
      'quiz_type': instance.modelQuizType,
      'time_limit_minutes': instance.modelTimeLimitMinutes,
      'passing_score': instance.modelPassingScore,
      'difficulty_level': instance.modelDifficultyLevel,
      'estimated_duration_minutes': instance.modelEstimatedDurationMinutes,
      'total_questions': instance.modelTotalQuestions,
      'average_score': instance.modelAverageScore,
      'total_attempts': instance.modelTotalAttempts,
      'is_premium': instance.modelIsPremium,
      'tags': instance.modelTags,
      'subject': instance.modelSubject?.toJson(),
      'chapter': instance.modelChapter?.toJson(),
      'user_stats': instance.modelUserStats?.toJson(),
    };

SubjectInfoModel _$SubjectInfoModelFromJson(Map<String, dynamic> json) =>
    SubjectInfoModel(
      modelId: (json['id'] as num).toInt(),
      modelNameAr: json['name_ar'] as String,
      modelColor: json['color'] as String?,
      modelIcon: json['icon'] as String?,
    );

Map<String, dynamic> _$SubjectInfoModelToJson(SubjectInfoModel instance) =>
    <String, dynamic>{
      'id': instance.modelId,
      'name_ar': instance.modelNameAr,
      'color': instance.modelColor,
      'icon': instance.modelIcon,
    };

ChapterInfoModel _$ChapterInfoModelFromJson(Map<String, dynamic> json) =>
    ChapterInfoModel(
      modelId: (json['id'] as num).toInt(),
      modelNameAr: json['name_ar'] as String,
    );

Map<String, dynamic> _$ChapterInfoModelToJson(ChapterInfoModel instance) =>
    <String, dynamic>{
      'id': instance.modelId,
      'name_ar': instance.modelNameAr,
    };

UserQuizStatsModel _$UserQuizStatsModelFromJson(Map<String, dynamic> json) =>
    UserQuizStatsModel(
      modelAttemptsCount: (json['attempts_count'] as num).toInt(),
      modelBestScore: (json['best_score'] as num?)?.toDouble(),
      modelLastAttemptAt: json['last_attempt_at'] == null
          ? null
          : DateTime.parse(json['last_attempt_at'] as String),
      modelLastAttemptId: (json['last_attempt_id'] as num?)?.toInt(),
      modelHasInProgress: json['has_in_progress'] as bool,
    );

Map<String, dynamic> _$UserQuizStatsModelToJson(UserQuizStatsModel instance) =>
    <String, dynamic>{
      'attempts_count': instance.modelAttemptsCount,
      'best_score': instance.modelBestScore,
      'last_attempt_at': instance.modelLastAttemptAt?.toIso8601String(),
      'last_attempt_id': instance.modelLastAttemptId,
      'has_in_progress': instance.modelHasInProgress,
    };

AcademicStreamInfoModel _$AcademicStreamInfoModelFromJson(
        Map<String, dynamic> json) =>
    AcademicStreamInfoModel(
      modelId: (json['id'] as num).toInt(),
      modelNameAr: json['name_ar'] as String,
      modelSlug: json['slug'] as String?,
    );

Map<String, dynamic> _$AcademicStreamInfoModelToJson(
        AcademicStreamInfoModel instance) =>
    <String, dynamic>{
      'id': instance.modelId,
      'name_ar': instance.modelNameAr,
      'slug': instance.modelSlug,
    };
