import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/flashcard_deck_entity.dart';
import '../repositories/flashcards_repository.dart';

class GetDecksUseCase {
  final FlashcardsRepository repository;

  GetDecksUseCase(this.repository);

  Future<Either<Failure, List<FlashcardDeckEntity>>> call(
      GetDecksParams params) {
    return repository.getDecks(
      subjectId: params.subjectId,
      chapterId: params.chapterId,
      search: params.search,
      page: params.page,
      perPage: params.perPage,
    );
  }
}

class GetDecksParams {
  final int? subjectId;
  final int? chapterId;
  final String? search;
  final int page;
  final int perPage;

  const GetDecksParams({
    this.subjectId,
    this.chapterId,
    this.search,
    this.page = 1,
    this.perPage = 20,
  });
}
