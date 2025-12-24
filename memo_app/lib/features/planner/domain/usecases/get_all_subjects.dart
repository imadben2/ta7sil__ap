import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/subject.dart';
import '../repositories/planner_repository.dart';

/// Use case for getting all subjects
class GetAllSubjects implements UseCase<List<Subject>, NoParams> {
  final PlannerRepository repository;

  GetAllSubjects(this.repository);

  @override
  Future<Either<Failure, List<Subject>>> call(NoParams params) async {
    return await repository.getAllSubjects();
  }
}
