import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json_converters.dart';
import '../../domain/entities/review_session_entity.dart';
import 'flashcard_deck_model.dart';

part 'review_session_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ReviewSessionModel extends ReviewSessionEntity {
  @JsonKey(name: 'id')
  @SafeIntConverter()
  final int modelId;

  @JsonKey(name: 'deck_id')
  @SafeNullableIntConverter()
  final int? modelDeckId;

  @JsonKey(name: 'deck')
  final FlashcardDeckModel? modelDeck;

  @JsonKey(name: 'started_at')
  final DateTime modelStartedAt;

  @JsonKey(name: 'completed_at')
  final DateTime? modelCompletedAt;

  @JsonKey(name: 'duration_seconds', defaultValue: 0)
  final int modelDurationSeconds;

  @JsonKey(name: 'total_cards_reviewed', defaultValue: 0)
  final int modelTotalCardsReviewed;

  @JsonKey(name: 'new_cards_studied', defaultValue: 0)
  final int modelNewCardsStudied;

  @JsonKey(name: 'review_cards_studied', defaultValue: 0)
  final int modelReviewCardsStudied;

  @JsonKey(name: 'again_count', defaultValue: 0)
  final int modelAgainCount;

  @JsonKey(name: 'hard_count', defaultValue: 0)
  final int modelHardCount;

  @JsonKey(name: 'good_count', defaultValue: 0)
  final int modelGoodCount;

  @JsonKey(name: 'easy_count', defaultValue: 0)
  final int modelEasyCount;

  @JsonKey(name: 'average_response_time_seconds')
  final double? modelAverageResponseTimeSeconds;

  @JsonKey(name: 'session_retention_rate', defaultValue: 0.0)
  final double modelSessionRetentionRate;

  @JsonKey(name: 'status', defaultValue: 'in_progress')
  final String modelStatus;

  @JsonKey(name: 'cards_reviewed')
  final List<int>? modelCardsReviewed;

  ReviewSessionModel({
    required this.modelId,
    this.modelDeckId,
    this.modelDeck,
    required this.modelStartedAt,
    this.modelCompletedAt,
    this.modelDurationSeconds = 0,
    this.modelTotalCardsReviewed = 0,
    this.modelNewCardsStudied = 0,
    this.modelReviewCardsStudied = 0,
    this.modelAgainCount = 0,
    this.modelHardCount = 0,
    this.modelGoodCount = 0,
    this.modelEasyCount = 0,
    this.modelAverageResponseTimeSeconds,
    this.modelSessionRetentionRate = 0,
    this.modelStatus = 'in_progress',
    this.modelCardsReviewed,
  }) : super(
          id: modelId,
          deckId: modelDeckId,
          deck: modelDeck,
          startedAt: modelStartedAt,
          completedAt: modelCompletedAt,
          durationSeconds: modelDurationSeconds,
          totalCardsReviewed: modelTotalCardsReviewed,
          newCardsStudied: modelNewCardsStudied,
          reviewCardsStudied: modelReviewCardsStudied,
          againCount: modelAgainCount,
          hardCount: modelHardCount,
          goodCount: modelGoodCount,
          easyCount: modelEasyCount,
          averageResponseTimeSeconds: modelAverageResponseTimeSeconds,
          sessionRetentionRate: modelSessionRetentionRate,
          status: modelStatus,
          cardsReviewed: modelCardsReviewed,
        );

  factory ReviewSessionModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewSessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewSessionModelToJson(this);
}

@JsonSerializable()
class AnswerResultModel extends AnswerResult {
  @JsonKey(name: 'card_id')
  @SafeIntConverter()
  final int modelCardId;

  @JsonKey(name: 'quality_rating')
  @SafeIntConverter()
  final int modelQualityRating;

  @JsonKey(name: 'was_correct')
  final bool modelWasCorrect;

  @JsonKey(name: 'review_data')
  final CardReviewResultModel modelReviewData;

  @JsonKey(name: 'session_progress')
  final SessionProgressModel modelSessionProgress;

