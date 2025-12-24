import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/prayer_times.dart';

/// Prayer Times Repository Interface
///
/// Abstract interface for fetching Islamic prayer times
/// Integrates with Aladhan API for Algerian prayer times
abstract class PrayerTimesRepository {
  /// Get prayer times for a specific city and date
  ///
  /// Uses Aladhan API with Muslim World League calculation method
  /// Caches results for 30 days to minimize API calls
  ///
  /// Parameters:
  /// - [city]: Algerian city (e.g., "Algiers", "Oran", "Constantine")
  /// - [date]: Date to fetch prayer times for
  ///
  /// Returns:
  /// - Right: PrayerTimes entity with all 5 prayer times
  /// - Left: PrayerTimesFailure if API fails or no cached data
  Future<Either<Failure, PrayerTimes>> getPrayerTimes({
    required String city,
    required DateTime date,
  });

  /// Get prayer times for multiple days (batch fetch)
  ///
  /// Useful for schedule generation (7-30 days ahead)
  ///
  /// Parameters:
  /// - [city]: Algerian city
  /// - [startDate]: First date to fetch
  /// - [days]: Number of days to fetch (default: 7)
  ///
  /// Returns:
  /// - Right: Map of date -> PrayerTimes
  /// - Left: PrayerTimesFailure
  Future<Either<Failure, Map<DateTime, PrayerTimes>>> getPrayerTimesRange({
    required String city,
    required DateTime startDate,
    int days = 7,
  });

  /// Get cached prayer times (offline fallback)
  ///
  /// Returns cached prayer times if available, null otherwise
  /// Does not make API call
  Future<Either<Failure, PrayerTimes?>> getCachedPrayerTimes({
    required String city,
    required DateTime date,
  });

  /// Clear prayer times cache
  ///
  /// Useful when user changes city or for manual refresh
  Future<Either<Failure, Unit>> clearCache();
}
