import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/exam.dart';
import '../repositories/planner_repository.dart';

/// Use case for adding a new exam
class AddExam implements UseCase<Exam, Exam> {
  final PlannerRepository repository;

  AddExam(this.repository);

  @override
  Future<Either<Failure, Exam>> call(Exam exam) async {
    return await repository.addExam(exam);
  }
}
