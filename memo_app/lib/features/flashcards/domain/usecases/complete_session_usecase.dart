import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/review_session_entity.dart';
import '../repositories/flashcards_repository.dart';

class CompleteSessionUseCase {
  final FlashcardsRepository repository;

  CompleteSessionUseCase(this.repository);

  Future<Either<Failure, ReviewSessionEntity>> call(int sessionId) {
    return repository.completeSession(sessionId);
  }
}
