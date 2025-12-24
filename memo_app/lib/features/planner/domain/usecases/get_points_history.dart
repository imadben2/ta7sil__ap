import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/points_history.dart';
import '../repositories/planner_repository.dart';

/// Use case for getting points history
class GetPointsHistory implements UseCase<PointsHistory, PointsHistoryParams> {
  final PlannerRepository repository;

  GetPointsHistory(this.repository);

  @override
  Future<Either<Failure, PointsHistory>> call(PointsHistoryParams params) async {
    return await repository.getPointsHistory(params.periodDays);
  }
}

class PointsHistoryParams {
  final int periodDays;

  const PointsHistoryParams({this.periodDays = 30});
}
