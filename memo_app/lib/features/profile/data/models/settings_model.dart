import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/settings_entity.dart';

part 'settings_model.g.dart';

/// نموذج الإعدادات (محلي فقط - Hive)
@JsonSerializable(explicitToJson: true)
class SettingsModel {
  final NotificationSettingsModel notifications;
  @JsonKey(name: 'prayer_times')
  final PrayerTimesSettingsModel prayerTimes;
  final String locale;
  @JsonKey(name: 'theme_mode')
  final String themeMode;
  @JsonKey(name: 'offline_mode')
  final bool offlineMode;
  @JsonKey(name: 'cache_size')
  final int cacheSize;
  @JsonKey(name: 'preferred_video_player', defaultValue: 'chewie')
  final String preferredVideoPlayer;

  SettingsModel({
    required this.notifications,
    required this.prayerTimes,
    required this.locale,
    required this.themeMode,
    required this.offlineMode,
    required this.cacheSize,
    required this.preferredVideoPlayer,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SettingsModelFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsModelToJson(this);

  /// Convert to flat structure for API
  /// API expects: theme, language, preferred_video_player (flat, not nested)
  Map<String, dynamic> toApiJson() {
    return {
      'theme': themeMode,
      'language': locale,
      'preferred_video_player': preferredVideoPlayer,
    };
  }

  SettingsEntity toEntity() {
    return SettingsEntity(
      notifications: notifications.toEntity(),
      prayerTimes: prayerTimes.toEntity(),
      locale: locale,
      themeMode: themeMode,
      offlineMode: offlineMode,
      cacheSize: cacheSize,
      preferredVideoPlayer: preferredVideoPlayer,
    );
  }

  factory SettingsModel.fromEntity(SettingsEntity entity) {
    return SettingsModel(
      notifications: NotificationSettingsModel.fromEntity(entity.notifications),
      prayerTimes: PrayerTimesSettingsModel.fromEntity(entity.prayerTimes),
      locale: entity.locale,
      themeMode: entity.themeMode,
      offlineMode: entity.offlineMode,
      cacheSize: entity.cacheSize,
      preferredVideoPlayer: entity.preferredVideoPlayer,
    );
  }

  factory SettingsModel.defaults() {
    return SettingsModel(
      notifications: NotificationSettingsModel(
        enabled: true,
        sessions: true,
        quizzes: true,
        achievements: true,
        prayerReminders: true,
      ),
      prayerTimes: PrayerTimesSettingsModel(
        enabled: true,
        city: 'Algiers',
        reminderMinutesBefore: 10,
      ),
      locale: 'ar',
      themeMode: 'system',
      offlineMode: false,
      cacheSize: 0,
      preferredVideoPlayer: 'chewie',
    );
  }
}

@JsonSerializable()
class NotificationSettingsModel {
  final bool enabled;
  final bool sessions;
  final bool quizzes;
  final bool achievements;
  @JsonKey(name: 'prayer_reminders')
  final bool prayerReminders;

  NotificationSettingsModel({
    required this.enabled,
    required this.sessions,
    required this.quizzes,
    required this.achievements,
    required this.prayerReminders,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationSettingsModelToJson(this);

  NotificationSettings toEntity() {
    return NotificationSettings(
      enabled: enabled,
      sessions: sessions,
      quizzes: quizzes,
      achievements: achievements,
      prayerReminders: prayerReminders,
    );
  }

  factory NotificationSettingsModel.fromEntity(NotificationSettings entity) {
    return NotificationSettingsModel(
      enabled: entity.enabled,
      sessions: entity.sessions,
      quizzes: entity.quizzes,
      achievements: entity.achievements,
      prayerReminders: entity.prayerReminders,
    );
  }
}

@JsonSerializable()
class PrayerTimesSettingsModel {
  final bool enabled;
  final String city;
  @JsonKey(name: 'reminder_minutes_before')
  final int reminderMinutesBefore;

  PrayerTimesSettingsModel({
    required this.enabled,
    required this.city,
    required this.reminderMinutesBefore,
  });

  factory PrayerTimesSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$PrayerTimesSettingsModelFromJson(json);

  Map<String, dynamic> toJson() => _$PrayerTimesSettingsModelToJson(this);

  PrayerTimesSettings toEntity() {
    return PrayerTimesSettings(
      enabled: enabled,
      city: city,
      reminderMinutesBefore: reminderMinutesBefore,
    );
  }

  factory PrayerTimesSettingsModel.fromEntity(PrayerTimesSettings entity) {
    return PrayerTimesSettingsModel(
      enabled: entity.enabled,
      city: entity.city,
      reminderMinutesBefore: entity.reminderMinutesBefore,
    );
  }
}
