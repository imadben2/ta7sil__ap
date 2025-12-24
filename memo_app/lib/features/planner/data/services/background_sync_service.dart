import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:get_it/get_it.dart';
import '../datasources/planner_sync_queue.dart';
import '../datasources/planner_remote_datasource.dart';
import '../datasources/planner_local_datasource.dart';
import '../models/sync_queue_item.dart';
import '../../../../core/network/network_info.dart';
import 'isolate_di_setup.dart';

/// Background service for syncing queued offline operations
///
/// This service uses WorkManager to schedule periodic background sync tasks
/// and provides manual sync capabilities
class BackgroundSyncService {
  final PlannerSyncQueue syncQueue;
  final PlannerRemoteDataSource remoteDataSource;
  final PlannerLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  static const String syncTaskName = 'planner_background_sync';
  static const String syncTaskTag = 'sync';
  static const String notificationSyncTaskName = 'daily_notification_sync';
  static const String notificationSyncTaskTag = 'notification_sync';

  BackgroundSyncService({
    required this.syncQueue,
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  /// Initialize WorkManager and register periodic task
  ///
  /// Note: WorkManager will run the task approximately every 30 minutes
  /// based on system constraints and battery optimization
  Future<void> init() async {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        // Disable debug notifications - they appear in English and are not user-friendly
        isInDebugMode: false,
      );

      // Cancel all existing tasks to clear any old debug-mode registrations
      await Workmanager().cancelAll();

      // Register periodic task (runs every 15-30 minutes based on system)
      await Workmanager().registerPeriodicTask(
        syncTaskName,
        syncTaskName,
        frequency: const Duration(minutes: 30),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        tag: syncTaskTag,
        inputData: <String, dynamic>{
          'taskName': syncTaskName,
          'registeredAt': DateTime.now().toIso8601String(),
        },
      );

      // Register daily notification sync task (runs every 24 hours at midnight)
      await Workmanager().registerPeriodicTask(
        notificationSyncTaskName,
        notificationSyncTaskName,
        frequency: const Duration(hours: 24),
        initialDelay: _calculateDelayUntilMidnight(),
        constraints: Constraints(
          networkType: NetworkType.not_required,
          requiresBatteryNotLow: false,
          requiresCharging: false,
        ),
        tag: notificationSyncTaskTag,
        inputData: <String, dynamic>{
          'taskName': notificationSyncTaskName,
          'registeredAt': DateTime.now().toIso8601String(),
        },
      );

      debugPrint('[BackgroundSyncService] Initialized with periodic sync every 30 minutes');
      debugPrint('[BackgroundSyncService] Initialized daily notification sync at midnight');
    } catch (e) {
      debugPrint('[BackgroundSyncService] ERROR initializing WorkManager: $e');
      // Don't rethrow - app should continue even if background sync fails to initialize
    }
  }

  /// Process all queued items ready for retry
  ///
  /// Returns [SyncResult] with success/failed/skipped counts
  Future<SyncResult> processQueue() async {
    debugPrint('[BackgroundSyncService] Starting sync process...');

    if (!await networkInfo.isConnected) {
      debugPrint('[BackgroundSyncService] No network connection, skipping sync');
      return SyncResult(success: 0, failed: 0, skipped: syncQueue.pendingCount);
    }

    final itemsToRetry = syncQueue.getItemsToRetry();
    debugPrint('[BackgroundSyncService] Processing ${itemsToRetry.length} items');

    int successCount = 0;
    int failCount = 0;

    for (final item in itemsToRetry) {
      try {
        await _syncItem(item);
        await syncQueue.removeFromQueue(item.id);
        successCount++;
        debugPrint('[BackgroundSyncService] ✓ Synced: ${item.description}');
      } catch (e) {
        await syncQueue.markRetry(item.id, errorMessage: e.toString());
        failCount++;
        debugPrint('[BackgroundSyncService] ✗ Failed: ${item.description} - $e');
      }
    }

    debugPrint('[BackgroundSyncService] Sync complete: $successCount success, $failCount failed');

    // Update last sync timestamp if any items were successfully synced
    if (successCount > 0) {
      await syncQueue.updateLastSyncTimestamp();
    }

    return SyncResult(success: successCount, failed: failCount, skipped: 0);
  }

  /// Sync a single queue item to the API
  Future<void> _syncItem(SyncQueueItem item) async {
    switch (item.operation) {
      case SyncOperation.action:
        await _syncSessionAction(item);
        break;
      case SyncOperation.create:
        // Future: Handle create operations (subjects, exams, settings)
        debugPrint('[BackgroundSyncService] CREATE operation not yet implemented');
        break;
      case SyncOperation.update:
        // Future: Handle update operations
        debugPrint('[BackgroundSyncService] UPDATE operation not yet implemented');
        break;
      case SyncOperation.delete:
        // Future: Handle delete operations
        debugPrint('[BackgroundSyncService] DELETE operation not yet implemented');
        break;
    }
  }

