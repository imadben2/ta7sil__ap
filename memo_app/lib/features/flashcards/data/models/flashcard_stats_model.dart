import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json_converters.dart';
import '../../domain/entities/flashcard_stats_entity.dart';

part 'flashcard_stats_model.g.dart';

@JsonSerializable()
class FlashcardStatsModel extends FlashcardStatsEntity {
  @JsonKey(name: 'total_decks')
  final int modelTotalDecks;

  @JsonKey(name: 'total_cards')
  final int modelTotalCards;

  @JsonKey(name: 'cards_studied')
  final int modelCardsStudied;

  @JsonKey(name: 'cards_mastered')
  final int modelCardsMastered;

  @JsonKey(name: 'cards_due')
  final int modelCardsDue;

  @JsonKey(name: 'average_ease_factor')
  final double modelAverageEaseFactor;

  @JsonKey(name: 'average_interval')
  final double modelAverageInterval;

  @JsonKey(name: 'retention_rate')
  final double modelRetentionRate;

  @JsonKey(name: 'total_reviews')
  final int modelTotalReviews;

  @JsonKey(name: 'reviews_today')
  final int modelReviewsToday;

  @JsonKey(name: 'sessions_today')
  final int modelSessionsToday;

  @JsonKey(name: 'time_studied_today_seconds')
  final int modelTimeStudiedTodaySeconds;

  @JsonKey(name: 'time_studied_today_formatted')
  final String modelTimeStudiedTodayFormatted;

  @JsonKey(name: 'current_streak')
  final int modelCurrentStreak;

  @JsonKey(name: 'longest_streak')
  final int modelLongestStreak;

  FlashcardStatsModel({
    this.modelTotalDecks = 0,
    this.modelTotalCards = 0,
    this.modelCardsStudied = 0,
    this.modelCardsMastered = 0,
    this.modelCardsDue = 0,
    this.modelAverageEaseFactor = 2.5,
    this.modelAverageInterval = 0,
    this.modelRetentionRate = 0,
    this.modelTotalReviews = 0,
    this.modelReviewsToday = 0,
    this.modelSessionsToday = 0,
    this.modelTimeStudiedTodaySeconds = 0,
    this.modelTimeStudiedTodayFormatted = '00:00:00',
    this.modelCurrentStreak = 0,
    this.modelLongestStreak = 0,
  }) : super(
          totalDecks: modelTotalDecks,
          totalCards: modelTotalCards,
          cardsStudied: modelCardsStudied,
          cardsMastered: modelCardsMastered,
          cardsDue: modelCardsDue,
          averageEaseFactor: modelAverageEaseFactor,
          averageInterval: modelAverageInterval,
          retentionRate: modelRetentionRate,
          totalReviews: modelTotalReviews,
          reviewsToday: modelReviewsToday,
          sessionsToday: modelSessionsToday,
          timeStudiedTodaySeconds: modelTimeStudiedTodaySeconds,
          timeStudiedTodayFormatted: modelTimeStudiedTodayFormatted,
          currentStreak: modelCurrentStreak,
          longestStreak: modelLongestStreak,
        );

  factory FlashcardStatsModel.fromJson(Map<String, dynamic> json) =>
      _$FlashcardStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$FlashcardStatsModelToJson(this);
}

@JsonSerializable()
class DailyForecastModel extends DailyForecast {
  @JsonKey(name: 'date')
  final DateTime modelDate;

  @JsonKey(name: 'day_name')
  final String modelDayName;

  @JsonKey(name: 'cards_due')
  @SafeIntConverter()
  final int modelCardsDue;

  DailyForecastModel({
    required this.modelDate,
    required this.modelDayName,
    required this.modelCardsDue,
  }) : super(
          date: modelDate,
          dayName: modelDayName,
          cardsDue: modelCardsDue,
        );

  factory DailyForecastModel.fromJson(Map<String, dynamic> json) =>
      _$DailyForecastModelFromJson(json);

  Map<String, dynamic> toJson() => _$DailyForecastModelToJson(this);
}

@JsonSerializable()
class HeatmapEntryModel extends HeatmapEntry {
  @JsonKey(name: 'date')
  final DateTime modelDate;

  @JsonKey(name: 'count')
  @SafeIntConverter()
  final int modelCount;

  HeatmapEntryModel({
    required this.modelDate,
    required this.modelCount,
  }) : super(
          date: modelDate,
          count: modelCount,
        );

  factory HeatmapEntryModel.fromJson(Map<String, dynamic> json) =>
      _$HeatmapEntryModelFromJson(json);

