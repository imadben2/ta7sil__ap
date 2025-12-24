import 'package:dio/dio.dart';
import '../../domain/entities/prayer_times.dart';
import '../models/prayer_times_model.dart';

/// Prayer Times Service
///
/// Fetches Islamic prayer times from Aladhan API
/// https://aladhan.com/prayer-times-api
class PrayerTimesService {
  final Dio dio;
  static const String baseUrl = 'https://api.aladhan.com/v1';

  PrayerTimesService(this.dio);

  /// Get prayer times for a specific city and date
  ///
  /// Returns PrayerTimes entity
  /// Throws DioException on network errors
  Future<PrayerTimes> getPrayerTimes({
    required String city,
    required String country,
    required DateTime date,
  }) async {
    try {
      // Format date as DD-MM-YYYY
      final formattedDate =
          '${date.day.toString().padLeft(2, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.year}';

      final response = await dio.get(
        '$baseUrl/timingsByCity/$formattedDate',
        queryParameters: {
          'city': city,
          'country': country,
          'method': 4, // Umm Al-Qura University, Makkah (used in Algeria)
        },
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        final data = response.data['data'];
        final model = PrayerTimesModel.fromAladhanJson(data);
        return model.toEntity();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch prayer times',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '$baseUrl/timingsByCity'),
        error: e.toString(),
      );
    }
  }

  /// Get prayer times for Algiers (default for Algerian students)
  Future<PrayerTimes> getPrayerTimesForAlgiers({required DateTime date}) async {
    return getPrayerTimes(city: 'Algiers', country: 'Algeria', date: date);
  }

  /// Get prayer times for the current month
  ///
  /// Returns a list of PrayerTimes for all days in the current month
  Future<List<PrayerTimes>> getMonthlyPrayerTimes({
    required String city,
    required String country,
    required int year,
    required int month,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/calendarByCity/$year/$month',
        queryParameters: {
          'city': city,
          'country': country,
          'method': 4, // Umm Al-Qura University, Makkah
        },
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        final dataList = response.data['data'] as List;
        final prayerTimesList = <PrayerTimes>[];

        for (final data in dataList) {
          final model = PrayerTimesModel.fromAladhanJson(data);
          prayerTimesList.add(model.toEntity());
        }

        return prayerTimesList;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch monthly prayer times',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '$baseUrl/calendarByCity'),
        error: e.toString(),
      );
    }
  }

  /// Get prayer times for Algiers for the current month
  Future<List<PrayerTimes>> getMonthlyPrayerTimesForAlgiers() async {
    final now = DateTime.now();
    return getMonthlyPrayerTimes(
      city: 'Algiers',
      country: 'Algeria',
      year: now.year,
      month: now.month,
    );
  }

  /// Check if prayer times need to be refreshed
  ///
  /// Returns true if cached prayer times are for a past date
  bool needsRefresh(PrayerTimes? cachedPrayerTimes) {
    if (cachedPrayerTimes == null) return true;

    final today = DateTime.now();
    final cachedDate = cachedPrayerTimes.date;

    // Refresh if cached date is not today
    return cachedDate.year != today.year ||
        cachedDate.month != today.month ||
        cachedDate.day != today.day;
  }
}
