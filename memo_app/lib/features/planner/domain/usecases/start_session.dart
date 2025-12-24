import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/planner_repository.dart';

/// Use case for starting a study session
class StartSession implements UseCase<Unit, String> {
  final PlannerRepository repository;

  StartSession(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String sessionId) async {
    return await repository.startSession(sessionId);
  }
}
