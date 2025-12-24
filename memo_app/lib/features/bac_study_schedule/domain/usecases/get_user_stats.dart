import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/bac_user_stats.dart';
import '../repositories/bac_study_repository.dart';

/// Use case to get user's overall BAC study statistics
class GetUserStats implements UseCase<BacUserStats, GetUserStatsParams> {
  final BacStudyRepository repository;

  GetUserStats(this.repository);

  @override
  Future<Either<Failure, BacUserStats>> call(GetUserStatsParams params) {
    return repository.getUserStats(params.streamId);
  }
}

class GetUserStatsParams {
  final int streamId;

  const GetUserStatsParams({required this.streamId});
}
