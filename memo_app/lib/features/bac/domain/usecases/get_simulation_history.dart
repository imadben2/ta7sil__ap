import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bac_simulation_entity.dart';
import '../entities/bac_enums.dart';
import '../repositories/bac_repository.dart';

/// Parameters for getting simulation history
class GetSimulationHistoryParams {
  final int? bacSubjectId;
  final SimulationStatus? status;
  final int? limit;

  GetSimulationHistoryParams({this.bacSubjectId, this.status, this.limit});
}

/// Use case to get user's simulation history
class GetSimulationHistory {
  final BacRepository repository;

  GetSimulationHistory(this.repository);

  Future<Either<Failure, List<BacSimulationEntity>>> call([
    GetSimulationHistoryParams? params,
  ]) async {
    return await repository.getSimulationHistory(
      bacSubjectId: params?.bacSubjectId,
      status: params?.status,
      limit: params?.limit,
    );
  }
}
