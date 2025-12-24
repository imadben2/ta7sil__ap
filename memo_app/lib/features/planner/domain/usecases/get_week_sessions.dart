import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/study_session.dart';
import '../repositories/planner_repository.dart';

/// Use case for getting a week's study sessions
class GetWeekSessions implements UseCase<List<StudySession>, GetWeekSessionsParams> {
  final PlannerRepository repository;

  GetWeekSessions(this.repository);

  @override
  Future<Either<Failure, List<StudySession>>> call(GetWeekSessionsParams params) async {
    return await repository.getWeekSessions(params.startDate);
  }
}

class GetWeekSessionsParams {
  final DateTime startDate;

  const GetWeekSessionsParams({required this.startDate});
}
