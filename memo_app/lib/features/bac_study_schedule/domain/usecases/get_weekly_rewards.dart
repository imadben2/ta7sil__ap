import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/bac_weekly_reward.dart';
import '../repositories/bac_study_repository.dart';

/// Use case to get all weekly rewards for a stream
class GetWeeklyRewards implements UseCase<List<BacWeeklyReward>, GetWeeklyRewardsParams> {
  final BacStudyRepository repository;

  GetWeeklyRewards(this.repository);

  @override
  Future<Either<Failure, List<BacWeeklyReward>>> call(GetWeeklyRewardsParams params) {
    return repository.getWeeklyRewards(params.streamId);
  }
}

class GetWeeklyRewardsParams {
  final int streamId;

  const GetWeeklyRewardsParams({required this.streamId});
}
