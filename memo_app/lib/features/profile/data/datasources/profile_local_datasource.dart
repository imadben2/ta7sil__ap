import 'package:hive/hive.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/profile_model.dart';

/// مصدر البيانات المحلي للملف الشخصي
///
/// يتعامل مع التخزين المحلي (Cache) باستخدام Hive
/// TTL: 30 دقيقة
abstract class ProfileLocalDataSource {
  /// جلب الملف الشخصي من Cache
  Future<ProfileModel?> getCachedProfile();

  /// حفظ الملف الشخصي في Cache
  Future<void> cacheProfile(ProfileModel profile);

  /// مسح Cache الملف الشخصي
  Future<void> clearProfileCache();

  /// التحقق من صلاحية Cache
  Future<bool> isCacheValid();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  static const String _profileBoxName = 'profile_cache';
  static const String _profileKey = 'cached_profile';
  static const String _timestampKey = 'cache_timestamp';
  static const int _cacheTTLMinutes = 30;

  @override
  Future<ProfileModel?> getCachedProfile() async {
    try {
      final box = await Hive.openBox(_profileBoxName);

      // التحقق من صلاحية Cache
      if (!await isCacheValid()) {
        await clearProfileCache();
        return null;
      }

      final profileJson = box.get(_profileKey);
      if (profileJson == null) return null;

      return ProfileModel.fromJson(Map<String, dynamic>.from(profileJson));
    } catch (e) {
      throw CacheException(message: 'فشل في جلب الملف الشخصي من Cache');
    }
  }

  @override
  Future<void> cacheProfile(ProfileModel profile) async {
    try {
      final box = await Hive.openBox(_profileBoxName);

      await box.put(_profileKey, profile.toJson());
      await box.put(_timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      throw CacheException(message: 'فشل في حفظ الملف الشخصي في Cache');
    }
  }

  @override
  Future<void> clearProfileCache() async {
    try {
      final box = await Hive.openBox(_profileBoxName);
      await box.clear();
    } catch (e) {
      throw CacheException(message: 'فشل في مسح Cache الملف الشخصي');
    }
  }

  @override
  Future<bool> isCacheValid() async {
    try {
      final box = await Hive.openBox(_profileBoxName);

      final timestamp = box.get(_timestampKey);
      if (timestamp == null) return false;

      final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(cachedTime);

      return difference.inMinutes < _cacheTTLMinutes;
    } catch (e) {
      return false;
    }
  }
}
