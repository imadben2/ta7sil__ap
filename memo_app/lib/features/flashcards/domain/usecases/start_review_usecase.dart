import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/flashcards_repository.dart';

class StartReviewUseCase {
  final FlashcardsRepository repository;

  StartReviewUseCase(this.repository);

  Future<Either<Failure, ReviewSessionData>> call(StartReviewParams params) {
    return repository.startReviewSession(
      deckId: params.deckId,
      cardLimit: params.cardLimit,
      browseMode: params.browseMode,
    );
  }
}

class StartReviewParams {
  final int? deckId;
  final int? cardLimit;
  final bool browseMode;

  const StartReviewParams({
    this.deckId,
    this.cardLimit,
    this.browseMode = false,
  });
}
