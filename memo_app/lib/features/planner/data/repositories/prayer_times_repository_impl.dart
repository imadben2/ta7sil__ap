import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/prayer_times.dart';
import '../../domain/repositories/prayer_times_repository.dart';
import '../datasources/prayer_times_datasource.dart';
import 'package:flutter/foundation.dart';

/// Prayer Times Repository Implementation
///
/// Implements the domain repository interface
/// Handles error mapping and offline-first strategy
class PrayerTimesRepositoryImpl implements PrayerTimesRepository {
  final PrayerTimesDataSource dataSource;

  PrayerTimesRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, PrayerTimes>> getPrayerTimes({
    required String city,
    required DateTime date,
  }) async {
    try {
      // Try to fetch from API (will check cache first internally)
      final prayerTimesModel = await dataSource.fetchPrayerTimes(
        city: city,
        date: date,
      );

      // Convert model to entity
      return Right(prayerTimesModel.toEntity());
    } on PrayerTimesException catch (e) {
      return Left(PrayerTimesFailure(e.message));
    } on NetworkException catch (e) {
      // Try to use cached data as fallback
      try {
        final cached = await dataSource.getCachedPrayerTimes(
          city: city,
          date: date,
        );

        if (cached != null) {
          return Right(cached.toEntity());
        }
      } catch (_) {
        // Cache also failed, return network failure
      }

      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      // Try cached data on timeout
      try {
        final cached = await dataSource.getCachedPrayerTimes(
          city: city,
          date: date,
        );

        if (cached != null) {
          return Right(cached.toEntity());
        }
      } catch (_) {}

      return Left(TimeoutFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(
        PrayerTimesFailure('فشل تحميل مواقيت الصلاة: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Map<DateTime, PrayerTimes>>> getPrayerTimesRange({
    required String city,
    required DateTime startDate,
    int days = 7,
  }) async {
    try {
      final prayerTimesMap = <DateTime, PrayerTimes>{};

      // Fetch prayer times for each day
      for (int i = 0; i < days; i++) {
        final date = startDate.add(Duration(days: i));

        try {
          final prayerTimesModel = await dataSource.fetchPrayerTimes(
            city: city,
            date: date,
          );

          prayerTimesMap[date] = prayerTimesModel.toEntity();
        } catch (e) {
          // Try cache for this specific date
          try {
            final cached = await dataSource.getCachedPrayerTimes(
              city: city,
              date: date,
            );

            if (cached != null) {
              prayerTimesMap[date] = cached.toEntity();
            }
          } catch (_) {
            // Skip this date if both API and cache fail
            if (kDebugMode)
              print(
                '[PrayerTimesRepository] Failed to get prayer times for $date',
              );
          }
        }
      }

      if (prayerTimesMap.isEmpty) {
        return const Left(
          PrayerTimesFailure('فشل تحميل مواقيت الصلاة لجميع الأيام'),
        );
      }

      return Right(prayerTimesMap);
    } catch (e) {
      return Left(
        PrayerTimesFailure('خطأ في تحميل مواقيت الصلاة: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, PrayerTimes?>> getCachedPrayerTimes({
    required String city,
    required DateTime date,
  }) async {
    try {
      final cached = await dataSource.getCachedPrayerTimes(
        city: city,
        date: date,
      );

      if (cached == null) {
        return const Right(null);
      }

      return Right(cached.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('فشل قراءة مواقيت الصلاة المحفوظة'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearCache() async {
    try {
      await dataSource.clearCache();
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return const Left(CacheFailure('فشل مسح ذاكرة التخزين المؤقت'));
    }
  }
}
