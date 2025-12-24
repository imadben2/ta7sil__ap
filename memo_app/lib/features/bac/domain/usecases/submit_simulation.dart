import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/simulation_results_entity.dart';
import '../repositories/bac_repository.dart';

/// Parameters for submitting a simulation
class SubmitSimulationParams {
  final int simulationId;
  final List<Map<String, dynamic>> answers;
  final int elapsedSeconds;
  final String? notes;

  SubmitSimulationParams({
    required this.simulationId,
    required this.answers,
    required this.elapsedSeconds,
    this.notes,
  });
}

/// Use case to submit simulation answers and complete it
class SubmitSimulation {
  final BacRepository repository;

  SubmitSimulation(this.repository);

  Future<Either<Failure, SimulationResultsEntity>> call(
    SubmitSimulationParams params,
  ) async {
    return await repository.submitSimulation(
      simulationId: params.simulationId,
      answers: params.answers,
      elapsedSeconds: params.elapsedSeconds,
      notes: params.notes,
    );
  }
}
