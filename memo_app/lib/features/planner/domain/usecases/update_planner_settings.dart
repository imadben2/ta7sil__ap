import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/planner_settings.dart';
import '../repositories/planner_repository.dart';

/// Use case for updating planner settings
class UpdatePlannerSettings implements UseCase<Unit, PlannerSettings> {
  final PlannerRepository repository;

  UpdatePlannerSettings(this.repository);

  @override
  Future<Either<Failure, Unit>> call(PlannerSettings settings) async {
    return await repository.updateSettings(settings);
  }
}
