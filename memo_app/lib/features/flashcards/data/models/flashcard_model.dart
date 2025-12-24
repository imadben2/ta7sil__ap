import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json_converters.dart';
import '../../domain/entities/flashcard_entity.dart';

part 'flashcard_model.g.dart';

@JsonSerializable(explicitToJson: true)
class FlashcardModel extends FlashcardEntity {
  @JsonKey(name: 'id')
  @SafeIntConverter()
  final int modelId;

  @JsonKey(name: 'deck_id')
  @SafeIntConverter()
  final int modelDeckId;

  @JsonKey(name: 'card_type', defaultValue: 'basic')
  final String modelCardType;

  @JsonKey(name: 'front_text_ar', defaultValue: '')
  final String modelFrontTextAr;

  @JsonKey(name: 'front_text_fr')
  final String? modelFrontTextFr;

  @JsonKey(name: 'front_image_url')
  final String? modelFrontImageUrl;

  @JsonKey(name: 'front_audio_url')
  final String? modelFrontAudioUrl;

  @JsonKey(name: 'back_text_ar', defaultValue: '')
  final String modelBackTextAr;

  @JsonKey(name: 'back_text_fr')
  final String? modelBackTextFr;

  @JsonKey(name: 'back_image_url')
  final String? modelBackImageUrl;

  @JsonKey(name: 'back_audio_url')
  final String? modelBackAudioUrl;

  @JsonKey(name: 'cloze_template')
  final String? modelClozeTemplate;

  @JsonKey(name: 'cloze_deletions')
  final List<ClozeItemModel>? modelClozeDeletions;

  @JsonKey(name: 'hint_ar')
  final String? modelHintAr;

  @JsonKey(name: 'explanation_ar')
  final String? modelExplanationAr;

  @JsonKey(name: 'tags')
  final List<String>? modelTags;

  @JsonKey(name: 'difficulty_level', defaultValue: 'medium')
  final String modelDifficultyLevel;

  @JsonKey(name: 'order', defaultValue: 0)
  final int modelOrder;

  @JsonKey(name: 'user_review_data')
  final CardReviewDataModel? modelReviewData;

  @JsonKey(name: 'formatted_content')
  final Map<String, dynamic>? formattedContent;

  @JsonKey(name: 'is_new')
  final bool? isNewCard;

  @JsonKey(name: 'next_interval_preview')
  final Map<String, IntervalPreviewModel>? intervalPreview;

  FlashcardModel({
    required this.modelId,
    required this.modelDeckId,
    required this.modelCardType,
    required this.modelFrontTextAr,
    this.modelFrontTextFr,
    this.modelFrontImageUrl,
    this.modelFrontAudioUrl,
    required this.modelBackTextAr,
    this.modelBackTextFr,
    this.modelBackImageUrl,
    this.modelBackAudioUrl,
    this.modelClozeTemplate,
    this.modelClozeDeletions,
    this.modelHintAr,
    this.modelExplanationAr,
    this.modelTags,
    this.modelDifficultyLevel = 'medium',
    this.modelOrder = 0,
    this.modelReviewData,
    this.formattedContent,
    this.isNewCard,
    this.intervalPreview,
  }) : super(
          id: modelId,
          deckId: modelDeckId,
          type: FlashcardType.fromString(modelCardType),
          frontTextAr: modelFrontTextAr,
          frontTextFr: modelFrontTextFr,
          frontImageUrl: modelFrontImageUrl,
          frontAudioUrl: modelFrontAudioUrl,
          backTextAr: modelBackTextAr,
          backTextFr: modelBackTextFr,
          backImageUrl: modelBackImageUrl,
          backAudioUrl: modelBackAudioUrl,
          clozeTemplate: modelClozeTemplate,
          clozeDeletions: modelClozeDeletions,
          hintAr: modelHintAr,
          explanationAr: modelExplanationAr,
          tags: modelTags,
          difficultyLevel: modelDifficultyLevel,
          order: modelOrder,
          reviewData: modelReviewData,
        );

  factory FlashcardModel.fromJson(Map<String, dynamic> json) =>
      _$FlashcardModelFromJson(json);

  Map<String, dynamic> toJson() => _$FlashcardModelToJson(this);
}

@JsonSerializable()
class ClozeItemModel extends ClozeItem {
  @JsonKey(name: 'id')
  final String modelId;

  @JsonKey(name: 'answer')
  final String modelAnswer;

  @JsonKey(name: 'hint')
  final String? modelHint;

  ClozeItemModel({
    required this.modelId,
    required this.modelAnswer,
    this.modelHint,
  }) : super(
          id: modelId,
          answer: modelAnswer,
          hint: modelHint,
        );

  factory ClozeItemModel.fromJson(Map<String, dynamic> json) =>
      _$ClozeItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ClozeItemModelToJson(this);
}

@JsonSerializable()
class CardReviewDataModel extends CardReviewData {
  @JsonKey(name: 'ease_factor')
  final double modelEaseFactor;

  @JsonKey(name: 'interval')
  final int modelInterval;

  @JsonKey(name: 'repetitions')
  final int modelRepetitions;

  @JsonKey(name: 'next_review_date')
  final DateTime? modelNextReviewDate;

  @JsonKey(name: 'last_review_date')
  final DateTime? modelLastReviewDate;

  @JsonKey(name: 'total_reviews')
  final int modelTotalReviews;

  @JsonKey(name: 'correct_reviews')
  final int modelCorrectReviews;

  @JsonKey(name: 'learning_state')
  final String modelLearningState;

  CardReviewDataModel({
    this.modelEaseFactor = 2.50,
    this.modelInterval = 0,
    this.modelRepetitions = 0,
    this.modelNextReviewDate,
    this.modelLastReviewDate,
    this.modelTotalReviews = 0,
    this.modelCorrectReviews = 0,
    this.modelLearningState = 'new',
  }) : super(
          easeFactor: modelEaseFactor,
          interval: modelInterval,
          repetitions: modelRepetitions,
          nextReviewDate: modelNextReviewDate,
          lastReviewDate: modelLastReviewDate,
          totalReviews: modelTotalReviews,
          correctReviews: modelCorrectReviews,
          learningState: modelLearningState,
        );

  factory CardReviewDataModel.fromJson(Map<String, dynamic> json) =>
      _$CardReviewDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$CardReviewDataModelToJson(this);
}

@JsonSerializable()
class IntervalPreviewModel extends IntervalPreview {
  @JsonKey(name: 'interval_days')
  final int modelIntervalDays;

  @JsonKey(name: 'interval_text')
  final String modelIntervalText;

  @JsonKey(name: 'next_date')
  final DateTime modelNextDate;

  IntervalPreviewModel({
    required this.modelIntervalDays,
    required this.modelIntervalText,
    required this.modelNextDate,
  }) : super(
          intervalDays: modelIntervalDays,
          intervalText: modelIntervalText,
          nextDate: modelNextDate,
        );

  factory IntervalPreviewModel.fromJson(Map<String, dynamic> json) =>
      _$IntervalPreviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$IntervalPreviewModelToJson(this);
}
