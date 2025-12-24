import 'package:equatable/equatable.dart';

abstract class FlashcardStatsEvent extends Equatable {
  const FlashcardStatsEvent();

  @override
  List<Object?> get props => [];
}

/// Load overall flashcard stats
class LoadFlashcardStats extends FlashcardStatsEvent {
  final int? deckId;

  const LoadFlashcardStats({this.deckId});

  @override
  List<Object?> get props => [deckId];
}

/// Load review forecast for upcoming days
class LoadForecast extends FlashcardStatsEvent {
  final int days;

  const LoadForecast({this.days = 7});

  @override
  List<Object?> get props => [days];
}

/// Load today's review summary
class LoadTodaySummary extends FlashcardStatsEvent {
  const LoadTodaySummary();
}

/// Refresh all stats
class RefreshStats extends FlashcardStatsEvent {
  const RefreshStats();
}
