import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Notification Priority Level
///
/// Used to filter which notifications should bypass focus mode.
enum NotificationPriority {
  /// Low priority (can be suppressed during focus)
  low,

  /// Normal priority (can be suppressed during focus)
  normal,

  /// High priority (may bypass focus depending on settings)
  high,

  /// Critical priority (always bypass focus)
  critical,
}

/// Focus Mode Settings
///
/// Configuration for how focus mode should behave.
/// Controls DND automation, notification suppression, quiet hours,
/// and integration with study sessions.
class FocusModeSettings extends Equatable {
  // ========== Behavior Settings ==========

  /// Auto-enable system DND when focus mode starts (Android only)
  final bool autoEnableSystemDnd;

  /// Suppress memo app's own notifications during focus mode
  final bool suppressOwnNotifications;

  /// Allow critical alerts to bypass focus mode (exams, emergencies)
  final bool allowCriticalAlerts;

  /// Allow prayer time notifications to bypass focus mode
  final bool allowPrayerReminders;

  // ========== Quiet Hours Scheduling ==========

  /// Enable quiet hours feature (auto-enable focus at specific times)
  final bool enableQuietHours;

  /// Quiet hours start time (e.g., 22:00 for 10 PM)
  final TimeOfDay quietHoursStart;

  /// Quiet hours end time (e.g., 08:00 for 8 AM)
  final TimeOfDay quietHoursEnd;

  /// Days of week when quiet hours are active (1=Monday, 7=Sunday)
  final List<int> quietHoursDays;

  // ========== Planner Integration ==========

  /// Auto-enable focus mode when user starts a study session
  final bool autoEnableDuringStudySessions;

  /// Show notification when focus mode activates
  final bool notifyWhenFocusModeStarts;

  /// Show floating focus indicator in app during active session
  final bool showFloatingIndicator;

  // ========== Priority Filter ==========

  /// Minimum priority level for notifications to show during focus
  /// (Only notifications >= this priority will be shown)
  final NotificationPriority minimumPriority;

  // ========== Achievement Notifications ==========

  /// Allow achievement notifications during focus mode
  final bool allowAchievementNotifications;

  const FocusModeSettings({
    this.autoEnableSystemDnd = true,
    this.suppressOwnNotifications = true,
    this.allowCriticalAlerts = true,
    this.allowPrayerReminders = true,
    this.enableQuietHours = false,
    this.quietHoursStart = const TimeOfDay(hour: 22, minute: 0),
    this.quietHoursEnd = const TimeOfDay(hour: 8, minute: 0),
    this.quietHoursDays = const [1, 2, 3, 4, 5, 6, 7], // All days
    this.autoEnableDuringStudySessions = true,
    this.notifyWhenFocusModeStarts = false,
    this.showFloatingIndicator = true,
    this.minimumPriority = NotificationPriority.critical,
    this.allowAchievementNotifications = false,
  });

  /// Default settings
  factory FocusModeSettings.defaults() {
    return const FocusModeSettings();
  }

  /// Check if current time is within quiet hours
  bool isWithinQuietHours() {
    if (!enableQuietHours) return false;

    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes =
        quietHoursStart.hour * 60 + quietHoursStart.minute;
    final endMinutes = quietHoursEnd.hour * 60 + quietHoursEnd.minute;

    final currentDay = DateTime.now().weekday; // 1=Monday, 7=Sunday

    // Check if today is in quietHoursDays
    if (!quietHoursDays.contains(currentDay)) {
      return false;
    }

    // Handle quiet hours that span midnight
    if (startMinutes > endMinutes) {
      // e.g., 22:00 to 08:00 (next day)
      return nowMinutes >= startMinutes || nowMinutes < endMinutes;
    } else {
      // e.g., 08:00 to 22:00 (same day)
      return nowMinutes >= startMinutes && nowMinutes < endMinutes;
    }
  }

