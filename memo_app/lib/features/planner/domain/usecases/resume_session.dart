import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/planner_repository.dart';

/// Use case for resuming a paused study session
class ResumeSession implements UseCase<Unit, String> {
  final PlannerRepository repository;

  ResumeSession(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String sessionId) async {
    return await repository.resumeSession(sessionId);
  }
}
