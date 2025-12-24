import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/planner_analytics.dart';
import '../repositories/planner_repository.dart';

/// Use case for getting planner analytics
class GetPlannerAnalytics
    implements UseCase<PlannerAnalytics, PlannerAnalyticsParams> {
  final PlannerRepository repository;

  GetPlannerAnalytics(this.repository);

  @override
  Future<Either<Failure, PlannerAnalytics>> call(
    PlannerAnalyticsParams params,
  ) async {
    return await repository.getPlannerAnalytics(params.period);
  }
}

class PlannerAnalyticsParams {
  final String
  period; // 'last_7_days', 'last_30_days', 'last_3_months', 'all_time'

  const PlannerAnalyticsParams({this.period = 'last_30_days'});
}
