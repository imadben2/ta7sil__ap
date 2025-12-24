import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/exam.dart';
import '../repositories/planner_repository.dart';

/// Use case for updating an existing exam
class UpdateExam implements UseCase<Exam, Exam> {
  final PlannerRepository repository;

  UpdateExam(this.repository);

  @override
  Future<Either<Failure, Exam>> call(Exam exam) async {
    return await repository.updateExam(exam);
  }
}
