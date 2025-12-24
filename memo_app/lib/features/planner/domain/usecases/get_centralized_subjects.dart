import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/centralized_subject.dart';
import '../repositories/planner_repository.dart';

/// Use case for fetching centralized subjects from shared API
///
/// These subjects are managed centrally and shared across features
/// (Planner, Content Management, etc.)
class GetCentralizedSubjects
    implements UseCase<List<CentralizedSubject>, GetCentralizedSubjectsParams> {
  final PlannerRepository repository;

  GetCentralizedSubjects(this.repository);

  @override
  Future<Either<Failure, List<CentralizedSubject>>> call(
    GetCentralizedSubjectsParams params,
  ) async {
    return await repository.getCentralizedSubjects(
      streamId: params.streamId,
      yearId: params.yearId,
      activeOnly: params.activeOnly,
    );
  }
}

/// Parameters for GetCentralizedSubjects use case
class GetCentralizedSubjectsParams {
  final int? streamId;
  final int? yearId;
  final bool activeOnly;

  const GetCentralizedSubjectsParams({
    this.streamId,
    this.yearId,
    this.activeOnly = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetCentralizedSubjectsParams &&
          runtimeType == other.runtimeType &&
          streamId == other.streamId &&
          yearId == other.yearId &&
          activeOnly == other.activeOnly;

  @override
  int get hashCode => streamId.hashCode ^ yearId.hashCode ^ activeOnly.hashCode;
}
