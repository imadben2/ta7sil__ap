import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/planner_settings.dart';
import '../repositories/planner_repository.dart';

/// Use case for getting planner settings
class GetPlannerSettings implements UseCase<PlannerSettings, NoParams> {
  final PlannerRepository repository;

  GetPlannerSettings(this.repository);

  @override
  Future<Either<Failure, PlannerSettings>> call(NoParams params) async {
    return await repository.getSettings();
  }
}
