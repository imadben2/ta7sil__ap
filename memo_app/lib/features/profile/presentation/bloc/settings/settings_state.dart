import 'package:equatable/equatable.dart';
import '../../../domain/entities/settings_entity.dart';

/// حالات الإعدادات
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

/// جاري التحميل
class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

/// تم التحميل بنجاح
class SettingsLoaded extends SettingsState {
  final SettingsEntity settings;

  const SettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// جاري الحفظ
class SettingsSaving extends SettingsState {
  final SettingsEntity settings;

  const SettingsSaving(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// تم الحفظ بنجاح
class SettingsSaved extends SettingsState {
  final SettingsEntity settings;

  const SettingsSaved(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// خطأ
class SettingsError extends SettingsState {
  final String message;
  final SettingsEntity? currentSettings;

  const SettingsError(this.message, [this.currentSettings]);

  @override
  List<Object?> get props => [message, currentSettings];
}
