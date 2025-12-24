// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlashcardModel _$FlashcardModelFromJson(Map<String, dynamic> json) =>
    FlashcardModel(
      modelId: const SafeIntConverter().fromJson(json['id']),
      modelDeckId: const SafeIntConverter().fromJson(json['deck_id']),
      modelCardType: json['card_type'] as String? ?? 'basic',
      modelFrontTextAr: json['front_text_ar'] as String? ?? '',
      modelFrontTextFr: json['front_text_fr'] as String?,
      modelFrontImageUrl: json['front_image_url'] as String?,
      modelFrontAudioUrl: json['front_audio_url'] as String?,
      modelBackTextAr: json['back_text_ar'] as String? ?? '',
      modelBackTextFr: json['back_text_fr'] as String?,
      modelBackImageUrl: json['back_image_url'] as String?,
      modelBackAudioUrl: json['back_audio_url'] as String?,
      modelClozeTemplate: json['cloze_template'] as String?,
      modelClozeDeletions: (json['cloze_deletions'] as List<dynamic>?)
          ?.map((e) => ClozeItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      modelHintAr: json['hint_ar'] as String?,
      modelExplanationAr: json['explanation_ar'] as String?,
      modelTags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      modelDifficultyLevel: json['difficulty_level'] as String? ?? 'medium',
      modelOrder: (json['order'] as num?)?.toInt() ?? 0,
      modelReviewData: json['user_review_data'] == null
          ? null
          : CardReviewDataModel.fromJson(
              json['user_review_data'] as Map<String, dynamic>),
      formattedContent: json['formatted_content'] as Map<String, dynamic>?,
      isNewCard: json['is_new'] as bool?,
      intervalPreview:
          (json['next_interval_preview'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            k, IntervalPreviewModel.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$FlashcardModelToJson(FlashcardModel instance) =>
    <String, dynamic>{
      'id': const SafeIntConverter().toJson(instance.modelId),
      'deck_id': const SafeIntConverter().toJson(instance.modelDeckId),
      'card_type': instance.modelCardType,
      'front_text_ar': instance.modelFrontTextAr,
      'front_text_fr': instance.modelFrontTextFr,
      'front_image_url': instance.modelFrontImageUrl,
      'front_audio_url': instance.modelFrontAudioUrl,
      'back_text_ar': instance.modelBackTextAr,
      'back_text_fr': instance.modelBackTextFr,
      'back_image_url': instance.modelBackImageUrl,
      'back_audio_url': instance.modelBackAudioUrl,
      'cloze_template': instance.modelClozeTemplate,
      'cloze_deletions':
          instance.modelClozeDeletions?.map((e) => e.toJson()).toList(),
      'hint_ar': instance.modelHintAr,
      'explanation_ar': instance.modelExplanationAr,
      'tags': instance.modelTags,
      'difficulty_level': instance.modelDifficultyLevel,
      'order': instance.modelOrder,
      'user_review_data': instance.modelReviewData?.toJson(),
      'formatted_content': instance.formattedContent,
      'is_new': instance.isNewCard,
      'next_interval_preview':
          instance.intervalPreview?.map((k, e) => MapEntry(k, e.toJson())),
    };

ClozeItemModel _$ClozeItemModelFromJson(Map<String, dynamic> json) =>
    ClozeItemModel(
      modelId: json['id'] as String,
      modelAnswer: json['answer'] as String,
      modelHint: json['hint'] as String?,
    );

Map<String, dynamic> _$ClozeItemModelToJson(ClozeItemModel instance) =>
    <String, dynamic>{
      'id': instance.modelId,
      'answer': instance.modelAnswer,
      'hint': instance.modelHint,
    };

CardReviewDataModel _$CardReviewDataModelFromJson(Map<String, dynamic> json) =>
    CardReviewDataModel(
      modelEaseFactor: (json['ease_factor'] as num?)?.toDouble() ?? 2.50,
      modelInterval: (json['interval'] as num?)?.toInt() ?? 0,
      modelRepetitions: (json['repetitions'] as num?)?.toInt() ?? 0,
      modelNextReviewDate: json['next_review_date'] == null
          ? null
          : DateTime.parse(json['next_review_date'] as String),
      modelLastReviewDate: json['last_review_date'] == null
          ? null
          : DateTime.parse(json['last_review_date'] as String),
      modelTotalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      modelCorrectReviews: (json['correct_reviews'] as num?)?.toInt() ?? 0,
      modelLearningState: json['learning_state'] as String? ?? 'new',
    );

Map<String, dynamic> _$CardReviewDataModelToJson(
        CardReviewDataModel instance) =>
    <String, dynamic>{
      'ease_factor': instance.modelEaseFactor,
      'interval': instance.modelInterval,
      'repetitions': instance.modelRepetitions,
      'next_review_date': instance.modelNextReviewDate?.toIso8601String(),
      'last_review_date': instance.modelLastReviewDate?.toIso8601String(),
      'total_reviews': instance.modelTotalReviews,
      'correct_reviews': instance.modelCorrectReviews,
      'learning_state': instance.modelLearningState,
    };

IntervalPreviewModel _$IntervalPreviewModelFromJson(
        Map<String, dynamic> json) =>
    IntervalPreviewModel(
      modelIntervalDays: (json['interval_days'] as num).toInt(),
      modelIntervalText: json['interval_text'] as String,
      modelNextDate: DateTime.parse(json['next_date'] as String),
    );

Map<String, dynamic> _$IntervalPreviewModelToJson(
        IntervalPreviewModel instance) =>
    <String, dynamic>{
      'interval_days': instance.modelIntervalDays,
      'interval_text': instance.modelIntervalText,
      'next_date': instance.modelNextDate.toIso8601String(),
    };
