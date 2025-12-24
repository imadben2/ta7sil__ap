import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/quiz_performance_entity.dart';
import '../repositories/quiz_repository.dart';

/// Use case for getting quiz performance statistics
class GetPerformanceUseCase {
  final QuizRepository repository;

  GetPerformanceUseCase(this.repository);

  Future<Either<Failure, QuizPerformanceEntity>> call(
    GetPerformanceParams params,
  ) {
    return repository.getPerformance(
      subjectId: params.subjectId,
      period: params.period,
    );
  }
}

/// Parameters for GetPerformanceUseCase
class GetPerformanceParams {
  final int? subjectId;
  final String period;

  const GetPerformanceParams({this.subjectId, this.period = 'all'});
}
