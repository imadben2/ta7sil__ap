import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/quiz_attempt_entity.dart';
import '../repositories/quiz_repository.dart';

/// Use case for getting quiz attempts history
class GetAttemptsHistoryUseCase {
  final QuizRepository repository;

  GetAttemptsHistoryUseCase(this.repository);

  Future<Either<Failure, List<QuizAttemptEntity>>> call(
    GetAttemptsHistoryParams params,
  ) async {
    return await repository.getAttemptsHistory(page: params.page);
  }
}

/// Parameters for getting attempts history
class GetAttemptsHistoryParams {
  final int? quizId;
  final int page;
  final int limit;

  const GetAttemptsHistoryParams({this.quizId, this.page = 1, this.limit = 20});
}
