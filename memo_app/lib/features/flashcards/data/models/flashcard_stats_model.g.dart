// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlashcardStatsModel _$FlashcardStatsModelFromJson(Map<String, dynamic> json) =>
    FlashcardStatsModel(
      modelTotalDecks: (json['total_decks'] as num?)?.toInt() ?? 0,
      modelTotalCards: (json['total_cards'] as num?)?.toInt() ?? 0,
      modelCardsStudied: (json['cards_studied'] as num?)?.toInt() ?? 0,
      modelCardsMastered: (json['cards_mastered'] as num?)?.toInt() ?? 0,
      modelCardsDue: (json['cards_due'] as num?)?.toInt() ?? 0,
      modelAverageEaseFactor:
          (json['average_ease_factor'] as num?)?.toDouble() ?? 2.5,
      modelAverageInterval: (json['average_interval'] as num?)?.toDouble() ?? 0,
      modelRetentionRate: (json['retention_rate'] as num?)?.toDouble() ?? 0,
      modelTotalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      modelReviewsToday: (json['reviews_today'] as num?)?.toInt() ?? 0,
      modelSessionsToday: (json['sessions_today'] as num?)?.toInt() ?? 0,
      modelTimeStudiedTodaySeconds:
          (json['time_studied_today_seconds'] as num?)?.toInt() ?? 0,
      modelTimeStudiedTodayFormatted:
          json['time_studied_today_formatted'] as String? ?? '00:00:00',
      modelCurrentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      modelLongestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$FlashcardStatsModelToJson(
        FlashcardStatsModel instance) =>
    <String, dynamic>{
      'total_decks': instance.modelTotalDecks,
      'total_cards': instance.modelTotalCards,
      'cards_studied': instance.modelCardsStudied,
      'cards_mastered': instance.modelCardsMastered,
      'cards_due': instance.modelCardsDue,
      'average_ease_factor': instance.modelAverageEaseFactor,
      'average_interval': instance.modelAverageInterval,
      'retention_rate': instance.modelRetentionRate,
      'total_reviews': instance.modelTotalReviews,
      'reviews_today': instance.modelReviewsToday,
      'sessions_today': instance.modelSessionsToday,
      'time_studied_today_seconds': instance.modelTimeStudiedTodaySeconds,
      'time_studied_today_formatted': instance.modelTimeStudiedTodayFormatted,
      'current_streak': instance.modelCurrentStreak,
      'longest_streak': instance.modelLongestStreak,
    };

DailyForecastModel _$DailyForecastModelFromJson(Map<String, dynamic> json) =>
    DailyForecastModel(
      modelDate: DateTime.parse(json['date'] as String),
      modelDayName: json['day_name'] as String,
      modelCardsDue: const SafeIntConverter().fromJson(json['cards_due']),
    );

Map<String, dynamic> _$DailyForecastModelToJson(DailyForecastModel instance) =>
    <String, dynamic>{
      'date': instance.modelDate.toIso8601String(),
      'day_name': instance.modelDayName,
      'cards_due': const SafeIntConverter().toJson(instance.modelCardsDue),
    };

HeatmapEntryModel _$HeatmapEntryModelFromJson(Map<String, dynamic> json) =>
    HeatmapEntryModel(
      modelDate: DateTime.parse(json['date'] as String),
      modelCount: const SafeIntConverter().fromJson(json['count']),
    );

Map<String, dynamic> _$HeatmapEntryModelToJson(HeatmapEntryModel instance) =>
    <String, dynamic>{
      'date': instance.modelDate.toIso8601String(),
      'count': const SafeIntConverter().toJson(instance.modelCount),
    };

TodaySummaryModel _$TodaySummaryModelFromJson(Map<String, dynamic> json) =>
    TodaySummaryModel(
      modelReviewsCompleted: (json['reviews_completed'] as num?)?.toInt() ?? 0,
      modelSessionsCompleted:
          (json['sessions_completed'] as num?)?.toInt() ?? 0,
      modelTimeStudied: json['time_studied'] as String? ?? '00:00:00',
      modelTimeStudiedSeconds:
          (json['time_studied_seconds'] as num?)?.toInt() ?? 0,
      modelCurrentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      modelLongestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
      modelCardsDue: (json['cards_due'] as num?)?.toInt() ?? 0,
      modelCardsMastered: (json['cards_mastered'] as num?)?.toInt() ?? 0,
      modelRetentionRate: (json['retention_rate'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$TodaySummaryModelToJson(TodaySummaryModel instance) =>
    <String, dynamic>{
      'reviews_completed': instance.modelReviewsCompleted,
      'sessions_completed': instance.modelSessionsCompleted,
      'time_studied': instance.modelTimeStudied,
      'time_studied_seconds': instance.modelTimeStudiedSeconds,
      'current_streak': instance.modelCurrentStreak,
      'longest_streak': instance.modelLongestStreak,
      'cards_due': instance.modelCardsDue,
      'cards_mastered': instance.modelCardsMastered,
      'retention_rate': instance.modelRetentionRate,
    };

DeckStatsModel _$DeckStatsModelFromJson(Map<String, dynamic> json) =>
    DeckStatsModel(
      modelDeckId: const SafeIntConverter().fromJson(json['deck_id']),
      modelDeckTitleAr: json['deck_title_ar'] as String,
      modelDeckColor: json['deck_color'] as String?,
      modelTotalCards: (json['total_cards'] as num?)?.toInt() ?? 0,
      modelCardsStudied: (json['cards_studied'] as num?)?.toInt() ?? 0,
      modelCardsMastered: (json['cards_mastered'] as num?)?.toInt() ?? 0,
      modelCardsDue: (json['cards_due'] as num?)?.toInt() ?? 0,
      modelAverageEaseFactor:
          (json['average_ease_factor'] as num?)?.toDouble() ?? 2.5,
      modelAverageInterval: (json['average_interval'] as num?)?.toDouble() ?? 0,
      modelRetentionRate: (json['retention_rate'] as num?)?.toDouble() ?? 0,
      modelTotalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      modelCardDistribution:
          (json['card_distribution'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, (e as num).toInt()),
              ) ??
              const {},
      modelDifficultyDistribution:
          (json['difficulty_distribution'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, (e as num).toInt()),
              ) ??
              const {},
    );

Map<String, dynamic> _$DeckStatsModelToJson(DeckStatsModel instance) =>
    <String, dynamic>{
      'deck_id': const SafeIntConverter().toJson(instance.modelDeckId),
      'deck_title_ar': instance.modelDeckTitleAr,
      'deck_color': instance.modelDeckColor,
      'total_cards': instance.modelTotalCards,
      'cards_studied': instance.modelCardsStudied,
      'cards_mastered': instance.modelCardsMastered,
      'cards_due': instance.modelCardsDue,
      'average_ease_factor': instance.modelAverageEaseFactor,
      'average_interval': instance.modelAverageInterval,
      'retention_rate': instance.modelRetentionRate,
      'total_reviews': instance.modelTotalReviews,
      'card_distribution': instance.modelCardDistribution,
      'difficulty_distribution': instance.modelDifficultyDistribution,
    };
