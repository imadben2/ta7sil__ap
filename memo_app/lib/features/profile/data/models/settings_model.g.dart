// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsModel _$SettingsModelFromJson(Map<String, dynamic> json) =>
    SettingsModel(
      notifications: NotificationSettingsModel.fromJson(
          json['notifications'] as Map<String, dynamic>),
      prayerTimes: PrayerTimesSettingsModel.fromJson(
          json['prayer_times'] as Map<String, dynamic>),
      locale: json['locale'] as String,
      themeMode: json['theme_mode'] as String,
      offlineMode: json['offline_mode'] as bool,
      cacheSize: (json['cache_size'] as num).toInt(),
      preferredVideoPlayer:
          json['preferred_video_player'] as String? ?? 'chewie',
    );

Map<String, dynamic> _$SettingsModelToJson(SettingsModel instance) =>
    <String, dynamic>{
      'notifications': instance.notifications.toJson(),
      'prayer_times': instance.prayerTimes.toJson(),
      'locale': instance.locale,
      'theme_mode': instance.themeMode,
      'offline_mode': instance.offlineMode,
      'cache_size': instance.cacheSize,
      'preferred_video_player': instance.preferredVideoPlayer,
    };

NotificationSettingsModel _$NotificationSettingsModelFromJson(
        Map<String, dynamic> json) =>
    NotificationSettingsModel(
      enabled: json['enabled'] as bool,
      sessions: json['sessions'] as bool,
      quizzes: json['quizzes'] as bool,
      achievements: json['achievements'] as bool,
      prayerReminders: json['prayer_reminders'] as bool,
    );

Map<String, dynamic> _$NotificationSettingsModelToJson(
        NotificationSettingsModel instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'sessions': instance.sessions,
      'quizzes': instance.quizzes,
      'achievements': instance.achievements,
      'prayer_reminders': instance.prayerReminders,
    };

PrayerTimesSettingsModel _$PrayerTimesSettingsModelFromJson(
        Map<String, dynamic> json) =>
    PrayerTimesSettingsModel(
      enabled: json['enabled'] as bool,
      city: json['city'] as String,
      reminderMinutesBefore: (json['reminder_minutes_before'] as num).toInt(),
    );

Map<String, dynamic> _$PrayerTimesSettingsModelToJson(
        PrayerTimesSettingsModel instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'city': instance.city,
      'reminder_minutes_before': instance.reminderMinutesBefore,
    };
