import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/planner_repository.dart';

/// Use case for deleting an exam
class DeleteExam implements UseCase<Unit, String> {
  final PlannerRepository repository;

  DeleteExam(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String examId) async {
    return await repository.deleteExam(examId);
  }
}
