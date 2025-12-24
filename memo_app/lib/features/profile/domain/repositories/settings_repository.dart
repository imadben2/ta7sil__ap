import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/settings_entity.dart';

/// واجهة مستودع الإعدادات
///
/// جميع الإعدادات محلية فقط (Hive) - لا يتم مزامنتها مع API
///
/// تحدد العمليات المتاحة:
/// - جلب الإعدادات المحلية
/// - تحديث الإعدادات
/// - إعادة تعيين الإعدادات للافتراضية
abstract class SettingsRepository {
  /// جلب الإعدادات المحلية
  ///
  /// إذا لم تكن موجودة، يعيد الإعدادات الافتراضية
  ///
  /// Returns: [SettingsEntity] دائمًا (لا تفشل)
  Future<Either<Failure, SettingsEntity>> getSettings();

  /// تحديث الإعدادات
  ///
  /// Parameters:
  /// - [settings]: كيان الإعدادات الجديد
  ///
  /// Returns: [SettingsEntity] المحدث في حالة النجاح
  /// Returns: [Failure] في حالة الفشل
  Future<Either<Failure, SettingsEntity>> updateSettings(
    SettingsEntity settings,
  );

  /// تحديث إعدادات الإشعارات فقط
  ///
  /// Parameters:
  /// - [notifications]: إعدادات الإشعارات الجديدة
  ///
  /// Returns: [SettingsEntity] المحدث في حالة النجاح
  /// Returns: [Failure] في حالة الفشل
  Future<Either<Failure, SettingsEntity>> updateNotificationSettings(
    NotificationSettings notifications,
  );

  /// تحديث إعدادات أوقات الصلاة فقط
  ///
  /// Parameters:
  /// - [prayerTimes]: إعدادات أوقات الصلاة الجديدة
  ///
  /// Returns: [SettingsEntity] المحدث في حالة النجاح
  /// Returns: [Failure] في حالة الفشل
  Future<Either<Failure, SettingsEntity>> updatePrayerTimesSettings(
    PrayerTimesSettings prayerTimes,
  );

  /// تحديث اللغة
  ///
  /// Parameters:
  /// - [locale]: رمز اللغة ('ar', 'fr', 'en')
  ///
  /// Returns: [SettingsEntity] المحدث في حالة النجاح
  /// Returns: [Failure] في حالة الفشل
  Future<Either<Failure, SettingsEntity>> updateLocale(String locale);

  /// تحديث وضع الثيم
  ///
  /// Parameters:
  /// - [themeMode]: وضع الثيم ('system', 'light', 'dark')
  ///
  /// Returns: [SettingsEntity] المحدث في حالة النجاح
  /// Returns: [Failure] في حالة الفشل
  Future<Either<Failure, SettingsEntity>> updateThemeMode(String themeMode);

  /// تحديث الوضع غير متصل
  ///
  /// Parameters:
  /// - [offlineMode]: تفعيل/تعطيل
  ///
  /// Returns: [SettingsEntity] المحدث في حالة النجاح
  /// Returns: [Failure] في حالة الفشل
  Future<Either<Failure, SettingsEntity>> updateOfflineMode(bool offlineMode);

  /// مسح الذاكرة المؤقتة
  ///
  /// Returns: [void] في حالة النجاح
  /// Returns: [Failure] في حالة الفشل
  Future<Either<Failure, void>> clearCache();

  /// حساب حجم الذاكرة المؤقتة
  ///
  /// Returns: حجم الذاكرة المؤقتة بـ MB
  /// Returns: [Failure] في حالة الفشل
  Future<Either<Failure, int>> calculateCacheSize();

  /// إعادة تعيين الإعدادات للافتراضية
  ///
  /// Returns: [SettingsEntity] الافتراضي في حالة النجاح
  /// Returns: [Failure] في حالة الفشل
  Future<Either<Failure, SettingsEntity>> resetToDefaults();
}
