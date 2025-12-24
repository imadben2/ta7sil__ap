import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:memo_app/core/storage/hive_service.dart';
import 'package:memo_app/core/services/system_dnd_manager.dart';
import 'package:memo_app/features/focus_mode/domain/entities/focus_mode_settings.dart';
import 'package:memo_app/features/focus_mode/domain/entities/focus_session_entity.dart';
import 'package:uuid/uuid.dart';

/// Focus Mode Service
///
/// Singleton service that manages focus mode sessions and coordinates
/// with system DND and notification suppression.
///
/// **Responsibilities:**
/// - Track active focus sessions
/// - Enable/disable system DND (Android)
/// - Suppress/restore app notifications
/// - Manage focus mode settings
/// - Emit focus state changes via stream
///
/// **Usage:**
/// ```dart
/// final focusService = FocusModeService();
/// await focusService.init();
///
/// // Start focus mode
/// await focusService.startFocusMode(
///   type: FocusModeType.studySession,
///   duration: Duration(minutes: 45),
/// );
///
/// // Listen to session changes
/// focusService.onSessionChanged.listen((session) {
///   print('Focus mode ${session != null ? "active" : "inactive"}');
/// });
///
/// // End focus mode
/// await focusService.endFocusMode();
/// ```
class FocusModeService {
  static final FocusModeService _instance = FocusModeService._internal();
  factory FocusModeService() => _instance;
  FocusModeService._internal();

  // Dependencies
  final SystemDndManager _dndManager = SystemDndManager();
  late Box _settingsBox;
  late Box _sessionBox;

  // State
  FocusSessionEntity? _activeSession;
  FocusModeSettings? _settings;
  int? _previousDndState;

  // Timer for quiet hours check
  Timer? _quietHoursTimer;

  // Stream controllers
  final StreamController<FocusSessionEntity?> _sessionController =
      StreamController<FocusSessionEntity?>.broadcast();

  final StreamController<FocusModeSettings> _settingsController =
      StreamController<FocusModeSettings>.broadcast();

  // Storage keys
  static const String _settingsBoxName = 'focus_mode_settings';
  static const String _sessionBoxName = 'focus_mode_sessions';
  static const String _settingsKey = 'current_settings';
  static const String _activeSessionKey = 'active_session';

  // Getters
  Stream<FocusSessionEntity?> get onSessionChanged => _sessionController.stream;
  Stream<FocusModeSettings> get onSettingsChanged => _settingsController.stream;
  bool get isFocusModeActive => _activeSession != null;
  FocusSessionEntity? get activeSession => _activeSession;
  FocusModeSettings get settings =>
      _settings ?? FocusModeSettings.defaults();

  /// Initialize the service
  Future<void> init() async {
    try {
      debugPrint('[FocusModeService] Initializing...');

      // Open Hive boxes
      _settingsBox = await Hive.openBox(_settingsBoxName);
      _sessionBox = await Hive.openBox(_sessionBoxName);

      // Load settings
      await _loadSettings();

      // Check for active session
      await _checkActiveSession();

      // Check quiet hours
      _scheduleQuietHoursCheck();

      debugPrint('[FocusModeService] Initialized successfully');
    } catch (e) {
      debugPrint('[FocusModeService] Initialization error: $e');
    }
  }

  /// Load settings from storage
  Future<void> _loadSettings() async {
    try {
      final settingsJson = _settingsBox.get(_settingsKey);

      if (settingsJson != null) {
        _settings = FocusModeSettings.fromJson(
          Map<String, dynamic>.from(jsonDecode(settingsJson)),
        );
        debugPrint('[FocusModeService] Settings loaded');
      } else {
        _settings = FocusModeSettings.defaults();
        await _saveSettings();
        debugPrint('[FocusModeService] Default settings created');
      }

      _settingsController.add(_settings!);
    } catch (e) {
      debugPrint('[FocusModeService] Error loading settings: $e');
      _settings = FocusModeSettings.defaults();
    }
  }

