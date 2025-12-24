import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/planner_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/prayer_times_model.dart';

/// Prayer Times Data Source Interface
///
/// Handles fetching prayer times from Aladhan API and caching
abstract class PrayerTimesDataSource {
  /// Fetch prayer times from Aladhan API
  Future<PrayerTimesModel> fetchPrayerTimes({
    required String city,
    required DateTime date,
  });

  /// Get cached prayer times from Hive
  Future<PrayerTimesModel?> getCachedPrayerTimes({
    required String city,
    required DateTime date,
  });

  /// Cache prayer times to Hive
  Future<void> cachePrayerTimes(PrayerTimesModel prayerTimes);

  /// Clear all cached prayer times
  Future<void> clearCache();
}

/// Prayer Times Data Source Implementation
///
/// Integrates with Aladhan API for Islamic prayer times
/// Source: https://aladhan.com/prayer-times-api
class PrayerTimesDataSourceImpl implements PrayerTimesDataSource {
  final Dio httpClient;
  final Box<PrayerTimesModel> cacheBox;

  PrayerTimesDataSourceImpl({required this.httpClient, required this.cacheBox});

  @override
  Future<PrayerTimesModel> fetchPrayerTimes({
    required String city,
    required DateTime date,
  }) async {
    try {
      // Check cache first (minimize API calls)
      final cached = await getCachedPrayerTimes(city: city, date: date);
      if (cached != null) {
        return cached;
      }

      // Build Aladhan API URL
      // Format: https://api.aladhan.com/v1/timingsByCity/DD-MM-YYYY
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;

      final url =
          '${PlannerConstants.prayerTimesByCityEndpoint}/$day-$month-$year';

      // Make API request
      final response = await httpClient.get(
        url,
        queryParameters: {
          'city': city,
          'country': PlannerConstants.defaultCountry, // Algeria
          'method':
              PlannerConstants.prayerCalculationMethod, // Muslim World League
        },
      );

      // Validate response
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        // Check API status
        if (data['code'] != 200) {
          throw PrayerTimesException(
            message: 'Aladhan API error: ${data['status']}',
            data: data,
          );
        }

        // Parse response
        final prayerTimesModel = PrayerTimesModel.fromJson({
          ...data['data'],
          'city': city,
          'date': date.toIso8601String(),
        });

        // Cache for future use
        await cachePrayerTimes(prayerTimesModel);

        return prayerTimesModel;
      } else {
        throw PrayerTimesException(
          message: 'Invalid response from Aladhan API',
          data: response.data,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw TimeoutException(message: 'Prayer times API timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: 'No internet connection');
      } else {
        throw PrayerTimesException(message: 'Failed to fetch prayer times', data: e.message);
      }
    } catch (e) {
      throw PrayerTimesException(
        message: 'Unexpected error fetching prayer times',
        data: e.toString(),
      );
    }
  }

  @override
  Future<PrayerTimesModel?> getCachedPrayerTimes({
    required String city,
    required DateTime date,
  }) async {
    try {
      // Create cache key: "city_yyyy-mm-dd"
      final cacheKey = _getCacheKey(city, date);

      // Check if cached
      if (cacheBox.containsKey(cacheKey)) {
        final cached = cacheBox.get(cacheKey);

        // Validate cache age (30 days max)
        if (cached != null) {
          final cachedDate = DateTime.parse(cached.date);
          final cacheAge = DateTime.now().difference(cachedDate).inDays;

          if (cacheAge <= PlannerConstants.prayerTimesCacheDays) {
            return cached;
          } else {
            // Cache expired, remove it
            await cacheBox.delete(cacheKey);
          }
        }
      }

      return null;
    } catch (e) {
      // If cache read fails, return null (will fetch from API)
      // Silent failure - non-critical error
      return null;
    }
  }

  @override
  Future<void> cachePrayerTimes(PrayerTimesModel prayerTimes) async {
    try {
      final cacheKey = _getCacheKey(
        prayerTimes.city,
        DateTime.parse(prayerTimes.date),
      );
      await cacheBox.put(cacheKey, prayerTimes);
    } catch (e) {
      // Non-critical error - silent failure
      // Prayer times will be fetched from API next time
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await cacheBox.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear prayer times cache', data: e.toString());
    }
  }

  /// Generate cache key for prayer times
  String _getCacheKey(String city, DateTime date) {
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '${city.toLowerCase()}_$dateKey';
  }
}
