import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/subject.dart';
import '../repositories/planner_repository.dart';

/// Use case for adding a new subject
class AddSubject implements UseCase<Subject, Subject> {
  final PlannerRepository repository;

  AddSubject(this.repository);

  @override
  Future<Either<Failure, Subject>> call(Subject subject) async {
    return await repository.addSubject(subject);
  }
}
