import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/planner_repository.dart';

/// Use case for pausing a study session
class PauseSession implements UseCase<Unit, String> {
  final PlannerRepository repository;

  PauseSession(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String sessionId) async {
    return await repository.pauseSession(sessionId);
  }
}
