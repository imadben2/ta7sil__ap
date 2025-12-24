import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/review_session_entity.dart';
import '../repositories/flashcards_repository.dart';

class SubmitAnswerUseCase {
  final FlashcardsRepository repository;

  SubmitAnswerUseCase(this.repository);

  Future<Either<Failure, AnswerResult>> call(SubmitAnswerParams params) {
    return repository.submitAnswer(
      sessionId: params.sessionId,
      cardId: params.cardId,
      response: params.response,
      responseTimeSeconds: params.responseTimeSeconds,
    );
  }
}

class SubmitAnswerParams {
  final int sessionId;
  final int cardId;
  final String response; // 'again', 'hard', 'good', 'easy'
  final int? responseTimeSeconds;

  const SubmitAnswerParams({
    required this.sessionId,
    required this.cardId,
    required this.response,
    this.responseTimeSeconds,
  });
}
