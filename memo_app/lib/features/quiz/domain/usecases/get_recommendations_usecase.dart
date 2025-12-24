import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/quiz_entity.dart';
import '../repositories/quiz_repository.dart';

/// Use case for getting recommended quizzes
class GetRecommendationsUseCase {
  final QuizRepository repository;

  GetRecommendationsUseCase(this.repository);

  Future<Either<Failure, List<QuizEntity>>> call({int limit = 10}) {
    return repository.getRecommendations(limit: limit);
  }
}
