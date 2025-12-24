import 'package:dio/dio.dart';
import '../../domain/entities/leaderboard_entity.dart';
import '../models/leaderboard_model.dart';

/// Remote data source for leaderboard feature
///
/// Handles all API calls to Laravel backend for leaderboard data
abstract class LeaderboardRemoteDataSource {
  /// Get leaderboard by user's academic stream
  ///
  /// [period] - Time period filter: 'week', 'month', 'all'
  /// [limit] - Maximum number of entries to return
  Future<LeaderboardDataModel> getStreamLeaderboard({
    required LeaderboardPeriod period,
    int limit = 50,
  });

  /// Get leaderboard by subject
  ///
  /// [subjectId] - The subject to get rankings for
  /// [period] - Time period filter: 'week', 'month', 'all'
  /// [limit] - Maximum number of entries to return
  Future<LeaderboardDataModel> getSubjectLeaderboard({
    required int subjectId,
    required LeaderboardPeriod period,
    int limit = 50,
  });
}

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  final Dio dio;

  LeaderboardRemoteDataSourceImpl({required this.dio});

  @override
  Future<LeaderboardDataModel> getStreamLeaderboard({
    required LeaderboardPeriod period,
    int limit = 50,
  }) async {
    final response = await dio.get(
      '/v1/leaderboard/stream',
      queryParameters: {
        'period': period.value,
        'limit': limit,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data['data'] as Map<String, dynamic>;
      return LeaderboardDataModel.fromJson(data);
    }

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Failed to fetch stream leaderboard',
    );
  }

  @override
  Future<LeaderboardDataModel> getSubjectLeaderboard({
    required int subjectId,
    required LeaderboardPeriod period,
    int limit = 50,
  }) async {
    final response = await dio.get(
      '/v1/leaderboard/subject/$subjectId',
      queryParameters: {
        'period': period.value,
        'limit': limit,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data['data'] as Map<String, dynamic>;
      return LeaderboardDataModel.fromJson(data);
    }

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Failed to fetch subject leaderboard',
    );
  }
}
