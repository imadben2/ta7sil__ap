import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/flashcard_entity.dart';
import '../repositories/flashcards_repository.dart';

class GetDueCardsUseCase {
  final FlashcardsRepository repository;

  GetDueCardsUseCase(this.repository);

  Future<Either<Failure, List<FlashcardEntity>>> call(GetDueCardsParams params) {
    return repository.getDueCards(
      deckId: params.deckId,
      limit: params.limit,
    );
  }
}

class GetDueCardsParams {
  final int? deckId;
  final int limit;

  const GetDueCardsParams({
    this.deckId,
    this.limit = 50,
  });
}
