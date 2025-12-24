import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/settings_entity.dart';
import '../../../domain/usecases/get_settings_usecase.dart';
import '../../../domain/usecases/update_settings_usecase.dart';
import 'settings_state.dart';

/// Cubit الإعدادات
class SettingsCubit extends Cubit<SettingsState> {
  final GetSettingsUseCase getSettingsUseCase;
  final UpdateSettingsUseCase updateSettingsUseCase;

  SettingsCubit({
    required this.getSettingsUseCase,
    required this.updateSettingsUseCase,
  }) : super(const SettingsInitial());

  /// Helper to get current settings from any "loaded" state
  SettingsEntity? _getCurrentSettings() {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      return currentState.settings;
    } else if (currentState is SettingsSaved) {
      return currentState.settings;
    } else if (currentState is SettingsSaving) {
      return currentState.settings;
    } else if (currentState is SettingsError && currentState.currentSettings != null) {
      return currentState.currentSettings;
    }
    return null;
  }

  /// تحميل الإعدادات
  Future<void> loadSettings() async {
    emit(const SettingsLoading());

    final result = await getSettingsUseCase();

    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (settings) => emit(SettingsLoaded(settings)),
    );
  }

  /// تحديث الإعدادات
  Future<void> updateSettings(SettingsEntity settings) async {
    final currentSettings = _getCurrentSettings();
    if (currentSettings == null) {
      print('❌ Cannot update settings: no current settings available');
      return;
    }

    emit(SettingsSaving(settings));

    final result = await updateSettingsUseCase(settings);

    result.fold(
      (failure) => emit(SettingsError(failure.message, currentSettings)),
      (updatedSettings) => emit(SettingsSaved(updatedSettings)),
    );
  }

  /// تحديث إعدادات الإشعارات
  Future<void> updateNotifications(NotificationSettings notifications) async {
    final currentSettings = _getCurrentSettings();
    if (currentSettings == null) return;

    final updatedSettings = currentSettings.copyWith(
      notifications: notifications,
    );

    await updateSettings(updatedSettings);
  }

  /// تحديث إعدادات أوقات الصلاة
  Future<void> updatePrayerTimes(PrayerTimesSettings prayerTimes) async {
    final currentSettings = _getCurrentSettings();
    if (currentSettings == null) return;

    final updatedSettings = currentSettings.copyWith(
      prayerTimes: prayerTimes,
    );

    await updateSettings(updatedSettings);
  }

  /// تغيير اللغة
  Future<void> changeLocale(String locale) async {
    final currentSettings = _getCurrentSettings();
    if (currentSettings == null) return;

    final updatedSettings = currentSettings.copyWith(locale: locale);

    await updateSettings(updatedSettings);
  }

  /// تغيير الثيم
  Future<void> changeTheme(String themeMode) async {
    final currentSettings = _getCurrentSettings();
    if (currentSettings == null) return;

    final updatedSettings = currentSettings.copyWith(
      themeMode: themeMode,
    );

    await updateSettings(updatedSettings);
  }

  /// تغيير الوضع غير متصل
  Future<void> toggleOfflineMode(bool offlineMode) async {
    final currentSettings = _getCurrentSettings();
    if (currentSettings == null) return;

    final updatedSettings = currentSettings.copyWith(
      offlineMode: offlineMode,
    );

    await updateSettings(updatedSettings);
  }

  /// تغيير مشغل الفيديو المفضل
  Future<void> changeVideoPlayer(String playerType) async {
    final currentSettings = _getCurrentSettings();
    if (currentSettings == null) {
      print('❌ Cannot change video player: no current settings available');
      return;
    }

    print('🎬 Changing video player to: $playerType');

    final updatedSettings = currentSettings.copyWith(
      preferredVideoPlayer: playerType,
    );

    await updateSettings(updatedSettings);

    print('🎬 Video player changed successfully');
  }

  /// إعادة تعيين للافتراضي
  Future<void> resetToDefaults() async {
    emit(const SettingsLoading());

    final defaultSettings = SettingsEntity.defaults();

    final result = await updateSettingsUseCase(defaultSettings);

    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (settings) => emit(SettingsSaved(settings)),
    );
  }
}
