import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/bac_study_day_model.dart';
import '../models/bac_weekly_reward_model.dart';
import '../models/bac_user_stats_model.dart';

/// Remote data source for BAC Study Schedule feature
class BacStudyRemoteDataSource {
  final Dio dio;

  BacStudyRemoteDataSource({required this.dio});

  /// Get full 98-day schedule for a stream
  /// Uses: GET /api/bac-study/schedule/{stream_id}
  Future<List<BacStudyDayModel>> getFullSchedule(int streamId) async {
    final response = await dio.get(
      '${ApiConstants.bacStudySchedule}/$streamId',
    );
    final data = response.data['data'] as List;
    return data
        .map((json) => BacStudyDayModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get a specific day's schedule
  /// Uses: GET /api/bac-study/day/{stream_id}/{day_number}
  Future<BacStudyDayModel> getDaySchedule(int streamId, int dayNumber) async {
    final response = await dio.get(
      '${ApiConstants.bacStudyDay}/$streamId/$dayNumber',
    );
    return BacStudyDayModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  /// Get a specific week's schedule with reward
  /// Uses: GET /api/bac-study/week/{stream_id}/{week_number}
  Future<Map<String, dynamic>> getWeekSchedule(
    int streamId,
    int weekNumber,
  ) async {
    final response = await dio.get(
      '${ApiConstants.bacStudyWeek}/$streamId/$weekNumber',
    );
    // API returns: { "success": true, "week_number": 1, "data": [...] }
    // We need to return the entire response.data, not response.data['data']
    return response.data as Map<String, dynamic>;
  }

  /// Get a day with user's progress
  /// Uses: GET /api/bac-study/day-with-progress/{stream_id}/{day_number}
  Future<BacStudyDayModel> getDayWithProgress(
    int streamId,
    int dayNumber,
  ) async {
    final response = await dio.get(
      '${ApiConstants.bacStudyDayWithProgress}/$streamId/$dayNumber',
    );
    return BacStudyDayModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  /// Get user's overall statistics
  /// Uses: GET /api/bac-study/progress/stats
  Future<BacUserStatsModel> getUserStats(int streamId) async {
    final response = await dio.get(
      ApiConstants.bacStudyStats,
      queryParameters: {'stream_id': streamId},
    );
    return BacUserStatsModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  /// Get all weekly rewards
  /// Uses: GET /api/bac-study/rewards/{stream_id}
  Future<List<BacWeeklyRewardModel>> getWeeklyRewards(int streamId) async {
    final response = await dio.get(
      '${ApiConstants.bacStudyRewards}/$streamId',
    );
    final data = response.data['data'] as List;
    return data
        .map((json) =>
            BacWeeklyRewardModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Mark a topic as completed or incomplete
  /// Uses: POST /api/bac-study/progress/complete
  Future<void> markTopicComplete(int topicId, bool isCompleted) async {
    await dio.post(
      ApiConstants.bacStudyComplete,
      data: {
        'topic_id': topicId,
        'is_completed': isCompleted,
      },
    );
  }
}