  /// Save settings to storage
  Future<void> _saveSettings() async {
    try {
      if (_settings != null) {
        await _settingsBox.put(_settingsKey, jsonEncode(_settings!.toJson()));
        _settingsController.add(_settings!);
        debugPrint('[FocusModeService] Settings saved');
      }
    } catch (e) {
      debugPrint('[FocusModeService] Error saving settings: $e');
    }
  }

  /// Update settings
  Future<void> updateSettings(FocusModeSettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
  }

  /// Check for active session on startup
  Future<void> _checkActiveSession() async {
    try {
      final sessionJson = _sessionBox.get(_activeSessionKey);

      if (sessionJson != null) {
        final sessionData = Map<String, dynamic>.from(jsonDecode(sessionJson));

        _activeSession = FocusSessionEntity(
          id: sessionData['id'],
          startTime: DateTime.parse(sessionData['startTime']),
          endTime: sessionData['endTime'] != null
              ? DateTime.parse(sessionData['endTime'])
              : null,
          type: FocusModeType.values[sessionData['type']],
          settings: FocusModeSettings.fromJson(sessionData['settings']),
          studySessionId: sessionData['studySessionId'],
          notes: sessionData['notes'],
          systemDndEnabled: sessionData['systemDndEnabled'] ?? false,
        );

        // Check if session should still be active
        if (_activeSession!.endTime != null &&
            DateTime.now().isAfter(_activeSession!.endTime!)) {
          // Session expired, end it
          debugPrint('[FocusModeService] Active session expired, ending...');
          await endFocusMode();
        } else {
          debugPrint('[FocusModeService] Active session restored');
          _sessionController.add(_activeSession);
        }
      }
    } catch (e) {
      debugPrint('[FocusModeService] Error checking active session: $e');
    }
  }

  /// Start focus mode
  ///
  /// @param type The type of focus session
  /// @param duration Optional duration (null = manual end required)
  /// @param studySessionId Optional study session ID if type is studySession
  /// @return true if started successfully, false otherwise
  Future<bool> startFocusMode({
    required FocusModeType type,
    Duration? duration,
    String? studySessionId,
  }) async {
    try {
      debugPrint('[FocusModeService] Starting focus mode (type: $type)');

      // Don't start if already active
      if (_activeSession != null) {
        debugPrint('[FocusModeService] Focus mode already active');
        return false;
      }

      // Create session
      final session = FocusSessionEntity(
        id: const Uuid().v4(),
        startTime: DateTime.now(),
        endTime: duration != null ? DateTime.now().add(duration) : null,
        type: type,
        settings: _settings!,
        studySessionId: studySessionId,
        systemDndEnabled: false,
      );

      // Save current DND state
      _previousDndState = await _dndManager.getCurrentDndState();
      debugPrint(
          '[FocusModeService] Previous DND state: ${_dndManager.getStateNameAr(_previousDndState!)}');

      // Enable system DND if configured
      bool dndEnabled = false;
      if (_settings!.autoEnableSystemDnd) {
        final hasPermission = await _dndManager.hasDndPermission();

        if (hasPermission) {
          dndEnabled = await _dndManager.setDndMode(true);
          debugPrint(
              '[FocusModeService] System DND ${dndEnabled ? "enabled" : "failed to enable"}');
        } else {
          debugPrint(
              '[FocusModeService] DND permission not granted, skipping DND activation');
        }
      }

      // Update session with DND status
      _activeSession = session.copyWith(systemDndEnabled: dndEnabled);

      // Save session
      await _saveActiveSession();

      // Emit session change
      _sessionController.add(_activeSession);

      debugPrint('[FocusModeService] Focus mode started successfully');
      return true;
    } catch (e) {
      debugPrint('[FocusModeService] Error starting focus mode: $e');
      return false;
    }
  }

