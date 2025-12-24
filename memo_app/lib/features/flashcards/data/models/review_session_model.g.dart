// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewSessionModel _$ReviewSessionModelFromJson(Map<String, dynamic> json) =>
    ReviewSessionModel(
      modelId: const SafeIntConverter().fromJson(json['id']),
      modelDeckId: const SafeNullableIntConverter().fromJson(json['deck_id']),
      modelDeck: json['deck'] == null
          ? null
          : FlashcardDeckModel.fromJson(json['deck'] as Map<String, dynamic>),
      modelStartedAt: DateTime.parse(json['started_at'] as String),
      modelCompletedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      modelDurationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      modelTotalCardsReviewed:
          (json['total_cards_reviewed'] as num?)?.toInt() ?? 0,
      modelNewCardsStudied: (json['new_cards_studied'] as num?)?.toInt() ?? 0,
      modelReviewCardsStudied:
          (json['review_cards_studied'] as num?)?.toInt() ?? 0,
      modelAgainCount: (json['again_count'] as num?)?.toInt() ?? 0,
      modelHardCount: (json['hard_count'] as num?)?.toInt() ?? 0,
      modelGoodCount: (json['good_count'] as num?)?.toInt() ?? 0,
      modelEasyCount: (json['easy_count'] as num?)?.toInt() ?? 0,
      modelAverageResponseTimeSeconds:
          (json['average_response_time_seconds'] as num?)?.toDouble(),
      modelSessionRetentionRate:
          (json['session_retention_rate'] as num?)?.toDouble() ?? 0.0,
      modelStatus: json['status'] as String? ?? 'in_progress',
      modelCardsReviewed: (json['cards_reviewed'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$ReviewSessionModelToJson(ReviewSessionModel instance) =>
    <String, dynamic>{
      'id': const SafeIntConverter().toJson(instance.modelId),
      'deck_id': const SafeNullableIntConverter().toJson(instance.modelDeckId),
      'deck': instance.modelDeck?.toJson(),
      'started_at': instance.modelStartedAt.toIso8601String(),
      'completed_at': instance.modelCompletedAt?.toIso8601String(),
      'duration_seconds': instance.modelDurationSeconds,
      'total_cards_reviewed': instance.modelTotalCardsReviewed,
      'new_cards_studied': instance.modelNewCardsStudied,
      'review_cards_studied': instance.modelReviewCardsStudied,
      'again_count': instance.modelAgainCount,
      'hard_count': instance.modelHardCount,
      'good_count': instance.modelGoodCount,
      'easy_count': instance.modelEasyCount,
      'average_response_time_seconds': instance.modelAverageResponseTimeSeconds,
      'session_retention_rate': instance.modelSessionRetentionRate,
      'status': instance.modelStatus,
      'cards_reviewed': instance.modelCardsReviewed,
    };

AnswerResultModel _$AnswerResultModelFromJson(Map<String, dynamic> json) =>
    AnswerResultModel(
      modelCardId: const SafeIntConverter().fromJson(json['card_id']),
      modelQualityRating:
          const SafeIntConverter().fromJson(json['quality_rating']),
      modelWasCorrect: json['was_correct'] as bool,
      modelReviewData: CardReviewResultModel.fromJson(
          json['review_data'] as Map<String, dynamic>),
      modelSessionProgress: SessionProgressModel.fromJson(
          json['session_progress'] as Map<String, dynamic>),
      modelNextIntervalPreview:
          (json['next_interval_preview'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, IntervalPreviewDataModel.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$AnswerResultModelToJson(AnswerResultModel instance) =>
    <String, dynamic>{
      'card_id': const SafeIntConverter().toJson(instance.modelCardId),
      'quality_rating':
          const SafeIntConverter().toJson(instance.modelQualityRating),
      'was_correct': instance.modelWasCorrect,
      'review_data': instance.modelReviewData,
      'session_progress': instance.modelSessionProgress,
      'next_interval_preview': instance.modelNextIntervalPreview,
    };

CardReviewResultModel _$CardReviewResultModelFromJson(
        Map<String, dynamic> json) =>
    CardReviewResultModel(
      modelEaseFactor:
          const SafeDoubleConverter().fromJson(json['ease_factor']),
      modelInterval: const SafeIntConverter().fromJson(json['interval']),
      modelRepetitions: const SafeIntConverter().fromJson(json['repetitions']),
      modelNextReviewDate: json['next_review_date'] as String?,
      modelLearningState: json['learning_state'] as String,
      modelRetentionRate:
          const SafeDoubleConverter().fromJson(json['retention_rate']),
    );

Map<String, dynamic> _$CardReviewResultModelToJson(
        CardReviewResultModel instance) =>
    <String, dynamic>{
      'ease_factor':
          const SafeDoubleConverter().toJson(instance.modelEaseFactor),
      'interval': const SafeIntConverter().toJson(instance.modelInterval),
      'repetitions': const SafeIntConverter().toJson(instance.modelRepetitions),
      'next_review_date': instance.modelNextReviewDate,
      'learning_state': instance.modelLearningState,
      'retention_rate':
          const SafeDoubleConverter().toJson(instance.modelRetentionRate),
    };

SessionProgressModel _$SessionProgressModelFromJson(
        Map<String, dynamic> json) =>
    SessionProgressModel(
      modelCardsReviewed:
          const SafeIntConverter().fromJson(json['cards_reviewed']),
      modelAgainCount: const SafeIntConverter().fromJson(json['again_count']),
      modelHardCount: const SafeIntConverter().fromJson(json['hard_count']),
      modelGoodCount: const SafeIntConverter().fromJson(json['good_count']),
      modelEasyCount: const SafeIntConverter().fromJson(json['easy_count']),
    );

Map<String, dynamic> _$SessionProgressModelToJson(
        SessionProgressModel instance) =>
    <String, dynamic>{
      'cards_reviewed':
          const SafeIntConverter().toJson(instance.modelCardsReviewed),
      'again_count': const SafeIntConverter().toJson(instance.modelAgainCount),
      'hard_count': const SafeIntConverter().toJson(instance.modelHardCount),
      'good_count': const SafeIntConverter().toJson(instance.modelGoodCount),
      'easy_count': const SafeIntConverter().toJson(instance.modelEasyCount),
    };

IntervalPreviewDataModel _$IntervalPreviewDataModelFromJson(
        Map<String, dynamic> json) =>
    IntervalPreviewDataModel(
      modelIntervalDays:
          const SafeIntConverter().fromJson(json['interval_days']),
      modelIntervalText: json['interval_text'] as String,
      modelNextDate: json['next_date'] as String,
    );

Map<String, dynamic> _$IntervalPreviewDataModelToJson(
        IntervalPreviewDataModel instance) =>
    <String, dynamic>{
      'interval_days':
          const SafeIntConverter().toJson(instance.modelIntervalDays),
      'interval_text': instance.modelIntervalText,
      'next_date': instance.modelNextDate,
    };
