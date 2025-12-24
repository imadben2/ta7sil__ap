import 'dart:async';
import 'package:flutter/widgets.dart';
import '../../features/planner/presentation/bloc/planner_bloc.dart';
import '../../features/planner/presentation/bloc/planner_event.dart';
import '../../features/planner/presentation/bloc/planner_state.dart';
import '../../features/planner/presentation/bloc/settings_cubit.dart';
import '../../features/planner/presentation/bloc/settings_state.dart';
import '../../features/planner/data/services/background_sync_service.dart';
import '../../features/planner/services/session_notification_service.dart';
import 'connectivity_service.dart';

/// Observer for app lifecycle events and connectivity changes
///
/// Triggers session lifecycle checks when:
/// 1. App returns to foreground (with debounce)
/// 2. At midnight for day transition
/// 3. Network connectivity is restored
class AppLifecycleObserver with WidgetsBindingObserver {
  final PlannerBloc plannerBloc;
  final SettingsCubit settingsCubit;
  final BackgroundSyncService syncService;
  final ConnectivityService connectivityService;
  final SessionNotificationService sessionNotificationService;

  Timer? _midnightTimer;
  DateTime? _lastForegroundCheck;
  StreamSubscription<bool>? _connectivitySubscription;

  /// Minimum time between foreground checks (debounce)
  static const Duration _foregroundDebounce = Duration(minutes: 5);

  AppLifecycleObserver({
    required this.plannerBloc,
    required this.settingsCubit,
    required this.syncService,
    required this.connectivityService,
    required this.sessionNotificationService,
  }) {
    WidgetsBinding.instance.addObserver(this);
    _scheduleMidnightCheck();
    _listenToConnectivity();
  }

  /// Initialize observer - call this at app startup
  void init() {
    // Trigger initial lifecycle check
    plannerBloc.add(const CheckSessionLifecycleEvent());
  }

  /// Listen to connectivity changes and trigger sync when network is restored
  void _listenToConnectivity() {
    _connectivitySubscription = connectivityService.onConnectivityChanged.listen(
      (isConnected) {
        if (isConnected) {
          // Network restored - trigger background sync
          syncService.processQueue();
        }
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _onAppResumed();
    }
  }

  /// Handle app returning to foreground
  void _onAppResumed() async {
    final now = DateTime.now();

    // Debounce check - don't run if we checked recently
    if (_lastForegroundCheck != null) {
      final timeSinceLastCheck = now.difference(_lastForegroundCheck!);
      if (timeSinceLastCheck < _foregroundDebounce) {
        return;
      }
    }

    _lastForegroundCheck = now;

    // Trigger lifecycle check
    plannerBloc.add(const CheckSessionLifecycleEvent());

    // Sync notifications on app resume
    await _syncNotifications();
  }

  /// Schedule check for midnight (day transition)
  void _scheduleMidnightCheck() {
    _midnightTimer?.cancel();

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = midnight.difference(now);

    _midnightTimer = Timer(timeUntilMidnight, () async {
      // Trigger lifecycle check at midnight
      plannerBloc.add(const CheckSessionLifecycleEvent());

      // Sync notifications for new day
      await _syncNotifications();

      // Schedule next midnight check
      _scheduleMidnightCheck();
    });
  }

  /// Sync scheduled notifications with current sessions
  ///
  /// Called on app resume and midnight to ensure notifications stay up-to-date
  Future<void> _syncNotifications() async {
    try {
      // Get current planner state
      final currentState = plannerBloc.state;

      if (currentState is! ScheduleLoaded) {
        debugPrint('[AppLifecycleObserver] Planner not loaded, skipping sync');
        return;
      }

      // Get settings from SettingsCubit
      final settingsState = settingsCubit.state;

      if (!settingsState.hasSettings) {
        debugPrint('[AppLifecycleObserver] Settings not loaded, skipping sync');
        return;
      }

      // Check if reminders are enabled
      if (!settingsState.settings!.sessionReminders) {
        debugPrint('[AppLifecycleObserver] Session reminders disabled, skipping sync');
        return;
      }

      // Get upcoming scheduled sessions (limit to 64 for Android notification limit)
      final now = DateTime.now();
      final upcomingSessions = currentState.sessions
          .where((s) => s.status.name == 'scheduled')
          .where((s) {
            final sessionStart = DateTime(
              s.scheduledDate.year,
              s.scheduledDate.month,
              s.scheduledDate.day,
              s.scheduledStartTime.hour,
              s.scheduledStartTime.minute,
            );
            return sessionStart.isAfter(now);
          })
          .toList()
        ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

      final sessionsToSync = upcomingSessions.take(64).toList();

      // Sync notifications (cancel orphaned, schedule missing)
      await sessionNotificationService.syncScheduledNotifications(
        sessionsToSync,
        settingsState.settings!.reminderMinutesBefore,
      );

      // Cleanup past notifications
      await sessionNotificationService.cleanupPastNotifications();

      debugPrint('[AppLifecycleObserver] Notification sync completed - ${sessionsToSync.length} sessions');
    } catch (e) {
      debugPrint('[AppLifecycleObserver] Error syncing notifications: $e');
    }
  }

  /// Force a lifecycle check manually
  void forceCheck() {
    plannerBloc.add(const CheckSessionLifecycleEvent());
  }

  /// Dispose of observer - call when no longer needed
  void dispose() {
    _midnightTimer?.cancel();
    _connectivitySubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }
}

/// Mixin to add lifecycle checking to StatefulWidgets
/// Use this on screens that display sessions
mixin SessionLifecycleCheckMixin<T extends StatefulWidget> on State<T> {
  Timer? _periodicTimer;

  /// Override this to provide the PlannerBloc
  PlannerBloc get plannerBloc;

  /// Interval for periodic checks (default: 1 minute)
  Duration get checkInterval => const Duration(minutes: 1);

  @override
  void initState() {
    super.initState();
    // Start periodic check for overdue sessions
    _startPeriodicCheck();
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicCheck() {
    _periodicTimer = Timer.periodic(checkInterval, (_) {
      // Check for overdue sessions while the screen is visible
      plannerBloc.add(const LoadOverdueSessionsEvent());
    });
  }

  /// Call this to trigger a manual check
  void checkSessionLifecycle() {
    plannerBloc.add(const CheckSessionLifecycleEvent());
  }
}
