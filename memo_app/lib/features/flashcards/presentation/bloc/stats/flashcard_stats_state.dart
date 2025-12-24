import 'package:equatable/equatable.dart';

import '../../../domain/entities/flashcard_stats_entity.dart';

abstract class FlashcardStatsState extends Equatable {
  const FlashcardStatsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class FlashcardStatsInitial extends FlashcardStatsState {
  const FlashcardStatsInitial();
}

/// Loading stats
class FlashcardStatsLoading extends FlashcardStatsState {
  const FlashcardStatsLoading();
}

/// Stats loaded successfully
class FlashcardStatsLoaded extends FlashcardStatsState {
  final FlashcardStatsEntity? stats;
  final List<DailyForecast>? forecast;
  final TodaySummary? todaySummary;

  const FlashcardStatsLoaded({
    this.stats,
    this.forecast,
    this.todaySummary,
  });

  FlashcardStatsLoaded copyWith({
    FlashcardStatsEntity? stats,
    List<DailyForecast>? forecast,
    TodaySummary? todaySummary,
  }) {
    return FlashcardStatsLoaded(
      stats: stats ?? this.stats,
      forecast: forecast ?? this.forecast,
      todaySummary: todaySummary ?? this.todaySummary,
    );
  }

  @override
  List<Object?> get props => [stats, forecast, todaySummary];
}

/// Error loading stats
class FlashcardStatsError extends FlashcardStatsState {
  final String message;

  const FlashcardStatsError({required this.message});

  @override
  List<Object?> get props => [message];
}
