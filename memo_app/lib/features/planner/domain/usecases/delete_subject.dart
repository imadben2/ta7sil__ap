import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/planner_repository.dart';

/// Use case for deleting a subject
class DeleteSubject implements UseCase<Unit, String> {
  final PlannerRepository repository;

  DeleteSubject(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String subjectId) async {
    return await repository.deleteSubject(subjectId);
  }
}
