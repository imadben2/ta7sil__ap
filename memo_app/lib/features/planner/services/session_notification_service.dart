import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../../core/services/notification_service.dart';
import '../domain/entities/study_session.dart';
import 'notification_id_manager.dart';

/// Service for managing session reminder notifications
/// Schedules local notifications before study sessions start
class SessionNotificationService {
  final NotificationService _notificationService;
  final NotificationIdManager _notificationIdManager;

  SessionNotificationService({
    required NotificationService notificationService,
    required NotificationIdManager notificationIdManager,
  })  : _notificationService = notificationService,
        _notificationIdManager = notificationIdManager;

  // ===== PUBLIC API =====

  /// Schedule a notification for a single session
  Future<void> scheduleSessionNotification(
    StudySession session,
    int reminderMinutes,
  ) async {
    try {
      // Skip if session is not scheduled status
      if (session.status != SessionStatus.scheduled) {
        debugPrint(
            '[SessionNotificationService] Skipping non-scheduled session ${session.id}');
        return;
      }

      // Calculate notification time
      final notificationTime =
          _calculateNotificationTime(session, reminderMinutes);

      // Skip if notification time is in the past
      if (notificationTime == null || notificationTime.isBefore(DateTime.now())) {
        debugPrint(
            '[SessionNotificationService] Skipping past notification for session ${session.id}');
        return;
      }

      // Generate notification ID
      final notificationId =
          _notificationIdManager.generateUniqueId(session.id);

      // Build content
      final title = _buildTitle(session);
      final body = await _buildBody(session);
      final payload = _buildPayload(session);

      // Schedule notification
      await _notificationService.scheduleLocalNotification(
        id: notificationId,
        title: title,
        body: body,
        scheduledTime: notificationTime,
        payload: payload,
      );

      // Save mapping
      await _notificationIdManager.saveMapping(
        session.id,
        notificationId,
        notificationTime,
      );

      debugPrint(
          '[SessionNotificationService] Scheduled notification $notificationId for session ${session.id} at $notificationTime');
    } catch (e) {
      debugPrint('[SessionNotificationService] Error scheduling: $e');
    }
  }

  /// Schedule notifications for multiple sessions (bulk)
  Future<void> scheduleMultipleSessions(
    List<StudySession> sessions,
    int reminderMinutes,
  ) async {
    try {
      // Filter valid sessions
      final now = DateTime.now();
      final validSessions = sessions.where((session) {
        if (session.status != SessionStatus.scheduled) return false;

        final notificationTime =
            _calculateNotificationTime(session, reminderMinutes);
        return notificationTime != null && notificationTime.isAfter(now);
      }).toList();

      // Sort by date
      validSessions
          .sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

      // Limit to 64 (Android notification limit)
      final sessionsToSchedule = validSessions.take(64).toList();

      debugPrint(
          '[SessionNotificationService] Scheduling ${sessionsToSchedule.length} sessions');

      // Schedule in batches to avoid blocking UI
      const batchSize = 10;
      for (var i = 0; i < sessionsToSchedule.length; i += batchSize) {
        final batch = sessionsToSchedule.skip(i).take(batchSize);

        await Future.wait(
          batch.map((s) => scheduleSessionNotification(s, reminderMinutes)),
        );

        // Yield to event loop
        await Future.delayed(const Duration(milliseconds: 10));
      }

      debugPrint(
          '[SessionNotificationService] Successfully scheduled ${sessionsToSchedule.length} notifications');
    } catch (e) {
      debugPrint('[SessionNotificationService] Error bulk scheduling: $e');
    }
  }

  /// Reschedule a session notification (cancel old, schedule new)
  Future<void> rescheduleSessionNotification(
    StudySession session,
    int reminderMinutes,
  ) async {
    try {
      // Cancel existing notification
      await cancelSessionNotification(session.id);

      // Schedule new notification if applicable
      if (session.status == SessionStatus.scheduled) {
        await scheduleSessionNotification(session, reminderMinutes);
      }

      debugPrint(
          '[SessionNotificationService] Rescheduled notification for session ${session.id}');
    } catch (e) {
      debugPrint('[SessionNotificationService] Error rescheduling: $e');
    }
  }

  /// Cancel a notification for a session
  Future<void> cancelSessionNotification(String sessionId) async {
    try {
      final notificationId =
          await _notificationIdManager.getNotificationId(sessionId);

      if (notificationId != null) {
        await _notificationService.cancelLocalNotification(notificationId);
        await _notificationIdManager.removeMapping(sessionId);

        debugPrint(
            '[SessionNotificationService] Cancelled notification for session $sessionId');
      }
    } catch (e) {
      debugPrint('[SessionNotificationService] Error canceling: $e');
    }
  }

  /// Cancel notifications for multiple sessions
  Future<void> cancelMultipleSessions(List<String> sessionIds) async {
    try {
      for (final sessionId in sessionIds) {
        await cancelSessionNotification(sessionId);
      }

      debugPrint(
          '[SessionNotificationService] Cancelled ${sessionIds.length} notifications');
    } catch (e) {
      debugPrint('[SessionNotificationService] Error bulk canceling: $e');
    }
  }

  /// Cancel all session notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationService.cancelAllLocalNotifications();
      await _notificationIdManager.clearAllMappings();

