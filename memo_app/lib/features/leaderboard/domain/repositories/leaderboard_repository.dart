import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/leaderboard_entity.dart';

/// Repository interface for leaderboard operations
abstract class LeaderboardRepository {
  /// Get leaderboard by user's academic stream
  ///
  /// [period] - Time period filter: 'week', 'month', 'all'
  /// [limit] - Maximum number of entries to return (default: 50)
  Future<Either<Failure, LeaderboardData>> getStreamLeaderboard({
    required LeaderboardPeriod period,
    int limit = 50,
  });

  /// Get leaderboard by subject
  ///
  /// [subjectId] - The subject to get rankings for
  /// [period] - Time period filter: 'week', 'month', 'all'
  /// [limit] - Maximum number of entries to return (default: 50)
  Future<Either<Failure, LeaderboardData>> getSubjectLeaderboard({
    required int subjectId,
    required LeaderboardPeriod period,
    int limit = 50,
  });
}
