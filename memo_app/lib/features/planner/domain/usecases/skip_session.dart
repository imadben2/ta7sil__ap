import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/planner_repository.dart';

/// Use case for skipping a study session
class SkipSession implements UseCase<Unit, SkipSessionParams> {
  final PlannerRepository repository;

  SkipSession(this.repository);

  @override
  Future<Either<Failure, Unit>> call(SkipSessionParams params) async {
    return await repository.skipSession(params.sessionId, params.reason);
  }
}

class SkipSessionParams {
  final String sessionId;
  final String reason;

  SkipSessionParams({required this.sessionId, required this.reason});
}
