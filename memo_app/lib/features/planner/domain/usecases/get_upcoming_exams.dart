import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/exam.dart';
import '../repositories/planner_repository.dart';

/// Use case for getting upcoming exams
class GetUpcomingExams implements UseCase<List<Exam>, NoParams> {
  final PlannerRepository repository;

  GetUpcomingExams(this.repository);

  @override
  Future<Either<Failure, List<Exam>>> call(NoParams params) async {
    return await repository.getUpcomingExams();
  }
}
