import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/leaderboard_entity.dart';
import '../repositories/leaderboard_repository.dart';

/// Use case to get stream leaderboard (rankings by academic stream)
class GetStreamLeaderboardUseCase {
  final LeaderboardRepository repository;

  GetStreamLeaderboardUseCase(this.repository);

  Future<Either<Failure, LeaderboardData>> call({
    required LeaderboardPeriod period,
    int limit = 50,
  }) {
    return repository.getStreamLeaderboard(
      period: period,
      limit: limit,
    );
  }
}

/// Use case to get subject leaderboard (rankings by subject)
class GetSubjectLeaderboardUseCase {
  final LeaderboardRepository repository;

  GetSubjectLeaderboardUseCase(this.repository);

  Future<Either<Failure, LeaderboardData>> call({
    required int subjectId,
    required LeaderboardPeriod period,
    int limit = 50,
  }) {
    return repository.getSubjectLeaderboard(
      subjectId: subjectId,
      period: period,
      limit: limit,
    );
  }
}
