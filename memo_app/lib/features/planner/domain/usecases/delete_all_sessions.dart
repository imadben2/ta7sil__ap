import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/planner_repository.dart';

/// Use case for deleting all study sessions (entire schedule)
class DeleteAllSessions implements UseCase<Unit, NoParams> {
  final PlannerRepository repository;

  DeleteAllSessions(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    return await repository.deleteAllSessions();
  }
}
