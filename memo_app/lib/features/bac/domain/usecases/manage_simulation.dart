import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bac_simulation_entity.dart';
import '../repositories/bac_repository.dart';

/// Use case to start a simulation
class StartSimulation {
  final BacRepository repository;

  StartSimulation(this.repository);

  Future<Either<Failure, BacSimulationEntity>> call(int simulationId) async {
    return await repository.startSimulation(simulationId);
  }
}

/// Use case to pause a simulation
class PauseSimulation {
  final BacRepository repository;

  PauseSimulation(this.repository);

  Future<Either<Failure, BacSimulationEntity>> call(int simulationId) async {
    return await repository.pauseSimulation(simulationId);
  }
}

/// Use case to resume a paused simulation
class ResumeSimulation {
  final BacRepository repository;

  ResumeSimulation(this.repository);

  Future<Either<Failure, BacSimulationEntity>> call(int simulationId) async {
    return await repository.resumeSimulation(simulationId);
  }
}
