import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/quiz_attempt_entity.dart';
import '../repositories/quiz_repository.dart';

/// Use case for starting a new quiz attempt
class StartQuizUseCase {
  final QuizRepository repository;

  StartQuizUseCase(this.repository);

  Future<Either<Failure, QuizAttemptEntity>> call(StartQuizParams params) {
    return repository.startQuiz(quizId: params.quizId, seed: params.seed);
  }
}

/// Parameters for StartQuizUseCase
class StartQuizParams {
  final int quizId;
  final int? seed;

  const StartQuizParams({required this.quizId, this.seed});
}