      debugPrint(
          '[SessionNotificationService] Cancelled all notifications');
    } catch (e) {
      debugPrint('[SessionNotificationService] Error canceling all: $e');
    }
  }

  /// Sync scheduled notifications with current sessions
  /// Cancels orphaned notifications and schedules missing ones
  Future<void> syncScheduledNotifications(
    List<StudySession> activeSessions,
    int reminderMinutes,
  ) async {
    try {
      // Get all current mappings
      final mappings = await _notificationIdManager.getAllMappings();
      final activeSessionIds = activeSessions.map((s) => s.id).toSet();

      // Cancel orphaned notifications (sessions that no longer exist or changed status)
      final orphanedSessionIds =
          mappings.keys.where((id) => !activeSessionIds.contains(id)).toList();

      for (final sessionId in orphanedSessionIds) {
        await cancelSessionNotification(sessionId);
      }

      debugPrint(
          '[SessionNotificationService] Cancelled ${orphanedSessionIds.length} orphaned notifications');

      // Schedule missing notifications
      await scheduleMultipleSessions(activeSessions, reminderMinutes);

      debugPrint('[SessionNotificationService] Sync completed');
    } catch (e) {
      debugPrint('[SessionNotificationService] Error syncing: $e');
    }
  }

  /// Cleanup past notifications and orphaned mappings
  Future<void> cleanupPastNotifications() async {
    try {
      final mappings = await _notificationIdManager.getAllMappingObjects();
      final now = DateTime.now();

      int cleanedCount = 0;

      for (final mapping in mappings) {
        // Check if notification time has passed
        if (mapping.scheduledFor.isBefore(now)) {
          await _notificationService
              .cancelLocalNotification(mapping.notificationId);
          await _notificationIdManager.removeMapping(mapping.sessionId);
          cleanedCount++;
        }
      }

      debugPrint(
          '[SessionNotificationService] Cleaned up $cleanedCount past notifications');
    } catch (e) {
      debugPrint('[SessionNotificationService] Error cleaning up: $e');
    }
  }

  // ===== PRIVATE HELPER METHODS =====

  /// Calculate when the notification should be shown
  DateTime? _calculateNotificationTime(
    StudySession session,
    int reminderMinutes,
  ) {
    try {
      final sessionStart = DateTime(
        session.scheduledDate.year,
        session.scheduledDate.month,
        session.scheduledDate.day,
        session.scheduledStartTime.hour,
        session.scheduledStartTime.minute,
      );

      final notificationTime = sessionStart.subtract(
        Duration(minutes: reminderMinutes),
      );

      return notificationTime;
    } catch (e) {
      debugPrint(
          '[SessionNotificationService] Error calculating time: $e');
      return null;
    }
  }

  /// Build notification title (Arabic)
  String _buildTitle(StudySession session) {
    try {
      // Get subject name from session
      final subject = session.subjectName;

      // Get session type name
      final sessionType = _getSessionTypeName(session.contentPhase ?? 'study');

      return 'تذكير: $subject - $sessionType';
    } catch (e) {
      debugPrint('[SessionNotificationService] Error building title: $e');
      return 'تذكير جلسة دراسية';
    }
  }

  /// Build notification body (Arabic)
  Future<String> _buildBody(StudySession session) async {
    try {
      // Format start time with English numerals (e.g., "3:05 م")
      final hour = session.scheduledStartTime.hour;
      final minute = session.scheduledStartTime.minute;
      final period = hour >= 12 ? 'م' : 'ص';
      final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final startTime = '$hour12:${minute.toString().padLeft(2, '0')} $period';

      // Calculate duration in minutes
      final durationMinutes = session.duration.inMinutes;
      String durationText;
      if (durationMinutes >= 60) {
        final hours = durationMinutes ~/ 60;
        final mins = durationMinutes % 60;
        if (mins > 0) {
          durationText = '$hours ساعة و$mins دقيقة';
        } else {
          durationText = hours == 1 ? 'ساعة واحدة' : '$hours ساعات';
        }
      } else {
        durationText = '$durationMinutes دقيقة';
      }

      // Build body
      String body = 'الوقت: $startTime\nالمدة: $durationText';

      // Add content title if available
      if (session.contentTitle != null && session.contentTitle!.isNotEmpty) {
        body += '\nالموضوع: ${session.contentTitle}';
      }

      return body;
    } catch (e) {
      debugPrint('[SessionNotificationService] Error building body: $e');
      return 'جلسة دراسية قادمة';
    }
  }

  /// Build notification payload for deep linking
  Map<String, dynamic> _buildPayload(StudySession session) {
    return {
      'type': 'session_reminder',
      'sessionId': session.id,
      'subjectId': session.subjectId,
      'scheduledDate': session.scheduledDate.toIso8601String(),
      'route': '/planner/session/${session.id}',
      'action': 'open_session_detail',
    };
  }


  /// Get session type name in Arabic
  String _getSessionTypeName(String contentPhase) {
    switch (contentPhase) {
      case 'understanding':
      case 'initial':
        return 'دراسة أولية';
      case 'review':
        return 'مراجعة';
      case 'theory_practice':
        return 'تطبيق نظري';
      case 'exercise_practice':
        return 'تمارين';
      case 'test':
        return 'اختبار';
      default:
        return 'جلسة دراسية';
    }
  }

  /// Check if session is in the past
  bool _isSessionInPast(StudySession session, DateTime now) {
    try {
      final sessionStart = DateTime(
        session.scheduledDate.year,
        session.scheduledDate.month,
        session.scheduledDate.day,
        session.scheduledStartTime.hour,
        session.scheduledStartTime.minute,
      );

      return sessionStart.isBefore(now);
    } catch (e) {
      return false;
    }
  }
}
