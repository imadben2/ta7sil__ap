import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/quiz_attempt_entity.dart';
import '../repositories/quiz_repository.dart';

/// Use case for getting current in-progress quiz attempt
class GetCurrentAttemptUseCase {
  final QuizRepository repository;

  GetCurrentAttemptUseCase(this.repository);

  Future<Either<Failure, QuizAttemptEntity?>> call() {
    return repository.getCurrentAttempt();
  }
}