  /// End focus mode
  ///
  /// @return true if ended successfully, false otherwise
  Future<bool> endFocusMode() async {
    try {
      debugPrint('[FocusModeService] Ending focus mode');

      if (_activeSession == null) {
        debugPrint('[FocusModeService] No active session to end');
        return false;
      }

      // Restore previous DND state
      if (_activeSession!.systemDndEnabled && _previousDndState != null) {
        // Only restore if we changed it
        if (_previousDndState == SystemDndManager.interruptionFilterAll) {
          await _dndManager.setDndMode(false);
          debugPrint('[FocusModeService] System DND restored to normal');
        }
      }

      // Clear session
      _activeSession = null;
      _previousDndState = null;
      await _clearActiveSession();

      // Emit session change
      _sessionController.add(null);

      debugPrint('[FocusModeService] Focus mode ended successfully');
      return true;
    } catch (e) {
      debugPrint('[FocusModeService] Error ending focus mode: $e');
      return false;
    }
  }

  /// Save active session to storage
  Future<void> _saveActiveSession() async {
    try {
      if (_activeSession != null) {
        final sessionData = {
          'id': _activeSession!.id,
          'startTime': _activeSession!.startTime.toIso8601String(),
          'endTime': _activeSession!.endTime?.toIso8601String(),
          'type': _activeSession!.type.index,
          'settings': _activeSession!.settings.toJson(),
          'studySessionId': _activeSession!.studySessionId,
          'notes': _activeSession!.notes,
          'systemDndEnabled': _activeSession!.systemDndEnabled,
        };

        await _sessionBox.put(_activeSessionKey, jsonEncode(sessionData));
        debugPrint('[FocusModeService] Active session saved');
      }
    } catch (e) {
      debugPrint('[FocusModeService] Error saving active session: $e');
    }
  }

  /// Clear active session from storage
  Future<void> _clearActiveSession() async {
    try {
      await _sessionBox.delete(_activeSessionKey);
      debugPrint('[FocusModeService] Active session cleared');
    } catch (e) {
      debugPrint('[FocusModeService] Error clearing active session: $e');
    }
  }

  /// Schedule quiet hours check
  void _scheduleQuietHoursCheck() {
    // Cancel existing timer if any
    _quietHoursTimer?.cancel();

    if (!_settings!.enableQuietHours) return;

    // Check every minute and store timer reference
    _quietHoursTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkQuietHours();
    });

    // Initial check
    _checkQuietHours();
  }

  /// Check if we're in quiet hours and should auto-enable
  Future<void> _checkQuietHours() async {
    if (!_settings!.enableQuietHours) return;
    if (_activeSession != null) return; // Already active

    if (_settings!.isWithinQuietHours()) {
      debugPrint('[FocusModeService] Quiet hours active, starting focus mode');
      await startFocusMode(type: FocusModeType.quietHours);
    }
  }

  /// Check if focus mode should suppress a notification
  ///
  /// @param priority The notification priority level
  /// @param type The notification type
  /// @return true if notification should be suppressed, false otherwise
  bool shouldSuppressNotification({
    required NotificationPriority priority,
    String? type,
  }) {
    if (!isFocusModeActive) return false;
    if (!_settings!.suppressOwnNotifications) return false;

    // Critical alerts always bypass
    if (_settings!.allowCriticalAlerts &&
        priority == NotificationPriority.critical) {
      return false;
    }

    // Prayer reminders bypass if allowed
    if (_settings!.allowPrayerReminders && type == 'prayer') {
      return false;
    }

    // Achievement notifications bypass if allowed
    if (_settings!.allowAchievementNotifications && type == 'achievement') {
      return false;
    }

    // Check priority filter
    return priority.index < _settings!.minimumPriority.index;
  }

  /// Dispose
  void dispose() {
    // Cancel timer
    _quietHoursTimer?.cancel();

    // Close stream controllers
    _sessionController.close();
    _settingsController.close();

    // Close Hive boxes
    _settingsBox.close();
    _sessionBox.close();
  }
}
