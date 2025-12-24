import 'package:hive/hive.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/settings_model.dart';

/// مصدر البيانات المحلي للإعدادات
///
/// جميع الإعدادات محلية فقط (لا يتم مزامنتها مع API)
abstract class SettingsLocalDataSource {
  /// جلب الإعدادات
  Future<SettingsModel> getSettings();

  /// حفظ الإعدادات
  Future<void> saveSettings(SettingsModel settings);

  /// حذف الإعدادات (إعادة تعيين)
  Future<void> deleteSettings();

  /// حساب حجم الذاكرة المؤقتة
  Future<int> calculateCacheSize();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  static const String _settingsBoxName = 'settings';
  static const String _settingsKey = 'user_settings';

  @override
  Future<SettingsModel> getSettings() async {
    try {
      final box = await Hive.openBox(_settingsBoxName);

      final settingsJson = box.get(_settingsKey);
      if (settingsJson == null) {
        // إعادة الإعدادات الافتراضية إذا لم تكن موجودة
        return SettingsModel.defaults();
      }

      return SettingsModel.fromJson(Map<String, dynamic>.from(settingsJson));
    } catch (e) {
      // في حالة الخطأ، نعيد الإعدادات الافتراضية
      return SettingsModel.defaults();
    }
  }

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    try {
      print('🎬 DataSource: Opening Hive box...');
      final box = await Hive.openBox(_settingsBoxName);
      print('🎬 DataSource: Converting settings to JSON...');
      final json = settings.toJson();
      print('🎬 DataSource: JSON = $json');
      print('🎬 DataSource: Saving to Hive...');
      await box.put(_settingsKey, json);
      print('🎬 DataSource: Saved successfully!');
    } catch (e, stackTrace) {
      print('❌ DataSource: Error saving settings: $e');
      print('❌ DataSource: Stack trace: $stackTrace');
      throw CacheException(message: 'فشل في حفظ الإعدادات: $e');
    }
  }

  @override
  Future<void> deleteSettings() async {
    try {
      final box = await Hive.openBox(_settingsBoxName);
      await box.delete(_settingsKey);
    } catch (e) {
      throw CacheException(message: 'فشل في حذف الإعدادات');
    }
  }

  @override
  Future<int> calculateCacheSize() async {
    try {
      // حساب حجم جميع صناديق Hive
      int totalSize = 0;

      // قائمة بأسماء الصناديق المستخدمة في التطبيق
      final boxNames = [
        'profile_cache',
        'statistics_cache',
        'settings',
        'auth_cache',
        'home_cache',
        'planner_cache',
        'bac_cache',
      ];

      for (final boxName in boxNames) {
        try {
          if (Hive.isBoxOpen(boxName)) {
            final box = Hive.box(boxName);
            // تقدير تقريبي: عدد المفاتيح * متوسط حجم القيمة (1 KB)
            totalSize += box.length * 1024;
          } else {
            final box = await Hive.openBox(boxName);
            totalSize += box.length * 1024;
            await box.close();
          }
        } catch (e) {
          // تجاهل الأخطاء للصناديق غير الموجودة
          continue;
        }
      }

      // تحويل إلى ميجابايت
      return (totalSize / (1024 * 1024)).round();
    } catch (e) {
      return 0;
    }
  }
}
