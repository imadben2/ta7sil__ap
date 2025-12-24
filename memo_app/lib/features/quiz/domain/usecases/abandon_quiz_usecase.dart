import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/quiz_repository.dart';

/// Use case for abandoning a quiz attempt
class AbandonQuizUseCase {
  final QuizRepository repository;

  AbandonQuizUseCase(this.repository);

  Future<Either<Failure, void>> call(int attemptId) {
    return repository.abandonQuiz(attemptId);
  }
}