  @JsonKey(name: 'next_interval_preview')
  final Map<String, IntervalPreviewDataModel> modelNextIntervalPreview;

  AnswerResultModel({
    required this.modelCardId,
    required this.modelQualityRating,
    required this.modelWasCorrect,
    required this.modelReviewData,
    required this.modelSessionProgress,
    required this.modelNextIntervalPreview,
  }) : super(
          cardId: modelCardId,
          qualityRating: modelQualityRating,
          wasCorrect: modelWasCorrect,
          reviewData: modelReviewData,
          sessionProgress: modelSessionProgress,
          nextIntervalPreview: modelNextIntervalPreview,
        );

  factory AnswerResultModel.fromJson(Map<String, dynamic> json) =>
      _$AnswerResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$AnswerResultModelToJson(this);
}

@JsonSerializable()
class CardReviewResultModel extends CardReviewResult {
  @JsonKey(name: 'ease_factor')
  @SafeDoubleConverter()
  final double modelEaseFactor;

  @JsonKey(name: 'interval')
  @SafeIntConverter()
  final int modelInterval;

  @JsonKey(name: 'repetitions')
  @SafeIntConverter()
  final int modelRepetitions;

  @JsonKey(name: 'next_review_date')
  final String? modelNextReviewDate;

  @JsonKey(name: 'learning_state')
  final String modelLearningState;

  @JsonKey(name: 'retention_rate')
  @SafeDoubleConverter()
  final double modelRetentionRate;

  CardReviewResultModel({
    required this.modelEaseFactor,
    required this.modelInterval,
    required this.modelRepetitions,
    this.modelNextReviewDate,
    required this.modelLearningState,
    required this.modelRetentionRate,
  }) : super(
          easeFactor: modelEaseFactor,
          interval: modelInterval,
          repetitions: modelRepetitions,
          nextReviewDate: modelNextReviewDate,
          learningState: modelLearningState,
          retentionRate: modelRetentionRate,
        );

  factory CardReviewResultModel.fromJson(Map<String, dynamic> json) =>
      _$CardReviewResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$CardReviewResultModelToJson(this);
}

@JsonSerializable()
class SessionProgressModel extends SessionProgress {
  @JsonKey(name: 'cards_reviewed')
  @SafeIntConverter()
  final int modelCardsReviewed;

  @JsonKey(name: 'again_count')
  @SafeIntConverter()
  final int modelAgainCount;

  @JsonKey(name: 'hard_count')
  @SafeIntConverter()
  final int modelHardCount;

  @JsonKey(name: 'good_count')
  @SafeIntConverter()
  final int modelGoodCount;

  @JsonKey(name: 'easy_count')
  @SafeIntConverter()
  final int modelEasyCount;

  SessionProgressModel({
    required this.modelCardsReviewed,
    required this.modelAgainCount,
    required this.modelHardCount,
    required this.modelGoodCount,
    required this.modelEasyCount,
  }) : super(
          cardsReviewed: modelCardsReviewed,
          againCount: modelAgainCount,
          hardCount: modelHardCount,
          goodCount: modelGoodCount,
          easyCount: modelEasyCount,
        );

  factory SessionProgressModel.fromJson(Map<String, dynamic> json) =>
      _$SessionProgressModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionProgressModelToJson(this);
}

@JsonSerializable()
class IntervalPreviewDataModel extends IntervalPreviewData {
  @JsonKey(name: 'interval_days')
  @SafeIntConverter()
  final int modelIntervalDays;

  @JsonKey(name: 'interval_text')
  final String modelIntervalText;

  @JsonKey(name: 'next_date')
  final String modelNextDate;

  IntervalPreviewDataModel({
    required this.modelIntervalDays,
    required this.modelIntervalText,
    required this.modelNextDate,
  }) : super(
          intervalDays: modelIntervalDays,
          intervalText: modelIntervalText,
          nextDate: modelNextDate,
        );

  factory IntervalPreviewDataModel.fromJson(Map<String, dynamic> json) =>
      _$IntervalPreviewDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$IntervalPreviewDataModelToJson(this);
}
