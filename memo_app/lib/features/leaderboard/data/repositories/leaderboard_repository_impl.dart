import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/leaderboard_entity.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../datasources/leaderboard_remote_datasource.dart';

/// Implementation of LeaderboardRepository
class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardRemoteDataSource remoteDataSource;

  LeaderboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, LeaderboardData>> getStreamLeaderboard({
    required LeaderboardPeriod period,
    int limit = 50,
  }) async {
    try {
      final result = await remoteDataSource.getStreamLeaderboard(
        period: period,
        limit: limit,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(GenericFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, LeaderboardData>> getSubjectLeaderboard({
    required int subjectId,
    required LeaderboardPeriod period,
    int limit = 50,
  }) async {
    try {
      final result = await remoteDataSource.getSubjectLeaderboard(
        subjectId: subjectId,
        period: period,
        limit: limit,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(GenericFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  /// Handle Dio errors and convert to appropriate Failure types
  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _extractErrorMessage(error.response?.data);

        if (statusCode == 401) {
          return AuthenticationFailure(message);
        } else if (statusCode == 403) {
          return PermissionFailure(message);
        } else if (statusCode == 404) {
          return NotFoundFailure(message);
        } else if (statusCode == 422) {
          return ValidationFailure(message);
        } else if (statusCode != null && statusCode >= 500) {
          return ServerFailure(message);
        }
        return ClientFailure(message);
      default:
        return const GenericFailure();
    }
  }

  /// Extract error message from API response
  String _extractErrorMessage(dynamic data) {
    if (data == null) return 'حدث خطأ ما';

    if (data is Map<String, dynamic>) {
      if (data.containsKey('message')) {
        return data['message'] as String;
      }
      if (data.containsKey('error')) {
        return data['error'] as String;
      }
    }

    return 'حدث خطأ ما';
  }
}
