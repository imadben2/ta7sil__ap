import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/planner_repository.dart';

/// Use case for rescheduling a study session
class RescheduleSession implements UseCase<Unit, RescheduleSessionParams> {
  final PlannerRepository repository;

  RescheduleSession(this.repository);

  @override
  Future<Either<Failure, Unit>> call(RescheduleSessionParams params) async {
    return await repository.rescheduleSession(params.sessionId, params.newDate);
  }
}

class RescheduleSessionParams {
  final String sessionId;
  final DateTime newDate;

  RescheduleSessionParams({required this.sessionId, required this.newDate});
}
