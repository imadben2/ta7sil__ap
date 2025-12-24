import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/statistics_model.dart';

/// مصدر البيانات المحلي للإحصائيات
///
/// TTL: 15 دقيقة
abstract class StatisticsLocalDataSource {
  /// جلب الإحصائيات من Cache
  Future<StatisticsModel?> getCachedStatistics();

  /// حفظ الإحصائيات في Cache
  Future<void> cacheStatistics(StatisticsModel statistics);

  /// مسح Cache الإحصائيات
  Future<void> clearStatisticsCache();

  /// التحقق من صلاحية Cache
  Future<bool> isCacheValid();
}

class StatisticsLocalDataSourceImpl implements StatisticsLocalDataSource {
  static const String _statisticsBoxName = 'statistics_cache_v2'; // v2 for String storage
  static const String _statisticsKey = 'cached_statistics';
  static const String _timestampKey = 'cache_timestamp';
  static const int _cacheTTLMinutes = 15;

  /// Get or open the statistics cache box
  Future<Box<String>> _getBox() async {
    if (Hive.isBoxOpen(_statisticsBoxName)) {
      return Hive.box<String>(_statisticsBoxName);
    }
    return await Hive.openBox<String>(_statisticsBoxName);
  }

  @override
  Future<StatisticsModel?> getCachedStatistics() async {
    try {
      final box = await _getBox();

      if (!await isCacheValid()) {
        await clearStatisticsCache();
        return null;
      }

      final statisticsJsonString = box.get(_statisticsKey);
      if (statisticsJsonString == null) return null;

      final Map<String, dynamic> statisticsJson =
          jsonDecode(statisticsJsonString) as Map<String, dynamic>;

      return StatisticsModel.fromJson(statisticsJson);
    } catch (e) {
      debugPrint('[StatisticsLocalDataSource] getCachedStatistics error: $e');
      // Don't throw - return null to allow fresh fetch
      return null;
    }
  }

  @override
  Future<void> cacheStatistics(StatisticsModel statistics) async {
    try {
      final box = await _getBox();

      // Convert to JSON string for Hive storage
      final jsonString = jsonEncode(statistics.toJson());
      await box.put(_statisticsKey, jsonString);
      await box.put(_timestampKey, DateTime.now().millisecondsSinceEpoch.toString());
      debugPrint('[StatisticsLocalDataSource] Statistics cached successfully');
    } catch (e) {
      debugPrint('[StatisticsLocalDataSource] cacheStatistics error: $e');
      // Don't throw - caching failure should not break the app
      // The data was already fetched successfully from API
    }
  }

  @override
  Future<void> clearStatisticsCache() async {
    try {
      final box = await _getBox();
      await box.clear();
    } catch (e) {
      debugPrint('[StatisticsLocalDataSource] clearStatisticsCache error: $e');
      // Don't throw - clearing cache failure is not critical
    }
  }

  @override
  Future<bool> isCacheValid() async {
    try {
      final box = await _getBox();

      final timestampStr = box.get(_timestampKey);
      if (timestampStr == null) return false;

      final timestamp = int.tryParse(timestampStr);
      if (timestamp == null) return false;

      final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(cachedTime);

      return difference.inMinutes < _cacheTTLMinutes;
    } catch (e) {
      debugPrint('[StatisticsLocalDataSource] isCacheValid error: $e');
      return false;
    }
  }
}
