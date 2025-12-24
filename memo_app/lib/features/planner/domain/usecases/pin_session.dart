import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/planner_repository.dart';

/// Use case for pinning/unpinning a study session
/// Pinned sessions prevent auto-rescheduling
class PinSession implements UseCase<Unit, PinSessionParams> {
  final PlannerRepository repository;

  PinSession(this.repository);

  @override
  Future<Either<Failure, Unit>> call(PinSessionParams params) async {
    return await repository.pinSession(params.sessionId, params.isPinned);
  }
}

class PinSessionParams {
  final String sessionId;
  final bool isPinned;

  PinSessionParams({required this.sessionId, required this.isPinned});
}
