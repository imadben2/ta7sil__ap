import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/subject.dart';
import '../repositories/planner_repository.dart';

/// Use case for updating an existing subject
class UpdateSubject implements UseCase<Subject, Subject> {
  final PlannerRepository repository;

  UpdateSubject(this.repository);

  @override
  Future<Either<Failure, Subject>> call(Subject subject) async {
    return await repository.updateSubject(subject);
  }
}
