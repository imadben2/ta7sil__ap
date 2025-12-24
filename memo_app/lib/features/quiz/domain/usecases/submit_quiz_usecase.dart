import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/quiz_result_entity.dart';
import '../repositories/quiz_repository.dart';

/// Use case for submitting quiz for grading
class SubmitQuizUseCase {
  final QuizRepository repository;

  SubmitQuizUseCase(this.repository);

  Future<Either<Failure, QuizResultEntity>> call(SubmitQuizParams params) {
    return repository.submitQuiz(
      attemptId: params.attemptId,
      finalAnswers: params.finalAnswers,
    );
  }
}

/// Parameters for SubmitQuizUseCase
class SubmitQuizParams {
  final int attemptId;
  final Map<int, dynamic>? finalAnswers;

  const SubmitQuizParams({required this.attemptId, this.finalAnswers});
}
