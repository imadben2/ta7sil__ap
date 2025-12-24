import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/bac_study_day.dart';
import '../../domain/entities/bac_weekly_reward.dart';
import '../../domain/entities/bac_user_stats.dart';
import '../../domain/repositories/bac_study_repository.dart';
import '../datasources/bac_study_remote_datasource.dart';
import '../datasources/bac_study_local_datasource.dart';
import '../models/bac_study_day_model.dart';
import '../models/bac_weekly_reward_model.dart';

/// Implementation of BacStudyRepository with offline support
class BacStudyRepositoryImpl implements BacStudyRepository {
  final BacStudyRemoteDataSource remoteDataSource;
  final BacStudyLocalDataSource localDataSource;

  BacStudyRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<BacStudyDay>>> getFullSchedule(int streamId) async {
    try {
      // Try to get cached data first
      final cachedSchedule = await localDataSource.getCachedFullSchedule(streamId);
      if (cachedSchedule != null) {
        return Right(cachedSchedule);
      }

      // Fetch from remote
      final schedule = await remoteDataSource.getFullSchedule(streamId);

      // Cache the data
      await localDataSource.cacheFullSchedule(streamId, schedule);

      return Right(schedule);
    } on DioException catch (e) {
      // Try to return cached data on network error
      final cachedSchedule = await localDataSource.getCachedFullSchedule(streamId);
      if (cachedSchedule != null) {
        return Right(cachedSchedule);
      }
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BacStudyDay>> getDaySchedule(
    int streamId,
    int dayNumber,
  ) async {
    try {
      // Try cache first
      final cachedDay = await localDataSource.getCachedDaySchedule(
        streamId,
        dayNumber,
      );
      if (cachedDay != null) {
        return Right(cachedDay);
      }

      // Fetch from remote
      final day = await remoteDataSource.getDaySchedule(streamId, dayNumber);

      // Cache the data
      await localDataSource.cacheDaySchedule(streamId, dayNumber, day);

      return Right(day);
    } on DioException catch (e) {
      // Try cached data on error
      final cachedDay = await localDataSource.getCachedDaySchedule(
        streamId,
        dayNumber,
      );
      if (cachedDay != null) {
        return Right(cachedDay);
      }
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BacWeekScheduleData>> getWeekSchedule(
    int streamId,
    int weekNumber,
  ) async {
    try {
      // Always fetch fresh data to get current progress
      // Cache is only used as fallback for network errors
      final weekData = await remoteDataSource.getWeekSchedule(
        streamId,
        weekNumber,
      );

      // Cache the data for offline fallback
      await localDataSource.cacheWeekSchedule(streamId, weekNumber, weekData);

      return Right(_parseWeekScheduleData(weekData));
    } on DioException catch (e) {
      // Try cached data on error
      final cachedWeek = await localDataSource.getCachedWeekSchedule(
        streamId,
        weekNumber,
      );
      if (cachedWeek != null) {
        try {
          return Right(_parseWeekScheduleData(cachedWeek));
        } catch (parseError) {
          // If parsing fails, return network error instead
          return Left(_handleDioError(e));
        }
      }
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BacStudyDay>> getDayWithProgress(
    int streamId,
    int dayNumber,
  ) async {
    try {
      // Always fetch fresh data for progress
      final day = await remoteDataSource.getDayWithProgress(streamId, dayNumber);

      // Update cache
      await localDataSource.cacheDaySchedule(streamId, dayNumber, day);

      // Apply any local offline progress
      final localProgress = localDataSource.getLocalTopicProgress();
      if (localProgress.isNotEmpty) {
        return Right(_applyLocalProgress(day, localProgress));
      }

      return Right(day);
    } on DioException catch (e) {
      // On network error, try to return cached day with local progress
      final cachedDay = await localDataSource.getCachedDaySchedule(
        streamId,
        dayNumber,
      );
      if (cachedDay != null) {
        final localProgress = localDataSource.getLocalTopicProgress();
        return Right(_applyLocalProgress(cachedDay, localProgress));
      }
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BacUserStats>> getUserStats(int streamId) async {
    try {
      // Try cache first
      final cachedStats = await localDataSource.getCachedUserStats(streamId);
      if (cachedStats != null) {
        return Right(cachedStats);
      }

      // Fetch from remote
      final stats = await remoteDataSource.getUserStats(streamId);

      // Cache the data
      await localDataSource.cacheUserStats(streamId, stats);

      return Right(stats);
    } on DioException catch (e) {
      // Try cached data on error
      final cachedStats = await localDataSource.getCachedUserStats(streamId);
      if (cachedStats != null) {
        return Right(cachedStats);
      }
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BacWeeklyReward>>> getWeeklyRewards(
    int streamId,
  ) async {
    try {
      // Try cache first
      final cachedRewards = await localDataSource.getCachedWeeklyRewards(streamId);
      if (cachedRewards != null) {
        return Right(cachedRewards);
      }

      // Fetch from remote
      final rewards = await remoteDataSource.getWeeklyRewards(streamId);

      // Cache the data
      await localDataSource.cacheWeeklyRewards(streamId, rewards);

      return Right(rewards);
    } on DioException catch (e) {
      // Try cached data on error
      final cachedRewards = await localDataSource.getCachedWeeklyRewards(streamId);
      if (cachedRewards != null) {
        return Right(cachedRewards);
      }
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markTopicComplete(
    int topicId,
    bool isCompleted,
  ) async {
    try {
      // Save locally first (offline support)
      await localDataSource.saveTopicProgress(topicId, isCompleted);

      // Try to sync with server
      await remoteDataSource.markTopicComplete(topicId, isCompleted);

      // Clear local progress for this topic after successful sync
      await localDataSource.clearSyncedProgress([topicId]);

      // Invalidate stats cache to force refresh
      await localDataSource.clearScheduleCache();

      return const Right(unit);
    } on DioException catch (e) {
      // Already saved locally, return success for offline mode
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ============ Helper Methods ============

  /// Parse week schedule data from JSON
  /// API returns: { "success": true, "week_number": 1, "data": [...] }
  BacWeekScheduleData _parseWeekScheduleData(Map<String, dynamic> responseData) {
    try {
      // Validate data structure - API uses "data" field for days array
      if (responseData['data'] == null || responseData['data'] is! List) {
        throw FormatException('Invalid week schedule data: data is not a list');
      }

      // Parse week_number safely - it might be null, int, or string
      final weekNumberValue = responseData['week_number'];
      final weekNumberInt = weekNumberValue != null
          ? (weekNumberValue is int ? weekNumberValue : int.tryParse(weekNumberValue.toString()) ?? 1)
          : 1;

      // Parse days and inject week_number if not present
      final days = (responseData['data'] as List)
          .map((json) {
            if (json is! Map) {
              throw FormatException('Invalid day data: not a map');
            }
            // Create a mutable copy and add week_number if missing
            final dayJson = Map<String, dynamic>.from(json as Map);
            if (dayJson['week_number'] == null) {
              dayJson['week_number'] = weekNumberInt;
            }
            return BacStudyDayModel.fromJson(dayJson);
          })
          .toList();

      BacWeeklyReward? reward;
      if (responseData['reward'] != null) {
        if (responseData['reward'] is! Map) {
          throw FormatException('Invalid reward data: not a map');
        }
        reward = BacWeeklyRewardModel.fromJson(
          Map<String, dynamic>.from(responseData['reward'] as Map),
        );
      }

      return BacWeekScheduleData(
        weekNumber: weekNumberInt,
        days: days,
        reward: reward,
      );
    } catch (e) {
      // If parsing fails, throw a more descriptive error
      throw FormatException('Failed to parse week schedule data: ${e.toString()}');
    }
  }

  /// Apply local offline progress to a day
  BacStudyDay _applyLocalProgress(
    BacStudyDay day,
    Map<int, bool> localProgress,
  ) {
    if (localProgress.isEmpty) return day;

    final updatedSubjects = day.subjects.map((subject) {
      final updatedTopics = subject.topics.map((topic) {
        if (localProgress.containsKey(topic.id)) {
          return topic.copyWith(isCompleted: localProgress[topic.id]);
        }
        return topic;
      }).toList();
      return subject.copyWith(topics: updatedTopics);
    }).toList();

    return day.copyWith(subjects: updatedSubjects);
  }

  /// Handle Dio errors and return appropriate failure
  Failure _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return const AuthenticationFailure();
        } else if (statusCode == 403) {
          return const PermissionFailure();
        } else if (statusCode == 404) {
          return const NotFoundFailure('جدول المراجعة غير متوفر لهذا التخصص');
        } else {
          return ServerFailure(e.message ?? 'خطأ في الخادم');
        }
      default:
        return ServerFailure(e.message ?? 'حدث خطأ ما');
    }
  }
}
