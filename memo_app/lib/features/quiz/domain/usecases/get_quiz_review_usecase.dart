import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/quiz_result_entity.dart';
import '../repositories/quiz_repository.dart';

/// Use case for getting quiz review with answer breakdown
class GetQuizReviewUseCase {
  final QuizRepository repository;

  GetQuizReviewUseCase(this.repository);

  Future<Either<Failure, QuizResultEntity>> call(int attemptId) {
    return repository.getQuizReview(attemptId);
  }
}
