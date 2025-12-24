import 'package:hive/hive.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/bac_study_day_model.dart';
import '../models/bac_weekly_reward_model.dart';
import '../models/bac_user_stats_model.dart';

/// Local data source for BAC Study Schedule using Hive for caching
class BacStudyLocalDataSource {
  static const String _scheduleKey = 'full_schedule_';
  static const String _dayKey = 'day_';
  static const String _weekKey = 'week_';
  static const String _rewardsKey = 'rewards_';
  static const String _statsKey = 'stats_';
  static const String _progressKey = 'progress_';
  static const String _lastFetchKey = 'last_fetch_';

  // Cache duration - 1 hour for schedule, 24 hours for progress
  static const Duration scheduleCacheDuration = Duration(hours: 1);
  static const Duration progressCacheDuration = Duration(hours: 24);

  /// Get the Hive box
  Box _getBox() {
    return Hive.box(ApiConstants.hiveBoxBacStudy);
  }

  /// Check if cached data is still valid
  bool _isCacheValid(String key, Duration duration) {
    final box = _getBox();
    final lastFetch = box.get('$_lastFetchKey$key');
    if (lastFetch == null) return false;

    final lastFetchTime = DateTime.parse(lastFetch as String);
    return DateTime.now().difference(lastFetchTime) < duration;
  }

  /// Update last fetch time
  Future<void> _updateLastFetch(String key) async {
    final box = _getBox();
    await box.put('$_lastFetchKey$key', DateTime.now().toIso8601String());
  }

  // ============ Full Schedule ============