  Map<String, dynamic> toJson() => _$HeatmapEntryModelToJson(this);
}

@JsonSerializable()
class TodaySummaryModel extends TodaySummary {
  @JsonKey(name: 'reviews_completed')
  final int modelReviewsCompleted;

  @JsonKey(name: 'sessions_completed')
  final int modelSessionsCompleted;

  @JsonKey(name: 'time_studied')
  final String modelTimeStudied;

  @JsonKey(name: 'time_studied_seconds')
  final int modelTimeStudiedSeconds;

  @JsonKey(name: 'current_streak')
  final int modelCurrentStreak;

  @JsonKey(name: 'longest_streak')
  final int modelLongestStreak;

  @JsonKey(name: 'cards_due')
  final int modelCardsDue;

  @JsonKey(name: 'cards_mastered')
  final int modelCardsMastered;

  @JsonKey(name: 'retention_rate')
  final double modelRetentionRate;

  TodaySummaryModel({
    this.modelReviewsCompleted = 0,
    this.modelSessionsCompleted = 0,
    this.modelTimeStudied = '00:00:00',
    this.modelTimeStudiedSeconds = 0,
    this.modelCurrentStreak = 0,
    this.modelLongestStreak = 0,
    this.modelCardsDue = 0,
    this.modelCardsMastered = 0,
    this.modelRetentionRate = 0,
  }) : super(
          reviewsCompleted: modelReviewsCompleted,
          sessionsCompleted: modelSessionsCompleted,
          timeStudied: modelTimeStudied,
          timeStudiedSeconds: modelTimeStudiedSeconds,
          currentStreak: modelCurrentStreak,
          longestStreak: modelLongestStreak,
          cardsDue: modelCardsDue,
          cardsMastered: modelCardsMastered,
          retentionRate: modelRetentionRate,
        );

  factory TodaySummaryModel.fromJson(Map<String, dynamic> json) =>
      _$TodaySummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$TodaySummaryModelToJson(this);
}

@JsonSerializable()
class DeckStatsModel extends DeckStats {
  @JsonKey(name: 'deck_id')
  @SafeIntConverter()
  final int modelDeckId;

  @JsonKey(name: 'deck_title_ar')
  final String modelDeckTitleAr;

  @JsonKey(name: 'deck_color')
  final String? modelDeckColor;

  @JsonKey(name: 'total_cards')
  final int modelTotalCards;

  @JsonKey(name: 'cards_studied')
  final int modelCardsStudied;

  @JsonKey(name: 'cards_mastered')
  final int modelCardsMastered;

  @JsonKey(name: 'cards_due')
  final int modelCardsDue;

  @JsonKey(name: 'average_ease_factor')
  final double modelAverageEaseFactor;

  @JsonKey(name: 'average_interval')
  final double modelAverageInterval;

  @JsonKey(name: 'retention_rate')
  final double modelRetentionRate;

  @JsonKey(name: 'total_reviews')
  final int modelTotalReviews;

  @JsonKey(name: 'card_distribution')
  final Map<String, int> modelCardDistribution;

  @JsonKey(name: 'difficulty_distribution')
  final Map<String, int> modelDifficultyDistribution;

  DeckStatsModel({
    required this.modelDeckId,
    required this.modelDeckTitleAr,
    this.modelDeckColor,
    this.modelTotalCards = 0,
    this.modelCardsStudied = 0,
    this.modelCardsMastered = 0,
    this.modelCardsDue = 0,
    this.modelAverageEaseFactor = 2.5,
    this.modelAverageInterval = 0,
    this.modelRetentionRate = 0,
    this.modelTotalReviews = 0,
    this.modelCardDistribution = const {},
    this.modelDifficultyDistribution = const {},
  }) : super(
          deckId: modelDeckId,
          deckTitleAr: modelDeckTitleAr,
          deckColor: modelDeckColor,
          totalCards: modelTotalCards,
          cardsStudied: modelCardsStudied,
          cardsMastered: modelCardsMastered,
          cardsDue: modelCardsDue,
          averageEaseFactor: modelAverageEaseFactor,
          averageInterval: modelAverageInterval,
          retentionRate: modelRetentionRate,
          totalReviews: modelTotalReviews,
          cardDistribution: modelCardDistribution,
          difficultyDistribution: modelDifficultyDistribution,
        );

  factory DeckStatsModel.fromJson(Map<String, dynamic> json) =>
      _$DeckStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeckStatsModelToJson(this);
}
