import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/statistics_entity.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../datasources/statistics_remote_datasource.dart';
import '../datasources/statistics_local_datasource.dart';

/// تطبيق مستودع الإحصائيات
class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsRemoteDataSource remoteDataSource;
  final StatisticsLocalDataSource localDataSource;

  StatisticsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, StatisticsEntity>> getStatistics() async {
    try {
      // محاولة الجلب من Cache
      final cachedStats = await localDataSource.getCachedStatistics();
      if (cachedStats != null) {
        return Right(cachedStats.toEntity());
      }

      // الجلب من API
      final remoteStats = await remoteDataSource.getStatistics();

      // حفظ في Cache
      await localDataSource.cacheStatistics(remoteStats);

      return Right(remoteStats.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, List<WeeklyDataPoint>>> getWeeklyChart({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final weeklyData = await remoteDataSource.getWeeklyChart(
        startDate: startDate,
        endDate: endDate,
      );

      final entities = weeklyData.map((d) => d.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء جلب بيانات الرسم البياني'));
    }
  }

  @override
  Future<Either<Failure, StatisticsEntity>> refreshStatistics() async {
    try {
      // تجاوز Cache والجلب مباشرة من API
      final remoteStats = await remoteDataSource.getStatistics();

      // تحديث Cache
      await localDataSource.cacheStatistics(remoteStats);

      return Right(remoteStats.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء تحديث الإحصائيات'));
    }
  }
}
