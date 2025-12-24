import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../datasources/settings_remote_datasource.dart';
import '../models/settings_model.dart';

/// تطبيق مستودع الإعدادات (مع مزامنة API)
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;
  final SettingsRemoteDataSource remoteDataSource;

  SettingsRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, SettingsEntity>> getSettings() async {
    try {
      print('🎬 Repository: Loading settings...');

      // Try to sync from API first
      try {
        print('🎬 Repository: Syncing from API...');
        final remoteSettings = await remoteDataSource.getSettings();

        // Save to local storage
        await localDataSource.saveSettings(remoteSettings);
        print('🎬 Repository: Synced from API and saved locally');

        return Right(remoteSettings.toEntity());
      } catch (e) {
        print('⚠️ Repository: API sync failed, loading from local: $e');

        // If API fails, load from local storage
        final settings = await localDataSource.getSettings();
        return Right(settings.toEntity());
      }
    } catch (e) {
      print('❌ Repository: All methods failed, returning defaults: $e');
      // في حالة الخطأ، نعيد الإعدادات الافتراضية
      return Right(SettingsEntity.defaults());
    }
  }

  @override
  Future<Either<Failure, SettingsEntity>> updateSettings(
    SettingsEntity settings,
  ) async {
    try {
      print('🎬 Repository: Saving settings with player: ${settings.preferredVideoPlayer}');
      final model = SettingsModel.fromEntity(settings);

      // Save locally first for offline support
      await localDataSource.saveSettings(model);
      print('🎬 Repository: Settings saved locally');

      // Try to sync with API
      try {
        await remoteDataSource.saveSettings(model);
        print('🎬 Repository: Settings synced to API');
      } catch (e) {
        // If API sync fails, still return success since local save worked
        print('⚠️ Repository: API sync failed but local save succeeded: $e');
      }

      return Right(settings);
    } on CacheException catch (e) {
      print('❌ Repository: Cache exception: ${e.message}');
      return Left(CacheFailure(e.message));
    } catch (e) {
      print('❌ Repository: Unknown error: $e');
      return Left(CacheFailure('حدث خطأ أثناء حفظ الإعدادات: $e'));
    }
  }

  @override
  Future<Either<Failure, SettingsEntity>> updateNotificationSettings(
    NotificationSettings notifications,
  ) async {
    try {
      // جلب الإعدادات الحالية
      final currentSettings = await localDataSource.getSettings();
      final currentEntity = currentSettings.toEntity();

      // تحديث إعدادات الإشعارات فقط
      final updatedEntity = currentEntity.copyWith(
        notifications: notifications,
      );

      // حفظ
      final model = SettingsModel.fromEntity(updatedEntity);
      await localDataSource.saveSettings(model);

      return Right(updatedEntity);
    } catch (e) {
      return Left(CacheFailure('حدث خطأ أثناء حفظ إعدادات الإشعارات'));
    }
  }

  @override
  Future<Either<Failure, SettingsEntity>> updatePrayerTimesSettings(
    PrayerTimesSettings prayerTimes,
  ) async {
    try {
      final currentSettings = await localDataSource.getSettings();
      final currentEntity = currentSettings.toEntity();

      final updatedEntity = currentEntity.copyWith(prayerTimes: prayerTimes);

      final model = SettingsModel.fromEntity(updatedEntity);
      await localDataSource.saveSettings(model);

      return Right(updatedEntity);
    } catch (e) {
      return Left(CacheFailure('حدث خطأ أثناء حفظ إعدادات أوقات الصلاة'));
    }
  }

  @override
  Future<Either<Failure, SettingsEntity>> updateLocale(String locale) async {
    try {
      final currentSettings = await localDataSource.getSettings();
      final currentEntity = currentSettings.toEntity();

      final updatedEntity = currentEntity.copyWith(locale: locale);

      final model = SettingsModel.fromEntity(updatedEntity);
      await localDataSource.saveSettings(model);

      return Right(updatedEntity);
    } catch (e) {
      return Left(CacheFailure('حدث خطأ أثناء تغيير اللغة'));
    }
  }

  @override
  Future<Either<Failure, SettingsEntity>> updateThemeMode(
    String themeMode,
  ) async {
    try {
      final currentSettings = await localDataSource.getSettings();
      final currentEntity = currentSettings.toEntity();

      final updatedEntity = currentEntity.copyWith(themeMode: themeMode);

      final model = SettingsModel.fromEntity(updatedEntity);
      await localDataSource.saveSettings(model);

      return Right(updatedEntity);
    } catch (e) {
      return Left(CacheFailure('حدث خطأ أثناء تغيير الثيم'));
    }
  }

  @override
  Future<Either<Failure, SettingsEntity>> updateOfflineMode(
    bool offlineMode,
  ) async {
    try {
      final currentSettings = await localDataSource.getSettings();
      final currentEntity = currentSettings.toEntity();

      final updatedEntity = currentEntity.copyWith(offlineMode: offlineMode);

      final model = SettingsModel.fromEntity(updatedEntity);
      await localDataSource.saveSettings(model);

      return Right(updatedEntity);
    } catch (e) {
      return Left(CacheFailure('حدث خطأ أثناء تحديث الوضع غير متصل'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      // هنا يمكن مسح جميع ذاكرة التطبيق المؤقتة
      // لكن الإعدادات نفسها تبقى
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('حدث خطأ أثناء مسح الذاكرة المؤقتة'));
    }
  }

  @override
  Future<Either<Failure, int>> calculateCacheSize() async {
    try {
      final size = await localDataSource.calculateCacheSize();
      return Right(size);
    } catch (e) {
      return const Right(0);
    }
  }

  @override
  Future<Either<Failure, SettingsEntity>> resetToDefaults() async {
    try {
      // حذف الإعدادات الحالية
      await localDataSource.deleteSettings();

      // إعادة الإعدادات الافتراضية
      final defaultSettings = SettingsModel.defaults();
      await localDataSource.saveSettings(defaultSettings);

      return Right(defaultSettings.toEntity());
    } catch (e) {
      return Left(CacheFailure('حدث خطأ أثناء إعادة تعيين الإعدادات'));
    }
  }
}
