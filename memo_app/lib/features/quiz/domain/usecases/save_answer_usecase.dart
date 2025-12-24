import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/quiz_repository.dart';

/// Use case for saving an answer during quiz attempt
class SaveAnswerUseCase {
  final QuizRepository repository;

  SaveAnswerUseCase(this.repository);

  Future<Either<Failure, void>> call(SaveAnswerParams params) {
    return repository.saveAnswer(
      attemptId: params.attemptId,
      questionId: params.questionId,
      answer: params.answer,
    );
  }
}

/// Parameters for SaveAnswerUseCase
class SaveAnswerParams {
  final int attemptId;
  final int questionId;
  final dynamic answer;

  const SaveAnswerParams({
    required this.attemptId,
    required this.questionId,
    required this.answer,
  });
}
