import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/simulation_results_entity.dart';
import '../repositories/bac_repository.dart';

/// Use case to get detailed results for a specific simulation
class GetSimulationResults {
  final BacRepository repository;

  GetSimulationResults(this.repository);

  Future<Either<Failure, SimulationResultsEntity>> call(
    int simulationId,
  ) async {
    return await repository.getSimulationResults(simulationId);
  }
}