  /// Get formatted quiet hours time range
  String get quietHoursFormatted {
    return '${_formatTimeOfDay(quietHoursStart)} - ${_formatTimeOfDay(quietHoursEnd)}';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Copy with
  FocusModeSettings copyWith({
    bool? autoEnableSystemDnd,
    bool? suppressOwnNotifications,
    bool? allowCriticalAlerts,
    bool? allowPrayerReminders,
    bool? enableQuietHours,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
    List<int>? quietHoursDays,
    bool? autoEnableDuringStudySessions,
    bool? notifyWhenFocusModeStarts,
    bool? showFloatingIndicator,
    NotificationPriority? minimumPriority,
    bool? allowAchievementNotifications,
  }) {
    return FocusModeSettings(
      autoEnableSystemDnd: autoEnableSystemDnd ?? this.autoEnableSystemDnd,
      suppressOwnNotifications:
          suppressOwnNotifications ?? this.suppressOwnNotifications,
      allowCriticalAlerts: allowCriticalAlerts ?? this.allowCriticalAlerts,
      allowPrayerReminders: allowPrayerReminders ?? this.allowPrayerReminders,
      enableQuietHours: enableQuietHours ?? this.enableQuietHours,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      quietHoursDays: quietHoursDays ?? this.quietHoursDays,
      autoEnableDuringStudySessions:
          autoEnableDuringStudySessions ?? this.autoEnableDuringStudySessions,
      notifyWhenFocusModeStarts:
          notifyWhenFocusModeStarts ?? this.notifyWhenFocusModeStarts,
      showFloatingIndicator:
          showFloatingIndicator ?? this.showFloatingIndicator,
      minimumPriority: minimumPriority ?? this.minimumPriority,
      allowAchievementNotifications:
          allowAchievementNotifications ?? this.allowAchievementNotifications,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'autoEnableSystemDnd': autoEnableSystemDnd,
      'suppressOwnNotifications': suppressOwnNotifications,
      'allowCriticalAlerts': allowCriticalAlerts,
      'allowPrayerReminders': allowPrayerReminders,
      'enableQuietHours': enableQuietHours,
      'quietHoursStart': {
        'hour': quietHoursStart.hour,
        'minute': quietHoursStart.minute,
      },
      'quietHoursEnd': {
        'hour': quietHoursEnd.hour,
        'minute': quietHoursEnd.minute,
      },
      'quietHoursDays': quietHoursDays,
      'autoEnableDuringStudySessions': autoEnableDuringStudySessions,
      'notifyWhenFocusModeStarts': notifyWhenFocusModeStarts,
      'showFloatingIndicator': showFloatingIndicator,
      'minimumPriority': minimumPriority.index,
      'allowAchievementNotifications': allowAchievementNotifications,
    };
  }

  /// Create from JSON
  factory FocusModeSettings.fromJson(Map<String, dynamic> json) {
    return FocusModeSettings(
      autoEnableSystemDnd: json['autoEnableSystemDnd'] ?? true,
      suppressOwnNotifications: json['suppressOwnNotifications'] ?? true,
      allowCriticalAlerts: json['allowCriticalAlerts'] ?? true,
      allowPrayerReminders: json['allowPrayerReminders'] ?? true,
      enableQuietHours: json['enableQuietHours'] ?? false,
      quietHoursStart: json['quietHoursStart'] != null
          ? TimeOfDay(
              hour: json['quietHoursStart']['hour'] ?? 22,
              minute: json['quietHoursStart']['minute'] ?? 0,
            )
          : const TimeOfDay(hour: 22, minute: 0),
      quietHoursEnd: json['quietHoursEnd'] != null
          ? TimeOfDay(
              hour: json['quietHoursEnd']['hour'] ?? 8,
              minute: json['quietHoursEnd']['minute'] ?? 0,
            )
          : const TimeOfDay(hour: 8, minute: 0),
      quietHoursDays: json['quietHoursDays'] != null
          ? List<int>.from(json['quietHoursDays'])
          : const [1, 2, 3, 4, 5, 6, 7],
      autoEnableDuringStudySessions:
          json['autoEnableDuringStudySessions'] ?? true,
      notifyWhenFocusModeStarts: json['notifyWhenFocusModeStarts'] ?? false,
      showFloatingIndicator: json['showFloatingIndicator'] ?? true,
      minimumPriority: json['minimumPriority'] != null
          ? NotificationPriority.values[json['minimumPriority']]
          : NotificationPriority.critical,
      allowAchievementNotifications:
          json['allowAchievementNotifications'] ?? false,
    );
  }

  @override
  List<Object?> get props => [
        autoEnableSystemDnd,
        suppressOwnNotifications,
        allowCriticalAlerts,
        allowPrayerReminders,
        enableQuietHours,
        quietHoursStart,
        quietHoursEnd,
        quietHoursDays,
        autoEnableDuringStudySessions,
        notifyWhenFocusModeStarts,
        showFloatingIndicator,
        minimumPriority,
        allowAchievementNotifications,
      ];
}
