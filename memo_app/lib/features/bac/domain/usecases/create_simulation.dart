import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bac_simulation_entity.dart';
import '../entities/bac_enums.dart';
import '../repositories/bac_repository.dart';

/// Parameters for creating a simulation
class CreateSimulationParams {
  final int bacSubjectId;
  final SimulationMode mode;
  final DifficultyLevel? difficulty;
  final List<int>? chapterIds;
  final int totalQuestions;
  final int durationMinutes;

  CreateSimulationParams({
    required this.bacSubjectId,
    required this.mode,
    this.difficulty,
    this.chapterIds,
    required this.totalQuestions,
    required this.durationMinutes,
  });
}

/// Use case to create a new simulation
class CreateSimulation {
  final BacRepository repository;

  CreateSimulation(this.repository);

  Future<Either<Failure, BacSimulationEntity>> call(
    CreateSimulationParams params,
  ) async {
    return await repository.createSimulation(
      bacSubjectId: params.bacSubjectId,
      mode: params.mode,
      difficulty: params.difficulty,
      chapterIds: params.chapterIds,
      totalQuestions: params.totalQuestions,
      durationMinutes: params.durationMinutes,
    );
  }
}
