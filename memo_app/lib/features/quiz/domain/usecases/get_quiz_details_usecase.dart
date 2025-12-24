import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/quiz_entity.dart';
import '../repositories/quiz_repository.dart';

/// Use case for getting detailed quiz information
class GetQuizDetailsUseCase {
  final QuizRepository repository;

  GetQuizDetailsUseCase(this.repository);

  Future<Either<Failure, QuizEntity>> call(int quizId) {
    return repository.getQuizDetails(quizId);
  }
}
