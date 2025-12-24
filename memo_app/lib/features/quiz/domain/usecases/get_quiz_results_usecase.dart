import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/quiz_result_entity.dart';
import '../repositories/quiz_repository.dart';

/// Use case for getting quiz results
class GetQuizResultsUseCase {
  final QuizRepository repository;

  GetQuizResultsUseCase(this.repository);

  Future<Either<Failure, QuizResultEntity>> call(int attemptId) {
    return repository.getQuizResults(attemptId);
  }
}
