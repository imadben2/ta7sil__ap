import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/flashcard_deck_entity.dart';
import '../repositories/flashcards_repository.dart';

class GetDeckDetailsUseCase {
  final FlashcardsRepository repository;

  GetDeckDetailsUseCase(this.repository);

  Future<Either<Failure, FlashcardDeckEntity>> call(int deckId) {
    return repository.getDeckDetails(deckId);
  }
}
