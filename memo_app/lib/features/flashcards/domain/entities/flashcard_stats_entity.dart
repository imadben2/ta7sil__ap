import 'package:equatable/equatable.dart';

/// Overall flashcard statistics for user
class FlashcardStatsEntity extends Equatable {
  final int totalDecks;
  final int totalCards;
  final int cardsStudied;
  final int cardsMastered;
  final int cardsDue;
  final double averageEaseFactor;
  final double averageInterval;
  final double retentionRate;
  final int totalReviews;
  final int reviewsToday;
  final int sessionsToday;
  final int timeStudiedTodaySeconds;
  final String timeStudiedTodayFormatted;
  final int currentStreak;
  final int longestStreak;
  final List<DeckStats> deckStats;

  const FlashcardStatsEntity({
    this.totalDecks = 0,
    this.totalCards = 0,
    this.cardsStudied = 0,
    this.cardsMastered = 0,
    this.cardsDue = 0,
    this.averageEaseFactor = 2.5,
    this.averageInterval = 0,
    this.retentionRate = 0,
    this.totalReviews = 0,
    this.reviewsToday = 0,
    this.sessionsToday = 0,
    this.timeStudiedTodaySeconds = 0,
    this.timeStudiedTodayFormatted = '00:00:00',
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.deckStats = const [],
  });

  /// Average retention rate
  double get averageRetention => retentionRate;

  /// Get mastery percentage
  double get masteryPercentage {
    if (totalCards == 0) return 0;
    return (cardsMastered / totalCards) * 100;
  }

  /// Get study completion percentage
  double get studyCompletion {
    if (totalCards == 0) return 0;
    return (cardsStudied / totalCards) * 100;
  }

  @override
  List<Object?> get props => [
        totalDecks,
        totalCards,
        cardsStudied,
        cardsMastered,
        cardsDue,
        retentionRate,
        totalReviews,
        reviewsToday,
        currentStreak,
        longestStreak,
      ];
}

/// Daily forecast entry
class DailyForecast extends Equatable {
  final DateTime date;
  final String dayName;
  final int cardsDue;

  const DailyForecast({
    required this.date,
    required this.dayName,
    required this.cardsDue,
  });

  @override
  List<Object?> get props => [date, dayName, cardsDue];
}

/// Heatmap entry for a day
class HeatmapEntry extends Equatable {
  final DateTime date;
  final int count;

  const HeatmapEntry({
    required this.date,
    required this.count,
  });

  /// Get intensity level (0-4) based on count
  int get intensityLevel {
    if (count == 0) return 0;
    if (count <= 10) return 1;
    if (count <= 25) return 2;
    if (count <= 50) return 3;
    return 4;
  }

  @override
  List<Object?> get props => [date, count];
}

/// Today's summary
class TodaySummary extends Equatable {
  final int reviewsCompleted;
  final int sessionsCompleted;
  final String timeStudied;
  final int timeStudiedSeconds;
  final int currentStreak;
  final int longestStreak;
  final int cardsDue;
  final int cardsMastered;
  final double retentionRate;

  const TodaySummary({
    this.reviewsCompleted = 0,
    this.sessionsCompleted = 0,
    this.timeStudied = '00:00:00',
    this.timeStudiedSeconds = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.cardsDue = 0,
    this.cardsMastered = 0,
    this.retentionRate = 0,
  });

  /// Alias for reviewsCompleted
  int get cardsReviewed => reviewsCompleted;

  /// Study minutes (from seconds)
  int get studyMinutes => timeStudiedSeconds ~/ 60;

  /// Streak days alias
  int get streakDays => currentStreak;

  @override
  List<Object?> get props => [
        reviewsCompleted,
        sessionsCompleted,
        timeStudied,
        currentStreak,
        cardsDue,
      ];
}

/// Deck-specific statistics
class DeckStats extends Equatable {
  final int deckId;
  final String deckTitleAr;
  final String? deckColor;
  final int totalCards;
  final int cardsStudied;
  final int cardsMastered;
  final int cardsDue;
  final double averageEaseFactor;
  final double averageInterval;
  final double retentionRate;
  final int totalReviews;
  final Map<String, int> cardDistribution;
  final Map<String, int> difficultyDistribution;

  const DeckStats({
    required this.deckId,
    required this.deckTitleAr,
    this.deckColor,
    this.totalCards = 0,
    this.cardsStudied = 0,
    this.cardsMastered = 0,
    this.cardsDue = 0,
    this.averageEaseFactor = 2.5,
    this.averageInterval = 0,
    this.retentionRate = 0,
    this.totalReviews = 0,
    this.cardDistribution = const {},
    this.difficultyDistribution = const {},
  });

  double get masteryPercentage {
    if (totalCards == 0) return 0;
    return (cardsMastered / totalCards) * 100;
  }

  @override
  List<Object?> get props => [
        deckId,
        deckTitleAr,
        totalCards,
        cardsMastered,
        retentionRate,
      ];
}
