import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/flashcard_stats_entity.dart';
import '../repositories/flashcards_repository.dart';

class GetFlashcardStatsUseCase {
  final FlashcardsRepository repository;

  GetFlashcardStatsUseCase(this.repository);

  Future<Either<Failure, FlashcardStatsEntity>> call({int? deckId}) {
    return repository.getStats(deckId: deckId);
  }
}

class GetForecastUseCase {
  final FlashcardsRepository repository;

  GetForecastUseCase(this.repository);

  Future<Either<Failure, List<DailyForecast>>> call({int days = 7}) {
    return repository.getForecast(days: days);
  }
}

class GetTodaySummaryUseCase {
  final FlashcardsRepository repository;

  GetTodaySummaryUseCase(this.repository);

  Future<Either<Failure, TodaySummary>> call() {
    return repository.getTodaySummary();
  }
}