  /// Get cached full schedule
  Future<List<BacStudyDayModel>?> getCachedFullSchedule(int streamId) async {
    try {
      final key = '$_scheduleKey$streamId';
      if (!_isCacheValid(key, scheduleCacheDuration)) return null;

      final box = _getBox();
      final data = box.get(key);
      if (data == null) return null;

      // Handle type cast errors from corrupt cache
      if (data is! List) {
        await box.delete(key);
        return null;
      }

      final jsonList = (data as List).cast<Map<dynamic, dynamic>>();
      return jsonList
          .map((json) => BacStudyDayModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      // If there's any error, clear this cache entry and return null
      final key = '$_scheduleKey$streamId';
      final box = _getBox();
      await box.delete(key);
      return null;
    }
  }

  /// Cache full schedule
  Future<void> cacheFullSchedule(
    int streamId,
    List<BacStudyDayModel> days,
  ) async {
    final key = '$_scheduleKey$streamId';
    final box = _getBox();
    final jsonList = days.map((day) => day.toJson()).toList();
    await box.put(key, jsonList);
    await _updateLastFetch(key);
  }

  // ============ Day Schedule ============

  /// Get cached day schedule
  Future<BacStudyDayModel?> getCachedDaySchedule(
    int streamId,
    int dayNumber,
  ) async {
    try {
      final key = '$_dayKey${streamId}_$dayNumber';
      if (!_isCacheValid(key, scheduleCacheDuration)) return null;

      final box = _getBox();
      final data = box.get(key);
      if (data == null) return null;

      // Handle type cast errors from corrupt cache
      if (data is! Map) {
        await box.delete(key);
        return null;
      }

      return BacStudyDayModel.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      // If there's any error, clear this cache entry and return null
      final key = '$_dayKey${streamId}_$dayNumber';
      final box = _getBox();
      await box.delete(key);
      return null;
    }
  }

  /// Cache day schedule
  Future<void> cacheDaySchedule(
    int streamId,
    int dayNumber,
    BacStudyDayModel day,
  ) async {
    final key = '$_dayKey${streamId}_$dayNumber';
    final box = _getBox();
    await box.put(key, day.toJson());
    await _updateLastFetch(key);
  }

  // ============ Week Schedule ============

  /// Get cached week schedule
  Future<Map<String, dynamic>?> getCachedWeekSchedule(
    int streamId,
    int weekNumber,
  ) async {
    try {
      final key = '$_weekKey${streamId}_$weekNumber';
      if (!_isCacheValid(key, scheduleCacheDuration)) return null;

      final box = _getBox();
      final data = box.get(key);
      if (data == null) return null;

      // Handle type cast errors from corrupt cache
      if (data is! Map) {
        await box.delete(key);
        return null;
      }

      return Map<String, dynamic>.from(data as Map);
    } catch (e) {
      // If there's any error, clear this cache entry and return null
      final key = '$_weekKey${streamId}_$weekNumber';
      final box = _getBox();
      await box.delete(key);
      return null;
    }
  }

  /// Cache week schedule
  Future<void> cacheWeekSchedule(
    int streamId,
    int weekNumber,
    Map<String, dynamic> weekData,
  ) async {
    final key = '$_weekKey${streamId}_$weekNumber';
    final box = _getBox();
    await box.put(key, weekData);
    await _updateLastFetch(key);
  }

  // ============ Weekly Rewards ============

  /// Get cached weekly rewards
  Future<List<BacWeeklyRewardModel>?> getCachedWeeklyRewards(int streamId) async {
    try {
      final key = '$_rewardsKey$streamId';
      if (!_isCacheValid(key, progressCacheDuration)) return null;

      final box = _getBox();
      final data = box.get(key);
      if (data == null) return null;

      // Handle type cast errors from corrupt cache
      if (data is! List) {
        await box.delete(key);
        return null;
      }

      final jsonList = (data as List).cast<Map<dynamic, dynamic>>();
      return jsonList
          .map((json) =>
              BacWeeklyRewardModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      // If there's any error, clear this cache entry and return null
      final key = '$_rewardsKey$streamId';
      final box = _getBox();
      await box.delete(key);
      return null;
    }
  }

  /// Cache weekly rewards
  Future<void> cacheWeeklyRewards(
    int streamId,
    List<BacWeeklyRewardModel> rewards,
  ) async {
    final key = '$_rewardsKey$streamId';
    final box = _getBox();
    final jsonList = rewards.map((reward) => reward.toJson()).toList();
    await box.put(key, jsonList);
    await _updateLastFetch(key);
  }

  // ============ User Stats ============

  /// Get cached user stats
  Future<BacUserStatsModel?> getCachedUserStats(int streamId) async {
    try {
      final key = '$_statsKey$streamId';
      if (!_isCacheValid(key, progressCacheDuration)) return null;

      final box = _getBox();
      final data = box.get(key);
      if (data == null) return null;

      // Handle type cast errors from corrupt cache
      if (data is! Map) {
        await box.delete(key);
        return null;
      }

      return BacUserStatsModel.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      // If there's any error, clear this cache entry and return null
      final key = '$_statsKey$streamId';
      final box = _getBox();
      await box.delete(key);
      return null;
    }
  }

  /// Cache user stats
  Future<void> cacheUserStats(int streamId, BacUserStatsModel stats) async {
    final key = '$_statsKey$streamId';
    final box = _getBox();
    await box.put(key, stats.toJson());
    await _updateLastFetch(key);
  }

  // ============ Local Progress (Offline Support) ============

  /// Save topic completion state locally
  Future<void> saveTopicProgress(int topicId, bool isCompleted) async {
    final box = _getBox();
    final progressData = box.get(_progressKey) as Map? ?? {};
    progressData[topicId.toString()] = {
      'is_completed': isCompleted,
      'updated_at': DateTime.now().toIso8601String(),
    };
    await box.put(_progressKey, progressData);
  }

  /// Get local topic progress
  Map<int, bool> getLocalTopicProgress() {
    final box = _getBox();
    final progressData = box.get(_progressKey) as Map?;
    if (progressData == null) return {};

    final result = <int, bool>{};
    for (final entry in progressData.entries) {
      final topicId = int.tryParse(entry.key.toString());
      if (topicId != null) {
        final data = entry.value as Map;
        result[topicId] = data['is_completed'] as bool? ?? false;
      }
    }
    return result;
  }

  /// Clear synced progress
  Future<void> clearSyncedProgress(List<int> topicIds) async {
    final box = _getBox();
    final progressData = box.get(_progressKey) as Map? ?? {};
    for (final topicId in topicIds) {
      progressData.remove(topicId.toString());
    }
    await box.put(_progressKey, progressData);
  }

  // ============ Cache Management ============

  /// Clear all BAC Study Schedule cache
  Future<void> clearAllCache() async {
    final box = _getBox();
    await box.clear();
  }

  /// Clear schedule cache only (keeps progress)
  Future<void> clearScheduleCache() async {
    final box = _getBox();
    final keysToRemove = <String>[];

    for (final key in box.keys) {
      final keyStr = key.toString();
      if (keyStr.startsWith(_scheduleKey) ||
          keyStr.startsWith(_dayKey) ||
          keyStr.startsWith(_weekKey) ||
          keyStr.startsWith(_rewardsKey) ||
          keyStr.startsWith(_statsKey) ||
          keyStr.startsWith(_lastFetchKey)) {
        keysToRemove.add(keyStr);
      }
    }

    for (final key in keysToRemove) {
      await box.delete(key);
    }
  }

  /// Initialize Hive box
  static Future<void> initializeBox() async {
    if (!Hive.isBoxOpen(ApiConstants.hiveBoxBacStudy)) {
      await Hive.openBox(ApiConstants.hiveBoxBacStudy);
    }
  }

  /// Close Hive box
  static Future<void> closeBox() async {
    if (Hive.isBoxOpen(ApiConstants.hiveBoxBacStudy)) {
      await Hive.box(ApiConstants.hiveBoxBacStudy).close();
    }
  }
}
