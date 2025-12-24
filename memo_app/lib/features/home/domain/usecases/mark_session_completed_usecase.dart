import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/home_repository.dart';

/// Use case to mark a study session as completed
class MarkSessionCompletedUseCase {
  final HomeRepository repository;

  MarkSessionCompletedUseCase(this.repository);

  Future<Either<Failure, void>> call(int sessionId) async {
    return await repository.markSessionCompleted(sessionId);
  }
}
