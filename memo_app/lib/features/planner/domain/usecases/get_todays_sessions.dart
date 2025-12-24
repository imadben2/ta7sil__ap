import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/study_session.dart';
import '../repositories/planner_repository.dart';

/// Use case for getting today's study sessions
class GetTodaysSessions implements UseCase<List<StudySession>, NoParams> {
  final PlannerRepository repository;

  GetTodaysSessions(this.repository);

  @override
  Future<Either<Failure, List<StudySession>>> call(NoParams params) async {
    return await repository.getTodaysSessions();
  }
}
