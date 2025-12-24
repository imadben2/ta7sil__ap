import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// System Do Not Disturb Manager
///
/// Manages Android system-level Do Not Disturb (DND) mode through platform channels.
/// Provides methods to check permission status, request permission, get current DND state,
/// and enable/disable DND mode programmatically.
///
/// **Platform Support:**
/// - Android: Full support (API 23+)
/// - iOS: Limited support (can only check Focus mode status, cannot control)
///
/// **Usage:**
/// ```dart
/// final dndManager = SystemDndManager();
///
/// // Check permission
/// final hasPermission = await dndManager.hasDndPermission();
///
/// // Request permission (opens Settings)
/// if (!hasPermission) {
///   await dndManager.requestDndPermission();
/// }
///
/// // Enable DND
/// await dndManager.setDndMode(true);
///
/// // Disable DND
/// await dndManager.setDndMode(false);
/// ```
class SystemDndManager {
  static const MethodChannel _channel = MethodChannel('memo.app/dnd_manager');

  /// DND Interruption Filter States
  static const int interruptionFilterAll = 1; // Normal mode (all notifications)
  static const int interruptionFilterPriority = 2; // Priority only
  static const int interruptionFilterNone = 3; // Total silence
  static const int interruptionFilterAlarms = 4; // Alarms only
  static const int interruptionFilterUnknown = 0; // Unknown/error

  /// Check if app has DND permission
  ///
  /// Returns `true` if the app has notification policy access permission,
  /// `false` otherwise or on iOS.
  ///
  /// **Android:** Checks `isNotificationPolicyAccessGranted`
  /// **iOS:** Always returns `false` (programmatic DND control not supported)
  Future<bool> hasDndPermission() async {
    if (!Platform.isAndroid) {
      debugPrint('[SystemDndManager] iOS does not support programmatic DND control');
      return false;
    }

    try {
      final bool hasPermission =
          await _channel.invokeMethod('hasDndPermission');
      debugPrint(
          '[SystemDndManager] DND permission status: $hasPermission');
      return hasPermission;
    } on PlatformException catch (e) {
      debugPrint('[SystemDndManager] Error checking permission: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[SystemDndManager] Unexpected error checking permission: $e');
      return false;
    }
  }

  /// Request DND permission
  ///
  /// Opens the system notification policy access settings screen where
  /// the user can grant permission to the app.
  ///
  /// **Android:** Opens `Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS`
  /// **iOS:** No-op (shows debug message)
  ///
  /// **Note:** User must manually grant permission in Settings.
  Future<void> requestDndPermission() async {
    if (!Platform.isAndroid) {
      debugPrint(
          '[SystemDndManager] iOS does not support DND permission request');
      return;
    }

    try {
      await _channel.invokeMethod('requestDndPermission');
      debugPrint(
          '[SystemDndManager] DND permission request opened Settings');
    } on PlatformException catch (e) {
      debugPrint(
          '[SystemDndManager] Error requesting permission: ${e.message}');
    } catch (e) {
      debugPrint(
          '[SystemDndManager] Unexpected error requesting permission: $e');
    }
  }

  /// Get current DND state
  ///
  /// Returns the current interruption filter state:
  /// - `1` = INTERRUPTION_FILTER_ALL (normal mode, all notifications)
  /// - `2` = INTERRUPTION_FILTER_PRIORITY (priority only)
  /// - `3` = INTERRUPTION_FILTER_NONE (total silence)
  /// - `4` = INTERRUPTION_FILTER_ALARMS (alarms only)
  /// - `0` = INTERRUPTION_FILTER_UNKNOWN (unknown/error or iOS)
  ///
  /// **Android:** Returns current `NotificationManager.currentInterruptionFilter`
  /// **iOS:** Returns `INTERRUPTION_FILTER_UNKNOWN`
  Future<int> getCurrentDndState() async {
    if (!Platform.isAndroid) {
      return interruptionFilterUnknown;
    }

    try {
      final int state = await _channel.invokeMethod('getCurrentDndState');
      debugPrint('[SystemDndManager] Current DND state: ${_getStateName(state)}');
      return state;
    } on PlatformException catch (e) {
      debugPrint('[SystemDndManager] Error getting DND state: ${e.message}');
      return interruptionFilterUnknown;
    } catch (e) {
      debugPrint('[SystemDndManager] Unexpected error getting DND state: $e');
      return interruptionFilterUnknown;
    }
  }

  /// Enable or disable DND mode
  ///
  /// @param enable `true` to enable DND (alarms only), `false` to disable (normal mode)
  /// @return `true` if operation succeeded, `false` otherwise or on iOS
  ///
  /// **Android:**
  /// - When `enable = true`: Sets to INTERRUPTION_FILTER_ALARMS (total silence except alarms)
  /// - When `enable = false`: Sets to INTERRUPTION_FILTER_ALL (normal mode)
  /// - Requires DND permission granted
  ///
  /// **iOS:** Always returns `false` (not supported)
  Future<bool> setDndMode(bool enable) async {
    if (!Platform.isAndroid) {
      debugPrint('[SystemDndManager] iOS does not support programmatic DND control');
      return false;
    }

    try {
      final bool success = await _channel.invokeMethod('setDndMode', {
        'enable': enable,
      });

      if (success) {
        debugPrint(
            '[SystemDndManager] DND mode ${enable ? "enabled" : "disabled"} successfully');
      } else {
        debugPrint(
            '[SystemDndManager] Failed to ${enable ? "enable" : "disable"} DND mode (permission not granted?)');
      }

      return success;
    } on PlatformException catch (e) {
      debugPrint('[SystemDndManager] Error setting DND mode: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[SystemDndManager] Unexpected error setting DND mode: $e');
      return false;
    }
  }

  /// Check if DND is currently active
  ///
  /// Returns `true` if current state is anything other than INTERRUPTION_FILTER_ALL,
  /// meaning some form of DND/silence is active.
  Future<bool> isDndActive() async {
    final state = await getCurrentDndState();
    return state != interruptionFilterAll && state != interruptionFilterUnknown;
  }

  /// Get human-readable state name
  String _getStateName(int state) {
    switch (state) {
      case interruptionFilterAll:
        return 'ALL (Normal)';
      case interruptionFilterPriority:
        return 'PRIORITY';
      case interruptionFilterNone:
        return 'NONE (Total Silence)';
      case interruptionFilterAlarms:
        return 'ALARMS ONLY';
      case interruptionFilterUnknown:
      default:
        return 'UNKNOWN';
    }
  }

  /// Get human-readable state name in Arabic
  String getStateNameAr(int state) {
    switch (state) {
      case interruptionFilterAll:
        return 'عادي';
      case interruptionFilterPriority:
        return 'الأولوية فقط';
      case interruptionFilterNone:
        return 'صامت تماماً';
      case interruptionFilterAlarms:
        return 'المنبهات فقط';
      case interruptionFilterUnknown:
      default:
        return 'غير معروف';
    }
  }
}
