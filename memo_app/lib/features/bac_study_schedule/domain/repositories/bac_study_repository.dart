import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bac_study_day.dart';
import '../entities/bac_weekly_reward.dart';
import '../entities/bac_user_stats.dart';

/// Abstract repository for BAC Study Schedule feature
abstract class BacStudyRepository {
  /// Get full 98-day schedule for a stream
  Future<Either<Failure, List<BacStudyDay>>> getFullSchedule(int streamId);

  /// Get a specific day's schedule
  Future<Either<Failure, BacStudyDay>> getDaySchedule(int streamId, int dayNumber);

  /// Get a specific week's schedule with reward
  Future<Either<Failure, BacWeekScheduleData>> getWeekSchedule(int streamId, int weekNumber);

  /// Get a day with user's progress
  Future<Either<Failure, BacStudyDay>> getDayWithProgress(int streamId, int dayNumber);

  /// Get user's overall statistics
  Future<Either<Failure, BacUserStats>> getUserStats(int streamId);

  /// Get all weekly rewards
  Future<Either<Failure, List<BacWeeklyReward>>> getWeeklyRewards(int streamId);

  /// Mark a topic as completed or incomplete
  Future<Either<Failure, Unit>> markTopicComplete(int topicId, bool isCompleted);
}

/// Data class for week schedule with reward
class BacWeekScheduleData {
  final int weekNumber;
  final List<BacStudyDay> days;
  final BacWeeklyReward? reward;

  const BacWeekScheduleData({
    required this.weekNumber,
    required this.days,
    this.reward,
  });
}