  /// Sync session actions (start, pause, resume, complete, skip, reschedule, pin)
  Future<void> _syncSessionAction(SyncQueueItem item) async {
    final sessionId = item.data['sessionId'] as String;
    final actionType = item.actionType;

    debugPrint('[BackgroundSyncService] Syncing action: $actionType for session: $sessionId');

    switch (actionType) {
      case 'start':
        await remoteDataSource.startSession(sessionId);
        break;
      case 'pause':
        await remoteDataSource.pauseSession(sessionId);
        break;
      case 'resume':
        await remoteDataSource.resumeSession(sessionId);
        break;
      case 'complete':
        await remoteDataSource.completeSession(
          sessionId,
          item.data['completionPercentage'] as int,
          item.data['userNotes'] as String?,
          item.data['mood'] as String?,
        );
        break;
      case 'skip':
        await remoteDataSource.skipSession(
          sessionId,
          item.data['reason'] as String,
        );
        break;
      case 'reschedule':
        final newDate = DateTime.parse(item.data['newDate'] as String);
        final newStartTimeStr = item.data['newStartTime'] as String?;
        final newEndTimeStr = item.data['newEndTime'] as String?;
        // Parse time strings (format: "HH:mm")
        TimeOfDay parseTime(String? timeStr, int defaultHour) {
          if (timeStr != null && timeStr.contains(':')) {
            final parts = timeStr.split(':');
            return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          }
          return TimeOfDay(hour: defaultHour, minute: 0);
        }
        await remoteDataSource.rescheduleSession(
          sessionId,
          newDate,
          parseTime(newStartTimeStr, 8),
          parseTime(newEndTimeStr, 9),
        );
        break;
      case 'pin':
        await remoteDataSource.pinSession(
          sessionId,
          item.data['isPinned'] as bool,
        );
        break;
      default:
        throw Exception('Unknown action type: $actionType');
    }
  }

  /// Calculate delay until next midnight
  ///
  /// Used to schedule daily tasks to run at midnight
  Duration _calculateDelayUntilMidnight() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    return nextMidnight.difference(now);
  }

  /// Cancel all background tasks
  ///
  /// Useful for debugging or when user disables background sync
  Future<void> cancelAllTasks() async {
    try {
      await Workmanager().cancelAll();
      debugPrint('[BackgroundSyncService] All background tasks cancelled');
    } catch (e) {
      debugPrint('[BackgroundSyncService] ERROR cancelling tasks: $e');
    }
  }
}

/// Result of sync operation
class SyncResult {
  final int success;
  final int failed;
  final int skipped;

  SyncResult({
    required this.success,
    required this.failed,
    required this.skipped,
  });

  @override
  String toString() =>
      'SyncResult(success: $success, failed: $failed, skipped: $skipped)';
}

/// Callback dispatcher for WorkManager (runs in isolate)
///
/// This function runs in a separate isolate and cannot access
/// the main app's dependency injection container.
/// It initializes a lightweight DI container with only sync-related dependencies.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('[WorkManager] Executing task: $task');

    try {
      // Initialize DI container in isolate
      await initIsolateDI();
      debugPrint('[WorkManager] DI initialized in isolate');

      bool success = false;

      // Route to appropriate task handler
      switch (task) {
        case BackgroundSyncService.syncTaskName:
          success = await _handleSyncTask();
          break;

        case BackgroundSyncService.notificationSyncTaskName:
          success = await _handleNotificationSyncTask();
          break;

        default:
          debugPrint('[WorkManager] Unknown task: $task');
          success = false;
      }

      // Cleanup DI container
      await cleanupIsolateDI();
      debugPrint('[WorkManager] Task completed successfully');

      return Future.value(success);
    } catch (e, stackTrace) {
      debugPrint('[WorkManager] Task failed: $e');
      debugPrint('[WorkManager] Stack trace: $stackTrace');

      // Attempt cleanup even on failure
      try {
        await cleanupIsolateDI();
      } catch (cleanupError) {
        debugPrint('[WorkManager] Cleanup also failed: $cleanupError');
      }

      return Future.value(false);
    }
  });
}

/// Handle sync queue task
Future<bool> _handleSyncTask() async {
  final syncService = GetIt.instance<BackgroundSyncService>();
  final result = await syncService.processQueue();
  debugPrint('[WorkManager] Sync result: $result');
  return true;
}

/// Handle daily notification sync task
Future<bool> _handleNotificationSyncTask() async {
  try {
    // Note: In a real implementation, we would need to register notification services
    // in isolate DI. For now, this is a placeholder showing the structure.
    // The actual notification sync logic would:
    // 1. Get planner settings to check if reminders are enabled
    // 2. Get next 7 days of scheduled sessions
    // 3. Cleanup past notifications
    // 4. Schedule notifications for upcoming sessions

    debugPrint('[WorkManager] Notification sync task - skipped (notification services not available in isolate)');
    debugPrint('[WorkManager] Note: Notification sync is handled by AppLifecycleObserver on app resume');

    return true;
  } catch (e) {
    debugPrint('[WorkManager] Notification sync failed: $e');
    return false;
  }
}
